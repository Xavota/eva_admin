import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class RemotePdfPreview extends StatefulWidget {
  final String pdfUrl;
  const RemotePdfPreview({super.key, required this.pdfUrl});

  @override
  State<RemotePdfPreview> createState() => _RemotePdfPreviewState();
}

class _RemotePdfPreviewState extends State<RemotePdfPreview> {
  Uint8List? pdfBytes;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    final response = await http.get(Uri.parse(widget.pdfUrl));
    if (response.statusCode == 200) {
      setState(() {
        pdfBytes = response.bodyBytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pdfBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return PdfPreview(
      allowPrinting: false,
      allowSharing: false,
      canChangeOrientation: false,
      canChangePageFormat: false,
      build: (format) async => pdfBytes!,
    );
  }
}
