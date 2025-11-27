package com.example.demo;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class AfroseSana {

    @GetMapping("/afrosesana")
    public String redirectToImage() {
        return "redirect:/afrosesana.png";
    }
}
