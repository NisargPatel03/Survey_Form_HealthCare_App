import { useState } from 'react';
import { supabase } from '../services/supabase';
import { UserPlus, Mail, Lock, User, Calendar } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';

export default function Signup() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [fullName, setFullName] = useState('');
  const [dob, setDob] = useState(''); // Format: YYYY-MM-DD from input
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);

  const handleSignup = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    // Convert YYYY-MM-DD to DDMMYYYY for password
    const dateParts = dob.split('-');
    if (dateParts.length !== 3) {
      setError('Please select a valid Date of Birth');
      setLoading(false);
      return;
    }
    const password = `${dateParts[2]}${dateParts[1]}${dateParts[0]}`;

    try {
      // 1. Sign up user in Supabase Auth
      const { data, error: signupError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            full_name: fullName,
          }
        }
      });

      if (signupError) throw signupError;

      if (data.user) {
        // 2. Create profile in 'profiles' table
        const { error: profileError } = await supabase
          .from('profiles')
          .insert([
            { 
              id: data.user.id, 
              full_name: fullName, 
              role: 'faculty' 
            }
          ]);

        if (profileError) throw profileError;
        
        setSuccess(true);
        setTimeout(() => navigate('/login'), 3000);
      }
    } catch (error) {
      setError(error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen w-screen flex items-center justify-center bg-gray-50 px-4 py-12">
      <div className="max-w-md w-full space-y-8 bg-white p-10 rounded-2xl shadow-xl border border-gray-100">
        <div className="text-center">
          <div className="mx-auto h-40 w-40 p-4 bg-white rounded-full shadow-2xl border-4 border-gray-50 flex items-center justify-center overflow-hidden mb-8 ring-8 ring-primary-50">
            <img src="/logo.jpg" alt="Logo" className="h-full w-full object-contain mix-blend-multiply" />
          </div>
          <h2 className="text-4xl font-black text-gray-900 tracking-tight">
            Faculty Registration
          </h2>
          <p className="mt-2 text-xs text-primary-600 font-black uppercase tracking-[0.2em]">
            Community Health Care
          </p>
        </div>
        
        <form className="mt-8 space-y-6" onSubmit={handleSignup}>
          {error && (
            <div className="bg-red-50 text-red-700 p-3 rounded-lg text-sm border border-red-100 animate-pulse">
              {error}
            </div>
          )}

          {success && (
            <div className="bg-green-50 text-green-700 p-4 rounded-lg text-sm border border-green-100">
              Registration successful! Redirecting to login...
            </div>
          )}
          
          <div className="rounded-md shadow-sm space-y-4">
            <div className="relative">
              <User className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
              <input
                type="text"
                required
                className="appearance-none rounded-lg relative block w-full px-10 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm"
                placeholder="Full Name"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
              />
            </div>
            
            <div className="relative">
              <Mail className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
              <input
                type="email"
                required
                className="appearance-none rounded-lg relative block w-full px-10 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm"
                placeholder="Email address"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>

            <div className="space-y-1">
              <label className="text-xs font-semibold text-gray-500 ml-1">Date of Birth (Used as Password)</label>
              <div className="relative">
                <Calendar className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="date"
                  required
                  className="appearance-none rounded-lg relative block w-full px-10 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm"
                  value={dob}
                  onChange={(e) => setDob(e.target.value)}
                />
              </div>
              <p className="text-[10px] text-gray-400 ml-1 mt-1 italic">
                Your password will be generated automatically as DDMMYYYY from your DOB.
              </p>
            </div>
          </div>

          <div>
            <button
              type="submit"
              disabled={loading || success}
              className="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 transition-all disabled:opacity-50 active:scale-95"
            >
              {loading ? 'Registering...' : 'Create Account'}
            </button>
          </div>

          <div className="text-center">
            <Link to="/login" className="text-sm text-primary-600 hover:text-primary-500 font-medium">
              Already have an account? Sign In
            </Link>
          </div>
        </form>
      </div>
    </div>
  );
}
