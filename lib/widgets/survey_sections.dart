import 'package:flutter/material.dart';
import '../models/survey_data.dart';

// Section 1: Basic Information
class BasicInformationSection extends StatefulWidget {
  final SurveyData surveyData;

  const BasicInformationSection({super.key, required this.surveyData});

  @override
  State<BasicInformationSection> createState() => _BasicInformationSectionState();
}

class _BasicInformationSectionState extends State<BasicInformationSection> {
  final _areaNameController = TextEditingController();
  final _healthCentreController = TextEditingController();
  final _headOfFamilyController = TextEditingController();
  final _subCasteController = TextEditingController();
  final _houseNoController = TextEditingController();
  final _aadharController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _areaNameController.text = widget.surveyData.areaName ?? '';
    _healthCentreController.text = widget.surveyData.healthCentreName ?? '';
    _headOfFamilyController.text = widget.surveyData.headOfFamily ?? '';
    _subCasteController.text = widget.surveyData.subCaste ?? '';
    _houseNoController.text = widget.surveyData.houseNo ?? '';
    _aadharController.text = widget.surveyData.aadharNumber ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Name of the area Rural / Urban:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _houseNoController,
          decoration: const InputDecoration(
            labelText: 'House No.',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.home),
          ),
          onChanged: (value) => widget.surveyData.houseNo = value,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _aadharController,
          decoration: const InputDecoration(
            labelText: 'Aadhar Card No. (Head of Family)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.credit_card),
            counterText: "",
          ),
          keyboardType: TextInputType.number,
          maxLength: 12,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) => widget.surveyData.aadharNumber = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Aadhar Card No.';
            }
            if (value.length != 12) {
              return 'Aadhar Card No. must be exactly 12 digits';
            }
            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
               return 'Please enter valid digits only';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _areaNameController,
          decoration: const InputDecoration(
            labelText: 'Area Name',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => widget.surveyData.areaName = value,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        const Text(
          'Area Type:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        RadioListTile<String>(
          title: const Text('Rural'),
          value: 'Rural',
          groupValue: widget.surveyData.areaType,
          onChanged: (value) {
            setState(() => widget.surveyData.areaType = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('Urban'),
          value: 'Urban',
          groupValue: widget.surveyData.areaType,
          onChanged: (value) {
            setState(() => widget.surveyData.areaType = value);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '2. Name of the Health centre:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _healthCentreController,
          decoration: const InputDecoration(
            labelText: 'Health Centre Name',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => widget.surveyData.healthCentreName = value,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        const Text(
          '3. Name of the Head of the family:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _headOfFamilyController,
          decoration: const InputDecoration(
            labelText: 'Head of Family',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => widget.surveyData.headOfFamily = value,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        const Text(
          '4. Type of family:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        CheckboxListTile(
          title: const Text('4.1 Nuclear'),
          value: widget.surveyData.familyType == 'Nuclear',
          onChanged: (value) {
            setState(() => widget.surveyData.familyType = 'Nuclear');
          },
        ),
        CheckboxListTile(
          title: const Text('4.2 Joint'),
          value: widget.surveyData.familyType == 'Joint',
          onChanged: (value) {
            setState(() => widget.surveyData.familyType = 'Joint');
          },
        ),
        CheckboxListTile(
          title: const Text('4.3 Single'),
          value: widget.surveyData.familyType == 'Single',
          onChanged: (value) {
            setState(() => widget.surveyData.familyType = 'Single');
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '5. Religion:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        RadioListTile<String>(
          title: const Text('5.1 Hindu'),
          value: 'Hindu',
          groupValue: widget.surveyData.religion,
          onChanged: (value) {
            setState(() => widget.surveyData.religion = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('5.2 Muslim'),
          value: 'Muslim',
          groupValue: widget.surveyData.religion,
          onChanged: (value) {
            setState(() => widget.surveyData.religion = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('5.3 Christian'),
          value: 'Christian',
          groupValue: widget.surveyData.religion,
          onChanged: (value) {
            setState(() => widget.surveyData.religion = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('5.4 Any other'),
          value: 'Other',
          groupValue: widget.surveyData.religion,
          onChanged: (value) {
            setState(() => widget.surveyData.religion = value);
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _subCasteController,
          decoration: const InputDecoration(
            labelText: 'Specify the sub caste',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => widget.surveyData.subCaste = value,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _areaNameController.dispose();
    _healthCentreController.dispose();
    _headOfFamilyController.dispose();
    _subCasteController.dispose();
    super.dispose();
  }
}

// Section 2: Housing Condition
class HousingConditionSection extends StatefulWidget {
  final SurveyData surveyData;

  const HousingConditionSection({super.key, required this.surveyData});

  @override
  State<HousingConditionSection> createState() => _HousingConditionSectionState();
}

class _HousingConditionSectionState extends State<HousingConditionSection> {
  final _roomsController = TextEditingController();
  final _rentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _roomsController.text = widget.surveyData.numberOfRooms?.toString() ?? '';
    _rentController.text = widget.surveyData.monthlyRent ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '6. Housing condition:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          '6.1 Type of house:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        RadioListTile<String>(
          title: const Text('1. Pucca'),
          value: 'Pucca',
          groupValue: widget.surveyData.houseType,
          onChanged: (value) {
            setState(() => widget.surveyData.houseType = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('2. Semi pucca'),
          value: 'Semi pucca',
          groupValue: widget.surveyData.houseType,
          onChanged: (value) {
            setState(() => widget.surveyData.houseType = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('3. Kutcha'),
          value: 'Kutcha',
          groupValue: widget.surveyData.houseType,
          onChanged: (value) {
            setState(() => widget.surveyData.houseType = value);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '6.2 Rooms:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        TextFormField(
          controller: _roomsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Number of rooms',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            widget.surveyData.numberOfRooms = int.tryParse(value);
          },
        ),
        const SizedBox(height: 8),
        RadioListTile<String>(
          title: const Text('1. Adequate'),
          value: 'Adequate',
          groupValue: widget.surveyData.roomAdequacy,
          onChanged: (value) {
            setState(() => widget.surveyData.roomAdequacy = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('2. Inadequate'),
          value: 'Inadequate',
          groupValue: widget.surveyData.roomAdequacy,
          onChanged: (value) {
            setState(() => widget.surveyData.roomAdequacy = value);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '6.3 Occupancy:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        RadioListTile<String>(
          title: const Text('1. Tenant'),
          value: 'Tenant',
          groupValue: widget.surveyData.occupancy,
          onChanged: (value) {
            setState(() => widget.surveyData.occupancy = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('2. Owner'),
          value: 'Owner',
          groupValue: widget.surveyData.occupancy,
          onChanged: (value) {
            setState(() => widget.surveyData.occupancy = value);
          },
        ),
        if (widget.surveyData.occupancy == 'Tenant') ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _rentController,
            decoration: const InputDecoration(
              labelText: 'a. Monthly Rent',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => widget.surveyData.monthlyRent = value,
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          '6.4 Ventilation:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        RadioListTile<String>(
          title: const Text('1. Adequate'),
          value: 'Adequate',
          groupValue: widget.surveyData.ventilation,
          onChanged: (value) {
            setState(() => widget.surveyData.ventilation = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('2. Inadequate'),
          value: 'Inadequate',
          groupValue: widget.surveyData.ventilation,
          onChanged: (value) {
            setState(() => widget.surveyData.ventilation = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('3. No Ventilation'),
          value: 'No Ventilation',
          groupValue: widget.surveyData.ventilation,
          onChanged: (value) {
            setState(() => widget.surveyData.ventilation = value);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '6.5 Lighting:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        RadioListTile<String>(
          title: const Text('1. Electricity'),
          value: 'Electricity',
          groupValue: widget.surveyData.lighting,
          onChanged: (value) {
            setState(() => widget.surveyData.lighting = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('2. Gas lamp'),
          value: 'Gas lamp',
          groupValue: widget.surveyData.lighting,
          onChanged: (value) {
            setState(() => widget.surveyData.lighting = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('3. Oil lamp'),
          value: 'Oil lamp',
          groupValue: widget.surveyData.lighting,
          onChanged: (value) {
            setState(() => widget.surveyData.lighting = value);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '6.6 Water supply:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        RadioListTile<String>(
          title: const Text('1. Tap / Hand pump'),
          value: 'Tap / Hand pump',
          groupValue: widget.surveyData.waterSupply,
          onChanged: (value) {
            setState(() => widget.surveyData.waterSupply = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('2. Well'),
          value: 'Well',
          groupValue: widget.surveyData.waterSupply,
          onChanged: (value) {
            setState(() => widget.surveyData.waterSupply = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('3. Open Tank'),
          value: 'Open Tank',
          groupValue: widget.surveyData.waterSupply,
          onChanged: (value) {
            setState(() => widget.surveyData.waterSupply = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('4. Others (Specify)'),
          value: 'Others',
          groupValue: widget.surveyData.waterSupply,
          onChanged: (value) {
            setState(() => widget.surveyData.waterSupply = value);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '6.7 Kitchen:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        RadioListTile<String>(
          title: const Text('1. Separate'),
          value: 'Separate',
          groupValue: widget.surveyData.kitchen,
          onChanged: (value) {
            setState(() => widget.surveyData.kitchen = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('2. Corner of the room'),
          value: 'Corner of the room',
          groupValue: widget.surveyData.kitchen,
          onChanged: (value) {
            setState(() => widget.surveyData.kitchen = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('3. Veranda'),
          value: 'Veranda',
          groupValue: widget.surveyData.kitchen,
          onChanged: (value) {
            setState(() => widget.surveyData.kitchen = value);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '6.8 Drainage:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        RadioListTile<String>(
          title: const Text('1. Adequate'),
          value: 'Adequate',
          groupValue: widget.surveyData.drainage,
          onChanged: (value) {
            setState(() => widget.surveyData.drainage = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('2. Inadequate'),
          value: 'Inadequate',
          groupValue: widget.surveyData.drainage,
          onChanged: (value) {
            setState(() => widget.surveyData.drainage = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('3. No Drainage'),
          value: 'No Drainage',
          groupValue: widget.surveyData.drainage,
          onChanged: (value) {
            setState(() => widget.surveyData.drainage = value);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '6.9 Lavatory:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        RadioListTile<String>(
          title: const Text('1. Own Latrine'),
          value: 'Own Latrine',
          groupValue: widget.surveyData.lavatory,
          onChanged: (value) {
            setState(() => widget.surveyData.lavatory = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('2. Public Latrine'),
          value: 'Public Latrine',
          groupValue: widget.surveyData.lavatory,
          onChanged: (value) {
            setState(() => widget.surveyData.lavatory = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('3. Open air defecation'),
          value: 'Open air defecation',
          groupValue: widget.surveyData.lavatory,
          onChanged: (value) {
            setState(() => widget.surveyData.lavatory = value);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _roomsController.dispose();
    _rentController.dispose();
    super.dispose();
  }
}

// Section 3: Family Composition
class FamilyCompositionSection extends StatefulWidget {
  final SurveyData surveyData;

  const FamilyCompositionSection({super.key, required this.surveyData});

  @override
  State<FamilyCompositionSection> createState() => _FamilyCompositionSectionState();
}

class _FamilyCompositionSectionState extends State<FamilyCompositionSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '7. Family Composition:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  widget.surveyData.familyMembers.add(FamilyMember(
                    name: '',
                    relationship: '',
                    age: 0,
                    gender: '',
                    education: '',
                    occupation: '',
                    healthStatus: '',
                  ));
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Member'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...widget.surveyData.familyMembers.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
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
                        'Member ${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            widget.surveyData.familyMembers.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: member.name,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => member.name = value,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: member.relationship.isNotEmpty ? member.relationship : null,
                    decoration: const InputDecoration(
                      labelText: 'Relationship With Head of the Family',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Hof', child: Text('Hof')),
                      DropdownMenuItem(value: 'Father', child: Text('Father')),
                      DropdownMenuItem(value: 'Mother', child: Text('Mother')),
                      DropdownMenuItem(value: 'Husband', child: Text('Husband')),
                      DropdownMenuItem(value: 'Wife', child: Text('Wife')),
                      DropdownMenuItem(value: 'Brother', child: Text('Brother')),
                      DropdownMenuItem(value: 'Sister', child: Text('Sister')),
                      DropdownMenuItem(value: 'Uncle', child: Text('Uncle')),
                      DropdownMenuItem(value: 'Aunty', child: Text('Aunty')),
                      DropdownMenuItem(value: 'Grand Son', child: Text('Grand Son')),
                      DropdownMenuItem(value: 'Grand Daughter', child: Text('Grand Daughter')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) => setState(() => member.relationship = value ?? ''),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: member.age.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Age in years',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            member.age = int.tryParse(value) ?? 0;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: member.gender.isNotEmpty ? member.gender : null,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                            DropdownMenuItem(value: 'Female', child: Text('Female')),
                          ],
                          onChanged: (value) {
                            setState(() => member.gender = value ?? '');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: member.education.isNotEmpty ? member.education : null,
                    decoration: const InputDecoration(
                      labelText: 'Education',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Professional Degree, Post Graduate', child: Text('Professional/Post Grad')),
                      DropdownMenuItem(value: 'Graduate', child: Text('Graduate')),
                      DropdownMenuItem(value: 'Diploma', child: Text('Diploma')),
                      DropdownMenuItem(value: 'High secondary school', child: Text('High secondary school')),
                      DropdownMenuItem(value: 'Secondary school', child: Text('Secondary school')),
                      DropdownMenuItem(value: 'Primary school or literate', child: Text('Primary school/literate')),
                      DropdownMenuItem(value: 'Illiterate', child: Text('Illiterate')),
                    ],
                    onChanged: (value) => setState(() => member.education = value ?? ''),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: member.occupation.isNotEmpty ? member.occupation : null,
                    decoration: const InputDecoration(
                      labelText: 'Occupation',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Laborer', child: Text('Laborer')),
                      DropdownMenuItem(value: 'Farmer', child: Text('Farmer')),
                      DropdownMenuItem(value: 'Own Business', child: Text('Own Business')),
                      DropdownMenuItem(value: 'Private job', child: Text('Private job')),
                      DropdownMenuItem(value: 'Government job', child: Text('Government job')),
                      DropdownMenuItem(value: 'Unemployment', child: Text('Unemployment')),
                    ],
                    onChanged: (value) => setState(() => member.occupation = value ?? ''),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: member.income?.toString() ?? '',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Income',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            member.income = double.tryParse(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: member.healthStatus,
                          decoration: const InputDecoration(
                            labelText: 'General health status',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => member.healthStatus = value,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

// Section 4: Income & Socio-economic
class IncomeSection extends StatefulWidget {
  final SurveyData surveyData;

  const IncomeSection({super.key, required this.surveyData});

  @override
  State<IncomeSection> createState() => _IncomeSectionState();
}

class _IncomeSectionState extends State<IncomeSection> {
  final _incomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _incomeController.text = widget.surveyData.totalIncome?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '7.A. TOTAL INCOME OF FAMILY/MONTH',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _incomeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Total Income (Rs.)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            widget.surveyData.totalIncome = double.tryParse(value);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '7.B SOCIO-ECONOMIC CLASS',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        RadioListTile<String>(
          title: const Text('a. Below Rs.1000'),
          value: 'Below Rs.1000',
          groupValue: widget.surveyData.socioEconomicClass,
          onChanged: (value) {
            setState(() => widget.surveyData.socioEconomicClass = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('b. Rs. 1000 - 1500'),
          value: 'Rs. 1000 - 1500',
          groupValue: widget.surveyData.socioEconomicClass,
          onChanged: (value) {
            setState(() => widget.surveyData.socioEconomicClass = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('c. Rs. 1501 - 2000'),
          value: 'Rs. 1501 - 2000',
          groupValue: widget.surveyData.socioEconomicClass,
          onChanged: (value) {
            setState(() => widget.surveyData.socioEconomicClass = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('d. Rs. 2001 - 2500'),
          value: 'Rs. 2001 - 2500',
          groupValue: widget.surveyData.socioEconomicClass,
          onChanged: (value) {
            setState(() => widget.surveyData.socioEconomicClass = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('e. Rs. 2501 and above'),
          value: 'Rs. 2501 and above',
          groupValue: widget.surveyData.socioEconomicClass,
          onChanged: (value) {
            setState(() => widget.surveyData.socioEconomicClass = value);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }
}

// Section 5: Transport & Communication
class TransportCommunicationSection extends StatefulWidget {
  final SurveyData surveyData;

  const TransportCommunicationSection({super.key, required this.surveyData});

  @override
  State<TransportCommunicationSection> createState() => _TransportCommunicationSectionState();
}

class _TransportCommunicationSectionState extends State<TransportCommunicationSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '8. TRANSPORT & COMMUNICATION MEDIA',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          '8.1 COMMUNICATION',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        CheckboxListTile(
          title: const Text('a. Telephone/Mobile'),
          value: widget.surveyData.communicationMedia.contains('Telephone/Mobile'),
          onChanged: (value) {
            setState(() {
              if (value ?? false) {
                widget.surveyData.communicationMedia.add('Telephone/Mobile');
              } else {
                widget.surveyData.communicationMedia.remove('Telephone/Mobile');
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('b. Television'),
          value: widget.surveyData.communicationMedia.contains('Television'),
          onChanged: (value) {
            setState(() {
              if (value ?? false) {
                widget.surveyData.communicationMedia.add('Television');
              } else {
                widget.surveyData.communicationMedia.remove('Television');
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('c. Radio'),
          value: widget.surveyData.communicationMedia.contains('Radio'),
          onChanged: (value) {
            setState(() {
              if (value ?? false) {
                widget.surveyData.communicationMedia.add('Radio');
              } else {
                widget.surveyData.communicationMedia.remove('Radio');
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('d. Newspaper/ Magazine'),
          value: widget.surveyData.communicationMedia.contains('Newspaper/ Magazine'),
          onChanged: (value) {
            setState(() {
              if (value ?? false) {
                widget.surveyData.communicationMedia.add('Newspaper/ Magazine');
              } else {
                widget.surveyData.communicationMedia.remove('Newspaper/ Magazine');
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('e. Post and Telegraph / Email'),
          value: widget.surveyData.communicationMedia.contains('Post and Telegraph / Email'),
          onChanged: (value) {
            setState(() {
              if (value ?? false) {
                widget.surveyData.communicationMedia.add('Post and Telegraph / Email');
              } else {
                widget.surveyData.communicationMedia.remove('Post and Telegraph / Email');
              }
            });
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Transport:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        CheckboxListTile(
          title: const Text('a. Tractor / Tempo'),
          value: widget.surveyData.transportOptions.contains('Tractor / Tempo'),
          onChanged: (value) {
            setState(() {
              if (value ?? false) {
                widget.surveyData.transportOptions.add('Tractor / Tempo');
              } else {
                widget.surveyData.transportOptions.remove('Tractor / Tempo');
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('b. Own Vehicle'),
          value: widget.surveyData.transportOptions.contains('Own Vehicle'),
          onChanged: (value) {
            setState(() {
              if (value ?? false) {
                widget.surveyData.transportOptions.add('Own Vehicle');
              } else {
                widget.surveyData.transportOptions.remove('Own Vehicle');
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('c. Uses GTS / GSRTC'),
          value: widget.surveyData.transportOptions.contains('Uses GTS / GSRTC'),
          onChanged: (value) {
            setState(() {
              if (value ?? false) {
                widget.surveyData.transportOptions.add('Uses GTS / GSRTC');
              } else {
                widget.surveyData.transportOptions.remove('Uses GTS / GSRTC');
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('d. Private Bus'),
          value: widget.surveyData.transportOptions.contains('Private Bus'),
          onChanged: (value) {
            setState(() {
              if (value ?? false) {
                widget.surveyData.transportOptions.add('Private Bus');
              } else {
                widget.surveyData.transportOptions.remove('Private Bus');
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('e. Train'),
          value: widget.surveyData.transportOptions.contains('Train'),
          onChanged: (value) {
            setState(() {
              if (value ?? false) {
                widget.surveyData.transportOptions.add('Train');
              } else {
                widget.surveyData.transportOptions.remove('Train');
              }
            });
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '8.2 LANGUAGE:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        const Text('Mother tongue:'),
        RadioListTile<String>(
          title: const Text('a. Gujarati'),
          value: 'Gujarati',
          groupValue: widget.surveyData.motherTongue,
          onChanged: (value) {
            setState(() => widget.surveyData.motherTongue = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('b. Hindi'),
          value: 'Hindi',
          groupValue: widget.surveyData.motherTongue,
          onChanged: (value) {
            setState(() => widget.surveyData.motherTongue = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('c. Others (Specify)'),
          value: 'Others',
          groupValue: widget.surveyData.motherTongue,
          onChanged: (value) {
            setState(() => widget.surveyData.motherTongue = value);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '8.3 LANGUAGE KNOWN:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        CheckboxListTile(
          title: const Text('a. Gujarati Read / Write'),
          value: widget.surveyData.languagesKnown.contains('Gujarati Read / Write'),
          onChanged: (value) {
            setState(() {
              if (value ?? false) {
                widget.surveyData.languagesKnown.add('Gujarati Read / Write');
              } else {
                widget.surveyData.languagesKnown.remove('Gujarati Read / Write');
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('b. Hindi Read / Write'),
          value: widget.surveyData.languagesKnown.contains('Hindi Read / Write'),
          onChanged: (value) {
            setState(() {
              if (value ?? false) {
                widget.surveyData.languagesKnown.add('Hindi Read / Write');
              } else {
                widget.surveyData.languagesKnown.remove('Hindi Read / Write');
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('c. English Read / Write'),
          value: widget.surveyData.languagesKnown.contains('English Read / Write'),
          onChanged: (value) {
            setState(() {
              if (value ?? false) {
                widget.surveyData.languagesKnown.add('English Read / Write');
              } else {
                widget.surveyData.languagesKnown.remove('English Read / Write');
              }
            });
          },
        ),
      ],
    );
  }
}

