import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/survey_data.dart';

// Section 10: Pregnant Women
class PregnantWomenSection extends StatefulWidget {
  final SurveyData surveyData;

  const PregnantWomenSection({super.key, required this.surveyData});

  @override
  State<PregnantWomenSection> createState() => _PregnantWomenSectionState();
}

class _PregnantWomenSectionState extends State<PregnantWomenSection> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  '16. ANY PREGNANT WOMEN',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    widget.surveyData.pregnantWomen.add(PregnantWoman(name: ''));
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add', style: TextStyle(fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: widget.surveyData.pregnantWomen.isEmpty
                ? const Center(
                    child: Text(
                      'No pregnant women added yet',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.surveyData.pregnantWomen.length,
                    itemBuilder: (context, index) {
                      final woman = widget.surveyData.pregnantWomen[index];
                      return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pregnant Woman ${index + 1}'),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              widget.surveyData.pregnantWomen.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      initialValue: woman.name,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => woman.name = value,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: woman.gravida?.toString() ?? '',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '16.1 Specify Gravida',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        woman.gravida = int.tryParse(value);
                      },
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('16.2 Has she been registered?'),
                      value: woman.registered ?? false,
                      onChanged: (value) {
                        setState(() => woman.registered = value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('16.3 Is she getting iron and folic acid tablets?'),
                      value: woman.gettingIronFolicAcid ?? false,
                      onChanged: (value) {
                        setState(() => woman.gettingIronFolicAcid = value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('16.4 Has she had Tetanus Toxoid?'),
                      value: woman.hadTetanusToxoid ?? false,
                      onChanged: (value) {
                        setState(() => woman.hadTetanusToxoid = value ?? false);
                      },
                    ),
                  ],
                ),
              ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Section 11: Vital Statistics
class VitalStatisticsSection extends StatefulWidget {
  final SurveyData surveyData;

  const VitalStatisticsSection({super.key, required this.surveyData});

  @override
  State<VitalStatisticsSection> createState() => _VitalStatisticsSectionState();
}

class _VitalStatisticsSectionState extends State<VitalStatisticsSection> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '17. HAVE THERE BEEN ANY births & deaths (within one year) - Vital statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TabBar(
              tabs: [
                Tab(text: 'Births'),
                Tab(text: 'Deaths'),
                Tab(text: 'Marriages'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildBirthsTab(),
                  _buildDeathsTab(),
                  _buildMarriagesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                widget.surveyData.births.add(BirthRecord(
                  gender: '',
                  parents: '',
                  remarks: '',
                ));
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Birth Record'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.surveyData.births.length,
            itemBuilder: (context, index) {
              final birth = widget.surveyData.births[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Birth ${index + 1}'),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                widget.surveyData.births.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                        ListTile(
                          title: const Text('Date of birth'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(birth.dateOfBirth != null
                                  ? DateFormat('yyyy-MM-dd').format(birth.dateOfBirth!)
                                  : 'Not set'),
                              if (birth.dateOfBirth != null)
                                Text(
                                  _calculateAge(birth.dateOfBirth!),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => birth.dateOfBirth = date);
                            }
                          },
                        ),
                      DropdownButtonFormField<String>(
                        value: birth.gender.isEmpty ? null : birth.gender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                        ],
                        onChanged: (value) {
                          setState(() => birth.gender = value ?? '');
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: birth.parents,
                        decoration: const InputDecoration(
                          labelText: 'Parents',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => birth.parents = value,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: birth.remarks,
                        decoration: const InputDecoration(
                          labelText: 'Remarks',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        onChanged: (value) => birth.remarks = value,
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

  Widget _buildDeathsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                widget.surveyData.deaths.add(DeathRecord(
                  gender: '',
                  parents: '',
                  remarks: '',
                ));
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Death Record'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.surveyData.deaths.length,
            itemBuilder: (context, index) {
              final death = widget.surveyData.deaths[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Death ${index + 1}'),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                widget.surveyData.deaths.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                      ListTile(
                        title: const Text('Date of death'),
                        subtitle: Text(death.dateOfDeath != null
                            ? DateFormat('yyyy-MM-dd').format(death.dateOfDeath!)
                            : 'Not set'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => death.dateOfDeath = date);
                          }
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: death.gender.isEmpty ? null : death.gender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                        ],
                        onChanged: (value) {
                          setState(() => death.gender = value ?? '');
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: death.parents,
                        decoration: const InputDecoration(
                          labelText: 'Parents',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => death.parents = value,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: death.remarks,
                        decoration: const InputDecoration(
                          labelText: 'Remarks',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        onChanged: (value) => death.remarks = value,
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

  Widget _buildMarriagesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                widget.surveyData.marriages.add(MarriageRecord(
                  name: '',
                  age: 0,
                  remarks: '',
                ));
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Marriage Record'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.surveyData.marriages.length,
            itemBuilder: (context, index) {
              final marriage = widget.surveyData.marriages[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Marriage ${index + 1}'),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                widget.surveyData.marriages.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                      TextFormField(
                        initialValue: marriage.name,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => marriage.name = value,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: marriage.age.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          marriage.age = int.tryParse(value) ?? 0;
                        },
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        title: const Text('Date of Marriage'),
                        subtitle: Text(marriage.dateOfMarriage != null
                            ? DateFormat('yyyy-MM-dd').format(marriage.dateOfMarriage!)
                            : 'Not set'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => marriage.dateOfMarriage = date);
                          }
                        },
                      ),
                      TextFormField(
                        initialValue: marriage.remarks,
                        decoration: const InputDecoration(
                          labelText: 'Remarks',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        onChanged: (value) => marriage.remarks = value,
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
  String _calculateAge(DateTime dob) {
    final now = DateTime.now();
    final difference = now.difference(dob);
    final days = difference.inDays;
    final years = (days / 365).floor();
    final months = ((days % 365) / 30).floor();
    
    if (years > 0) {
      return '$years years ${months > 0 ? '$months months' : ''}';
    } else if (months > 0) {
      return '$months months';
    } else {
      return '$days days';
    }
  }
}

// Section 12: Immunization
class ImmunizationSection extends StatefulWidget {
  final SurveyData surveyData;

  const ImmunizationSection({super.key, required this.surveyData});

  @override
  State<ImmunizationSection> createState() => _ImmunizationSectionState();
}

class _ImmunizationSectionState extends State<ImmunizationSection> {
  final List<String> _vaccinations = [
    'BCG',
    'OPV 0',
    'OPV 1',
    'OPV 2',
    'OPV 3',
    'OPV Booster',
    'Pentavalent 1',
    'Pentavalent 2',
    'Pentavalent 3',
    'Pentavalent Booster',
    'Measles & Rubella',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  '18. ARE THERE ANY CHILDREN BELOW 5 YEARS WHO HAVE NOT RECEIVED IMMUNIZATION',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    widget.surveyData.immunizationRecords.add(ImmunizationRecord(
                      childName: '',
                      remarks: '',
                    ));
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Child'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: widget.surveyData.immunizationRecords.isEmpty
                ? const Center(
                    child: Text(
                      'No immunization records added yet',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.surveyData.immunizationRecords.length,
                    itemBuilder: (context, index) {
                final record = widget.surveyData.immunizationRecords[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Child ${index + 1}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  widget.surveyData.immunizationRecords.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                        TextFormField(
                          initialValue: record.childName,
                          decoration: const InputDecoration(
                            labelText: 'Name of children',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => record.childName = value,
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          title: const Text('Date of birth'),
                          subtitle: Text(record.dateOfBirth != null
                              ? DateFormat('yyyy-MM-dd').format(record.dateOfBirth!)
                              : 'Not set'),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2015),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => record.dateOfBirth = date);
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Vaccinations:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ..._vaccinations.map((vaccine) {
                          return CheckboxListTile(
                            title: Text(vaccine),
                            value: record.vaccinations[vaccine] ?? false,
                            onChanged: (value) {
                              setState(() {
                                record.vaccinations[vaccine] = value ?? false;
                              });
                            },
                          );
                        }).toList(),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: record.remarks,
                          decoration: const InputDecoration(
                            labelText: 'Remarks',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                          onChanged: (value) => record.remarks = value,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

