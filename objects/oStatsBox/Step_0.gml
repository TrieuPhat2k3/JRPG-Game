// Don't process input if the menu is closed or animating
if (currentState == STATS_STATE.CLOSED && !closing) return;

if (!visible) return;

// Handle animation
if (opening) {
    animationProgress += animationSpeed;
    if (animationProgress >= 1) {
        opening = false;
        animationProgress = 1;
    }
    return; // Don't process input during opening animation
}

if (closing) {
    animationProgress -= animationSpeed;
    if (animationProgress <= 0) {
        closing = false;
        animationProgress = 0;
        visible = false;
        // Make absolutely sure we're in closed state
        currentState = STATS_STATE.CLOSED;
    }
    return; // Don't process input during closing animation
}

// Handle escape key to close
if (keyboard_check_pressed(vk_escape)) {
    Close();
}

// Handle different states
switch (currentState) {
    case STATS_STATE.SELECTING_CHARACTER:
        // Get input
        var keyUp = keyboard_check_pressed(vk_up);
        var keyDown = keyboard_check_pressed(vk_down);
        var keyConfirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
        var keyCancel = keyboard_check_pressed(vk_escape);
        
        // Move selection up/down
        if (keyUp) {
            selectedIndex--;
            if (selectedIndex < 0) selectedIndex = array_length(characters) - 1;
        }
        
        if (keyDown) {
            selectedIndex++;
            if (selectedIndex >= array_length(characters)) selectedIndex = 0;
        }
        
        // Select character
        if (keyConfirm) {
            var selectedChar = characters[selectedIndex];
            if (!instance_exists(oCharacterDetails)) {
                instance_create_depth(0, 0, -10000, oCharacterDetails);
            }
            with (oCharacterDetails) {
                Open(selectedChar);
            }
        }
        
        // Close menu
        if (keyCancel) {
            Close();
        }
        break;
} 