import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import Analytics from './pages/Analytics';
import FamilyDirectory from './pages/FamilyDirectory';
import Export from './pages/Export';
import MapHealth from './pages/MapHealth';

function App() {
  return (
    <Routes>
      <Route path="/" element={<Layout />}>
        <Route index element={<Dashboard />} />
        <Route path="analytics" element={<Analytics />} />
        <Route path="map" element={<MapHealth />} />
        <Route path="families" element={<FamilyDirectory />} />
        <Route path="export" element={<Export />} />
      </Route>
    </Routes>
  );
}

export default App;
