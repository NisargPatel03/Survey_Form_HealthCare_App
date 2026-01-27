import React, { useMemo } from 'react';
import { useSurveys } from '../hooks/useSurveys';
import StatCard from '../components/StatCard';
import { FaUsers, FaCheckCircle, FaClock, FaClipboardList } from 'react-icons/fa';

const Dashboard = () => {
    const { surveys, loading, error } = useSurveys();

    const stats = useMemo(() => {
        if (!surveys) return { total: 0, approved: 0, pending: 0, recent: [] };

        // Note: 'isApproved' logic depends on the JSON structure synced from Flutter
        // Based on previous files, 'isApproved' is a top-level field in the JSON blob
        const total = surveys.length;
        const approved = surveys.filter(s => s.data?.isApproved === true).length;
        const pending = total - approved;

        // Get recent 5
        const recent = [...surveys]
            .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
            .slice(0, 5);

        return { total, approved, pending, recent };
    }, [surveys]);

    if (loading) return <div className="p-8 text-center text-gray-500">Loading Dashboard...</div>;
    if (error) return <div className="p-8 text-center text-red-500">Error: {error}</div>;

    return (
        <div>
            <h2 className="text-3xl font-bold text-gray-800 mb-6">Dashboard Overview</h2>

            {/* Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <StatCard
                    title="Total Surveys"
                    value={stats.total}
                    icon={<FaClipboardList />}
                    color="bg-blue-500"
                />
                <StatCard
                    title="Approved Surveys"
                    value={stats.approved}
                    icon={<FaCheckCircle />}
                    color="bg-green-500"
                />
                <StatCard
                    title="Pending Approval"
                    value={stats.pending}
                    icon={<FaClock />}
                    color="bg-orange-500"
                />
                <StatCard
                    title="Total Families"
                    value={stats.total}
                    icon={<FaUsers />}
                    color="bg-purple-500"
                    subtext="Same as surveys for now"
                />
            </div>

            {/* Recent Activity */}
            <div className="bg-white rounded-xl shadow-md overflow-hidden">
                <div className="px-6 py-4 border-b border-gray-100">
                    <h3 className="text-lg font-semibold text-gray-800">Recent Submissions</h3>
                </div>
                <div className="overflow-x-auto">
                    <table className="w-full text-left">
                        <thead className="bg-gray-50 text-gray-600 uppercase text-xs">
                            <tr>
                                <th className="px-6 py-3">Head of Family</th>
                                <th className="px-6 py-3">Area</th>
                                <th className="px-6 py-3">Student Name</th>
                                <th className="px-6 py-3">Date</th>
                                <th className="px-6 py-3">Status</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {stats.recent.map((survey) => (
                                <tr key={survey.id} className="hover:bg-gray-50">
                                    <td className="px-6 py-4 font-medium text-gray-900">
                                        {survey.data?.headOfFamily || 'Unknown'}
                                    </td>
                                    <td className="px-6 py-4 text-gray-600">
                                        {survey.data?.areaName || 'N/A'}
                                    </td>
                                    <td className="px-6 py-4 text-gray-600">
                                        {survey.student_name || 'Unknown'}
                                    </td>
                                    <td className="px-6 py-4 text-gray-500 text-sm">
                                        {new Date(survey.created_at).toLocaleDateString()}
                                    </td>
                                    <td className="px-6 py-4">
                                        <span className={`px-2 py-1 rounded-full text-xs font-semibold ${survey.data?.isApproved
                                                ? 'bg-green-100 text-green-800'
                                                : 'bg-orange-100 text-orange-800'
                                            }`}>
                                            {survey.data?.isApproved ? 'Approved' : 'Pending'}
                                        </span>
                                    </td>
                                </tr>
                            ))}
                            {stats.recent.length === 0 && (
                                <tr>
                                    <td colSpan="5" className="px-6 py-8 text-center text-gray-500">
                                        No recent activity found.
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
};

export default Dashboard;
