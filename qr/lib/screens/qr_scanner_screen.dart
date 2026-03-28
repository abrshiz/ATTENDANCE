import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/student.dart';

class QRScannerScreen extends StatefulWidget {
  final Function(Student) onStudentScanned;

  const QRScannerScreen({super.key, required this.onStudentScanned});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;
  String lastScannedId = "";

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? scannedData = barcode.rawValue;
      if (scannedData != null && scannedData != lastScannedId) {
        try {
          final Map<String, dynamic> data = jsonDecode(scannedData);
          final student = Student(
            id: data['id'],
            name: data['name'],
            timestamp: DateTime.parse(data['timestamp']),
            status: AttendanceStatus.present,
          );

          setState(() {
            isScanning = false;
            lastScannedId = scannedData;
          });

          widget.onStudentScanned(student);
          _showSuccessDialog(student);
        } catch (e) {
          _showMessage("Invalid QR Code", Colors.red);
        }
        break;
      }
    }
  }

  void _showSuccessDialog(Student student) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Attendance Marked"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Student: ${student.name}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("ID: ${student.id}"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text(
                    "Marked as Present",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isScanning = true;
                lastScannedId = "";
              });
            },
            child: const Text("Scan Next"),
          ),
        ],
      ),
    );
  }

  void _showMessage(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Stack(
            children: [
              MobileScanner(controller: cameraController, onDetect: _onDetect),
              // Scanner overlay
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(40),
                child: const Center(
                  child: Text(
                    "Scan QR Code",
                    style: TextStyle(
                      color: Colors.white,
                      backgroundColor: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                "QR Code Scanner",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Position the QR code within the frame",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      cameraController.torchState == TorchState.off
                          ? Icons.flashlight_off
                          : Icons.flashlight_on,
                      size: 28,
                    ),
                    onPressed: () => cameraController.toggleTorch(),
                    tooltip: "Toggle Flashlight",
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.switch_camera, size: 28),
                    onPressed: () => cameraController.switchCamera(),
                    tooltip: "Switch Camera",
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension on MobileScannerController {
  get torchState => null;
}
