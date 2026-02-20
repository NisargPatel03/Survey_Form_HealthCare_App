import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import ProtectedRoute from './components/ProtectedRoute';
import Login from './pages/Login';

import Dashboard from './pages/Dashboard';
import Analytics from './pages/Analytics';
import FamilyDirectory from './pages/FamilyDirectory';
import Export from './pages/Export';
import MapHealth from './pages/MapHealth';
import SurveyorAnalytics from './pages/SurveyorAnalytics';

function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/" element={
        <ProtectedRoute>
          <Layout />
        </ProtectedRoute>
      }>
        <Route index element={<Dashboard />} />
        <Route path="analytics" element={<Analytics />} />
        <Route path="operations" element={<SurveyorAnalytics />} />
        <Route path="map" element={<MapHealth />} />
        <Route path="families" element={<FamilyDirectory />} />
        <Route path="export" element={<Export />} />
      </Route>
    </Routes>
  );
}

export default App;
