'use client';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { adminLogout } from '@/services/api';

const NAV = [
  { href: '/admin/dashboard', label: 'Dashboard', icon: '📊' },
  { href: '/admin/matches', label: 'Matches', icon: '⚽' },
  { href: '/admin/leagues', label: 'Leagues', icon: '🏆' },
  { href: '/admin/teams', label: 'Teams', icon: '🛡️' },
  { href: '/admin/reports', label: 'Reports', icon: '📋' },
  { href: '/admin/users', label: 'Users', icon: '👥' },
  { href: '/admin/notifications', label: 'Notifications', icon: '🔔' },
];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();

  const handleLogout = () => {
    adminLogout();
    router.push('/admin/login');
  };

  return (
    <div style={{ display: 'flex', minHeight: '100vh', background: '#0D1B2A', color: '#fff', fontFamily: 'Inter, sans-serif' }}>
      {/* Sidebar */}
      <aside style={{ width: 220, background: '#1A2D42', display: 'flex', flexDirection: 'column', padding: '24px 0' }}>
        <div style={{ padding: '0 20px 24px', borderBottom: '1px solid #253D56' }}>
          <div style={{ fontSize: 20, fontWeight: 700, color: '#00C896' }}>MatchIQ</div>
          <div style={{ fontSize: 11, color: '#8BA7BE', marginTop: 2 }}>Admin Panel</div>
        </div>
        <nav style={{ flex: 1, padding: '16px 0' }}>
          {NAV.map((item) => (
            <Link key={item.href} href={item.href} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '10px 20px', color: '#8BA7BE', textDecoration: 'none', fontSize: 14, transition: 'color 0.2s' }}
              onMouseOver={(e) => (e.currentTarget.style.color = '#fff')}
              onMouseOut={(e) => (e.currentTarget.style.color = '#8BA7BE')}>
              <span>{item.icon}</span>
              {item.label}
            </Link>
          ))}
        </nav>
        <div style={{ padding: '0 20px', borderTop: '1px solid #253D56', paddingTop: 16 }}>
          <button onClick={handleLogout} style={{ width: '100%', padding: '8px 12px', background: 'transparent', border: '1px solid #EF476F', color: '#EF476F', borderRadius: 8, cursor: 'pointer', fontSize: 13 }}>
            Sign Out
          </button>
        </div>
      </aside>

      {/* Main */}
      <main style={{ flex: 1, padding: 32, overflowY: 'auto' }}>
        {children}
      </main>
    </div>
  );
}
