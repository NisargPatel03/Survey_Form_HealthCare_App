import React, { createContext, useContext, useEffect, useState } from 'react';
import { supabase } from '../services/supabase';

const AuthContext = createContext({});

export const useAuth = () => useContext(AuthContext);

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        // Check active sessions and sets the user
        supabase.auth.getSession().then(({ data: { session } }) => {
            setUser(session?.user ?? null);
            setLoading(false);
        });

        // Listen for changes on auth state (signed in, signed out, etc.)
        const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
            setUser(session?.user ?? null);
            setLoading(false);
        });

        return () => subscription.unsubscribe();
    }, []);

    const formatDobToPassword = (dob) => {
        // Assuming dob is in YYYY-MM-DD from input type="date"
        // We want DDMMYYYY
        if (!dob) return '';
        const parts = dob.split('-');
        if (parts.length !== 3) return dob; // Fallback
        return `${parts[2]}${parts[1]}${parts[0]}`;
    };

    const login = async (email, dob) => {
        const password = formatDobToPassword(dob);
        return supabase.auth.signInWithPassword({ email, password });
    };

    const signup = async (email, dob, fullName) => {
        const password = formatDobToPassword(dob);
        return supabase.auth.signUp({
            email,
            password,
            options: {
                data: { full_name: fullName },
                emailRedirectTo: `${window.location.origin}/`,
            },
        });
    };

    const logout = () => {
        return supabase.auth.signOut();
    };

    const value = {
        user,
        login,
        signup,
        logout,
        loading,
    };

    return (
        <AuthContext.Provider value={value}>
            {!loading && children}
        </AuthContext.Provider>
    );
};
