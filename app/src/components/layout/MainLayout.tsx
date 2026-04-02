import type { ReactNode } from 'react';
import { Sidebar } from './Sidebar';

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

interface MainLayoutProps {
  children: ReactNode;
  sections: NavSection[];
  companyName?: string;
  companySubtitle?: string;
}

export function MainLayout({ children, sections, companyName, companySubtitle }: MainLayoutProps) {
  return (
    <div className="flex min-h-screen bg-slate-950">
      <Sidebar
        sections={sections}
        companyName={companyName}
        companySubtitle={companySubtitle}
      />
      <main className="flex-1 overflow-auto">
        {children}
      </main>
    </div>
  );
}
