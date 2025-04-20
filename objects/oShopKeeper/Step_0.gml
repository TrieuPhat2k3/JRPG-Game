// oShopKeeper Step Event

// Check if player is in range for interaction
var wasInRange = playerInRange;
playerInRange = CheckPlayerRange();

// If player is in range, face them
if (playerInRange) {
    FacePlayer();
} else {
    // Default facing direction when no player is nearby
    currentDirection = 0; // Face down
    image_index = currentDirection;
}

// Show interaction indicator when player enters range
if (playerInRange && !wasInRange) {
    show_debug_message("Player in range of shopkeeper");
}

// Handle player input for shop interaction
if (playerInRange && !isInteracting && keyboard_check_pressed(ord("F"))) {
    // Open shop menu
    OpenShop();
    
    // Pause player movement if needed
    if (instance_exists(oPlayer)) {
        // You could add code here to pause the player during shop interaction
    }
}

// Reset interaction state if shop menu is closed
if (isInteracting && !instance_exists(oShopMenu)) {
    isInteracting = false;
    show_debug_message("Shop closed");
} 