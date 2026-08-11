import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../lib/AuthContext';

export default function Signup() {
  const { signUp } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState(null);
  const [info, setInfo] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);
    setInfo(null);
    setSubmitting(true);
    const { data, error } = await signUp(email, password);
    setSubmitting(false);
    if (error) {
      setError(error.message);
      return;
    }
    if (data?.user && !data?.session) {
      setInfo('Account created. Check your email to confirm before logging in.');
      return;
    }
    navigate('/');
  }

  return (
    <div style={{ maxWidth: 360, margin: '4rem auto' }}>
      <h1>Supplier sign up</h1>
      <form onSubmit={handleSubmit}>
        <label>
          Email
          <input
            type="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            style={{ display: 'block', width: '100%', marginBottom: 12 }}
          />
        </label>
        <label>
          Password
          <input
            type="password"
            required
            minLength={6}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            style={{ display: 'block', width: '100%', marginBottom: 12 }}
          />
        </label>
        {error && <p style={{ color: 'crimson' }}>{error}</p>}
        {info && <p style={{ color: 'green' }}>{info}</p>}
        <button type="submit" disabled={submitting}>
          {submitting ? 'Creating account…' : 'Sign up'}
        </button>
      </form>
      <p>
        Already have an account? <Link to="/login">Log in</Link>
      </p>
    </div>
  );
}
