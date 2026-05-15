class CourseRequirement {
  final String srNo;
  final String postingType;
  final String category;
  final String name;
  final int quantity;
  final bool isSurvey; // Identifies if this is the survey report

  const CourseRequirement({
    required this.srNo,
    required this.postingType,
    required this.category,
    required this.name,
    required this.quantity,
    this.isSurvey = false,
  });
}

class CourseRequirementsData {
  static const List<CourseRequirement> nur303 = [
    // I. Rural posting
    CourseRequirement(srNo: '1.1', postingType: 'I. Rural posting', category: '1. Orientation report', name: 'Community Health Centre/Primary Health Centre', quantity: 1),
    CourseRequirement(srNo: '2.1', postingType: 'I. Rural posting', category: '2. Care plan', name: 'Communicable disease', quantity: 1),
    CourseRequirement(srNo: '3.1', postingType: 'I. Rural posting', category: '3. Care study', name: 'Communicable disease', quantity: 1),
    CourseRequirement(srNo: '4.1', postingType: 'I. Rural posting', category: '4. Procedure', name: 'Health assessment of infant', quantity: 1),
    CourseRequirement(srNo: '4.2', postingType: 'I. Rural posting', category: '4. Procedure', name: 'Health assessment of adolescent', quantity: 1),
    CourseRequirement(srNo: '5.1', postingType: 'I. Rural posting', category: '5. Health education', name: 'Exhibition/Health Talk - Group', quantity: 1),
    CourseRequirement(srNo: '6.1', postingType: 'I. Rural posting', category: '6. Participation in outreach services in Rural Area', name: 'School Health Programme', quantity: 1),
    CourseRequirement(srNo: '6.2', postingType: 'I. Rural posting', category: '6. Participation in outreach services in Rural Area', name: 'Aanaganwadi Assessment Programme', quantity: 1),
    CourseRequirement(srNo: '6.3', postingType: 'I. Rural posting', category: '6. Participation in outreach services in Rural Area', name: 'Community Health Survey Report', quantity: 1, isSurvey: true),
    
    // II. Urban posting
    CourseRequirement(srNo: '7.1', postingType: 'II. Urban posting', category: '7. Orientation report', name: 'Urban Health Centre', quantity: 1),
    CourseRequirement(srNo: '8.1', postingType: 'II. Urban posting', category: '8. Care plan', name: 'Non communicable disease', quantity: 1),
    CourseRequirement(srNo: '9.1', postingType: 'II. Urban posting', category: '9. Care study', name: 'Non communicable disease', quantity: 1),
    CourseRequirement(srNo: '10.1', postingType: 'II. Urban posting', category: '10. Procedure', name: 'Health assessment of woman', quantity: 1),
    CourseRequirement(srNo: '10.2', postingType: 'II. Urban posting', category: '10. Procedure', name: 'Health assessment of adult', quantity: 1),
    CourseRequirement(srNo: '11.1', postingType: 'II. Urban posting', category: '11. Health Talk', name: 'Health Talk - Individual', quantity: 1),
    CourseRequirement(srNo: '12.1', postingType: 'II. Urban posting', category: '12. Participation in outreach services in Urban Area', name: 'Role Play', quantity: 1),
    
    // III. Observation visit
    CourseRequirement(srNo: '13.1', postingType: 'III. Observation visit', category: '13. Observation visit', name: 'Water purification plant', quantity: 1),
    CourseRequirement(srNo: '13.2', postingType: 'III. Observation visit', category: '13. Observation visit', name: 'Sewage treatment plant', quantity: 1),
    CourseRequirement(srNo: '13.3', postingType: 'III. Observation visit', category: '13. Observation visit', name: 'Milk dairy', quantity: 1),
    CourseRequirement(srNo: '13.4', postingType: 'III. Observation visit', category: '13. Observation visit', name: 'Slaughter-House', quantity: 1),
    CourseRequirement(srNo: '13.5', postingType: 'III. Observation visit', category: '13. Observation visit', name: 'Rain water harvesting', quantity: 1),
    CourseRequirement(srNo: '13.6', postingType: 'III. Observation visit', category: '13. Observation visit', name: 'Market', quantity: 1),
  ];

