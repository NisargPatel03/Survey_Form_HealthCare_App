import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { supabase } from '../services/supabase';
import { ChevronLeft, Save, CheckCircle, RotateCcw, AlertTriangle, UserPlus } from 'lucide-react';

export default function Evaluation() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [submission, setSubmission] = useState(null);
  const [formSchema, setFormSchema] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [evaluationMarks, setEvaluationMarks] = useState({});
  const [remarks, setRemarks] = useState('');
  const [error, setError] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [faculties, setFaculties] = useState([]);

  useEffect(() => {
    fetchSubmissionAndSchema();
    fetchFaculties();
  }, [id]);

  const fetchFaculties = async () => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('id, full_name')
        .eq('role', 'faculty')
        .order('full_name', { ascending: true });
      if (error) throw error;
      setFaculties(data || []);
    } catch (err) {
      console.error('Error fetching faculties:', err);
    }
  };

  const fetchSubmissionAndSchema = async () => {
    try {
      // 1. Fetch submission
      const { data: sub, error: subError } = await supabase
        .from('requirement_submissions')
        .select('*')
        .eq('id', id)
        .single();

      if (subError) throw subError;
      setSubmission(sub);
      setRemarks(sub.faculty_remarks || '');
      setEvaluationMarks(sub.evaluation_data || {});

      // 2. Determine which schema to use based on Sr No and Semester
      const lookup5th = {
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

      const lookup7th = {
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

      const getStudentSemester = (s) => {
        let sem;
        const course = (s.course_name || '').toUpperCase();
        if (course.includes('NUR 401') || course.includes('NURSING - II') || course.includes('NURSING-II') || course.includes('SEM-7') || course.includes('7TH')) {
          sem = '7';
        } else if (course.includes('NUR 303') || course.includes('NURSING - I') || course.includes('NURSING-I') || course.includes('SEM-5') || course.includes('5TH')) {
          sem = '5';
        } else {
          sem = s.class_semester || s.form_data?.class_semester || s.form_data?.semester_year || s.form_data?.semester;
        }
        sem = (sem || '5').toString().trim();
        if (sem.includes('7')) return '7';
        if (sem.includes('5')) return '5';
        return '5';
      };

      const semester = getStudentSemester(sub);
      const lookup = semester === '7' ? lookup7th : lookup5th;
      const schemaFile = lookup[sub.requirement_sr_no];

      if (!schemaFile) {
        throw new Error(`No schema found for Requirement ${sub.requirement_sr_no} in ${semester}th Semester`);
      }

      const res = await fetch(`/forms/${schemaFile}`);
      const foundSchema = await res.json();
      setFormSchema(foundSchema);
      
      // Initialize marks if empty
      if (!sub.evaluation_data && foundSchema) {
        const evalSection = foundSchema.sections.find(s => s.section.toLowerCase().includes('evaluat'));
        if (evalSection) {
          const marksField = evalSection.fields.find(f => f.key === 'marks');
          if (marksField && marksField.properties) {
            const initialMarks = {};
            Object.keys(marksField.properties).forEach(key => {
              if (key !== 'total') initialMarks[key] = '';
            });
            setEvaluationMarks(initialMarks);
          }
        }
      }

    } catch (error) {
      console.error('Error:', error);
      setError('Failed to load evaluation data.');
    } finally {
      setLoading(false);
    }
  };

  const calculateTotal = () => {
    return Object.values(evaluationMarks).reduce((sum, val) => sum + (Number(val) || 0), 0);
  };

  const handleMarkChange = (key, value, max) => {
    if (value === '') {
      setEvaluationMarks(prev => ({ ...prev, [key]: '' }));
      return;
    }
    const numVal = Math.min(Math.max(0, Number(value) || 0), max);
    setEvaluationMarks(prev => ({ ...prev, [key]: numVal }));
  };

  const submitEvaluation = async (status) => {
    if (status === 'resubmission_required' && !remarks.trim()) {
      alert('Please enter faculty remarks explaining what the student needs to correct.');
      return;
    }

    if (status === 'approved') {
      const evalSection = formSchema?.sections.find(s => s.section.toLowerCase().includes('evaluat'));
      const marksField = evalSection?.fields.find(f => f.key === 'marks');
      const marksProperties = marksField?.properties;
      
      if (marksProperties) {
        const missingKeys = [];
        Object.keys(marksProperties).forEach(key => {
          if (key !== 'total') {
            const val = evaluationMarks[key];
            if (val === undefined || val === null || val === '') {
              missingKeys.push(marksProperties[key].label || key);
            }
          }
        });
        
        if (missingKeys.length > 0) {
          alert(`Please enter marks for all criteria before approving. Missing marks for:\n- ${missingKeys.join('\n- ')}`);
          return;
        }
      }
    }

    setSaving(true);
    try {
      const isResubmit = status === 'resubmission_required';
      const total = calculateTotal();
      const evalSection = formSchema.sections.find(s => s.section.toLowerCase().includes('evaluat'));
      const marksField = evalSection?.fields.find(f => f.key === 'marks');
      const maxTotal = marksField?.properties?.total?.max_marks || 0;

      const { error } = await supabase
        .from('requirement_submissions')
        .update({
          status: status,
          marks_obtained: isResubmit ? null : total,
          max_marks: isResubmit ? null : maxTotal,
          faculty_remarks: remarks,
          evaluation_data: isResubmit ? null : evaluationMarks,
          evaluated_at: new Date().toISOString()
        })
        .eq('id', id);

      if (error) throw error;
      navigate('/');
    } catch (error) {
      console.error('Error saving evaluation:', error);
      alert('Failed to save evaluation.');
    } finally {
      setSaving(false);
    }
  };

  const saveEditedEvaluation = async () => {
    const evalSection = formSchema?.sections.find(s => s.section.toLowerCase().includes('evaluat'));
    const marksField = evalSection?.fields.find(f => f.key === 'marks');
    const marksProperties = marksField?.properties;
    
    if (marksProperties) {
      const missingKeys = [];
      Object.keys(marksProperties).forEach(key => {
        if (key !== 'total') {
          const val = evaluationMarks[key];
          if (val === undefined || val === null || val === '') {
            missingKeys.push(marksProperties[key].label || key);
          }
        }
      });
      
      if (missingKeys.length > 0) {
        alert(`Please enter marks for all criteria. Missing marks for:\n- ${missingKeys.join('\n- ')}`);
        return;
      }
    }

    setSaving(true);
    try {
      const total = calculateTotal();
      const maxTotal = marksField?.properties?.total?.max_marks || 0;

      const { error } = await supabase
        .from('requirement_submissions')
        .update({
          marks_obtained: total,
          max_marks: maxTotal,
          faculty_remarks: remarks,
          evaluation_data: evaluationMarks,
          evaluated_at: new Date().toISOString()
        })
        .eq('id', id);

      if (error) throw error;
      
      setSubmission(prev => ({
        ...prev,
        marks_obtained: total,
        max_marks: maxTotal,
        faculty_remarks: remarks,
        evaluation_data: evaluationMarks,
        evaluated_at: new Date().toISOString()
      }));
      
      setIsEditing(false);
      alert('Evaluation updated successfully.');
    } catch (error) {
      console.error('Error saving edited evaluation:', error);
      alert('Failed to update evaluation.');
    } finally {
      setSaving(false);
    }
  };

  const handleReassignFaculty = async (facultyId) => {
    const targetFaculty = faculties.find(f => f.id === facultyId);
    if (!targetFaculty) return;

    const confirmTransfer = window.confirm(
      `Are you sure you want to re-assign this submission to ${targetFaculty.full_name}?\n\nThis will transfer all evaluation responsibilities, and you will be redirected to the dashboard.`
    );
    if (!confirmTransfer) return;

    setSaving(true);
    try {
      const { error } = await supabase
        .from('requirement_submissions')
        .update({
          assigned_faculty_id: facultyId
        })
        .eq('id', id);

      if (error) throw error;
      alert(`Submission successfully transferred to ${targetFaculty.full_name}.`);
      navigate('/');
    } catch (err) {
      console.error('Error reassigning submission:', err);
      alert('Failed to re-assign submission.');
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <div className="flex justify-center py-20"><div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-primary-600"></div></div>;
  if (error) return <div className="text-center py-20 text-red-600 font-medium">{error}</div>;

  const evalSection = formSchema?.sections.find(s => s.section.toLowerCase().includes('evaluat'));
  const marksProperties = evalSection?.fields.find(f => f.key === 'marks')?.properties;

  return (
    <div className="max-w-6xl mx-auto space-y-6 lg:space-y-8 pb-20 px-2 sm:px-4 lg:px-0">
      <button 
        onClick={() => navigate('/')}
        className="flex items-center gap-2 text-gray-600 hover:text-primary-600 transition-colors p-2 -ml-2 rounded-lg hover:bg-gray-100"
      >
        <ChevronLeft className="h-5 w-5" />
        <span className="font-bold text-sm lg:text-base">Back to Dashboard</span>
      </button>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Left: Student Submission Content */}
        <div className="lg:col-span-2 space-y-6">
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
            <div className="bg-gray-50 px-6 py-4 border-b border-gray-200">
              <h3 className="font-bold text-gray-800">Student Submission Detail</h3>
              <p className="text-sm text-gray-500">{submission.requirement_sr_no} - {submission.course_name}</p>
            </div>
            <div className="p-6 space-y-8">
              {/* Render Form Data by Schema Sections */}
              {formSchema?.sections.map((section, sIdx) => (
                <div key={sIdx} className="space-y-4">
                  <h4 className="text-sm font-bold text-primary-700 border-b border-primary-100 pb-2 uppercase tracking-wide">
                    {section.section}
                  </h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    {section.fields.map((field, fIdx) => {
                      const value = submission.form_data[field.key];
                      if (field.type === 'object' || field.key === 'marks') return null;
                      
                      return (
                        <div key={fIdx} className="space-y-1">
                          <label className="text-xs font-semibold text-gray-400 uppercase">{field.label}</label>
                          <div className="text-gray-900 border-l-2 border-primary-200 pl-3 py-1 bg-primary-50/30 rounded-r-md min-h-[2rem]">
                            {field.type === 'array' ? (
                              <div className="space-y-2 py-1">
                                {Array.isArray(value) && value.map((item, iIdx) => (
                                  <div key={iIdx} className="text-sm bg-white p-2 rounded border border-primary-100 shadow-sm">
                                    {typeof item === 'object' ? (
                                      Object.entries(item).map(([k, v]) => (
                                        <div key={k} className="flex gap-2">
                                          <span className="font-semibold text-gray-500">{k}:</span>
                                          <span>{v?.toString()}</span>
                                        </div>
                                      ))
                                    ) : item?.toString()}
                                  </div>
                                ))}
                                {renderDistributionChart(field.key, value)}
                              </div>
                            ) : (field.type === 'sketch' || field.key === 'physical_layout_sketch' || field.key === 'layout_sketch_or_map') ? (
                              value ? (
                                value.startsWith('http') ? (
                                  <div className="mt-2 rounded-lg border border-gray-200 overflow-hidden bg-gray-50 max-w-lg shadow-sm">
                                    <a href={value} target="_blank" rel="noopener noreferrer" className="block relative group">
                                      <img 
                                        src={value} 
                                        alt={field.label} 
                                        className="w-full h-auto max-h-80 object-contain hover:scale-[1.02] transition-transform duration-200" 
                                      />
                                      <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center text-white text-xs font-semibold">
                                        Click to view full image
                                      </div>
                                    </a>
                                  </div>
                                ) : (
                                  <div className="text-sm text-amber-700 bg-amber-50 border border-amber-200 p-3 rounded-lg flex flex-col gap-1 mt-1">
                                    <span className="font-bold flex items-center gap-1">
                                      ⚠️ Local Draft Not Uploaded
                                    </span>
                                    <span className="text-xs break-all">Path: {value}</span>
                                  </div>
                                )
                              ) : (
                                <span className="text-gray-400 italic">No sketch response</span>
                              )
                            ) : (
                              value?.toString() || <span className="text-gray-400 italic">No response</span>
                            )}
                          </div>
                        </div>
                      );
                    })}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Right: Evaluation Form */}
        <div className="space-y-6 lg:sticky lg:top-8">
          <div className="bg-white rounded-xl shadow-sm border-2 border-primary-100 overflow-hidden">
            <div className="bg-primary-50 px-6 py-4 border-b border-primary-100">
              <h3 className="font-bold text-primary-900 flex items-center gap-2">
                <CheckCircle className="h-5 w-5" />
                Evaluator Panel
              </h3>
            </div>
            
            <div className="p-6 space-y-6">
              {/* Component-wise Marks */}
              <div className="space-y-4">
                <h4 className="text-sm font-bold text-gray-700 uppercase tracking-wider">Evaluation Criteria</h4>
                <div className="space-y-3">
                  {marksProperties && Object.entries(marksProperties).map(([key, prop]) => {
                    if (key === 'total') return null;
                    return (
                      <div key={key} className="flex flex-col gap-1">
                        <div className="flex justify-between text-sm">
                          <label className="text-gray-600 font-medium">{prop.label}</label>
                          <span className="text-gray-400">Max: {prop.max_marks}</span>
                        </div>
                        <input
                          type="number"
                          className="w-full rounded-lg border-gray-300 focus:ring-primary-500 focus:border-primary-500 py-2"
                          value={evaluationMarks[key] === undefined || evaluationMarks[key] === null ? '' : evaluationMarks[key]}
                          onChange={(e) => handleMarkChange(key, e.target.value, prop.max_marks)}
                          disabled={submission.status === 'approved' && !isEditing}
                          min="0"
                          max={prop.max_marks}
                          placeholder="Enter marks..."
                        />
                      </div>
                    );
                  })}
                </div>
                
                <div className="pt-4 border-t border-gray-100 flex justify-between items-center font-bold text-lg text-primary-900">
                  <span>Total Marks</span>
                  <span>{calculateTotal()} / {marksProperties?.total?.max_marks || 0}</span>
                </div>
              </div>

              {/* Remarks */}
              <div className="space-y-2">
                <label className="text-sm font-bold text-gray-700 uppercase tracking-wider">Faculty Remarks</label>
                <textarea
                  className="w-full rounded-lg border-gray-300 focus:ring-primary-500 focus:border-primary-500 h-32"
                  placeholder="Enter your feedback for the student..."
                  value={remarks}
                  onChange={(e) => setRemarks(e.target.value)}
                  disabled={submission.status === 'approved' && !isEditing}
                />
              </div>

              {/* Actions */}
              {submission.status !== 'approved' && (
                <div className="space-y-3 pt-4">
                  <button
                    onClick={() => submitEvaluation('approved')}
                    disabled={saving}
                    className="w-full bg-green-600 text-white py-3 rounded-lg font-bold hover:bg-green-700 transition-colors flex items-center justify-center gap-2"
                  >
                    <CheckCircle className="h-5 w-5" />
                    Approve & Assign Marks
                  </button>
                  <button
                    onClick={() => submitEvaluation('resubmission_required')}
                    disabled={saving}
                    className="w-full bg-orange-500 hover:bg-orange-650 text-white py-3 rounded-lg font-bold transition-colors flex items-center justify-center gap-2"
                  >
                    <RotateCcw className="h-5 w-5" />
                    Request Resubmission
                  </button>
                  <button
                    onClick={() => submitEvaluation('rejected')}
                    disabled={saving}
                    className="w-full bg-red-600 text-white py-3 rounded-lg font-bold hover:bg-red-700 transition-colors flex items-center justify-center gap-2"
                  >
                    <AlertTriangle className="h-5 w-5" />
                    Reject Submission
                  </button>
                </div>
              )}

              {submission.status === 'approved' && (
                <div className="space-y-3 pt-4">
                  {!isEditing ? (
                    <>
                      <div className="bg-green-50 text-green-800 p-4 rounded-lg border border-green-100 text-center font-bold flex items-center justify-center gap-2">
                        <CheckCircle className="h-5 w-5 text-green-600" />
                        Approved & Graded
                      </div>
                      <button
                        onClick={() => setIsEditing(true)}
                        disabled={saving}
                        className="w-full bg-primary-600 hover:bg-primary-700 text-white py-3 rounded-lg font-bold transition-colors flex items-center justify-center gap-2"
                      >
                        <RotateCcw className="h-5 w-5" />
                        Re-evaluate / Edit Marks
                      </button>
                    </>
                  ) : (
                    <>
                      <button
                        onClick={saveEditedEvaluation}
                        disabled={saving}
                        className="w-full bg-green-600 text-white py-3 rounded-lg font-bold hover:bg-green-700 transition-colors flex items-center justify-center gap-2"
                      >
                        <Save className="h-5 w-5" />
                        Save Changes
                      </button>
                      <button
                        onClick={() => {
                          setIsEditing(false);
                          setRemarks(submission.faculty_remarks || '');
                          setEvaluationMarks(submission.evaluation_data || {});
                        }}
                        disabled={saving}
                        className="w-full bg-gray-150 hover:bg-gray-200 text-gray-700 py-3 rounded-lg font-bold transition-colors flex items-center justify-center gap-2 border"
                      >
                        Cancel
                      </button>
                    </>
                  )}
                </div>
              )}

              {submission.status === 'resubmission_required' && (
                <div className="bg-orange-50 text-orange-800 p-4 rounded-lg border border-orange-200 text-center font-medium mt-3">
                  ⚠️ Requested resubmission from the student. Waiting for their update...
                </div>
              )}
            </div>
          </div>

          {/* Load Distribution Card */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden p-6 space-y-4">
            <h4 className="text-sm font-bold text-gray-700 uppercase tracking-wider flex items-center gap-2">
              <UserPlus className="h-5 w-5 text-primary-500" />
              Faculty Load Distribution
            </h4>
            <div className="space-y-2">
              <label className="text-xs font-semibold text-gray-500">Transfer Submission to Faculty</label>
              <select
                value={submission.assigned_faculty_id || ''}
                onChange={(e) => handleReassignFaculty(e.target.value)}
                disabled={saving}
                className="w-full rounded-lg border-gray-300 focus:ring-primary-500 focus:border-primary-500 py-2.5 text-sm cursor-pointer"
              >
                <option value="" disabled>Select Faculty...</option>
                {faculties.map((f) => (
                  <option key={f.id} value={f.id}>
                    {f.full_name}
                  </option>
                ))}
              </select>
              <p className="text-[10px] text-gray-400 mt-1 italic leading-normal">
                Re-assigning this submission will transfer all grading and review responsibilities to the selected faculty member immediately.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

const renderDistributionChart = (fieldKey, listData) => {
  if (!Array.isArray(listData) || listData.length === 0) return null;

  const chartableKeys = [
    'gender_wise_distribution',
    'religion_wise_distribution',
    'education_wise_distribution',
    'family_type_distribution',
    'occupation_wise_distribution',
    'house_type_distribution',
    'drainage_distribution',
    'waste_disposal_distribution',
    'age_wise_distribution',
    'problems_identified',
    'common_problems_identified',
    'community_diagnosis'
  ];

  if (!chartableKeys.includes(fieldKey)) return null;

  // Map elements to standard structure and sort descending
  const items = listData
    .map(item => {
      if (typeof item !== 'object' || item === null) return null;
      const category = item.category || item.condition || item.health_problem || 'Unknown';
      const pct = parseFloat(item.percentage) || 0;
      const freq = parseFloat(item.frequency || item.number_of_problems_identified) || 0;
      return { category, pct, freq };
    })
    .filter(Boolean)
    .sort((a, b) => b.pct - a.pct);

  if (items.length === 0) return null;

  const colors = [
    'bg-blue-600',
    'bg-teal-500',
    'bg-orange-500',
    'bg-purple-500',
    'bg-red-500',
    'bg-indigo-500',
    'bg-pink-500',
    'bg-amber-500'
  ];

  return (
    <div className="mt-4 p-4 bg-white rounded-xl border border-blue-150 shadow-sm space-y-4 w-full">
      <div className="flex items-center gap-2 text-blue-800 border-b border-blue-50 pb-2">
        <svg className="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 002 2h2a2 2 0 002-2z" />
        </svg>
        <span className="font-bold text-sm">Distribution Visualization</span>
      </div>
      <div className="space-y-3">
        {items.map((item, idx) => {
          const colorClass = colors[idx % colors.length];
          return (
            <div key={idx} className="space-y-1">
              <div className="flex justify-between text-xs font-semibold text-gray-700">
                <span className="truncate max-w-[70%]" title={item.category}>{item.category}</span>
                <span className="text-gray-500 font-bold">{item.freq} ({item.pct.toFixed(1)}%)</span>
              </div>
              <div className="w-full bg-gray-100 h-2.5 rounded-full overflow-hidden">
                <div 
                  className={`h-full rounded-full transition-all duration-500 ${colorClass}`}
                  style={{ width: `${Math.min(100, Math.max(0, item.pct))}%` }}
                />
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
