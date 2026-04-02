import { useState } from 'react';
import type { FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';

export function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const { signIn } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      await signIn(email, password);
      navigate('/');
    } catch (err) {
      setError('Credenciales inválidas. Por favor intenta de nuevo.');
    } finally {
      setLoading(false);
    }
  };

  const demoAccounts = [
    { email: 'saas@demo.com', password: 'demo', role: 'SaaS Admin' },
    { email: 'empresa@demo.com', password: 'demo', role: 'Empresa Admin' },
    { email: 'super@demo.com', password: 'demo', role: 'Supervisión' },
    { email: 'tecnico@demo.com', password: 'demo', role: 'Operativo' },
    { email: 'cliente@demo.com', password: 'demo', role: 'Cliente' },
  ];

  return (
    <div className="min-h-screen flex">
      <div className="flex-1 flex items-center justify-center px-4 sm:px-6 lg:px-8">
        <div className="max-w-md w-full space-y-8">
          <div className="text-center">
            <div className="text-6xl mb-4">🛡️</div>
            <h2 className="text-3xl font-bold text-white mb-2">FumiControl</h2>
            <p className="text-slate-400">Sistema de Gestión de Fumigación</p>
          </div>

          <div className="bg-slate-800/70 backdrop-blur-sm border border-slate-700/50 rounded-xl p-8">
            <div className="mb-6">
              <h3 className="text-xl font-semibold text-white mb-1">Bienvenido de nuevo</h3>
              <p className="text-slate-400 text-sm">Ingresa tus credenciales para acceder</p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              <Input
                type="email"
                label="Correo electrónico"
                placeholder="tu@empresa.com"
                icon="📧"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />

              <Input
                type="password"
                label="Contraseña"
                placeholder="••••••••"
                icon="🔒"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />

              {error && (
                <div className="bg-red-500/10 border border-red-500/50 rounded-lg p-3 text-red-400 text-sm">
                  {error}
                </div>
              )}

              <Button type="submit" fullWidth loading={loading}>
                Iniciar Sesión
              </Button>
            </form>

            <div className="mt-6 pt-6 border-t border-slate-700/50">
              <p className="text-xs text-slate-500 mb-3 text-center">Cuentas de demostración:</p>
              <div className="grid grid-cols-2 gap-2">
                {demoAccounts.map((account) => (
                  <button
                    key={account.email}
                    onClick={() => {
                      setEmail(account.email);
                      setPassword(account.password);
                    }}
                    className="text-xs bg-slate-700/50 hover:bg-slate-700 text-slate-300 px-3 py-2 rounded-md transition-colors"
                  >
                    {account.role}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="hidden lg:block flex-1 bg-gradient-to-br from-primary-600 to-primary-800 p-12">
        <div className="h-full flex flex-col justify-center text-white">
          <h2 className="text-4xl font-bold mb-6">Control total de tu negocio de fumigación</h2>
          <p className="text-xl text-primary-100 mb-12">
            La plataforma más completa para gestionar hoteles, casas, negocios y todo tipo de fumigaciones.
          </p>
          <div className="space-y-6">
            <div className="flex items-start gap-4">
              <div className="text-4xl">🏨</div>
              <div>
                <h3 className="text-lg font-semibold mb-1">Gestión de Locaciones</h3>
                <p className="text-primary-100">Administra hoteles, casas y negocios con todas sus áreas.</p>
              </div>
            </div>
            <div className="flex items-start gap-4">
              <div className="text-4xl">📊</div>
              <div>
                <h3 className="text-lg font-semibold mb-1">Reportes Detallados</h3>
                <p className="text-primary-100">Genera reportes profesionales de cada fumigación.</p>
              </div>
            </div>
            <div className="flex items-start gap-4">
              <div className="text-4xl">👥</div>
              <div>
                <h3 className="text-lg font-semibold mb-1">Múltiples Usuarios</h3>
                <p className="text-primary-100">Administradores, supervisores y agentes.</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
