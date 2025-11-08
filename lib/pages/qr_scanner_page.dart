import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:paws/pages/check_in_form_page.dart';
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
        
        // Validate and process QR code
        _validateAndProcessQRCode(code);
        break;
      }
    }
  }

  void _validateAndProcessQRCode(String qrCode) {
    // Validate if QR code is official
    final validationResult = _validateOfficialQRCode(qrCode);
    
    if (validationResult['isValid'] == true) {
      // Navigate to check-in form page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckInFormPage(
            clinicName: validationResult['clinicName'] as String,
            qrCode: qrCode,
          ),
        ),
      ).then((_) {
        // Reset scan state when returning from form
        if (mounted) {
          setState(() => _isScanned = false);
        }
      });
    } else {
      // Show error for invalid QR code
      _showInvalidQRDialog(validationResult['error'] as String);
    }
  }

  Map<String, dynamic> _validateOfficialQRCode(String qrCode) {
    // Security: Check if QR code is empty or too short
    if (qrCode.isEmpty || qrCode.length < 10) {
      return {
        'isValid': false,
        'error': 'Invalid QR code format',
      };
    }

    // Security: Check for SQL injection attempts or malicious characters
    final dangerousPatterns = [
      RegExp(r'''[';\"\\]'''),  // SQL injection characters
      RegExp(r'<script', caseSensitive: false),  // XSS attempts
      RegExp(r'javascript:', caseSensitive: false),  // JavaScript injection
    ];

    for (final pattern in dangerousPatterns) {
      if (pattern.hasMatch(qrCode)) {
        return {
          'isValid': false,
          'error': 'Security violation detected',
        };
      }
    }

    // Validate official QR code format
    // Expected format: https://[domain]/checkin?id=[ID]&site=[site_identifier]
    // Scalable: Add more domains to the list as needed
    final authorizedDomains = [
      'bathandbarkclinic.com',
      // Add more clinic domains here in the future:
      // 'anotherclinic.com',
      // 'yourclinic.com',
    ];

    // Build regex pattern from authorized domains
    final domainPattern = authorizedDomains.map((d) => d.replaceAll('.', r'\.')).join('|');
    final urlPattern = RegExp(
      r'^https?://([a-zA-Z0-9.-]+\.)?(' + domainPattern + r')/checkin\?.*$',
      caseSensitive: false,
    );

    if (!urlPattern.hasMatch(qrCode)) {
      return {
        'isValid': false,
        'error': 'This QR code is not from an authorized clinic',
      };
    }

    // Parse clinic name from validated QR code
    final clinicName = _parseClinicName(qrCode);
    
    if (clinicName.isEmpty || clinicName.startsWith('Clinic:')) {
      return {
        'isValid': false,
        'error': 'Unable to identify clinic from QR code',
      };
    }

    return {
      'isValid': true,
      'clinicName': clinicName,
    };
  }

  void _showInvalidQRDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('Invalid QR Code'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorMessage),
            const SizedBox(height: 16),
            const Text(
              'Please scan an official clinic QR code.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to previous screen
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
              setState(() {
                _isScanned = false; // Allow scanning again
              });
            },
            child: const Text('Scan Again'),
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
      return 'Bath and Bark Clinic';
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
