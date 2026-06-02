import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom';
import { supabase } from '../services/supabase';
import { LayoutDashboard, LogOut, User, ClipboardCheck, Menu, X, FileText, ChevronDown } from 'lucide-react';
import { useState, useEffect } from 'react';

export default function Layout() {
  const navigate = useNavigate();
  const location = useLocation();
  const [profile, setProfile] = useState(null);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isGuidelinesOpen, setIsGuidelinesOpen] = useState(false);

  const guidelinesPdfs = [
    { name: '10 B School Health Program Guidelines', file: '/guidelines/10 B School Health  Program Report Guidelines.pdf' },
    { name: '11 B Anganwadi Assessment Guidelines', file: '/guidelines/11 B Anganwadi Assessment Program Report Guidelines.pdf' },
    { name: '13 B Health Screening Camp Report', file: '/guidelines/13 B Health Screening Camp Report.pdf' },
    { name: '14 B Role Play Report', file: '/guidelines/14 B Role Play Report.pdf' },
    { name: '15 B Procedure Format Guidelines', file: '/guidelines/15 B Procedure Format Guidelines.pdf' },
    { name: '16 B VISIT REPORT GUIDELINES', file: '/guidelines/16 B VISIT REPORT GUIDELINES.pdf' },
    { name: '25 B. PRIMARY MANAGEMENT AND CARE (PROTOCOL-BASED)', file: '/guidelines/25 B. PRIMARY MANAGEMENT AND CARE (PROTOCOL-BASED).pdf' },
    { name: '26 B. Participation in Disaster Mockdrills', file: '/guidelines/26 B. Participation in Disaster Mockdrills.pdf' },
    { name: '27 B. Interaction with health workers', file: '/guidelines/27 B. Interaction with health workers.pdf' },
  ];

  useEffect(() => {
    fetchProfile();
  }, []);

  // Close mobile menu and guidelines dropdown on route change
  useEffect(() => {
    setIsMobileMenuOpen(false);
    setIsGuidelinesOpen(false);
  }, [location.pathname]);

  const fetchProfile = async () => {
    const { data: { user } } = await supabase.auth.getUser();
    if (user) {
      const { data } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .single();
      setProfile(data);
    }
  };

  const handleLogout = async () => {
    await supabase.auth.signOut();
    navigate('/login');
  };

  const SidebarContent = () => (
    <>
      <div className="p-6">
        <div className="flex flex-col items-center text-center gap-5">
          <div className="h-32 w-32 p-3 bg-white rounded-full shadow-2xl border-4 border-primary-800 flex items-center justify-center overflow-hidden ring-4 ring-primary-900/50">
            <img src="/logo.jpg" alt="Logo" className="h-full w-full object-contain mix-blend-multiply" />
          </div>
          <div className="space-y-1">
            <h1 className="text-[10px] font-black tracking-[0.2em] text-white leading-tight uppercase">
              MANIKAKA TOPAWALA
            </h1>
            <h1 className="text-[8px] font-bold tracking-[0.1em] text-primary-300 uppercase">
              INSTITUTE OF NURSING
            </h1>
          </div>
        </div>
      </div>
      
      <nav className="flex-1 px-4 py-4 space-y-2">
        <Link
          to="/"
          className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 ${
            location.pathname === '/' 
              ? 'bg-white/10 text-white shadow-lg border border-white/5' 
              : 'text-primary-100 hover:bg-white/5 hover:text-white'
          }`}
        >
          <LayoutDashboard className="h-5 w-5" />
          <span className="font-medium">Dashboard</span>
        </Link>
      </nav>

      <div className="p-4 border-t border-primary-800/50">
        <div className="flex items-center gap-3 px-4 py-3 mb-2 bg-primary-800/30 rounded-2xl border border-white/5">
          <div className="h-10 w-10 rounded-full bg-primary-700 flex items-center justify-center shadow-inner">
            <User className="h-6 w-6 text-primary-100" />
          </div>
          <div className="overflow-hidden">
            <p className="text-sm font-bold truncate text-white">{profile?.full_name || 'Faculty'}</p>
            <p className="text-[10px] text-primary-300 uppercase tracking-wider">Faculty Portal</p>
          </div>
        </div>
        <button
          onClick={handleLogout}
          className="flex items-center gap-3 px-4 py-3 w-full rounded-xl text-primary-200 hover:bg-red-500/10 hover:text-red-400 transition-all duration-200"
        >
          <LogOut className="h-5 w-5" />
          <span className="font-medium">Sign Out</span>
        </button>
      </div>
    </>
  );

  return (
    <div className="min-h-screen bg-gray-50 flex overflow-hidden">
      {/* Desktop Sidebar */}
      <div className="hidden lg:flex w-72 bg-primary-900 text-white flex-col shadow-2xl z-20">
        <SidebarContent />
      </div>

      {/* Mobile Drawer Overlay */}
      {isMobileMenuOpen && (
        <div 
          className="fixed inset-0 bg-primary-950/60 backdrop-blur-sm z-40 lg:hidden transition-opacity duration-300"
          onClick={() => setIsMobileMenuOpen(false)}
        />
      )}

      {/* Mobile Drawer Sidebar */}
      <div className={`fixed inset-y-0 left-0 w-72 bg-primary-900 text-white flex flex-col z-50 lg:hidden transform transition-transform duration-300 ease-in-out ${
        isMobileMenuOpen ? 'translate-x-0 shadow-2xl' : '-translate-x-full'
      }`}>
        <div className="absolute top-4 right-4 lg:hidden">
          <button onClick={() => setIsMobileMenuOpen(false)} className="p-2 text-white/50 hover:text-white transition-colors">
            <X className="h-6 w-6" />
          </button>
        </div>
        <SidebarContent />
      </div>

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col h-screen overflow-hidden min-w-0">
        <header className="bg-white/80 backdrop-blur-md shadow-sm border-b px-4 lg:px-8 py-4 flex justify-between items-center z-30">
          <div className="flex items-center gap-2 sm:gap-4 min-w-0">
            <button 
              onClick={() => setIsMobileMenuOpen(true)}
              className="lg:hidden p-2 rounded-lg hover:bg-gray-100 transition-colors flex-shrink-0"
            >
              <Menu className="h-6 w-6 text-gray-600" />
            </button>
            <h2 className="text-base sm:text-lg lg:text-xl font-bold text-gray-800 truncate">
              {location.pathname === '/' ? 'Submissions Overview' : 'Requirement Evaluation'}
            </h2>
          </div>
          <div className="flex items-center gap-2 sm:gap-4 flex-shrink-0">
            {location.pathname.startsWith('/evaluation/') && (
              <div className="relative">
                <button
                  onClick={() => setIsGuidelinesOpen(!isGuidelinesOpen)}
                  className="flex items-center gap-1.5 sm:gap-2 px-2.5 py-1.5 sm:px-3 bg-primary-50 text-primary-700 hover:bg-primary-100 border border-primary-200 rounded-lg text-xs sm:text-sm font-bold shadow-sm transition duration-150 cursor-pointer"
                >
                  <FileText className="h-4 w-4 flex-shrink-0" />
                  <span className="hidden sm:inline">Guidelines PDFs</span>
                  <span className="inline sm:hidden">Guidelines</span>
                  <ChevronDown className={`h-4 w-4 transition-transform duration-200 flex-shrink-0 ${isGuidelinesOpen ? 'rotate-180' : ''}`} />
                </button>
                {isGuidelinesOpen && (
                  <>
                    <div 
                      className="fixed inset-0 z-40" 
                      onClick={() => setIsGuidelinesOpen(false)}
                    />
                    <div className="absolute right-0 mt-2 w-[calc(100vw-2rem)] sm:w-80 bg-white rounded-xl shadow-xl border border-gray-100 py-2 z-50 animate-in fade-in slide-in-from-top-2 duration-150">
                      <div className="px-4 py-2 text-xs font-extrabold text-gray-400 uppercase tracking-widest border-b border-gray-100 pb-2 mb-1">
                        Select a Guideline PDF
                      </div>
                      <div className="max-h-80 overflow-y-auto">
                        {guidelinesPdfs.map((pdf, idx) => (
                          <button
                            key={idx}
                            onClick={() => {
                              window.open(pdf.file, '_blank');
                              setIsGuidelinesOpen(false);
                            }}
                            className="w-full text-left px-4 py-2.5 text-xs font-semibold text-gray-700 hover:bg-primary-50 hover:text-primary-900 transition duration-150 flex items-start gap-2 border-b border-gray-50/50 last:border-0 cursor-pointer"
                          >
                            <FileText className="h-4 w-4 text-primary-500 mt-0.5 flex-shrink-0" />
                            <span className="leading-tight">{pdf.name}</span>
                          </button>
                        ))}
                      </div>
                    </div>
                  </>
                )}
              </div>
            )}
            <div className="hidden sm:block text-xs font-bold text-primary-600 uppercase tracking-widest bg-primary-50 px-3 py-1.5 rounded-full border border-primary-100">
              Faculty Panel
            </div>
          </div>
        </header>
        
        <main className="flex-1 overflow-auto bg-[#F8FAFC]">
          <div className="max-w-[1600px] mx-auto p-4 lg:p-8">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
}
