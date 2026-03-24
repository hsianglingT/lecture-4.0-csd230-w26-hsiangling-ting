package csd230.bookstore.controllers;
import org.springframework.stereotype.Controller;

@Controller
public class LoginController {

    public String login() {
        return "login";
    }
}