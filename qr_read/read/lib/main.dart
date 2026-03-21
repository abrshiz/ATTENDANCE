import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class QRToPdfScanner extends StatefulWidget {
  const QRToPdfScanner({super.key});

  @override
  State<QRToPdfScanner> createState() => _QRToPdfScannerState();
}

class _QRToPdfScannerState extends State<QRToPdfScanner> {
  bool isScanning = true;

  // 1. Function to Generate and Show the PDF
  Future<void> _generatePdf(
    String id,
    String name,
    Uint8List? imageBytes,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            // Corrected: Use named argument 'crossAxisAlignment'
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, text: "User Scan Report"),
              pw.SizedBox(height: 20),
              pw.Text("User ID: $id", style: pw.TextStyle(fontSize: 18)),
              pw.Text("User Name: $name", style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 30),
              pw.Text("Captured Scan Image:"),
              pw.SizedBox(height: 10),
              if (imageBytes != null)
                pw.Center(
                  child: pw.Image(pw.MemoryImage(imageBytes), width: 300),
                ),
              pw.Divider(),
              pw.Text("Generated on ${DateTime.now()}"),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
  // 2. Open PDF Preview (allows saving to phone or printing)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR to PDF")),
      body: isScanning
          ? MobileScanner(
              // returnImage: true captures the frame where the QR was found
              controller: MobileScannerController(returnImage: true),
              onDetect: (capture) async {
                final List<Barcode> barcodes = capture.barcodes;
                final Uint8List? image =
                    capture.image; // The "image" you asked for

                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    setState(() => isScanning = false); // Stop scanner

                    try {
                      // Parse the JSON data
                      final data = jsonDecode(barcode.rawValue!);
                      final String id = data['id']?.toString() ?? "N/A";
                      final String name = data['name'] ?? "Unknown";

                      // Proceed to PDF generation
                      await _generatePdf(id, name, image);
                    } catch (e) {
                      debugPrint("Invalid JSON in QR: $e");
                    }

                    setState(
                      () => isScanning = true,
                    ); // Restart scanner after PDF closes
                  }
                }
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
