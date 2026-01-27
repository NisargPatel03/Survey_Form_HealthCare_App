import React from 'react';
import { Line, Bar, Doughnut, Pie } from 'react-chartjs-2';
import {
    Chart as ChartJS,
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    BarElement,
    ArcElement,
    Title,
    Tooltip,
    Legend,
    Filler,
} from 'chart.js';

ChartJS.register(
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    BarElement,
    ArcElement,
    Title,
    Tooltip,
    Legend,
    Filler
);

const commonOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
        legend: { position: 'bottom' },
    },
};

export const LineChart = ({ data, title }) => (
    <div className="bg-white p-4 rounded-xl shadow-md h-80">
        <h3 className="text-gray-700 font-semibold mb-4">{title}</h3>
        <div className="h-64">
            <Line data={data} options={{ ...commonOptions }} />
        </div>
    </div>
);

export const BarChart = ({ data, title }) => (
    <div className="bg-white p-4 rounded-xl shadow-md h-80">
        <h3 className="text-gray-700 font-semibold mb-4">{title}</h3>
        <div className="h-64">
            <Bar data={data} options={{ ...commonOptions }} />
        </div>
    </div>
);

export const PieChart = ({ data, title }) => (
    <div className="bg-white p-4 rounded-xl shadow-md h-80">
        <h3 className="text-gray-700 font-semibold mb-4">{title}</h3>
        <div className="h-64 flex justify-center">
            <Doughnut data={data} options={{ ...commonOptions }} />
        </div>
    </div>
);
