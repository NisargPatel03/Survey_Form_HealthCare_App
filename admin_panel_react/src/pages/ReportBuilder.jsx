import React, { useState, useMemo } from 'react';
import { useSurveys } from '../hooks/useSurveys';
import { FaFilter, FaFilePdf, FaFileExcel, FaUsers } from 'react-icons/fa';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';
import * as XLSX from 'xlsx';

const ReportBuilder = () => {
    const { surveys, loading, error } = useSurveys();

    // Filter States
    const [filters, setFilters] = useState({
        areaName: '',
        incomeClass: '',
        facilityType: '',
        hasDisease: '', // 'Yes', 'No', ''
    });

    // Extract unique options for dropdowns dynamically from the dataset
    const dropdownOptions = useMemo(() => {
        if (!surveys) return { areas: [], incomes: [], facilities: [] };

        const areas = new Set();
        const incomes = new Set();
        const facilities = new Set();

        surveys.forEach(s => {
            const data = s.data || {};
            if (data.areaName) areas.add(data.areaName.trim());
            if (data.socioEconomicClass) incomes.add(data.socioEconomicClass.trim());
            if (data.facilityType) facilities.add(data.facilityType.trim());
        });

        return {
            areas: Array.from(areas).sort(),
            incomes: Array.from(incomes).sort(),
            facilities: Array.from(facilities).sort()
        };
    }, [surveys]);

    // Apply the filters to the survey dataset
    const filteredSurveys = useMemo(() => {
        if (!surveys) return [];

        return surveys.filter(s => {
            const data = s.data || {};

            // 1. Area Filter
            if (filters.areaName && data.areaName?.trim() !== filters.areaName) return false;

            // 2. Income Filter
            if (filters.incomeClass && data.socioEconomicClass?.trim() !== filters.incomeClass) return false;

            // 3. Facility Type Filter
            if (filters.facilityType && data.facilityType?.trim() !== filters.facilityType) return false;

            // 4. Disease Filter
            if (filters.hasDisease) {
                const members = data.familyMembers || [];
                const familyHasDisease = members.some(m => {
                    const status = (m.healthStatus || 'Healthy').toLowerCase();
                    return status !== 'healthy' && status !== 'none';
                });

                if (filters.hasDisease === 'Yes' && !familyHasDisease) return false;
                if (filters.hasDisease === 'No' && familyHasDisease) return false;
            }

            return true;
        });
    }, [surveys, filters]);

    // Handle Input Change
    const handleFilterChange = (e) => {
        const { name, value } = e.target;
        setFilters(prev => ({ ...prev, [name]: value }));
    };

    const resetFilters = () => {
        setFilters({ areaName: '', incomeClass: '', facilityType: '', hasDisease: '' });
    };

    // PDF Export Logic
    const exportPDF = () => {
        // use 'new jsPDF.jsPDF' or similar depending on the module export, but typically 'new jsPDF()' is fine if imported correctly. Let's ensure it's robust.
        // The error "doc.autoTable is not a function" or "jsPDF is not a constructor" usually occurs here.
        // In Vite with this specific library version, we sometimes need to instantiate it like this:
        const doc = new jsPDF({ orientation: 'landscape' });

        doc.setFontSize(18);
        doc.text("Custom Family Report", 14, 20);

        doc.setFontSize(10);
        doc.text(`Generated on: ${new Date().toLocaleDateString()}`, 14, 28);

        // Print active filters
        let filterText = 'Filters Applied: ';
        let activeFilters = [];
        if (filters.areaName) activeFilters.push(`Area: ${filters.areaName}`);
        if (filters.incomeClass) activeFilters.push(`Income: ${filters.incomeClass}`);
        if (filters.facilityType) activeFilters.push(`Facility: ${filters.facilityType}`);
        if (filters.hasDisease) activeFilters.push(`Disease: ${filters.hasDisease}`);

        filterText += activeFilters.length > 0 ? activeFilters.join(' | ') : 'None (All Records)';
        doc.text(filterText, 14, 34);

        const tableColumn = ["Head of Family", "Contact Number", "Facility Type", "Area", "Income Class", "Total Members", "Health Status Note"];
        const tableRows = [];

        filteredSurveys.forEach(survey => {
            const data = survey.data || {};

            // Calculate a quick health summary for the family
            const members = data.familyMembers || [];
            let healthNote = 'Healthy';
            const sickMembers = members.filter(m => {
                const status = (m.healthStatus || 'Healthy').toLowerCase();
                return status !== 'healthy' && status !== 'none';
            });
            if (sickMembers.length > 0) {
                healthNote = sickMembers.map(m => `${m.name} (${m.healthStatus})`).join(', ');
            }

            const rowData = [
                data.headOfFamily || 'Unknown',
                data.contactNumber || 'N/A',
                data.facilityType || 'N/A',
                data.areaName || 'N/A',
                data.socioEconomicClass || 'N/A',
                members.length.toString(),
                healthNote
            ];
            tableRows.push(rowData);
        });

        autoTable(doc, {
            head: [tableColumn],
            body: tableRows,
            startY: 40,
            styles: { fontSize: 8 },
            headStyles: { fillColor: [41, 128, 185] }
        });

        doc.save(`Custom_Report_${new Date().getTime()}.pdf`);
    };

    // Excel Export Logic
    const exportExcel = () => {
        const exportData = filteredSurveys.map(survey => {
            const data = survey.data || {};
            const members = data.familyMembers || [];
            let healthList = '';

            const sickMembers = members.filter(m => {
                const status = (m.healthStatus || 'Healthy').toLowerCase();
                return status !== 'healthy' && status !== 'none';
            });
            if (sickMembers.length > 0) {
                healthList = sickMembers.map(m => `${m.name} - ${m.healthStatus}`).join('; ');
            } else {
                healthList = 'Healthy';
            }

            return {
                'Head of Family': data.headOfFamily,
                'Contact Number': data.contactNumber,
                'Address/House No': data.houseNo,
                'Area': data.areaName,
                'Facility Type': data.facilityType,
                'Income Class': data.socioEconomicClass,
                'Religion': data.religion,
                'Total Members': members.length,
                'Health Status Summary': healthList
            };
        });

        const worksheet = XLSX.utils.json_to_sheet(exportData);
        const workbook = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(workbook, worksheet, "Custom Report");
        XLSX.writeFile(workbook, `Custom_Report_${new Date().getTime()}.xlsx`);
    };

    if (loading) return <div className="p-8 text-center text-gray-500">Loading Report Builder...</div>;
    if (error) return <div className="p-8 text-center text-red-500">Error loading data.</div>;

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h2 className="text-3xl font-bold text-gray-800">Custom Query Builder</h2>
                    <p className="text-gray-500 text-sm">Filter families dynamically and export precise datasets.</p>
                </div>
                {/* Export Buttons */}
                <div className="flex gap-3">
                    <button
                        onClick={exportExcel}
                        disabled={filteredSurveys.length === 0}
                        className="flex items-center gap-2 bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg transition-colors font-medium disabled:opacity-50"
                    >
                        <FaFileExcel />
                        Export Excel
                    </button>
                    <button
                        onClick={exportPDF}
                        disabled={filteredSurveys.length === 0}
                        className="flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg transition-colors font-medium disabled:opacity-50"
                    >
                        <FaFilePdf />
                        Export PDF
                    </button>
                </div>
            </div>

            {/* Filters Area */}
            <div className="bg-white p-6 rounded-xl shadow-md border border-gray-100 flex flex-col gap-4">
                <div className="flex items-center gap-2 text-primary font-bold border-b pb-2">
                    <FaFilter />
                    <h3>Query Parameters</h3>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                    {/* Area Dropdown */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Community Area</label>
                        <select
                            name="areaName"
                            value={filters.areaName}
                            onChange={handleFilterChange}
                            className="w-full border-gray-300 rounded-md shadow-sm focus:ring-primary focus:border-primary p-2 border"
                        >
                            <option value="">All Areas</option>
                            {dropdownOptions.areas.map(a => <option key={a} value={a}>{a}</option>)}
                        </select>
                    </div>

                    {/* Income Dropdown */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Socio-Economic Class</label>
                        <select
                            name="incomeClass"
                            value={filters.incomeClass}
                            onChange={handleFilterChange}
                            className="w-full border-gray-300 rounded-md shadow-sm focus:ring-primary focus:border-primary p-2 border"
                        >
                            <option value="">All Classes</option>
                            {dropdownOptions.incomes.map(i => <option key={i} value={i}>{i}</option>)}
                        </select>
                    </div>

                    {/* Facility Dropdown */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Facility Type</label>
                        <select
                            name="facilityType"
                            value={filters.facilityType}
                            onChange={handleFilterChange}
                            className="w-full border-gray-300 rounded-md shadow-sm focus:ring-primary focus:border-primary p-2 border"
                        >
                            <option value="">All Facilities</option>
                            {dropdownOptions.facilities.map(f => <option key={f} value={f}>{f}</option>)}
                        </select>
                    </div>

                    {/* Disease Toggle */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Illness Reported in Family</label>
                        <select
                            name="hasDisease"
                            value={filters.hasDisease}
                            onChange={handleFilterChange}
                            className="w-full border-gray-300 rounded-md shadow-sm focus:ring-primary focus:border-primary p-2 border"
                        >
                            <option value="">Any</option>
                            <option value="Yes">Yes (Has Disease)</option>
                            <option value="No">No (Healthy Family)</option>
                        </select>
                    </div>
                </div>

                <div className="flex justify-end mt-2">
                    <button
                        onClick={resetFilters}
                        className="text-gray-500 hover:text-gray-800 text-sm font-medium underline"
                    >
                        Clear All Filters
                    </button>
                </div>
            </div>

            {/* Results Counters */}
            <div className="flex items-center gap-3 text-lg font-semibold text-gray-800">
                <FaUsers className="text-secondary" />
                <span>Found {filteredSurveys.length} matching families</span>
            </div>

            {/* Data Table */}
            <div className="bg-white rounded-xl shadow-md border border-gray-100 overflow-hidden">
                <div className="overflow-x-auto max-h-[600px]">
                    <table className="min-w-full text-sm text-left relative">
                        <thead className="bg-primary text-white sticky top-0 z-10">
                            <tr>
                                <th className="p-4 font-semibold">Head of Family</th>
                                <th className="p-4 font-semibold">Contact</th>
                                <th className="p-4 font-semibold">Facility</th>
                                <th className="p-4 font-semibold">Area</th>
                                <th className="p-4 font-semibold">Income Class</th>
                                <th className="p-4 font-semibold">Health Snapshot</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-200">
                            {filteredSurveys.slice(0, 100).map((survey, idx) => {
                                const data = survey.data || {};
                                const members = data.familyMembers || [];
                                const sickMembers = members.filter(m => {
                                    const status = (m.healthStatus || 'Healthy').toLowerCase();
                                    return status !== 'healthy' && status !== 'none';
                                });

                                return (
                                    <tr key={idx} className="hover:bg-blue-50 transition-colors">
                                        <td className="p-4 font-medium text-gray-900">{data.headOfFamily || '-'}</td>
                                        <td className="p-4 text-gray-600">{data.contactNumber || '-'}</td>
                                        <td className="p-4">
                                            <span className="bg-gray-100 text-gray-800 px-2 py-1 rounded text-xs font-semibold">
                                                {data.facilityType || '-'}
                                            </span>
                                        </td>
                                        <td className="p-4 text-gray-600">{data.areaName || '-'}</td>
                                        <td className="p-4">
                                            <span className="bg-green-100 text-green-800 px-2 py-1 rounded text-xs">
                                                {data.socioEconomicClass || '-'}
                                            </span>
                                        </td>
                                        <td className="p-4 max-w-xs truncate text-red-600 text-xs">
                                            {sickMembers.length > 0
                                                ? sickMembers.map(m => <div key={m.name}>• {m.name} ({m.healthStatus})</div>)
                                                : <span className="text-green-600">Healthy</span>
                                            }
                                        </td>
                                    </tr>
                                );
                            })}
                        </tbody>
                    </table>
                    {filteredSurveys.length > 100 && (
                        <div className="p-4 text-center text-gray-500 bg-gray-50 border-t">
                            Showing first 100 rows. Please click Export to see all {filteredSurveys.length} results.
                        </div>
                    )}
                    {filteredSurveys.length === 0 && (
                        <div className="p-8 text-center text-gray-500">
                            No families match these filters.
                        </div>
                    )}
                </div>
            </div>

        </div>
    );
};

export default ReportBuilder;
