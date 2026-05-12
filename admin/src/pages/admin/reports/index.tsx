import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import AdminLayout from '@/components/layout/AdminLayout';
import { api, isLoggedIn } from '@/services/api';

export default function ReportsPage() {
  const router = useRouter();
  const [reports, setReports] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchReports = () => {
    api.get('/admin/reports').then((r) => { setReports(r.data); setLoading(false); });
  };

  useEffect(() => {
    if (!isLoggedIn()) { router.push('/admin/login'); return; }
    fetchReports();
  }, []);

  const togglePublish = async (r: any) => {
    await api.put(`/admin/reports/${r.id}`, { isPublished: !r.isPublished });
    fetchReports();
  };

  const handleDelete = async (id: number) => {
    if (!confirm('Delete this report?')) return;
    await api.delete(`/admin/reports/${id}`);
    fetchReports();
  };

  const riskColor = (level: string) => ({
    LOW: '#00C896', MEDIUM: '#FFD166', HIGH: '#EF476F', UNCERTAIN: '#8BA7BE',
  }[level] ?? '#8BA7BE');

  return (
    <AdminLayout>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
        <h1 style={{ color: '#fff', fontSize: 22, fontWeight: 700 }}>Premium Reports</h1>
        <button onClick={() => router.push('/admin/reports/new')}
          style={{ padding: '8px 18px', background: '#00C896', border: 'none', borderRadius: 8, color: '#000', fontWeight: 600, cursor: 'pointer' }}>
          + New Report
        </button>
      </div>

      {loading ? <p style={{ color: '#8BA7BE' }}>Loading...</p> : (
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 14 }}>
            <thead>
              <tr style={{ borderBottom: '1px solid #253D56' }}>
                {['ID', 'Title', 'Match', 'Data Score', 'Risk', 'Published', 'Actions'].map((h) => (
                  <th key={h} style={{ textAlign: 'left', padding: '10px 12px', color: '#8BA7BE', fontWeight: 600 }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {reports.map((r) => (
                <tr key={r.id} style={{ borderBottom: '1px solid #1A2D42' }}>
                  <td style={{ padding: '10px 12px', color: '#8BA7BE' }}>{r.id}</td>
                  <td style={{ padding: '10px 12px', color: '#fff', maxWidth: 200, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{r.title}</td>
                  <td style={{ padding: '10px 12px', color: '#8BA7BE' }}>
                    {r.match?.homeTeam?.name} vs {r.match?.awayTeam?.name}
                  </td>
                  <td style={{ padding: '10px 12px', color: '#FFD166' }}>{r.dataScore}/100</td>
                  <td style={{ padding: '10px 12px' }}>
                    <span style={{ color: riskColor(r.riskLevel), fontSize: 12, fontWeight: 600 }}>{r.riskLevel}</span>
                  </td>
                  <td style={{ padding: '10px 12px' }}>
                    <button onClick={() => togglePublish(r)}
                      style={{ padding: '3px 10px', background: r.isPublished ? 'rgba(0,200,150,0.15)' : 'rgba(139,167,190,0.1)', border: 'none', borderRadius: 6, color: r.isPublished ? '#00C896' : '#8BA7BE', cursor: 'pointer', fontSize: 12 }}>
                      {r.isPublished ? 'Published' : 'Draft'}
                    </button>
                  </td>
                  <td style={{ padding: '10px 12px' }}>
                    <button onClick={() => router.push(`/admin/reports/${r.id}/edit`)}
                      style={{ marginRight: 6, padding: '4px 10px', background: 'rgba(255,209,102,0.15)', border: 'none', borderRadius: 6, color: '#FFD166', cursor: 'pointer', fontSize: 12 }}>
                      Edit
                    </button>
                    <button onClick={() => handleDelete(r.id)}
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
