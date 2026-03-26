import { useState } from 'react';
import { useAuth } from './provider/authProvider';

function AudioBook({ id, title, author, price, narrator, onDelete, onUpdate, onAddToCart }) {
    const { isAdmin } = useAuth();
    const [isEditing, setIsEditing] = useState(false);
    const [tempTitle, setTempTitle] = useState(title);
    const [tempAuthor, setTempAuthor] = useState(author);
    const [tempPrice, setTempPrice] = useState(price);
    const [tempNarrator, setTempNarrator] = useState(narrator);

    const handleSave = () => {
        onUpdate(id, { id, title: tempTitle, author: tempAuthor, price: parseFloat(tempPrice), narrator: tempNarrator });
        setIsEditing(false);
    };

    if (isEditing) {
        return (
            <div className="book-row editing">
                <input type="text" value={tempTitle} onChange={(e) => setTempTitle(e.target.value)} placeholder="Title" />
                <input type="text" value={tempAuthor} onChange={(e) => setTempAuthor(e.target.value)} placeholder="Author" />
                <input type="number" value={tempPrice} onChange={(e) => setTempPrice(e.target.value)} placeholder="Price" />
                <input type="text" value={tempNarrator} onChange={(e) => setTempNarrator(e.target.value)} placeholder="Narrator" />
                <button onClick={handleSave} className="btn-save">Save</button>
                <button onClick={() => setIsEditing(false)}>Cancel</button>
            </div>
        );
    }

    return (
        <div className="book-row">
            <div className="book-info">
                <h3>{title}</h3>
                <p><strong>Author:</strong> {author} | <strong>Narrator:</strong> {narrator} | <strong>Price:</strong> ${Number(price).toFixed(2)}</p>
            </div>
            <div className="book-actions">
                <button onClick={() => onAddToCart(id)} style={{ backgroundColor: '#28a745', color: 'white' }}>🛒 Add to Cart</button>
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

export default AudioBook;