  static const List<CourseRequirement> nur401 = [
    // I. Rural posting
    CourseRequirement(srNo: '1.1', postingType: 'I. Rural posting', category: '1. Orientation report', name: 'Community health centre', quantity: 1),
    CourseRequirement(srNo: '2.1', postingType: 'I. Rural posting', category: '2. Family Case study', name: 'Maternal/child health', quantity: 1),
    CourseRequirement(srNo: '3.1', postingType: 'I. Rural posting', category: '3. Care plan', name: 'High risk pregnancy', quantity: 1),
    CourseRequirement(srNo: '3.2', postingType: 'I. Rural posting', category: '3. Care plan', name: 'High risk neonate', quantity: 1),
    CourseRequirement(srNo: '4.1', postingType: 'I. Rural posting', category: '4. Procedure', name: 'Assessment of antenatal', quantity: 1),
    CourseRequirement(srNo: '4.2', postingType: 'I. Rural posting', category: '4. Procedure', name: 'Assessment of intrapartum', quantity: 1),
    CourseRequirement(srNo: '4.3', postingType: 'I. Rural posting', category: '4. Procedure', name: 'Assessment of postnatal', quantity: 1),
    CourseRequirement(srNo: '4.4', postingType: 'I. Rural posting', category: '4. Procedure', name: 'Assessment of new-born', quantity: 1),
    CourseRequirement(srNo: '4.5', postingType: 'I. Rural posting', category: '4. Procedure', name: 'Conduction of normal child birth', quantity: 1),
    CourseRequirement(srNo: '4.6', postingType: 'I. Rural posting', category: '4. Procedure', name: 'Immediate new born care', quantity: 1),
    CourseRequirement(srNo: '4.7', postingType: 'I. Rural posting', category: '4. Procedure', name: 'Assessment of mental health', quantity: 1),
    CourseRequirement(srNo: '4.8', postingType: 'I. Rural posting', category: '4. Procedure', name: 'Assessment of elderly', quantity: 1),
    CourseRequirement(srNo: '5.1', postingType: 'I. Rural posting', category: '5. Participation in outreach services in rural Area', name: 'Under five children health screening camp', quantity: 1),
    CourseRequirement(srNo: '5.2', postingType: 'I. Rural posting', category: '5. Participation in outreach services in rural Area', name: 'Geriatric health screening Camp', quantity: 1),
    CourseRequirement(srNo: '5.3', postingType: 'I. Rural posting', category: '5. Participation in outreach services in rural Area', name: 'Community health survey report', quantity: 1, isSurvey: true),
    CourseRequirement(srNo: '6.1', postingType: 'I. Rural posting', category: '6. Report', name: 'Interaction with ASHA worker', quantity: 1),
    CourseRequirement(srNo: '6.2', postingType: 'I. Rural posting', category: '6. Report', name: 'Interaction with Anganwadi Worker', quantity: 1),
    CourseRequirement(srNo: '6.3', postingType: 'I. Rural posting', category: '6. Report', name: 'Primary management and care based on protocols', quantity: 1),
    
    // II. Urban posting
    CourseRequirement(srNo: '7.1', postingType: 'II. Urban posting', category: '7. Orientation report', name: 'Urban health centre', quantity: 1),
    CourseRequirement(srNo: '8.1', postingType: 'II. Urban posting', category: '8. Care plan', name: 'Minor ailments', quantity: 1),
    CourseRequirement(srNo: '8.2', postingType: 'II. Urban posting', category: '8. Care plan', name: 'Emergencies', quantity: 1),
    CourseRequirement(srNo: '8.3', postingType: 'II. Urban posting', category: '8. Care plan', name: 'Occupational health problems-1', quantity: 1),
    CourseRequirement(srNo: '8.4', postingType: 'II. Urban posting', category: '8. Care plan', name: 'Occupational health problem-2', quantity: 1),
    CourseRequirement(srNo: '8.5', postingType: 'II. Urban posting', category: '8. Care plan', name: 'ENT problems', quantity: 1),
    CourseRequirement(srNo: '8.6', postingType: 'II. Urban posting', category: '8. Care plan', name: 'Eye problems', quantity: 1),
    CourseRequirement(srNo: '8.7', postingType: 'II. Urban posting', category: '8. Care plan', name: 'Dental Problem', quantity: 1),
    CourseRequirement(srNo: '9.1', postingType: 'II. Urban posting', category: '11. Health education', name: 'Health talk - Individual: adolescent health', quantity: 1),
    CourseRequirement(srNo: '9.2', postingType: 'II. Urban posting', category: '11. Health education', name: 'Health talk - individual: family planning', quantity: 1),
    CourseRequirement(srNo: '10.1', postingType: 'II. Urban posting', category: '12. Participation in outreach services in urban Area', name: 'Exhibition/Health Talk - Group', quantity: 1),
    CourseRequirement(srNo: '11.1', postingType: 'II. Urban posting', category: '13. Report', name: 'Participation in disaster mock drills', quantity: 1),
    
    // III. Observation visit
    CourseRequirement(srNo: '12.1', postingType: 'III. Observation visit', category: 'III. Observation visit', name: 'Biomedical waste management site', quantity: 1),
    CourseRequirement(srNo: '12.2', postingType: 'III. Observation visit', category: 'III. Observation visit', name: 'AYUSH centre', quantity: 1),
    CourseRequirement(srNo: '12.3', postingType: 'III. Observation visit', category: 'III. Observation visit', name: 'Industry', quantity: 1),
    CourseRequirement(srNo: '12.4', postingType: 'III. Observation visit', category: 'III. Observation visit', name: 'Geriatric home', quantity: 1),
    
    // IV. Other
    CourseRequirement(srNo: '13.1', postingType: 'IV. Other', category: 'IV. Other', name: 'Continuous evaluation of performance in community', quantity: 1),
  ];
}
