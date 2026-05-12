import { useState } from 'react';
import { useRouter } from 'next/router';
import { adminLogin } from '@/services/api';

export default function AdminLoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      await adminLogin(email, password);
      router.push('/admin/dashboard');
    } catch (err: any) {
      setError(err.response?.data?.message ?? 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ minHeight: '100vh', background: '#0D1B2A', display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: 'Inter, sans-serif' }}>
      <div style={{ background: '#1A2D42', borderRadius: 16, padding: 40, width: 360 }}>
        <div style={{ textAlign: 'center', marginBottom: 32 }}>
          <div style={{ fontSize: 32 }}>📊</div>
          <h1 style={{ color: '#fff', fontSize: 22, fontWeight: 700, margin: '8px 0 4px' }}>MatchIQ Admin</h1>
          <p style={{ color: '#8BA7BE', fontSize: 13 }}>Sign in to manage the platform</p>
        </div>

        {error && (
          <div style={{ background: 'rgba(239,71,111,0.1)', border: '1px solid #EF476F', borderRadius: 8, padding: '10px 14px', color: '#EF476F', fontSize: 13, marginBottom: 16 }}>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div style={{ marginBottom: 16 }}>
            <label style={{ color: '#8BA7BE', fontSize: 12, display: 'block', marginBottom: 6 }}>Email</label>
            <input
              type="email" value={email} onChange={(e) => setEmail(e.target.value)} required
              style={{ width: '100%', padding: '10px 14px', background: '#0D1B2A', border: '1px solid #253D56', borderRadius: 8, color: '#fff', fontSize: 14, boxSizing: 'border-box' }}
            />
          </div>
          <div style={{ marginBottom: 24 }}>
            <label style={{ color: '#8BA7BE', fontSize: 12, display: 'block', marginBottom: 6 }}>Password</label>
            <input
              type="password" value={password} onChange={(e) => setPassword(e.target.value)} required
              style={{ width: '100%', padding: '10px 14px', background: '#0D1B2A', border: '1px solid #253D56', borderRadius: 8, color: '#fff', fontSize: 14, boxSizing: 'border-box' }}
            />
          </div>
          <button
            type="submit" disabled={loading}
            style={{ width: '100%', padding: '12px', background: '#00C896', border: 'none', borderRadius: 8, color: '#000', fontWeight: 600, fontSize: 15, cursor: 'pointer' }}>
            {loading ? 'Signing in...' : 'Sign In'}
          </button>
        </form>
      </div>
    </div>
  );
}
