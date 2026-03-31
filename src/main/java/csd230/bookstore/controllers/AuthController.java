package csd230.bookstore.controllers;

import csd230.bookstore.auth.JwtUtil;
import csd230.bookstore.entities.CartEntity;
import csd230.bookstore.entities.UserEntity;
import csd230.bookstore.model.request.LoginReq;
import csd230.bookstore.model.request.RegisterReq;
import csd230.bookstore.model.response.ErrorRes;
import csd230.bookstore.model.response.LoginRes;
import csd230.bookstore.repositories.CartEntityRepository;
import csd230.bookstore.repositories.UserEntityRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/rest/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;
    private final UserEntityRepository userRepository;
    private final CartEntityRepository cartRepository;
    private final PasswordEncoder passwordEncoder;

    public AuthController(AuthenticationManager authenticationManager, JwtUtil jwtUtil,
                          UserEntityRepository userRepository, CartEntityRepository cartRepository,
                          PasswordEncoder passwordEncoder) {
        this.authenticationManager = authenticationManager;
        this.jwtUtil = jwtUtil;
        this.userRepository = userRepository;
        this.cartRepository = cartRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginReq loginReq)  {
        try {
            // This line checks the DB using your CustomUserDetailsService
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(loginReq.getEmail(), loginReq.getPassword())
            );

            String email = authentication.getName();
            // Pass the roles from the DB into the token
            String token = jwtUtil.createToken(email, authentication.getAuthorities());

            return ResponseEntity.ok(new LoginRes(email, token));

        } catch (BadCredentialsException e){
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorRes(HttpStatus.BAD_REQUEST, "Invalid username or password"));
        }
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterReq req) {
        if (userRepository.findByUsername(req.getUsername()) != null) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(new ErrorRes(HttpStatus.CONFLICT, "Username already taken"));
        }

        UserEntity newUser = new UserEntity(req.getUsername(), passwordEncoder.encode(req.getPassword()), "USER");
        userRepository.save(newUser);

        CartEntity cart = new CartEntity();
        cart.setUser(newUser);
        cartRepository.save(cart);

        return ResponseEntity.status(HttpStatus.CREATED).body("User registered successfully");
    }
}



