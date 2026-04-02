import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

export function Home() {
  const { user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (user?.role) {
      switch (user.role) {
        case 'saas_admin':
          navigate('/saas');
          break;
        case 'company_admin':
          navigate('/empresa');
          break;
        case 'supervisor':
          navigate('/supervision');
          break;
        case 'technician':
          navigate('/operativo');
          break;
        case 'client':
          navigate('/cliente');
          break;
        default:
          navigate('/login');
      }
    }
  }, [user, navigate]);

  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <div className="text-6xl mb-4">🛡️</div>
        <div className="text-white text-xl">Cargando...</div>
      </div>
    </div>
  );
}
