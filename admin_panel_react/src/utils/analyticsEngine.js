/**
 * Analytics Engine
 * Processes raw survey data into statistical models efficiently.
 */

// Helper to calculate percentage
const calcPercent = (count, total) => {
    if (!total || total === 0) return 0;
    return ((count / total) * 100).toFixed(1);
};

export const processAnalytics = (surveys) => {
    // if (!surveys || surveys.length === 0) return null; // REMOVED: Allow zero-data processing
    const safeSurveys = surveys || [];

    // --- master aggregators ---
    let totalMembers = 0;
    let totalHouseholds = safeSurveys.length;

    // 1. Demographics
    const ageGroups = {
        'Under 5 (< 5)': 0,
        'School (5-12)': 0,
        'Teen (12-19)': 0,
        'Early Adol (19-25)': 0,
        'Mid Adol (25-40)': 0,
        'Late Adol (40-60)': 0,
        'Old Age (> 60)': 0
    };
    const genderCount = { Male: 0, Female: 0, Other: 0 };
    const religionCount = {};
    const educationCount = {
        'Professional/Post Grad': 0,
        'Graduate': 0,
        'Diploma': 0,
        'High Secondary': 0,
        'Secondary': 0,
        'Primary/Literate': 0,
        'Illiterate': 0,
        'Other': 0
    };
    const familyTypeCount = { 'Nuclear': 0, 'Joint': 0, 'Single': 0, 'Other': 0 };
    const occupationCount = {
        'Laborer': 0,
        'Farmer': 0,
        'Own Business': 0,
        'Private Job': 0,
        'Govt Job': 0,
        'Housewife': 0,
        'Unemployed': 0,
        'Other': 0
    };

    // 2. Environmental
    const houseTypeCount = { 'Pucca': 0, 'Semi-Pucca': 0, 'Kutcha': 0, 'Other': 0 };
    const drainageCount = { 'Adequate': 0, 'Inadequate': 0, 'No Drainage': 0, 'Other': 0 };
    const wasteDisposalCount = { 'Composting': 0, 'Burning': 0, 'Burying': 0, 'Dumping': 0, 'Other': 0 };

    // 3. Vital Stats & Others
    const vitalStats = {
        'Tubectomy': 0,
        'Vasectomy': 0,
        'Temporary Contraceptives': 0,
        'Infertility': 0,
        'Births (Last 1yr)': 0,
        'Deaths (Last 1yr)': 0,
        'Antenatal Mothers': 0,
        'Postnatal Mothers': 0,
        'Eligible Couples': 0,
        'Marriages': 0,
        'Under 5 Children': 0,
    };

    // 4. Community Diagnosis - Detailed Split
    const communicableCounts = {
        'Small pox': 0, 'Chicken pox': 0, 'Measles': 0, 'Influenza': 0, 'Rubella': 0,
        'ARI’s & Pneumonia': 0, 'Mumps': 0, 'Diphtheria': 0, 'Whooping cough': 0,
        'Meningococcal meningitis': 0, 'Tuberculosis': 0, 'SARS': 0, 'SARS 2(CORONA VIRUS)': 0,
        'EBOLA virus disease': 0, 'Nipah Virus infection': 0, 'Poliomyelitis': 0, 'Viral Hepatitis': 0,
        'Cholera': 0, 'Diarrheal diseases': 0, 'Typhoid Fever': 0, 'Food poisoning': 0,
        'Hook worm infection': 0, 'Dengue': 0, 'Malaria': 0, 'Filariasis': 0, 'Rabies': 0,
        'Yellow fever': 0, 'Japanese encephalitis': 0, 'Brucellosis': 0, 'Plague': 0,
        'Anthrax': 0, 'Trachoma': 0, 'Tetanus': 0, 'Leprosy': 0, 'STD & RTI': 0,
        'Yaws': 0, 'HIV/AIDS': 0
    };
    const nonCommunicableCounts = {
        'Malnutrition': 0, 'Anemia': 0, 'Hypertension': 0, 'Stroke': 0,
        'Rheumatic Heart Disease': 0, 'Coronary Heart Disease': 0, 'Cancer': 0,
        'Diabetes mellitus': 0, 'Blindness': 0, 'Accidents': 0, 'Mental illness': 0,
        'Obesity': 0, 'Iodine Deficiency': 0, 'Fluorosis': 0, 'Epilepsy': 0
    };
    const symptomCounts = { 'Fever': 0, 'Skin Disease': 0, 'Cough': 0 };
    const otherIllnessCounts = {};

    // Detailed tracking for PDF
    const diseaseDetails = {};

    // Helper to add details
    const trackDetail = (diseaseName, data, surveyDate) => {
        if (!diseaseDetails[diseaseName]) diseaseDetails[diseaseName] = [];
        diseaseDetails[diseaseName].push({
            hof: data.headOfFamily || 'N/A',
            contact: data.contactNumber || 'N/A',
            date: surveyDate ? new Date(surveyDate).toLocaleDateString() : 'N/A'
        });
    };

    // --- Processing Loop ---
    safeSurveys.forEach(survey => {
        const data = survey.data || {};
        const sDate = survey.created_at;

        // -- Household Level Stats --

        // Religion
        const rel = data.religion || 'Unknown';
        religionCount[rel] = (religionCount[rel] || 0) + 1;

        // Family Type
        let fType = (data.familyType || 'Other').trim();
        if (/Nuclear/i.test(fType)) fType = 'Nuclear';
        else if (/Joint/i.test(fType)) fType = 'Joint';
        else if (/Single/i.test(fType)) fType = 'Single';
        else fType = 'Other';
        familyTypeCount[fType]++;

        // House
        let hType = (data.houseType || 'Other').trim();
        if (/Pucca/i.test(hType) && !/Semi/i.test(hType)) hType = 'Pucca';
        else if (/Semi/i.test(hType)) hType = 'Semi-Pucca';
        else if (/Kutcha/i.test(hType)) hType = 'Kutcha';
        else hType = 'Other';
        houseTypeCount[hType]++;

        // Drainage
        let drain = (data.drainage || 'Other').trim();
        if (/Adequate/i.test(drain) && !/Inadequate/i.test(drain)) drain = 'Adequate';
        else if (/Inadequate/i.test(drain)) drain = 'Inadequate';
        else if (/No/i.test(drain)) drain = 'No Drainage';
        else drain = 'Other';
        drainageCount[drain]++;

        // Waste
        const methods = data.wasteDisposalMethods || [];
        if (methods.length > 0) {
            methods.forEach(m => {
                if (/Composting/i.test(m)) wasteDisposalCount['Composting']++;
                else if (/Burning/i.test(m)) wasteDisposalCount['Burning']++;
                else if (/Burying/i.test(m)) wasteDisposalCount['Burying']++;
                else if (/Dumping/i.test(m)) wasteDisposalCount['Dumping']++;
                else wasteDisposalCount['Other']++;
            });
        }

        // Vital Stats
        if (data.intendingTubalLigation) vitalStats['Tubectomy']++;
        if (data.intendingVasectomy) vitalStats['Vasectomy']++;
        if (data.contraceptiveMethod && data.contraceptiveMethod !== 'None') vitalStats['Temporary Contraceptives']++;

        if (data.births) vitalStats['Births (Last 1yr)'] += data.births.length;
        if (data.deaths) vitalStats['Deaths (Last 1yr)'] += data.deaths.length;
        if (data.pregnantWomen) vitalStats['Antenatal Mothers'] += data.pregnantWomen.length;

        if (data.eligibleCouples) vitalStats['Eligible Couples'] += data.eligibleCouples.length;
        if (data.marriages) vitalStats['Marriages'] += data.marriages.length;


        // -- Member Level Stats --
        if (data.familyMembers && Array.isArray(data.familyMembers)) {
            data.familyMembers.forEach(member => {
                totalMembers++;

                // Gender
                const g = (member.gender || 'Other').trim();
                genderCount[g] = (genderCount[g] || 0) + 1;

                // Age Bucket
                const age = parseInt(member.age) || 0;
                if (age < 5) {
                    ageGroups['Under 5 (< 5)']++;
                    vitalStats['Under 5 Children']++;
                }
                else if (age >= 5 && age < 12) ageGroups['School (5-12)']++;
                else if (age >= 12 && age < 19) ageGroups['Teen (12-19)']++;
                else if (age >= 19 && age < 25) ageGroups['Early Adol (19-25)']++;
                else if (age >= 25 && age < 40) ageGroups['Mid Adol (25-40)']++;
                else if (age >= 40 && age <= 60) ageGroups['Late Adol (40-60)']++;
                else ageGroups['Old Age (> 60)']++;

                // Education
                let edu = (member.education || 'Other').toLowerCase();
                if (edu.includes('professional') || edu.includes('post')) educationCount['Professional/Post Grad']++;
                else if (edu.includes('graduate')) educationCount['Graduate']++;
                else if (edu.includes('diploma')) educationCount['Diploma']++;
                else if (edu.includes('higher') || edu.includes('12')) educationCount['High Secondary']++;
                else if (edu.includes('secondary') || edu.includes('10')) educationCount['Secondary']++;
                else if (edu.includes('primary') || edu.includes('literate')) educationCount['Primary/Literate']++;
                else if (edu.includes('illiterate')) educationCount['Illiterate']++;
                else educationCount['Other']++;

                // Occupation
                let occ = (member.occupation || 'Other').toLowerCase();
                if (occ.includes('labor')) occupationCount['Laborer']++;
                else if (occ.includes('farm')) occupationCount['Farmer']++;
                else if (occ.includes('business')) occupationCount['Own Business']++;
                else if (occ.includes('private')) occupationCount['Private Job']++;
                else if (occ.includes('gov')) occupationCount['Govt Job']++;
                else if (occ.includes('housewife')) occupationCount['Housewife']++;
                else if (occ.includes('unemploy') || occ.includes('student')) occupationCount['Unemployed']++;
                else occupationCount['Other']++;
            });
        }

        // -- Diseases Split --

        // 1. Communicable
        const commDiseases = data.communicableDiseases || [];
        commDiseases.forEach(d => {
            communicableCounts[d] = (communicableCounts[d] || 0) + 1;
            trackDetail(d, data, sDate);
        });

        // 2. Non-Communicable
        const nonCommDiseases = data.nonCommunicableDiseases || [];
        nonCommDiseases.forEach(d => {
            nonCommunicableCounts[d] = (nonCommunicableCounts[d] || 0) + 1;
            trackDetail(d, data, sDate);
        });

        // 3. Symptoms (Fever, Skin, Cough)
        if (data.feverCases && data.feverCases.length > 0) {
            symptomCounts['Fever'] += data.feverCases.length;
            trackDetail('Fever', data, sDate);
        }
        if (data.skinDiseases && data.skinDiseases.length > 0) {
            symptomCounts['Skin Disease'] += data.skinDiseases.length;
            trackDetail('Skin Disease', data, sDate);
        }
        if (data.coughCases && data.coughCases.length > 0) {
            symptomCounts['Cough'] += data.coughCases.length;
            trackDetail('Cough', data, sDate);
        }

        // 4. Other Illnesses
        const others = data.otherIllnesses || [];
        others.forEach(d => {
            const name = (typeof d === 'string') ? d : (d.name || d.illness || 'Unknown');
            otherIllnessCounts[name] = (otherIllnessCounts[name] || 0) + 1;
            trackDetail(name, data, sDate);
        });

    });

    return {
        totalTotal: totalHouseholds, // Renamed to avoid confusion
        totalMembers,
        aggr: {
            ageGroups,
            genderCount,
            religionCount,
            educationCount,
            familyTypeCount,
            occupationCount,
            houseTypeCount,
            drainageCount,
            wasteDisposalCount,
            vitalStats,
            // Split Disease Data
            communicableCounts,
            nonCommunicableCounts,
            symptomCounts,
            otherIllnessCounts,
            diseaseDetails
        }
    };
};

