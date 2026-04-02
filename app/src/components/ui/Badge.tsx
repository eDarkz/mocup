interface BadgeProps {
  children: React.ReactNode;
  variant?: 'default' | 'success' | 'warning' | 'danger' | 'info';
  size?: 'sm' | 'md';
}

export function Badge({ children, variant = 'default', size = 'md' }: BadgeProps) {
  const variants = {
    default: 'bg-slate-700 text-slate-300',
    success: 'bg-green-500/15 text-green-400',
    warning: 'bg-yellow-500/15 text-yellow-400',
    danger: 'bg-red-500/15 text-red-400',
    info: 'bg-blue-500/15 text-blue-400',
  };

  const sizes = {
    sm: 'px-2 py-0.5 text-xs',
    md: 'px-2.5 py-1 text-sm',
  };

  return (
    <span
      className={`
        inline-flex items-center font-medium rounded-md
        ${variants[variant]}
        ${sizes[size]}
      `.trim().replace(/\s+/g, ' ')}
    >
      {children}
    </span>
  );
}
