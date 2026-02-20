import React, { useState } from 'react';
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import { FaHome, FaChartPie, FaUsers, FaFileDownload, FaBars, FaTimes, FaMapMarkedAlt, FaSignOutAlt, FaClipboardList } from 'react-icons/fa';


const Layout = () => {
    // Desktop: Default Open | Mobile: Default Closed
    const [sidebarOpen, setSidebarOpen] = useState(window.innerWidth > 768);
    const location = useLocation();
    const navigate = useNavigate();

    const handleLogout = () => {
        localStorage.removeItem('isAuthenticated');
        navigate('/login');
    };


    // Close sidebar on route change (Mobile)
    React.useEffect(() => {
        if (window.innerWidth <= 768) setSidebarOpen(false);
    }, [location]);

    const navItems = [
        { path: '/', name: 'Dashboard', icon: <FaHome /> },
        { path: '/analytics', name: 'Analytics', icon: <FaChartPie /> },
        { path: '/map', name: 'Health Map', icon: <FaMapMarkedAlt /> },
        { path: '/families', name: 'Family Directory', icon: <FaUsers /> },
        { path: '/operations', name: 'Operations', icon: <FaClipboardList /> },
        { path: '/export', name: 'Export Data', icon: <FaFileDownload /> },
    ];

    return (
        <div className="flex h-screen bg-gray-100 overflow-hidden relative">
            {/* Mobile Backdrop */}
            {sidebarOpen && (
                <div
                    className="fixed inset-0 bg-black/50 z-20 md:hidden"
                    onClick={() => setSidebarOpen(false)}
                ></div>
            )}

            {/* Sidebar */}
            <aside
                className={`
                    absolute md:relative z-30 h-full bg-primary text-white flex flex-col shadow-xl transition-all duration-300
                    ${sidebarOpen ? 'w-64 translate-x-0' : 'w-64 -translate-x-full md:translate-x-0 md:w-20'}
                `}
            >
                <div className="p-4 flex items-center justify-between border-b border-secondary h-16">
                    <h1 className={`font-bold text-xl truncate ${!sidebarOpen && 'md:hidden'}`}>MTIN Admin</h1>
                    <button
                        onClick={() => setSidebarOpen(!sidebarOpen)}
                        className="p-2 hover:bg-secondary rounded focus:outline-none"
                    >
                        {sidebarOpen ? <FaTimes className="md:hidden" /> : <FaBars />}
                        <FaBars className="hidden md:block" />
                    </button>
                </div>

                <nav className="flex-1 py-6 overflow-y-auto">
                    <ul className="space-y-2">
                        {navItems.map((item) => (
                            <li key={item.path}>
                                <NavLink
                                    to={item.path}
                                    className={({ isActive }) =>
                                        `flex items-center px-4 py-3 transition-colors ${isActive ? 'bg-secondary border-r-4 border-white' : 'hover:bg-secondary/50'
                                        }`
                                    }
                                    title={item.name}
                                >
                                    <span className="text-xl min-w-[24px] text-center">{item.icon}</span>
                                    <span className={`ml-4 font-medium whitespace-nowrap transition-opacity duration-200
                                        ${!sidebarOpen ? 'md:opacity-0 md:hidden' : 'opacity-100'}
                                    `}>
                                        {item.name}
                                    </span>
                                </NavLink>
                            </li>
                        ))}
                    </ul>
                </nav>

                <div className="p-4 border-t border-secondary text-sm text-center text-gray-200">
                    <button
                        onClick={handleLogout}
                        className="flex items-center w-full px-4 py-2 mb-4 text-white hover:bg-secondary/50 rounded transition-colors"
                    >
                        <span className="text-xl min-w-[24px] text-center"><FaSignOutAlt /></span>
                        <span className={`ml-4 font-medium whitespace-nowrap transition-opacity duration-200
                            ${!sidebarOpen ? 'md:opacity-0 md:hidden' : 'opacity-100'}
                        `}>
                            Logout
                        </span>
                    </button>
                    <p className={`${!sidebarOpen && 'md:hidden'}`}>v1.0.0</p>
                </div>

            </aside>

            {/* Main Content */}
            <div className="flex-1 flex flex-col h-full overflow-hidden">
                {/* Mobile Header */}
                <header className="bg-white shadow-sm p-4 flex items-center md:hidden z-10">
                    <button onClick={() => setSidebarOpen(true)} className="text-gray-600 focus:outline-none mr-4">
                        <FaBars size={24} />
                    </button>
                    <h2 className="font-bold text-lg text-gray-800">Community Survey</h2>
                </header>

                <main className="flex-1 overflow-auto p-4 md:p-8 relative">
                    <Outlet />
                </main>
            </div>
        </div>
    );
};

export default Layout;
