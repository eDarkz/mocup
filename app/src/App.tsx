import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import { ProtectedRoute } from './components/ProtectedRoute';
import { Login } from './pages/Login';
import { Home } from './pages/Home';
import { SaasDashboard } from './pages/saas/Dashboard';
import { EmpresaDashboard } from './pages/empresa/Dashboard';

function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route
            path="/"
            element={
              <ProtectedRoute>
                <Home />
              </ProtectedRoute>
            }
          />
          <Route
            path="/saas"
            element={
              <ProtectedRoute allowedRoles={['saas_admin']}>
                <SaasDashboard />
              </ProtectedRoute>
            }
          />
          <Route
            path="/empresa"
            element={
              <ProtectedRoute allowedRoles={['company_admin']}>
                <EmpresaDashboard />
              </ProtectedRoute>
            }
          />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  );
}

export default App;
