import 'package:flutter/material.dart';
import '../models/survey_data.dart';

// Section 6: Dietary Pattern
class DietaryPatternSection extends StatefulWidget {
  final SurveyData surveyData;

  const DietaryPatternSection({super.key, required this.surveyData});

  @override
  State<DietaryPatternSection> createState() => _DietaryPatternSectionState();
}

class _DietaryPatternSectionState extends State<DietaryPatternSection> {
  final List<String> _foodItems = [
    'Rice',
    'Bajra',
    'Jowar',
    'Wheat',
    'Vegetables',
    'Fish',
    'Meat',
    'Egg',
    'Milk & Milk Products',
    'Pulses',
    'Tubers',
  ];

  @override
  void initState() {
    super.initState();
    for (var item in _foodItems) {
      if (!widget.surveyData.dietaryPattern.containsKey(item)) {
        widget.surveyData.dietaryPattern[item] = DietaryInfo();
      }
    }
  }

  @override
  void didUpdateWidget(DietaryPatternSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.surveyData != oldWidget.surveyData) {
      for (var item in _foodItems) {
        if (!widget.surveyData.dietaryPattern.containsKey(item)) {
          widget.surveyData.dietaryPattern[item] = DietaryInfo();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '9. DIETARY PATTERN:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._foodItems.map((item) {
          final info = widget.surveyData.dietaryPattern[item]!;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: info.available,
                        onChanged: (value) {
                          setState(() {
                            info.available = value ?? false;
                            if (info.available) {
                              info.used = true;
                            } else {
                              info.used = false;
                              info.traditional = false;
                              info.ideal = false;
                              info.unhygienic = false;
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Food Item',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  if (info.available) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: info.frequency.isNotEmpty ? info.frequency : null,
                      decoration: const InputDecoration(
                        labelText: 'Frequency',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                        DropdownMenuItem(value: 'Occasionally', child: Text('Occasionally')),
                        DropdownMenuItem(value: 'Never', child: Text('Never')),
                      ],
                      onChanged: (value) {
                         setState(() => info.frequency = value ?? '');
                      },
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    const Text(
                      'Food Preparation and Storage:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RadioListTile<String>(
                      title: const Text('Traditional', style: TextStyle(fontSize: 14)),
                      value: 'traditional',
                      groupValue: info.traditional
                          ? 'traditional'
                          : info.ideal
                              ? 'ideal'
                              : info.unhygienic
                                  ? 'unhygienic'
                                  : null,
                      onChanged: (value) {
                        setState(() {
                          info.traditional = value == 'traditional';
                          info.ideal = false;
                          info.unhygienic = false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<String>(
                      title: const Text('Ideal', style: TextStyle(fontSize: 14)),
                      value: 'ideal',
                      groupValue: info.traditional
                          ? 'traditional'
                          : info.ideal
                              ? 'ideal'
                              : info.unhygienic
                                  ? 'unhygienic'
                                  : null,
                      onChanged: (value) {
                        setState(() {
                          info.traditional = false;
                          info.ideal = value == 'ideal';
                          info.unhygienic = false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<String>(
                      title: const Text('Unhygienic', style: TextStyle(fontSize: 14)),
                      value: 'unhygienic',
                      groupValue: info.traditional
                          ? 'traditional'
                          : info.ideal
                              ? 'ideal'
                              : info.unhygienic
                                  ? 'unhygienic'
                                  : null,
                      onChanged: (value) {
                        setState(() {
                          info.traditional = false;
                          info.ideal = false;
                          info.unhygienic = value == 'unhygienic';
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

// Section 7: Expenditure
class ExpenditureSection extends StatefulWidget {
  final SurveyData surveyData;

  const ExpenditureSection({super.key, required this.surveyData});

  @override
  State<ExpenditureSection> createState() => _ExpenditureSectionState();
}

class _ExpenditureSectionState extends State<ExpenditureSection> {
  final List<String> _expenditureItems = [
    'Food',
    'Clothing',
    'Housing',
    'Medicine',
    'Children education',
    'Recreation (movie etc)',
    'Smoking, alcohol',
    'Debt',
    'Savings',
    'Other (specify)',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.surveyData.expenditureItems.isEmpty) {
      for (var item in _expenditureItems) {
        widget.surveyData.expenditureItems.add(ExpenditureItem(
          item: item,
          amount: 0.0,
          percentage: 0.0,
        ));
      }
    }
  }

  @override
  void didUpdateWidget(ExpenditureSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.surveyData != oldWidget.surveyData) {
      if (widget.surveyData.expenditureItems.isEmpty) {
        for (var item in _expenditureItems) {
          widget.surveyData.expenditureItems.add(ExpenditureItem(
            item: item,
            amount: 0.0,
            percentage: 0.0,
          ));
        }
      }
    }
  }

  void _calculatePercentages() {
    final total = widget.surveyData.expenditureItems
        .fold<double>(0.0, (sum, item) => sum + item.amount);
    if (total > 0) {
      for (var item in widget.surveyData.expenditureItems) {
        item.percentage = (item.amount / total) * 100;
      }
    }
  }

  void _calculateSavings() {
    double totalIncome = widget.surveyData.totalIncome ?? 0.0;
    double totalExpenditureExceptSavings = 0.0;
    ExpenditureItem? savingsItem;

    for (var item in widget.surveyData.expenditureItems) {
      if (item.item == 'Savings') {
        savingsItem = item;
      } else {
        totalExpenditureExceptSavings += item.amount;
      }
    }

    if (savingsItem != null) {
      double calculatedSavings = totalIncome - totalExpenditureExceptSavings;
      // Allow negative savings (deficit) or clamp to 0? Usually savings can't be negative, but debt can increase.
      // If negative, maybe savings is 0 and debt increases? But prompt just says "Savings will be autocalculated".
      // I'll set it to calculated value, if negative, it means they are overspending.
      savingsItem.amount = calculatedSavings; 
    }
  }

  @override
  Widget build(BuildContext context) {
    // Recalculate savings before build to ensure up-to-date
    _calculateSavings(); 
    _calculatePercentages();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '10. STATEMENT OF EXPENDITURE OF FAMILY:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...widget.surveyData.expenditureItems.map((item) {
          return Card(
            key: ObjectKey(item),
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    item.item,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: item.amount.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Amount spent',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            item.amount = double.tryParse(value) ?? 0.0;
                            // Recalculation happens in build or setState
                            setState(() {}); 
                          },
                          readOnly: item.item == 'Savings', // Savings is auto-calculated
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '${item.percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Income:', style: TextStyle(fontSize: 16)),
                  Text(
                    'Rs. ${(widget.surveyData.totalIncome ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Expenditure:', style: TextStyle(fontSize: 16)),
                  Flexible(
                    child: Text(
                      'Rs. ${widget.surveyData.expenditureItems.where((i) => i.item != 'Savings').fold<double>(0.0, (sum, item) => sum + item.amount).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Income Left:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Flexible(
                    child: Text(
                      'Rs. ${((widget.surveyData.totalIncome ?? 0) - widget.surveyData.expenditureItems.where((i) => i.item != 'Savings').fold<double>(0.0, (sum, item) => sum + item.amount)).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ((widget.surveyData.totalIncome ?? 0) - widget.surveyData.expenditureItems.where((i) => i.item != 'Savings').fold<double>(0.0, (sum, item) => sum + item.amount)) < 0
                            ? Colors.redAccent
                            : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Section 8: Health Conditions
class HealthConditionsSection extends StatefulWidget {
  final SurveyData surveyData;

  const HealthConditionsSection({super.key, required this.surveyData});

  @override
  State<HealthConditionsSection> createState() => _HealthConditionsSectionState();
}

class _HealthConditionsSectionState extends State<HealthConditionsSection> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: DefaultTabController(
        length: 6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Conditions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
          TabBar(
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.primary, // Ensure visible label color
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Non-Communicable'),
              Tab(text: 'Communicable'),
              Tab(text: 'Fever'),
              Tab(text: 'Skin Disease'),
              Tab(text: 'Cough'),
              Tab(text: 'Other Illness'),
            ],
          ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildDiseaseChecklist(
                    'Non-Communicable Diseases',
                    [
                      'Malnutrition', 'Anemia', 'Hypertension', 'Stroke', 'Rheumatic Heart Disease',
                      'Coronary Heart Disease', 'Cancer', 'Diabetes mellitus', 'Blindness',
                      'Fluorosis', 'Epilepsy', 'Others'
                    ],
                    widget.surveyData.nonCommunicableDiseases,
                    isNonCommunicable: true,
                  ),
                  _buildDiseaseChecklist(
                    'Communicable Diseases',
                    [
                      'Small pox', 'Chicken pox', 'Measles', 'Influenza', 'Rubella',
                      'ARI’s & Pneumonia', 'Mumps', 'Diphtheria', 'Whooping cough',
                      'Meningococcal meningitis', 'Tuberculosis', 'SARS', 'SARS 2(CORONA VIRUS)',
                      'EBOLA virus disease', 'Nipah Virus infection', 'Poliomyelitis',
                      'Viral Hepatitis', 'Cholera', 'Diarrheal diseases', 'Typhoid Fever',
                      'Food poisoning', 'Hook worm infection', 'Dengue', 'Malaria',
                      'Filariasis', 'Rabies', 'Yellow fever', 'Japanese encephalitis',
                      'Brucellosis', 'Plague', 'Anthrax', 'Trachoma', 'Tetanus',
                      'Leprosy', 'STD & RTI', 'Yaws', 'HIV/AIDS', 'Others'
                    ],
                    widget.surveyData.communicableDiseases,
                    isNonCommunicable: false,
                  ),
                  _buildHealthConditionList(
                    '11. IS THERE ANY CASE OF FEVER',
                    widget.surveyData.feverCases,
                    (list) => widget.surveyData.feverCases = list,
                  ),
                  _buildHealthConditionList(
                    '12. DOES ANYONE HAVE ANY SKIN DISEASE',
                    widget.surveyData.skinDiseases,
                    (list) => widget.surveyData.skinDiseases = list,
                  ),
                  _buildHealthConditionList(
                    '13. DOES ANY ONE HAVE COUGH FOR MORE THAN 2 WEEKS',
                    widget.surveyData.coughCases,
                    (list) => widget.surveyData.coughCases = list,
                  ),
                  _buildHealthConditionList(
                    '14. DOES ANY ONE HAVE ANY OTHER ILLNESS',
                    widget.surveyData.otherIllnesses,
                    (list) => widget.surveyData.otherIllnesses = list,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseChecklist(
    String title,
    List<String> diseases,
    List<String> selectedDiseases, {
    required bool isNonCommunicable,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: diseases.length,
            itemBuilder: (context, index) {
              final disease = diseases[index];
              return Column(
                children: [
                   CheckboxListTile(
                    title: Text(disease),
                    value: selectedDiseases.contains(disease),
                    onChanged: (value) {
                      setState(() {
                        if (value ?? false) {
                          if (!selectedDiseases.contains(disease)) {
                            selectedDiseases.add(disease);
                          }
                        } else {
                          selectedDiseases.remove(disease);
                        }
                      });
                    },
                  ),
                  if (disease == 'Others' && selectedDiseases.contains('Others'))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextFormField(
                        initialValue: isNonCommunicable 
                            ? widget.surveyData.nonCommunicableOther 
                            : widget.surveyData.communicableOther,
                        decoration: const InputDecoration(
                          labelText: 'Specify Others',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (isNonCommunicable) {
                            widget.surveyData.nonCommunicableOther = value;
                          } else {
                            widget.surveyData.communicableOther = value;
                          }
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHealthConditionList(
    String title,
    List<HealthCondition> conditions,
    Function(List<HealthCondition>) onUpdate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title)),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    conditions.add(HealthCondition(
                      name: '',
                      age: 0,
                      disease: '',
                      treatment: '',
                      remarks: '',
                    ));
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Case'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: conditions.length,
            itemBuilder: (context, index) {
              final condition = conditions[index];
              return Card(
                key: ObjectKey(condition),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Case ${index + 1}'),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                conditions.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                      TextFormField(
                        initialValue: condition.name,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => condition.name = value,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: condition.age.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Age',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                condition.age = int.tryParse(value) ?? 0;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: condition.disease,
                              decoration: const InputDecoration(
                                labelText: 'Disease',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) => condition.disease = value,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: condition.treatment,
                        decoration: const InputDecoration(
                          labelText: 'Treatment',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => condition.treatment = value,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: condition.remarks,
                        decoration: const InputDecoration(
                          labelText: 'Remarks',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        onChanged: (value) => condition.remarks = value,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Section 9: Family Health Attitude
class FamilyHealthAttitudeSection extends StatefulWidget {
  final SurveyData surveyData;

  const FamilyHealthAttitudeSection({super.key, required this.surveyData});

  @override
  State<FamilyHealthAttitudeSection> createState() => _FamilyHealthAttitudeSectionState();
}

class _FamilyHealthAttitudeSectionState extends State<FamilyHealthAttitudeSection> {
  final _communityLeadersController = TextEditingController();
  final List<String> _healthServiceOptions = [
    'Private Hospital',
    'Govt Hospital',
    'CHC',
    'PHC',
    'Local Doctors',
    'Other Systems',
  ];

  @override
  void initState() {
    super.initState();
    _communityLeadersController.text = widget.surveyData.communityLeaders ?? '';
    if (widget.surveyData.healthServiceUtilizationList == null) {
      widget.surveyData.healthServiceUtilizationList = [];
    }
  }

  @override
  void didUpdateWidget(FamilyHealthAttitudeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.surveyData != oldWidget.surveyData) {
      _communityLeadersController.text = widget.surveyData.communityLeaders ?? '';
      if (widget.surveyData.healthServiceUtilizationList == null) {
        widget.surveyData.healthServiceUtilizationList = [];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '15. FAMILY HEALTH ATTITUDE',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'a. Knowledge and attitude of family about health and illness',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: ['Inadequate', 'Moderate', 'Adequate'].contains(widget.surveyData.healthKnowledgeAttitude)
              ? widget.surveyData.healthKnowledgeAttitude
              : null,
          decoration: const InputDecoration(
            labelText: 'Select',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Inadequate', child: Text('Inadequate', style: TextStyle(fontSize: 15))),
            DropdownMenuItem(value: 'Moderate', child: Text('Moderate', style: TextStyle(fontSize: 15))),
            DropdownMenuItem(value: 'Adequate', child: Text('Adequate', style: TextStyle(fontSize: 15))),
          ],
          onChanged: (value) {
            setState(() => widget.surveyData.healthKnowledgeAttitude = value);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'b. Knowledge, attitude and beliefs of family about nutrition',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: ['Inadequate', 'Moderate', 'Adequate'].contains(widget.surveyData.nutritionKnowledgeAttitude)
              ? widget.surveyData.nutritionKnowledgeAttitude
              : null,
          decoration: const InputDecoration(
            labelText: 'Select',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Inadequate', child: Text('Inadequate', style: TextStyle(fontSize: 15))),
            DropdownMenuItem(value: 'Moderate', child: Text('Moderate', style: TextStyle(fontSize: 15))),
            DropdownMenuItem(value: 'Adequate', child: Text('Adequate', style: TextStyle(fontSize: 15))),
          ],
          onChanged: (value) {
            setState(() => widget.surveyData.nutritionKnowledgeAttitude = value);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'c. Utilization of health services',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ..._healthServiceOptions.map((option) {
          return CheckboxListTile(
            title: Text(option, style: const TextStyle(fontSize: 15)),
            value: widget.surveyData.healthServiceUtilizationList?.contains(option) ?? false,
            onChanged: (value) {
              setState(() {
                widget.surveyData.healthServiceUtilizationList ??= [];
                if (value ?? false) {
                  if (!widget.surveyData.healthServiceUtilizationList!.contains(option)) {
                    widget.surveyData.healthServiceUtilizationList!.add(option);
                  }
                } else {
                  widget.surveyData.healthServiceUtilizationList!.remove(option);
                }
                widget.surveyData.healthServiceUtilization =
                    widget.surveyData.healthServiceUtilizationList!.join(', ');
              });
            },
          );
        }).toList(),
        const SizedBox(height: 16),
        TextFormField(
          controller: _communityLeadersController,
          decoration: const InputDecoration(
            labelText: 'd. Community leaders',
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(fontSize: 15),
          onChanged: (value) => widget.surveyData.communityLeaders = value,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _communityLeadersController.dispose();
    super.dispose();
  }
}

