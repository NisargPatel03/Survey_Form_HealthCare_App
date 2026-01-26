import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/survey_data.dart';

class DashboardOverview extends StatefulWidget {
  const DashboardOverview({super.key});

  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  final _supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  List<SurveyData> _surveys = [];
  
  // Stats
  int _totalSurveys = 0;
  int _totalPopulation = 0;
  int _malnutritionCount = 0;
  int _highRiskPregnancies = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Fetch all surveys
      // In a real production app with millions of rows, we would use .count() or Edge Functions.
      // For now, fetching all is fine for the prototype.
      final response = await _supabase
          .from('surveys')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      
      List<SurveyData> loadedSurveys = [];
      int popCount = 0;
      int malCount = 0;
      int pregCount = 0;

      for (var row in data) {
        // The helpful JSON is inside the 'json_content' column
        final jsonMap = row['json_content'];
        if (jsonMap != null) {
          // We manually inject the ID from the wrapper row if needed, 
          // but SurveyData.fromJson usually looks inside the map. 
          // Let's ensure 'id' is passed if the model uses it.
          jsonMap['id'] = row['id']; 
          
          final survey = SurveyData.fromJson(jsonMap);
          loadedSurveys.add(survey);

          // Calculate Metrics
          popCount += survey.familyMembers.length;
          
          if (survey.malnutritionCases.isNotEmpty) {
            malCount += survey.malnutritionCases.length;
          }

          // Check for high risk pregnancies (custom logic based on your fields)
          // For now, just counting total pregnant women
          if (survey.pregnantWomen.isNotEmpty) {
            pregCount += survey.pregnantWomen.length;
          }
        }
      }

      setState(() {
        _surveys = loadedSurveys;
        _totalSurveys = loadedSurveys.length;
        _totalPopulation = popCount;
        _malnutritionCount = malCount;
        _highRiskPregnancies = pregCount; // Using total pregnant for now as proxy
        _isLoading = false;
      });

    } catch (e) {
      debugPrint("Error fetching dashboard stats: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading data: $e")),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard Overview",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Stat Cards Row
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildStatCard(
                "Total Surveys",
                _totalSurveys.toString(),
                Icons.assignment,
                Colors.blue,
              ),
              _buildStatCard(
                "Total Population",
                _totalPopulation.toString(),
                Icons.groups,
                Colors.green,
              ),
              _buildStatCard(
                "Malnutrition Cases",
                _malnutritionCount.toString(),
                Icons.warning_amber,
                Colors.orange,
              ),
              _buildStatCard(
                "Pregnancies",
                _highRiskPregnancies.toString(),
                Icons.pregnant_woman,
                Colors.pink,
              ),
            ],
          ),

          const SizedBox(height: 40),
          const Text(
            "Recent Submissions",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          Expanded(
            child: Card(
              child: ListView.separated(
                itemCount: _surveys.length > 10 ? 10 : _surveys.length,
                separatorBuilder: (c, i) => const Divider(),
                itemBuilder: (context, index) {
                  final survey = _surveys[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(survey.headOfFamily?.substring(0, 1) ?? "?"),
                    ),
                    title: Text(survey.headOfFamily ?? "Unknown Family"),
                    subtitle: Text("${survey.areaName} • ${survey.familyMembers.length} Members"),
                    trailing: Text(
                      survey.surveyDate?.toString().split(' ')[0] ?? "No Date",
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 30),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
