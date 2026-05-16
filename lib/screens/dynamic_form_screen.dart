import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/submission_service.dart';
import 'pdf_viewer_screen.dart';

class DynamicFormScreen extends StatefulWidget {
  final String studentId;
  final String courseName;
  final String requirementSrNo;

  const DynamicFormScreen({
    super.key,
    required this.studentId,
    required this.courseName,
    required this.requirementSrNo,
  });

  @override
  State<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends State<DynamicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final SubmissionService _submissionService = SubmissionService();
  
  bool _isLoading = true;
  String _formTitle = 'Loading Form...';
  List<dynamic> _fields = [];
  List<dynamic> _sections = [];
  Map<String, dynamic> _formData = {};
  bool _hasUnsavedChanges = false;

  String get _draftKey => 'draft_${widget.studentId}_${widget.requirementSrNo}';

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftKey, jsonEncode(_formData));
    _hasUnsavedChanges = true;
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
    _hasUnsavedChanges = false;
  }

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    try {
      final lookup = {
        '1.1': '1_1_orientation_report.json',
        '2.1': '2_1_care_plan.json',
        '3.1': '3_1_care_study.json',
        '4.1': 'procedure_format.json',
        '4.2': 'procedure_format.json',
        '5.1': '5_1_group_health_talk.json',
        '6.1': '6_1_school_health_program.json',
        '6.2': '6_2_anganwadi_assessment.json',
        '6.3': '6_3_survey_report.json',
        '7.1': '1_1_orientation_report.json',
        '8.1': '2_1_care_plan.json',
        '9.1': '3_1_care_study.json',
        '10.1': 'procedure_format.json',
        '10.2': 'procedure_format.json',
        '11.1': '11_1_individual_health_talk.json',
        '12.1': '12_1_role_play_report.json',
      };
      
      final schemaFile = lookup[widget.requirementSrNo];
      if (schemaFile == null) {
        setState(() {
          _formTitle = 'Form Not Available';
          _isLoading = false;
        });
        return;
      }

      final String jsonString = await rootBundle.loadString('assets/forms/$schemaFile');
      final Map<String, dynamic> schema = jsonDecode(jsonString);
      
      final existingData = await _submissionService.getSubmission(widget.studentId, widget.requirementSrNo);
      Map<String, dynamic> initialData = existingData ?? {};

      // Auto-load draft if it exists
      final prefs = await SharedPreferences.getInstance();
      final draftString = prefs.getString(_draftKey);
      if (draftString != null) {
        try {
          final draftData = jsonDecode(draftString) as Map<String, dynamic>;
          initialData = draftData;
          _hasUnsavedChanges = true; // Mark as unsaved so warning shows
        } catch (_) {}
      }

      setState(() {
        _formTitle = schema['title'] ?? 'Form';
        _fields = schema['fields'] ?? [];
        _sections = schema['sections'] ?? [];
        _formData = initialData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _formTitle = 'Error Loading Form';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);
    
    try {
      await _submissionService.submitRequirement(
        widget.studentId,
        widget.courseName,
        widget.requirementSrNo,
        _formData,
      );
      
      await _clearDraft();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form Submitted Successfully!')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildField(Map<String, dynamic> field, Map<String, dynamic> dataMap) {
    final key = field['key'];
    final label = field['label'];
    final type = field['type'];
    final isRequired = field['required'] == true;

    if (type == 'text' || type == 'number' || type == 'textarea') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: TextFormField(
          initialValue: dataMap[key]?.toString(),
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          maxLines: type == 'textarea' ? 4 : 1,
          keyboardType: type == 'number' ? TextInputType.number : TextInputType.text,
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
          onChanged: (value) {
            dataMap[key] = value;
            _saveDraft();
          },
          onSaved: (value) => dataMap[key] = value,
        ),
      );
    } else if (type == 'dropdown') {
      final List<dynamic> options = field['options'] ?? [];
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          value: dataMap[key],
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: options.map<DropdownMenuItem<String>>((opt) {
            return DropdownMenuItem<String>(
              value: opt.toString(),
              child: Text(opt.toString()),
            );
          }).toList(),
          validator: (value) {
            if (isRequired && value == null) {
              return 'Please select an option';
            }
            return null;
          },
          onChanged: (val) {
            setState(() {
              dataMap[key] = val;
            });
            _saveDraft();
          },
          onSaved: (value) => dataMap[key] = value,
        ),
      );
    } else if (type == 'date') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2101),
            );
            if (picked != null) {
              setState(() {
                dataMap[key] = "${picked.toLocal()}".split(' ')[0];
              });
              _saveDraft();
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            child: Text(dataMap[key] ?? 'Select Date'),
          ),
        ),
      );
    } else if (type == 'file') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dataMap[key] ?? 'No file selected (Coming soon)'),
              const Icon(Icons.upload_file),
            ],
          ),
        ),
      );
    } else if (type == 'object') {
       return Padding(
         padding: const EdgeInsets.only(bottom: 16.0),
         child: Text('[$label object - View only]', style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
       );
    } else if (type == 'array') {
      if (dataMap[key] == null) {
        dataMap[key] = [];
      }
      List<dynamic> listData = dataMap[key];

      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey.shade50,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (field['hint'] != null) ...[
                const SizedBox(height: 4),
                Text(field['hint'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
              const SizedBox(height: 12),
              
              for (int i = 0; i < listData.length; i++)
                _buildArrayItem(field, listData, i, key),

              const SizedBox(height: 12),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      if (field['itemSchema'] != null) {
                        listData.add(<String, dynamic>{});
                      } else {
                        listData.add('');
                      }
                    });
                    _saveDraft();
                  },
                  icon: const Icon(Icons.add),
                  label: Text('Add ${field['itemLabel'] ?? 'Entry'}'),
                ),
              )
            ],
          ),
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildArrayItem(Map<String, dynamic> arrayField, List<dynamic> listData, int index, String arrayKey) {
    bool hasSchema = arrayField['itemSchema'] != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${arrayField['itemLabel'] ?? 'Entry'} #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () {
                  setState(() {
                    listData.removeAt(index);
                  });
                  _saveDraft();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!hasSchema)
            TextFormField(
              initialValue: listData[index].toString(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) {
                listData[index] = val;
                _saveDraft();
              },
              onSaved: (val) => listData[index] = val,
            )
          else
            ...arrayField['itemSchema'].entries.map<Widget>((entry) {
              final subField = Map<String, dynamic>.from(entry.value);
              subField['key'] = entry.key;
              
              // Ensure listData[index] is a Map<String, dynamic> to prevent type errors
              if (listData[index] is! Map<String, dynamic>) {
                listData[index] = Map<String, dynamic>.from(listData[index] as Map);
              }
              
              return _buildField(subField, listData[index] as Map<String, dynamic>);
            }).toList(),
        ],
      ),
    );
  }

  List<Widget> _buildFormContents() {
    List<Widget> widgets = [];
    
    // Flat Fields
    for (var f in _fields) {
      widgets.add(_buildField(f, _formData));
    }

    // Sections
    for (var s in _sections) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: Text(
            s['section'] ?? '',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
      final List<dynamic> sectionFields = s['fields'] ?? [];
      for (var f in sectionFields) {
        widgets.add(_buildField(f, _formData));
      }
    }

    widgets.add(const SizedBox(height: 24));
    widgets.add(
      ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: const Text('Submit Requirement'),
      ),
    );

    return widgets;
  }

  void _openPdf() {
    final pdfLookup = {
      '1.1': {'Orientation Report': 'assets/pdfs/orientation_report.pdf'},
      '2.1': {'Family Care Plan': 'assets/pdfs/family_care_plan.pdf'},
      '3.1': {'Family Care Study': 'assets/pdfs/family_care_study.pdf'},
      '4.1': {
        'Procedure Format': 'assets/pdfs/procedure_format.pdf',
        'Procedure Guidelines': 'assets/pdfs/procedure_format_guidelines.pdf'
      },
      '4.2': {
        'Procedure Format': 'assets/pdfs/procedure_format.pdf',
        'Procedure Guidelines': 'assets/pdfs/procedure_format_guidelines.pdf'
      },
      '5.1': {'Group Health Talk': 'assets/pdfs/group_health_talk.pdf'},
      '6.1': {
        '10 A School Health Program': 'assets/pdfs/school_health_program.pdf',
        '10 B School Health Program Guidelines': 'assets/pdfs/school_health_program_guidelines.pdf',
      },
      '6.2': {
        '11 A Anganwadi Assessment Report': 'assets/pdfs/anganwadi_assessment_report.pdf',
        '11 B Anganwadi Assessment Guidelines': 'assets/pdfs/anganwadi_assessment_guidelines.pdf',
      },
      '6.3': {
        '18 Survey Report (PDF version)': 'assets/pdfs/survey_report.pdf',
      },
      '7.1': {'Orientation Report': 'assets/pdfs/orientation_report.pdf'},
      '8.1': {'Family Care Plan': 'assets/pdfs/family_care_plan.pdf'},
      '9.1': {'Family Care Study': 'assets/pdfs/family_care_study.pdf'},
      '10.1': {
        'Procedure Format': 'assets/pdfs/procedure_format.pdf',
        'Procedure Guidelines': 'assets/pdfs/procedure_format_guidelines.pdf'
      },
      '10.2': {
        'Procedure Format': 'assets/pdfs/procedure_format.pdf',
        'Procedure Guidelines': 'assets/pdfs/procedure_format_guidelines.pdf'
      },
      '11.1': {'7 Individual Health Talk Format': 'assets/pdfs/individual_health_talk.pdf'},
      '12.1': {
        '14 A Role Play Format': 'assets/pdfs/role_play_format.pdf',
        '14 B Role Play Guidelines': 'assets/pdfs/role_play_guidelines.pdf'
      },
    };

    final options = pdfLookup[widget.requirementSrNo];
    if (options != null && options.isNotEmpty) {
      if (options.length == 1) {
        // Only one PDF, open directly
        final entry = options.entries.first;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(assetPath: entry.value, title: entry.key),
          ),
        );
      } else {
        // Multiple PDFs, show a selection dialog
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Select PDF to View', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...options.entries.map((entry) => ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(entry.key),
                    onTap: () {
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewerScreen(assetPath: entry.value, title: entry.key),
                        ),
                      );
                    },
                  )),
                ],
              ),
            );
          },
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No PDF available for this requirement.')));
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Form?'),
        content: const Text('Your current progress has been automatically saved as a local draft. You can safely exit and resume later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primaryContainer),
            child: const Text('Exit (Draft Saved)'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
        title: Text(_formTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'View PDF Format',
            onPressed: _openPdf,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_fields.isEmpty && _sections.isEmpty)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Form configuration not yet available for requirement ${widget.requirementSrNo}.\n\n(Configured: 1.1, 2.1, 3.1, 4.1, 4.2, 5.1, 6.1, 6.2, 6.3, 7.1, 8.1, 9.1, 10.1, 10.2, 11.1, 12.1)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _buildFormContents(),
                    ),
                  ),
                ),
      ),
    );
  }
}
