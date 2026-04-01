import { useState } from 'react';
import { useNavigate, Link } from 'react-router';
import api from '../api/axiosConfig';

const Register = () => {
    const navigate = useNavigate();
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [error, setError] = useState('');

    const handleRegister = async (e) => {
        e.preventDefault();
        setError('');

        if (password !== confirmPassword) {
            setError('Passwords do not match.');
            return;
        }

        try {
            await api.post('/auth/register', { username, password });
            navigate('/login');
        } catch (err) {
            const msg = err.response?.data?.message || err.response?.data || 'Registration failed.';
            setError(msg);
        }
    };

    return (
        <div className="login-page">
            <div className="login-panel-left">
                <div className="login-icon">📖</div>
                <h1 className="login-title">Bookstore</h1>
                <div className="login-divider" />
                <p className="login-tagline">Your digital library for books, magazines, and audio books.</p>
            </div>

            <div className="login-panel-right">
                <h2>Create an account</h2>
                <p className="login-welcome">Fill in the details below to register.</p>

                {error && <div className="login-alert-error">{error}</div>}

                <form onSubmit={handleRegister} className="login-form">
                    <div className="login-field">
                        <label>Username</label>
                        <input
                            type="text"
                            value={username}
                            onChange={(e) => setUsername(e.target.value)}
                            required
                        />
                    </div>

                    <div className="login-field">
                        <label>Password</label>
                        <input
                            type="password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            required
                        />
                    </div>

                    <div className="login-field">
                        <label>Confirm Password</label>
                        <input
                            type="password"
                            value={confirmPassword}
                            onChange={(e) => setConfirmPassword(e.target.value)}
                            required
                        />
                    </div>

                    <button type="submit" className="login-btn">Register</button>
                </form>

                <p style={{ marginTop: '12px' }}>
                    Already have an account? <Link to="/login">Sign in</Link>
                </p>
            </div>
        </div>
    );
};

export default Register;
