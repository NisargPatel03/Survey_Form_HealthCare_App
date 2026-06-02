import React, { useState, useEffect } from 'react';
import { supabase } from '../services/supabase';
import { 
    FaMapMarkerAlt, 
    FaCalendarAlt, 
    FaUsers, 
    FaClipboardCheck, 
    FaSpinner, 
    FaCheckCircle, 
    FaExclamationCircle 
} from 'react-icons/fa';

// Prefilled list of official community villages from the Flutter app
const VILLAGES = [
    // PHCs
    { name: 'Changa', type: 'PHC' },
    { name: 'Piplav', type: 'PHC' },
    { name: 'Bandhani', type: 'PHC' },
    { name: 'Morad', type: 'PHC' },
    { name: 'Sihol', type: 'PHC' },
    { name: 'Nar', type: 'PHC' },
    { name: 'Ajarpura', type: 'PHC' },
    { name: 'Navli', type: 'PHC' },
    // CHCs
    { name: 'Sarsa', type: 'CHC' },
    { name: 'Tarapur', type: 'CHC' },
    { name: 'Mahelav', type: 'CHC' },
    // UHCs
    { name: 'Nehrubaugh', type: 'UHC' },
    { name: 'PP Unit Anand', type: 'UHC' },
    { name: 'Bakrol', type: 'UHC' }
];

