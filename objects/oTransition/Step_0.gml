if (transitionPhase == "in") {
    fadeAlpha += fadeSpeed;  // Increase alpha to fade in
    if (fadeAlpha >= 1) {
        fadeAlpha = 1;
        // Start battle setup once fade-in is complete
        instance_create_layer(0, 0, "Instances", oBattle);
        transitionPhase = "out"; // Change phase to fade out
    }
} else if (transitionPhase == "out") {
    fadeAlpha -= fadeSpeed; // Decrease alpha to fade out
    if (fadeAlpha <= 0) {
        fadeAlpha = 0;
        instance_destroy(); // Destroy the transition object after fade-out
    }
}