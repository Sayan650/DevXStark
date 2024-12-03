import React from 'react';

const stats = [
  { label: 'Market Cap', value: '$2.5M' },
  { label: '24h Change', value: '+15.3%' },
  { label: 'Total Value Locked', value: '$1.8M' },
  { label: 'Hidden Score', value: '89.5' },
  { label: 'Lifetime Performance', value: '+125.4%' },
  { label: 'Intelligence', value: '95.2' },
];

export function Stats() {
  return (
    <div className="grid grid-cols-6 gap-4 mb-8">
      {stats.map((stat) => (
        <div key={stat.label} className="bg-white/5 backdrop-blur-lg rounded-lg p-4">
          <p className="text-sm text-gray-400">{stat.label}</p>
          <p className="text-lg font-medium text-white">{stat.value}</p>
        </div>
      ))}
    </div>
  );
}