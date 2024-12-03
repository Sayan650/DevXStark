import React from 'react';

interface Column {
  key: string;
  label: string;
}

const columns: Column[] = [
  { key: 'name', label: 'AI agents' },
  { key: 'marketCap', label: 'Market Cap' },
  { key: 'dayChange', label: '1 Day Change' },
  { key: 'totalValue', label: 'Total Value Locked' },
  { key: 'holderCount', label: 'Holder Count' },
  { key: 'lifetime', label: 'Lifetime Inferences' },
  { key: 'intelligence', label: 'Intelligence' },
];

const agents = [
  {
    name: 'Alpha Agent',
    marketCap: '$1.2M',
    dayChange: '+12.3%',
    totalValue: '$800K',
    holderCount: '1,234',
    lifetime: '45.6K',
    intelligence: '98.2',
  },
  {
    name: 'Beta Agent',
    marketCap: '$950K',
    dayChange: '+8.7%',
    totalValue: '$600K',
    holderCount: '987',
    lifetime: '32.1K',
    intelligence: '95.7',
  },
  {
    name: 'Gamma Agent',
    marketCap: '$750K',
    dayChange: '+5.2%',
    totalValue: '$400K',
    holderCount: '756',
    lifetime: '28.9K',
    intelligence: '93.4',
  },
];

export function AgentsTable() {
  return (
    <div className="w-full overflow-x-auto">
      <table className="w-full">
        <thead>
          <tr>
            {columns.map((column) => (
              <th
                key={column.key}
                className="text-left py-3 px-4 text-sm font-medium text-gray-400"
              >
                {column.label}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-white/5">
          {agents.map((agent, index) => (
            <tr
              key={index}
              className="hover:bg-white/5 transition-colors cursor-pointer"
            >
              <td className="py-3 px-4 text-white">{agent.name}</td>
              <td className="py-3 px-4 text-white">{agent.marketCap}</td>
              <td className="py-3 px-4 text-green-400">{agent.dayChange}</td>
              <td className="py-3 px-4 text-white">{agent.totalValue}</td>
              <td className="py-3 px-4 text-white">{agent.holderCount}</td>
              <td className="py-3 px-4 text-white">{agent.lifetime}</td>
              <td className="py-3 px-4 text-white">{agent.intelligence}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}