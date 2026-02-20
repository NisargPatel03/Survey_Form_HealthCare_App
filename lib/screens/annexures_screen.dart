import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AnnexuresScreen extends StatefulWidget {
  const AnnexuresScreen({super.key});

  @override
  State<AnnexuresScreen> createState() => _AnnexuresScreenState();
}

class _AnnexuresScreenState extends State<AnnexuresScreen> {
  String? _localPath;
  bool _isLoading = true;
  String _selectedPdfName = 'General Annexures';

  final Map<String, String> _pdfFiles = {
    'General Annexures': 'assets/Annexures.pdf',
    'Family Care Study Format': 'assets/pdfs/family_care_study.pdf',
    'Family Care Plan Format': 'assets/pdfs/family_care_plan.pdf',
    'Individual Health Talk': 'assets/pdfs/individual_health_talk.pdf',
    'Group Health Talk': 'assets/pdfs/group_health_talk.pdf',
    'Orientation Report': 'assets/pdfs/orientation_report.pdf',
    'School Health Program': 'assets/pdfs/school_health_program.pdf',
    'School Health Program Guidelines': 'assets/pdfs/school_health_program_guidelines.pdf',
    'Anganwadi Assessment Report': 'assets/pdfs/anganwadi_assessment_report.pdf',
    'Anganwadi Assessment Guidelines': 'assets/pdfs/anganwadi_assessment_guidelines.pdf',
    'Health Exhibition Report': 'assets/pdfs/health_exhibition_report.pdf',
    'Health Exhibition Guidelines': 'assets/pdfs/health_exhibition_guidelines.pdf',
    'Health Screening Camp Report A': 'assets/pdfs/health_screening_camp_report_a.pdf',
    'Health Screening Camp Report B': 'assets/pdfs/health_screening_camp_report_b.pdf',
    'Role Play Report A': 'assets/pdfs/role_play_report_a.pdf',
    'Role Play Report B': 'assets/pdfs/role_play_report_b.pdf',
    'Procedure Format': 'assets/pdfs/procedure_format.pdf',
    'Procedure Format Guidelines': 'assets/pdfs/procedure_format_guidelines.pdf',
    'Visit Report': 'assets/pdfs/visit_report.pdf',
    'Visit Report Guidelines': 'assets/pdfs/visit_report_guidelines.pdf',
    'Village Leader Meeting Report A': 'assets/pdfs/village_leader_meeting_report_a.pdf',
    'Village Leader Meeting Report B': 'assets/pdfs/village_leader_meeting_report_b.pdf',
    'Community Diagnosis': 'assets/pdfs/community_diagnosis.pdf',
    'Master Sheet': 'assets/pdfs/master_sheet.pdf',
    'Community Profile Format': 'assets/pdfs/community_profile_format.pdf',
  };

  @override
  void initState() {
    super.initState();
    _loadPdf(_pdfFiles[_selectedPdfName]!);
  }

  Future<void> _loadPdf(String assetPath) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final filename = assetPath.split('/').last;
      final path = await _fromAsset(assetPath, filename);
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

  void _sharePdf() async {
    if (_localPath == null) return;
    try {
      // ignore: deprecated_member_use
      final result = await Share.shareXFiles(
        [XFile(_localPath!)],
        text: 'Download/Share $_selectedPdfName',
      );
      if (result.status == ShareResultStatus.success) {
         if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('File shared/saved successfully')),
          );
         }
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error sharing PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annexures'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download / Share PDF',
            onPressed: (_isLoading || _localPath == null) ? null : _sharePdf,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedPdfName,
                items: _pdfFiles.keys.map((String key) {
                  return DropdownMenuItem<String>(
                    value: key,
                    child: Text(
                      key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null && newValue != _selectedPdfName) {
                    setState(() {
                      _selectedPdfName = newValue;
                    });
                    _loadPdf(_pdfFiles[newValue]!);
                  }
                },
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _localPath == null
              ? const Center(child: Text('Failed to load PDF'))
              : PDFView(
                  key: Key(_localPath!), // Force rebuild when path changes
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
