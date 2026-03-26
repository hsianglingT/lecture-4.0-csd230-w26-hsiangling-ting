package csd230.bookstore.repositories;

import csd230.bookstore.entities.AudioBookEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AudioBookEntityRepository extends JpaRepository<AudioBookEntity, Long> {
}
