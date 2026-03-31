import { useState, useEffect } from 'react';

function OrderHistory({ api }) {
    const [orders, setOrders] = useState(null);

    useEffect(() => {
        api.get('/orders').then(res => setOrders(res.data));
    }, []);

    if (!orders) return <p>Loading...</p>;

    return (
        <div>
            <h1>Order History</h1>
            {orders.length === 0 ? (
                <p>No orders yet.</p>
            ) : (
                orders.map(order => (
                    <div key={order.id} style={{ border: '1px solid #ccc', margin: '16px 0', padding: '12px' }}>
                        <h3>
                            Order #{order.id} &nbsp;|&nbsp;
                            {new Date(order.orderDate).toLocaleString()} &nbsp;|&nbsp;
                            Total: <strong>${order.totalAmount.toFixed(2)}</strong>
                        </h3>
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
                                {order.items.map(item => (
                                    <tr key={item.id}>
                                        <td>{item.productName}</td>
                                        <td>${item.pricePerUnit.toFixed(2)}</td>
                                        <td>{item.quantity}</td>
                                        <td>${(item.pricePerUnit * item.quantity).toFixed(2)}</td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                ))
            )}
        </div>
    );
}

export default OrderHistory;
