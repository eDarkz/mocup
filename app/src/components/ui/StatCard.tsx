interface StatCardProps {
  icon: string;
  value: string | number;
  label: string;
  trend?: {
    value: string;
    positive: boolean;
  };
  color?: 'blue' | 'green' | 'yellow' | 'red' | 'purple';
}

export function StatCard({ icon, value, label, trend, color = 'blue' }: StatCardProps) {
  const colorClasses = {
    blue: 'bg-blue-500/10 text-blue-400 border-blue-500/20',
    green: 'bg-green-500/10 text-green-400 border-green-500/20',
    yellow: 'bg-yellow-500/10 text-yellow-400 border-yellow-500/20',
    red: 'bg-red-500/10 text-red-400 border-red-500/20',
    purple: 'bg-purple-500/10 text-purple-400 border-purple-500/20',
  };

  return (
    <div className="bg-slate-800/70 backdrop-blur-sm border border-slate-700/50 rounded-xl p-6 hover:border-primary-500/30 transition-all duration-200">
      <div className="flex items-start justify-between mb-3">
        <div className={`text-3xl p-3 rounded-lg ${colorClasses[color]}`}>
          {icon}
        </div>
      </div>
      <div className="text-3xl font-bold text-white mb-1">{value}</div>
      <div className="text-sm text-slate-400">{label}</div>
      {trend && (
        <div className={`text-xs mt-2 ${trend.positive ? 'text-green-400' : 'text-red-400'}`}>
          {trend.positive ? '↑' : '↓'} {trend.value}
        </div>
      )}
    </div>
  );
}
