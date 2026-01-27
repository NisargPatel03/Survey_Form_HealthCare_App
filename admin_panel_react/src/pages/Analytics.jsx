import React, { useState, useMemo } from 'react';
import { useSurveys } from '../hooks/useSurveys';
import { processAnalytics, generateChartConfig } from '../utils/analyticsEngine';
import { LineChart, BarChart, PieChart } from '../components/Charts/ChartWidgets';
import StatCard from '../components/StatCard';
import { FaFilter, FaUsers, FaHeartbeat, FaChartLine, FaCalendarAlt } from 'react-icons/fa';

const Analytics = () => {
    const { surveys, loading, error } = useSurveys();

    // -- State --
    const [activeTab, setActiveTab] = useState('overview'); // overview, population, health, impact
    const [filters, setFilters] = useState({
        startDate: '',
        endDate: '',
        areaType: 'All', // All, Rural, Urban
    });
    const [showFilters, setShowFilters] = useState(false);

    // -- Filtering Logic --
    const filteredSurveys = useMemo(() => {
        if (!surveys) return [];

        return surveys.filter(s => {
            const data = s.data || {};
            const date = new Date(s.created_at);

            // Date Range
            if (filters.startDate && date < new Date(filters.startDate)) return false;
            if (filters.endDate && date > new Date(filters.endDate)) return false;

            // Area Type
            if (filters.areaType !== 'All') {
                // Normalize: Database might store "Rural", "Urban" or capitalized/lowercase
                const type = (data.areaType || '').toLowerCase();
                if (type !== filters.areaType.toLowerCase()) return false;
            }

            return true;
        });
    }, [surveys, filters]);

    // -- Analytics Processing --
    const analytics = useMemo(() => processAnalytics(filteredSurveys), [filteredSurveys]);
    const chartConfig = useMemo(() => generateChartConfig(analytics), [analytics]);

    // -- Handlers --
    const handleFilterChange = (key, value) => {
        setFilters(prev => ({ ...prev, [key]: value }));
    };

    const clearFilters = () => {
        setFilters({ startDate: '', endDate: '', areaType: 'All' });
    };

    if (loading) return <div className="p-8 text-center text-gray-500">Loading Analytics Engine...</div>;
    if (error) return <div className="p-8 text-center text-red-500">Error: {error}</div>;
    if (!analytics) return <div className="p-8 text-center text-gray-500">No data found matching criteria.</div>;

    return (
        <div className="space-y-6">

            {/* Header & Filter Controls */}
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                <div>
                    <h2 className="text-3xl font-bold text-gray-800">Advanced Analytics</h2>
                    <p className="text-gray-500 text-sm">Real-time intelligence based on {filteredSurveys.length} records</p>
                </div>

                <button
                    onClick={() => setShowFilters(!showFilters)}
                    className={`flex items-center px-4 py-2 rounded-lg font-medium transition ${showFilters ? 'bg-primary text-white' : 'bg-white text-gray-700 hover:bg-gray-50 border'
                        }`}
                >
                    <FaFilter className="mr-2" />
                    {showFilters ? 'Hide Filters' : 'Filter Data'}
                </button>
            </div>

            {/* Filter Bar */}
            {showFilters && (
                <div className="bg-white p-4 rounded-xl shadow-inner border border-gray-200 grid grid-cols-1 md:grid-cols-4 gap-4 animate-fade-in-down">
                    <div>
                        <label className="block text-xs font-semibold text-gray-500 mb-1">Start Date</label>
                        <input
                            type="date"
                            className="w-full border rounded p-2 text-sm"
                            value={filters.startDate}
                            onChange={(e) => handleFilterChange('startDate', e.target.value)}
                        />
                    </div>
                    <div>
                        <label className="block text-xs font-semibold text-gray-500 mb-1">End Date</label>
                        <input
                            type="date"
                            className="w-full border rounded p-2 text-sm"
                            value={filters.endDate}
                            onChange={(e) => handleFilterChange('endDate', e.target.value)}
                        />
                    </div>
                    <div>
                        <label className="block text-xs font-semibold text-gray-500 mb-1">Area Type</label>
                        <select
                            className="w-full border rounded p-2 text-sm"
                            value={filters.areaType}
                            onChange={(e) => handleFilterChange('areaType', e.target.value)}
                        >
                            <option value="All">All Areas</option>
                            <option value="Rural">Rural</option>
                            <option value="Urban">Urban</option>
                        </select>
                    </div>
                    <div className="flex items-end">
                        <button onClick={clearFilters} className="text-sm text-red-500 hover:underline">Clear Filters</button>
                    </div>
                </div>
            )}

            {/* Tabs */}
            <div className="flex border-b border-gray-200 overflow-x-auto">
                {[
                    { id: 'overview', icon: <FaChartLine />, label: 'Overview' },
                    { id: 'population', icon: <FaUsers />, label: 'Population' },
                    { id: 'health', icon: <FaHeartbeat />, label: 'Health Indicators' },
                    { id: 'trends', icon: <FaCalendarAlt />, label: 'Trends' },
                ].map(tab => (
                    <button
                        key={tab.id}
                        onClick={() => setActiveTab(tab.id)}
                        className={`flex items-center px-6 py-3 border-b-2 font-medium whitespace-nowrap transition ${activeTab === tab.id
                                ? 'border-primary text-primary'
                                : 'border-transparent text-gray-500 hover:text-gray-700'
                            }`}
                    >
                        <span className="mr-2">{tab.icon}</span>
                        {tab.label}
                    </button>
                ))}
            </div>

            {/* Content Area */}
            <div className="min-h-[400px]">
                {/* OVERVIEW TAB */}
                {activeTab === 'overview' && (
                    <div className="space-y-6">
                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                            <StatCard title="Avg Family Size" value={analytics.indicators.avgFamilySize} icon={<FaUsers />} color="bg-blue-500" />
                            <StatCard title="Sex Ratio" value={analytics.indicators.sexRatio} subtext="Females / 1000 Males" icon={<FaUsers />} color="bg-pink-500" />
                            <StatCard title="Morbidity Rate" value={`${analytics.indicators.morbidityRate}%`} subtext="Pop. with Illness" icon={<FaHeartbeat />} color="bg-red-500" />
                            <StatCard title="Dependency Ratio" value={`${analytics.indicators.dependencyRatio}%`} icon={<FaUsers />} color="bg-yellow-500" />
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <LineChart data={chartConfig.trendLine} title="Survey Collection Trend" />
                            <PieChart data={chartConfig.genderPie} title="Gender Distribution" />
                        </div>
                    </div>
                )}

                {/* POPULATION TAB */}
                {activeTab === 'population' && (
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <BarChart data={chartConfig.ageBar} title="Age Demographics" />
                        <PieChart data={chartConfig.genderPie} title="Gender Split" />
                    </div>
                )}

                {/* HEALTH TAB */}
                {activeTab === 'health' && (
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div className="md:col-span-2">
                            <BarChart data={chartConfig.diseaseBar} title="Disease Prevalence" />
                        </div>
                    </div>
                )}

                {/* TRENDS TAB */}
                {activeTab === 'trends' && (
                    <div className="grid grid-cols-1 gap-6">
                        <LineChart data={chartConfig.trendLine} title="Survey Submission Velocity" />
                    </div>
                )}

            </div>
        </div>
    );
};

export default Analytics;
