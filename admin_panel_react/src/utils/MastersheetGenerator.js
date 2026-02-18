import XLSX from 'xlsx-js-style';

/**
 * Mastersheet Generator (Excel)
 * Generates an aggregate matrix .xlsx report using 'xlsx-js-style' library.
 * Rows: Categories (Age, Sex, Religion, etc.)
 * Columns: Student IDs (extracted from student_name/id)
 * Values: Counts
 */

export const generateMastersheetExcel = (surveys) => {
    // 1. Identify all unique Students (Columns)
    const studentMap = {}; // id -> student_name
    surveys.forEach(s => {
        let sid = s.student_name || s.student_id || 'Unknown';
        // Extract number if possible (e.g. 23CS042 -> 42)
        const match = sid.match(/\d+$/);
        const shortId = match ? match[0] : sid;
        studentMap[shortId] = sid; // Keep full name reference if needed, but key by short ID
    });

    const studentIds = Object.keys(studentMap).sort((a, b) => {
        // numeric sort if possible
        if (!isNaN(a) && !isNaN(b)) return parseInt(a) - parseInt(b);
        return a.localeCompare(b);
    });

    // 2. Initialize Data Structure
    // structure: { category: { rowLabel: { studentId: count } } }
    const matrix = {};

    const increment = (category, label, studentId) => {
        if (!label) return;
        if (!matrix[category]) matrix[category] = {};
        if (!matrix[category][label]) matrix[category][label] = {}; // init row
        studentIds.forEach(id => {
            if (!matrix[category][label][id]) matrix[category][label][id] = 0;
        });

        // Find the correct student column for this survey
        if (matrix[category][label][studentId] !== undefined) {
            matrix[category][label][studentId]++;
        }
    };

    // 3. Process Surveys
    surveys.forEach(s => {
        const d = s.data || {};
        let sid = s.student_name || s.student_id || 'Unknown';
        const match = sid.match(/\d+$/);
        const studentKey = match ? match[0] : sid;

        // -- Section 0: Total Houses (Direct Row, distinct from General category headers) --
        increment('__TOP__', 'Total Houses Allotted', studentKey);

        // -- Section 1: Age (Member Level) --
        const members = d.familyMembers || [];
        members.forEach(m => {
            const age = parseInt(m.age) || 0;
            let ageGroup = '';
            if (age <= 5) ageGroup = 'a. 0 - 5 (Under Five)';
            else if (age <= 12) ageGroup = 'b. 5 - 12 (School Children)';
            else if (age <= 19) ageGroup = 'c. 12 - 19 (Teenagers)';
            else if (age <= 25) ageGroup = 'd. 19 - 25 (Early Adolescence)';
            else if (age <= 40) ageGroup = 'e. 25 - 40 (Middle Adolescence)';
            else if (age <= 60) ageGroup = 'f. 40 - 60 (Late Adolescence)';
            else ageGroup = 'g. >60 (Old Age)';

            increment('1. AGE (IN YEARS)', ageGroup, studentKey);

            // -- Section 2: Sex (Member Level) --
            const gender = (m.gender || '').toLowerCase();
            if (gender === 'male') increment('2. SEX', 'a. Male', studentKey);
            else if (gender === 'female') increment('2. SEX', 'b. Female', studentKey);

            // -- Section 4: Education (Member Level) --
            const edu = (m.education || '').toLowerCase();
            if (edu.includes('illiterate')) increment('4. EDUCATION STATUS', 'a. Illiterate', studentKey);
            else if (edu.includes('primary')) increment('4. EDUCATION STATUS', 'b. Primary', studentKey);
            else if (edu.includes('secondary') && !edu.includes('higher')) increment('4. EDUCATION STATUS', 'c. Secondary', studentKey);
            else if (edu.includes('higher secondary')) increment('4. EDUCATION STATUS', 'd. Higher Secondary', studentKey);
            else if (edu.includes('graduate')) increment('4. EDUCATION STATUS', 'e. Graduate and above', studentKey);

            // -- Section 6: Occupation (Member Level) --
            const job = (m.occupation || '').toLowerCase();
            if (job.includes('daily wages') || job.includes('labour')) increment('6. OCCUPATION', 'a. Daily wages', studentKey);
            else if (job.includes('farmer')) increment('6. OCCUPATION', 'b. Farmer', studentKey);
            else if (job.includes('business')) increment('6. OCCUPATION', 'c. Business', studentKey);
            else if (job.includes('self')) increment('6. OCCUPATION', 'd. Self Employed', studentKey);
            else if (job.includes('govt')) increment('6. OCCUPATION', 'e. Govt job', studentKey);
            else if (job.includes('private')) increment('6. OCCUPATION', 'f. Private', studentKey);
            else if (job.includes('housewife')) increment('6. OCCUPATION', 'g. Housewife', studentKey);
            else if (job.includes('student')) increment('6. OCCUPATION', 'h. Student', studentKey);
        });

        // -- Section 3: Religion (Family Level) --
        const rel = (d.religion || '').toLowerCase();
        if (rel === 'hindu') increment('3. RELIGION', 'a. Hindu', studentKey);
        else if (rel === 'muslim') increment('3. RELIGION', 'b. Muslim', studentKey);
        else if (rel === 'christian') increment('3. RELIGION', 'c. Christian', studentKey);
        else if (rel) increment('3. RELIGION', 'd. Other', studentKey);

        // -- Section 5: Type of Family --
        const ftype = (d.familyType || '').toLowerCase();
        if (ftype === 'nuclear') increment('5. TYPE OF FAMILY', 'a. Nuclear', studentKey);
        else if (ftype === 'joint') increment('5. TYPE OF FAMILY', 'b. Joint', studentKey);
        else if (ftype === 'single' || ftype === 'living alone') increment('5. TYPE OF FAMILY', 'c. Single', studentKey);

        // -- Section 7: Income (Family Level) --
        const income = parseInt(d.totalIncome) || 0;
        if (income < 1000) increment('7. FAMILY INCOME / MONTH', 'Below rs:-1000', studentKey);
        else if (income <= 1500) increment('7. FAMILY INCOME / MONTH', 'Rs 1000-1500', studentKey);
        else if (income <= 2000) increment('7. FAMILY INCOME / MONTH', 'Rs 1501-2000', studentKey);
        else if (income <= 2500) increment('7. FAMILY INCOME / MONTH', 'Rs 2001-2500', studentKey);
        else increment('7. FAMILY INCOME / MONTH', 'Rs 2501 and above', studentKey);

        // -- Section 8: House Type --
        const htype = (d.houseType || '').toLowerCase();
        if (htype === 'pucca') increment('8. TYPE OF HOUSE', 'a. Pucca', studentKey);
        else if (htype === 'semi' || htype.includes('semi')) increment('8. TYPE OF HOUSE', 'b. Semipucca', studentKey);
        else if (htype === 'kutcha') increment('8. TYPE OF HOUSE', 'c. Kutcha', studentKey);

        // -- Section 9: Drainage --
        const drain = (d.drainage || '').toLowerCase();
        if (drain === 'adequate') increment('9. DRAINAGE', 'Adequate', studentKey);
        else if (drain === 'inadequate') increment('9. DRAINAGE', 'Inadequate', studentKey);
        else if (drain.includes('no')) increment('9. DRAINAGE', 'No drainage', studentKey);

        // -- Section 10: Waste Disposal --
        const wastes = Array.isArray(d.wasteDisposalMethods) ? d.wasteDisposalMethods : [d.wasteDisposalMethods];
        wastes.forEach(w => {
            if (!w) return;
            const wl = w.toLowerCase();
            if (wl.includes('compost')) increment('10. DISPOSAL OF WASTE', 'Composting', studentKey);
            else if (wl.includes('burn')) increment('10. DISPOSAL OF WASTE', 'Burning', studentKey);
            else if (wl.includes('bury')) increment('10. DISPOSAL OF WASTE', 'Burying', studentKey);
            else if (wl.includes('dump')) increment('10. DISPOSAL OF WASTE', 'Dumping', studentKey);
        });

        // -- Section 11: Eligible Couple (Methods) --
        if (d.intendingTubalLigation || d.intendingTubectomy || (d.contraceptiveMethod && d.contraceptiveMethod.toLowerCase().includes('tubect')))
            increment('11. ELIGIBLE COUPLE', 'Tubectomy', studentKey);
        if (d.intendingVasectomy || (d.contraceptiveMethod && d.contraceptiveMethod.toLowerCase().includes('vasect')))
            increment('11. ELIGIBLE COUPLE', 'Vasectomy', studentKey);
        if (d.contraceptiveMethod === 'Temporary' || d.usesContraceptives)
            increment('11. ELIGIBLE COUPLE', 'Temporary Contraceptives', studentKey);
        if (d.infertility)
            increment('11. ELIGIBLE COUPLE', 'Infertility', studentKey);

        // -- Section 12: Total Population --
        if (!matrix['12. TOTAL POPULATION']) matrix['12. TOTAL POPULATION'] = { 'Total Population': {} };
        if (!matrix['12. TOTAL POPULATION']['Total Population'][studentKey]) matrix['12. TOTAL POPULATION']['Total Population'][studentKey] = 0;
        matrix['12. TOTAL POPULATION']['Total Population'][studentKey] += members.length;

        // -- Section 13: Deaths --
        if (d.deaths && d.deaths.length > 0) increment('13. NUMBER OF DEATH IN LAST ONE YEAR', 'Deaths', studentKey);

        // -- Section 14: Births --
        if (d.births && d.births.length > 0) increment('14. NUMBER OF BIRTH IN LAST ONE YEAR', 'Births', studentKey);

        // -- Section 15: Under 5 Children --
        const under5 = members.filter(m => (parseInt(m.age) || 0) <= 5).length;
        if (under5 > 0) {
            if (!matrix['15. UNDER FIVE CHILDREN']) matrix['15. UNDER FIVE CHILDREN'] = { 'Under 5': {} };
            if (!matrix['15. UNDER FIVE CHILDREN']['Under 5'][studentKey]) matrix['15. UNDER FIVE CHILDREN']['Under 5'][studentKey] = 0;
            matrix['15. UNDER FIVE CHILDREN']['Under 5'][studentKey] += under5;
        }

        // -- Section 16: Antenatal Mothers --
        const pregnant = d.pregnantWomen && d.pregnantWomen.length > 0;
        if (pregnant) increment('16. ANTENATAL MOTHERS', 'Antenatal Mothers', studentKey);

        // -- Section 17: Postnatal Mothers --
        const birthCount = d.births ? d.births.length : 0;
        if (birthCount > 0) increment('17. POSTNATAL MOTHERS', 'Postnatal Mothers', studentKey);

        // -- Section 18: Eligible Couples (Priority) --
        if (d.eligibleCouples) {
            d.eligibleCouples.forEach(ec => {
                // Check boolean or string (depends on DB format, handling both)
                if (ec.priority1 === true || ec.priority1 === 'true' || ec.priority === 'I')
                    increment('18. ELIGIBLE COUPLES', 'Priority - I', studentKey);

                if (ec.priority2 === true || ec.priority2 === 'true' || ec.priority === 'II')
                    increment('18. ELIGIBLE COUPLES', 'Priority - II', studentKey);
            });
        }

        // -- Section 19: Marriages --
        const marriageCount = d.marriages ? d.marriages.length : 0;
        if (marriageCount > 0) increment('19. NUMBER OF MARRIAGES IN LAST ONE YEAR', 'Marriages', studentKey);
    });

    // 4. Generate Sheet Data (Array of Arrays)
    const sheetData = [];

    // Header Row: [ID NO, ...studentNumbers, TOTAL]
    const headerRow = ['ID NO', ...studentIds, 'TOTAL'];
    sheetData.push(headerRow);

    // Helper to generate row
    const generateRow = (category, labelsOrder) => {
        if (!matrix[category]) return;

        // Push Category Header Row (Bold Title)
        if (category !== '__TOP__') {
            sheetData.push([category]); // Just the category name in first col
        }

        const labels = labelsOrder || Object.keys(matrix[category]).sort();

        labels.forEach(label => {
            const studentCounts = matrix[category][label] || {};
            let rowTotal = 0;
            const rowData = studentIds.map(id => {
                const count = studentCounts[id] || 0;
                rowTotal += count;
                return count;
            });

            // Row: Label, Counts..., Total
            // Note: studentIds correspond to columns 1 to N. Last col is Total.
            // label goes in Col 0.
            sheetData.push([label, ...rowData, rowTotal]);
        });
    };

    // -- Top Row: Total Houses Allotted --
    // This is essentially Row 2 in the sheet.
    if (matrix['__TOP__'] && matrix['__TOP__']['Total Houses Allotted']) {
        const studentCounts = matrix['__TOP__']['Total Houses Allotted'];
        let rowTotal = 0;
        const rowData = studentIds.map(id => {
            const count = studentCounts[id] || 0;
            rowTotal += count;
            return count;
        });
        sheetData.push(['Total Houses Allotted', ...rowData, rowTotal]);
    }

    // -- Sections --
    generateRow('1. AGE (IN YEARS)', [
        'a. 0 - 5 (Under Five)', 'b. 5 - 12 (School Children)', 'c. 12 - 19 (Teenagers)',
        'd. 19 - 25 (Early Adolescence)', 'e. 25 - 40 (Middle Adolescence)',
        'f. 40 - 60 (Late Adolescence)', 'g. >60 (Old Age)'
    ]);
    generateRow('2. SEX', ['a. Male', 'b. Female']);
    generateRow('3. RELIGION', ['a. Hindu', 'b. Muslim', 'c. Christian', 'd. Other']);
    generateRow('4. EDUCATION STATUS', [
        'a. Illiterate', 'b. Primary', 'c. Secondary', 'd. Higher Secondary', 'e. Graduate and above'
    ]);
    generateRow('5. TYPE OF FAMILY', ['a. Nuclear', 'b. Joint', 'c. Single']);
    generateRow('6. OCCUPATION', [
        'a. Daily wages', 'b. Farmer', 'c. Business', 'd. Self Employed',
        'e. Govt job', 'f. Private', 'g. Housewife', 'h. Student'
    ]);
    generateRow('7. FAMILY INCOME / MONTH', [
        'Below rs:-1000', 'Rs 1000-1500', 'Rs 1501-2000', 'Rs 2001-2500', 'Rs 2501 and above'
    ]);
    generateRow('8. TYPE OF HOUSE', ['a. Pucca', 'b. Semipucca', 'c. Kutcha']);
    generateRow('9. DRAINAGE', ['Adequate', 'Inadequate', 'No drainage']);
    generateRow('10. DISPOSAL OF WASTE', ['Composting', 'Burning', 'Burying', 'Dumping']);
    generateRow('11. ELIGIBLE COUPLE', ['Tubectomy', 'Vasectomy', 'Temporary Contraceptives', 'Infertility']);
    generateRow('12. TOTAL POPULATION', ['Total Population']);
    generateRow('13. NUMBER OF DEATH IN LAST ONE YEAR', ['Deaths']);
    generateRow('14. NUMBER OF BIRTH IN LAST ONE YEAR', ['Births']);
    generateRow('15. UNDER FIVE CHILDREN', ['Under 5']);
    generateRow('16. ANTENATAL MOTHERS', ['Antenatal Mothers']);
    generateRow('17. POSTNATAL MOTHERS', ['Postnatal Mothers']);
    generateRow('18. ELIGIBLE COUPLES', ['Priority - I', 'Priority - II']);
    generateRow('19. NUMBER OF MARRIAGES IN LAST ONE YEAR', ['Marriages']);

    // 5. Create Workbook with Styling
    const wb = XLSX.utils.book_new();
    const ws = XLSX.utils.aoa_to_sheet(sheetData);

    // Basic Column Widths
    const wscols = [{ wch: 35 }]; // First col wider
    studentIds.forEach(() => wscols.push({ wch: 5 })); // Student cols narrow
    wscols.push({ wch: 8 }); // Total col
    ws['!cols'] = wscols;

    // Apply Styles Loop
    // Range of sheet
    const range = XLSX.utils.decode_range(ws['!ref']);

    for (let R = range.s.r; R <= range.e.r; ++R) {
        for (let C = range.s.c; C <= range.e.c; ++C) {
            const cellRef = XLSX.utils.encode_cell({ c: C, r: R });
            if (!ws[cellRef]) continue;

            const cell = ws[cellRef];
            if (!cell.s) cell.s = {};

            // 1. Header Row (Bold & Centered)
            if (R === 0) {
                cell.s.font = { bold: true };
                cell.s.alignment = { horizontal: 'center' };
            }

            // 2. Total Column (Bold)
            if (C === range.e.c) {
                cell.s.font = { bold: true };
            }

            // 3. Section Titles (Row where Col 0 has value like names above, and other cols empty)
            if (C === 0) {
                const val = String(cell.v);
                // Check 1: "Total Houses Allotted"
                if (val === 'Total Houses Allotted') {
                    cell.s.font = { bold: true };
                }
                // Check 2: Numbered Sections (e.g., "1. AGE (IN YEARS)")
                // Updated regex to allow parentheses, hyphens, etc.
                else if (val.match(/^\d+\.\s+[A-Z\s\/()-]+$/)) {
                    cell.s.font = { bold: true };
                }
            }
        }
    }

    XLSX.utils.book_append_sheet(wb, ws, "Mastersheet");

    // Return file
    XLSX.writeFile(wb, `Mastersheet_Aggregation_${new Date().toISOString().split('T')[0]}.xlsx`);
};
