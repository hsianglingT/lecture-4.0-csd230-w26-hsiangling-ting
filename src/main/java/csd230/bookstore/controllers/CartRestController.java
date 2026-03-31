package csd230.bookstore.controllers;

import csd230.bookstore.entities.CartEntity;
import csd230.bookstore.entities.ProductEntity;
import csd230.bookstore.entities.PublicationEntity;
import csd230.bookstore.entities.UserEntity;
import csd230.bookstore.repositories.CartEntityRepository;
import csd230.bookstore.repositories.ProductEntityRepository;
import csd230.bookstore.repositories.UserEntityRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/rest/cart")
@CrossOrigin(origins = "*")
public class CartRestController {
    private final CartEntityRepository cartRepository;
    private final ProductEntityRepository productRepository;
    private final UserEntityRepository userRepository;

    public CartRestController(CartEntityRepository cartRepository, ProductEntityRepository productRepository, UserEntityRepository userRepository) {
        this.cartRepository = cartRepository;
        this.productRepository = productRepository;
        this.userRepository = userRepository;
    }

    private CartEntity getCurrentUserCart() {
        String username = SecurityContextHolder.getContext().getAuthentication().getName();
        UserEntity user = userRepository.findByUsername(username);
        return cartRepository.findByUser(user).orElseThrow();
    }

    @GetMapping
    public CartEntity getCart() {
        return getCurrentUserCart();
    }

    @PostMapping("/add/{productId}")
    public CartEntity addToCart(@PathVariable Long productId) {
        CartEntity cart = getCurrentUserCart();
        ProductEntity product = productRepository.findById(productId).orElseThrow();

        if (product instanceof PublicationEntity pub) {
            long inCart = cart.getProducts().stream()
                    .filter(p -> p.getId().equals(productId))
                    .count();
            if (inCart >= pub.getCopies()) {
                throw new IllegalStateException(
                        "Cannot add more '" + pub.getTitle() + "'. Only " + pub.getCopies() + " cop" +
                        (pub.getCopies() == 1 ? "y" : "ies") + " available.");
            }
        }

        cart.addProduct(product);
        return cartRepository.save(cart);
    }

    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<String> handleIllegalState(IllegalStateException ex) {
        return ResponseEntity.badRequest().body(ex.getMessage());
    }

    @DeleteMapping("/remove/{productId}")
    public CartEntity removeFromCart(@PathVariable Long productId) {
        CartEntity cart = getCurrentUserCart();
        ProductEntity product = productRepository.findById(productId).orElseThrow();
        cart.getProducts().remove(product);
        return cartRepository.save(cart);
    }
}
