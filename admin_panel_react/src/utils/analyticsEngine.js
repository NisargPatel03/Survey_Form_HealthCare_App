export const processAnalytics = (surveys) => {
    if (!surveys || surveys.length === 0) return null;

    // --- Initial Aggregators ---
    const genderCount = { Male: 0, Female: 0, Other: 0 };
    const ageGroups = { '0-5': 0, '6-18': 0, '19-35': 0, '36-60': 0, '60+': 0 };
    const housingTypes = {};
    const incomeLevels = { '< 5k': 0, '5k-10k': 0, '10k-20k': 0, '> 20k': 0 };
    const diseaseCounts = {}; // Combined communicable & non-communicable
    const healthServiceByGender = { Male: { Yes: 0, No: 0 }, Female: { Yes: 0, No: 0 } };

    // Trend Aggregators
    const surveysByMonth = {};
    const diseaseTrend = {}; // { 'YYYY-MM': { DiseaseA: 5, DiseaseB: 3 } }

    // New stats
    let totalMembers = 0;
    let totalChildren = 0; // 0-14
    let totalElderly = 0; // 65+
    let totalWorkingAge = 0; // 15-64
    let membersWithIllness = 0;

    surveys.forEach(survey => {
        const data = survey.data || {};
        const date = new Date(survey.created_at);
        const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;

        // Survey Trend
        surveysByMonth[monthKey] = (surveysByMonth[monthKey] || 0) + 1;

        // Housing
        const hType = data.houseType || 'Unknown';
        if (hType) housingTypes[hType] = (housingTypes[hType] || 0) + 1;

        // Income
        const income = data.totalIncome || 0;
        if (income < 5000) incomeLevels['< 5k']++;
        else if (income < 10000) incomeLevels['5k-10k']++;
        else if (income < 20000) incomeLevels['10k-20k']++;
        else incomeLevels['> 20k']++;

        // Family Members Analysis
        if (data.familyMembers && Array.isArray(data.familyMembers)) {
            data.familyMembers.forEach(member => {
                totalMembers++;

                // Gender
                const g = member.gender ? member.gender.trim() : 'Other';
                if (genderCount[g] !== undefined) genderCount[g]++;
                else genderCount['Other']++;

                // Age Groups & Dependency Ratio
                const age = member.age || 0;
                if (age <= 5) ageGroups['0-5']++;
                else if (age <= 18) ageGroups['6-18']++;
                else if (age <= 35) ageGroups['19-35']++;
                else if (age <= 60) ageGroups['36-60']++;
                else ageGroups['60+']++;

                if (age < 15) totalChildren++;
                else if (age >= 65) totalElderly++;
                else totalWorkingAge++;

                // Illness (Crude Check)
                if (member.healthStatus && member.healthStatus.toLowerCase() !== 'healthy') {
                    membersWithIllness++;
                }
            });
        }

        // Disease Aggregation
        const diseases = [
            ...(data.communicableDiseases || []),
            ...(data.nonCommunicableDiseases || [])
        ];

        // Also check explicit cases lists if available in newer format or fallback
        if (data.feverCases?.length) diseaseCounts['Fever'] = (diseaseCounts['Fever'] || 0) + data.feverCases.length;

        diseases.forEach(d => {
            diseaseCounts[d] = (diseaseCounts[d] || 0) + 1;

            // Trend
            if (!diseaseTrend[monthKey]) diseaseTrend[monthKey] = {};
            diseaseTrend[monthKey][d] = (diseaseTrend[monthKey][d] || 0) + 1;
        });

    });

    // --- Calculations ---
    const sexRatio = (genderCount.Female / (genderCount.Male || 1)) * 1000;
    const dependencyRatio = totalWorkingAge > 0 ? ((totalChildren + totalElderly) / totalWorkingAge) * 100 : 0;
    const morbidityRate = totalMembers > 0 ? (membersWithIllness / totalMembers) * 100 : 0;

    return {
        raw: {
            genderCount,
            ageGroups,
            housingTypes,
            incomeLevels,
            diseaseCounts,
            surveysByMonth,
            diseaseTrend
        },
        indicators: {
            totalMembers,
            avgFamilySize: surveys.length > 0 ? (totalMembers / surveys.length).toFixed(1) : 0,
            sexRatio: sexRatio.toFixed(0),
            dependencyRatio: dependencyRatio.toFixed(1),
            morbidityRate: morbidityRate.toFixed(1)
        }
    };
};

export const generateChartConfig = (analytics) => {
    if (!analytics) return null;
    const { raw } = analytics;

    return {
        genderPie: {
            labels: Object.keys(raw.genderCount),
            datasets: [{
                data: Object.values(raw.genderCount),
                backgroundColor: ['#3b82f6', '#ec4899', '#9ca3af'], // Blue, Pink, Gray
            }]
        },
        ageBar: {
            labels: Object.keys(raw.ageGroups),
            datasets: [{
                label: 'Population Count',
                data: Object.values(raw.ageGroups),
                backgroundColor: '#10b981',
            }]
        },
        diseaseBar: {
            labels: Object.keys(raw.diseaseCounts),
            datasets: [{
                label: 'Reported Cases',
                data: Object.values(raw.diseaseCounts),
                backgroundColor: '#ef4444',
            }]
        },
        trendLine: {
            labels: Object.keys(raw.surveysByMonth).sort(),
            datasets: [{
                label: 'Survey Submissions',
                data: Object.keys(raw.surveysByMonth).sort().map(k => raw.surveysByMonth[k]),
                borderColor: '#8b5cf6',
                backgroundColor: 'rgba(139, 92, 246, 0.5)',
                tension: 0.3,
                fill: true,
            }]
        },
        // Advanced: Stacked Disease Trend (Top 3 Diseases) - Logic omitted for brevity, using simple trend
    };
};
