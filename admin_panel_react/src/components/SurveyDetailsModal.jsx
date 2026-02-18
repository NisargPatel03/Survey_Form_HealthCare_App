import React, { useState } from 'react';
import { FaTimes, FaExclamationTriangle, FaFilePdf, FaChevronDown, FaChevronUp } from 'react-icons/fa';
import { analyzeQuality } from '../utils/qualityEngine';
import { generateHealthCard } from '../utils/pdfGenerator';

const Section = ({ title, children, defaultOpen = false }) => {
    const [isOpen, setIsOpen] = useState(defaultOpen);
    return (
        <div className="border border-gray-200 rounded-lg mb-4 overflow-hidden">
            <button
                onClick={() => setIsOpen(!isOpen)}
                className="w-full flex justify-between items-center bg-gray-50 px-4 py-3 text-left font-semibold text-gray-700 hover:bg-gray-100 transition"
            >
                {title}
                {isOpen ? <FaChevronUp className="text-gray-500" /> : <FaChevronDown className="text-gray-500" />}
            </button>
            {isOpen && <div className="p-4 bg-white border-t border-gray-100">{children}</div>}
        </div>
    );
};

const KeyValueGrid = ({ data }) => (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-y-2 gap-x-4 text-sm">
        {Object.entries(data).map(([key, value]) => {
            if (value === null || value === undefined || value === '' || (Array.isArray(value) && value.length === 0)) return null;
            // Skip complex objects
            if (typeof value === 'object' && !Array.isArray(value)) return null;

            return (
                <div key={key} className="flex flex-col sm:flex-row sm:justify-between border-b border-gray-100 pb-1 last:border-0">
                    <span className="font-medium text-gray-600 capitalize pr-2">{key.replace(/([A-Z])/g, ' $1').trim()}</span>
                    <span className="text-gray-800 text-right font-semibold">{String(value)}</span>
                </div>
            );
        })}
    </div>
);

