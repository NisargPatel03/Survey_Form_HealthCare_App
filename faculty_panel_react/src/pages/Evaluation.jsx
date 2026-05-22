import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { supabase } from '../services/supabase';
import { ChevronLeft, Save, CheckCircle, RotateCcw, AlertTriangle } from 'lucide-react';

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

  useEffect(() => {
    fetchSubmissionAndSchema();
  }, [id]);

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
        let sem = s.class_semester || s.form_data?.class_semester || s.form_data?.semester_year || s.form_data?.semester;
        if (!sem && s.course_name) {
          if (s.course_name.includes('NUR 401') || s.course_name.includes('Nursing - II')) {
            sem = '7';
          } else if (s.course_name.includes('NUR 303') || s.course_name.includes('Nursing - I')) {
            sem = '5';
          }
        }
        sem = (sem || '5').toString().trim();
        if (sem.includes('7')) return '7';
        if (sem.includes('5')) return '5';
        return sem;
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
        <div className="space-y-6">
          <div className="bg-white rounded-xl shadow-sm border-2 border-primary-100 overflow-hidden sticky top-8">
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
                          disabled={submission.status === 'approved'}
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
                  disabled={submission.status === 'approved'}
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
                <div className="bg-green-50 text-green-800 p-4 rounded-lg border border-green-100 text-center font-medium">
                  This submission has been approved.
                </div>
              )}

              {submission.status === 'resubmission_required' && (
                <div className="bg-orange-50 text-orange-800 p-4 rounded-lg border border-orange-200 text-center font-medium mt-3">
                  ⚠️ Requested resubmission from the student. Waiting for their update...
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
