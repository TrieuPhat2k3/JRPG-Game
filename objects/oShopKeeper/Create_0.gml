// oShopKeeper Create Event
// Initialize variables for the shopkeeper

// Animation variables
sprite_index = sShopkeep;
image_speed = 0; // No automatic animation, we'll control the frame manually
currentDirection = 0; // 0=down, 1=right, 2=up, 3=left
animIndex = 0;

// Interaction variables
interactionRange = 128; // How close the player needs to be to interact
playerInRange = false;
isInteracting = false;
interactionPrompt = "Press F to shop";

// Shop inventory and prices
shopItems = [
    {name: "Potion", description: "Restores 50 HP", price: 25, sellPrice: 12, type: "item"},
    {name: "Hi-Potion", description: "Restores 200 HP", price: 100, sellPrice: 50, type: "item"},
    {name: "Ether", description: "Restores 30 MP", price: 75, sellPrice: 37, type: "item"},
    {name: "Phoenix Down", description: "Revives a fallen ally", price: 150, sellPrice: 75, type: "item"},
    {name: "Antidote", description: "Cures poison", price: 30, sellPrice: 15, type: "item"}
];

// Function to face the player based on their position
function FacePlayer() {
    if (!instance_exists(oPlayer)) return;
    
    // Get angle between shopkeeper and player
    var angle = point_direction(x, y, oPlayer.x, oPlayer.y);
    
    // Convert angle to direction based on exact frame descriptions:
    // Frame 0: Looks right
    // Frame 1: Looks up
    // Frame 2: Looks left
    // Frame 3: Looks down
    
    // Match player position to correct frame
    if ((angle >= 0 && angle < 45) || (angle >= 315 && angle <= 360)) {
        // Player is to the right, use frame 0 (looking right)
        image_index = 0;
    } else if (angle >= 45 && angle < 135) {
        // Player is above, use frame 1 (looking up)
        image_index = 1;
    } else if (angle >= 135 && angle < 225) {
        // Player is to the left, use frame 2 (looking left)
        image_index = 2; 
    } else if (angle >= 225 && angle < 315) {
        // Player is below, use frame 3 (looking down)
        image_index = 3;
    }
}

// Function to open shop menu
function OpenShop() {
    if (!instance_exists(oShopMenu)) {
        // Create shop menu
        instance_create_depth(0, 0, -10000, oShopMenu);
        isInteracting = true;
        show_debug_message("Shop opened");
    }
}

// Function to check if player is in range for interaction
function CheckPlayerRange() {
    playerInRange = false;
    
    if (instance_exists(oPlayer)) {
        var _dist = point_distance(x, y, oPlayer.x, oPlayer.y);
        playerInRange = (_dist <= interactionRange);
    }
    
    return playerInRange;
} 