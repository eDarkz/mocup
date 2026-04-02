import { MainLayout } from '../../components/layout/MainLayout';
import { PageHeader } from '../../components/layout/PageHeader';
import { StatCard } from '../../components/ui/StatCard';
import { Card, CardHeader, CardBody } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';

const saasNavSections = [
  {
    title: 'Principal',
    items: [
      { icon: '📊', label: 'Dashboard', path: '/saas' },
      { icon: '📈', label: 'Analytics', path: '/saas/analytics' },
    ],
  },
  {
    title: 'Gestión',
    items: [
      { icon: '🏢', label: 'Empresas', path: '/saas/empresas', badge: 24 },
      { icon: '💳', label: 'Suscripciones', path: '/saas/suscripciones' },
      { icon: '🎧', label: 'Soporte', path: '/saas/soporte' },
    ],
  },
  {
    title: 'Sistema',
    items: [
      { icon: '🚩', label: 'Feature Flags', path: '/saas/feature-flags' },
      { icon: '📜', label: 'Auditoría', path: '/saas/auditoria' },
      { icon: '💾', label: 'Backups', path: '/saas/backups' },
      { icon: '⚙️', label: 'Configuración', path: '/saas/configuracion' },
    ],
  },
];

export function SaasDashboard() {
  return (
    <MainLayout
      sections={saasNavSections}
      companyName="FumiControl"
      companySubtitle="Super Administrador"
    >
      <PageHeader
        title="📊 Dashboard Global SaaS"
        subtitle="Vista general de todo el sistema FumiControl"
        actions={
          <select className="px-4 py-2 bg-slate-800 border border-slate-700 rounded-lg text-white">
            <option>Este mes</option>
            <option>Último trimestre</option>
            <option>Este año</option>
          </select>
        }
      />

      <div className="p-8 space-y-8">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <StatCard
            icon="💰"
            value="$128,450"
            label="Ingresos Mensuales"
            trend={{ value: '12% vs mes anterior', positive: true }}
            color="purple"
          />
          <StatCard
            icon="🏢"
            value="47"
            label="Empresas Activas"
            trend={{ value: '3 nuevas este mes', positive: true }}
            color="blue"
          />
          <StatCard
            icon="👥"
            value="312"
            label="Usuarios Totales"
            trend={{ value: '8% crecimiento', positive: true }}
            color="green"
          />
          <StatCard
            icon="📍"
            value="1,847"
            label="Locaciones Registradas"
            trend={{ value: '156 nuevas', positive: true }}
            color="yellow"
          />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <StatCard icon="🔫" value="23,456" label="Fumigaciones Este Mes" />
          <StatCard icon="🪤" value="12,340" label="Cebaderas Activas" />
          <StatCard icon="💡" value="3,210" label="Trampas de Luz" />
          <StatCard icon="✅" value="99.8%" label="Uptime del Sistema" color="green" />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <Card>
            <CardHeader title="Empresas Recientes" action={<Button variant="ghost" size="sm">Ver todas →</Button>} />
            <CardBody>
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead>
                    <tr className="text-left border-b border-slate-700">
                      <th className="pb-3 text-sm font-medium text-slate-400">Empresa</th>
                      <th className="pb-3 text-sm font-medium text-slate-400">Plan</th>
                      <th className="pb-3 text-sm font-medium text-slate-400">Usuarios</th>
                      <th className="pb-3 text-sm font-medium text-slate-400">Estado</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-800">
                    <tr>
                      <td className="py-3 text-white font-medium">Fumigaciones López</td>
                      <td className="py-3"><Badge variant="info">Pro</Badge></td>
                      <td className="py-3 text-slate-400">12</td>
                      <td className="py-3"><Badge variant="success">Activo</Badge></td>
                    </tr>
                    <tr>
                      <td className="py-3 text-white font-medium">Control Pest MX</td>
                      <td className="py-3"><Badge variant="info">Enterprise</Badge></td>
                      <td className="py-3 text-slate-400">28</td>
                      <td className="py-3"><Badge variant="success">Activo</Badge></td>
                    </tr>
                    <tr>
                      <td className="py-3 text-white font-medium">Fumigadora del Norte</td>
                      <td className="py-3"><Badge variant="info">Pro</Badge></td>
                      <td className="py-3 text-slate-400">8</td>
                      <td className="py-3"><Badge variant="warning">Pendiente</Badge></td>
                    </tr>
                    <tr>
                      <td className="py-3 text-white font-medium">EcoFumiga</td>
                      <td className="py-3"><Badge>Básico</Badge></td>
                      <td className="py-3 text-slate-400">3</td>
                      <td className="py-3"><Badge variant="success">Activo</Badge></td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </CardBody>
          </Card>

          <Card>
            <CardHeader title="Actividad Reciente" action={<Button variant="ghost" size="sm">Ver todo →</Button>} />
            <CardBody>
              <div className="space-y-4">
                <div className="flex gap-3">
                  <div className="w-8 h-8 bg-green-500/20 text-green-400 rounded-full flex items-center justify-center flex-shrink-0">✓</div>
                  <div className="flex-1">
                    <p className="text-white text-sm"><strong>Fumigaciones López</strong> registró 15 fumigaciones</p>
                    <span className="text-xs text-slate-500">Hace 2 horas</span>
                  </div>
                </div>
                <div className="flex gap-3">
                  <div className="w-8 h-8 bg-blue-500/20 text-blue-400 rounded-full flex items-center justify-center flex-shrink-0">+</div>
                  <div className="flex-1">
                    <p className="text-white text-sm">Nueva empresa: <strong>EcoFumiga</strong></p>
                    <span className="text-xs text-slate-500">Hace 5 horas</span>
                  </div>
                </div>
                <div className="flex gap-3">
                  <div className="w-8 h-8 bg-yellow-500/20 text-yellow-400 rounded-full flex items-center justify-center flex-shrink-0">⚡</div>
                  <div className="flex-1">
                    <p className="text-white text-sm"><strong>Control Pest MX</strong> actualizó a plan Enterprise</p>
                    <span className="text-xs text-slate-500">Hace 1 día</span>
                  </div>
                </div>
                <div className="flex gap-3">
                  <div className="w-8 h-8 bg-green-500/20 text-green-400 rounded-full flex items-center justify-center flex-shrink-0">✓</div>
                  <div className="flex-1">
                    <p className="text-white text-sm"><strong>Fumigadora del Norte</strong> agregó 45 locaciones</p>
                    <span className="text-xs text-slate-500">Hace 2 días</span>
                  </div>
                </div>
              </div>
            </CardBody>
          </Card>
        </div>
      </div>
    </MainLayout>
  );
}
