import 'package:reslocate/main.dart' show ContextExtension, supabase;
import 'package:flutter/material.dart';
import 'package:reslocate/pages/parent_pages/parent_homepage.dart';
import 'package:reslocate/widgets/mytoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:reslocate/widgets/loadingAnimation.dart';

class Studentdetails extends StatefulWidget {
  const Studentdetails({super.key});

  @override
  State<Studentdetails> createState() => _StudentdetailsState();
}

class _StudentdetailsState extends State<Studentdetails> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  bool _isFlashOn = false;

  Future<void> _linkParentAndStudent(String studentId) async {
    if (_isProcessing) return; // Prevent multiple simultaneous attempts
    setState(() => _isProcessing = true);

    try {
      // First check if student exists with this ID
      final studentResponse = await supabase
          .from('profiles')
          .select('id, is_parent, parent_id')
          .eq('id', studentId)
          .maybeSingle();

      if (studentResponse == null) {
        MyToast.showToast(context, 'No student found with this QR code');
        return;
      }

      // Check if this is a student account
      if (studentResponse['is_parent'] == true) {
        MyToast.showToast(context, 'This QR code belongs to a parent account');
        return;
      }

      // Check if student already has a parent
      if (studentResponse['parent_id'] != null) {
        MyToast.showToast(
            context, 'This student is already linked to a parent');
        return;
      }

      // Get current parent's details
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        MyToast.showToast(context, 'Parent authentication error');
        return;
      }

      final parentResponse = await supabase
          .from('profiles')
          .select('first_name, last_name, phone_number')
          .eq('id', currentUserId)
          .single();

      // Update student's profile with parent's information
      await supabase.from('profiles').update({
        'pfirst_name': parentResponse['first_name'],
        'plast_name': parentResponse['last_name'],
        'pphone_number': parentResponse['phone_number'],
        'parent_id': currentUserId,
      }).eq('id', studentId);

      if (mounted) {
        MyToast.showToast(context, 'Successfully linked with student!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ParentHomepage()),
        );
      }
    } catch (error) {
      print('Error linking parent and student: $error');
      if (mounted) {
        if (error is PostgrestException) {
          MyToast.showToast(context, 'Database error: ${error.message}');
        } else {
          MyToast.showToast(
              context, 'Error linking profiles. Please try again.');
        }
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Student QR Code'),
        actions: [
          // Toggle flash button
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              await cameraController.toggleTorch();
              setState(() {
                _isFlashOn = !_isFlashOn;
              });
            },
          ),
          // Switch camera button
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        _linkParentAndStudent(barcode.rawValue!);
                      }
                    }
                  },
                ),
                // QR code scanning overlay
                CustomPaint(
                  painter: QRScannerOverlayPainter(),
                  child: Container(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Scan your child\'s QR code to link accounts',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: BouncingImageLoader(),
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
}

// Custom painter for QR scanner overlay
class QRScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final Rect scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    final Paint paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // Draw semi-transparent overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRect(scanArea),
      ),
      paint,
    );

    // Draw scanning area border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(scanArea, borderPaint);

    // Draw corner markers
    final cornerLength = scanAreaSize * 0.1;
    final cornerPaint = Paint()
      ..color = const Color(0xFF0D47A1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Top left corner
    canvas.drawPath(
      Path()
        ..moveTo(scanArea.left, scanArea.top + cornerLength)
        ..lineTo(scanArea.left, scanArea.top)
        ..lineTo(scanArea.left + cornerLength, scanArea.top),
      cornerPaint,
    );

    // Top right corner
    canvas.drawPath(
      Path()
        ..moveTo(scanArea.right - cornerLength, scanArea.top)
        ..lineTo(scanArea.right, scanArea.top)
        ..lineTo(scanArea.right, scanArea.top + cornerLength),
      cornerPaint,
    );

    // Bottom left corner
    canvas.drawPath(
      Path()
        ..moveTo(scanArea.left, scanArea.bottom - cornerLength)
        ..lineTo(scanArea.left, scanArea.bottom)
        ..lineTo(scanArea.left + cornerLength, scanArea.bottom),
      cornerPaint,
    );

    // Bottom right corner
    canvas.drawPath(
      Path()
        ..moveTo(scanArea.right - cornerLength, scanArea.bottom)
        ..lineTo(scanArea.right, scanArea.bottom)
        ..lineTo(scanArea.right, scanArea.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
