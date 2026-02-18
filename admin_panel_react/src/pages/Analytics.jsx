import React, { useState, useMemo } from 'react';
import { useSurveys } from '../hooks/useSurveys';
import { processAnalytics, generateChartConfig } from '../utils/analyticsEngine';
import { LineChart, BarChart, PieChart } from '../components/Charts/ChartWidgets';
import StatsTable from '../components/StatsTable';
import StatCard from '../components/StatCard';
import { FaFilter, FaUsers, FaLeaf, FaBaby, FaNotesMedical, FaHeartbeat } from 'react-icons/fa';

/**
 * Analytics Dashboard
 * Now features PDF downloads with detailed disease tracking.
 */
const Analytics = () => {
    const { surveys, loading, error } = useSurveys();

    // -- State --
    const [activeTab, setActiveTab] = useState('demographics');
    const [filters, setFilters] = useState({
        startDate: '',
        endDate: '',
        areaType: 'All',
        communityArea: 'All',
        village: 'All',
        year: 'All',
        month: 'All'
    });
    const [showFilters, setShowFilters] = useState(false);

    // -- Constants --
    const FACILITY_MAPPING = {
        'Primary Health Centers (PHCs)': ['Changa', 'Piplav', 'Bandhani', 'Morad', 'Sihol', 'Nar', 'Ajarpura', 'Navli'],
        'Community Health Centers (CHCs)': ['Sarsa', 'Tarapur', 'Mahelav'],
        'Urban Health Centers (UHCs)': ['Nehrubaugh', 'PP Unit Anand', 'Bakrol']
    };

    // -- Derived Filter Options --
    const filterOptions = useMemo(() => {
        // Use static keys for Community Areas to ensure dropdown shows ALL options
        const communityAreas = Object.keys(FACILITY_MAPPING);

        // Village options depend on selected Community Area (Master List)
        let villages = [];
        if (filters.communityArea !== 'All' && FACILITY_MAPPING[filters.communityArea]) {
            villages = FACILITY_MAPPING[filters.communityArea];
        } else {
            // If All Areas selected, show all possible villages from the mapping
            // We can also append any extra villages found in data if they aren't in the mapping (rare case)
            const mappedVillages = Object.values(FACILITY_MAPPING).flat();
            const dataVillages = surveys ? [...new Set(surveys.map(s => s.data?.areaName).filter(Boolean))] : [];
            villages = [...new Set([...mappedVillages, ...dataVillages])].sort();
        }

        const years = surveys ? [...new Set(surveys.map(s => new Date(s.created_at).getFullYear()))].sort((a, b) => b - a) : [];

        return { communityAreas, villages, years };
    }, [surveys, filters.communityArea]);

    // -- Filtering Logic --
    const filteredSurveys = useMemo(() => {
        if (!surveys) return [];

        return surveys.filter(s => {
            const data = s.data || {};
            const date = new Date(s.created_at);
            const year = date.getFullYear();
            const month = date.getMonth() + 1; // 1-12

            // Date Range
            if (filters.startDate && date < new Date(filters.startDate)) return false;
            if (filters.endDate && date > new Date(filters.endDate)) return false;

            // Area Type
            if (filters.areaType !== 'All') {
                const type = (data.areaType || '').toLowerCase();
                if (type !== filters.areaType.toLowerCase()) return false;
            }

            // Community Area (Facility Type)
            if (filters.communityArea !== 'All') {
                const facility = (data.facilityType || '');
                const village = (data.areaName || '');

                // Smart Filter: Match exact facility type OR if missing, match if village belongs to this facility (using Master Mapping)
                const matchesFacility = facility === filters.communityArea;
                const matchesVillageInFacility = FACILITY_MAPPING[filters.communityArea]?.includes(village);

                if (!matchesFacility && !matchesVillageInFacility) return false;
            }

            // Village
            if (filters.village !== 'All') {
                const village = (data.areaName || '').toLowerCase();
                if (village !== filters.village.toLowerCase()) return false;
            }

            // Year
            if (filters.year !== 'All') {
                if (year !== parseInt(filters.year)) return false;
            }

            // Month
            if (filters.month !== 'All') {
                if (month !== parseInt(filters.month)) return false;
            }

            return true;
        });
    }, [surveys, filters]);

    // -- Analytics Processing --
    const analytics = useMemo(() => processAnalytics(filteredSurveys), [filteredSurveys]);
    const chartConfig = useMemo(() => generateChartConfig(analytics), [analytics]);

    // -- Handlers --
    const handleFilterChange = (key, value) => {
        if (key === 'communityArea') {
            // Reset village when community area changes
            setFilters(prev => ({ ...prev, [key]: value, village: 'All' }));
        } else {
            setFilters(prev => ({ ...prev, [key]: value }));
        }
    };

    const clearFilters = () => {
        setFilters({
            startDate: '', endDate: '', areaType: 'All', communityArea: 'All',
            village: 'All', year: 'All', month: 'All'
        });
    };

    if (loading) return <div className="p-8 text-center text-gray-500">Loading Analytics Engine...</div>;
    if (error) return <div className="p-8 text-center text-red-500">Error: {error}</div>;

    // Don't return null here if no data, let the rest render so we can change filters
    // if (!analytics) return <div className="p-8 text-center text-gray-500">No data found matching criteria.</div>;

    const { vitalStats } = chartConfig;

    return (
        <div className="space-y-6">

            {/* Header & Filter Controls */}
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                <div>
                    <h2 className="text-3xl font-bold text-gray-800">Advanced Analytics</h2>
                    <p className="text-gray-500 text-sm">
                        Real-time intelligence based on {filteredSurveys.length} filtered records
                    </p>
                </div>

                <div className="flex gap-2 items-center">
                    <button
                        onClick={() => setShowFilters(!showFilters)}
                        className={`flex items-center px-4 py-2 rounded-lg font-medium transition ${showFilters ? 'bg-blue-600 text-white' : 'bg-white text-gray-700 hover:bg-gray-50 border'
                            }`}
                    >
                        <FaFilter className="mr-2" />
                        {showFilters ? 'Hide Filters' : 'Filter Data'}
                    </button>
                </div>
            </div>

            {/* Filter Bar */}
            {showFilters && (
                <div className="bg-white p-4 rounded-xl shadow-inner border border-gray-200 animate-fade-in-down">
                    <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-4">
                        {/* Row 1: Dates & Area Type */}
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

                        {/* Row 2: Comm. Area, Village, Year, Month */}
                        <div>
                            <label className="block text-xs font-semibold text-gray-500 mb-1">Community Area</label>
                            <select
                                className="w-full border rounded p-2 text-sm"
                                value={filters.communityArea}
                                onChange={(e) => handleFilterChange('communityArea', e.target.value)}
                            >
                                <option value="All">All Community Areas</option>
                                {filterOptions.communityAreas.map(c => (
                                    <option key={c} value={c}>{c}</option>
                                ))}
                            </select>
                        </div>
                        <div>
                            <label className="block text-xs font-semibold text-gray-500 mb-1">Village</label>
                            <select
                                className="w-full border rounded p-2 text-sm"
                                value={filters.village}
                                onChange={(e) => handleFilterChange('village', e.target.value)}
                            >
                                <option value="All">All Villages</option>
                                {filterOptions.villages.map(v => (
                                    <option key={v} value={v}>{v}</option>
                                ))}
                            </select>
                        </div>
                        <div>
                            <label className="block text-xs font-semibold text-gray-500 mb-1">Year</label>
                            <select
                                className="w-full border rounded p-2 text-sm"
                                value={filters.year}
                                onChange={(e) => handleFilterChange('year', e.target.value)}
                            >
                                <option value="All">All Years</option>
                                {filterOptions.years.map(y => (
                                    <option key={y} value={y}>{y}</option>
                                ))}
                            </select>
                        </div>
                        {/* Month Filter moved below or wrapped if needed, logically belongs here */}
                        <div>
                            <label className="block text-xs font-semibold text-gray-500 mb-1">Month</label>
                            <select
                                className="w-full border rounded p-2 text-sm"
                                value={filters.month}
                                onChange={(e) => handleFilterChange('month', e.target.value)}
                            >
                                <option value="All">All Months</option>
                                <option value="1">January</option>
                                <option value="2">February</option>
                                <option value="3">March</option>
                                <option value="4">April</option>
                                <option value="5">May</option>
                                <option value="6">June</option>
                                <option value="7">July</option>
                                <option value="8">August</option>
                                <option value="9">September</option>
                                <option value="10">October</option>
                                <option value="11">November</option>
                                <option value="12">December</option>
                            </select>
                        </div>
                    </div>
                    <div className="flex justify-end mt-4">
                        <button onClick={clearFilters} className="text-sm text-red-500 hover:text-red-700 font-medium hover:underline">
                            Clear All Filters
                        </button>
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
