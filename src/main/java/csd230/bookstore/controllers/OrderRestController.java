package csd230.bookstore.controllers;

import csd230.bookstore.entities.*;
import csd230.bookstore.repositories.CartEntityRepository;
import csd230.bookstore.repositories.OrderEntityRepository;
import csd230.bookstore.repositories.ProductEntityRepository;
import csd230.bookstore.repositories.UserEntityRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/rest/orders")
@CrossOrigin(origins = "*")
public class OrderRestController {

    private final OrderEntityRepository orderRepository;
    private final CartEntityRepository cartRepository;
    private final UserEntityRepository userRepository;
    private final ProductEntityRepository productRepository;

    public OrderRestController(OrderEntityRepository orderRepository,
                               CartEntityRepository cartRepository,
                               UserEntityRepository userRepository,
                               ProductEntityRepository productRepository) {
        this.orderRepository = orderRepository;
        this.cartRepository = cartRepository;
        this.userRepository = userRepository;
        this.productRepository = productRepository;
    }

    private UserEntity getCurrentUser() {
        String username = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByUsername(username);
    }

    /** GET /api/rest/orders — returns all orders for the current user, newest first */
    @GetMapping
    public List<OrderEntity> getOrders() {
        return orderRepository.findByUserOrderByOrderDateDesc(getCurrentUser());
    }

    /** POST /api/rest/orders/checkout — converts cart into a saved order and clears the cart */
    @PostMapping("/checkout")
    public OrderEntity checkout() {
        UserEntity user = getCurrentUser();
        CartEntity cart = cartRepository.findByUser(user).orElseThrow();

        if (cart.getProducts().isEmpty()) {
            throw new IllegalStateException("Cart is empty");
        }

        // Group cart products by id to count quantities
        Map<Long, OrderItemEntity> itemMap = new LinkedHashMap<>();
        for (ProductEntity product : cart.getProducts()) {
            itemMap.compute(product.getId(), (id, existing) -> {
                if (existing == null) {
                    OrderItemEntity item = new OrderItemEntity();
                    item.setProductId(product.getId());
                    item.setProductName(resolveProductName(product));
                    item.setPricePerUnit(product.getPrice());
                    item.setQuantity(1);
                    return item;
                } else {
                    existing.setQuantity(existing.getQuantity() + 1);
                    return existing;
                }
            });
        }

        // Validate stock and decrement copies for physical products
        for (Map.Entry<Long, OrderItemEntity> entry : itemMap.entrySet()) {
            ProductEntity product = cart.getProducts().stream()
                    .filter(p -> p.getId().equals(entry.getKey()))
                    .findFirst().orElseThrow();

            if (product instanceof PublicationEntity pub) {
                int requested = entry.getValue().getQuantity();
                if (pub.getCopies() < requested) {
                    throw new IllegalStateException(
                            "Not enough copies of '" + pub.getTitle() + "'. " +
                            "Available: " + pub.getCopies() + ", requested: " + requested);
                }
                pub.setCopies(pub.getCopies() - requested);
                productRepository.save(pub);
            }
        }

        // Build the order
        OrderEntity order = new OrderEntity();
        order.setUser(user);
        order.setOrderDate(LocalDateTime.now());

        double total = 0;
        for (OrderItemEntity item : itemMap.values()) {
            item.setOrder(order);
            order.getItems().add(item);
            total += item.getPricePerUnit() * item.getQuantity();
        }
        order.setTotalAmount(total);

        // Save order and clear cart
        OrderEntity saved = orderRepository.save(order);
        cart.getProducts().clear();
        cartRepository.save(cart);

        return saved;
    }

    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<String> handleIllegalState(IllegalStateException ex) {
        return ResponseEntity.badRequest().body(ex.getMessage());
    }

    private String resolveProductName(ProductEntity product) {
        if (product instanceof PublicationEntity pub) return pub.getTitle();
        if (product instanceof DigitalProductEntity dig) return dig.getTitle();
        if (product instanceof TicketEntity t) return t.getDescription();
        return "Unknown Product";
    }
}
