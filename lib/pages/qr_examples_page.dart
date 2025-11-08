import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrExamplesPage extends StatelessWidget {
  const QrExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scalable: Add more clinic locations here in the future
    final List<Map<String, String>> qrCodes = [
      {
        'name': 'Bath and Bark Clinic',
        'url': 'https://bathandbarkclinic.com/checkin?id=BBC001&site=main',
      },
      // Add more clinic locations here:
      // {
      //   'name': 'Your Clinic Name - Branch',
      //   'url': 'https://yourclinic.com/checkin?id=YC001&site=branch',
      // },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic QR Codes'),
        backgroundColor: const Color(0xFFE2BF65),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: qrCodes.length,
        itemBuilder: (context, index) {
          final qr = qrCodes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 24),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    qr['name']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  QrImageView(
                    data: qr['url']!,
                    version: QrVersions.auto,
                    size: 250.0,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    qr['url']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
