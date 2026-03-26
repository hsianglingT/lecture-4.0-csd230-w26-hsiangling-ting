package csd230.bookstore.entities;

import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;

@Entity
@DiscriminatorValue("AUDIOBOOK")
public class AudioBookEntity extends DigitalProductEntity {

    private String narrator;

    public AudioBookEntity() {}

    public AudioBookEntity(String title, String author, double price, String downloadUrl, String narrator) {
        super(title, author, price, downloadUrl);
        this.narrator = narrator;
    }

    public String getNarrator() { return narrator; }
    public void setNarrator(String narrator) { this.narrator = narrator; }

    @Override
    public String toString() {
        return "AudioBook{narrator='" + narrator + "', " + super.toString() + "}";
    }
}
