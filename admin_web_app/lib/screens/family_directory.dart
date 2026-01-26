import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/survey_data.dart';

class FamilyDirectory extends StatefulWidget {
  const FamilyDirectory({super.key});

  @override
  State<FamilyDirectory> createState() => _FamilyDirectoryState();
}

class _FamilyDirectoryState extends State<FamilyDirectory> {
  final _supabase = Supabase.instance.client;
  
  List<SurveyData> _allSurveys = [];
  List<SurveyData> _filteredSurveys = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await _supabase
          .from('surveys')
          .select()
          .order('head_of_family', ascending: true);
          
      final List<dynamic> data = response as List<dynamic>;
      List<SurveyData> loaded = [];

      for (var row in data) {
        final jsonMap = row['json_content'];
        if (jsonMap != null) {
          jsonMap['id'] = row['id'];
          loaded.add(SurveyData.fromJson(jsonMap));
        }
      }

      setState(() {
        _allSurveys = loaded;
        _filteredSurveys = loaded;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filter(String query) {
    final lower = query.toLowerCase();
    setState(() {
      _filteredSurveys = _allSurveys.where((s) {
        final name = s.headOfFamily?.toLowerCase() ?? '';
        final area = s.areaName?.toLowerCase() ?? '';
        return name.contains(lower) || area.contains(lower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Family Directory",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: "Search by Head of Family or Area...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _filter,
          ),
          const SizedBox(height: 20),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSurveys.isEmpty
                    ? const Center(child: Text("No families found"))
                    : ListView.separated(
                        itemCount: _filteredSurveys.length,
                        separatorBuilder: (c, i) => const Divider(),
                        itemBuilder: (context, index) {
                          final survey = _filteredSurveys[index];
                          return Card(
                            elevation: 2,
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                child: Text("${index + 1}"),
                              ),
                              title: Text(
                                survey.headOfFamily ?? "Unknown",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Area: ${survey.areaName} • Members: ${survey.familyMembers.length} • Income: ${survey.totalIncome}",
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow("Religion", survey.religion),
                                      _buildInfoRow("House No", survey.houseNo),
                                      _buildInfoRow("House Type", survey.houseType),
                                      const SizedBox(height: 10),
                                      const Text("Family Members:", style: TextStyle(fontWeight: FontWeight.bold)),
                                      ...survey.familyMembers.map((m) => Text("- ${m.name} (${m.age}, ${m.gender})")),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value ?? "N/A"),
        ],
      ),
    );
  }
}
