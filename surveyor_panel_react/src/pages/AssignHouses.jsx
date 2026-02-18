import React, { useState } from 'react';
import { supabase } from '../services/supabase';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import { Save, ArrowLeft } from 'lucide-react';

const REMARKS_OPTIONS = [
    'Permanent Closed',
    'Available',
    'Temporary Closed',
    'Temple',
    'Shop',
    'Broken House',
    'Other'
];

const REASON_OPTIONS = [
    'Migrate',
    'Available only after 8 P.M.',
    'Available only after 9 P.M.',
    'Available only after 6 P.M.',
    'Under Construction',
    'Broken House',
    'Revue',
    'Other'
];

export default function AssignHouses() {
    const { user } = useAuth();
    const navigate = useNavigate();
    const [loading, setLoading] = useState(false);

    // Header Data
    const [studentId, setStudentId] = useState('');
    const [areaName, setAreaName] = useState('');

    // Dynamic House List
    const [houses, setHouses] = useState([
        { id: Date.now(), house_no: '', remarksType: '', remarks: '', reasonType: '', reason: '' }
    ]);

    const [error, setError] = useState('');

    const addHouse = () => {
        setHouses([...houses, { id: Date.now() + Math.random(), house_no: '', remarksType: '', remarks: '', reasonType: '', reason: '' }]);
    };

    const removeHouse = (id) => {
        if (houses.length === 1) return;
        setHouses(houses.filter(h => h.id !== id));
    };

    const updateHouse = (id, field, value) => {
        setHouses(houses.map(h => {
            if (h.id === id) {
                const updated = { ...h, [field]: value };

                // Handle Remarks Dropdown Logic
                if (field === 'remarksType') {
                    updated.remarks = value !== 'Other' ? value : '';
                }

                // Handle Reason Dropdown Logic
                if (field === 'reasonType') {
                    updated.reason = value !== 'Other' ? value : '';
                }
                return updated;
            }
            return h;
        }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');

        if (houses.some(h => !h.house_no)) {
            setError('Please enter House No. for all entries.');
            return;
        }

        try {
            setLoading(true);

            // Prepare payload
            const assignments = houses.map(h => ({
                surveyor_id: user.id,
                student_id: studentId,
                area_name: areaName,
                house_no: parseInt(h.house_no),
                remarks: h.remarks,
                reason: h.reason
            }));

            const { error } = await supabase.from('survey_assignments').insert(assignments);

            if (error) throw error;
            navigate('/');
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div>
            <div className="flex items-center gap-4 mb-6">
                <button
                    onClick={() => navigate('/')}
                    className="text-gray-500 hover:text-gray-700"
                >
                    <ArrowLeft size={24} />
                </button>
                <h2 className="text-2xl font-bold text-gray-800">Assign Houses</h2>
            </div>

            <div className="bg-white rounded-lg shadow p-6 max-w-4xl">
                {error && (
                    <div className="bg-red-50 border-l-4 border-red-500 p-4 mb-6">
                        <p className="text-sm text-red-700">{error}</p>
                    </div>
                )}

                <form onSubmit={handleSubmit} className="space-y-6">
                    {/* Header Info */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6 p-4 bg-gray-50 rounded-lg">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Student ID</label>
                            <input
                                type="text"
                                required
                                className="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 py-2 px-3 border"
                                placeholder="e.g. STU001"
                                value={studentId}
                                onChange={(e) => setStudentId(e.target.value)}
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Area / Village Name</label>
                            <input
                                type="text"
                                required
                                className="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 py-2 px-3 border"
                                placeholder="e.g. Anand Nagar"
                                value={areaName}
                                onChange={(e) => setAreaName(e.target.value)}
                            />
                        </div>
                    </div>

                    {/* House List */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-medium text-gray-900 border-b pb-2">House Details</h3>
                        {houses.map((house, index) => (
                            <div key={house.id} className="border border-gray-200 rounded-lg p-4 relative bg-gray-50/50 hover:bg-gray-50 transition-colors">
                                <div className="grid grid-cols-1 md:grid-cols-12 gap-4 items-start">
                                    {/* House No - width 2 */}
                                    <div className="md:col-span-2">
                                        <label className="block text-xs font-medium text-gray-500 mb-1">House No</label>
                                        <input
                                            type="number"
                                            required
                                            min="1"
                                            className="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 py-2 px-3 border text-sm"
                                            placeholder="101"
                                            value={house.house_no}
                                            onChange={(e) => updateHouse(house.id, 'house_no', e.target.value)}
                                        />
                                    </div>

                                    {/* Remarks - width 4 */}
                                    <div className="md:col-span-4">
                                        <label className="block text-xs font-medium text-gray-500 mb-1">Remarks</label>
                                        <select
                                            value={house.remarksType}
                                            onChange={(e) => updateHouse(house.id, 'remarksType', e.target.value)}
                                            className="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 py-2 px-3 border text-sm mb-2"
                                        >
                                            <option value="">-- Select --</option>
                                            {REMARKS_OPTIONS.map(opt => (
                                                <option key={opt} value={opt}>{opt}</option>
                                            ))}
                                        </select>
                                        {house.remarksType === 'Other' && (
                                            <input
                                                type="text"
                                                className="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 py-2 px-3 border text-sm"
                                                placeholder="Custom remark..."
                                                value={house.remarks}
                                                onChange={(e) => updateHouse(house.id, 'remarks', e.target.value)}
                                            />
                                        )}
                                    </div>

                                    {/* Reason - width 4 */}
                                    <div className="md:col-span-4">
                                        <label className="block text-xs font-medium text-gray-500 mb-1">Reason</label>
                                        <select
                                            value={house.reasonType}
                                            onChange={(e) => updateHouse(house.id, 'reasonType', e.target.value)}
                                            className="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 py-2 px-3 border text-sm mb-2"
                                        >
                                            <option value="">-- Select --</option>
                                            {REASON_OPTIONS.map(opt => (
                                                <option key={opt} value={opt}>{opt}</option>
                                            ))}
                                        </select>
                                        {house.reasonType === 'Other' && (
                                            <input
                                                type="text"
                                                className="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 py-2 px-3 border text-sm"
                                                placeholder="Custom reason..."
                                                value={house.reason}
                                                onChange={(e) => updateHouse(house.id, 'reason', e.target.value)}
                                            />
                                        )}
                                    </div>

                                    {/* Remove Button - width 2 */}
                                    {houses.length > 1 && (
                                        <div className="md:col-span-2 flex justify-center mt-6">
                                            <button
                                                type="button"
                                                onClick={() => removeHouse(house.id)}
                                                className="text-red-600 hover:text-red-800 text-sm font-medium"
                                            >
                                                Remove
                                            </button>
                                        </div>
                                    )}
                                </div>
                            </div>
                        ))}

                        <button
                            type="button"
                            onClick={addHouse}
                            className="mt-2 text-blue-600 hover:text-blue-800 text-sm font-medium flex items-center gap-1"
                        >
                            + Add Another House
                        </button>
                    </div>

                    <div className="flex justify-end pt-4 border-t">
                        <button
                            type="button"
                            onClick={() => navigate('/')}
                            className="mr-3 px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            disabled={loading}
                            className="flex items-center justify-center px-6 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
                        >
                            {loading ? 'Saving...' : (
                                <>
                                    <Save size={18} className="mr-2" />
                                    Assign All Houses
                                </>
                            )}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}