/**
 * Generates Chart.js data objects with Freq & Percentage logic
 */
const createChartData = (label, dataset, totalForPercent, colorPalette, detailsMap = null) => {
    const labels = Object.keys(dataset);
    const dataValues = Object.values(dataset);

    return {
        labels,
        datasets: [{
            label: label,
            data: dataValues,
            backgroundColor: colorPalette,
            borderWidth: 1
        }],
        // Pass diseaseDetails map to charts to be used by PDF generator
        details: detailsMap
    };
};

// Standard Palettes
const PALETTE_MULTI = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#6366f1', '#14b8a6'];

export const generateChartConfig = (processedData) => {
    if (!processedData) return null;

    const { aggr } = processedData;

    return {
        demographics: {
            age: createChartData('Population', aggr.ageGroups, processedData.totalMembers, PALETTE_MULTI),
            gender: createChartData('Gender', aggr.genderCount, processedData.totalMembers, ['#3b82f6', '#ec4899', '#9ca3af']),
            religion: createChartData('Religion', aggr.religionCount, processedData.totalHouseholds, PALETTE_MULTI),
            education: createChartData('Education', aggr.educationCount, processedData.totalMembers, PALETTE_MULTI),
            family: createChartData('Family Type', aggr.familyTypeCount, processedData.totalHouseholds, ['#f59e0b', '#8b5cf6', '#10b981', '#9ca3af']),
            occupation: createChartData('Occupation', aggr.occupationCount, processedData.totalMembers, PALETTE_MULTI),
        },
        environment: {
            house: createChartData('House Type', aggr.houseTypeCount, processedData.totalHouseholds, ['#10b981', '#f59e0b', '#ef4444', '#9ca3af']),
            drainage: createChartData('Drainage', aggr.drainageCount, processedData.totalHouseholds, ['#3b82f6', '#ef4444', '#9ca3af', '#64748b']),
            waste: createChartData('Waste Disposal', aggr.wasteDisposalCount, processedData.totalHouseholds, PALETTE_MULTI),
        },
        health: {
            // Split Charts with Disease Details for PDF
            communicable: createChartData('Communicable Cases', aggr.communicableCounts, 0, PALETTE_MULTI, aggr.diseaseDetails),
            nonCommunicable: createChartData('Non-Communicable Cases', aggr.nonCommunicableCounts, 0, PALETTE_MULTI, aggr.diseaseDetails),
            symptoms: createChartData('Symptom Cases', aggr.symptomCounts, 0, ['#ef4444', '#f59e0b', '#8b5cf6'], aggr.diseaseDetails),
            other: createChartData('Other Illnesses', aggr.otherIllnessCounts, 0, PALETTE_MULTI, aggr.diseaseDetails),
        },
        // We pass raw vital stats for card display
        vitalStats: aggr.vitalStats
    };
};
