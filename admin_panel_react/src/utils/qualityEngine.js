export const analyzeQuality = (survey) => {
    const data = survey.data || {};
    const warnings = [];
    let score = 100;

    // Helper to deduct score
    const deduct = (points, message) => {
        score = Math.max(0, score - points);
        warnings.push(message);
    };

    // 1. Critical Missing Fields (High Penalty)
    const criticalFields = ['headOfFamily', 'areaName', 'houseNo', 'totalIncome'];
    criticalFields.forEach(field => {
        if (!data[field]) deduct(15, `Missing Critical Field: ${field}`);
    });

    // 2. Family Member Logic Inconsistencies
    if (data.familyMembers && Array.isArray(data.familyMembers)) {
        data.familyMembers.forEach(member => {
            const age = member.age || 0;
            const gender = (member.gender || '').toLowerCase();
            const occupation = (member.occupation || '').toLowerCase();

            // Age vs Occupation
            if (age < 14 && occupation.includes('full-time')) {
                deduct(10, `Child Labor Risk: ${member.name} (Age ${age}) is working full-time.`);
            }

            // Gender Mismatch (Simple Heuristic for name-based typically hard, but we can check specific fields if they exist)
            // Checking Pregnant Women list against Gender if possible, but PregnantWomen is separate list.
        });
    }

    // 3. Pregnant Women Check
    if (data.pregnantWomen && Array.isArray(data.pregnantWomen)) {
        data.pregnantWomen.forEach(pw => {
            // Check if this person exists in family members and is Female
            const member = data.familyMembers?.find(m => m.name === pw.name);
            if (member) {
                if (member.gender?.toLowerCase() === 'male') {
                    deduct(20, `Data Error: Pregnant Woman '${pw.name}' is listed as Male in family members.`);
                }
                if ((member.age || 0) < 15) {
                    deduct(15, `High Risk: Pregnant Woman '${pw.name}' is under-age (${member.age}).`);
                }
            } else {
                deduct(5, `Inconsistency: Pregnant Woman '${pw.name}' not found in Family Members list.`);
            }
        });
    }

    // 4. Financial Logic
    const totalIncome = data.totalIncome || 0;
    let totalExpenses = 0;
    if (data.expenditureItems && Array.isArray(data.expenditureItems)) {
        totalExpenses = data.expenditureItems.reduce((sum, item) => sum + (item.amount || 0), 0);
    }

    if (totalExpenses > totalIncome * 1.5 && totalIncome > 0) {
        deduct(10, `Financial Discrepancy: Reported Expenses (${totalExpenses}) significantly exceed Income (${totalIncome}).`);
    }

    // 5. Environmental Logic
    if (data.houseType === 'Kutcha' && (data.houseKeptClean === true)) {
        // Not necessarily an error, but worth a check? Actually this is fine. 
        // Let's check Sanitation.
    }

    if (data.openAirDefecation === true || data.lavatory?.toLowerCase().includes('open')) {
        deduct(5, 'Sanitation Risk: Open Defecation reported.');
    }

    return {
        score,
        warnings,
        status: score >= 90 ? 'Excellent' : score >= 70 ? 'Good' : score >= 50 ? 'Average' : 'Poor',
        color: score >= 90 ? 'text-green-600' : score >= 70 ? 'text-blue-600' : score >= 50 ? 'text-orange-600' : 'text-red-600',
        bg: score >= 90 ? 'bg-green-100' : score >= 70 ? 'bg-blue-100' : score >= 50 ? 'bg-orange-100' : 'bg-red-100'
    };
};
