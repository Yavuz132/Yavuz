import { useEffect } from 'react';
import { useRouter } from 'next/router';
import { isLoggedIn } from '@/services/api';

export default function IndexPage() {
  const router = useRouter();
  useEffect(() => {
    router.replace(isLoggedIn() ? '/admin/dashboard' : '/admin/login');
  }, []);
  return null;
}
