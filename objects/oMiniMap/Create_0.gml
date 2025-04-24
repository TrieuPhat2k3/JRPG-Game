// Make the mini-map persistent
persistent = true;

// Check if another instance already exists
if (instance_number(oMiniMap) > 1) {
    instance_destroy();
    exit;
}

// Mini-map settings
visible = true;
size = 50; // Reduced from 100 to 50 (half size)
position = [10, 10]; // Top-left corner position
scale = 0.05; // Reduced from 0.1 to 0.05 (half scale)
borderColor = c_black;
backgroundColor = make_color_rgb(0, 0, 0); // Black color
backgroundColorAlpha = 0.5; // Alpha value for transparency
playerColor = c_red;
wallColor = c_white;

// Mini-map toggle
showMinimap = true; 