import React, { useState } from 'react';
import { useSurveys } from '../hooks/useSurveys';
import { FaSearch, FaEye, FaExclamationTriangle } from 'react-icons/fa';
import SurveyDetailsModal from '../components/SurveyDetailsModal';
import { analyzeQuality } from '../utils/qualityEngine';

const FamilyDirectory = () => {
    const { surveys, loading, error } = useSurveys();
    const [searchTerm, setSearchTerm] = useState('');
    const [selectedSurvey, setSelectedSurvey] = useState(null);

    const filteredSurveys = surveys.filter(survey => {
        const head = survey.data?.headOfFamily?.toLowerCase() || '';
        const area = survey.data?.areaName?.toLowerCase() || '';
        const student = survey.student_name?.toLowerCase() || '';
        const search = searchTerm.toLowerCase();

        return head.includes(search) || area.includes(search) || student.includes(search);
    });

    if (loading) return <div className="p-8 text-center text-gray-500">Loading Directory...</div>;
    if (error) return <div className="p-8 text-center text-red-500">Error: {error}</div>;

    return (
        <div>
            <div className="flex justify-between items-center mb-6">
                <h2 className="text-3xl font-bold text-gray-800">Family Directory</h2>

                {/* Search Bar */}
                <div className="relative">
                    <input
                        type="text"
                        placeholder="Search families..."
                        className="pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary w-64"
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                    />
                    <FaSearch className="absolute left-3 top-3 text-gray-400" />
                </div>
            </div>

            {/* Table */}
            <div className="bg-white rounded-xl shadow-md overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full text-left">
                        <thead className="bg-gray-100 text-gray-700 uppercase text-xs font-semibold">
                            <tr>
                                <th className="px-6 py-4">#</th>
                                <th className="px-6 py-4">Head of Family</th>
                                <th className="px-6 py-4">Members</th>
                                <th className="px-6 py-4">Area</th>
                                <th className="px-6 py-4">Surveyor</th>
                                <th className="px-6 py-4">Quality</th>
                                <th className="px-6 py-4 text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-200">
                            {filteredSurveys.map((survey, index) => (
                                <tr key={survey.id} className="hover:bg-gray-50 transition">
                                    <td className="px-6 py-4 text-gray-500">{index + 1}</td>
                                    <td className="px-6 py-4 font-medium text-gray-900">
                                        {survey.data?.headOfFamily || 'Unknown'}
                                    </td>
                                    <td className="px-6 py-4 text-gray-600">
                                        {survey.data?.familyMembers?.length || 0}
                                    </td>
                                    <td className="px-6 py-4 text-gray-600">
                                        {survey.data?.areaName || 'N/A'}
                                    </td>
                                    <td className="px-6 py-4 text-gray-600">
                                        {survey.student_name || 'Anonymous'}
                                    </td>
                                    <td className="px-6 py-4">
                                        {(() => {
                                            const quality = analyzeQuality(survey);
                                            return (
                                                <span className={`inline-flex items-center px-2 py-1 rounded text-xs font-medium ${quality.bg} ${quality.color}`}>
                                                    {quality.score}% {quality.score < 80 && <FaExclamationTriangle className="ml-1" />}
                                                </span>
                                            );
                                        })()}
                                    </td>
                                    <td className="px-6 py-4 text-center">
                                        <button
                                            onClick={() => setSelectedSurvey(survey)}
                                            className="text-primary hover:text-secondary bg-primary/10 hover:bg-primary/20 p-2 rounded-full transition"
                                            title="View Details"
                                        >
                                            <FaEye />
                                        </button>
                                    </td>
                                </tr>
                            ))}
                            {filteredSurveys.length === 0 && (
                                <tr>
                                    <td colSpan="7" className="px-6 py-12 text-center text-gray-500">
                                        No families found matching specific criteria.
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Detail Modal */}
            {selectedSurvey && (
                <SurveyDetailsModal
                    survey={selectedSurvey}
                    onClose={() => setSelectedSurvey(null)}
                />
            )}
        </div>
    );
};

export default FamilyDirectory;
