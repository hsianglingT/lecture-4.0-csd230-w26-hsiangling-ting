package csd230.bookstore.repositories;

import csd230.bookstore.entities.CartEntity;
import csd230.bookstore.entities.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CartEntityRepository extends JpaRepository<CartEntity, Long> {
    Optional<CartEntity> findByUser(UserEntity user);
}