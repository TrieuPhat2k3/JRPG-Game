/// @description Handle input

// Skip if animating
if (isAnimating) {
    animCounter++;
    if (animCounter >= animFrames) {
        isAnimating = false;
    }
    return;
}

// Ensure we're always at the correct depth for GUI rendering
depth = -10000;

// Reduce input cooldown
if (inputCooldown > 0) {
    inputCooldown--;
}

// Only process input when cooldown is zero
if (inputCooldown == 0) {
    // Switch character with left/right arrow keys
    if (keyboard_check_pressed(vk_left)) {
        selectedCharIndex = (selectedCharIndex - 1 + characterCount) % characterCount;
        inputCooldown = inputCooldownMax / 2;
        
        // Play a sound effect if available
        if (audio_exists(snd_movemenu)) {
            audio_play_sound(snd_movemenu, 1, false);
        }
    }
    
    if (keyboard_check_pressed(vk_right)) {
        selectedCharIndex = (selectedCharIndex + 1) % characterCount;
        inputCooldown = inputCooldownMax / 2;
        
        // Play a sound effect if available
        if (audio_exists(snd_movemenu)) {
            audio_play_sound(snd_movemenu, 1, false);
        }
    }
    
    // Switch tabs with up/down arrow keys
    if (keyboard_check_pressed(vk_up)) {
        selectedTab = (selectedTab - 1 + array_length(tabs)) % array_length(tabs);
        inputCooldown = inputCooldownMax / 2;
        
        // Play a sound effect if available
        if (audio_exists(snd_movemenu)) {
            audio_play_sound(snd_movemenu, 1, false);
        }
    }
    
    if (keyboard_check_pressed(vk_down)) {
        selectedTab = (selectedTab + 1) % array_length(tabs);
        inputCooldown = inputCooldownMax / 2;
        
        // Play a sound effect if available
        if (audio_exists(snd_movemenu)) {
            audio_play_sound(snd_movemenu, 1, false);
        }
    }
    
    // Close with the G (same key that opens it)
    if (keyboard_check_pressed(ord("G"))) {
        isAnimating = true;
        animCounter = 0;
        
        // Play a sound effect if available
        if (audio_exists(snd_select)) {
            audio_play_sound(snd_select, 1, false);
        }
        
        // Destroy after animation
        alarm[0] = animFrames;
    }
}

// Create or recreate the portrait surface if needed
if (!surface_exists(portraitSurface)) {
    portraitSurface = surface_create(charPanelWidth, charPanelHeight);
} 