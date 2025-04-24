// Initialize variables
visible = false;
depth = -10000; // Ensure it's drawn on top

// Get camera view dimensions
camWidth = camera_get_view_width(view_camera[0]);
camHeight = camera_get_view_height(view_camera[0]);

// Menu dimensions - use a percentage of camera view size for better scaling
menuWidth = min(camWidth * 0.6, 400); // 60% of camera width, max 400px
menuHeight = min(camHeight * 0.7, 300); // 70% of camera height, max 300px

// Menu animations
opening = false;
closing = false;
animationProgress = 0;
animationSpeed = 0.1;

// Handle opening the stats box
function Open() {
    if (!visible) {
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

// Handle closing the stats box
function Close() {
    if (visible) {
        closing = true;
        opening = false;
    }
}

// Toggle the stats box's visibility
function Toggle() {
    if (visible) {
        Close();
    } else {
        Open();
    }
}

// Font settings
draw_set_font(fnOpenSansPX);
draw_set_halign(fa_left);
draw_set_valign(fa_top); 