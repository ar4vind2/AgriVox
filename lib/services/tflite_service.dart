import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/disease_prescription.dart';

class TFLiteService {
  static final TFLiteService _instance = TFLiteService._internal();
  factory TFLiteService() => _instance;
  TFLiteService._internal();

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;

  Future<void> initialize() async {
    try {
      try {
        final labelData = await rootBundle.loadString('assets/models/labels.txt');
        _labels = labelData.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      } catch (_) {
        debugPrint("labels.txt not present in assets, ready for Member 1 handoff");
      }

      try {
        _interpreter = await Interpreter.fromAsset('assets/models/yolov8n-cls_int8.tflite');
        _isModelLoaded = true;
        debugPrint("TFLite model loaded successfully from assets");
      } catch (e) {
        debugPrint("TFLite model pending from Member 1 ($e). Running in Dual-Mode (Mock inference active).");
        _isModelLoaded = false;
      }
    } catch (e) {
      debugPrint("TFLite initialization error: $e");
    }
  }

  Future<({File croppedImageFile, DiseasePrescription prescription})> processAndClassify(String imagePath) async {
    final rawBytes = await File(imagePath).readAsBytes();
    final originalImage = img.decodeImage(rawBytes);

    if (originalImage == null) {
      throw Exception("Failed to decode captured camera image");
    }

    // Center crop: extract the square matching the aiming reticle
    final cropSize = (originalImage.width < originalImage.height ? originalImage.width : originalImage.height) * 0.7;
    final x = ((originalImage.width - cropSize) / 2).round();
    final y = ((originalImage.height - cropSize) / 2).round();

    final cropped = img.copyCrop(
      originalImage,
      x: x,
      y: y,
      width: cropSize.round(),
      height: cropSize.round(),
    );

    // Resize to standard input tensor resolution (224x224)
    final resized = img.copyResize(cropped, width: 224, height: 224);

    final tempDir = Directory.systemTemp;
    final croppedFilePath = '${tempDir.path}/agrivox_crop_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final croppedFile = File(croppedFilePath);
    await croppedFile.writeAsBytes(img.encodeJpg(resized, quality: 90));

    if (_isModelLoaded && _interpreter != null) {
      final prescription = await _runTFLiteInference(resized);
      return (croppedImageFile: croppedFile, prescription: prescription);
    }

    // Realistic offline edge simulation latency (~45ms)
    await Future.delayed(const Duration(milliseconds: 50));
    final sample = DiseasePrescription.samplePrescriptions.first;
    return (croppedImageFile: croppedFile, prescription: sample);
  }

  Future<DiseasePrescription> _runTFLiteInference(img.Image image) async {
    final input = List.generate(
      1,
      (b) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = image.getPixel(x, y);
            return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
          },
        ),
      ),
    );

    final numClasses = _labels.isNotEmpty ? _labels.length : 10;
    final output = List.generate(1, (_) => List<double>.filled(numClasses, 0.0));

    _interpreter!.run(input, output);

    final probabilities = output[0];
    int maxIndex = 0;
    double maxScore = probabilities[0];

    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxScore) {
        maxScore = probabilities[i];
        maxIndex = i;
      }
    }

    final detectedLabel = (_labels.isNotEmpty && maxIndex < _labels.length)
        ? _labels[maxIndex]
        : 'rubber_abnormal_leaf_fall';

    return DiseasePrescription.samplePrescriptions.firstWhere(
      (p) => p.diseaseId.toLowerCase() == detectedLabel.toLowerCase(),
      orElse: () => DiseasePrescription.samplePrescriptions.first,
    );
  }
}
