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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 20),
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
              Text(
                "Supported Crops (KAU Dataset)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
              Text(
                "10 Classes",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green.shade700),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Crop Badges Grid
          Row(
            children: [
              _buildCropCard("Tomato", "തക്കാളി", Icons.circle, Colors.red.shade700),
              const SizedBox(width: 10),
              _buildCropCard("Potato", "ഉരുളക്കിഴങ്ങ്", Icons.grass, Colors.brown.shade600),
              const SizedBox(width: 10),
              _buildCropCard("Bell Pepper", "കാപ്സിക്കം", Icons.spa, Colors.deepOrange.shade600),
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
                _buildSpecRow("Vision Architecture", "YOLOv8n-cls (INT8 Quantized)"),
                _buildSpecRow("Input Tensor Resolution", "224 × 224 × 3 (Center-crop)"),
                _buildSpecRow("Average Latency", "<40 ms (Offline CPU/GPU)"),
                _buildSpecRow("Agronomy Database", "KAU Package of Practices 2024"),
                _buildSpecRow("Voice Engine", "Indic Malayalam / English TTS"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropCard(String titleEn, String titleMl, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(titleEn, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(titleMl, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ],
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
