import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/survey_data.dart';

class AnalyticsCharts extends StatefulWidget {
  const AnalyticsCharts({super.key});

  @override
  State<AnalyticsCharts> createState() => _AnalyticsChartsState();
}

class _AnalyticsChartsState extends State<AnalyticsCharts> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  
  // Data for Charts
  Map<String, int> _socioEconomicCounts = {};
  Map<String, int> _diseaseCounts = {
    'Fever': 0,
    'Cough': 0,
    'Skin': 0,
    'Other': 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await _supabase.from('surveys').select();
      final List<dynamic> data = response as List<dynamic>;

      final Map<String, int> socioCounts = {};
      final Map<String, int> healthCounts = {
        'Fever': 0,
        'Cough': 0,
        'Skin': 0,
        'Other': 0,
      };

      for (var row in data) {
        final jsonMap = row['json_content'];
        if (jsonMap != null) {
          jsonMap['id'] = row['id']; // Inject ID
          final survey = SurveyData.fromJson(jsonMap);

          // 1. Socio Economic
          final seClass = survey.socioEconomicClass ?? 'Unknown';
          socioCounts[seClass] = (socioCounts[seClass] ?? 0) + 1;

          // 2. Diseases
          healthCounts['Fever'] = (healthCounts['Fever']!) + survey.feverCases.length;
          healthCounts['Cough'] = (healthCounts['Cough']!) + survey.coughCases.length;
          healthCounts['Skin'] = (healthCounts['Skin']!) + survey.skinDiseases.length;
          healthCounts['Other'] = (healthCounts['Other']!) + survey.otherIllnesses.length;
        }
      }

      setState(() {
        _socioEconomicCounts = socioCounts;
        _diseaseCounts = healthCounts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching analytics: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Analytics & Insights",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // Row 1: Pie Chart (Socio-Economic)
          const Text(
            "Socio-Economic Class Distribution",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: _socioEconomicCounts.isEmpty 
              ? const Center(child: Text("No Data Available"))
              : PieChart(
                PieChartData(
                  sections: _socioEconomicCounts.entries.map((entry) {
                    return PieChartSectionData(
                      color: _getColorForClass(entry.key),
                      value: entry.value.toDouble(),
                      title: '${entry.key}\n${entry.value}',
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
          ),

          const SizedBox(height: 50),

          // Row 2: Bar Chart (Diseases)
          const Text(
            "Morbidity Overview (Reported Cases)",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(),
                barGroups: _diseaseCounts.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data.value.toDouble(),
                        color: _getColorForDisease(data.key),
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final keys = _diseaseCounts.keys.toList();
                        if (value.toInt() >= 0 && value.toInt() < keys.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(keys[value.toInt()]),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY() {
    int max = 0;
    for (var val in _diseaseCounts.values) {
      if (val > max) max = val;
    }
    return (max + 5).toDouble(); // Add buffer
  }

  Color _getColorForClass(String className) {
    switch (className) {
      case 'Upper': return Colors.green;
      case 'Middle': return Colors.blue;
      case 'Lower': return Colors.orange;
      case 'Unknown': return Colors.grey;
      default: return Colors.purple;
    }
  }

  Color _getColorForDisease(String disease) {
    switch (disease) {
      case 'Fever': return Colors.redAccent;
      case 'Cough': return Colors.blueAccent;
      case 'Skin': return Colors.amber;
      default: return Colors.teal;
    }
  }
}
