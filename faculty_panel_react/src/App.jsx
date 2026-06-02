import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { useState, useEffect } from 'react';
import { supabase } from './services/supabase';
import Login from './pages/Login';
import Signup from './pages/Signup';
import Dashboard from './pages/Dashboard';
import Evaluation from './pages/Evaluation';
import Layout from './components/Layout';

function App() {
  const [session, setSession] = useState(null);
  const [loading, setLoading] = useState(true);
  const [userRole, setUserRole] = useState(null);

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      if (session) fetchUserRole(session.user.id);
      else setLoading(false);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      if (session) fetchUserRole(session.user.id);
      else {
        setUserRole(null);
        setLoading(false);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  const fetchUserRole = async (userId) => {
    setLoading(true);
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single();

      if (error) throw error;
      
      if (data && data.role === 'faculty') {
        setUserRole(data.role);
      } else {
        console.warn('Unauthorized role detected. Access denied.');
        setUserRole(null);
        await supabase.auth.signOut();
        alert('Access Denied: You do not have faculty privileges.');
      }
    } catch (error) {
      console.error('Error fetching role:', error);
      setUserRole(null);
      await supabase.auth.signOut();
      alert('Access Denied: Faculty profile not found. Please register.');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  return (
    <Router>
      <Routes>
        <Route path="/login" element={
          !session ? <Login /> : <Navigate to="/" replace />
        } />
        
        <Route path="/signup" element={
          !session ? <Signup /> : <Navigate to="/" replace />
        } />
        
        <Route element={
          session && userRole === 'faculty' ? <Layout /> : <Navigate to="/login" replace />
        }>
          <Route path="/" element={<Dashboard />} />
          <Route path="/evaluation/:id" element={<Evaluation />} />
        </Route>

        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  );
}

export default App;
