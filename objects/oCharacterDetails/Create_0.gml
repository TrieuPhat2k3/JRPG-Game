// Initialize variables
visible = false;
depth = -10000; // Ensure it's drawn on top

// Get camera view dimensions
camWidth = camera_get_view_width(view_camera[0]);
camHeight = camera_get_view_height(view_camera[0]);

// Menu dimensions - use a percentage of camera view size for better scaling
menuWidth = min(camWidth * 0.4, 300); // 40% of camera width, max 300px
menuHeight = min(camHeight * 0.5, 250); // 50% of camera height, max 250px

// Menu animations
opening = false;
closing = false;
animationProgress = 0;
animationSpeed = 0.1;

// Character data
selectedCharacter = "";
characterData = {
    "LuLu": {
        name: "LuLu",
        level: 1,
        hp: 100,
        hpMax: 100,
        mp: 50,
        mpMax: 50,
        attack: 10,
        defense: 5
    },
    "Questy": {
        name: "Questy",
        level: 1,
        hp: 80,
        hpMax: 80,
        mp: 70,
        mpMax: 70,
        attack: 8,
        defense: 7
    }
};

// Handle opening the details box
function Open(character) {
    if (!visible) {
        selectedCharacter = character;
        visible = true;
        opening = true;
        closing = false;
        
        // Update position based on current camera view
        var camX = camera_get_view_x(view_camera[0]);
        var camY = camera_get_view_y(view_camera[0]);
        menuX = camX + (camWidth - menuWidth) / 2;
        menuY = camY + (camHeight - menuHeight) / 2;
    }
}

// Handle closing the details box
function Close() {
    if (visible) {
        closing = true;
        opening = false;
    }
} 