import React, { useState, useMemo } from 'react';
import { useSurveys } from '../hooks/useSurveys';
import { processAnalytics, generateChartConfig } from '../utils/analyticsEngine';
import { LineChart, BarChart, PieChart } from '../components/Charts/ChartWidgets';
import StatCard from '../components/StatCard';
import { FaFilter, FaUsers, FaHeartbeat, FaChartLine, FaLeaf, FaBaby, FaNotesMedical } from 'react-icons/fa';

/**
 * Reusable Table to show Frequency and Percentage
 */
const StatsTable = ({ title, data }) => {
    if (!data || !data.datasets || data.datasets.length === 0) return null;

    const dataset = data.datasets[0];
    const total = dataset.data.reduce((a, b) => a + b, 0);

    return (
        <div className="bg-white p-4 rounded-xl shadow-md flex flex-col h-full">
            <h3 className="text-gray-700 font-semibold mb-4 border-b pb-2">{title}</h3>
            <div className="overflow-y-auto flex-1">
                <table className="w-full text-sm text-center">
                    <thead className="text-xs text-gray-500 bg-gray-50 uppercase">
                        <tr>
                            <th className="py-2 text-left pl-2">Category</th>
                            <th className="py-2">Freq</th>
                            <th className="py-2">%</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                        {data.labels.map((label, i) => {
                            const count = dataset.data[i];
                            const percent = total > 0 ? ((count / total) * 100).toFixed(1) : 0;
                            return (
                                <tr key={i} className="hover:bg-gray-50">
                                    <td className="py-2 text-left pl-2 font-medium text-gray-700">{label}</td>
                                    <td className="py-2 text-gray-600">{count}</td>
                                    <td className="py-2 text-blue-600 font-semibold">{percent}%</td>
                                </tr>
                            );
                        })}
                    </tbody>
                    <tfoot className="border-t font-bold bg-gray-50">
                        <tr>
                            <td className="py-2 text-left pl-2">Total</td>
                            <td className="py-2">{total}</td>
                            <td className="py-2">100%</td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>
    );
};

