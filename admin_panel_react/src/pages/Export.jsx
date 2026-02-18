import React from 'react';
import { useSurveys } from '../hooks/useSurveys';
import { generateMastersheetExcel } from '../utils/MastersheetGenerator';
import { FaFileCsv, FaDownload, FaFileExcel } from 'react-icons/fa';

const Export = () => {
    const { surveys, loading, error } = useSurveys();

    const handleDownloadMastersheet = () => {
        if (!surveys || surveys.length === 0) return;
        generateMastersheetExcel(surveys);
    };

    const handleDownloadCSV = () => {
        if (!surveys || surveys.length === 0) return;

        // Define columns to export
        const headers = [
            'ID', 'Student Name', 'Survey Date', 'Approved',
            'Head of Family', 'Area Name', 'Area Type',
            'Address', 'Contact Number', 'Total Income',
            'Family Members Count', 'House Type'
        ];

        // Map data to rows
        const rows = surveys.map(s => {
            const d = s.data || {};
            return [
                s.id,
                s.student_name,
                new Date(s.created_at).toLocaleDateString(),
                d.isApproved ? 'Yes' : 'No',
                // CSV safe strings (replace commas)
                (d.headOfFamily || '').replace(/,/g, ' '),
                (d.areaName || '').replace(/,/g, ' '),
                (d.areaType || ''),
                (d.houseNo || '').replace(/,/g, ' '),
                (d.contactNumber || ''),
                d.totalIncome || 0,
                (d.familyMembers || []).length,
                (d.houseType || '')
            ].join(',');
        });

        const csvContent = [
            headers.join(','),
            ...rows
        ].join('\n');

        // Create Blob and Download
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.setAttribute('href', url);
        link.setAttribute('download', `survey_export_${new Date().toISOString().split('T')[0]}.csv`);
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    };

    if (loading) return <div className="p-8 text-center text-gray-500">Loading Data for Export...</div>;
    if (error) return <div className="p-8 text-center text-red-500">Error: {error}</div>;

    return (
        <div className="max-w-4xl mx-auto">
            <div className="bg-white rounded-xl shadow-md p-8 text-center">
                <div className="inline-block p-4 bg-green-100 rounded-full mb-4">
                    <FaFileCsv className="text-4xl text-green-600" />
                </div>

                <h2 className="text-3xl font-bold text-gray-800 mb-2">Export Data</h2>
                <p className="text-gray-500 mb-6">
                    Download all {surveys.length} survey records as a CSV file for analysis in Excel or Google Sheets.
                </p>

                <button
                    onClick={handleDownloadCSV}
                    className="inline-flex items-center px-6 py-3 bg-primary hover:bg-secondary text-white font-semibold rounded-lg transition shadow-lg hover:shadow-xl transform hover:-translate-y-1"
                >
                    <FaDownload className="mr-2" />
                    Download Raw CSV
                </button>

                <div className="mt-4">
                    <button
                        onClick={handleDownloadMastersheet}
                        className="inline-flex items-center px-6 py-3 bg-green-600 hover:bg-green-700 text-white font-semibold rounded-lg transition shadow-lg hover:shadow-xl transform hover:-translate-y-1"
                    >
                        <FaDownload className="mr-2" />
                        Download Mastersheet (Aggregate)
                    </button>
                </div>

                <div className="mt-8 text-left bg-gray-50 p-4 rounded-lg border border-gray-200">
                    <h4 className="font-semibold text-gray-700 mb-2">Note:</h4>
                    <p className="text-sm text-gray-600">
                        The exported CSV contains summary fields. For full nested data (like individual family member details), please view them in the Family Directory or request a custom JSON export.
                    </p>
                </div>
            </div>
        </div>
    );
};

export default Export;
