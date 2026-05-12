import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import AdminLayout from '@/components/layout/AdminLayout';
import { api, isLoggedIn } from '@/services/api';

export default function UsersPage() {
  const router = useRouter();
  const [users, setUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!isLoggedIn()) { router.push('/admin/login'); return; }
    api.get('/admin/users').then((r) => { setUsers(r.data); setLoading(false); });
  }, []);

  const addCredits = async (userId: number) => {
    const amount = prompt('Credits to add:');
    if (!amount || isNaN(Number(amount))) return;
    await api.post(`/admin/users/${userId}/add-credits`, { amount: Number(amount) });
    alert('Credits added!');
  };

  const activateSub = async (userId: number) => {
    const pkg = prompt('Package ID (weekly_pro / monthly_pro / elite):');
    if (!pkg) return;
    try {
      await api.post(`/admin/users/${userId}/activate-subscription`, { packageId: pkg });
      alert('Subscription activated!');
    } catch (e: any) {
      alert(e.response?.data?.message ?? 'Error');
    }
  };

  return (
    <AdminLayout>
      <h1 style={{ color: '#fff', fontSize: 22, fontWeight: 700, marginBottom: 24 }}>Users</h1>

      {loading ? <p style={{ color: '#8BA7BE' }}>Loading...</p> : (
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 14 }}>
            <thead>
              <tr style={{ borderBottom: '1px solid #253D56' }}>
                {['ID', 'Name', 'Email', 'Credits', 'Subscription', 'Joined', 'Actions'].map((h) => (
                  <th key={h} style={{ textAlign: 'left', padding: '10px 12px', color: '#8BA7BE', fontWeight: 600 }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {users.map((u) => (
                <tr key={u.id} style={{ borderBottom: '1px solid #1A2D42' }}>
                  <td style={{ padding: '10px 12px', color: '#8BA7BE' }}>{u.id}</td>
                  <td style={{ padding: '10px 12px', color: '#fff' }}>{u.name}</td>
                  <td style={{ padding: '10px 12px', color: '#8BA7BE' }}>{u.email}</td>
                  <td style={{ padding: '10px 12px', color: '#00C896', fontWeight: 600 }}>{u.creditBalance}</td>
                  <td style={{ padding: '10px 12px', color: u.subscription?.status === 'ACTIVE' ? '#FFD166' : '#8BA7BE' }}>
                    {u.subscription?.status === 'ACTIVE' ? u.subscription.packageName : 'Free'}
                  </td>
                  <td style={{ padding: '10px 12px', color: '#8BA7BE' }}>{new Date(u.createdAt).toLocaleDateString()}</td>
                  <td style={{ padding: '10px 12px' }}>
                    <button onClick={() => addCredits(u.id)}
                      style={{ marginRight: 6, padding: '4px 10px', background: 'rgba(0,200,150,0.15)', border: 'none', borderRadius: 6, color: '#00C896', cursor: 'pointer', fontSize: 12 }}>
                      + Credits
                    </button>
                    <button onClick={() => activateSub(u.id)}
                      style={{ padding: '4px 10px', background: 'rgba(255,209,102,0.15)', border: 'none', borderRadius: 6, color: '#FFD166', cursor: 'pointer', fontSize: 12 }}>
                      Activate Sub
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
