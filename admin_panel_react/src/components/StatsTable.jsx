import React from 'react';
import { jsPDF } from 'jspdf';
import autoTable from 'jspdf-autotable';
import { FaDownload } from 'react-icons/fa';

const StatsTable = ({ title, data }) => {
    if (!data || !data.datasets || data.datasets.length === 0) return null;

    const dataset = data.datasets[0];
    const total = dataset.data.reduce((a, b) => a + b, 0);
    const detailsMap = data.details || {}; // Access details passed from engine

    const handleDownloadPDF = () => {
        try {
            const doc = new jsPDF();

            // -- Header --
            doc.setFontSize(16);
            doc.text(`${title} - Report`, 14, 15);
            doc.setFontSize(10);
            doc.text(`Generated on: ${new Date().toLocaleDateString()}`, 14, 22);

            // -- Table 1: Summary Statistics --
            const tableColumn = ["Category", "Frequency", "Percentage"];
            const tableRows = [];

            data.labels.forEach((label, i) => {
                const count = dataset.data[i];
                const percent = total > 0 ? ((count / total) * 100).toFixed(1) : 0;
                tableRows.push([label, count, `${percent}%`]);
            });

            // Add Total Row
            tableRows.push(['TOTAL', total, '100%']);

            autoTable(doc, {
                head: [tableColumn],
                body: tableRows,
                startY: 28,
                theme: 'grid',
                headStyles: { fillColor: [59, 130, 246] }, // Blue header
            });

            // -- Table 2: Detailed Disease List (If applicable) --
            // Check if we have any impacted cases to show
            let hasDetails = false;

            // We will append a new section for each disease that has cases
            // Access finalY from the last autoTable call (tracked via doc['lastAutoTable'])
            // or pass use the return value if we were using it, but autoTable attaches to doc
            let finalY = doc.lastAutoTable.finalY + 15;

            data.labels.forEach((label, i) => {
                const count = dataset.data[i];
                const cases = detailsMap[label] || [];

                if (count > 0 && cases.length > 0) {
                    hasDetails = true;

                    // Check page break
                    if (finalY > 250) {
                        doc.addPage();
                        finalY = 20;
                    }

                    doc.setFontSize(12);
                    doc.setTextColor(0, 0, 0);
                    doc.text(`Details: ${label} (${count} cases)`, 14, finalY);

                    const detailColumns = ["HOF Name", "Contact Number", "Survey Date"];
                    const detailRows = cases.map(c => [c.hof, c.contact, c.date]);

                    autoTable(doc, {
                        head: [detailColumns],
                        body: detailRows,
                        startY: finalY + 5,
                        theme: 'striped',
                        headStyles: { fillColor: [220, 38, 38] }, // Red header for diseases
                        styles: { fontSize: 9 },
                    });

                    finalY = doc.lastAutoTable.finalY + 10;
                }
            });

            if (!hasDetails && Object.keys(detailsMap).length > 0) {
                doc.setFontSize(10);
                doc.setTextColor(100);
                doc.text("No specific cases recorded with details.", 14, finalY);
            }

            doc.save(`${title.replace(/\s+/g, '_')}_Report.pdf`);
        } catch (error) {
            console.error("PDF Generation Error:", error);
            alert("Failed to generate PDF. Please check console for details. Error: " + error.message);
        }
    };

    return (
        <div className="bg-white p-4 rounded-xl shadow-md flex flex-col h-full">
            <div className="flex justify-between items-center mb-4 border-b pb-2">
                <h3 className="text-gray-700 font-semibold">{title}</h3>
                <button
                    onClick={handleDownloadPDF}
                    className="flex items-center gap-2 text-xs bg-blue-50 text-blue-600 px-3 py-1.5 rounded-md hover:bg-blue-100 transition"
                    title="Download PDF Report"
                >
                    <FaDownload /> PDF
                </button>
            </div>

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

export default StatsTable;
