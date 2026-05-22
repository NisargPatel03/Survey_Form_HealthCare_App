import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/submission_service.dart';
import '../services/attachment_service.dart';
import 'pdf_viewer_screen.dart';
import 'sketch_canvas_screen.dart';

class DynamicFormScreen extends StatefulWidget {
  final String studentId;
  final String courseName;
  final String semester;
  final String requirementSrNo;

  const DynamicFormScreen({
    super.key,
    required this.studentId,
    required this.courseName,
    required this.semester,
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
  
  // Faculty features
  List<Map<String, dynamic>> _faculties = [];
  String? _selectedFacultyId;
  String? _status;
  bool _isReadOnly = false;
  String? _facultyRemarks;
  num? _marksObtained;
  num? _maxMarks;
  Map<String, dynamic>? _evaluationData;

  String get _draftKey => 'draft_${widget.semester}_${widget.studentId}_${widget.requirementSrNo}';

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
      final lookup5th = {
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
        '13.1': '13_visit_report.json',
        '13.2': '13_visit_report.json',
        '13.3': '13_visit_report.json',
        '13.4': '13_visit_report.json',
        '13.5': '13_visit_report.json',
        '13.6': '13_visit_report.json',
      };

      final lookup7th = {
        '1.1': '1_1_orientation_report.json',
        '2.1': '3_1_care_study.json',
        '3.1': '2_1_care_plan.json',
        '3.2': '2_1_care_plan.json',
        '4.1': 'procedure_format.json',
        '4.2': 'procedure_format.json',
        '4.3': 'procedure_format.json',
        '4.4': 'procedure_format.json',
        '4.5': 'procedure_format.json',
        '4.6': 'procedure_format.json',
        '4.7': 'procedure_format.json',
        '4.8': 'procedure_format.json',
        '5.1': '5_1_health_screening_camp_report.json',
        '5.2': '5_1_health_screening_camp_report.json',
        '5.3': '6_3_survey_report.json',
        '6.1': '6_1_interaction_with_health_workers.json',
        '6.2': '6_1_interaction_with_health_workers.json',
        '6.3': '6_3_primary_management_and_care.json',
        '7.1': '1_1_orientation_report.json',
        '8.1': '2_1_care_plan.json',
        '8.2': '2_1_care_plan.json',
        '8.3': '2_1_care_plan.json',
        '8.4': '2_1_care_plan.json',
        '8.5': '2_1_care_plan.json',
        '8.6': '2_1_care_plan.json',
        '8.7': '2_1_care_plan.json',
        '9.1': '11_1_individual_health_talk.json',
        '9.2': '11_1_individual_health_talk.json',
        '10.1': '5_1_group_health_talk.json',
        '11.1': '11_1_disaster_mock_drill.json',
        '12.1': '13_visit_report.json',
        '12.2': '13_visit_report.json',
        '12.3': '13_visit_report.json',
        '12.4': '13_visit_report.json',
        '13.1': '13_1_continuous_evaluation.json',
      };
      
      final lookup = widget.semester == '7th Sem' ? lookup7th : lookup5th;
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
      
      // 2. Load existing submission from database
      final existingData = await _submissionService.getSubmission(widget.studentId, widget.courseName, widget.requirementSrNo);
      Map<String, dynamic> initialData = existingData != null ? Map<String, dynamic>.from(existingData['form_data']) : {};

      // Auto-load local draft if it's newer or if no database data exists
      final prefs = await SharedPreferences.getInstance();
      final draftString = prefs.getString(_draftKey);
      if (draftString != null) {
        try {
          final draftData = jsonDecode(draftString) as Map<String, dynamic>;
          // Always load the local draft if it exists, so students see their latest unsaved edits
          if (draftData.isNotEmpty) {
            initialData = {...initialData, ...draftData};
            _hasUnsavedChanges = true;
          }
        } catch (_) {}
      }

      // 3. Fetch faculty profiles
      final faculties = await _submissionService.getFacultyProfiles();

      setState(() {
        _formTitle = schema['title'] ?? 'Form';
        _fields = schema['fields'] ?? [];
        _sections = schema['sections'] ?? [];
        _formData = initialData;
        _faculties = faculties;
        _status = existingData?['status'];
        // Form is only locked if it's approved or rejected
        _isReadOnly = (_status == 'approved' || _status == 'rejected');
        _facultyRemarks = existingData?['faculty_remarks'];
        _marksObtained = existingData?['marks_obtained'];
        _maxMarks = existingData?['max_marks'];
        _evaluationData = existingData?['evaluation_data'];
        _selectedFacultyId = existingData?['assigned_faculty_id'];
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
      if (_selectedFacultyId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Faculty member for evaluation')));
        setState(() => _isLoading = false);
        return;
      }

      // 1. Process and upload any offline/local sketch layout images to Supabase Storage
      final attachmentService = AttachmentService();
      
      Future<void> uploadFieldIfSketch(Map<String, dynamic> field) async {
        final key = field['key'];
        final type = field['type'];
        if (type == 'sketch') {
          final localPath = _formData[key];
          if (localPath is String && localPath.isNotEmpty && !localPath.startsWith('http')) {
            final cloudUrl = await attachmentService.uploadRequirementAttachment(
              studentId: widget.studentId,
              requirementSrNo: widget.requirementSrNo,
              localFilePath: localPath,
            );
            _formData[key] = cloudUrl;
          }
        }
      }

      // Process root level fields
      for (final f in _fields) {
        if (f is Map<String, dynamic>) {
          await uploadFieldIfSketch(f);
        } else if (f is Map) {
          await uploadFieldIfSketch(Map<String, dynamic>.from(f));
        }
      }

      // Process section level fields
      for (final s in _sections) {
        final List<dynamic> sectionFields = s['fields'] ?? [];
        for (final f in sectionFields) {
          if (f is Map<String, dynamic>) {
            await uploadFieldIfSketch(f);
          } else if (f is Map) {
            await uploadFieldIfSketch(Map<String, dynamic>.from(f));
          }
        }
      }

      // 2. Submit to DB
      await _submissionService.submitRequirement(
        studentId: widget.studentId,
        courseName: widget.courseName,
        requirementSrNo: widget.requirementSrNo,
        formData: _formData,
        assignedFacultyId: _selectedFacultyId!,
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

  Future<void> _openInteractiveCanvas(String key, Map<String, dynamic> dataMap) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SketchCanvasScreen(),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        dataMap[key] = result;
      });
      _saveDraft();
    }
  }

  Future<void> _pickSketchFromCameraOrGallery(String key, Map<String, dynamic> dataMap) async {
    final ImagePicker picker = ImagePicker();
    
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Source of Sketch Layout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Take Photo of Drawing'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (source != null) {
      try {
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        
        if (image != null) {
          setState(() {
            dataMap[key] = image.path;
          });
          _saveDraft();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error picking layout image: $e')),
          );
        }
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
          enabled: !_isReadOnly,
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
          onChanged: _isReadOnly ? null : (val) {
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
          onTap: _isReadOnly ? null : () async {
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
      final fileVal = dataMap[key]?.toString();
      final bool hasValue = fileVal != null && fileVal.isNotEmpty;
      final bool isImage = hasValue && (fileVal.startsWith('http') || fileVal.endsWith('.png') || fileVal.endsWith('.jpg') || fileVal.endsWith('.jpeg') || fileVal.contains('sketch_'));

      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      fileVal ?? 'No file selected',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasValue ? Colors.blueGrey.shade800 : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    isImage ? Icons.image_outlined : Icons.upload_file,
                    color: Colors.blueGrey,
                  ),
                ],
              ),
            ),
            if (isImage) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  height: 220,
                  width: double.infinity,
                  child: fileVal.startsWith('http')
                      ? Image.network(
                          fileVal,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey),
                            ),
                          ),
                        )
                      : Image.file(
                          File(fileVal),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      );
    } else if (type == 'sketch') {
      final currentSketch = dataMap[key];
      final bool isCloud = currentSketch != null && currentSketch.toString().startsWith('http');
      final bool isLocal = currentSketch != null && !isCloud;
      final bool isFileValid = isLocal && File(currentSketch.toString()).existsSync();

      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 12),
              
              if (currentSketch != null && currentSketch.toString().isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      if (isCloud)
                        Image.network(
                          currentSketch.toString(),
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              height: 220,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 220,
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image_outlined, color: Colors.grey, size: 48),
                                    SizedBox(height: 8),
                                    Text('Error loading sketch from cloud', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      else if (isFileValid)
                        Image.file(
                          File(currentSketch.toString()),
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        )
                      else
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            border: Border.all(color: Colors.amber.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 48, color: Colors.amber),
                              SizedBox(height: 8),
                              Text("Local file draft path not found", style: TextStyle(color: Colors.amber)),
                            ],
                          ),
                        ),
                      if (!_isReadOnly)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(0.6),
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.close, size: 16, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  dataMap[key] = null;
                                });
                                _saveDraft();
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("No sketch uploaded or drawn yet", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              if (!_isReadOnly)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openInteractiveCanvas(key, dataMap),
                        icon: const Icon(Icons.brush, size: 18),
                        label: const Text('Draw Sketch'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          elevation: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickSketchFromCameraOrGallery(key, dataMap),
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: const Text('Capture Sketch'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue.shade700),
                          foregroundColor: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
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

    // Faculty Remarks for Resubmission
    if (_status == 'resubmission_required' && _facultyRemarks != null) {
      widgets.insert(0, Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.yellow.shade50,
          border: Border.all(color: Colors.yellow.shade700),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rotate_left, color: Colors.yellow.shade900),
                const SizedBox(width: 8),
                Text('Resubmission Required', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow.shade900)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Faculty Remarks: $_facultyRemarks', style: TextStyle(color: Colors.yellow.shade900)),
          ],
        ),
      ));
    }

    // Marks Display for Approved
    if (_status == 'approved' && _marksObtained != null) {
      widgets.add(const Divider(height: 48));
      widgets.add(Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          children: [
            const Text('EVALUATION RESULT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.green)),
            const SizedBox(height: 16),
            Text('$_marksObtained / $_maxMarks', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
            if (_facultyRemarks != null) ...[
              const SizedBox(height: 12),
              Text('Remarks: $_facultyRemarks', textAlign: TextAlign.center, style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
            if (_evaluationData != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ..._evaluationData!.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        e.key.replaceAll('_', ' ').toUpperCase(), 
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              )).toList(),
            ]
          ],
        ),
      ));
    }

    // Faculty Selection Dropdown
    if (_status != 'approved') {
      widgets.add(const SizedBox(height: 32));
      widgets.add(const Text('Select Faculty for Evaluation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
      widgets.add(const SizedBox(height: 8));
      widgets.add(
        DropdownButtonFormField<String>(
          value: _selectedFacultyId,
          decoration: const InputDecoration(
            hintText: 'Choose Evaluator',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          items: _faculties.map((f) => DropdownMenuItem(
            value: f['id'].toString(),
            child: Text(f['full_name']),
          )).toList(),
          onChanged: (val) => setState(() => _selectedFacultyId = val),
          validator: (val) => val == null ? 'Please select a faculty member' : null,
        )
      );
    }

    widgets.add(const SizedBox(height: 24));
    if (_status != 'approved') {
      widgets.add(
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            textStyle: const TextStyle(fontSize: 18),
            backgroundColor: _status == 'resubmission_required' ? Colors.orange : null,
          ),
          child: Text(_status == 'resubmission_required' ? 'Resubmit Requirement' : 'Submit Requirement'),
        ),
      );
    } else {
      widgets.add(
        const Center(child: Text('This requirement has been approved and cannot be edited.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)))
      );
    }

    return widgets;
  }

  void _openPdf() {
    final pdfLookup5th = {
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
        '14 A Role Play Format': 'assets/pdfs/role_play_report_a.pdf',
        '14 B Role Play Guidelines': 'assets/pdfs/role_play_report_b.pdf'
      },
      '13.1': {
        '16 A Visit Report Format': 'assets/pdfs/visit_report.pdf',
        '16 B Visit Report Guidelines': 'assets/pdfs/visit_report_guidelines.pdf'
      },
      '13.2': {
        '16 A Visit Report Format': 'assets/pdfs/visit_report.pdf',
        '16 B Visit Report Guidelines': 'assets/pdfs/visit_report_guidelines.pdf'
      },
      '13.3': {
        '16 A Visit Report Format': 'assets/pdfs/visit_report.pdf',
        '16 B Visit Report Guidelines': 'assets/pdfs/visit_report_guidelines.pdf'
      },
      '13.4': {
        '16 A Visit Report Format': 'assets/pdfs/visit_report.pdf',
        '16 B Visit Report Guidelines': 'assets/pdfs/visit_report_guidelines.pdf'
      },
      '13.5': {
        '16 A Visit Report Format': 'assets/pdfs/visit_report.pdf',
        '16 B Visit Report Guidelines': 'assets/pdfs/visit_report_guidelines.pdf'
      },
      '13.6': {
        '16 A Visit Report Format': 'assets/pdfs/visit_report.pdf',
        '16 B Visit Report Guidelines': 'assets/pdfs/visit_report_guidelines.pdf'
      },
    };

    final pdfLookup7th = {
      '1.1': {'Orientation Report': 'assets/pdfs/orientation_report.pdf'},
      '2.1': {'Family Care Study': 'assets/pdfs/family_care_study.pdf'},
      '3.1': {'Family Care Plan': 'assets/pdfs/family_care_plan.pdf'},
      '3.2': {'Family Care Plan': 'assets/pdfs/family_care_plan.pdf'},
      '4.1': { 'Procedure Format': 'assets/pdfs/procedure_format.pdf', 'Procedure Guidelines': 'assets/pdfs/procedure_format_guidelines.pdf' },
      '4.2': { 'Procedure Format': 'assets/pdfs/procedure_format.pdf', 'Procedure Guidelines': 'assets/pdfs/procedure_format_guidelines.pdf' },
      '4.3': { 'Procedure Format': 'assets/pdfs/procedure_format.pdf', 'Procedure Guidelines': 'assets/pdfs/procedure_format_guidelines.pdf' },
      '4.4': { 'Procedure Format': 'assets/pdfs/procedure_format.pdf', 'Procedure Guidelines': 'assets/pdfs/procedure_format_guidelines.pdf' },
      '4.5': { 'Procedure Format': 'assets/pdfs/procedure_format.pdf', 'Procedure Guidelines': 'assets/pdfs/procedure_format_guidelines.pdf' },
      '4.6': { 'Procedure Format': 'assets/pdfs/procedure_format.pdf', 'Procedure Guidelines': 'assets/pdfs/procedure_format_guidelines.pdf' },
      '4.7': { 'Procedure Format': 'assets/pdfs/procedure_format.pdf', 'Procedure Guidelines': 'assets/pdfs/procedure_format_guidelines.pdf' },
      '4.8': { 'Procedure Format': 'assets/pdfs/procedure_format.pdf', 'Procedure Guidelines': 'assets/pdfs/procedure_format_guidelines.pdf' },
      '5.1': { '13 A Health Screening Camp': 'assets/pdfs/health_screening_camp_report_a.pdf', '13 B Guidelines': 'assets/pdfs/health_screening_camp_report_b.pdf' },
      '5.2': { '13 A Health Screening Camp': 'assets/pdfs/health_screening_camp_report_a.pdf', '13 B Guidelines': 'assets/pdfs/health_screening_camp_report_b.pdf' },
      '5.3': {'18 Survey Report (PDF version)': 'assets/pdfs/survey_report.pdf'},
      '6.1': { '27 A Interaction with Health Workers': 'assets/pdfs/interaction_with_health_workers_a.pdf', '27 B Guidelines': 'assets/pdfs/interaction_with_health_workers_b.pdf' },
      '6.2': { '27 A Interaction with Health Workers': 'assets/pdfs/interaction_with_health_workers_a.pdf', '27 B Guidelines': 'assets/pdfs/interaction_with_health_workers_b.pdf' },
      '6.3': { '25 A Primary Management': 'assets/pdfs/primary_management_and_care_a.pdf', '25 B Guidelines': 'assets/pdfs/primary_management_and_care_b.pdf' },
      '7.1': {'Orientation Report': 'assets/pdfs/orientation_report.pdf'},
      '8.1': {'Family Care Plan': 'assets/pdfs/family_care_plan.pdf'},
      '8.2': {'Family Care Plan': 'assets/pdfs/family_care_plan.pdf'},
      '8.3': {'Family Care Plan': 'assets/pdfs/family_care_plan.pdf'},
      '8.4': {'Family Care Plan': 'assets/pdfs/family_care_plan.pdf'},
      '8.5': {'Family Care Plan': 'assets/pdfs/family_care_plan.pdf'},
      '8.6': {'Family Care Plan': 'assets/pdfs/family_care_plan.pdf'},
      '8.7': {'Family Care Plan': 'assets/pdfs/family_care_plan.pdf'},
      '9.1': {'7 Individual Health Talk Format': 'assets/pdfs/individual_health_talk.pdf'},
      '9.2': {'7 Individual Health Talk Format': 'assets/pdfs/individual_health_talk.pdf'},
      '10.1': {'Group Health Talk': 'assets/pdfs/group_health_talk.pdf'},
      '11.1': { '26 A Disaster Mock Drill': 'assets/pdfs/disaster_mock_drill_a.pdf', '26 B Guidelines': 'assets/pdfs/disaster_mock_drill_b.pdf' },
      '12.1': { '16 A Visit Report Format': 'assets/pdfs/visit_report.pdf', '16 B Visit Report Guidelines': 'assets/pdfs/visit_report_guidelines.pdf' },
      '12.2': { '16 A Visit Report Format': 'assets/pdfs/visit_report.pdf', '16 B Visit Report Guidelines': 'assets/pdfs/visit_report_guidelines.pdf' },
      '12.3': { '16 A Visit Report Format': 'assets/pdfs/visit_report.pdf', '16 B Visit Report Guidelines': 'assets/pdfs/visit_report_guidelines.pdf' },
      '12.4': { '16 A Visit Report Format': 'assets/pdfs/visit_report.pdf', '16 B Visit Report Guidelines': 'assets/pdfs/visit_report_guidelines.pdf' },
      '13.1': { '24 Continuous Evaluation': 'assets/pdfs/continuous_evaluation.pdf' },
    };

    final pdfLookup = widget.semester == '7th Sem' ? pdfLookup7th : pdfLookup5th;
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
                      'Form configuration not yet available for requirement ${widget.requirementSrNo} (${widget.semester}).',
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
