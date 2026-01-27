import React from 'react';

const StatCard = ({ title, value, icon, color, subtext }) => {
    return (
        <div className="bg-white rounded-xl shadow-md p-6 flex items-start justify-between transform transition hover:scale-105">
            <div>
                <p className="text-gray-500 text-sm font-medium uppercase tracking-wider">{title}</p>
                <h3 className="text-3xl font-bold text-gray-800 mt-2">{value}</h3>
                {subtext && <p className="text-sm text-gray-400 mt-1">{subtext}</p>}
            </div>
            <div className={`p-3 rounded-full ${color} bg-opacity-20 text-white`}>
                {/* The icon handles its own color, but background opacities are nice */}
                <span className={`text-2xl ${color.replace('bg-', 'text-')}`}>{icon}</span>
            </div>
        </div>
    );
};

export default StatCard;
