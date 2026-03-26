import { useState } from 'react';

function AudioBookForm({ onAudioBookAdded, api }) {
    const [title, setTitle] = useState('');
    const [author, setAuthor] = useState('');
    const [price, setPrice] = useState(0);
    const [narrator, setNarrator] = useState('');
    const [downloadUrl, setDownloadUrl] = useState('');

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const res = await api.post('/audiobooks', { title, author, price: parseFloat(price), narrator, downloadUrl });
            alert("Audio Book Saved!");
            onAudioBookAdded(res.data);
            setTitle(''); setAuthor(''); setPrice(0); setNarrator(''); setDownloadUrl('');
        } catch (err) {
            alert("Save failed.");
        }
    };

    return (
        <form onSubmit={handleSubmit} className="form-style">
            <h3>Add New Audio Book</h3>
            <input type="text" placeholder="Title" value={title} onChange={(e) => setTitle(e.target.value)} required />
            <input type="text" placeholder="Author" value={author} onChange={(e) => setAuthor(e.target.value)} required />
            <input type="number" placeholder="Price" value={price} onChange={(e) => setPrice(e.target.value)} required />
            <input type="text" placeholder="Narrator" value={narrator} onChange={(e) => setNarrator(e.target.value)} required />
            <input type="text" placeholder="Download URL" value={downloadUrl} onChange={(e) => setDownloadUrl(e.target.value)} required />
            <button type="submit">Save Audio Book</button>
        </form>
    );
}

export default AudioBookForm;
