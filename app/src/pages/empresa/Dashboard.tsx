import { MainLayout } from '../../components/layout/MainLayout';
import { PageHeader } from '../../components/layout/PageHeader';
import { StatCard } from '../../components/ui/StatCard';
import { Card, CardHeader, CardBody } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';

const empresaNavSections = [
  {
    title: 'Principal',
    items: [
      { icon: '📊', label: 'Dashboard', path: '/empresa' },
      { icon: '📅', label: 'Calendario', path: '/empresa/calendario' },
      { icon: '🗺️', label: 'Rutas', path: '/empresa/rutas' },
    ],
  },
  {
    title: 'Clientes',
    items: [
      { icon: '🤝', label: 'Clientes', path: '/empresa/clientes' },
      { icon: '📍', label: 'Locaciones', path: '/empresa/locaciones' },
      { icon: '📄', label: 'Contratos', path: '/empresa/contratos' },
    ],
  },
  {
    title: 'Operaciones',
    items: [
      { icon: '📝', label: 'Órdenes', path: '/empresa/ordenes', badge: 8 },
      { icon: '🐛', label: 'Catálogo Plagas', path: '/empresa/plagas' },
      { icon: '🧪', label: 'Químicos', path: '/empresa/quimicos' },
      { icon: '📦', label: 'Inventario', path: '/empresa/inventario' },
    ],
  },
  {
    title: 'Recursos',
    items: [
      { icon: '👷', label: 'Técnicos', path: '/empresa/tecnicos' },
      { icon: '🚐', label: 'Vehículos', path: '/empresa/vehiculos' },
    ],
  },
  {
    title: 'Reportes',
    items: [
      { icon: '📊', label: 'Reportes', path: '/empresa/reportes' },
      { icon: '💰', label: 'Facturación', path: '/empresa/facturacion' },
    ],
  },
];

export function EmpresaDashboard() {
  return (
    <MainLayout
      sections={empresaNavSections}
      companyName="FumiControl"
      companySubtitle="Fumigaciones López S.A."
    >
      <PageHeader
        title="📊 Dashboard de Empresa"
        subtitle="Bienvenido. Aquí está el resumen de tu empresa."
        actions={
          <>
            <Button variant="secondary">📥 Exportar</Button>
            <Button variant="primary">+ Nueva Fumigación</Button>
          </>
        }
      />

      <div className="p-8 space-y-8">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <StatCard icon="🏨" value="12" label="Hoteles" color="blue" />
          <StatCard icon="🏠" value="45" label="Casas" color="green" />
          <StatCard icon="🏪" value="23" label="Negocios" color="yellow" />
          <StatCard icon="⏰" value="8" label="Pendientes Hoy" color="red" />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <StatCard icon="👥" value="24" label="Empleados" />
          <StatCard icon="🚐" value="5" label="Vehículos" />
          <StatCard icon="🪤" value="156" label="Cebaderas" />
          <StatCard icon="💡" value="48" label="Trampas Luz" />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <Card>
            <CardHeader title="📅 Fumigaciones de Hoy" action={<Button variant="ghost" size="sm">Ver todas →</Button>} />
            <CardBody>
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead>
                    <tr className="text-left border-b border-slate-700">
                      <th className="pb-3 text-sm font-medium text-slate-400">Hora</th>
                      <th className="pb-3 text-sm font-medium text-slate-400">Locación</th>
                      <th className="pb-3 text-sm font-medium text-slate-400">Agente</th>
                      <th className="pb-3 text-sm font-medium text-slate-400">Estado</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-800">
                    <tr>
                      <td className="py-3 text-slate-400">09:00</td>
                      <td className="py-3 text-white font-medium">Hotel Marriott</td>
                      <td className="py-3 text-slate-400">Carlos R.</td>
                      <td className="py-3"><Badge variant="success">Completada</Badge></td>
                    </tr>
                    <tr>
                      <td className="py-3 text-slate-400">11:00</td>
                      <td className="py-3 text-white font-medium">Casa García</td>
                      <td className="py-3 text-slate-400">María S.</td>
                      <td className="py-3"><Badge variant="warning">En proceso</Badge></td>
                    </tr>
                    <tr>
                      <td className="py-3 text-slate-400">14:00</td>
                      <td className="py-3 text-white font-medium">Rest. La Parilla</td>
                      <td className="py-3 text-slate-400">Pedro M.</td>
                      <td className="py-3"><Badge variant="info">Programada</Badge></td>
                    </tr>
                    <tr>
                      <td className="py-3 text-slate-400">16:00</td>
                      <td className="py-3 text-white font-medium">Hotel Hilton</td>
                      <td className="py-3 text-slate-400">Carlos R.</td>
                      <td className="py-3"><Badge variant="info">Programada</Badge></td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </CardBody>
          </Card>

          <Card>
            <CardHeader title="Alertas y Notificaciones" />
            <CardBody>
              <div className="space-y-4">
                <div className="flex gap-3">
                  <div className="w-8 h-8 bg-red-500/20 text-red-400 rounded-full flex items-center justify-center flex-shrink-0">!</div>
                  <div className="flex-1">
                    <p className="text-white text-sm"><strong>Hotel Marriott</strong> - Cebaderas requieren revisión</p>
                    <span className="text-xs text-slate-500">Vence mañana</span>
                  </div>
                </div>
                <div className="flex gap-3">
                  <div className="w-8 h-8 bg-yellow-500/20 text-yellow-400 rounded-full flex items-center justify-center flex-shrink-0">⚡</div>
                  <div className="flex-1">
                    <p className="text-white text-sm"><strong>Casa Rodríguez</strong> - Fumigación programada</p>
                    <span className="text-xs text-slate-500">En 3 horas</span>
                  </div>
                </div>
                <div className="flex gap-3">
                  <div className="w-8 h-8 bg-blue-500/20 text-blue-400 rounded-full flex items-center justify-center flex-shrink-0">📋</div>
                  <div className="flex-1">
                    <p className="text-white text-sm">5 reportes pendientes de firma</p>
                    <span className="text-xs text-slate-500">Desde ayer</span>
                  </div>
                </div>
                <div className="flex gap-3">
                  <div className="w-8 h-8 bg-green-500/20 text-green-400 rounded-full flex items-center justify-center flex-shrink-0">✓</div>
                  <div className="flex-1">
                    <p className="text-white text-sm"><strong>Rest. La Fogata</strong> - Reporte aprobado</p>
                    <span className="text-xs text-slate-500">Hace 1 hora</span>
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
