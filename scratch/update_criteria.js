const fs = require('fs');
const path = require('path');

const formsDir = path.join(__dirname, '../assets/forms');

const criteriaData = {
  "1_1_orientation_report.json": {
    "intro": { "label": "1. Introduction and Objectives", "max_marks": 5 },
    "layout": { "label": "2. Physical Layout Description", "max_marks": 5 },
    "staffing": { "label": "3. Staffing Pattern", "max_marks": 5 },
    "services": { "label": "4. Services and Departmental Details", "max_marks": 5 },
    "records": { "label": "5. Records and Reports Maintained", "max_marks": 5 },
    "conclusion": { "label": "6. Conclusion and References", "max_marks": 5 },
    "total": { "label": "Total", "max_marks": 30 }
  },
  "2_1_care_plan.json": {
    "community_profile": { "label": "1. Community profile", "max_marks": 2 },
    "intro_obj": { "label": "2. Introduction & Objectives", "max_marks": 2 },
    "id_needs": { "label": "3. Identification of Needs/Problems", "max_marks": 4 },
    "care_plan": { "label": "4. Family Care plan", "max_marks": 10 },
    "nutrition": { "label": "5. Nutritional Assessment", "max_marks": 2 },
    "health_edu": { "label": "6. Health Education", "max_marks": 5 },
    "conclusion": { "label": "7. Conclusion and Summary", "max_marks": 2 },
    "biblio": { "label": "8. Bibliography", "max_marks": 3 },
    "total": { "label": "Total", "max_marks": 30 }
  },
  "3_1_care_study.json": {
    "intro": { "label": "1. Introduction", "max_marks": 5 },
    "obj": { "label": "2. Objectives", "max_marks": 5 },
    "roaster": { "label": "3. Family Roaster /Composition", "max_marks": 10 },
    "exam": { "label": "4. General Examination", "max_marks": 15 },
    "disease": { "label": "5. Disease Condition", "max_marks": 10 },
    "needs": { "label": "6. Identification Of Needs/Problems", "max_marks": 5 },
    "care_plan": { "label": "7. Family Care plan", "max_marks": 15 },
    "nutrition": { "label": "8. Nutritional Assessment", "max_marks": 5 },
    "health_edu": { "label": "9. Health Education", "max_marks": 10 },
    "av_aids": { "label": "10. A. V. Aids", "max_marks": 10 },
    "conclusion": { "label": "11. Conclusion and Summary", "max_marks": 5 },
    "biblio": { "label": "12. Bibliography", "max_marks": 5 },
    "total": { "label": "Total", "max_marks": 100 }
  },
  "procedure_format.json": {
    "intro": { "label": "1. Introduction & Relevance", "max_marks": 5 },
    "obj": { "label": "2. Clarity of Objectives", "max_marks": 5 },
    "baseline": { "label": "3. Client Baseline Data", "max_marks": 5 },
    "purpose": { "label": "4. Purpose of the Procedure", "max_marks": 5 },
    "articles": { "label": "5. Articles Used with Their Purpose", "max_marks": 5 },
    "steps": { "label": "6. Steps of Procedure with Rationale", "max_marks": 10 },
    "recording": { "label": "7. Recording and Reporting", "max_marks": 5 },
    "resp": { "label": "8. Nursing Responsibilities After", "max_marks": 5 },
    "biblio": { "label": "9. References / Bibliography", "max_marks": 5 },
    "total": { "label": "Total", "max_marks": 50 }
  },
  "6_1_school_health_program.json": {
    "intro": { "label": "1. Introduction", "max_marks": 5 },
    "assessment": { "label": "2. School Assessment", "max_marks": 5 },
    "planning": { "label": "3. Planning and Preparation", "max_marks": 5 },
    "execution": { "label": "4. Execution Process", "max_marks": 10 },
    "role": { "label": "5. Role of Nursing Students", "max_marks": 5 },
    "screening": { "label": "6. Health Screening Components", "max_marks": 5 },
    "data": { "label": "7. Assessment Data Presentation", "max_marks": 5 },
    "outcome": { "label": "8. Outcome Reporting", "max_marks": 5 },
    "conclusion": { "label": "9. Conclusion and Summary", "max_marks": 5 },
    "total": { "label": "Total", "max_marks": 50 }
  },
  "6_2_anganwadi_assessment.json": {
    "intro": { "label": "1. Introduction", "max_marks": 5 },
    "obj": { "label": "2. Objectives", "max_marks": 5 },
    "assessment": { "label": "3. Assessment of Anganwadi", "max_marks": 5 },
    "services": { "label": "4. Services Provided", "max_marks": 5 },
    "staffing": { "label": "5. Staffing Pattern", "max_marks": 5 },
    "layout": { "label": "6. Physical Layout & Schedule", "max_marks": 5 },
    "diet": { "label": "7. Weekly Diet Menu", "max_marks": 5 },
    "activities": { "label": "8. Student Activities", "max_marks": 5 },
    "assessment_child": { "label": "9. Health Assessment of Children", "max_marks": 5 },
    "conclusion": { "label": "10. Conclusion and Summary", "max_marks": 5 },
    "total": { "label": "Total", "max_marks": 50 }
  },
  "6_3_survey_report.json": {
    "intro": { "label": "1. Clarity of Introduction/Objectives", "max_marks": 5 },
    "village": { "label": "2. Overview/Profile of Village", "max_marks": 5 },
    "social": { "label": "3. Social Environment/Landmarks", "max_marks": 10 },
    "demographic": { "label": "4. Demographic/Environmental Analysis", "max_marks": 10 },
    "diagnosis": { "label": "5. Community Diagnosis", "max_marks": 10 },
    "knowledge": { "label": "6. Assessment of Health Knowledge", "max_marks": 5 },
    "conclusion": { "label": "7. Conclusion/Summary", "max_marks": 5 },
    "total": { "label": "Total", "max_marks": 50 }
  },
  "12_1_role_play_report.json": {
    "intro": { "label": "1. Introduction & Relevance", "max_marks": 5 },
    "obj": { "label": "2. Clarity of Objectives", "max_marks": 5 },
    "script": { "label": "3. Script Summary & Theme", "max_marks": 5 },
    "execution": { "label": "4. Role Play Execution", "max_marks": 10 },
    "participation": { "label": "5. Participation & Distribution", "max_marks": 5 },
    "methodology": { "label": "6. Methodology & Engagement", "max_marks": 5 },
    "audience": { "label": "7. Audience Involvement", "max_marks": 5 },
    "feedback": { "label": "8. Feedback Collection", "max_marks": 5 },
    "conclusion": { "label": "9. Conclusion & Impact", "max_marks": 5 },
    "total": { "label": "Total", "max_marks": 50 }
  },
  "13_visit_report.json": {
    "intro": { "label": "1. Introduction and Objectives", "max_marks": 5 },
    "layout": { "label": "2. Physical Layout Description", "max_marks": 5 },
    "staffing": { "label": "3. Staffing Pattern", "max_marks": 5 },
    "services": { "label": "4. Services and Details", "max_marks": 5 },
    "records": { "label": "5. Records and Reports", "max_marks": 5 },
    "conclusion": { "label": "6. Conclusion and References", "max_marks": 5 },
    "total": { "label": "Total", "max_marks": 30 }
  },
  "5_1_health_screening_camp_report.json": {
    "intro": { "label": "1. Introduction and Objectives", "max_marks": 5 },
    "planning": { "label": "2. Planning and Preparation", "max_marks": 10 },
    "services": { "label": "3. Services Provided During Camp", "max_marks": 10 },
    "statistics": { "label": "4. Camp Statistics and Outcome", "max_marks": 10 },
    "role": { "label": "5. Nursing Student’s Role", "max_marks": 10 },
    "conclusion": { "label": "6. Conclusion and References", "max_marks": 5 },
    "total": { "label": "Total", "max_marks": 50 }
  },
  "6_1_interaction_with_health_workers.json": {
    "details": { "label": "1. Student Details & Objectives", "max_marks": 3 },
    "profile": { "label": "2. Profile of Health Worker", "max_marks": 3 },
    "roles": { "label": "3. Roles, Responsibilities & Services", "max_marks": 6 },
    "programs": { "label": "4. National Programs & Interaction", "max_marks": 5 },
    "coordination": { "label": "5. Coordination & Problem Solving", "max_marks": 5 },
    "observation": { "label": "6. Student Observation & Learning", "max_marks": 5 },
    "conclusion": { "label": "7. Conclusion & Presentation", "max_marks": 3 },
    "total": { "label": "Total", "max_marks": 30 }
  },
  "6_3_primary_management_and_care.json": {
    "id": { "label": "1. Identification & Protocol", "max_marks": 3 },
    "screening": { "label": "2. Screening / Assessment Table", "max_marks": 6 },
    "classification": { "label": "3. Classification", "max_marks": 2 },
    "management": { "label": "4. Management & Care Table", "max_marks": 8 },
    "health_advice": { "label": "5. Health Advice Table", "max_marks": 5 },
    "referral": { "label": "6. Referral Decision (Reason)", "max_marks": 3 },
    "presentation": { "label": "7. Presentation & Conclusion", "max_marks": 3 },
    "total": { "label": "Total", "max_marks": 30 }
  },
  "11_1_disaster_mock_drill.json": {
    "details": { "label": "1. Student Details & Objectives", "max_marks": 3 },
    "understanding": { "label": "2. Understanding of Drill", "max_marks": 4 },
    "description": { "label": "3. Step-wise Description", "max_marks": 6 },
    "roles": { "label": "4. Roles of Teams", "max_marks": 5 },
    "analysis": { "label": "5. Observational Analysis", "max_marks": 5 },
    "learning": { "label": "6. Learning Experience", "max_marks": 5 },
    "conclusion": { "label": "7. Conclusion", "max_marks": 2 },
    "total": { "label": "Total", "max_marks": 30 }
  },
  "13_1_continuous_evaluation.json": {
    "leadership": { "label": "I-a) Leadership", "max_marks": 4 },
    "punctuality": { "label": "I-b) Punctuality", "max_marks": 4 },
    "grooming": { "label": "I-c) Grooming", "max_marks": 4 },
    "relationship": { "label": "I-d) Relationship with others", "max_marks": 4 },
    "attitude": { "label": "I-e) Attitude towards suggestions", "max_marks": 4 },
    "history": { "label": "II-a) History taking", "max_marks": 4 },
    "physical": { "label": "II-b) Physical assessment", "max_marks": 4 },
    "investigation": { "label": "II-c) Assisting investigation", "max_marks": 4 },
    "observation": { "label": "II-d) Observation of signs", "max_marks": 4 },
    "needs": { "label": "II-e) Identification of needs", "max_marks": 4 },
    "priority": { "label": "III-a) Selection of priority", "max_marks": 4 },
    "objectives": { "label": "III-b) Setting objectives", "max_marks": 4 },
    "interventions": { "label": "III-c) Planning interventions", "max_marks": 4 },
    "allocation": { "label": "III-d) Resource allocation", "max_marks": 4 },
    "approach": { "label": "IV-a) Approach to family", "max_marks": 4 },
    "purpose": { "label": "IV-b) Explaining purpose", "max_marks": 4 },
    "home_care": { "label": "IV-c) Providing home care", "max_marks": 4 },
    "procedure": { "label": "IV-d) Simple procedure at home", "max_marks": 4 },
    "clinical": { "label": "IV-e) Assisting in clinical services", "max_marks": 4 },
    "education": { "label": "IV-f) Health education", "max_marks": 4 },
    "recording": { "label": "IV-g) Recording and reporting", "max_marks": 4 },
    "teaching": { "label": "V-a) Health teaching", "max_marks": 4 },
    "care_eval": { "label": "V-b) Family Care", "max_marks": 4 },
    "self": { "label": "V-c) Self-assessment", "max_marks": 4 },
    "submission": { "label": "V-d) Submitting assignment on time", "max_marks": 4 },
    "total": { "label": "Total Marks", "max_marks": 100 }
  }
};

function updateForms() {
  for (const [filename, criteria] of Object.entries(criteriaData)) {
    const filePath = path.join(formsDir, filename);
    if (!fs.existsSync(filePath)) continue;

    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    
    // REMOVE all old evaluation sections to avoid duplicates and confusion
    data.sections = data.sections.filter(s => !s.section.toLowerCase().includes('evaluat'));

    // ADD the new clean evaluation section
    data.sections.push({
      "section": "Evaluation (For Evaluator Use Only)",
      "fields": [
        {
          "key": "marks",
          "label": "Evaluation Criteria",
          "type": "object",
          "properties": criteria
        }
      ]
    });

    fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
    console.log(`Cleaned and Updated ${filename}`);
  }
}

updateForms();
