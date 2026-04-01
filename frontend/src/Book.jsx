import { useState } from 'react';
import { useAuth } from './provider/authProvider';

function Book({ id, title, author, price, copies, onDelete, onUpdate, onAddToCart }) {
    const { isAdmin } = useAuth(); 
    const [isEditing, setIsEditing] = useState(false);
    const [tempTitle, setTempTitle] = useState(title);
    const [tempAuthor, setTempAuthor] = useState(author);
    const [tempPrice, setTempPrice] = useState(price);
    const [tempCopies, setTempCopies] = useState(copies);

    const handleSave = () => {
        const updatedBook = { id, title: tempTitle, author: tempAuthor, price: parseFloat(tempPrice), copies: parseInt(tempCopies) };
        onUpdate(id, updatedBook);
        setIsEditing(false);
    };

    if (isEditing) {
        return (
            <div className="book-row editing">
                <input type="text" value={tempTitle} onChange={(e) => setTempTitle(e.target.value)} />
                <input type="text" value={tempAuthor} onChange={(e) => setTempAuthor(e.target.value)} />
                <input type="number" value={tempPrice} onChange={(e) => setTempPrice(e.target.value)} />
                <input type="number" value={tempCopies} onChange={(e) => setTempCopies(e.target.value)} placeholder="Copies" style={{width: '70px'}} />
                <button onClick={handleSave} className="btn-save">Save</button>
                <button onClick={() => setIsEditing(false)}>Cancel</button>
            </div>
        );
    }

    return (
        <div className="book-row">
            <div className="book-info">
                <h3>{title}</h3>
                <p><strong>Author:</strong> {author} | <strong>Price:</strong> ${Number(price).toFixed(2)}</p>
            </div>
            <div className="book-actions">
                {tempCopies === 0
                    ? <span style={{ color: 'red', fontWeight: 'bold' }}>SOLD OUT</span>
                    : <button onClick={() => onAddToCart(id)} style={{ backgroundColor: '#28a745', color: 'white' }}>🛒 Add to Cart</button>
                }
                {isAdmin && (
                    <>
                        <button onClick={() => setIsEditing(true)} style={{ backgroundColor: '#ffc107' }}>Edit</button>
                        <button onClick={() => onDelete(id)} style={{ backgroundColor: '#ff4444', color: 'white' }}>Delete</button>
                    </>
                )}
            </div>
        </div>
    );
}
export default Book;