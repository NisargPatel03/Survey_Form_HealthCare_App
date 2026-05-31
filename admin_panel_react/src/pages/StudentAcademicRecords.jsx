import React, { useState, useEffect, useMemo, useRef } from 'react';
import { supabase } from '../services/supabase';
import { 
  FaGraduationCap, 
  FaSearch, 
  FaFileCsv, 
  FaPrint, 
  FaTimes, 
  FaCheckCircle, 
  FaRegCircle, 
  FaSpinner, 
  FaExclamationCircle, 
  FaUserGraduate, 
  FaBookOpen, 
  FaAward,
  FaDownload
} from 'react-icons/fa';
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas-pro';
import XLSX from 'xlsx-js-style';

// 5th Semester Official requirements template (22 requirements, 1100 marks)
const requirements5th = [
  // I. RURAL POSTING
  { sr: '1.1', section: 'I. RURAL POSTING', category: '1. Orientation report', name: 'Primary Health Centre', max: 30 },
  { sr: '2.1', section: 'I. RURAL POSTING', category: '2. Care plan', name: 'Communicable disease', max: 30 },
  { sr: '3.1', section: 'I. RURAL POSTING', category: '3. Care study', name: 'Communicable disease', max: 100 },
  { sr: '4.1', section: 'I. RURAL POSTING', category: '4. Procedure', name: 'Health assessment of infant', max: 50 },
  { sr: '4.2', section: 'I. RURAL POSTING', category: '4. Procedure', name: 'Health assessment of adult', max: 50 },
  { sr: '5.1', section: 'I. RURAL POSTING', category: '5. Health education', name: 'Exhibition/Health Talk – Group', max: 100 },
  { sr: '6.1', section: 'I. RURAL POSTING', category: '6. Outreach', name: 'School Health Programme', max: 50 },
  { sr: '6.2', section: 'I. RURAL POSTING', category: '6. Outreach', name: 'Anganwadi Assessment Programme', max: 50 },
  { sr: '6.3', section: 'I. RURAL POSTING', category: '6. Outreach', name: 'Community Health Survey Report', max: 50 },
  
  // II. URBAN POSTING
  { sr: '7.1', section: 'II. URBAN POSTING', category: '7. Orientation report', name: 'Urban Health Centre', max: 30 },
  { sr: '8.1', section: 'II. URBAN POSTING', category: '8. Care plan', name: 'Non communicable disease', max: 30 },
  { sr: '9.1', section: 'II. URBAN POSTING', category: '9. Care study', name: 'Non communicable disease', max: 100 },
  { sr: '10.1', section: 'II. URBAN POSTING', category: '10. Procedure', name: 'Health assessment of woman', max: 50 },
  { sr: '10.2', section: 'II. URBAN POSTING', category: '10. Procedure', name: 'Health assessment of adolescent', max: 50 },
  { sr: '11.1', section: 'II. URBAN POSTING', category: '11. Health Talk', name: 'Health Talk – Individual', max: 100 },
  { sr: '12.1', section: 'II. URBAN POSTING', category: '12. Outreach', name: 'Role Play', max: 50 },
  
  // III. OBSERVATION VISIT
  { sr: '13.1', section: 'III. OBSERVATION VISIT', category: '13. Visits', name: 'Water purification plant', max: 30 },
  { sr: '13.2', section: 'III. OBSERVATION VISIT', category: '13. Visits', name: 'Sewage treatment plant', max: 30 },
  { sr: '13.3', section: 'III. OBSERVATION VISIT', category: '13. Visits', name: 'Milk dairy', max: 30 },
  { sr: '13.4', section: 'III. OBSERVATION VISIT', category: '13. Visits', name: 'Slaughter-House', max: 30 },
  { sr: '13.5', section: 'III. OBSERVATION VISIT', category: '13. Visits', name: 'Rain water harvesting', max: 30 },
  { sr: '13.6', section: 'III. OBSERVATION VISIT', category: '13. Visits', name: 'Market', max: 30 },
];

// 7th Semester Official requirements template (35 requirements, 1620 marks)
const requirements7th = [
  // I. Rural posting
  { sr: '1.1', section: 'I. RURAL POSTING', category: '1. Orientation report', name: 'Community health centre', max: 30 },
  { sr: '2.1', section: 'I. RURAL POSTING', category: '2. Family Case study', name: 'Family Case study', max: 100 },
  { sr: '3.1', section: 'I. RURAL POSTING', category: '3. Care plan', name: 'High risk pregnancy', max: 30 },
  { sr: '3.2', section: 'I. RURAL POSTING', category: '3. Care plan', name: 'High risk neonate', max: 30 },
  { sr: '4.1', section: 'I. RURAL POSTING', category: '4. Procedure', name: 'Assessment of antenatal', max: 50 },
  { sr: '4.2', section: 'I. RURAL POSTING', category: '4. Procedure', name: 'Assessment of intrapartum', max: 50 },
  { sr: '4.3', section: 'I. RURAL POSTING', category: '4. Procedure', name: 'Assessment of postnatal', max: 50 },
  { sr: '4.4', section: 'I. RURAL POSTING', category: '4. Procedure', name: 'Assessment of new-born', max: 50 },
  { sr: '4.5', section: 'I. RURAL POSTING', category: '4. Procedure', name: 'Conduction of normal child birth', max: 50 },
  { sr: '4.6', section: 'I. RURAL POSTING', category: '4. Procedure', name: 'Immediate new born care', max: 50 },
  { sr: '4.7', section: 'I. RURAL POSTING', category: '4. Procedure', name: 'Assessment of mental health', max: 50 },
  { sr: '4.8', section: 'I. RURAL POSTING', category: '4. Procedure', name: 'Assessment of elderly', max: 50 },
  { sr: '5.1', section: 'I. RURAL POSTING', category: '5. Outreach', name: 'Under five children health screening camp', max: 50 },
  { sr: '5.2', section: 'I. RURAL POSTING', category: '5. Outreach', name: 'Geriatric health screening Camp', max: 50 },
  { sr: '5.3', section: 'I. RURAL POSTING', category: '5. Outreach', name: 'Community health survey report', max: 50 },
  { sr: '6.1', section: 'I. RURAL POSTING', category: '6. Report', name: 'Interaction with ASHA worker', max: 30 },
  { sr: '6.2', section: 'I. RURAL POSTING', category: '6. Report', name: 'Interaction with Anganwadi Worker', max: 30 },
  { sr: '6.3', section: 'I. RURAL POSTING', category: '6. Report', name: 'Primary management and care based on protocols approved by MOH&FW', max: 30 },
  
  // II. Urban posting
  { sr: '7.1', section: 'II. URBAN POSTING', category: '7. Orientation report', name: 'Urban health centre', max: 30 },
  { sr: '8.1', section: 'II. URBAN POSTING', category: '8. Care plan', name: 'Minor ailments', max: 30 },
  { sr: '8.2', section: 'II. URBAN POSTING', category: '8. Care plan', name: 'Emergencies', max: 30 },
  { sr: '8.3', section: 'II. URBAN POSTING', category: '8. Care plan', name: 'Occupational health problems-1', max: 30 },
  { sr: '8.4', section: 'II. URBAN POSTING', category: '8. Care plan', name: 'Occupational health problem-2', max: 30 },
  { sr: '8.5', section: 'II. URBAN POSTING', category: '8. Care plan', name: 'ENT problems', max: 30 },
  { sr: '8.6', section: 'II. URBAN POSTING', category: '8. Care plan', name: 'Eye problems', max: 30 },
  { sr: '8.7', section: 'II. URBAN POSTING', category: '8. Care plan', name: 'Dental Problem', max: 30 },
  { sr: '9.1', section: 'II. URBAN POSTING', category: '9. Health education', name: 'Health talk – Individual: adolescent health', max: 100 },
  { sr: '9.2', section: 'II. URBAN POSTING', category: '9. Health education', name: 'Health talk – individual: family planning', max: 100 },
  { sr: '10.1', section: 'II. URBAN POSTING', category: '10. Outreach', name: 'Exhibition/Health Talk – Group', max: 100 },
  { sr: '11.1', section: 'II. URBAN POSTING', category: '11. Report', name: 'Participation in disaster mock drills', max: 30 },
  
  // III. Observation visit
  { sr: '12.1', section: 'III. OBSERVATION VISIT', category: '12. Visits', name: 'Biomedical waste management site', max: 30 },
  { sr: '12.2', section: 'III. OBSERVATION VISIT', category: '12. Visits', name: 'AYUSH Centre', max: 30 },
  { sr: '12.3', section: 'III. OBSERVATION VISIT', category: '12. Visits', name: 'Industry', max: 30 },
  { sr: '12.4', section: 'III. OBSERVATION VISIT', category: '12. Visits', name: 'Geriatric home', max: 30 },
  
  // IV. Other
  { sr: '13.1', section: 'IV. OTHER', category: '13. Continuous Evaluation', name: 'Continuous evaluation of performance in community', max: 100 },
];

