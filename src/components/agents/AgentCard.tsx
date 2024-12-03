import React from 'react';

interface AgentCardProps {
  name: string;
  stats: {
    marketCap: string;
    dayChange: string;
    totalValue: string;
  };
}

export function AgentCard({ name, stats }: AgentCardProps) {
  return (
    <div className="bg-white/5 backdrop-blur-lg rounded-xl p-4 hover:bg-white/10 transition-colors">
      <h3 className="text-lg font-medium text-white mb-3">{name}</h3>
      <div className="grid grid-cols-3 gap-4">
        <div>
          <p className="text-xs text-gray-400">Market Cap</p>
          <p className="text-sm text-white">{stats.marketCap}</p>
        </div>
        <div>
          <p className="text-xs text-gray-400">24h Change</p>
          <p className="text-sm text-green-400">{stats.dayChange}</p>
        </div>
        <div>
          <p className="text-xs text-gray-400">Total Value</p>
          <p className="text-sm text-white">{stats.totalValue}</p>
        </div>
      </div>
    </div>
  );
}