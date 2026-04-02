import { Link, useLocation } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';

interface NavItem {
  icon: string;
  label: string;
  path: string;
  badge?: string | number;
}

interface NavSection {
  title: string;
  items: NavItem[];
}

interface SidebarProps {
  sections: NavSection[];
  companyName?: string;
  companySubtitle?: string;
}

export function Sidebar({ sections, companyName = 'FumiControl', companySubtitle }: SidebarProps) {
  const location = useLocation();
  const { user, signOut } = useAuth();

  const isActive = (path: string) => location.pathname === path;

  return (
    <aside className="w-[280px] bg-slate-900/80 backdrop-blur-sm border-r border-slate-800 flex flex-col h-screen sticky top-0">
      <div className="p-6 border-b border-slate-800">
        <div className="flex items-center gap-3 mb-2">
          <div className="text-3xl">🛡️</div>
          <h1 className="text-xl font-bold text-white">{companyName}</h1>
        </div>
        {companySubtitle && (
          <p className="text-sm text-slate-400 ml-11">{companySubtitle}</p>
        )}
      </div>

      <nav className="flex-1 overflow-y-auto p-4 space-y-6">
        {sections.map((section, idx) => (
          <div key={idx}>
            <div className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-3 px-3">
              {section.title}
            </div>
            <div className="space-y-1">
              {section.items.map((item) => (
                <Link
                  key={item.path}
                  to={item.path}
                  className={`
                    flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200
                    ${
                      isActive(item.path)
                        ? 'bg-primary-600 text-white shadow-lg shadow-primary-600/30'
                        : 'text-slate-400 hover:text-white hover:bg-slate-800/50'
                    }
                  `.trim().replace(/\s+/g, ' ')}
                >
                  <span className="text-lg">{item.icon}</span>
                  <span className="flex-1">{item.label}</span>
                  {item.badge && (
                    <span className="px-2 py-0.5 text-xs bg-primary-500/20 text-primary-400 rounded-full">
                      {item.badge}
                    </span>
                  )}
                </Link>
              ))}
            </div>
          </div>
        ))}
      </nav>

      <div className="p-4 border-t border-slate-800">
        <div className="flex items-center gap-3 p-3 bg-slate-800/50 rounded-lg">
          <div className="w-10 h-10 bg-primary-600 rounded-full flex items-center justify-center text-white font-semibold">
            {user?.first_name?.[0]}{user?.last_name?.[0]}
          </div>
          <div className="flex-1 min-w-0">
            <div className="text-sm font-medium text-white truncate">
              {user?.first_name} {user?.last_name}
            </div>
            <div className="text-xs text-slate-400 truncate capitalize">
              {user?.role?.replace('_', ' ')}
            </div>
          </div>
          <button
            onClick={() => signOut()}
            className="text-slate-400 hover:text-white transition-colors"
            title="Cerrar sesión"
          >
            🚪
          </button>
        </div>
      </div>
    </aside>
  );
}