// Helper to format date beautifully
const formatDate = (dateString) => {
  if (!dateString) return '—';
  try {
    const date = new Date(dateString);
    if (isNaN(date.getTime())) return '—';
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  } catch (e) {
    return '—';
  }
};

const StudentAcademicRecords = () => {
  const [submissions, setSubmissions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [activeSemester, setActiveSemester] = useState('5');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedStudent, setSelectedStudent] = useState(null);
  const [isDownloading, setIsDownloading] = useState(false);
  const printPageRef = useRef(null);
  const [selectedStudentIds, setSelectedStudentIds] = useState([]);
  const [bulkProgress, setBulkProgress] = useState('');
  const [bulkRenderStudent, setBulkRenderStudent] = useState(null);
  const bulkPrintRef = useRef(null);

  // Fetch evaluated submissions from Supabase
  useEffect(() => {
    const fetchSubmissions = async () => {
      try {
        setLoading(true);
        // We fetch ALL submissions to group them by student Roll No
        const { data, error } = await supabase
          .from('requirement_submissions')
          .select('*')
          .order('evaluated_at', { ascending: false });

        if (error) throw error;
        setSubmissions(data || []);
      } catch (err) {
        console.error('Error fetching requirements:', err);
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchSubmissions();
  }, []);

  // Robust student grouping and semester deduction logic
  const studentProfiles = useMemo(() => {
    if (!submissions.length) return {};

    const profiles = {};

    submissions.forEach(sub => {
      const id = sub.student_id ? sub.student_id.trim().toUpperCase() : null;
      if (!id) return;

      // Initialize profile
      if (!profiles[id]) {
        // Retrieve name dynamically from form_data (student_name, student_names, etc.)
        let name = 'Unknown Student';
        const data = sub.form_data || {};
        
        if (data.student_name) {
          name = data.student_name;
        } else if (data.student_names && Array.isArray(data.student_names)) {
          // Join group names or find this student's specific name
          name = data.student_names.join(', ');
        } else if (data.student_names && typeof data.student_names === 'string') {
          name = data.student_names;
        } else if (sub.student_id) {
          name = `Student ${sub.student_id}`;
        }

        // Deduce Semester based on course name or explicitly set semester
        let semester = '5';
        const course = (sub.course_name || '').toUpperCase();
        if (course.includes('NUR 401') || course.includes('NURSING - II') || course.includes('NURSING-II') || course.includes('SEM-7') || course.includes('7TH')) {
          semester = '7';
        } else if (course.includes('NUR 303') || course.includes('NURSING - I') || course.includes('NURSING-I') || course.includes('SEM-5') || course.includes('5TH')) {
          semester = '5';
        } else if (sub.class_semester && sub.class_semester.toString().includes('7')) {
          semester = '7';
        } else if (data.class_semester && data.class_semester.toString().includes('7')) {
          semester = '7';
        }

        profiles[id] = {
          student_id: id,
          student_name: name,
          semester: semester,
          requirements: {},
          totalSubmissions: 0,
          approvedCount: 0,
          totalMarks: 0,
          courseName: sub.course_name || 'N/A'
        };
      }

      // Add submission details mapped by Requirement Sr. No
      const sr = sub.requirement_sr_no;
      if (sr) {
        profiles[id].requirements[sr] = {
          status: sub.status,
          marks_obtained: sub.marks_obtained,
          max_marks: sub.max_marks,
          evaluated_at: sub.evaluated_at,
          remarks: sub.faculty_remarks,
          id: sub.id
        };

        if (sub.status === 'approved') {
          profiles[id].approvedCount += 1;
          profiles[id].totalMarks += (Number(sub.marks_obtained) || 0);
        }
        profiles[id].totalSubmissions += 1;
      }
    });

    return profiles;
  }, [submissions]);

  // Filter students based on active semester and search queries
  const filteredStudents = useMemo(() => {
    return Object.values(studentProfiles).filter(student => {
      const matchesSemester = student.semester === activeSemester;
      const matchesSearch = 
        student.student_id.toLowerCase().includes(searchQuery.toLowerCase()) ||
        student.student_name.toLowerCase().includes(searchQuery.toLowerCase());
      return matchesSemester && matchesSearch;
    });
  }, [studentProfiles, activeSemester, searchQuery]);

  // General Batch Summary Statistics
  const stats = useMemo(() => {
    const totalRequirementsCount = activeSemester === '5' ? 22 : 35;
    const totalPossibleMarks = activeSemester === '5' ? 1100 : 1620;
    
    if (!filteredStudents.length) {
      return { total: 0, completed: 0, avgMarks: 0, totalPossibleMarks };
    }

    const total = filteredStudents.length;
    
    // Student completed their posting if ALL required items are approved
    const completed = filteredStudents.filter(s => s.approvedCount >= totalRequirementsCount).length;
    
    // Average batch cumulative score
    const totalCumulativeScores = filteredStudents.reduce((sum, s) => sum + s.totalMarks, 0);
    const avgMarks = (totalCumulativeScores / total).toFixed(1);

    return { total, completed, avgMarks, totalPossibleMarks };
  }, [filteredStudents, activeSemester]);

  // CSV Exporter for posting completion lists
  const exportToCSV = () => {
    const isSem5 = activeSemester === '5';
    const reqs = isSem5 ? requirements5th : requirements7th;
    const totalPossible = isSem5 ? 1100 : 1620;

    // Header definition
    let csvContent = "data:text/csv;charset=utf-8,";
    csvContent += "Student ID,Student Name,Semester,Course Name,Approved Requirements,Cumulative Score (Out of " + totalPossible + "),Completion Status\n";

    filteredStudents.forEach(s => {
      const completionStatus = s.approvedCount >= reqs.length ? "COMPLETED" : "IN PROGRESS";
      // Sanitize fields to prevent csv breaks
      const name = s.student_name.replace(/"/g, '""');
      const course = s.courseName.replace(/"/g, '""');
      csvContent += `"${s.student_id}","${name}","${s.semester}th Semester","${course}",${s.approvedCount}/${reqs.length},${s.totalMarks},"${completionStatus}"\n`;
    });

    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `Posting_Completion_Summary_Sem_${activeSemester}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const handleDownloadPDF = async () => {
    if (!printPageRef.current) return;
    
    try {
      setIsDownloading(true);
      const element = printPageRef.current;
      
      const canvas = await html2canvas(element, {
        scale: 2,
        useCORS: true,
        logging: false,
        backgroundColor: '#dbe5f1',
      });
      
      const imgData = canvas.toDataURL('image/png');
      
      // Highly robust proportional single-page size in standard mm units
      const imgWidth = 210; // A4 standard width in mm
      const imgHeight = (canvas.height * imgWidth) / canvas.width;
      
      const pdf = new jsPDF('p', 'mm', [imgWidth, imgHeight]);
      
      pdf.addImage(
        imgData, 
        'PNG', 
        0, 
        0, 
        imgWidth, 
        imgHeight,
        undefined,
        'FAST'
      );
      
      const filename = `${selectedStudent.student_id}_${selectedStudent.student_name.replace(/\s+/g, '_')}_Marksheet.pdf`;
      pdf.save(filename);
    } catch (error) {
      console.error('Error generating PDF:', error);
      alert('Failed to generate PDF: ' + (error.message || error));
    } finally {
      setIsDownloading(false);
    }
  };

  const handleToggleSelect = (studentId) => {
    setSelectedStudentIds(prev => 
      prev.includes(studentId)
        ? prev.filter(id => id !== studentId)
        : [...prev, studentId]
    );
  };

  const handleSelectAll = (e) => {
    if (e.target.checked) {
      setSelectedStudentIds(filteredStudents.map(s => s.student_id));
    } else {
      setSelectedStudentIds([]);
    }
  };

  const handleBulkDownload = async () => {
    if (selectedStudentIds.length === 0) return;
    
    try {
      const idsToDownload = [...selectedStudentIds];
      
      for (let i = 0; i < idsToDownload.length; i++) {
        const studentId = idsToDownload[i];
        const student = studentProfiles[studentId];
        if (!student) continue;
        
        setBulkProgress(`Generating ${i + 1}/${idsToDownload.length}...`);
        setBulkRenderStudent(student);
        
        // Wait for React to render the new student details off-screen
        await new Promise(r => setTimeout(r, 200));
        
        if (bulkPrintRef.current) {
          const element = bulkPrintRef.current;
          
          const canvas = await html2canvas(element, {
            scale: 2,
            useCORS: true,
            logging: false,
            backgroundColor: '#dbe5f1',
          });
          
          const imgData = canvas.toDataURL('image/png');
          
          const imgWidth = 210; // A4 standard width in mm
          const imgHeight = (canvas.height * imgWidth) / canvas.width;
          
          const pdf = new jsPDF('p', 'mm', [imgWidth, imgHeight]);
          
          pdf.addImage(
            imgData, 
            'PNG', 
            0, 
            0, 
            imgWidth, 
            imgHeight,
            undefined,
            'FAST'
          );
          
          const filename = `${student.student_id}_${student.student_name.replace(/\s+/g, '_')}_Marksheet.pdf`;
          pdf.save(filename);
        }
      }
      
      alert(`Successfully downloaded ${idsToDownload.length} marksheets!`);
      setSelectedStudentIds([]);
    } catch (error) {
      console.error('Error generating bulk PDFs:', error);
      alert('Failed to generate bulk PDFs: ' + (error.message || error));
    } finally {
      setBulkProgress('');
      setBulkRenderStudent(null);
    }
  };

  const handleExportRequirementsExcel = () => {
    if (!filteredStudents.length) return;

    try {
      const activeReqs = activeSemester === '5' ? requirements5th : requirements7th;
      const isSem5 = activeSemester === '5';

      // 1. Double Header Arrays
      const row0 = [''];
      const row1 = ['Student Id'];

      const merges = [];

      if (isSem5) {
        // Col B to J: Rural Area
        row0[1] = 'Rural Area';
        // Col K to Q: Urban Area
        row0[10] = 'Urban Area';
        // Col R to W: Observation visit
        row0[17] = 'Observation visit';

        // Add standard empty strings for merged cells
        for (let i = 2; i <= 9; i++) row0[i] = '';
        for (let i = 11; i <= 16; i++) row0[i] = '';
        for (let i = 18; i <= 22; i++) row0[i] = '';
        row0[23] = ''; // Total cell is blank in row 0

        // Merges: B1:J1 (Col 1 to 9), K1:Q1 (Col 10 to 16), R1:W1 (Col 17 to 22)
        merges.push({ s: { r: 0, c: 1 }, e: { r: 0, c: 9 } });
        merges.push({ s: { r: 0, c: 10 }, e: { r: 0, c: 16 } });
        merges.push({ s: { r: 0, c: 17 }, e: { r: 0, c: 22 } });

        // Row 1 Column headers
        // Rural Posting
        row1.push('Orientation report');
        row1.push('Care plan');
        row1.push('Care study');
        row1.push('Procedure-1');
        row1.push('Procedure-2');
        row1.push('Group Health education');
        row1.push('School Health Programme');
        row1.push('Aanaganwadi Assessment Programme');
        row1.push('Community Health Survey Report');

        // Urban Posting
        row1.push('Orientation report');
        row1.push('Care plan');
        row1.push('Care study');
        row1.push('Procedure-1');
        row1.push('Procedure-2');
        row1.push('Individual Health education');
        row1.push('Role Play');

        // Observation visits
        row1.push('Water purification plant');
        row1.push('Sewage treatment plant');
        row1.push('Milk dairy');
        row1.push('Slaughter House');
        row1.push('Rain water harvesting');
        row1.push('Market');

        row1.push('Total');
      } else {
        // Semester 7 merging logic
        // Identify sections and lengths
        const ruralCount = activeReqs.filter(r => r.section.toUpperCase().includes('RURAL')).length;
        const urbanCount = activeReqs.filter(r => r.section.toUpperCase().includes('URBAN')).length;
        const obsCount = activeReqs.filter(r => r.section.toUpperCase().includes('OBSERVATION')).length;
        const otherCount = activeReqs.filter(r => r.section.toUpperCase().includes('OTHER')).length;

        let colIdx = 1;

        // Rural area merge
        row0[colIdx] = 'Rural Area';
        for (let i = 1; i < ruralCount; i++) row0[colIdx + i] = '';
        merges.push({ s: { r: 0, c: colIdx }, e: { r: 0, c: colIdx + ruralCount - 1 } });
        colIdx += ruralCount;

        // Urban area merge
        row0[colIdx] = 'Urban Area';
        for (let i = 1; i < urbanCount; i++) row0[colIdx + i] = '';
        merges.push({ s: { r: 0, c: colIdx }, e: { r: 0, c: colIdx + urbanCount - 1 } });
        colIdx += urbanCount;

        // Observation visit merge
        row0[colIdx] = 'Observation visit';
        for (let i = 1; i < obsCount; i++) row0[colIdx + i] = '';
        merges.push({ s: { r: 0, c: colIdx }, e: { r: 0, c: colIdx + obsCount - 1 } });
        colIdx += obsCount;

        // Other merge if exists
        if (otherCount > 0) {
          row0[colIdx] = 'Other';
          for (let i = 1; i < otherCount; i++) row0[colIdx + i] = '';
          merges.push({ s: { r: 0, c: colIdx }, e: { r: 0, c: colIdx + otherCount - 1 } });
          colIdx += otherCount;
        }

        row0[colIdx] = ''; // Total cell

        // Row 1 Column headers
        activeReqs.forEach(req => {
          row1.push(req.name);
        });
        row1.push('Total');
      }

      // 2. Build Rows Data
      const sheetData = [row0, row1];

      filteredStudents.forEach(student => {
        const studentRow = [student.student_id];
        
        activeReqs.forEach(req => {
          const achievement = student.requirements[req.sr];
          if (achievement && achievement.status === 'approved') {
            studentRow.push(achievement.marks_obtained);
          } else {
            studentRow.push(0); // Match non-empty numeric zero if not completed
          }
        });

        studentRow.push(student.totalMarks);
        sheetData.push(studentRow);
      });

      // 3. Create Workbook & Sheets
      const wb = XLSX.utils.book_new();
      const ws = XLSX.utils.aoa_to_sheet(sheetData);

      // Apply Merges
      ws['!merges'] = merges;

      // Define standard styling (clean table borders, solid headers)
      const borderStyle = {
        top: { style: 'thin', color: { rgb: 'CCCCCC' } },
        bottom: { style: 'thin', color: { rgb: 'CCCCCC' } },
        left: { style: 'thin', color: { rgb: 'CCCCCC' } },
        right: { style: 'thin', color: { rgb: 'CCCCCC' } }
      };

      const range = XLSX.utils.decode_range(ws['!ref']);

      // Apply premium styles to cells
      for (let R = range.s.r; R <= range.e.r; ++R) {
        for (let C = range.s.c; C <= range.e.c; ++C) {
          const cellRef = XLSX.utils.encode_cell({ c: C, r: R });
          const cell = ws[cellRef];
          if (!cell) continue;

          if (!cell.s) cell.s = {};
          cell.s.border = borderStyle;

          // Double Row 0 and Row 1 headers (Bold, Centered)
          if (R === 0 || R === 1) {
            cell.s.font = { bold: true, name: 'Calibri', sz: 10 };
            cell.s.alignment = { horizontal: 'center', vertical: 'center' };
          } else {
            // Data Rows alignment
            if (C === 0) {
              // Student Roll Number left aligned, bold
              cell.s.font = { bold: true, name: 'Calibri', sz: 10 };
              cell.s.alignment = { horizontal: 'left', vertical: 'center' };
            } else if (C === range.e.c) {
              // Total Marks Column bold, centered
              cell.s.font = { bold: true, name: 'Calibri', sz: 10 };
              cell.s.alignment = { horizontal: 'center', vertical: 'center' };
            } else {
              // Marks: centered
              cell.s.alignment = { horizontal: 'center', vertical: 'center' };
            }
          }
        }
      }

      // Column widths
      const wscols = [{ wch: 15 }]; // Student Id column
      for (let i = 1; i < row1.length - 1; i++) {
        wscols.push({ wch: 18 }); // Requirement columns wide enough
      }
      wscols.push({ wch: 10 }); // Total column
      ws['!cols'] = wscols;

      // 4. Save file
      XLSX.utils.book_append_sheet(wb, ws, `NUR${isSem5 ? '303' : '404'}_Marksheet`);
      XLSX.writeFile(wb, `NUR${isSem5 ? '303' : '404'}_REQUIREMENTS_MARKS_${new Date().toISOString().split('T')[0]}.xlsx`);

    } catch (error) {
      console.error('Error generating Requirements Excel:', error);
      alert('Failed to generate Excel sheet: ' + (error.message || error));
    }
  };

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center p-12 min-h-[400px]">
        <FaSpinner className="animate-spin text-primary text-5xl mb-4" />
        <span className="text-gray-600 font-semibold">Fetching academic evaluation records...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-xl p-6 text-center max-w-lg mx-auto my-8">
        <FaExclamationCircle className="text-red-500 text-5xl mx-auto mb-4" />
        <h3 className="text-xl font-bold text-red-800 mb-2">Failed to Load Records</h3>
        <p className="text-red-600 mb-4">{error}</p>
        <button 
          onClick={() => window.location.reload()}
          className="px-6 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition"
        >
          Retry
        </button>
      </div>
    );
  }

  const selectedReqs = selectedStudent?.semester === '5' ? requirements5th : requirements7th;
  const selectedTotalPossible = selectedStudent?.semester === '5' ? 1100 : 1620;
  const isSelectedCompleted = selectedStudent && selectedStudent.approvedCount >= selectedReqs.length;

  return (
    <div className="relative">
      {/* Hide wrapper layout on printing */}
      <div className="print:hidden">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-8 gap-4">
          <div>
            <h2 className="text-3xl font-bold text-gray-800 flex items-center gap-3">
              <FaGraduationCap className="text-primary" />
              Academic Evaluation & Posting Completion
            </h2>
            <p className="text-gray-600 mt-1">
              Access semester-wise student transcripts, view marks, print official marksheets, and export posting summaries.
            </p>
          </div>
          <div className="flex flex-col sm:flex-row gap-3 justify-end items-stretch sm:items-center w-full md:w-auto">
            <button
              onClick={handleExportRequirementsExcel}
              disabled={!filteredStudents.length}
              className="flex items-center justify-center gap-2 px-5 py-2.5 bg-[#1D6F42] text-white font-semibold rounded-lg shadow hover:bg-[#155231] disabled:opacity-50 disabled:cursor-not-allowed transition duration-200 text-sm"
            >
              <FaFileCsv size={18} />
              Download NUR{activeSemester === '5' ? '303' : '404'} Excel
            </button>

            <button
              onClick={exportToCSV}
              disabled={!filteredStudents.length}
              className="flex items-center justify-center gap-2 px-5 py-2.5 bg-green-600 text-white font-semibold rounded-lg shadow hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition duration-200 text-sm"
            >
              <FaFileCsv size={18} />
              Export Posting Summary
            </button>
            
            <button
              onClick={handleBulkDownload}
              disabled={selectedStudentIds.length === 0 || bulkProgress !== ''}
              className="flex items-center justify-center gap-2 px-5 py-2.5 bg-primary text-white font-semibold rounded-lg shadow hover:bg-secondary disabled:opacity-50 disabled:cursor-not-allowed transition duration-200 text-sm"
            >
              {bulkProgress !== '' ? (
                <>
                  <FaSpinner className="animate-spin" size={18} />
                  <span>{bulkProgress}</span>
                </>
              ) : (
                <>
                  <FaDownload size={18} />
                  <span>Download Selected ({selectedStudentIds.length})</span>
                </>
              )}
            </button>
          </div>
        </div>

        {/* Tab switcher and search query */}
        <div className="flex flex-col md:flex-row justify-between items-center gap-4 bg-white p-4 rounded-xl shadow-sm border border-gray-100 mb-8">
          <div className="flex gap-2 w-full md:w-auto">
            <button
              onClick={() => { setActiveSemester('5'); setSelectedStudent(null); setSelectedStudentIds([]); }}
              className={`flex-1 md:flex-none px-6 py-2.5 rounded-lg font-bold transition duration-200 ${
                activeSemester === '5' 
                  ? 'bg-primary text-white shadow-md' 
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              5th Semester
            </button>
            <button
              onClick={() => { setActiveSemester('7'); setSelectedStudent(null); setSelectedStudentIds([]); }}
              className={`flex-1 md:flex-none px-6 py-2.5 rounded-lg font-bold transition duration-200 ${
                activeSemester === '7' 
                  ? 'bg-primary text-white shadow-md' 
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              7th Semester
            </button>
          </div>

          <div className="relative w-full md:w-80">
            <FaSearch className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              placeholder="Search Student ID or Name..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary text-sm"
            />
          </div>
        </div>

        {/* Summary statistics grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100 flex items-center gap-4">
            <div className="p-3.5 bg-blue-50 text-blue-600 rounded-lg">
              <FaUserGraduate size={24} />
            </div>
            <div>
              <span className="text-sm text-gray-500 font-medium block">Students Enrolled</span>
              <span className="text-2xl font-bold text-gray-800">{stats.total}</span>
            </div>
          </div>

          <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100 flex items-center gap-4">
            <div className="p-3.5 bg-green-50 text-green-600 rounded-lg">
              <FaCheckCircle size={24} />
            </div>
            <div>
              <span className="text-sm text-gray-500 font-medium block">Completed Postings</span>
              <span className="text-2xl font-bold text-gray-800">
                {stats.completed} <span className="text-sm text-gray-400 font-normal">/ {stats.total}</span>
              </span>
            </div>
          </div>

          <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100 flex items-center gap-4">
            <div className="p-3.5 bg-purple-50 text-purple-600 rounded-lg">
              <FaAward size={24} />
            </div>
            <div>
              <span className="text-sm text-gray-500 font-medium block">Average Marks</span>
              <span className="text-2xl font-bold text-gray-800">
                {stats.avgMarks} <span className="text-sm text-gray-400 font-normal">/ {stats.totalPossibleMarks}</span>
              </span>
            </div>
          </div>

          <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100 flex items-center gap-4">
            <div className="p-3.5 bg-orange-50 text-orange-600 rounded-lg">
              <FaBookOpen size={24} />
            </div>
            <div>
              <span className="text-sm text-gray-500 font-medium block">Total Requirements</span>
              <span className="text-2xl font-bold text-gray-800">{activeSemester === '5' ? 22 : 35}</span>
            </div>
          </div>
        </div>

        {/* Directory List Table */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden mb-8">
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead className="bg-gray-50 text-gray-600 uppercase text-xs font-semibold">
                <tr>
                  <th className="px-6 py-4 w-12 text-center">
                    <input
                      type="checkbox"
                      checked={filteredStudents.length > 0 && selectedStudentIds.length === filteredStudents.length}
                      onChange={handleSelectAll}
                      className="h-4.5 w-4.5 rounded border-gray-300 text-primary focus:ring-primary cursor-pointer accent-[#000080]"
                    />
                  </th>
                  <th className="px-6 py-4">Student ID (Roll No)</th>
                  <th className="px-6 py-4">Student Name</th>
                  <th className="px-6 py-4">Course Code / Class</th>
                  <th className="px-6 py-4 text-center">Approved Submissions</th>
                  <th className="px-6 py-4 text-center">Cumulative Marks</th>
                  <th className="px-6 py-4 text-center">Completion Status</th>
                  <th className="px-6 py-4 text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 text-sm">
                {filteredStudents.map((student) => {
                  const reqsLength = student.semester === '5' ? 22 : 35;
                  const totalPossible = student.semester === '5' ? 1100 : 1620;
                  const isCompleted = student.approvedCount >= reqsLength;
                  
                  return (
                    <tr key={student.student_id} className="hover:bg-gray-50/50">
                      <td className="px-6 py-4 w-12 text-center">
                        <input
                          type="checkbox"
                          checked={selectedStudentIds.includes(student.student_id)}
                          onChange={() => handleToggleSelect(student.student_id)}
                          className="h-4.5 w-4.5 rounded border-gray-300 text-primary focus:ring-primary cursor-pointer accent-[#000080]"
                        />
                      </td>
                      <td className="px-6 py-4 font-bold text-primary">{student.student_id}</td>
                      <td className="px-6 py-4 font-semibold text-gray-800">{student.student_name}</td>
                      <td className="px-6 py-4 text-gray-500 text-xs font-medium truncate max-w-[200px]" title={student.courseName}>
                        {student.courseName}
                      </td>
                      <td className="px-6 py-4 text-center font-bold text-gray-700">
                        {student.approvedCount} <span className="text-gray-300 font-normal text-xs">/ {reqsLength}</span>
                      </td>
                      <td className="px-6 py-4 text-center font-extrabold text-gray-800">
                        {student.totalMarks} <span className="text-gray-400 font-normal text-xs">/ {totalPossible}</span>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <span className={`px-2.5 py-1 rounded-full text-xs font-bold leading-none ${
                          isCompleted
                            ? 'bg-green-100 text-green-800 border border-green-200'
                            : 'bg-amber-100 text-amber-800 border border-amber-200'
                        }`}>
                          {isCompleted ? 'COMPLETED' : 'IN PROGRESS'}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-right">
                        <button
                          onClick={() => setSelectedStudent(student)}
                          className="px-3.5 py-1.5 bg-primary text-white text-xs font-bold rounded hover:bg-secondary transition duration-150 shadow-sm"
                        >
                          View Marksheet
                        </button>
                      </td>
                    </tr>
                  );
                })}
                {filteredStudents.length === 0 && (
                  <tr>
                    <td colSpan="8" className="px-6 py-12 text-center text-gray-500">
                      <p className="font-semibold text-base">No student records found</p>
                      <p className="text-sm text-gray-400 mt-1">Try resetting the filters or typing a different search query.</p>
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* High-Fidelity Marksheet Detail Modal */}
      {selectedStudent && (
        <div className="fixed inset-0 z-50 bg-black/60 flex items-center justify-center p-0 md:p-4 overflow-y-auto print:relative print:z-auto print:bg-white print:p-0">
          <div className="bg-white w-full max-w-4xl rounded-none md:rounded-2xl shadow-2xl flex flex-col h-full md:max-h-[90vh] overflow-hidden print:shadow-none print:w-full print:h-auto print:max-h-none print:overflow-visible">
            
            {/* Modal Header (Hidden on printing) */}
            <div className="px-4 py-3 md:px-6 md:py-4 bg-primary text-white flex items-center justify-between gap-2 print:hidden">
              <div className="flex items-center gap-2 min-w-0">
                <FaGraduationCap size={22} className="flex-shrink-0" />
                <h3 className="font-bold text-sm sm:text-base md:text-lg leading-tight truncate">Student Posting Completion Transcript</h3>
              </div>
              <div className="flex items-center gap-1.5 md:gap-3 flex-shrink-0">
                <button
                  onClick={handleDownloadPDF}
                  disabled={isDownloading}
                  className="flex items-center gap-1.5 px-3 py-1.5 md:px-4 md:py-1.5 bg-white text-primary hover:bg-white/95 disabled:opacity-75 disabled:cursor-not-allowed rounded-lg text-xs md:text-sm font-bold shadow-sm transition whitespace-nowrap"
                >
                  {isDownloading ? (
                    <>
                      <FaSpinner className="animate-spin text-[10px] md:text-xs" />
                      <span>Downloading...</span>
                    </>
                  ) : (
                    <>
                      <FaDownload className="text-[10px] md:text-xs" />
                      <span>Download Marksheet PDF</span>
                    </>
                  )}
                </button>
                <button
                  onClick={() => setSelectedStudent(null)}
                  className="p-1.5 hover:bg-white/20 rounded-full transition flex-shrink-0"
                >
                  <FaTimes size={16} />
                </button>
              </div>
            </div>

            {/* Scrollable Document Container */}
            <div className="flex-1 overflow-auto p-4 md:p-8 bg-[#f3f4f6] print:p-0 print:overflow-visible">
              
              {/* printable page layout */}
              <div ref={printPageRef} className="print-page text-black font-sans bg-[#dbe5f1] print:bg-[#dbe5f1] leading-relaxed mx-auto w-[800px] min-w-[800px] border-[8px] border-[#000080] p-8 print:p-8 shadow-md">
                
                {/* School Header with Logo */}
                <div className="flex flex-col items-center mb-6 border-b-4 border-[#000080] pb-4">
                  <div className="flex items-center justify-center gap-4 mb-3 w-full">
                    <img 
                      src="/logo.jpg" 
                      alt="MTIN Logo" 
                      className="h-16 w-16 object-contain rounded-full border border-gray-300 shadow-sm" 
                    />
                    <div className="text-left">
                      <h1 className="text-xl font-extrabold uppercase tracking-wide text-gray-900 leading-tight">
                        Manikaka Topawala Institute of Nursing
                      </h1>
                      <p className="text-xs font-semibold text-gray-600 uppercase tracking-wider mt-0.5">
                        Constituent of CHARUSAT – Community Health Nursing
                      </p>
                    </div>
                  </div>
                  <div className="mt-2 mb-4 inline-block border-2 border-[#000080] px-4 py-1.5 uppercase font-extrabold text-xs tracking-wider bg-white/80">
                    Posting Completion Marksheet ({selectedStudent.semester}th Semester)
                  </div>
                </div>

                {/* Student Info Box with elegant blue tint */}
                <div className="grid grid-cols-2 gap-x-6 gap-y-2 text-sm border-4 border-[#000080] p-4 mb-6 mt-6 bg-white/95 print:bg-white/95 rounded-lg">
                  <div>
                    <span className="font-bold text-[#000080]">Student Name: </span>
                    <span className="font-semibold text-gray-800">{selectedStudent.student_name}</span>
                  </div>
                  <div>
                    <span className="font-bold text-[#000080]">Student ID No: </span>
                    <span className="font-bold text-primary">{selectedStudent.student_id}</span>
                  </div>
                  <div>
                    <span className="font-bold text-[#000080]">Course / Class: </span>
                    <span className="font-medium text-gray-700 truncate block max-w-xs" title={selectedStudent.courseName}>
                      {selectedStudent.courseName}
                    </span>
                  </div>
                  <div>
                    <span className="font-bold text-[#000080]">Posting Progress: </span>
                    <span className="font-bold text-blue-700">
                      {selectedStudent.approvedCount} / {selectedReqs.length} Approved ({Math.round((selectedStudent.approvedCount / selectedReqs.length) * 100)}%)
                    </span>
                  </div>
                  <div className="col-span-2 mt-1 pt-1 border-t border-[#000080]">
                    <span className="font-bold text-[#000080]">Overall Status: </span>
                    <span className={`inline-block px-2.5 py-0.5 rounded font-extrabold text-xs border leading-none ${
                      isSelectedCompleted
                        ? 'bg-green-100 text-green-800 border-green-200'
                        : 'bg-amber-100 text-amber-800 border-amber-200'
                    }`}>
                      {isSelectedCompleted ? 'COMPLETED' : 'POSTING IN PROGRESS'}
                    </span>
                  </div>
                </div>

                {/* High Fidelity Table with Premium Blue Borders */}
                <table className="w-full border-collapse border-4 border-[#000080] text-xs text-left bg-white/95 print:bg-white/95">
                  <thead>
                    <tr className="bg-[#4f81bd] print:bg-[#4f81bd] text-white font-bold">
                      <th className="border-2 border-[#000080] px-3 py-2 text-center w-12 font-bold">Sr. No</th>
                      <th className="border-2 border-[#000080] px-3 py-2 font-bold">Name of Requirement</th>
                      <th className="border-2 border-[#000080] px-3 py-2 text-center w-14 font-bold">Quantity</th>
                      <th className="border-2 border-[#000080] px-3 py-2 text-center w-24 font-bold">Marks Allotted</th>
                      <th className="border-2 border-[#000080] px-3 py-2 text-center w-24 font-bold">Marks Achieved</th>
                      <th className="border-2 border-[#000080] px-3 py-2 text-center w-32 font-bold">Date of Submission</th>
                      <th className="border-2 border-[#000080] px-3 py-2 text-center w-24 print:hidden font-bold">Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {selectedReqs.map((req, idx) => {
                      const achievement = selectedStudent.requirements[req.sr];
                      
                      // Check if this is the start of a new major section
                      const prevReq = idx > 0 ? selectedReqs[idx - 1] : null;
                      const showSectionHeader = !prevReq || prevReq.section !== req.section;
                      const showCategoryHeader = !prevReq || prevReq.category !== req.category;

                      return (
                        <React.Fragment key={req.sr}>
                          {/* Section Divider Heading */}
                          {showSectionHeader && (
                            <tr className="bg-[#dbe5f1] print:bg-[#dbe5f1] font-bold text-[#000080]">
                              <td colSpan={7} className="border-2 border-[#000080] px-3 py-1.5 uppercase font-extrabold tracking-wide">
                                {req.section}
                              </td>
                            </tr>
                          )}

                          {/* Category Heading (subheadings like Orientation, Care plan etc) */}
                          {showCategoryHeader && req.category && (
                            <tr className="bg-[#f2f5f9] print:bg-[#f2f5f9] font-semibold text-[#000080]">
                              <td colSpan={7} className="border-2 border-[#000080] px-3 py-1 italic pl-5">
                                {req.category}
                              </td>
                            </tr>
                          )}

                          {/* Standard Row */}
                          <tr className="hover:bg-[#dbe5f1]/40">
                            <td className="border-2 border-[#000080] px-3 py-2 text-center font-bold text-[#000080]">{req.sr}</td>
                            <td className="border-2 border-[#000080] px-3 py-2 pl-6 font-medium">{req.name}</td>
                            <td className="border-2 border-[#000080] px-3 py-2 text-center">1</td>
                            <td className="border-2 border-[#000080] px-3 py-2 text-center font-bold text-gray-700">{req.max}</td>
                            <td className="border-2 border-[#000080] px-3 py-2 text-center font-extrabold text-sm text-[#000080]">
                              {achievement && achievement.status === 'approved' 
                                ? achievement.marks_obtained 
                                : achievement && achievement.status === 'pending'
                                ? 'Pending Evaluation'
                                : '—'}
                            </td>
                            <td className="border-2 border-[#000080] px-3 py-2 text-center font-medium text-gray-700">
                              {achievement && achievement.status === 'approved' && achievement.evaluated_at
                                ? formatDate(achievement.evaluated_at)
                                : '—'}
                            </td>
                            <td className="border-2 border-[#000080] px-3 py-2 text-center print:hidden">
                              <span className={`px-1.5 py-0.5 rounded-full text-[10px] font-bold ${
                                achievement && achievement.status === 'approved'
                                  ? 'bg-green-50 text-green-700 border border-green-200'
                                  : achievement && achievement.status === 'pending'
                                  ? 'bg-amber-50 text-amber-700 border border-amber-200 animate-pulse'
                                  : 'bg-gray-50 text-gray-400 border border-gray-200'
                              }`}>
                                {achievement ? achievement.status.toUpperCase() : 'NOT SUBMITTED'}
                              </span>
                            </td>
                          </tr>
                        </React.Fragment>
                      );
                    })}

                    {/* Total Sum Row */}
                    <tr className="bg-[#dbe5f1] font-extrabold print:bg-[#dbe5f1] text-sm text-[#000080]">
                      <td colSpan={2} className="border-2 border-[#000080] px-3 py-2.5 text-right uppercase">
                        Total posting requirements
                      </td>
                      <td className="border-2 border-[#000080] px-3 py-2.5 text-center">{selectedReqs.length}</td>
                      <td className="border-2 border-[#000080] px-3 py-2.5 text-center text-[#000080]">{selectedTotalPossible}</td>
                      <td className="border-2 border-[#000080] px-3 py-2.5 text-center text-[#000080] text-base">
                        {selectedStudent.totalMarks}
                      </td>
                      <td className="border-2 border-[#000080] px-3 py-2.5 text-center text-[#000080] font-bold">—</td>
                      <td className="border-2 border-[#000080] px-3 py-2.5 print:hidden"></td>
                    </tr>
                  </tbody>
                </table>

                {/* Signatures & Footer Row */}
                <div className="mt-16 print:mt-24 grid grid-cols-3 gap-6 text-center text-xs font-bold pt-8 border-t-4 border-dashed border-[#000080] signature-section">
                  <div className="flex flex-col items-center">
                    <div className="h-10 border-b border-black w-40 mb-2"></div>
                    <span>Course Coordinator</span>
                  </div>
                  <div className="flex flex-col items-center">
                    <div className="h-10 border-b border-black w-40 mb-2"></div>
                    <span>Head of Department</span>
                  </div>
                  <div className="flex flex-col items-center">
                    <div className="h-10 border-b border-black w-40 mb-2"></div>
                    <span>Principal</span>
                  </div>
                </div>

              </div>

            </div>

          </div>
        </div>
      )}

      {/* Print styles override embedded directly */}
      <style dangerouslySetInnerHTML={{ __html: `
        @media print {
          /* Force all containers to be fully visible and scrollable */
          html, body, #root, main, div, section, article {
            overflow: visible !important;
            height: auto !important;
            min-height: 0 !important;
            max-height: none !important;
            position: static !important;
            margin: 0 !important;
            padding: 0 !important;
          }

          /* Force backgrounds and colors to print accurately */
          * {
            -webkit-print-color-adjust: exact !important;
            print-color-adjust: exact !important;
          }

          /* Hide all screen elements */
          body * {
            visibility: hidden !important;
          }

          /* Only show the print-page container, its parents, and its inner content */
          .print-page, .print-page * {
            visibility: visible !important;
          }

          /* We must ensure the modal containers are set to visibility: visible so the child can be seen */
          .fixed, .fixed *, [role="dialog"], [role="dialog"] * {
            visibility: visible !important;
          }

          /* Position print-page at the absolute top-left of the printable area */
          .print-page {
            visibility: visible !important;
            position: absolute !important;
            left: 0 !important;
            top: 0 !important;
            width: 100% !important;
            margin: 0 !important;
            padding: 20px !important;
            border: none !important;
            background: white !important;
            color: black !important;
          }

          /* Signature spacing for printouts */
          .signature-section {
            margin-top: 80px !important;
            page-break-inside: avoid !important;
          }

          /* Remove page breaks inside table rows */
          tr {
            page-break-inside: avoid !important;
          }
          thead {
            display: table-header-group !important;
          }
          
          /* Remove links, headers, dates that browser puts automatically if possible, or hide print-only text */
          .print\\:hidden {
            display: none !important;
            visibility: hidden !important;
          }
        }
      `}} />

      {/* Hidden Off-Screen Marksheet Renderer for Bulk Downloads */}
      {bulkRenderStudent && (() => {
        const bulkReqs = bulkRenderStudent.semester === '5' ? requirements5th : requirements7th;
        const bulkTotalPossible = bulkRenderStudent.semester === '5' ? 1100 : 1620;
        const isBulkCompleted = bulkRenderStudent.approvedCount >= bulkReqs.length;

        return (
          <div style={{ position: 'absolute', top: '-9999px', left: '-9999px', width: '800px', pointerEvents: 'none' }}>
            <div ref={bulkPrintRef} className="print-page text-black font-sans bg-[#dbe5f1] leading-relaxed w-[800px] min-w-[800px] p-8 border-[8px] border-[#000080]">
              {/* School Header with Logo */}
              <div className="flex flex-col items-center mb-6 border-b-4 border-[#000080] pb-4">
                <div className="flex items-center justify-center gap-4 mb-3 w-full">
                  <img 
                    src="/logo.jpg" 
                    alt="MTIN Logo" 
                    className="h-16 w-16 object-contain rounded-full border border-gray-300 shadow-sm" 
                  />
                  <div className="text-left">
                    <h1 className="text-xl font-extrabold uppercase tracking-wide text-gray-900 leading-tight">
                      Manikaka Topawala Institute of Nursing
                    </h1>
                    <p className="text-xs font-semibold text-gray-600 uppercase tracking-wider mt-0.5">
                      Constituent of CHARUSAT – Community Health Nursing
                    </p>
                  </div>
                </div>
                <div className="mt-2 mb-4 inline-block border-2 border-[#000080] px-4 py-1.5 uppercase font-extrabold text-xs tracking-wider bg-white/80">
                  Posting Completion Marksheet ({bulkRenderStudent.semester}th Semester)
                </div>
              </div>

              {/* Student Info Box */}
              <div className="grid grid-cols-2 gap-x-6 gap-y-2 text-sm border-4 border-[#000080] p-4 mb-6 mt-6 bg-white/95 rounded-lg">
                <div>
                  <span className="font-bold text-[#000080]">Student Name: </span>
                  <span className="font-semibold text-gray-800">{bulkRenderStudent.student_name}</span>
                </div>
                <div>
                  <span className="font-bold text-[#000080]">Student ID No: </span>
                  <span className="font-bold text-primary">{bulkRenderStudent.student_id}</span>
                </div>
                <div className="col-span-2">
                  <span className="font-bold text-[#000080]">Course / Class: </span>
                  <span className="font-medium text-gray-700 inline" title={bulkRenderStudent.courseName}>
                    {bulkRenderStudent.courseName}
                  </span>
                </div>
                <div>
                  <span className="font-bold text-[#000080]">Posting Progress: </span>
                  <span className="font-bold text-blue-700">
                    {bulkRenderStudent.approvedCount} / {bulkReqs.length} Approved ({Math.round((bulkRenderStudent.approvedCount / bulkReqs.length) * 100)}%)
                  </span>
                </div>
                <div>
                  <span className="font-bold text-[#000080]">Overall Status: </span>
                  <span className={`inline-block px-2.5 py-0.5 rounded font-extrabold text-xs border leading-none ${
                    isBulkCompleted
                      ? 'bg-green-100 text-green-800 border-green-200'
                      : 'bg-amber-100 text-amber-800 border-amber-200'
                  }`}>
                    {isBulkCompleted ? 'COMPLETED' : 'POSTING IN PROGRESS'}
                  </span>
                </div>
              </div>

              {/* Academic Transcript Table */}
              <table className="w-full border-collapse border-4 border-[#000080] text-xs text-left bg-white/95">
                <thead>
                  <tr className="bg-[#4f81bd] text-white font-bold">
                    <th className="border-2 border-[#000080] px-3 py-2 text-center w-12 font-bold">Sr. No</th>
                    <th className="border-2 border-[#000080] px-3 py-2 font-bold">Name of Requirement</th>
                    <th className="border-2 border-[#000080] px-3 py-2 text-center w-14 font-bold">Quantity</th>
                    <th className="border-2 border-[#000080] px-3 py-2 text-center w-24 font-bold">Marks Allotted</th>
                    <th className="border-2 border-[#000080] px-3 py-2 text-center w-24 font-bold">Marks Achieved</th>
                    <th className="border-2 border-[#000080] px-3 py-2 text-center w-32 font-bold">Date of Submission</th>
                  </tr>
                </thead>
                <tbody>
                  {bulkReqs.map((req, idx) => {
                    const achievement = bulkRenderStudent.requirements[req.sr];
                    const prevReq = idx > 0 ? bulkReqs[idx - 1] : null;
                    const showSectionHeader = !prevReq || prevReq.section !== req.section;
                    const showCategoryHeader = !prevReq || prevReq.category !== req.category;

                    return (
                      <React.Fragment key={req.sr}>
                        {showSectionHeader && (
                          <tr className="bg-[#dbe5f1] font-bold text-[#000080]">
                            <td colSpan={6} className="border-2 border-[#000080] px-3 py-1.5 uppercase font-extrabold tracking-wide">
                              {req.section}
                            </td>
                          </tr>
                        )}

                        {showCategoryHeader && req.category && (
                          <tr className="bg-[#f2f5f9] font-semibold text-[#000080]">
                            <td colSpan={6} className="border-2 border-[#000080] px-3 py-1 italic pl-5">
                              {req.category}
                            </td>
                          </tr>
                        )}

                        <tr>
                          <td className="border-2 border-[#000080] px-3 py-2 text-center font-bold text-[#000080]">{req.sr}</td>
                          <td className="border-2 border-[#000080] px-3 py-2 pl-6 font-medium">{req.name}</td>
                          <td className="border-2 border-[#000080] px-3 py-2 text-center">1</td>
                          <td className="border-2 border-[#000080] px-3 py-2 text-center font-bold text-gray-700">{req.max}</td>
                          <td className="border-2 border-[#000080] px-3 py-2 text-center font-extrabold text-sm text-[#000080]">
                            {achievement && achievement.status === 'approved' 
                              ? achievement.marks_obtained 
                              : achievement && achievement.status === 'pending'
                              ? 'Pending Evaluation'
                              : '—'}
                          </td>
                          <td className="border-2 border-[#000080] px-3 py-2 text-center font-medium text-gray-700">
                            {achievement && achievement.status === 'approved' && achievement.evaluated_at
                              ? formatDate(achievement.evaluated_at)
                              : '—'}
                          </td>
                        </tr>
                      </React.Fragment>
                    );
                  })}

                  {/* Total Sum Row */}
                  <tr className="bg-[#dbe5f1] font-extrabold text-sm text-[#000080]">
                    <td colSpan={2} className="border-2 border-[#000080] px-3 py-2.5 text-right uppercase">
                      Total posting requirements
                    </td>
                    <td className="border-2 border-[#000080] px-3 py-2.5 text-center">{bulkReqs.length}</td>
                    <td className="border-2 border-[#000080] px-3 py-2.5 text-center text-[#000080]">{bulkTotalPossible}</td>
                    <td className="border-2 border-[#000080] px-3 py-2.5 text-center text-[#000080] text-base">
                      {bulkRenderStudent.totalMarks}
                    </td>
                    <td className="border-2 border-[#000080] px-3 py-2.5 text-center text-[#000080] font-bold">—</td>
                  </tr>
                </tbody>
              </table>

              {/* Signatures & Footer */}
              <div className="mt-16 grid grid-cols-3 gap-6 text-center text-xs font-bold pt-8 border-t-4 border-dashed border-[#000080]">
                <div className="flex flex-col items-center">
                  <div className="h-10 border-b border-black w-40 mb-2"></div>
                  <span>Course Coordinator</span>
                </div>
                <div className="flex flex-col items-center">
                  <div className="h-10 border-b border-black w-40 mb-2"></div>
                  <span>Head of Department</span>
                </div>
                <div className="flex flex-col items-center">
                  <div className="h-10 border-b border-black w-40 mb-2"></div>
                  <span>Principal, MTIN</span>
                </div>
              </div>
            </div>
          </div>
        );
      })()}
    </div>
  );
};

export default StudentAcademicRecords;
