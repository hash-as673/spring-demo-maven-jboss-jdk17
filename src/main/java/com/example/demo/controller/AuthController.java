package com.example.demo.controller;

import com.example.demo.model.User;
import com.example.demo.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
@Slf4j
public class AuthController {

    @Autowired
    private UserService userService;


    @GetMapping("/login")
    public String login(Model model) {
        log.info("Log in open webpage");
        model.addAttribute("user", new User());
        return "login";
    }


    @GetMapping("/register")
    public String registerForm(Model model) {
        log.info("Register webpage open");
        model.addAttribute("user", new User());
        return "register";
    }

    @PostMapping("/register")
    public String register(@ModelAttribute User user) {
        log.info("Registered! (Log)");
        userService.save(user);
        return "redirect:/login";
    }

    @PostMapping("/login")
    public String loginSubmit(@ModelAttribute User user, Model model) {
        log.info("Logged in! (Log)");
        User existingUser = userService.findByUsername(user.getUsername());

        if (existingUser != null && existingUser.getPassword().equals(user.getPassword())) {
            model.addAttribute("username", existingUser.getUsername());
            return "welcome"; // this will render welcome.html
        } else {
            model.addAttribute("error", "Invalid username or password");
            return "login";
        }
    }

}
