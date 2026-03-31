package csd230.bookstore.repositories;

import csd230.bookstore.entities.OrderEntity;
import csd230.bookstore.entities.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OrderEntityRepository extends JpaRepository<OrderEntity, Long> {
    List<OrderEntity> findByUserOrderByOrderDateDesc(UserEntity user);
}
