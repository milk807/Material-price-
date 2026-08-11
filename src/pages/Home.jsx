import { useAuth } from '../lib/AuthContext';

export default function Home() {
  const { user, profile, signOut } = useAuth();

  return (
    <div style={{ maxWidth: 480, margin: '4rem auto' }}>
      <h1>Ethiopian Material Price Directory</h1>
      <p>Logged in as: {user?.email}</p>
      <p>
        Profile row: {profile ? 'found' : 'not loaded yet (expected until Phase 2 RLS policies exist)'}
      </p>
      {profile && <p>is_admin: {String(profile.is_admin)}</p>}
      <p style={{ color: '#666' }}>
        Supplier dashboard (Phase 3) and admin view (Phase 4) aren't built yet — this
        page just confirms signup/login works end to end for Phase 1.
      </p>
      <button onClick={signOut}>Log out</button>
    </div>
  );
}
