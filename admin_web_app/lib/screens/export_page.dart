import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:csv/csv.dart';
import '../models/survey_data.dart';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // Only works on Web!

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final _supabase = Supabase.instance.client;
  bool _isExporting = false;

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);
    try {
      // 1. Fetch Data
      final response = await _supabase.from('surveys').select();
      final List<dynamic> data = response as List<dynamic>;
      
      List<SurveyData> surveys = [];
      for (var row in data) {
        if (row['json_content'] != null) {
          row['json_content']['id'] = row['id'];
          surveys.add(SurveyData.fromJson(row['json_content']));
        }
      }

      // 2. Convert to List<List>
      List<List<dynamic>> rows = [];
      
      // Header
      rows.add([
        "ID", "Head of Family", "Date", "Area", "Total Income", 
        "Family Members", "Malnutrition Cases", "Pregnant Women"
      ]);

      // Rows
      for (var s in surveys) {
        rows.add([
          s.id,
          s.headOfFamily,
          s.surveyDate?.toIso8601String(),
          s.areaName,
          s.totalIncome,
          s.familyMembers.length,
          s.malnutritionCases.length,
          s.pregnantWomen.length,
        ]);
      }

      // 3. Generate CSV String
      String csv = const ListToCsvConverter().convert(rows);

      // 4. Download (Web specific)
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", "mtin_surveys_export.csv")
        ..click();
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("CSV Exported Successfully!")),
        );
      }

    } catch (e) {
      debugPrint("Export Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Export Failed: $e")),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.download, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            "Export Data",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("Download all survey data as CSV for Excel/Analysis"),
          const SizedBox(height: 40),
          
          ElevatedButton.icon(
            onPressed: _isExporting ? null : _exportCsv,
            icon: _isExporting 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.file_download),
            label: Text(_isExporting ? "Generaing CSV..." : "Download CSV"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
