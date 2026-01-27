import React, { useMemo } from 'react';
import { MapContainer, TileLayer, Marker, Popup, CircleMarker } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import { useSurveys } from '../hooks/useSurveys';
import L from 'leaflet';

// Fix Leaflet Default Icon
import icon from 'leaflet/dist/images/marker-icon.png';
import iconShadow from 'leaflet/dist/images/marker-shadow.png';

let DefaultIcon = L.icon({
    iconUrl: icon,
    shadowUrl: iconShadow,
    iconSize: [25, 41],
    iconAnchor: [12, 41]
});

L.Marker.prototype.options.icon = DefaultIcon;

// Mock Coordinate Generator (Centered roughly on Anand/Gujarat for demo)
// In production, this would use real GPS from the survey
const generateMockCoords = (seedUser) => {
    // Base: 22.5645° N, 72.9289° E (Anand, Gujarat)
    const latBase = 22.5645;
    const lngBase = 72.9289;

    // Deterministic random based on ID (for consistency)
    const idStr = String(seedUser.id);
    const offsetLat = (idStr.charCodeAt(idStr.length - 1) % 100 - 50) / 1000;
    const offsetLng = (idStr.charCodeAt(0) % 100 - 50) / 1000;

    return [latBase + offsetLat, lngBase + offsetLng];
};

const MapHealth = () => {
    const { surveys, loading, error } = useSurveys();

    const markers = useMemo(() => {
        if (!surveys) return [];
        return surveys.map(s => {
            const coords = generateMockCoords(s);

            // Determine Color based on Risk
            const data = s.data || {};
            let color = 'green';
            if (data.openAirDefecation) color = 'red';
            else if (data.houseType === 'Kutcha') color = 'orange';

            return {
                id: s.id,
                position: coords,
                head: data.headOfFamily || 'Unknown',
                area: data.areaName,
                riskColor: color,
                defecation: data.openAirDefecation ? 'Yes' : 'No'
            };
        });
    }, [surveys]);

    if (loading) return <div className="p-8 text-center text-gray-500">Loading Map Data...</div>;
    if (error) return <div className="p-8 text-center text-red-500">Error: {error}</div>;

    return (
        <div className="h-[calc(100vh-100px)] relative rounded-xl overflow-hidden border border-gray-300 shadow-md">

            {/* Legend Overlay */}
            <div className="absolute top-4 right-4 z-[1000] bg-white p-4 rounded shadow-lg text-sm">
                <h4 className="font-bold mb-2">Sanitation Risk Map</h4>
                <div className="flex items-center mb-1"><span className="w-3 h-3 rounded-full bg-green-500 mr-2"></span> Low Risk</div>
                <div className="flex items-center mb-1"><span className="w-3 h-3 rounded-full bg-orange-500 mr-2"></span> Moderate (Kutcha House)</div>
                <div className="flex items-center"><span className="w-3 h-3 rounded-full bg-red-500 mr-2"></span> High (Open Defecation)</div>
            </div>

            <MapContainer center={[22.5645, 72.9289]} zoom={13} scrollWheelZoom={true} style={{ height: '100%', width: '100%' }}>
                <TileLayer
                    attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                />

                {markers.map((m) => (
                    <CircleMarker
                        key={m.id}
                        center={m.position}
                        radius={8}
                        pathOptions={{ color: m.riskColor, fillColor: m.riskColor, fillOpacity: 0.7 }}
                    >
                        <Popup>
                            <div className="text-sm">
                                <strong>{m.head}</strong><br />
                                Area: {m.area}<br />
                                Open Defecation: {m.defecation}
                            </div>
                        </Popup>
                    </CircleMarker>
                ))}
            </MapContainer>
        </div>
    );
};

export default MapHealth;
