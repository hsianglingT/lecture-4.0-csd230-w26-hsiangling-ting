import { Link } from 'react-router';
import { useAuth } from './provider/authProvider';

function Navbar({ cartCount }) {
    const { isAdmin } = useAuth();

    return (
        <nav className="navbar">
            <div className="navbar-brand">📖 Bookstore</div>

            <div className="navbar-links">
                <Link to="/">🏠 Home</Link>
                <Link to="/inventory">📚 Books</Link>
                <Link to="/magazines">📰 Magazines</Link>
                <Link to="/audiobooks">🎧 Audio Books</Link>
            </div>

            {isAdmin && (
                <div className="navbar-admin">
                    <span className="navbar-admin-label">Admin</span>
                    <Link to="/add">➕ Book</Link>
                    <Link to="/add-magazine">➕ Magazine</Link>
                    <Link to="/add-audiobook">➕ Audio Book</Link>
                </div>
            )}

            <div className="navbar-right">
                <Link to="/cart" className="navbar-cart">🛒 Cart ({cartCount})</Link>
                <Link to="/logout" className="navbar-logout">🚪 Logout</Link>
            </div>
        </nav>
    );
}
export default Navbar;