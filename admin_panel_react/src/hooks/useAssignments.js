import { useState, useEffect } from 'react';
import { supabase } from '../services/supabase';

export const useAssignments = () => {
    const [assignments, setAssignments] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const fetchAssignments = async () => {
        try {
            setLoading(true);
            const { data, error } = await supabase
                .from('survey_assignments')
                .select('*')
                .order('created_at', { ascending: false });

            if (error) {
                throw error;
            }

            setAssignments(data || []);
        } catch (err) {
            console.error("Error fetching assignments:", err);
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchAssignments();
    }, []);

    return { assignments, loading, error, refresh: fetchAssignments };
};
