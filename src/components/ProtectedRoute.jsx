import { Navigate } from 'react-router-dom';
import { useAuth } from '../lib/AuthContext';

export default function ProtectedRoute({ children }) {
  const { session, loading } = useAuth();
  if (loading) return <p style={{ textAlign: 'center', marginTop: '4rem' }}>Loading…</p>;
  if (!session) return <Navigate to="/login" replace />;
  return children;
}
