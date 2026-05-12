import { useEffect } from 'react';
import { useRouter } from 'next/router';
import AdminLayout from '@/components/layout/AdminLayout';
import { isLoggedIn } from '@/services/api';

export default function NotificationsPage() {
  const router = useRouter();
  useEffect(() => {
    if (!isLoggedIn()) router.push('/admin/login');
  }, []);

  return (
    <AdminLayout>
      <h1 style={{ color: '#fff', fontSize: 22, fontWeight: 700, marginBottom: 8 }}>Notifications</h1>
      <p style={{ color: '#8BA7BE', fontSize: 14, marginBottom: 32 }}>Firebase Cloud Messaging integration placeholder.</p>

      <div style={{ background: '#1E3448', borderRadius: 14, padding: 32, textAlign: 'center', border: '2px dashed #253D56' }}>
        <div style={{ fontSize: 48, marginBottom: 12 }}>🔔</div>
        <h2 style={{ color: '#fff', marginBottom: 8 }}>FCM Integration Pending</h2>
        <p style={{ color: '#8BA7BE', fontSize: 14, maxWidth: 400, margin: '0 auto' }}>
          Firebase Cloud Messaging is prepared in the backend NotificationsModule.
          Connect your Firebase project credentials here to enable push notifications to all users or subscribers.
        </p>
      </div>
    </AdminLayout>
  );
}
