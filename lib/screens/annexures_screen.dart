import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class AnnexuresScreen extends StatefulWidget {
  const AnnexuresScreen({super.key});

  @override
  State<AnnexuresScreen> createState() => _AnnexuresScreenState();
}

class _AnnexuresScreenState extends State<AnnexuresScreen> {
  String? _localPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final path = await _fromAsset('assets/Annexures.pdf', 'Annexures.pdf');
      if (mounted) {
        setState(() {
          _localPath = path;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading PDF: $e')),
        );
      }
    }
  }

  Future<String> _fromAsset(String asset, String filename) async {
    // To open an asset bundle file, it must be saved to a local file.
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    // Always overwrite to ensure latest version
    final data = await rootBundle.load(asset);
    final bytes = data.buffer.asUint8List();
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annexures'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _localPath == null
              ? const Center(child: Text('Failed to load PDF'))
              : PDFView(
                  filePath: _localPath,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  pageSnap: true,
                  onError: (error) {
                    print(error.toString());
                  },
                  onPageError: (page, error) {
                    print('$page: ${error.toString()}');
                  },
                ),
    );
  }
}
