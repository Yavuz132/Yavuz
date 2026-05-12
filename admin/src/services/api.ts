import axios from 'axios';
import Cookies from 'js-cookie';

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3000';

export const api = axios.create({ baseURL: API_URL });

api.interceptors.request.use((config) => {
  const token = Cookies.get('admin_token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

export async function adminLogin(email: string, password: string) {
  const res = await api.post('/auth/login', { email, password });
  Cookies.set('admin_token', res.data.accessToken, { expires: 1 });
  return res.data;
}

export function adminLogout() {
  Cookies.remove('admin_token');
}

export const isLoggedIn = () => !!Cookies.get('admin_token');