export default function AssignSurveys() {
    // Filter State
    const [semester, setSemester] = useState('5th Sem');
    const [academicYear, setAcademicYear] = useState('2024-25');
    
    // Assignment State
    const [selectedVillage, setSelectedVillage] = useState(VILLAGES[0].name);
    const [startDate, setStartDate] = useState('');
    const [endDate, setEndDate] = useState('');
    const [capacity, setCapacity] = useState('');
    
    // Data States
    const [students, setStudents] = useState([]);
    const [selectedStudents, setSelectedStudents] = useState({});
    const [loading, setLoading] = useState(false);
    const [submitting, setSubmitting] = useState(false);
    const [successMessage, setSuccessMessage] = useState('');
    const [errorMessage, setErrorMessage] = useState('');

    // Fetch students when filters change
    useEffect(() => {
        fetchStudents();
    }, [semester, academicYear]);

    // Automatically select first N students based on capacity input
    useEffect(() => {
        if (!capacity || isNaN(capacity) || students.length === 0) return;
        const count = Math.min(parseInt(capacity), students.length);
        const selection = {};
        for (let i = 0; i < count; i++) {
            selection[students[i].id] = true;
        }
        setSelectedStudents(selection);
    }, [capacity, students]);

    const fetchStudents = async () => {
        try {
            setLoading(true);
            setErrorMessage('');
            setSuccessMessage('');
            const { data, error } = await supabase
                .from('profiles')
                .select('id, full_name, student_id, semester, academic_year')
                .eq('role', 'student')
                .eq('semester', semester)
                .eq('academic_year', academicYear)
                .order('student_id', { ascending: true });

            if (error) throw error;
            setStudents(data || []);
            setSelectedStudents({});
            setCapacity('');
        } catch (err) {
            console.error('Error fetching students:', err);
            setErrorMessage('Failed to fetch students: ' + err.message);
        } finally {
            setLoading(false);
        }
    };

    const toggleStudentSelection = (id) => {
        setSelectedStudents(prev => ({
            ...prev,
            [id]: !prev[id]
        }));
    };

    const toggleSelectAll = () => {
        const allSelected = students.every(s => selectedStudents[s.id]);
        if (allSelected) {
            setSelectedStudents({});
            setCapacity('');
        } else {
            const selection = {};
            students.forEach(s => {
                selection[s.id] = true;
            });
            setSelectedStudents(selection);
            setCapacity(students.length.toString());
        }
    };

    const handleAssignSubmit = async (e) => {
        e.preventDefault();
        setErrorMessage('');
        setSuccessMessage('');

        const selectedUuids = Object.keys(selectedStudents).filter(id => selectedStudents[id]);
        if (selectedUuids.length === 0) {
            setErrorMessage('Please select at least one student to assign.');
            return;
        }
        if (!startDate || !endDate) {
            setErrorMessage('Please select a valid posting period (start and end dates).');
            return;
        }
        if (new Date(startDate) > new Date(endDate)) {
            setErrorMessage('Start date cannot be after end date.');
            return;
        }

        try {
            setSubmitting(true);
            
            // Get Admin Profile ID from Auth user if available (otherwise fallback null)
            const { data: { user } } = await supabase.auth.getUser();
            const adminId = user ? user.id : null;

            // 1. Prepare student assignments rows
            const selectedStudentsData = students.filter(s => selectedUuids.includes(s.id));
            const assignmentRows = selectedStudentsData.map(s => ({
                student_id: s.student_id,
                semester: semester,
                academic_year: academicYear,
                village_name: selectedVillage,
                posting_start_date: startDate,
                posting_end_date: endDate,
                assigned_by: adminId
            }));

            const { error: assignError } = await supabase
                .from('student_assignments')
                .insert(assignmentRows);

            if (assignError) throw assignError;

            // 2. Prepare notifications for the students
            const formattedStartDate = new Date(startDate).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' });
            const formattedEndDate = new Date(endDate).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' });
            
            const notificationRows = selectedStudentsData.map(s => ({
                student_id: s.student_id,
                title: 'New Survey Assignment',
                message: `You have been assigned to ${selectedVillage} village for your clinical posting from ${formattedStartDate} to ${formattedEndDate}. Please complete the required community survey.`,
                is_read: false
            }));

            const { error: notifError } = await supabase
                .from('notifications')
                .insert(notificationRows);

            if (notifError) throw notifError;

            setSuccessMessage(`Successfully assigned ${selectedUuids.length} students to ${selectedVillage} village from ${formattedStartDate} to ${formattedEndDate}!`);
            
            // Reset fields
            setSelectedStudents({});
            setCapacity('');
            setStartDate('');
            setEndDate('');
        } catch (err) {
            console.error('Error creating assignments:', err);
            setErrorMessage('Failed to create assignments: ' + err.message);
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <div className="max-w-6xl mx-auto space-y-6">
            {/* Header */}
            <div className="border-b pb-4">
                <h2 className="text-3xl font-extrabold text-gray-800 tracking-tight flex items-center gap-2">
                    <FaClipboardCheck className="text-blue-600" /> Assign Surveys to Students
                </h2>
                <p className="text-gray-500 mt-1">Select academic year, semester, posting period, village, and students to assign field duties.</p>
            </div>

            {/* Config & Filters Card */}
            <form onSubmit={handleAssignSubmit} className="space-y-6">
                <div className="bg-white rounded-xl shadow-md border border-gray-100 p-6 space-y-6">
                    <h4 className="font-bold text-lg text-gray-800 border-b pb-2 flex items-center gap-2">
                        <span className="w-2.5 h-2.5 rounded-full bg-blue-500"></span> Posting & Area Configuration
                    </h4>
                    
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                        {/* Semester */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Student Semester</label>
                            <select
                                value={semester}
                                onChange={(e) => setSemester(e.target.value)}
                                className="w-full border border-gray-300 rounded-lg py-2.5 px-3 bg-white text-gray-800 focus:ring-2 focus:ring-blue-500/20 focus:outline-none"
                            >
                                <option value="5th Sem">5th Sem (Nursing - I)</option>
                                <option value="7th Sem">7th Sem (Nursing - II)</option>
                            </select>
                        </div>

                        {/* Academic Year */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Academic Year</label>
                            <input
                                type="text"
                                value={academicYear}
                                onChange={(e) => setAcademicYear(e.target.value)}
                                placeholder="e.g. 2024-25"
                                className="w-full border border-gray-300 rounded-lg py-2.5 px-3 bg-white text-gray-800 focus:ring-2 focus:ring-blue-500/20 focus:outline-none"
                            />
                        </div>

                        {/* Village Dropdown */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2 flex items-center gap-1">
                                <FaMapMarkerAlt className="text-red-500" /> Village Name
                            </label>
                            <select
                                value={selectedVillage}
                                onChange={(e) => setSelectedVillage(e.target.value)}
                                className="w-full border border-gray-300 rounded-lg py-2.5 px-3 bg-white text-gray-800 focus:ring-2 focus:ring-blue-500/20 focus:outline-none"
                            >
                                {VILLAGES.map((v) => (
                                    <option key={v.name} value={v.name}>
                                        {v.name} ({v.type})
                                    </option>
                                ))}
                            </select>
                        </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                        {/* Start Date */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2 flex items-center gap-1.5">
                                <FaCalendarAlt className="text-gray-500" /> Posting Start Date
                            </label>
                            <input
                                type="date"
                                required
                                value={startDate}
                                onChange={(e) => setStartDate(e.target.value)}
                                className="w-full border border-gray-300 rounded-lg py-2.5 px-3 bg-white text-gray-800 focus:ring-2 focus:ring-blue-500/20 focus:outline-none"
                            />
                        </div>

                        {/* End Date */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2 flex items-center gap-1.5">
                                <FaCalendarAlt className="text-gray-500" /> Posting End Date
                            </label>
                            <input
                                type="date"
                                required
                                value={endDate}
                                onChange={(e) => setEndDate(e.target.value)}
                                className="w-full border border-gray-300 rounded-lg py-2.5 px-3 bg-white text-gray-800 focus:ring-2 focus:ring-blue-500/20 focus:outline-none"
                            />
                        </div>

                        {/* Capacity Select */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2 flex items-center gap-1.5">
                                <FaUsers className="text-gray-500" /> Students Capacity
                            </label>
                            <input
                                type="number"
                                min="1"
                                placeholder="Number of students to allot..."
                                value={capacity}
                                onChange={(e) => setCapacity(e.target.value)}
                                className="w-full border border-gray-300 rounded-lg py-2.5 px-3 bg-white text-gray-800 focus:ring-2 focus:ring-blue-500/20 focus:outline-none"
                            />
                        </div>
                    </div>
                </div>

                {successMessage && (
                    <div className="bg-green-50 border-l-4 border-green-500 p-4 rounded-r-lg flex items-start">
                        <FaCheckCircle className="text-green-500 mt-0.5 mr-3 shrink-0" size={18} />
                        <p className="text-sm text-green-700 font-medium">{successMessage}</p>
                    </div>
                )}

                {errorMessage && (
                    <div className="bg-red-50 border-l-4 border-red-500 p-4 rounded-r-lg flex items-start">
                        <FaExclamationCircle className="text-red-500 mt-0.5 mr-3 shrink-0" size={18} />
                        <p className="text-sm text-red-700 font-medium">{errorMessage}</p>
                    </div>
                )}

                {/* Students selection table */}
                <div className="bg-white rounded-xl shadow-md border border-gray-100 overflow-hidden">
                    <div className="px-6 py-4 bg-gray-50 border-b flex flex-col sm:flex-row sm:justify-between sm:items-center gap-4">
                        <div>
                            <h4 className="font-bold text-gray-800">
                                Students in {semester} ({academicYear})
                            </h4>
                            <p className="text-xs text-gray-500 mt-1">
                                Selected: {Object.values(selectedStudents).filter(Boolean).length} / {students.length}
                            </p>
                        </div>
                        
                        <button
                            type="submit"
                            disabled={submitting || Object.values(selectedStudents).filter(Boolean).length === 0}
                            className="bg-blue-600 hover:bg-blue-700 disabled:opacity-50 text-white font-semibold py-2.5 px-8 rounded-lg text-sm shadow-md transition-all flex items-center justify-center cursor-pointer disabled:cursor-not-allowed"
                        >
                            {submitting ? (
                                <>
                                    <FaSpinner className="animate-spin mr-2" /> Assigning Posting...
                                </>
                            ) : (
                                'Assign Posting to Selected Students'
                            )}
                        </button>
                    </div>

                    {loading ? (
                        <div className="py-12 flex flex-col items-center justify-center text-gray-400 space-y-2">
                            <FaSpinner className="animate-spin" size={24} />
                            <span className="text-sm">Loading student database...</span>
                        </div>
                    ) : students.length === 0 ? (
                        <div className="py-12 text-center text-gray-500">
                            <FaUsers className="mx-auto mb-3 text-gray-300" size={36} />
                            <p className="font-medium text-gray-600">No students enrolled in this semester batch yet.</p>
                            <p className="text-xs text-gray-400 mt-1">Onboard students using the Student Enrollment tab first.</p>
                        </div>
                    ) : (
                        <div className="overflow-x-auto max-h-[400px]">
                            <table className="w-full text-left border-collapse">
                                <thead>
                                    <tr className="bg-gray-100/70 border-b border-gray-200 text-xs font-semibold text-gray-500 uppercase tracking-wider">
                                        <th className="py-3 px-4 w-12 text-center">
                                            <input
                                                type="checkbox"
                                                onChange={toggleSelectAll}
                                                checked={students.length > 0 && students.every(s => selectedStudents[s.id])}
                                                className="w-4.5 h-4.5 text-blue-600 border-gray-300 rounded focus:ring-blue-500 focus:outline-none cursor-pointer"
                                            />
                                        </th>
                                        <th className="py-3 px-4">College ID</th>
                                        <th className="py-3 px-4">Student Name</th>
                                        <th className="py-3 px-4">Semester</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-gray-100 text-sm">
                                    {students.map((student) => (
                                        <tr 
                                            key={student.id} 
                                            className={`hover:bg-gray-50/80 cursor-pointer ${selectedStudents[student.id] ? 'bg-blue-50/20' : ''}`}
                                            onClick={() => toggleStudentSelection(student.id)}
                                        >
                                            <td className="py-3 px-4 w-12 text-center" onClick={(e) => e.stopPropagation()}>
                                                <input
                                                    type="checkbox"
                                                    checked={!!selectedStudents[student.id]}
                                                    onChange={() => toggleStudentSelection(student.id)}
                                                    className="w-4.5 h-4.5 text-blue-600 border-gray-300 rounded focus:ring-blue-500 focus:outline-none cursor-pointer"
                                                />
                                            </td>
                                            <td className="py-3 px-4 font-semibold text-gray-800">{student.student_id}</td>
                                            <td className="py-3 px-4 text-gray-700 font-medium">{student.full_name}</td>
                                            <td className="py-3 px-4 text-gray-500">{student.semester}</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    )}
                </div>
            </form>
        </div>
    );
}
