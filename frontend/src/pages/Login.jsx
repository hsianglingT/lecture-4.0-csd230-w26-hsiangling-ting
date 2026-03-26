import { useState } from "react";
import { useNavigate, useLocation } from "react-router"; 
import { useAuth } from "../provider/authProvider";
import api from "../api/axiosConfig";

const Login = () => {
    const { setToken } = useAuth();
    const navigate = useNavigate();
    
    // NEW for 2.12.1: Use location to check for "expired" query parameter
    const location = useLocation();
    const queryParams = new URLSearchParams(location.search);
    const isExpired = queryParams.get("expired");
    
    const [email, setEmail] = useState(""); // Variable named 'email' to match Backend LoginReq
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");

    const handleLogin = async (e) => {
        e.preventDefault();
        setError(""); // Clear previous errors
        
        try {
            // 1. Call the Spring Boot AuthController
            // We pass { email, password } to match the LoginReq.java POJO
            const res = await api.post("/auth/login", { email, password });
            
            // 2. Save the JWT to context (which also updates localStorage)
            setToken(res.data.token);
            
            // 3. Redirect to home page
            // 'replace: true' prevents the user from clicking "back" to the login page
            navigate("/", { replace: true });
        } catch (err) {
            console.error("Login Error:", err.response?.data || err.message);
            setError("Invalid username or password. Please try again.");
        }
    };

    return (
        <div className="login-page">
            {/* Left branding panel */}
            <div className="login-panel-left">
                <div className="login-icon">📖</div>
                <h1 className="login-title">Bookstore</h1>
                <div className="login-divider" />
                <p className="login-tagline">Your digital library for books, magazines, and audio books.</p>
            </div>

            {/* Right form panel */}
            <div className="login-panel-right">
                <h2>Welcome back</h2>
                <p className="login-welcome">Sign in to your account to continue.</p>

                {isExpired && (
                    <div className="login-alert-expired">
                        ⚠️ Your session has expired. Please log in again to continue.
                    </div>
                )}

                {error && (
                    <div className="login-alert-error">{error}</div>
                )}

                <form onSubmit={handleLogin} className="login-form">
                    <div className="login-field">
                        <label>Username</label>
                        <input
                            type="text"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            required
                            placeholder="e.g. admin"
                        />
                        <small>Hint: try 'admin' or 'user'</small>
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

                    <button type="submit" className="login-btn">Sign In</button>
                </form>
            </div>
        </div>
    );
};

export default Login;