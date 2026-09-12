import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'scanner_screen.dart';

class DashboardScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const DashboardScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icon/app_icon_no_bg.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            const Text(
              "AgriVox",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade600),
            ),
            child: Row(
              children: [
                Icon(Icons.airplanemode_active, size: 14, color: Colors.green.shade900),
                const SizedBox(width: 4),
                Text(
                  "Offline Mode",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                ),
              ],
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade900, Colors.green.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade900.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "AI CONCLAVE 2026 • AJCE",
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Offline Crop Doctor &\nVoice Copilot",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.25),
                ),
                const SizedBox(height: 8),
                Text(
                  "On-device lesion detection in <40ms. KAU agronomy treatments in Malayalam & English with zero internet.",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Primary Scan Action Card
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScannerScreen(cameras: cameras),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Icon(Icons.camera_alt, color: Colors.green.shade800, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Scan Crop Leaf Lesion",
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Center leaf in the viewfinder for instant offline diagnosis",
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 18, color: Colors.green.shade700),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Supported Crops Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Supported Crops",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Text(
                  "8 Crops • 25 Prescriptions",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 8-Crop Badges Grid (Paddy, Coconut, Banana, Brinjal, Okra, Pepper, Tomato, Potato)
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.88,
            children: [
              _buildCropGridItem(context, "Paddy", "നെല്ല്", "🌾", "Paddy"),
              _buildCropGridItem(context, "Coconut", "തെങ്ങ്", "🥥", "Coconut"),
              _buildCropGridItem(context, "Banana", "വാഴ", "🍌", "Banana"),
              _buildCropGridItem(context, "Brinjal", "വഴുതന", "🍆", "Brinjal"),
              _buildCropGridItem(context, "Okra", "വെണ്ട", "🥬", "Okra"),
              _buildCropGridItem(context, "Pepper", "കാപ്സിക്കം", "🌶️", "Pepper"),
              _buildCropGridItem(context, "Tomato", "തക്കാളി", "🍅", "Tomato"),
              _buildCropGridItem(context, "Potato", "ഉരുളക്കിഴങ്ങ്", "🥔", "Potato"),
            ],
          ),

          const SizedBox(height: 24),

          // Pipeline Specs Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.speed, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Edge AI Specifications",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _buildSpecRow("Vision Architecture", "Dual-Engine: YOLOv8n-cls + KAU Dual-Mode"),
                _buildSpecRow("Input Tensor Resolution", "224 × 224 × 3 (Center-crop)"),
                _buildSpecRow("Average Latency", "<40 ms (Offline CPU/GPU)"),
                _buildSpecRow("Agronomy Database", "KAU Package of Practices (25 Classes)"),
                _buildSpecRow("Voice Engine", "Indic Malayalam / English TTS"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropGridItem(
    BuildContext context,
    String titleEn,
    String titleMl,
    String emoji,
    String cropKey,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScannerScreen(
                cameras: cameras,
                initialCrop: cropKey,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                titleEn,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Text(
                titleMl,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 9.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
