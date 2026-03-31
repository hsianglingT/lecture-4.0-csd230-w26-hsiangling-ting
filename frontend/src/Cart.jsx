import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router';

function Cart({ api, onCartChange, onCheckout }) {
    const navigate = useNavigate();
    const [cart, setCart] = useState(null);
    const [confirmRemove, setConfirmRemove] = useState(null); // { id, name }
    const [showCheckout, setShowCheckout] = useState(false);

    const loadCart = async () => {
        const res = await api.get('/cart');
        setCart(res.data);
        onCartChange(res.data.products.length);
    };

    useEffect(() => { loadCart(); }, []);

    const handleAdd = async (id) => {
        try {
            await api.post(`/cart/add/${id}`);
            loadCart();
        } catch (err) {
            const msg = err.response?.data || 'Cannot add item.';
            alert(msg);
        }
    };

    const handleDecrease = (id, name, currentQty) => {
        if (currentQty === 1) {
            setConfirmRemove({ id, name });
        } else {
            api.delete(`/cart/remove/${id}`).then(loadCart);
        }
    };

    const confirmYes = async () => {
        await api.delete(`/cart/remove/${confirmRemove.id}`);
        setConfirmRemove(null);
        loadCart();
    };

    const handleCheckout = async () => {
        try {
            await api.post('/orders/checkout');
            onCartChange(0);
            onCheckout();
            navigate('/orders');
        } catch (err) {
            const msg = err.response?.data?.message || err.response?.data || 'Checkout failed.';
            alert(msg);
            setShowCheckout(false);
        }
    };

    if (!cart) return <p>Loading...</p>;

    // Group duplicate products by id
    const grouped = [];
    const seen = {};
    for (const p of cart.products) {
        if (seen[p.id]) {
            seen[p.id].qty++;
        } else {
            const item = { ...p, qty: 1 };
            seen[p.id] = item;
            grouped.push(item);
        }
    }

    const grandTotal = grouped.reduce((sum, p) => sum + p.price * p.qty, 0);

    return (
        <div>
            <h1>Your Cart</h1>

            {confirmRemove && (
                <div style={{ border: '1px solid red', padding: '10px', margin: '10px 0', background: '#fff3f3' }}>
                    <p>Are you sure to remove <strong>{confirmRemove.name}</strong>?</p>
                    <button onClick={confirmYes}>Yes</button>
                    {' '}
                    <button onClick={() => setConfirmRemove(null)}>No</button>
                </div>
            )}

            {grouped.length === 0 ? <p>Empty</p> : (
                <>
                <table border="1" width="100%">
                    <thead>
                        <tr>
                            <th>Item</th>
                            <th>Price/Unit</th>
                            <th>Qty</th>
                            <th>Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        {grouped.map(p => (
                            <tr key={p.id}>
                                <td>{p.title || p.description}</td>
                                <td>${p.price.toFixed(2)}</td>
                                <td>
                                    <button onClick={() => handleDecrease(p.id, p.title || p.description, p.qty)}>-</button>
                                    {' '}{p.qty}{' '}
                                    <button
                                        onClick={() => handleAdd(p.id)}
                                        disabled={p.copies != null && p.qty >= p.copies}
                                        title={p.copies != null && p.qty >= p.copies ? `Only ${p.copies} available` : ''}
                                    >+</button>
                                </td>
                                <td>${(p.price * p.qty).toFixed(2)}</td>
                            </tr>
                        ))}
                    </tbody>
                    <tfoot>
                        <tr>
                            <td colSpan="3"><strong>Grand Total</strong></td>
                            <td><strong>${grandTotal.toFixed(2)}</strong></td>
                        </tr>
                    </tfoot>
                </table>

                {!showCheckout ? (
                    <button style={{ marginTop: '12px' }} onClick={() => setShowCheckout(true)}>
                        Checkout
                    </button>
                ) : (
                    <div style={{ border: '1px solid green', padding: '10px', marginTop: '12px', background: '#f0fff0' }}>
                        <p>Would you like to pay <strong>${grandTotal.toFixed(2)}</strong>?</p>
                        <button onClick={handleCheckout}>Yes</button>
                        {' '}
                        <button onClick={() => setShowCheckout(false)}>No</button>
                    </div>
                )}
                </>
            )}
        </div>
    );
}

export default Cart;