const SubTable = ({ headers, rows }) => {
    if (!rows || rows.length === 0) return <p className="text-gray-500 text-sm italic">No records found.</p>;
    return (
        <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left border">
                <thead className="bg-gray-100 font-medium">
                    <tr>
                        {headers.map((h, i) => <th key={i} className="p-2 border-b">{h}</th>)}
                    </tr>
                </thead>
                <tbody>
                    {rows.map((row, idx) => (
                        <tr key={idx} className="border-b last:border-0">
                            {Object.values(row).map((val, cIdx) => (
                                <td key={cIdx} className="p-2 border-r last:border-0">{String(val)}</td>
                            ))}
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
};

const SurveyDetailsModal = ({ survey, onClose }) => {
    if (!survey) return null;

    const data = survey.data || {};
    const quality = analyzeQuality(survey);

    return (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-lg shadow-xl w-full max-w-5xl h-[90vh] flex flex-col animate-fade-in-up">

                {/* Header */}
                <div className="flex justify-between items-center p-6 border-b bg-primary text-white rounded-t-lg">
                    <div>
                        <h3 className="text-xl font-bold">Survey Details</h3>
                        <p className="text-sm opacity-90">ID: {survey.id} | Family: {data.headOfFamily}</p>
                    </div>
                    <button onClick={onClose} className="text-white hover:text-gray-200">
                        <FaTimes size={24} />
                    </button>
                </div>

                {/* Content */}
                <div className="p-6 overflow-y-auto flex-1 bg-gray-50/50">

                    {/* Quality Warnings */}
                    {quality.score < 100 && (
                        <div className="bg-red-50 border-1 border-red-200 p-4 mb-6 rounded-lg shadow-sm">
                            <div className="flex items-center mb-2">
                                <FaExclamationTriangle className="text-red-600 mr-2" />
                                <h4 className="font-bold text-red-800">Quality Score: {quality.score}/100</h4>
                            </div>
                            <ul className="list-disc list-inside text-sm text-red-700 ml-1">
                                {quality.warnings.map((w, i) => <li key={i}>{w}</li>)}
                            </ul>
                        </div>
                    )}

                    <Section title="1. Basic Information" defaultOpen>
                        <KeyValueGrid data={{
                            FacilityType: data.facilityType,
                            HeadOfFamily: data.headOfFamily,
                            AreaName: data.areaName,
                            AreaType: data.areaType,
                            Address: data.houseNo,
                            Religion: data.religion,
                            Caste: data.subCaste,
                            FamilyType: data.familyType,
                            Contact: data.contactNumber
                        }} />
                    </Section>

                    {/* Section 7: Family Members */}
                    <Section title={`2. Family Composition (${data.familyMembers?.length || 0})`} defaultOpen>
                        <SubTable
                            headers={['Name', 'Relation', 'Age', 'Gender', 'Education', 'Occupation', 'Health Status']}
                            rows={data.familyMembers?.map(m => ({
                                name: m.name, rel: m.relationship, age: m.age, sex: m.gender,
                                edu: m.education, occ: m.occupation, health: m.healthStatus
                            }))}
                        />
                    </Section>

                    {/* Section 6: Housing */}
                    <Section title="3. Housing & Environment">
                        <KeyValueGrid data={{
                            HouseType: data.houseType,
                            Ownership: data.occupancy,
                            Rooms: data.numberOfRooms,
                            Ventilation: data.ventilation,
                            Lighting: data.lighting,
                            WaterSupply: data.waterSupply,
                            Kitchen: data.kitchen,
                            Drainage: data.drainage,
                            Latrine: data.lavatory,
                            Cleanliness: data.houseKeptClean ? 'Clean' : 'Dirty',
                            StrayDogs: data.strayDogs ? `Yes (${data.numberOfStrayDogs})` : 'No'
                        }} />
                    </Section>

                    {/* Section 7A: Income & Expenditure */}
                    <Section title="4. Economy">
                        <div className="grid grid-cols-2 gap-4 mb-4 bg-green-50 p-4 rounded-lg">
                            <div><span className="text-gray-600 block text-xs">Total Income</span><span className="font-bold text-lg text-green-700">{data.totalIncome}</span></div>
                            <div><span className="text-gray-600 block text-xs">Monthly Range</span><span className="font-bold text-lg text-green-700">{data.monthlyIncomeRange || 'N/A'}</span></div>
                            <div><span className="text-gray-600 block text-xs">Class</span><span className="font-bold text-lg text-green-700">{data.socioEconomicClass}</span></div>
                        </div>
                        {data.expenditureItems && data.expenditureItems.length > 0 && (
                            <div className="mt-2">
                                <h5 className="font-semibold text-sm mb-2 text-gray-700">Detailed Expenditure</h5>
                                <div className="flex flex-wrap gap-2">
                                    {data.expenditureItems.map((e, idx) => (
                                        <span key={idx} className="px-3 py-1 bg-gray-100 rounded text-xs border">
                                            {e.item}: {e.amount}
                                        </span>
                                    ))}
                                </div>
                            </div>
                        )}
                    </Section>

                    {/* Section 11-14: Diseases */}
                    <Section title="5. Morbidity & Health Conditions">
                        <div className="space-y-4">
                            <div>
                                <h5 className="font-semibold text-xs text-red-600 uppercase mb-1">Communicable Diseases</h5>
                                <div className="flex flex-wrap gap-1">
                                    {data.communicableDiseases?.length > 0 ? (
                                        data.communicableDiseases.map((d, i) => <span key={i} className="bg-red-100 text-red-800 px-2 py-1 rounded text-xs px-2">{d}</span>)
                                    ) : <span className="text-gray-500 text-sm">None reported</span>}
                                </div>
                            </div>
                            <div>
                                <h5 className="font-semibold text-xs text-orange-600 uppercase mb-1">Non-Communicable Diseases</h5>
                                <div className="flex flex-wrap gap-1">
                                    {data.nonCommunicableDiseases?.length > 0 ? (
                                        data.nonCommunicableDiseases.map((d, i) => <span key={i} className="bg-orange-100 text-orange-800 px-2 py-1 rounded text-xs px-2">{d}</span>)
                                    ) : <span className="text-gray-500 text-sm">None reported</span>}
                                </div>
                            </div>
                        </div>
                    </Section>

                    {/* Section 16: Maternal Health */}
                    {data.pregnantWomen && data.pregnantWomen.length > 0 && (
                        <Section title="6. Maternal Health (Pregnant Women)">
                            <SubTable
                                headers={['Name', 'Age', 'LMP', 'EDD', 'Trimester', 'Tetanus', 'Iron/Folic', 'Place']}
                                rows={data.pregnantWomen.map(p => ({
                                    name: p.name, age: p.age, lmp: p.lastMenstrualPeriod, edd: p.expectedDeliveryDate,
                                    tri: p.trimester, tet: p.tetanusToxoid ? 'Yes' : 'No', iron: p.ironFolicAcid ? 'Yes' : 'No', place: p.deliveryPlace
                                }))}
                            />
                        </Section>
                    )}

                    {/* Section 17: Vital Events */}
                    <Section title="7. Vital Events (Births/Deaths)">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <h5 className="font-bold text-xs mb-2">Births</h5>
                                <SubTable headers={['Name', 'Sex', 'Weight']} rows={data.births?.map(b => ({ n: b.name, s: b.sex, w: b.birthWeight }))} />
                            </div>
                            <div>
                                <h5 className="font-bold text-xs mb-2">Deaths</h5>
                                <SubTable headers={['Name', 'Age', 'Cause']} rows={data.deaths?.map(d => ({ n: d.name, a: d.ageAtDeath, c: d.causeOfDeath }))} />
                            </div>
                        </div>
                    </Section>

                    {/* Section 18: Immunization */}
                    {data.immunizationRecords && data.immunizationRecords.length > 0 && (
                        <Section title="8. Child Immunization">
                            <SubTable
                                headers={['Child Name', 'BCG', 'Polio', 'DPT', 'Measles', 'Vitamin A']}
                                rows={data.immunizationRecords.map(i => ({
                                    name: i.childName, bcg: i.bcg ? 'Y' : 'N', polio: i.polio ? 'Y' : 'N',
                                    dpt: i.dpt ? 'Y' : 'N', measles: i.measles ? 'Y' : 'N', vitA: i.vitaminA ? 'Y' : 'N'
                                }))}
                            />
                        </Section>
                    )}

                    {/* Other Info */}
                    <Section title="9. Other Information">
                        <KeyValueGrid data={{
                            Transport: data.transportOptions?.join(', '),
                            Languages: data.languagesKnown?.join(', '),
                            FamilyStrengths: data.familyStrengths?.join(', '),
                            Contraceptive: data.contraceptiveMethod,
                            IntendingMethods: [
                                (data.intendingTubalLigation || data.intendingTubectomy) ? 'Tubectomy' : null,
                                data.intendingVasectomy ? 'Vasectomy' : null,
                                data.intendingAnyOtherMethod ? 'Other Method' : null
                            ].filter(Boolean).join(', ') || 'None'
                        }} />
                    </Section>

                </div>

                {/* Footer */}
                <div className="p-4 border-t flex justify-end gap-2 bg-gray-50 rounded-b-lg">
                    <button
                        onClick={() => generateHealthCard(survey)}
                        className="flex items-center bg-teal-600 hover:bg-teal-700 px-6 py-2 rounded text-white font-medium shadow-sm transition transform hover:-translate-y-0.5"
                    >
                        <FaFilePdf className="mr-2" />
                        Generate Health Card PDF
                    </button>
                    <button onClick={onClose} className="bg-gray-200 hover:bg-gray-300 px-6 py-2 rounded text-gray-800 font-medium transition">
                        Close
                    </button>
                </div>
            </div>
        </div>
    );
};

export default SurveyDetailsModal;
