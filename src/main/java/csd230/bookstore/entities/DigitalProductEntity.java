package csd230.bookstore.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;

@Entity
public abstract class DigitalProductEntity extends ProductEntity {

    @Column(name = "dig_title")
    private String title;

    @Column(name = "dig_author")
    private String author;

    @Column(name = "dig_price")
    private double price;

    private String downloadUrl;

    public DigitalProductEntity() {}

    public DigitalProductEntity(String title, String author, double price, String downloadUrl) {
        this.title = title;
        this.author = author;
        this.price = price;
        this.downloadUrl = downloadUrl;
    }

    @Override
    public void sellItem() {
        System.out.println("Download link sent for '" + title + "': " + downloadUrl);
    }

    @Override
    public Double getPrice() { return price; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public void setPrice(double price) { this.price = price; }

    public String getDownloadUrl() { return downloadUrl; }
    public void setDownloadUrl(String downloadUrl) { this.downloadUrl = downloadUrl; }

    @Override
    public String toString() {
        return "DigitalProduct{title='" + title + "', author='" + author +
                "', price=" + price + ", downloadUrl='" + downloadUrl + "'}";
    }
}