const Analytics = () => {
    const { surveys, loading, error } = useSurveys();

    // -- State --
    const [activeTab, setActiveTab] = useState('demographics');
    const [filters, setFilters] = useState({
        startDate: '',
        endDate: '',
        areaType: 'All',
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

    const { vitalStats } = chartConfig;

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
                    className={`flex items-center px-4 py-2 rounded-lg font-medium transition ${showFilters ? 'bg-blue-600 text-white' : 'bg-white text-gray-700 hover:bg-gray-50 border'
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
                    { id: 'demographics', icon: <FaUsers />, label: 'Demographics' },
                    { id: 'environmental', icon: <FaLeaf />, label: 'Environmental' },
                    { id: 'vital', icon: <FaBaby />, label: 'Vital Statistics' },
                    { id: 'diagnosis', icon: <FaNotesMedical />, label: 'Community Diagnosis' },
                ].map(tab => (
                    <button
                        key={tab.id}
                        onClick={() => setActiveTab(tab.id)}
                        className={`flex items-center px-6 py-3 border-b-2 font-medium whitespace-nowrap transition ${activeTab === tab.id
                            ? 'border-primary text-blue-600 border-blue-600'
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

                {/* A. Demographics */}
                {activeTab === 'demographics' && (
                    <div className="space-y-8">
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                            {/* Age */}
                            <div className="h-80"><BarChart data={chartConfig.demographics.age} title="Age Distribution" /></div>
                            <div className="h-80"><StatsTable title="Age Data" data={chartConfig.demographics.age} /></div>
                            <div className="h-80"><PieChart data={chartConfig.demographics.gender} title="Gender Distribution" /></div>

                            {/* Gender Table - Optional if Pie is clear, but keeping consistent */}
                            <div className="h-80"><StatsTable title="Gender Data" data={chartConfig.demographics.gender} /></div>

                            {/* Religion */}
                            <div className="h-80"><PieChart data={chartConfig.demographics.religion} title="Religion" /></div>
                            <div className="h-80"><StatsTable title="Religion Data" data={chartConfig.demographics.religion} /></div>

                            {/* Education */}
                            <div className="h-80"><BarChart data={chartConfig.demographics.education} title="Education" /></div>
                            <div className="h-80"><StatsTable title="Education Data" data={chartConfig.demographics.education} /></div>

                            {/* Family & Occupation */}
                            <div className="h-80"><PieChart data={chartConfig.demographics.family} title="Family Type" /></div>
                            <div className="h-80"><StatsTable title="Family Type Data" data={chartConfig.demographics.family} /></div>
                            <div className="h-80"><BarChart data={chartConfig.demographics.occupation} title="Occupation" /></div>
                            <div className="h-80"><StatsTable title="Occupation Data" data={chartConfig.demographics.occupation} /></div>
                        </div>
                    </div>
                )}

                {/* B. Environmental */}
                {activeTab === 'environmental' && (
                    <div className="space-y-8">
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                            <div className="h-80"><PieChart data={chartConfig.environment.house} title="House Type" /></div>
                            <div className="h-80"><StatsTable title="House Type Data" data={chartConfig.environment.house} /></div>

                            <div className="h-80"><PieChart data={chartConfig.environment.drainage} title="Drainage System" /></div>
                            <div className="h-80"><StatsTable title="Drainage Data" data={chartConfig.environment.drainage} /></div>

                            <div className="h-80"><BarChart data={chartConfig.environment.waste} title="Waste Disposal" /></div>
                            <div className="h-80"><StatsTable title="Waste Disposal Data" data={chartConfig.environment.waste} /></div>
                        </div>
                    </div>
                )}

                {/* C. Vital Stats */}
                {activeTab === 'vital' && (
                    <div className="space-y-6">
                        <h3 className="text-xl font-bold text-gray-700">Key Indicators</h3>
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                            <StatCard title="Births (1yr)" value={vitalStats['Births (Last 1yr)']} icon={<FaBaby />} color="bg-green-500" />
                            <StatCard title="Deaths (1yr)" value={vitalStats['Deaths (Last 1yr)']} icon={<FaHeartbeat />} color="bg-gray-500" />
                            <StatCard title="Antenatal Mothers" value={vitalStats['Antenatal Mothers']} icon={<FaHeartbeat />} color="bg-pink-500" />
                            <StatCard title="Eligible Couples" value={vitalStats['Eligible Couples']} icon={<FaUsers />} color="bg-blue-500" />
                            <StatCard title="Under 5 Children" value={vitalStats['Under 5 Children']} icon={<FaBaby />} color="bg-yellow-500" />
                            <StatCard title="Marriages" value={vitalStats['Marriages']} icon={<FaUsers />} color="bg-purple-500" />
                        </div>

                        <h3 className="text-xl font-bold text-gray-700 mt-8">Contraceptives & Family Planning</h3>
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                            <StatCard title="Tubectomy" value={vitalStats['Tubectomy']} icon={<FaNotesMedical />} color="bg-violet-500" />
                            <StatCard title="Vasectomy" value={vitalStats['Vasectomy']} icon={<FaNotesMedical />} color="bg-indigo-500" />
                            <StatCard title="Temp. Contraceptives" value={vitalStats['Temporary Contraceptives']} icon={<FaNotesMedical />} color="bg-teal-500" />
                            <StatCard title="Infertility" value={vitalStats['Infertility']} icon={<FaNotesMedical />} color="bg-red-400" />
                        </div>
                    </div>
                )}

                {/* D. Community Diagnosis */}
                {activeTab === 'diagnosis' && (
                    <div className="space-y-8">
                        {/* Communicable & Non-Communicable */}
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-6">
                            <div className="space-y-4">
                                <div className="h-80"><BarChart data={chartConfig.health.communicable} title="Communicable Diseases" /></div>
                                <div className="h-64"><StatsTable title="Communicable Stats" data={chartConfig.health.communicable} /></div>
                            </div>
                            <div className="space-y-4">
                                <div className="h-80"><BarChart data={chartConfig.health.nonCommunicable} title="Non-Communicable Diseases" /></div>
                                <div className="h-64"><StatsTable title="Non-Communicable Stats" data={chartConfig.health.nonCommunicable} /></div>
                            </div>
                        </div>

                        {/* Symptoms & Others */}
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-6">
                            <div className="space-y-4">
                                <div className="h-80"><BarChart data={chartConfig.health.symptoms} title="Common Symptoms" /></div>
                                <div className="h-64"><StatsTable title="Symptoms Stats" data={chartConfig.health.symptoms} /></div>
                            </div>
                            <div className="space-y-4">
                                <div className="h-80"><BarChart data={chartConfig.health.other} title="Other Illnesses" /></div>
                                <div className="h-64"><StatsTable title="Other Illness Stats" data={chartConfig.health.other} /></div>
                            </div>
                        </div>
                    </div>
                )}

            </div>
        </div>
    );
};

export default Analytics;
