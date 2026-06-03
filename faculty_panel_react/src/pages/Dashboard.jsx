import { useState, useEffect } from 'react';
import { supabase } from '../services/supabase';
import { Link } from 'react-router-dom';
import { Search, Filter, Clock, CheckCircle, XCircle, AlertCircle, FileText, Download } from 'lucide-react';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

export default function Dashboard({ isHistory = false }) {
  const [submissions, setSubmissions] = useState([]);
  const [allSubmissionsForProgress, setAllSubmissionsForProgress] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState('all');

  const [selectedStudent, setSelectedStudent] = useState(null);
  const [activeSemester, setActiveSemester] = useState('5');

  useEffect(() => {
    fetchSubmissions();

    const handleFocus = () => fetchSubmissions();
    window.addEventListener('focus', handleFocus);
    return () => window.removeEventListener('focus', handleFocus);
  }, []);

  const fetchSubmissions = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;
      
      const { data, error } = await supabase
          .from('requirement_submissions')
          .select('*')
          .eq('assigned_faculty_id', user.id)
          .order('created_at', { ascending: false });

      if (error) throw error;
      setSubmissions(data || []);

      if (data && data.length > 0) {
        const studentIds = [...new Set(data.map(sub => sub.student_id))];
        const { data: allData, error: allErr } = await supabase
            .from('requirement_submissions')
            .select('*')
            .in('student_id', studentIds);
        
        if (!allErr) {
          setAllSubmissionsForProgress(allData || []);
        }
      } else {
        setAllSubmissionsForProgress([]);
      }
    } catch (error) {
      console.error('Error fetching submissions:', error);
    } finally {
      setLoading(false);
    }
  };

  // Group submissions by Student ID
  const studentGroups = submissions.reduce((groups, sub) => {
    const id = sub.student_id;
    if (!groups[id]) groups[id] = [];
    groups[id].push(sub);
    return groups;
  }, {});

  // Helper to securely deduce student semester based on course_name as fallback
  const getStudentSemester = (sub) => {
    let sem;
    const course = (sub.course_name || '').toUpperCase();
    if (course.includes('NUR 401') || course.includes('NURSING - II') || course.includes('NURSING-II') || course.includes('SEM-7') || course.includes('7TH')) {
      sem = '7';
    } else if (course.includes('NUR 303') || course.includes('NURSING - I') || course.includes('NURSING-I') || course.includes('SEM-5') || course.includes('5TH')) {
      sem = '5';
    } else {
      sem = sub.class_semester || sub.form_data?.class_semester;
    }
    sem = (sem || '5').toString().trim();
    if (sem.includes('7')) return '7';
    if (sem.includes('5')) return '5';
    return '5';
  };

  // Filter students and their submissions based on page mode (Dashboard vs History)
  const displayStudents = Object.entries(studentGroups).map(([studentId, allStudentSubmissions]) => {
    const studentProgressSubs = allSubmissionsForProgress.filter(s => s.student_id === studentId);
    const progressList = studentProgressSubs.length > 0 ? studentProgressSubs : allStudentSubmissions;

    const approvedCount = progressList.filter(s => s.status === 'approved').length;
    const pendingCount = allStudentSubmissions.filter(s => s.status === 'submitted' || s.status === 'resubmission_required').length;
    
    const displaySubmissions = (isHistory ? progressList : allStudentSubmissions).filter(s => {
      if (isHistory) {
        return s.status === 'approved';
      } else {
        return s.status === 'submitted' || s.status === 'resubmission_required';
      }
    });

    return {
      studentId,
      allSubmissions: progressList,
      displaySubmissions,
      approvedCount,
      pendingCount,
      semesterStr: getStudentSemester(allStudentSubmissions[0])
    };
  }).filter(student => student.displaySubmissions.length > 0);

  // Group displayStudents by Semester
  const semesterGroups = displayStudents.reduce((acc, student) => {
    const sem = student.semesterStr;
    if (!acc[sem]) acc[sem] = [];
    acc[sem].push(student);
    return acc;
  }, {});

  // Total requirements expected for each semester
  const SEMESTER_TOTALS = { '5': 22, '7': 35 };

  const generateCombinedPDF = (studentId, studentSubmissions) => {
    const doc = new jsPDF();
    const pageWidth = doc.internal.pageSize.getWidth();
    
    // Header
    doc.setFontSize(22);
    doc.setTextColor(20, 83, 45); // Dark Green
    doc.text("CUMULATIVE CLINICAL RECORD", pageWidth / 2, 20, { align: "center" });
    
    doc.setFontSize(14);
    doc.setTextColor(100);
    doc.text(`Student ID: ${studentId}`, 20, 35);
    doc.text(`Course: ${studentSubmissions[0].course_name}`, 20, 42);
    doc.text(`Date of Report: ${new Date().toLocaleDateString()}`, 20, 49);
    
    doc.setLineWidth(0.5);
    doc.line(20, 55, pageWidth - 20, 55);

    let yPos = 65;

    studentSubmissions.sort((a, b) => a.requirement_sr_no.localeCompare(b.requirement_sr_no)).forEach((sub, index) => {
      if (yPos > 240) {
        doc.addPage();
        yPos = 20;
      }

      // Requirement Header
      doc.setFontSize(16);
      doc.setTextColor(37, 99, 235); // Blue
      doc.text(`${sub.requirement_sr_no}. Orientation / Report Details`, 20, yPos);
      yPos += 10;

      // Table of Data
      const tableRows = [];
      Object.entries(sub.form_data).forEach(([key, value]) => {
        if (key !== 'marks' && typeof value !== 'object' && value !== null) {
          tableRows.push([key.replaceAll('_', ' ').toUpperCase(), value.toString()]);
        }
      });

      autoTable(doc, {
        startY: yPos,
        head: [['Field', 'Content']],
        body: tableRows,
        theme: 'striped',
        headStyles: { fillColor: [37, 99, 235] },
        styles: { fontSize: 9, cellPadding: 3 },
        columnStyles: { 0: { fontStyle: 'bold', width: 60 } }
      });

      yPos = doc.lastAutoTable.finalY + 10;

      // Marks Summary
      doc.setFontSize(12);
      doc.setTextColor(0);
      doc.text(`Marks Obtained: ${sub.marks_obtained} / ${sub.max_marks}`, 20, yPos);
      yPos += 7;
      if (sub.faculty_remarks) {
        doc.text(`Faculty Remarks: ${sub.faculty_remarks}`, 20, yPos);
        yPos += 7;
      }
      yPos += 15;
    });

    // Footer on each page
    const pageCount = doc.internal.getNumberOfPages();
    for (let i = 1; i <= pageCount; i++) {
      doc.setPage(i);
      doc.setFontSize(10);
      doc.setTextColor(150);
      doc.text(`Page ${i} of ${pageCount}`, pageWidth / 2, doc.internal.pageSize.getHeight() - 10, { align: "center" });
    }

    doc.save(`Clinical_Record_${studentId}.pdf`);
  };

  const getStatusBadge = (status) => {
    switch (status) {
      case 'submitted':
        return <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-blue-100 text-blue-700">PENDING</span>;
      case 'approved':
        return <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-green-100 text-green-700">APPROVED</span>;
      case 'rejected':
        return <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-red-100 text-red-700">REJECTED</span>;
      case 'resubmission_required':
        return <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-orange-100 text-orange-700">RESUBMIT</span>;
      default:
        return <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-gray-100 text-gray-700 uppercase">{status}</span>;
    }
  };

  if (loading) return (
    <div className="flex justify-center py-20">
      <div className="animate-spin rounded-full h-10 w-10 border-t-2 border-b-2 border-primary-600"></div>
    </div>
  );

  return (
    <div className="space-y-8 animate-in fade-in duration-500 pb-20">
      {/* Header Section */}
      <div className="flex flex-col xl:flex-row xl:items-center justify-between gap-6">
        <div>
          <h2 className="text-2xl lg:text-3xl font-black text-gray-900 tracking-tight">
            {isHistory ? 'Faculty History' : 'Faculty Dashboard'}
          </h2>
          <p className="text-gray-500 text-sm mt-1">
            {isHistory 
              ? 'View and download approved student records' 
              : 'Manage and evaluate requirements grouped by semester'}
          </p>
        </div>
        
        <div className="flex items-center gap-2 bg-white p-1.5 rounded-2xl shadow-sm border border-gray-100 overflow-x-auto no-scrollbar scroll-smooth">
          <button 
            onClick={() => setActiveSemester('5')}
            className={`whitespace-nowrap px-4 lg:px-6 py-2.5 rounded-xl font-bold text-xs lg:text-sm transition-all flex-shrink-0 ${activeSemester === '5' ? 'bg-primary-600 text-white shadow-lg shadow-primary-200' : 'text-gray-500 hover:bg-gray-50'}`}
          >
            5th Semester ({semesterGroups['5']?.length || 0})
          </button>
          <button 
            onClick={() => setActiveSemester('7')}
            className={`whitespace-nowrap px-4 lg:px-6 py-2.5 rounded-xl font-bold text-xs lg:text-sm transition-all flex-shrink-0 ${activeSemester === '7' ? 'bg-primary-600 text-white shadow-lg shadow-primary-200' : 'text-gray-500 hover:bg-gray-50'}`}
          >
            7th Semester ({semesterGroups['7']?.length || 0})
          </button>
        </div>
      </div>

      <div className="flex items-center gap-3">
        <div className="relative w-full md:w-96">
          <Search className="absolute left-4 top-3 h-4 w-4 text-gray-400" />
          <input
            type="text"
            placeholder={`Search ${activeSemester}th Sem Students...`}
            className="pl-11 pr-4 py-3 border-none bg-white shadow-sm rounded-2xl text-sm focus:ring-2 focus:ring-primary-500 w-full"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
      </div>

      {/* Grid of Student Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        {(semesterGroups[activeSemester] || [])
          .filter((student) => student.studentId.toLowerCase().includes(search.toLowerCase()))
          .map((student) => {
            const { studentId, displaySubmissions, allSubmissions, approvedCount, pendingCount, semesterStr } = student;
            const totalRequired = SEMESTER_TOTALS[semesterStr] || 22; // Default to 22 if unknown
            
            const isComplete = approvedCount >= totalRequired;
            const isSelected = selectedStudent === studentId;

            return (
              <div 
                key={studentId}
                className={`group relative bg-white rounded-3xl shadow-sm border-2 transition-all duration-300 overflow-hidden ${
                  isSelected ? 'border-primary-500 ring-4 ring-primary-50' : 'border-transparent hover:border-primary-200 hover:shadow-xl'
                }`}
              >
                <div className="p-6 space-y-4">
                  {/* Card Header */}
                  <div className="flex justify-between items-start">
                    <div className={`${isComplete ? 'bg-green-100' : 'bg-primary-100'} p-3 rounded-2xl`}>
                       {isComplete ? <CheckCircle className="h-6 w-6 text-green-600" /> : <AlertCircle className="h-6 w-6 text-primary-600" />}
                    </div>
                    {pendingCount > 0 && !isHistory ? (
                      <span className="bg-red-500 text-white text-[10px] font-black px-2 py-1 rounded-lg animate-pulse">
                        {pendingCount} NEW
                      </span>
                    ) : isComplete ? (
                      <span className="bg-green-600 text-white text-[10px] font-black px-2 py-1 rounded-lg">
                        COMPLETED
                      </span>
                    ) : null}
                  </div>

                  {/* Student Info */}
                  <div>
                    <h3 className="text-xl font-bold text-gray-900">{studentId}</h3>
                    <p className="text-[10px] text-primary-600 font-black uppercase tracking-widest mt-1">
                      SEMESTER {semesterStr} STUDENT
                    </p>
                  </div>

                  {/* Quick Stats */}
                  <div className="flex items-center gap-4 pt-2">
                    <div className="flex flex-col">
                      <span className="text-[10px] text-gray-400 font-bold uppercase tracking-wider">Evaluation Progress</span>
                      <div className="flex items-center gap-2 mt-1">
                        <span className={`text-2xl font-black ${isComplete ? 'text-green-600' : 'text-gray-900'}`}>{approvedCount}</span>
                        <span className="text-gray-300 text-lg font-bold">/</span>
                        <span className="text-gray-400 text-lg font-bold">{totalRequired}</span>
                      </div>
                    </div>
                  </div>

                  {/* Action Buttons */}
                  <div className="flex flex-col gap-2">
                    <button 
                      onClick={() => setSelectedStudent(isSelected ? null : studentId)}
                      className={`w-full py-3 rounded-2xl font-bold text-sm transition-all duration-300 flex items-center justify-center gap-2 ${
                        isSelected 
                          ? 'bg-gray-100 text-gray-600' 
                          : 'bg-primary-600 text-white shadow-lg shadow-primary-200 hover:scale-[1.02] active:scale-95'
                      }`}
                    >
                      {isSelected ? 'Close Details' : 'Review Submissions'}
                    </button>

                    {isComplete && (
                      <button 
                        onClick={() => generateCombinedPDF(studentId, allSubmissions.filter(s => s.status === 'approved'))}
                        className="w-full py-3 rounded-2xl font-bold text-sm bg-green-600 text-white shadow-lg shadow-green-100 hover:bg-green-700 transition-all flex items-center justify-center gap-2"
                      >
                        <Download className="h-4 w-4" />
                        Download Cumulative PDF
                      </button>
                    )}
                  </div>
                </div>

                {/* Expanded Details Section */}
                {isSelected && (
                  <div className="bg-gray-50 border-t border-gray-100 p-4 space-y-3 animate-in slide-in-from-top-4 duration-300">
                    <h4 className="text-[10px] font-black text-gray-400 uppercase tracking-widest">Requirements List</h4>
                    <div className="space-y-2">
                      {displaySubmissions.map((sub) => (
                        <Link 
                          key={sub.id}
                          to={`/evaluation/${sub.id}`}
                          className="flex items-center justify-between p-3 bg-white rounded-xl border border-gray-200 hover:border-primary-400 hover:shadow-md transition-all group/item"
                        >
                          <div className="flex flex-col">
                            <span className="text-sm font-bold text-gray-800">{sub.requirement_sr_no}</span>
                            <span className="text-[10px] text-gray-400 truncate max-w-[120px]">{sub.course_name}</span>
                          </div>
                          <div className="flex items-center gap-3">
                            {getStatusBadge(sub.status)}
                            <CheckCircle className="h-4 w-4 text-gray-300 group-hover/item:text-primary-500 transition-colors" />
                          </div>
                        </Link>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            );
          })}
        {displayStudents.length === 0 && (
          <div className="col-span-full py-20 text-center space-y-4 bg-white rounded-3xl border-2 border-dashed border-gray-200">
            <div className="inline-block p-4 bg-gray-50 rounded-full">
              <AlertCircle className="h-8 w-8 text-gray-400" />
            </div>
            <p className="text-gray-500 font-medium">
              {isHistory ? 'No approved submissions yet.' : 'No pending submissions to review.'}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
