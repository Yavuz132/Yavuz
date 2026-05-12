import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import AdminLayout from '@/components/layout/AdminLayout';
import { api, isLoggedIn } from '@/services/api';

export default function MatchesPage() {
  const router = useRouter();
  const [matches, setMatches] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchMatches = () => {
    api.get('/admin/matches').then((r) => { setMatches(r.data); setLoading(false); });
  };

  useEffect(() => {
    if (!isLoggedIn()) { router.push('/admin/login'); return; }
    fetchMatches();
  }, []);

  const handleDelete = async (id: number) => {
    if (!confirm('Delete this match?')) return;
    await api.delete(`/admin/matches/${id}`);
    fetchMatches();
  };

  return (
    <AdminLayout>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
        <h1 style={{ color: '#fff', fontSize: 22, fontWeight: 700 }}>Matches</h1>
        <button onClick={() => router.push('/admin/matches/new')}
          style={{ padding: '8px 18px', background: '#00C896', border: 'none', borderRadius: 8, color: '#000', fontWeight: 600, cursor: 'pointer' }}>
          + New Match
        </button>
      </div>

      {loading ? <p style={{ color: '#8BA7BE' }}>Loading...</p> : (
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 14 }}>
            <thead>
              <tr style={{ borderBottom: '1px solid #253D56' }}>
                {['ID', 'Home', 'Away', 'League', 'Date', 'Status', 'Data Score', 'Actions'].map((h) => (
                  <th key={h} style={{ textAlign: 'left', padding: '10px 12px', color: '#8BA7BE', fontWeight: 600 }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {matches.map((m) => (
                <tr key={m.id} style={{ borderBottom: '1px solid #1A2D42' }}>
                  <td style={{ padding: '10px 12px', color: '#8BA7BE' }}>{m.id}</td>
                  <td style={{ padding: '10px 12px', color: '#fff' }}>{m.homeTeam?.name}</td>
                  <td style={{ padding: '10px 12px', color: '#fff' }}>{m.awayTeam?.name}</td>
                  <td style={{ padding: '10px 12px', color: '#8BA7BE' }}>{m.league?.name}</td>
                  <td style={{ padding: '10px 12px', color: '#8BA7BE' }}>{new Date(m.matchDate).toLocaleDateString()}</td>
                  <td style={{ padding: '10px 12px' }}>
                    <span style={{ padding: '2px 8px', background: 'rgba(0,200,150,0.15)', borderRadius: 4, color: '#00C896', fontSize: 12 }}>{m.status}</span>
                  </td>
                  <td style={{ padding: '10px 12px', color: '#FFD166' }}>{m.dataScore}/100</td>
                  <td style={{ padding: '10px 12px' }}>
                    <button onClick={() => router.push(`/admin/matches/${m.id}/edit`)}
                      style={{ marginRight: 8, padding: '4px 10px', background: 'rgba(255,209,102,0.15)', border: 'none', borderRadius: 6, color: '#FFD166', cursor: 'pointer', fontSize: 12 }}>
                      Edit
                    </button>
                    <button onClick={() => handleDelete(m.id)}
                      style={{ padding: '4px 10px', background: 'rgba(239,71,111,0.15)', border: 'none', borderRadius: 6, color: '#EF476F', cursor: 'pointer', fontSize: 12 }}>
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </AdminLayout>
  );
}
