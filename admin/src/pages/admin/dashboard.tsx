import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import AdminLayout from '@/components/layout/AdminLayout';
import { api, isLoggedIn } from '@/services/api';

interface Stats {
  totalUsers: number;
  totalMatches: number;
  totalReports: number;
  totalUnlocks: number;
}

export default function DashboardPage() {
  const router = useRouter();
  const [stats, setStats] = useState<Stats | null>(null);

  useEffect(() => {
    if (!isLoggedIn()) { router.push('/admin/login'); return; }
    api.get('/admin/dashboard').then((r) => setStats(r.data)).catch(() => router.push('/admin/login'));
  }, []);

  const cards = [
    { label: 'Total Users', value: stats?.totalUsers, icon: '👥', color: '#00C896' },
    { label: 'Total Matches', value: stats?.totalMatches, icon: '⚽', color: '#FFD166' },
    { label: 'Premium Reports', value: stats?.totalReports, icon: '📋', color: '#8B5CF6' },
    { label: 'Report Unlocks', value: stats?.totalUnlocks, icon: '🔓', color: '#EF476F' },
  ];

  return (
    <AdminLayout>
      <h1 style={{ color: '#fff', fontSize: 24, fontWeight: 700, marginBottom: 8 }}>Dashboard</h1>
      <p style={{ color: '#8BA7BE', fontSize: 14, marginBottom: 32 }}>Platform overview</p>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: 16 }}>
        {cards.map((c) => (
          <div key={c.label} style={{ background: '#1E3448', borderRadius: 14, padding: 24, borderLeft: `4px solid ${c.color}` }}>
            <div style={{ fontSize: 28 }}>{c.icon}</div>
            <div style={{ fontSize: 32, fontWeight: 700, color: c.color, marginTop: 8 }}>
              {stats ? c.value : '—'}
            </div>
            <div style={{ color: '#8BA7BE', fontSize: 13, marginTop: 4 }}>{c.label}</div>
          </div>
        ))}
      </div>
    </AdminLayout>
  );
}
