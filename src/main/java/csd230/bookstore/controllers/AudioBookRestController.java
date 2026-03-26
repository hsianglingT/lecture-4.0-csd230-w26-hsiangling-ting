package csd230.bookstore.controllers;

import csd230.bookstore.entities.AudioBookEntity;
import csd230.bookstore.repositories.AudioBookEntityRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "AudioBook REST API", description = "JSON API for managing audio books")
@RestController
@RequestMapping("/api/rest/audiobooks")
@CrossOrigin(origins = "*")
public class AudioBookRestController {
    private final AudioBookEntityRepository audioBookRepository;

    public AudioBookRestController(AudioBookEntityRepository audioBookRepository) {
        this.audioBookRepository = audioBookRepository;
    }

    @Operation(summary = "Get all audio books")
    @GetMapping
    public List<AudioBookEntity> all() {
        return audioBookRepository.findAll();
    }

    @Operation(summary = "Get a single audio book by ID")
    @GetMapping("/{id}")
    public AudioBookEntity getAudioBook(@PathVariable Long id) {
        return audioBookRepository.findById(id)
                .orElseThrow(() -> new BookNotFoundException(id));
    }

    @Operation(summary = "Create a new audio book")
    @PostMapping
    public AudioBookEntity newAudioBook(@RequestBody AudioBookEntity audioBook) {
        return audioBookRepository.save(audioBook);
    }

    @Operation(summary = "Update an audio book")
    @PutMapping("/{id}")
    public AudioBookEntity replaceAudioBook(@RequestBody AudioBookEntity updated, @PathVariable Long id) {
        return audioBookRepository.findById(id)
                .map(ab -> {
                    ab.setTitle(updated.getTitle());
                    ab.setAuthor(updated.getAuthor());
                    ab.setPrice(updated.getPrice());
                    ab.setNarrator(updated.getNarrator());
                    ab.setDownloadUrl(updated.getDownloadUrl());
                    return audioBookRepository.save(ab);
                })
                .orElseGet(() -> {
                    updated.setId(id);
                    return audioBookRepository.save(updated);
                });
    }

    @Operation(summary = "Delete an audio book")
    @DeleteMapping("/{id}")
    public void deleteAudioBook(@PathVariable Long id) {
        audioBookRepository.deleteById(id);
    }
}
