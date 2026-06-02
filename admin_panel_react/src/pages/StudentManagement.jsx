import React, { useState, useEffect } from 'react';
import { supabase } from '../services/supabase';
import * as XLSX from 'xlsx';
import { 
    FaUserPlus, 
    FaUserGraduate, 
    FaFileExcel, 
    FaUpload, 
    FaCheckCircle, 
    FaExclamationCircle, 
    FaSpinner,
    FaArrowRight
} from 'react-icons/fa';

export default function StudentManagement() {
    const [activeTab, setActiveTab] = useState('enroll'); // 'enroll' or 'promote'
    
    // Academic details selection
    const [semester, setSemester] = useState('5th Sem');
    const [academicYear, setAcademicYear] = useState('2024-25');
    
    // Enroll Tab State
    const [excelFile, setExcelFile] = useState(null);
    const [parsedStudents, setParsedStudents] = useState([]);
    const [uploadProgress, setUploadProgress] = useState({ current: 0, total: 0, status: 'idle' });
    const [enrollLogs, setEnrollLogs] = useState([]);
    const [enrollError, setEnrollError] = useState('');
    const [dragOver, setDragOver] = useState(false);

    // Promote Tab State
    const [currentSemesterFilter, setCurrentSemesterFilter] = useState('5th Sem');
    const [currentYearFilter, setCurrentYearFilter] = useState('2024-25');
    const [promoteSemester, setPromoteSemester] = useState('7th Sem');
    const [promoteYear, setPromoteYear] = useState('2025-26');
    const [studentsList, setStudentsList] = useState([]);
    const [selectedStudents, setSelectedStudents] = useState({});
    const [promoteLoading, setPromoteLoading] = useState(false);
    const [promoteSuccess, setPromoteSuccess] = useState('');
    const [promoteError, setPromoteError] = useState('');
    const [loadingStudents, setLoadingStudents] = useState(false);

    // Fetch students for promotion tab when filters change
    useEffect(() => {
        if (activeTab === 'promote') {
            fetchStudentsForPromotion();
        }
    }, [activeTab, currentSemesterFilter, currentYearFilter]);

    const fetchStudentsForPromotion = async () => {
        try {
            setLoadingStudents(true);
            setPromoteError('');
            setPromoteSuccess('');
            const { data, error } = await supabase
                .from('profiles')
                .select('id, full_name, student_id, semester, academic_year, dob, phone')
                .eq('role', 'student')
                .eq('semester', currentSemesterFilter)
                .eq('academic_year', currentYearFilter)
                .order('student_id', { ascending: true });

            if (error) throw error;
            setStudentsList(data || []);
            // Reset selection map
            setSelectedStudents({});
        } catch (err) {
            console.error('Error fetching students:', err);
            setPromoteError('Failed to load students: ' + err.message);
        } finally {
            setLoadingStudents(false);
        }
    };

    // Helper functions for parsing DOB from Excel
    const formatDOB = (dobValue) => {
        if (!dobValue) return '';
        // If it's a number (Excel date serial)
        if (typeof dobValue === 'number') {
            const date = new Date(Math.round((dobValue - 25569) * 86400 * 1000));
            const day = String(date.getDate()).padStart(2, '0');
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const year = date.getFullYear();
            return `${day}${month}${year}`;
        }
        // If it's a string, try parsing it
        const str = String(dobValue).trim();
        // Check if already in DDMMYYYY format
        if (/^\d{8}$/.test(str)) return str;
        
        // Try parsing DD-MM-YYYY, DD/MM/YYYY, etc.
        const parts = str.split(/[-/.]/);
        if (parts.length === 3) {
            let day, month, year;
            if (parts[0].length === 4) {
                // YYYY-MM-DD
                year = parts[0];
                month = parts[1];
                day = parts[2];
            } else {
                // DD-MM-YYYY or MM-DD-YYYY
                day = parts[0];
                month = parts[1];
                year = parts[2];
            }
            day = day.padStart(2, '0');
            month = month.padStart(2, '0');
            if (year.length === 2) year = '20' + year; // YY -> YYYY
            return `${day}${month}${year}`;
        }
        
        // Native JS Date parsing as fallback
        const parsed = new Date(str);
        if (!isNaN(parsed.getTime())) {
            const day = String(parsed.getDate()).padStart(2, '0');
            const month = String(parsed.getMonth() + 1).padStart(2, '0');
            const year = parsed.getFullYear();
            return `${day}${month}${year}`;
        }
        return '';
    };

    const toSQLDate = (dobValue) => {
        const ddmmyyyy = formatDOB(dobValue);
        if (!ddmmyyyy || ddmmyyyy.length !== 8) return null;
        const day = ddmmyyyy.substring(0, 2);
        const month = ddmmyyyy.substring(2, 4);
        const year = ddmmyyyy.substring(4, 8);
        return `${year}-${month}-${day}`;
    };

    // Handle excel file parsing
    const handleFileChange = (e) => {
        const file = e.target.files[0];
        if (!file) return;
        setExcelFile(file);
        parseExcelFile(file);
    };

    const handleDragOver = (e) => {
        e.preventDefault();
        setDragOver(true);
    };

    const handleDragLeave = () => {
        setDragOver(false);
    };

    const handleDrop = (e) => {
        e.preventDefault();
        setDragOver(false);
        const file = e.dataTransfer.files[0];
        if (file) {
            setExcelFile(file);
            parseExcelFile(file);
        }
    };

    const parseExcelFile = (file) => {
        setEnrollError('');
        const reader = new FileReader();
        reader.onload = (e) => {
            try {
                const data = new Uint8Array(e.target.result);
                const workbook = XLSX.read(data, { type: 'array' });
                const firstSheetName = workbook.SheetNames[0];
                const worksheet = workbook.Sheets[firstSheetName];
                const json = XLSX.utils.sheet_to_json(worksheet);

                // Validate headers
                if (json.length === 0) {
                    throw new Error('The uploaded file is empty.');
                }
                const firstRowKeys = Object.keys(json[0]).map(k => k.toLowerCase().replace(/\s/g, ''));
                
                const hasName = firstRowKeys.some(k => k.includes('name'));
                const hasID = firstRowKeys.some(k => k.includes('id') || k.includes('college'));
                const hasPhone = firstRowKeys.some(k => k.includes('phone') || k.includes('mobile'));
                const hasDOB = firstRowKeys.some(k => k.includes('dob') || k.includes('birth') || k.includes('date'));

                if (!hasName || !hasID || !hasDOB) {
                    throw new Error('Excel must contain columns for Name, College ID, and Date of Birth (DOB).');
                }

                // Map rows to normalized object structure
                const students = json.map((row, idx) => {
                    // Find actual keys from row
                    const nameKey = Object.keys(row).find(k => k.toLowerCase().replace(/\s/g, '').includes('name'));
                    const idKey = Object.keys(row).find(k => {
                        const clean = k.toLowerCase().replace(/\s/g, '');
                        return (clean.includes('id') || clean.includes('college')) && !clean.includes('email') && !clean.includes('mail');
                    });
                    const phoneKey = Object.keys(row).find(k => {
                        const clean = k.toLowerCase().replace(/\s/g, '');
                        return clean.includes('phone') || clean.includes('mobile');
                    });
                    const dobKey = Object.keys(row).find(k => {
                        const clean = k.toLowerCase().replace(/\s/g, '');
                        return clean.includes('dob') || clean.includes('birth') || clean.includes('date');
                    });
                    const emailKey = Object.keys(row).find(k => {
                        const clean = k.toLowerCase().replace(/\s/g, '');
                        return clean.includes('email') || clean.includes('mail');
                    });

                    const name = row[nameKey] ? String(row[nameKey]).trim() : '';
                    const id = row[idKey] ? String(row[idKey]).trim().toUpperCase() : '';
                    const phone = row[phoneKey] ? String(row[phoneKey]).trim() : '';
                    const dobRaw = row[dobKey];
                    
                    const dobPassword = formatDOB(dobRaw);
                    const sqlDate = toSQLDate(dobRaw);
                    
                    // Parse email from Excel or fallback to standard structure
                    let email = emailKey && row[emailKey] ? String(row[emailKey]).trim() : '';
                    if (!email && id) {
                        email = `${id.toLowerCase()}@charusat.edu.in`;
                    }

                    let error = '';
                    if (!name) error += 'Missing Name. ';
                    if (!id) error += 'Missing College ID. ';
                    if (!dobPassword) error += 'Invalid DOB format (Expected DD-MM-YYYY or Date). ';
                    if (!email) error += 'Missing Email ID. ';

                    return {
                        index: idx + 1,
                        name,
                        collegeId: id,
                        phone,
                        email,
                        dobRaw,
                        dobPassword,
                        sqlDate,
                        error,
                        status: error ? 'invalid' : 'pending'
                    };
                });

                setParsedStudents(students);
            } catch (err) {
                console.error(err);
                setEnrollError(err.message || 'Failed to parse Excel file.');
                setParsedStudents([]);
            }
        };
        reader.readAsArrayBuffer(file);
    };

    // Bulk enroll students
    const handleEnrollSubmit = async () => {
        const validStudents = parsedStudents.filter(s => s.status !== 'invalid');
        if (validStudents.length === 0) {
            setEnrollError('No valid students to enroll.');
            return;
        }

        setUploadProgress({ current: 0, total: validStudents.length, status: 'running' });
        setEnrollLogs([]);
        setEnrollError('');

        for (let i = 0; i < validStudents.length; i++) {
            const student = validStudents[i];
            
            // Update logs
            setEnrollLogs(prev => [...prev, { studentId: student.collegeId, status: 'loading', message: `Registering account...` }]);
            setUploadProgress(prev => ({ ...prev, current: i + 1 }));

            try {
                // Call public.enroll_student RPC function
                const { data, error } = await supabase.rpc('enroll_student', {
                    p_email: student.email,
                    p_password: student.dobPassword,
                    p_student_id: student.collegeId,
                    p_full_name: student.name,
                    p_phone: student.phone || null,
                    p_dob: student.sqlDate,
                    p_semester: semester,
                    p_academic_year: academicYear
                });

                if (error) throw error;

                // Create a notification for the newly enrolled student
                await supabase.from('notifications').insert({
                    student_id: student.collegeId,
                    title: 'Welcome to Community Health Care Survey',
                    message: `Welcome, ${student.name}! You have been enrolled in ${semester} (${academicYear}). You can login with your College ID and DOB (DDMMYYYY) as password.`,
                    is_read: false
                });

                setEnrollLogs(prev => prev.map(log => 
                    log.studentId === student.collegeId 
                    ? { ...log, status: 'success', message: 'Successfully registered and enrolled!' }
                    : log
                ));
            } catch (err) {
                console.error(`Error enrolling ${student.collegeId}:`, err);
                setEnrollLogs(prev => prev.map(log => 
                    log.studentId === student.collegeId 
                    ? { ...log, status: 'error', message: `Failed: ${err.message}` }
                    : log
                ));
            }
        }

        setUploadProgress(prev => ({ ...prev, status: 'completed' }));
        // Refresh promotion page student list just in case
        fetchStudentsForPromotion();
    };

    // Promote students logic
    const toggleSelectStudent = (id) => {
        setSelectedStudents(prev => ({
            ...prev,
            [id]: !prev[id]
        }));
    };

    const toggleSelectAll = () => {
        const allSelected = studentsList.every(s => selectedStudents[s.id]);
        if (allSelected) {
            setSelectedStudents({});
        } else {
            const selection = {};
            studentsList.forEach(s => {
                selection[s.id] = true;
            });
            setSelectedStudents(selection);
        }
    };

    const handlePromoteSubmit = async () => {
        const selectedUuids = Object.keys(selectedStudents).filter(id => selectedStudents[id]);
        if (selectedUuids.length === 0) {
            setPromoteError('Please select at least one student to promote.');
            return;
        }

        try {
            setPromoteLoading(true);
            setPromoteError('');
            setPromoteSuccess('');

            // 1. Update semester and academic year in profiles
            const { error: updateError } = await supabase
                .from('profiles')
                .update({
                    semester: promoteSemester,
                    academic_year: promoteYear
                })
                .in('id', selectedUuids);

            if (updateError) throw updateError;

            // 2. Generate notifications for each promoted student
            const selectedStudentsData = studentsList.filter(s => selectedUuids.includes(s.id));
            const notificationRows = selectedStudentsData.map(s => ({
                student_id: s.student_id,
                title: 'Academic Promotion',
                message: `Congratulations! You have been promoted to the ${promoteSemester} for the Academic Year ${promoteYear}. Your dashboard has been updated.`,
                is_read: false
            }));

            const { error: notifError } = await supabase
                .from('notifications')
                .insert(notificationRows);

            if (notifError) throw notifError;

            setPromoteSuccess(`Successfully promoted ${selectedUuids.length} students to ${promoteSemester} (${promoteYear})!`);
            // Refresh local student list
            fetchStudentsForPromotion();
        } catch (err) {
            console.error('Error promoting students:', err);
            setPromoteError('Failed to promote students: ' + err.message);
        } finally {
            setPromoteLoading(false);
        }
    };

    return (
        <div className="max-w-6xl mx-auto">
            {/* Header */}
            <div className="mb-6 flex flex-col md:flex-row md:items-center md:justify-between border-b pb-4 gap-4">
                <div>
                    <h2 className="text-3xl font-extrabold text-gray-800 tracking-tight">Student Enrollment & Promotion</h2>
                    <p className="text-gray-500 mt-1">Onboard new student batches via Excel or advance them across academic semesters.</p>
                </div>
                <div className="flex bg-gray-200 p-1 rounded-lg">
                    <button
                        onClick={() => { setActiveTab('enroll'); setPromoteError(''); setPromoteSuccess(''); }}
                        className={`flex items-center px-4 py-2 rounded-md font-medium text-sm transition-all focus:outline-none cursor-pointer ${activeTab === 'enroll' ? 'bg-white text-blue-600 shadow-sm' : 'text-gray-600 hover:text-gray-800'}`}
                    >
                        <FaUserPlus className="mr-2" /> Bulk Enroll
                    </button>
                    <button
                        onClick={() => { setActiveTab('promote'); setEnrollError(''); }}
                        className={`flex items-center px-4 py-2 rounded-md font-medium text-sm transition-all focus:outline-none cursor-pointer ${activeTab === 'promote' ? 'bg-white text-blue-600 shadow-sm' : 'text-gray-600 hover:text-gray-800'}`}
                    >
                        <FaUserGraduate className="mr-2" /> Batch Promotion
                    </button>
                </div>
            </div>

            {/* TAB 1: BULK ENROLL */}
            {activeTab === 'enroll' && (
                <div className="space-y-6">
                    {/* Setup Card */}
                    <div className="bg-white rounded-xl shadow-md p-6 border border-gray-100 grid grid-cols-1 md:grid-cols-3 gap-6 items-end">
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Target Semester</label>
                            <select
                                value={semester}
                                onChange={(e) => setSemester(e.target.value)}
                                className="w-full border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 py-2.5 px-3 bg-white text-gray-800 focus:outline-none"
                            >
                                <option value="5th Sem">5th Sem (Nursing - I)</option>
                                <option value="7th Sem">7th Sem (Nursing - II)</option>
                            </select>
                        </div>
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Academic Year</label>
                            <input
                                type="text"
                                value={academicYear}
                                onChange={(e) => setAcademicYear(e.target.value)}
                                placeholder="e.g. 2024-25"
                                className="w-full border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 py-2.5 px-3 bg-white text-gray-800 focus:outline-none"
                            />
                        </div>
                        <div className="text-sm text-gray-500 leading-normal pb-1">
                            <span className="font-bold text-gray-700">Rules:</span> Students will be registered with email: <span className="font-mono text-xs font-semibold bg-gray-100 px-1 py-0.5 rounded text-blue-600">collegeid@charusat.edu.in</span> and their initial password will be set to their formatted DOB <span className="font-mono text-xs font-semibold bg-gray-100 px-1 py-0.5 rounded text-blue-600">DDMMYYYY</span>.
                        </div>
                    </div>

                    {/* File Dropzone */}
                    <div
                        onDragOver={handleDragOver}
                        onDragLeave={handleDragLeave}
                        onDrop={handleDrop}
                        className={`border-2 border-dashed rounded-xl p-8 text-center transition-all flex flex-col items-center justify-center min-h-[220px] bg-white shadow-sm cursor-pointer hover:border-blue-400 ${dragOver ? 'border-blue-500 bg-blue-50/30' : 'border-gray-300'}`}
                        onClick={() => document.getElementById('excel-file-input').click()}
                    >
                        <input
                            type="file"
                            id="excel-file-input"
                            accept=".xlsx, .xls, .csv"
                            onChange={handleFileChange}
                            className="hidden"
                        />
                        <div className="p-4 bg-blue-50 rounded-full text-blue-500 mb-4 shadow-sm">
                            <FaFileExcel size={36} />
                        </div>
                        <h3 className="font-bold text-lg text-gray-700">Upload Student Excel Sheet</h3>
                        <p className="text-gray-500 text-sm max-w-md mt-2">
                            Drag & drop your Excel file here, or click to browse. Excel must have headers: <span className="font-semibold text-gray-700">Name</span>, <span className="font-semibold text-gray-700">College ID</span>, <span className="font-semibold text-gray-700">DOB</span>, and optional <span className="font-semibold text-gray-700">Phone Number</span>.
                        </p>
                        {excelFile && (
                            <div className="mt-4 px-3 py-1 bg-green-50 text-green-700 rounded-full font-medium text-sm flex items-center border border-green-200">
                                <FaCheckCircle className="mr-2" /> Selected: {excelFile.name}
                            </div>
                        )}
                    </div>

                    {enrollError && (
                        <div className="bg-red-50 border-l-4 border-red-500 p-4 rounded-r-lg flex items-start">
                            <FaExclamationCircle className="text-red-500 mt-0.5 mr-3 shrink-0" size={18} />
                            <p className="text-sm text-red-700 font-medium">{enrollError}</p>
                        </div>
                    )}

                    {/* Parsed List Preview */}
                    {parsedStudents.length > 0 && uploadProgress.status === 'idle' && (
                        <div className="bg-white rounded-xl shadow-md border border-gray-100 overflow-hidden">
                            <div className="px-6 py-4 bg-gray-50 border-b flex justify-between items-center">
                                <h4 className="font-bold text-gray-800">Excel Rows Parsed ({parsedStudents.length} Students)</h4>
                                <button
                                    onClick={handleEnrollSubmit}
                                    className="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-6 rounded-lg text-sm shadow-md transition-all flex items-center cursor-pointer"
                                >
                                    <FaUpload className="mr-2" /> Enroll All {parsedStudents.filter(s => s.status !== 'invalid').length} Students
                                </button>
                            </div>
                            <div className="overflow-x-auto max-h-[350px]">
                                <table className="w-full text-left border-collapse">
                                    <thead>
                                        <tr className="bg-gray-100/70 border-b border-gray-200 text-xs font-semibold text-gray-500 uppercase tracking-wider">
                                            <th className="py-3 px-4">#</th>
                                            <th className="py-3 px-4">College ID</th>
                                            <th className="py-3 px-4">Email ID</th>
                                            <th className="py-3 px-4">Name</th>
                                            <th className="py-3 px-4">Phone</th>
                                            <th className="py-3 px-4">DOB</th>
                                            <th className="py-3 px-4">Generated Password</th>
                                            <th className="py-3 px-4">Status</th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-gray-100 text-sm">
                                        {parsedStudents.map((student) => (
                                            <tr key={student.index} className={student.status === 'invalid' ? 'bg-red-50/40' : 'hover:bg-gray-50'}>
                                                <td className="py-3 px-4 text-gray-400 font-medium">{student.index}</td>
                                                <td className="py-3 px-4 font-semibold text-gray-800">{student.collegeId || <span className="text-red-500">Missing</span>}</td>
                                                <td className="py-3 px-4 text-gray-600 font-mono text-xs">{student.email || <span className="text-red-500">Missing</span>}</td>
                                                <td className="py-3 px-4 text-gray-700">{student.name || <span className="text-red-500">Missing</span>}</td>
                                                <td className="py-3 px-4 text-gray-500">{student.phone || <span className="text-gray-400">N/A</span>}</td>
                                                <td className="py-3 px-4 text-gray-600">{String(student.dobRaw)}</td>
                                                <td className="py-3 px-4"><code className="bg-gray-100 text-xs font-semibold px-2 py-0.5 rounded text-blue-700 font-mono">{student.dobPassword || 'N/A'}</code></td>
                                                <td className="py-3 px-4">
                                                    {student.status === 'invalid' ? (
                                                        <span className="text-red-600 font-medium text-xs flex items-center">
                                                            <FaExclamationCircle className="mr-1" /> {student.error}
                                                        </span>
                                                    ) : (
                                                        <span className="text-green-600 font-medium text-xs flex items-center">
                                                            <FaCheckCircle className="mr-1" /> Ready
                                                        </span>
                                                    )}
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    )}

                    {/* Upload progress & log panel */}
                    {uploadProgress.status !== 'idle' && (
                        <div className="bg-white rounded-xl shadow-md p-6 border border-gray-100 space-y-6">
                            <div className="flex justify-between items-center">
                                <h4 className="font-bold text-gray-800">
                                    {uploadProgress.status === 'running' ? 'Enrolling Batch...' : 'Enrollment Completed'}
                                </h4>
                                <span className="text-sm font-bold text-blue-600">
                                    {uploadProgress.current} / {uploadProgress.total} Registered
                                </span>
                            </div>
                            
                            {/* Progress bar */}
                            <div className="w-full bg-gray-100 rounded-full h-3.5 overflow-hidden">
                                <div 
                                    className="bg-blue-600 h-full transition-all duration-300 rounded-full"
                                    style={{ width: `${(uploadProgress.current / uploadProgress.total) * 100}%` }}
                                ></div>
                            </div>

                            {/* Logs list */}
                            <div className="border border-gray-200 rounded-lg bg-gray-50 p-4 max-h-[250px] overflow-y-auto font-mono text-xs space-y-2">
                                {enrollLogs.map((log, idx) => (
                                    <div key={idx} className="flex justify-between items-center py-1 border-b border-gray-200/50 last:border-0">
                                        <span className="font-semibold text-gray-700">{log.studentId}</span>
                                        <span className="flex items-center gap-1.5">
                                            {log.status === 'loading' && <FaSpinner className="animate-spin text-blue-500" />}
                                            {log.status === 'success' && <FaCheckCircle className="text-green-500" />}
                                            {log.status === 'error' && <FaExclamationCircle className="text-red-500" />}
                                            <span className={log.status === 'error' ? 'text-red-600' : log.status === 'success' ? 'text-green-600' : 'text-gray-500'}>
                                                {log.message}
                                            </span>
                                        </span>
                                    </div>
                                ))}
                            </div>

                            {uploadProgress.status === 'completed' && (
                                <div className="text-center">
                                    <button
                                        onClick={() => {
                                            setExcelFile(null);
                                            setParsedStudents([]);
                                            setUploadProgress({ current: 0, total: 0, status: 'idle' });
                                            setEnrollLogs([]);
                                        }}
                                        className="bg-gray-800 hover:bg-gray-900 text-white font-semibold py-2 px-6 rounded-lg text-sm shadow-md transition-all cursor-pointer"
                                    >
                                        Enroll Another Batch
                                    </button>
                                </div>
                            )}
                        </div>
                    )}
                </div>
            )}

            {/* TAB 2: BATCH PROMOTION */}
            {activeTab === 'promote' && (
                <div className="space-y-6">
                    {/* Setup Card & Target */}
                    <div className="bg-white rounded-xl shadow-md p-6 border border-gray-100 space-y-6">
                        <h4 className="font-bold text-lg text-gray-800 border-b pb-2">Academic Promotion Config</h4>
                        
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-start">
                            {/* Source Filter */}
                            <div className="p-4 bg-gray-50 rounded-lg border border-gray-150 space-y-4">
                                <h5 className="font-semibold text-gray-700 text-sm flex items-center gap-2">
                                    <span className="w-2 h-2 rounded-full bg-blue-500"></span> Find Current Students
                                </h5>
                                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-xs font-semibold text-gray-500 mb-1">Current Semester</label>
                                        <select
                                            value={currentSemesterFilter}
                                            onChange={(e) => setCurrentSemesterFilter(e.target.value)}
                                            className="w-full border border-gray-300 rounded-lg py-2 px-2 bg-white text-xs font-medium text-gray-700 focus:outline-none"
                                        >
                                            <option value="5th Sem">5th Sem (Nursing - I)</option>
                                            <option value="7th Sem">7th Sem (Nursing - II)</option>
                                        </select>
                                    </div>
                                    <div>
                                        <label className="block text-xs font-semibold text-gray-500 mb-1">Academic Year</label>
                                        <input
                                            type="text"
                                            value={currentYearFilter}
                                            onChange={(e) => setCurrentYearFilter(e.target.value)}
                                            placeholder="e.g. 2024-25"
                                            className="w-full border border-gray-300 rounded-lg py-2 px-2 bg-white text-xs font-medium text-gray-700 focus:outline-none"
                                        />
                                    </div>
                                </div>
                            </div>

                            {/* Destination Selection */}
                            <div className="p-4 bg-blue-50/50 rounded-lg border border-blue-100 space-y-4">
                                <h5 className="font-semibold text-blue-800 text-sm flex items-center gap-2">
                                    <span className="w-2 h-2 rounded-full bg-green-500"></span> Promote Target Details
                                </h5>
                                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-xs font-semibold text-blue-700 mb-1">Target Semester</label>
                                        <select
                                            value={promoteSemester}
                                            onChange={(e) => setPromoteSemester(e.target.value)}
                                            className="w-full border border-blue-200 rounded-lg py-2 px-2 bg-white text-xs font-medium text-gray-700 focus:outline-none"
                                        >
                                            <option value="7th Sem">7th Sem (Nursing - II)</option>
                                            <option value="Graduate">Graduate / Finished</option>
                                        </select>
                                    </div>
                                    <div>
                                        <label className="block text-xs font-semibold text-blue-700 mb-1">Target Academic Year</label>
                                        <input
                                            type="text"
                                            value={promoteYear}
                                            onChange={(e) => setPromoteYear(e.target.value)}
                                            placeholder="e.g. 2025-26"
                                            className="w-full border border-blue-200 rounded-lg py-2 px-2 bg-white text-xs font-medium text-gray-700 focus:outline-none"
                                        />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    {promoteSuccess && (
                        <div className="bg-green-50 border-l-4 border-green-500 p-4 rounded-r-lg flex items-start">
                            <FaCheckCircle className="text-green-500 mt-0.5 mr-3 shrink-0" size={18} />
                            <p className="text-sm text-green-700 font-medium">{promoteSuccess}</p>
                        </div>
                    )}

                    {promoteError && (
                        <div className="bg-red-50 border-l-4 border-red-500 p-4 rounded-r-lg flex items-start">
                            <FaExclamationCircle className="text-red-500 mt-0.5 mr-3 shrink-0" size={18} />
                            <p className="text-sm text-red-700 font-medium">{promoteError}</p>
                        </div>
                    )}

                    {/* Students list to promote */}
                    <div className="bg-white rounded-xl shadow-md border border-gray-100 overflow-hidden">
                        <div className="px-6 py-4 bg-gray-50 border-b flex flex-col sm:flex-row sm:justify-between sm:items-center gap-4">
                            <div>
                                <h4 className="font-bold text-gray-800">
                                    Students Found ({studentsList.length})
                                </h4>
                                <p className="text-xs text-gray-500 mt-1">
                                    Selected: {Object.values(selectedStudents).filter(Boolean).length} / {studentsList.length}
                                </p>
                            </div>
                            
                            <button
                                onClick={handlePromoteSubmit}
                                disabled={promoteLoading || Object.values(selectedStudents).filter(Boolean).length === 0}
                                className="bg-blue-600 hover:bg-blue-700 disabled:opacity-50 text-white font-semibold py-2 px-6 rounded-lg text-sm shadow-md transition-all flex items-center justify-center cursor-pointer disabled:cursor-not-allowed"
                            >
                                {promoteLoading ? (
                                    <>
                                        <FaSpinner className="animate-spin mr-2" /> Promoting...
                                    </>
                                ) : (
                                    <>
                                        Promote Selected <FaArrowRight className="ml-2" />
                                    </>
                                )}
                            </button>
                        </div>

                        {loadingStudents ? (
                            <div className="py-12 flex flex-col items-center justify-center text-gray-400 space-y-2">
                                <FaSpinner className="animate-spin" size={24} />
                                <span className="text-sm">Fetching student profiles...</span>
                            </div>
                        ) : studentsList.length === 0 ? (
                            <div className="py-12 text-center text-gray-500">
                                <FaUserGraduate className="mx-auto mb-3 text-gray-300" size={36} />
                                <p className="font-medium text-gray-600">No students found matching current filters.</p>
                                <p className="text-xs text-gray-400 mt-1">Verify current semester and academic year settings.</p>
                            </div>
                        ) : (
                            <div className="overflow-x-auto">
                                <table className="w-full text-left border-collapse">
                                    <thead>
                                        <tr className="bg-gray-100/70 border-b border-gray-200 text-xs font-semibold text-gray-500 uppercase tracking-wider">
                                            <th className="py-3 px-4 w-12 text-center">
                                                <input
                                                    type="checkbox"
                                                    onChange={toggleSelectAll}
                                                    checked={studentsList.length > 0 && studentsList.every(s => selectedStudents[s.id])}
                                                    className="w-4.5 h-4.5 text-blue-600 border-gray-300 rounded focus:ring-blue-500 focus:outline-none cursor-pointer"
                                                />
                                            </th>
                                            <th className="py-3 px-4">College ID</th>
                                            <th className="py-3 px-4">Name</th>
                                            <th className="py-3 px-4">Phone</th>
                                            <th className="py-3 px-4">DOB</th>
                                            <th className="py-3 px-4">Current Academic Semester</th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-gray-100 text-sm">
                                        {studentsList.map((student) => (
                                            <tr 
                                                key={student.id} 
                                                className={`hover:bg-gray-50/80 cursor-pointer ${selectedStudents[student.id] ? 'bg-blue-50/20' : ''}`}
                                                onClick={() => toggleSelectStudent(student.id)}
                                            >
                                                <td className="py-3 px-4 w-12 text-center" onClick={(e) => e.stopPropagation()}>
                                                    <input
                                                        type="checkbox"
                                                        checked={!!selectedStudents[student.id]}
                                                        onChange={() => toggleSelectStudent(student.id)}
                                                        className="w-4.5 h-4.5 text-blue-600 border-gray-300 rounded focus:ring-blue-500 focus:outline-none cursor-pointer"
                                                    />
                                                </td>
                                                <td className="py-3 px-4 font-semibold text-gray-800">{student.student_id}</td>
                                                <td className="py-3 px-4 text-gray-700 font-medium">{student.full_name}</td>
                                                <td className="py-3 px-4 text-gray-500">{student.phone || <span className="text-gray-300">N/A</span>}</td>
                                                <td className="py-3 px-4 text-gray-600">
                                                    {student.dob ? new Date(student.dob).toLocaleDateString('en-GB') : <span className="text-gray-300">N/A</span>}
                                                </td>
                                                <td className="py-3 px-4">
                                                    <span className="px-2.5 py-1 bg-gray-100 text-gray-700 rounded-full font-medium text-xs border border-gray-200">
                                                        {student.semester} ({student.academic_year})
                                                    </span>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        )}
                    </div>
                </div>
            )}
        </div>
    );
}
