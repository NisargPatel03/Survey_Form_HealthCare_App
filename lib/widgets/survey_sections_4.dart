import 'package:flutter/material.dart';
import '../models/survey_data.dart';

// Section 13: Eligible Couples
class EligibleCouplesSection extends StatefulWidget {
  final SurveyData surveyData;

  const EligibleCouplesSection({super.key, required this.surveyData});

  @override
  State<EligibleCouplesSection> createState() => _EligibleCouplesSectionState();
}

class _EligibleCouplesSectionState extends State<EligibleCouplesSection> {
  final _contraceptiveController = TextEditingController();
  final _notInterestedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contraceptiveController.text = widget.surveyData.contraceptiveMethod ?? '';
    _notInterestedController.text = widget.surveyData.notInterestedReason ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    '19. IS THERE ANY ELIGIBLE COUPLE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      widget.surveyData.eligibleCouples.add(EligibleCouple(
                        husbandName: '',
                        husbandAge: 0,
                        wifeName: '',
                        wifeAge: 0,
                      ));
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Couple'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: widget.surveyData.eligibleCouples.isEmpty
                  ? const Center(
                      child: Text(
                        'No eligible couples added yet',
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.surveyData.eligibleCouples.length,
                      itemBuilder: (context, index) {
                        final couple = widget.surveyData.eligibleCouples[index];
                        return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Couple ${index + 1}'),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              widget.surveyData.eligibleCouples.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      initialValue: couple.husbandName,
                      decoration: const InputDecoration(
                        labelText: 'Husband Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => couple.husbandName = value,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: couple.husbandAge.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Husband Age',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        couple.husbandAge = int.tryParse(value) ?? 0;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: couple.wifeName,
                      decoration: const InputDecoration(
                        labelText: 'Wife Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => couple.wifeName = value,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: couple.wifeAge.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Wife Age',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        couple.wifeAge = int.tryParse(value) ?? 0;
                      },
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('I Priority'),
                      value: couple.priority1,
                      onChanged: (value) {
                        setState(() => couple.priority1 = value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('II Priority'),
                      value: couple.priority2,
                      onChanged: (value) {
                        setState(() => couple.priority2 = value ?? false);
                      },
                    ),
                  ],
                ),
              ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            const Text(
              '19.1 Using contraceptive method? If yes, specify:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            TextFormField(
              controller: _contraceptiveController,
              decoration: const InputDecoration(
                labelText: 'Contraceptive Method',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => widget.surveyData.contraceptiveMethod = value,
            ),
            const SizedBox(height: 16),
            const Text(
              '19.2 Intending to undergo',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            CheckboxListTile(
              title: const Text('18.2.1 Vasectomy'),
              value: widget.surveyData.intendingVasectomy ?? false,
              onChanged: (value) {
                setState(() => widget.surveyData.intendingVasectomy = value);
              },
            ),
            CheckboxListTile(
              title: const Text('18.2.2 Tubal ligation'),
              value: widget.surveyData.intendingTubalLigation ?? false,
              onChanged: (value) {
                setState(() => widget.surveyData.intendingTubalLigation = value);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              '19.3 Not interested to adopt F. P. Method (state the reason)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            TextFormField(
              controller: _notInterestedController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => widget.surveyData.notInterestedReason = value,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contraceptiveController.dispose();
    _notInterestedController.dispose();
    super.dispose();
  }
}

// Section 14: Malnutrition
class MalnutritionSection extends StatefulWidget {
  final SurveyData surveyData;

  const MalnutritionSection({super.key, required this.surveyData});

  @override
  State<MalnutritionSection> createState() => _MalnutritionSectionState();
}

class _MalnutritionSectionState extends State<MalnutritionSection> {
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
                  '20. Is there any child 0-5 years in the family who show signs of Malnutrition',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    widget.surveyData.malnutritionCases.add(MalnutritionCase(
                      name: '',
                      age: 0,
                      remarks: '',
                    ));
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Case'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: widget.surveyData.malnutritionCases.isEmpty
                ? const Center(
                    child: Text(
                      'No malnutrition cases added yet',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.surveyData.malnutritionCases.length,
                    itemBuilder: (context, index) {
                      final case_ = widget.surveyData.malnutritionCases[index];
                      return Card(
              margin: const EdgeInsets.only(bottom: 16),
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
                              widget.surveyData.malnutritionCases.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      initialValue: case_.name,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => case_.name = value,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: case_.age.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        case_.age = int.tryParse(value) ?? 0;
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '20.1 Kwashiorkor? 20.2 Marasmus? 20.3 Vitamin A Deficiency? 20.4 Anemia? 20.5 Rickets?',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    CheckboxListTile(
                      title: const Text('20.1 Kwashiorkor'),
                      value: case_.kwashiorkor,
                      onChanged: (value) {
                        setState(() => case_.kwashiorkor = value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('20.2 Marasmus'),
                      value: case_.marasmus,
                      onChanged: (value) {
                        setState(() => case_.marasmus = value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('20.3 Vitamin A Deficiency'),
                      value: case_.vitaminADeficiency,
                      onChanged: (value) {
                        setState(() => case_.vitaminADeficiency = value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('20.4 Anemia'),
                      value: case_.anemia,
                      onChanged: (value) {
                        setState(() => case_.anemia = value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('20.5 Rickets'),
                      value: case_.rickets,
                      onChanged: (value) {
                        setState(() => case_.rickets = value ?? false);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: case_.remarks,
                      decoration: const InputDecoration(
                        labelText: 'Remarks',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: (value) => case_.remarks = value,
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

// Section 15: Environmental Health
class EnvironmentalHealthSection extends StatefulWidget {
  final SurveyData surveyData;

  const EnvironmentalHealthSection({super.key, required this.surveyData});

  @override
  State<EnvironmentalHealthSection> createState() => _EnvironmentalHealthSectionState();
}

class _EnvironmentalHealthSectionState extends State<EnvironmentalHealthSection> {
  final _sewageReasonController = TextEditingController();
  final _wasteReasonController = TextEditingController();
  final _excretaReasonController = TextEditingController();
  final _cattleReasonController = TextEditingController();
  final _wellMaintenanceReasonController = TextEditingController();
  final _wellChlorinationDateController = TextEditingController();
  final _wellChlorinationReasonController = TextEditingController();
  final _houseCleanReasonController = TextEditingController();
  final _houseSprayDateController = TextEditingController();
  final _houseSprayReasonController = TextEditingController();
  final _strayDogsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sewageReasonController.text = widget.surveyData.sewageDisposalReason ?? '';
    _wasteReasonController.text = widget.surveyData.wasteDisposalReason ?? '';
    _excretaReasonController.text = widget.surveyData.excretaDisposalReason ?? '';
    _cattleReasonController.text = widget.surveyData.cattlePoultryReason ?? '';
    _wellMaintenanceReasonController.text = widget.surveyData.wellMaintenanceReason ?? '';
    _wellChlorinationDateController.text = widget.surveyData.wellChlorinationDate ?? '';
    _wellChlorinationReasonController.text = widget.surveyData.wellChlorinationReason ?? '';
    _houseCleanReasonController.text = widget.surveyData.houseCleanReason ?? '';
    _houseSprayDateController.text = widget.surveyData.houseSprayDate ?? '';
    _houseSprayReasonController.text = widget.surveyData.houseSprayReason ?? '';
    _strayDogsController.text = widget.surveyData.numberOfStrayDogs?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '21. Is the sewage water being disposed of hygienically?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: widget.surveyData.sewageDisposalHygienic,
                onChanged: (value) {
                  setState(() => widget.surveyData.sewageDisposalHygienic = value);
                },
              ),
              const Text('Yes', style: TextStyle(fontSize: 15)),
              Radio<bool>(
                value: false,
                groupValue: widget.surveyData.sewageDisposalHygienic,
                onChanged: (value) {
                  setState(() => widget.surveyData.sewageDisposalHygienic = value);
                },
              ),
              const Text('No', style: TextStyle(fontSize: 15)),
            ],
          ),
          if (widget.surveyData.sewageDisposalHygienic == false)
            TextFormField(
              controller: _sewageReasonController,
              decoration: const InputDecoration(
                labelText: 'If no, state reasons',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 15),
              onChanged: (value) => widget.surveyData.sewageDisposalReason = value,
            ),
          if (widget.surveyData.sewageDisposalHygienic == true)
            DropdownButtonFormField<String>(
              value: ['Sewer System', 'Septic Tank', 'Pit Latrine', 'Other']
                      .contains(widget.surveyData.sewageDisposalReason)
                  ? widget.surveyData.sewageDisposalReason
                  : null,
              decoration: const InputDecoration(
                labelText: 'Method of disposal',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 15, color: Colors.black),
              items: const [
                DropdownMenuItem(value: 'Sewer System', child: Text('Sewer System', style: TextStyle(fontSize: 15, color: Colors.black))),
                DropdownMenuItem(value: 'Septic Tank', child: Text('Septic Tank', style: TextStyle(fontSize: 15, color: Colors.black))),
                DropdownMenuItem(value: 'Pit Latrine', child: Text('Pit Latrine', style: TextStyle(fontSize: 15, color: Colors.black))),
                DropdownMenuItem(value: 'Other', child: Text('Other', style: TextStyle(fontSize: 15, color: Colors.black))),
              ],
              onChanged: (value) {
                setState(() => widget.surveyData.sewageDisposalReason = value);
              },
            ),
          const SizedBox(height: 16),
          const Text(
            '22. Is the waste being disposed of hygienically?',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          CheckboxListTile(
            title: const Text('21.1 Composting'),
            value: widget.surveyData.wasteDisposalMethods.contains('Composting'),
            onChanged: (value) {
              setState(() {
                if (value ?? false) {
                  widget.surveyData.wasteDisposalMethods.add('Composting');
                } else {
                  widget.surveyData.wasteDisposalMethods.remove('Composting');
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('21.2 Burning'),
            value: widget.surveyData.wasteDisposalMethods.contains('Burning'),
            onChanged: (value) {
              setState(() {
                if (value ?? false) {
                  widget.surveyData.wasteDisposalMethods.add('Burning');
                } else {
                  widget.surveyData.wasteDisposalMethods.remove('Burning');
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('21.3 Burying'),
            value: widget.surveyData.wasteDisposalMethods.contains('Burying'),
            onChanged: (value) {
              setState(() {
                if (value ?? false) {
                  widget.surveyData.wasteDisposalMethods.add('Burying');
                } else {
                  widget.surveyData.wasteDisposalMethods.remove('Burying');
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('21.4 Dumping'),
            value: widget.surveyData.wasteDisposalMethods.contains('Dumping'),
            onChanged: (value) {
              setState(() {
                if (value ?? false) {
                  widget.surveyData.wasteDisposalMethods.add('Dumping');
                } else {
                  widget.surveyData.wasteDisposalMethods.remove('Dumping');
                }
              });
            },
          ),
          TextFormField(
            controller: _wasteReasonController,
            decoration: const InputDecoration(
              labelText: 'If no, state reasons',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => widget.surveyData.wasteDisposalReason = value,
          ),
          const SizedBox(height: 16),
          const Text(
            '23. Is the excreta being disposed of hygienically?',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: widget.surveyData.excretaDisposalHygienic,
                onChanged: (value) {
                  setState(() => widget.surveyData.excretaDisposalHygienic = value);
                },
              ),
              const Text('Yes'),
              Radio<bool>(
                value: false,
                groupValue: widget.surveyData.excretaDisposalHygienic,
                onChanged: (value) {
                  setState(() => widget.surveyData.excretaDisposalHygienic = value);
                },
              ),
              const Text('No'),
            ],
          ),
          if (widget.surveyData.excretaDisposalHygienic == false)
            TextFormField(
              controller: _excretaReasonController,
              decoration: const InputDecoration(
                labelText: 'If no, state reasons',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => widget.surveyData.excretaDisposalReason = value,
            ),
          const SizedBox(height: 16),
          const Text(
            '24. Are the cattle and poultry if any housed hygienically?',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: widget.surveyData.cattlePoultryHygienic,
                onChanged: (value) {
                  setState(() => widget.surveyData.cattlePoultryHygienic = value);
                },
              ),
              const Text('Yes'),
              Radio<bool>(
                value: false,
                groupValue: widget.surveyData.cattlePoultryHygienic,
                onChanged: (value) {
                  setState(() => widget.surveyData.cattlePoultryHygienic = value);
                },
              ),
              const Text('No'),
            ],
          ),
          if (widget.surveyData.cattlePoultryHygienic == true) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: ['separate', 'within house']
                      .contains(widget.surveyData.cattlePoultryHousing)
                  ? widget.surveyData.cattlePoultryHousing
                  : null,
              decoration: const InputDecoration(
                labelText: 'How are they housed?',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 15, color: Colors.black),
              items: const [
                DropdownMenuItem(value: 'separate', child: Text('24.1 Separate', style: TextStyle(fontSize: 15, color: Colors.black))),
                DropdownMenuItem(value: 'within house', child: Text('24.2 Within house', style: TextStyle(fontSize: 15, color: Colors.black))),
              ],
              onChanged: (value) {
                setState(() => widget.surveyData.cattlePoultryHousing = value);
              },
            ),
          ],
          if (widget.surveyData.cattlePoultryHygienic == false)
            TextFormField(
              controller: _cattleReasonController,
              decoration: const InputDecoration(
                labelText: 'If no, state reasons',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => widget.surveyData.cattlePoultryReason = value,
            ),
          const SizedBox(height: 16),
          const Text(
            '25. Is there a well or hand pump?',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: widget.surveyData.hasWellOrHandPump,
                onChanged: (value) {
                  setState(() => widget.surveyData.hasWellOrHandPump = value);
                },
              ),
              const Text('Yes'),
              Radio<bool>(
                value: false,
                groupValue: widget.surveyData.hasWellOrHandPump,
                onChanged: (value) {
                  setState(() => widget.surveyData.hasWellOrHandPump = value);
                },
              ),
              const Text('No'),
            ],
          ),
          if (widget.surveyData.hasWellOrHandPump == true) ...[
            const SizedBox(height: 8),
            const Text(
              '25.1 If yes is it maintained in good order/ condition?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: widget.surveyData.wellMaintained,
                  onChanged: (value) {
                    setState(() => widget.surveyData.wellMaintained = value);
                  },
                ),
                const Text('Yes'),
                Radio<bool>(
                  value: false,
                  groupValue: widget.surveyData.wellMaintained,
                  onChanged: (value) {
                    setState(() => widget.surveyData.wellMaintained = value);
                  },
                ),
                const Text('No'),
              ],
            ),
            if (widget.surveyData.wellMaintained == false)
              TextFormField(
                controller: _wellMaintenanceReasonController,
                decoration: const InputDecoration(
                  labelText: 'If no state reasons',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => widget.surveyData.wellMaintenanceReason = value,
              ),
            const SizedBox(height: 8),
            const Text(
              '25.2 If there is a well when was the well-chlorinated last?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Date of last chlorination', style: TextStyle(fontSize: 15)),
              subtitle: Text(
                widget.surveyData.wellChlorinationDate?.isNotEmpty ?? false
                    ? widget.surveyData.wellChlorinationDate!
                    : 'Not set',
                style: const TextStyle(fontSize: 14),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    widget.surveyData.wellChlorinationDate =
                        '${date.day}/${date.month}/${date.year}';
                  });
                }
              },
            ),
            TextFormField(
              controller: _wellChlorinationReasonController,
              decoration: const InputDecoration(
                labelText: 'If not chlorinated, state reasons',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => widget.surveyData.wellChlorinationReason = value,
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            '26. Whether house is kept clean?',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: widget.surveyData.houseKeptClean,
                onChanged: (value) {
                  setState(() => widget.surveyData.houseKeptClean = value);
                },
              ),
              const Text('Yes'),
              Radio<bool>(
                value: false,
                groupValue: widget.surveyData.houseKeptClean,
                onChanged: (value) {
                  setState(() => widget.surveyData.houseKeptClean = value);
                },
              ),
              const Text('No'),
            ],
          ),
          if (widget.surveyData.houseKeptClean == false)
            TextFormField(
              controller: _houseCleanReasonController,
              decoration: const InputDecoration(
                labelText: 'If no state reasons',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => widget.surveyData.houseCleanReason = value,
            ),
          const SizedBox(height: 16),
          const Text(
            '27. When was the house last sprayed?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Date of last spray', style: TextStyle(fontSize: 15)),
            subtitle: Text(
              widget.surveyData.houseSprayDate?.isNotEmpty ?? false
                  ? widget.surveyData.houseSprayDate!
                  : 'Not set',
              style: const TextStyle(fontSize: 14),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  widget.surveyData.houseSprayDate =
                      '${date.day}/${date.month}/${date.year}';
                });
              }
            },
          ),
          TextFormField(
            controller: _houseSprayReasonController,
            decoration: const InputDecoration(
              labelText: 'If no state reasons',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => widget.surveyData.houseSprayReason = value,
          ),
          const SizedBox(height: 16),
          const Text(
            '28. Is there any breeding place of insects and rodents?',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: widget.surveyData.breedingPlaceInsectsRodents,
                onChanged: (value) {
                  setState(() => widget.surveyData.breedingPlaceInsectsRodents = value);
                },
              ),
              const Text('Yes'),
              Radio<bool>(
                value: false,
                groupValue: widget.surveyData.breedingPlaceInsectsRodents,
                onChanged: (value) {
                  setState(() => widget.surveyData.breedingPlaceInsectsRodents = value);
                },
              ),
              const Text('No'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '29. Are there any stray dogs in the vicinity?',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: widget.surveyData.strayDogs,
                onChanged: (value) {
                  setState(() => widget.surveyData.strayDogs = value);
                },
              ),
              const Text('Yes'),
              Radio<bool>(
                value: false,
                groupValue: widget.surveyData.strayDogs,
                onChanged: (value) {
                  setState(() => widget.surveyData.strayDogs = value);
                },
              ),
              const Text('No'),
            ],
          ),
          if (widget.surveyData.strayDogs == true)
            TextFormField(
              controller: _strayDogsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'If yes, write the approximate number of dogs',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                widget.surveyData.numberOfStrayDogs = int.tryParse(value);
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sewageReasonController.dispose();
    _wasteReasonController.dispose();
    _excretaReasonController.dispose();
    _cattleReasonController.dispose();
    _wellMaintenanceReasonController.dispose();
    _wellChlorinationDateController.dispose();
    _wellChlorinationReasonController.dispose();
    _houseCleanReasonController.dispose();
    _houseSprayDateController.dispose();
    _houseSprayReasonController.dispose();
    _strayDogsController.dispose();
    super.dispose();
  }
}

