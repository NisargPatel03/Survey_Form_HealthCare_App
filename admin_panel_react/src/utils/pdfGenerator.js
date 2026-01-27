import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

export const generateHealthCard = (survey) => {
    if (!survey || !survey.data) return;
    const data = survey.data;

    // Create PDF Instance
    const doc = new jsPDF();

    // -- Header --
    doc.setFillColor(0, 121, 107); // Primary Color (Teal)
    doc.rect(0, 0, 210, 30, 'F');

    doc.setTextColor(255, 255, 255);
    doc.setFontSize(18);
    doc.text('Manikaka Topawala Institute of Nursing', 105, 12, { align: 'center' });
    doc.setFontSize(12);
    doc.text('Community Health Nursing - Family Health Card', 105, 22, { align: 'center' });

    // -- Family Info --
    doc.setTextColor(0, 0, 0);
    doc.setFontSize(12);
    doc.text(`Head of Family: ${data.headOfFamily || 'N/A'}`, 14, 40);
    doc.text(`Area: ${data.areaName || 'N/A'}  |  Type: ${data.areaType || 'N/A'}`, 14, 46);
    doc.text(`Contact: ${data.contactNumber || 'N/A'}`, 14, 52);
    doc.text(`Generated On: ${new Date().toLocaleDateString()}`, 150, 40);

    // -- Family Members Table --
    const members = data.familyMembers || [];
    const memberRows = members.map(m => [m.name, m.age, m.gender, m.relationship, m.healthStatus || 'Healthy']);

    // Use autoTable imported directly
    autoTable(doc, {
        startY: 60,
        head: [['Name', 'Age', 'Gender', 'Relation', 'Health Status']],
        body: memberRows,
        theme: 'striped',
        headStyles: { fillColor: [0, 121, 107] },
    });

    // -- Health Advice (AI-Driven Logic) --
    // Use lastAutoTable.finalY from doc (it attaches itself)
    let finalY = (doc.lastAutoTable?.finalY || 60) + 10;

    doc.setFontSize(14);
    doc.setTextColor(0, 121, 107);
    doc.text('Health Recommendations', 14, finalY);

    doc.setFontSize(10);
    doc.setTextColor(0, 0, 0);
    finalY += 6;

    const adviceUnordered = [];

    // Logic 1: Water
    if (data.waterSupply === 'Well' || data.waterSupply === 'Hand pump') {
        if (data.wellChlorinationDate === 'Never' || !data.wellChlorinationDate) {
            adviceUnordered.push('• Water source "Well" needs regular chlorination. Please practice boiling water before drinking.');
        }
    }

    // Logic 2: Sanitation
    if (data.openAirDefecation) {
        adviceUnordered.push('• Open defecation poses severe health risks. Please utilize community or private latrines.');
    }

    // Logic 3: Hygiene
    if (data.houseKeptClean === false) {
        adviceUnordered.push('• Improve house hygiene to prevent breeding of insects and spread of disease.');
    }

    // Logic 4: Immunization (Generic)
    const hasKids = members.some(m => m.age < 5);
    if (hasKids) {
        adviceUnordered.push('• Ensure all children under 5 have completed their immunization schedule (Polio, BCG, DPT).');
    }

    // Logic 5: General
    adviceUnordered.push('• Visit the nearest Health Centre for regular checkups.');

    // Render Advice
    adviceUnordered.forEach(line => {
        doc.text(line, 14, finalY);
        finalY += 5;
    });

    // Footer
    doc.setFontSize(8);
    doc.setTextColor(150, 150, 150);
    doc.text('Provided by Community Health Survey Initiative.', 105, 290, { align: 'center' });

    // Save
    doc.save(`HealthCard_${data.headOfFamily?.replace(/\s/g, '_') || 'Family'}.pdf`);
};
