import { useState, useEffect } from 'react';
import { supabase } from '../services/supabase';

export const useSurveys = () => {
    const [surveys, setSurveys] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const fetchSurveys = async () => {
        try {
            setLoading(true);
            const { data, error } = await supabase
                .from('surveys')
                .select('*')
                .order('created_at', { ascending: false });

            if (error) {
                throw error;
            }

            // Parse the json_content if needed, or just use the columns if they exist
            // Based on Flutter code, detailed data is in 'json_content'
            const parsedData = data.map(item => ({
                ...item,
                data: typeof item.json_content === 'string'
                    ? JSON.parse(item.json_content)
                    : item.json_content
            }));

            setSurveys(parsedData);
        } catch (err) {
            console.error("Error fetching surveys:", err);
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchSurveys();
    }, []);

    return { surveys, loading, error, refresh: fetchSurveys };
};
