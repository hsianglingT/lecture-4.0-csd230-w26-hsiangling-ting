package csd230.bookstore;


import com.github.javafaker.Commerce;
import com.github.javafaker.Faker;
import csd230.bookstore.entities.AudioBookEntity;
import csd230.bookstore.entities.BookEntity;
import csd230.bookstore.entities.CartEntity;
import csd230.bookstore.entities.MagazineEntity;
import csd230.bookstore.entities.UserEntity;
import csd230.bookstore.repositories.CartEntityRepository;
import csd230.bookstore.repositories.ProductEntityRepository;
import csd230.bookstore.repositories.UserEntityRepository;
import jakarta.transaction.Transactional;
import java.time.LocalDateTime;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;


@SpringBootApplication
public class Application implements CommandLineRunner {
    private final ProductEntityRepository productRepository;
    private final CartEntityRepository cartRepository;
    private final UserEntityRepository userRepository;
    private final PasswordEncoder passwordEncoder;


    public Application(ProductEntityRepository productRepository,
                       CartEntityRepository cartRepository,
                       UserEntityRepository userRepository,
                       PasswordEncoder passwordEncoder
    ) {
        this.productRepository = productRepository;
        this.cartRepository = cartRepository;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }


    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }


    @Override
    @Transactional
    public void run(String... args) throws Exception {
        Faker faker = new Faker();
        Commerce cm = faker.commerce();
        com.github.javafaker.Number number = faker.number();
        com.github.javafaker.Book fakeBook = faker.book();
        String name = cm.productName();
        String description = cm.material();

        for (int i = 0; i < 10; i++) {
            // We call the faker methods inside the loop so each book gets unique data
            String title = faker.book().title();
            String author = faker.book().author();
            String priceString = faker.commerce().price();

            // Create the book entity with the random data
            BookEntity book = new BookEntity(
                    title,
                    Double.parseDouble(priceString),
                    10,      // Defaulting to 10 copies each
                    author
            );

            // Save to database
            productRepository.save(book);

            System.out.println("Saved Book " + (i + 1) + ": " + title + " by " + author);
        }



        // ------------------------------------
        // CREATE USERS (Lecture 2.6)
        // ------------------------------------


        // Admin User (Can Add/Edit/Delete)
        UserEntity admin = new UserEntity("admin", passwordEncoder.encode("admin"), "ADMIN");
        userRepository.save(admin);

        // Regular User (Can only View/Buy)
        UserEntity user = new UserEntity("user", passwordEncoder.encode("user"), "USER");
        userRepository.save(user);

        System.out.println("Default users created: admin/admin and user/user");

        // Create one cart per user
        CartEntity adminCart = new CartEntity();
        adminCart.setUser(admin);
        cartRepository.save(adminCart);

        CartEntity userCart = new CartEntity();
        userCart.setUser(user);
        cartRepository.save(userCart);

        System.out.println("Created individual carts for admin and user");

        // ------------------------------------
        // CREATE AUDIO BOOKS
        // ------------------------------------
        String[] narrators = { "John Smith", "Jane Doe", "Michael Brown", "Emily Clark", "David Lee" };
        for (int i = 0; i < 5; i++) {
            String title = faker.book().title();
            String author = faker.book().author();
            double price = Double.parseDouble(faker.commerce().price());
            String narrator = narrators[i];
            String downloadUrl = "https://downloads.bookstore.com/audiobooks/" + title.toLowerCase().replace(" ", "-") + ".mp3";

            AudioBookEntity audioBook = new AudioBookEntity(title, author, price, downloadUrl, narrator);
            productRepository.save(audioBook);

                System.out.println("Saved AudioBook " + (i + 1) + ": " + title + " narrated by " + narrator);
        }

        // ------------------------------------
        // CREATE MAGAZINES
        // ------------------------------------
        MagazineEntity mag1 = new MagazineEntity(
                "National Geographic", 9.99, 50, 100,
                LocalDateTime.of(2026, 3, 1, 0, 0));
        productRepository.save(mag1);

        MagazineEntity mag2 = new MagazineEntity(
                "Scientific American", 7.99, 40, 80,
                LocalDateTime.of(2026, 2, 1, 0, 0));
        productRepository.save(mag2);

        MagazineEntity mag3 = new MagazineEntity(
                "The Economist", 6.99, 30, 60,
                LocalDateTime.of(2026, 1, 1, 0, 0));
        productRepository.save(mag3);

        System.out.println("Saved 3 magazines: National Geographic, Scientific American, The Economist");
    }
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                // Allow access to all /api endpoints from any origin
                registry.addMapping("/api/**").allowedOrigins("*");
            }
        };
    }



}

