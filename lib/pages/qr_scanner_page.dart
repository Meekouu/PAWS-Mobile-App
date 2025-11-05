import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:paws/themes/themes.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanned = false;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
        _isCheckingPermission = false;
      });
    } else {
      final result = await Permission.camera.request();
      setState(() {
        _hasPermission = result.isGranted;
        _isCheckingPermission = false;
      });
      
      if (!result.isGranted) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'This app needs camera access to scan QR codes. Please grant camera permission in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null) {
        setState(() {
          _isScanned = true;
        });
        
        // Show clinic information
        _showClinicDialog(code);
        break;
      }
    }
  }

  void _showClinicDialog(String qrCode) {
    // Parse QR code to determine clinic
    String clinicName = _parseClinicName(qrCode);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Clinic Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You can check into:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              clinicName,
              style: const TextStyle(
                fontSize: 18,
                color: secondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'QR Code: $qrCode',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanned = false;
              });
            },
            child: const Text('Scan Again'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _parseClinicName(String qrCode) {
    // You can customize this logic based on your QR code format
    // For now, it will check if the QR code contains specific keywords
    
    if (qrCode.toLowerCase().contains('paws') || 
        qrCode.toLowerCase().contains('clinic')) {
      return 'PAWS Veterinary Clinic';
    } else if (qrCode.toLowerCase().contains('emergency')) {
      return 'Emergency Pet Care Center';
    } else if (qrCode.toLowerCase().contains('animal') || 
               qrCode.toLowerCase().contains('hospital')) {
      return 'Animal Hospital';
    } else {
      // Default or parse from QR code format
      return qrCode.length > 30 
          ? 'Clinic: ${qrCode.substring(0, 30)}...'
          : 'Clinic: $qrCode';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Clinic QR Code'),
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_hasPermission) ...[
            IconButton(
              icon: const Icon(Icons.flash_on, color: Colors.white),
              onPressed: () => cameraController.toggleTorch(),
            ),
            IconButton(
              icon: const Icon(Icons.cameraswitch, color: Colors.white),
              onPressed: () => cameraController.switchCamera(),
            ),
          ],
        ],
      ),
      body: _isCheckingPermission
          ? const Center(
              child: CircularProgressIndicator(color: secondaryColor),
            )
          : !_hasPermission
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Camera permission is required',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _checkCameraPermission,
                        child: const Text('Grant Permission'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    MobileScanner(
                      controller: cameraController,
                      onDetect: _onDetect,
                    ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Point your camera at a clinic QR code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: secondaryColor,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
                  ],
                ),
    );
  }
}
