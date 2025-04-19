// Basic initialization for battle units
// Will be overridden by child objects but provides fallbacks for safety

// Initialize sprites struct if it doesn't exist yet
if (!variable_instance_exists(id, "sprites")) {
    sprites = {
        idle: sLuluIdle  // Default fallback sprite
    };
}

// Only set sprite if we have a sprites struct
if (variable_instance_exists(id, "sprites") && 
    variable_struct_exists(sprites, "idle")) {
    sprite_index = sprites.idle;
}

// Initialize other critical variables with defaults
if (!variable_instance_exists(id, "hp")) hp = 1;
if (!variable_instance_exists(id, "hpMax")) hpMax = 1;
if (!variable_instance_exists(id, "name")) name = "Unknown";

// Debug output
show_debug_message("Parent BattleUnit initialized");

