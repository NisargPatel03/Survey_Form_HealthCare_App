import React, { useState, useMemo } from 'react';
import { useAssignments } from '../hooks/useAssignments';
import { useSurveys } from '../hooks/useSurveys';
import StatCard from '../components/StatCard';
import { BarChart, PieChart, LineChart } from '../components/Charts/ChartWidgets';
import { FaClipboardList, FaCheckCircle, FaExclamationCircle, FaUserTie } from 'react-icons/fa';

const SurveyorAnalytics = () => {
    const { assignments, loading: assignmentsLoading, error: assignError } = useAssignments();
    const { surveys, loading: surveysLoading, error: surveyError } = useSurveys();

    // Data Processing
    const analytics = useMemo(() => {
        if (!assignments || !surveys) return null;

        // 1. Overall Stats
        const totalAssignments = assignments.length;
        const totalCompleted = surveys.length;

        // 2. Student Progress & Completion
        const studentStats = {};
        const completedSet = new Set();

        const normalize = (str) => (str || '').trim().toLowerCase();

        // Pass 1: Tag all completed surveys by area and house
        surveys.forEach(s => {
            const data = s.data || {};
            const area = normalize(data.areaName);
            const house = normalize(String(data.houseNo));
            if (area && house) {
                completedSet.add(`${area}_${house}`);
            }
        });

        // Pass 2: Calculate Assignments & Matched Completions
        const matchedCompleted = new Set();
        assignments.forEach(a => {
            const sid = normalize(a.student_id);
            const area = normalize(a.area_name);
            const house = normalize(String(a.house_no));

            if (!sid) return;
            if (!studentStats[sid]) {
                studentStats[sid] = { assigned: 0, completed: 0, originalName: a.student_id };
            }
            studentStats[sid].assigned += 1;

            const key = `${area}_${house}`;
            if (completedSet.has(key)) {
                studentStats[sid].completed += 1;
                matchedCompleted.add(key);
            }
        });

        // Pass 3: Add unmatched surveys as "Unassigned / Direct"
        surveys.forEach(s => {
            const data = s.data || {};
            const area = normalize(data.areaName);
            const house = normalize(String(data.houseNo));
            const key = `${area}_${house}`;

            if (area && house && !matchedCompleted.has(key)) {
                // This survey was done without a recorded assignment
                const sid = normalize(data.studentName) || 'unassigned';
                if (!studentStats[sid]) {
                    studentStats[sid] = { assigned: 0, completed: 0, originalName: data.studentName || 'Unassigned' };
                }
                studentStats[sid].completed += 1;
            }
        });

        const studentRows = Object.entries(studentStats).map(([id, stats]) => {
            const perc = stats.assigned > 0 ? Math.min((stats.completed / stats.assigned) * 100, 100).toFixed(1) : 100;
            return {
                id: stats.originalName,
                assigned: stats.assigned,
                completed: stats.completed,
                percentage: parseFloat(perc)
            };
        }).sort((a, b) => b.assigned - a.assigned); // Sort by most assigned

        // 3. Top Surveyors (Assignments Made)
        const surveyorAssignedMap = {};
        assignments.forEach(a => {
            // Using surveyor_id (UUID). If we have their email, that's better, but for now ID.
            const sId = a.surveyor_id || 'Unknown';
            surveyorAssignedMap[sId] = (surveyorAssignedMap[sId] || 0) + 1;
        });

        // 4. Exceptions / Reasons
        const exceptionsMap = {};
        assignments.forEach(a => {
            if (a.reason && a.reason.trim() !== '') {
                exceptionsMap[a.reason] = (exceptionsMap[a.reason] || 0) + 1;
            }
        });

        // 5. Area Coverage
        const areaAssignedMap = {};
        const areaCompletedMap = {};

        const toTitleCase = (str) => {
            return str.toLowerCase().split(' ').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');
        };

        assignments.forEach(a => {
            const area = a.area_name ? toTitleCase(a.area_name.trim()) : 'Unknown';
            areaAssignedMap[area] = (areaAssignedMap[area] || 0) + 1;
        });
        surveys.forEach(s => {
            const area = s.data?.areaName ? toTitleCase(s.data.areaName.trim()) : 'Unknown';
            areaCompletedMap[area] = (areaCompletedMap[area] || 0) + 1;
        });

        const allAreas = Array.from(new Set([...Object.keys(areaAssignedMap), ...Object.keys(areaCompletedMap)])).sort();

        return {
            totalAssignments,
            totalCompleted,
            studentRows,
            exceptionsMap,
            surveyorAssignedMap,
            areaAssignedMap,
            areaCompletedMap,
            allAreas
        };
    }, [assignments, surveys]);


    if (assignmentsLoading || surveysLoading) {
        return <div className="p-8 text-center text-gray-500">Loading Operations Data...</div>;
    }

    if (assignError || surveyError) {
        return <div className="p-8 text-center text-red-500">Error loading data.</div>;
    }

    if (!analytics) return null;

    // Prepare Chart Data
    const exLabels = Object.keys(analytics.exceptionsMap);
    const exData = Object.values(analytics.exceptionsMap);
    const exceptionChartData = {
        labels: exLabels.length > 0 ? exLabels : ['None'],
        datasets: [{
            label: 'Exceptions',
            data: exData.length > 0 ? exData : [1], // Dummy if empty just to render pie
            backgroundColor: ['#f59e0b', '#ef4444', '#8b5cf6', '#3b82f6', '#10b981'],
        }]
    };

    const areaLabels = analytics.allAreas;
    const areaAssignedData = areaLabels.map(l => analytics.areaAssignedMap[l] || 0);
    const areaCompletedData = areaLabels.map(l => analytics.areaCompletedMap[l] || 0);
    const areaChartData = {
        labels: areaLabels.length > 0 ? areaLabels : ['No Areas Recorded'],
        datasets: [
            {
                label: 'Assigned Houses',
                data: areaAssignedData.length > 0 ? areaAssignedData : [0],
                backgroundColor: '#3b82f6',
            },
            {
                label: 'Completed Surveys',
                data: areaCompletedData.length > 0 ? areaCompletedData : [0],
                backgroundColor: '#10b981',
            }
        ]
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h2 className="text-3xl font-bold text-gray-800">Operations Analytics</h2>
                    <p className="text-gray-500 text-sm">Monitor surveyor activity and student progress.</p>
                </div>
            </div>

            {/* Overview Stats */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <StatCard
                    title="Total Assignments"
                    value={analytics.totalAssignments}
                    icon={<FaClipboardList />}
                    color="bg-blue-500"
                />
                <StatCard
                    title="Total Surveys Completed"
                    value={analytics.totalCompleted}
                    icon={<FaCheckCircle />}
                    color="bg-green-500"
                />
                <StatCard
                    title="Exception Reports"
                    value={Object.keys(analytics.exceptionsMap).length > 0 ? exData.reduce((a, b) => a + b, 0) : 0}
                    icon={<FaExclamationCircle />}
                    color="bg-orange-500"
                />
                <StatCard
                    title="Active Lead Surveyors"
                    value={Object.keys(analytics.surveyorAssignedMap).length}
                    icon={<FaUserTie />}
                    color="bg-purple-500"
                />
            </div>

            {/* Charts Row */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <div className="lg:col-span-2">
                    <BarChart
                        data={areaChartData}
                        title="Area Coverage (Assigned vs Completed)"
                    />
                </div>

                <div>
                    <PieChart data={exceptionChartData} title="Common Exceptions (Reasons)" />
                </div>
            </div>

            {/* Student Progress Table */}
            <div className="bg-white p-6 rounded-xl shadow-md border border-gray-100">
                <h3 className="text-xl font-bold text-gray-800 mb-4">Student Progress Tracker</h3>
                <div className="overflow-x-auto">
                    <table className="min-w-full text-sm text-left">
                        <thead className="bg-gray-50 text-gray-600 font-semibold">
                            <tr>
                                <th className="p-3 border-b border-gray-200">Student ID</th>
                                <th className="p-3 border-b border-gray-200">Houses Assigned</th>
                                <th className="p-3 border-b border-gray-200">Surveys Completed</th>
                                <th className="p-3 border-b border-gray-200">Completion %</th>
                                <th className="p-3 border-b border-gray-200">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            {analytics.studentRows.map((student, idx) => {
                                let statusColor = 'text-green-600 bg-green-50';
                                let statusText = 'Excellent';
                                if (student.percentage < 50) {
                                    statusColor = 'text-red-600 bg-red-50';
                                    statusText = 'Critical Backup';
                                } else if (student.percentage < 80) {
                                    statusColor = 'text-orange-600 bg-orange-50';
                                    statusText = 'In Progress';
                                }

                                return (
                                    <tr key={idx} className="border-b last:border-0 hover:bg-gray-50">
                                        <td className="p-3 font-medium text-gray-800">{student.id.toUpperCase()}</td>
                                        <td className="p-3">{student.assigned}</td>
                                        <td className="p-3">{student.completed}</td>
                                        <td className="p-3">
                                            <div className="flex items-center gap-2">
                                                <div className="w-full bg-gray-200 rounded-full h-2.5 max-w-[100px]">
                                                    <div className={`h-2.5 rounded-full ${student.percentage >= 80 ? 'bg-green-500' : student.percentage >= 50 ? 'bg-orange-500' : 'bg-red-500'}`} style={{ width: `${student.percentage}%` }}></div>
                                                </div>
                                                <span className="font-semibold">{student.percentage}%</span>
                                            </div>
                                        </td>
                                        <td className="p-3">
                                            <span className={`px-2 py-1 rounded text-xs font-semibold ${statusColor}`}>
                                                {statusText}
                                            </span>
                                        </td>
                                    </tr>
                                );
                            })}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Exceptions / Remarks Table */}
            <div className="bg-white p-6 rounded-xl shadow-md border border-gray-100">
                <h3 className="text-xl font-bold text-gray-800 mb-4">Recent Exception Reports</h3>
                <div className="overflow-x-auto">
                    <table className="min-w-full text-sm text-left">
                        <thead className="bg-gray-50 text-gray-600 font-semibold">
                            <tr>
                                <th className="p-3 border-b border-gray-200">Date</th>
                                <th className="p-3 border-b border-gray-200">Student ID</th>
                                <th className="p-3 border-b border-gray-200">House No / Area</th>
                                <th className="p-3 border-b border-gray-200">Reason</th>
                                <th className="p-3 border-b border-gray-200">Remarks</th>
                            </tr>
                        </thead>
                        <tbody>
                            {assignments.filter(a => a.reason || a.remarks).slice(0, 10).map((a, i) => (
                                <tr key={i} className="border-b last:border-0 hover:bg-gray-50">
                                    <td className="p-3">{new Date(a.created_at).toLocaleDateString()}</td>
                                    <td className="p-3 font-medium">{a.student_id ? a.student_id.toUpperCase() : '-'}</td>
                                    <td className="p-3">{a.house_no} - {a.area_name}</td>
                                    <td className="p-3 text-red-600 font-medium">{a.reason || '-'}</td>
                                    <td className="p-3 text-gray-600 italic">{a.remarks || '-'}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    );
};

export default SurveyorAnalytics;
