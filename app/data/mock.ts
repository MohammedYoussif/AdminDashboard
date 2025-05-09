export interface User {
  id: string;
  name: string;
  email: string;
  role: string;
  lastActive: string;
}

export interface Category {
  id: string;
  name: string;
  icon: string;
  userCount: number;
}

export const users: User[] = Array.from({ length: 50 }, (_, i) => ({
  id: `u${i + 1}`,
  name: `User ${i + 1}`,
  email: `user${i + 1}@example.com`,
  role: i % 3 === 0 ? 'Admin' : 'User',
  lastActive: new Date(Date.now() - Math.random() * 10000000000).toISOString(),
}));

export const categories: Category[] = [
  { id: '1', name: 'Technology', icon: '💻', userCount: 15 },
  { id: '2', name: 'Marketing', icon: '📢', userCount: 8 },
  { id: '3', name: 'Sales', icon: '💰', userCount: 12 },
  { id: '4', name: 'Support', icon: '🎯', userCount: 6 },
  { id: '5', name: 'Development', icon: '⚙️', userCount: 20 },
  { id: '6', name: 'Design', icon: '🎨', userCount: 10 },
  { id: '7', name: 'Operations', icon: '📊', userCount: 5 },
  { id: '8', name: 'Finance', icon: '💳', userCount: 7 },
  { id: '9', name: 'HR', icon: '👥', userCount: 4 },
  { id: '10', name: 'Legal', icon: '⚖️', userCount: 3 },
];