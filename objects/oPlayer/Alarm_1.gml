// Delayed position reset after returning from battle
var posX = 0;
var posY = 0;

if (variable_global_exists("playerPreBattleX") && 
    variable_global_exists("playerPreBattleY")) {
    
    posX = global.playerPreBattleX;
    posY = global.playerPreBattleY;
    show_debug_message("Using global position vars: " + string(posX) + ", " + string(posY));
} else if (variable_instance_exists(id, "lastX") && 
           variable_instance_exists(id, "lastY")) {
    
    posX = lastX;
    posY = lastY;
    show_debug_message("Using backup position vars: " + string(posX) + ", " + string(posY));
} else {
    show_debug_message("WARNING: No position data found - position may be incorrect");
}

// Force the player position to the pre-battle coordinates
x = posX;
y = posY;

// Reset any depth or layer issues
depth = -1000; // Make sure player is visible

// Apply a brief cooldown to prevent immediate battles
alarm[0] = 60; // 1 second invincibility
invincible = true;

// Force enemy clearing after battle as last resort
global.forceClearEnemies = true;

// Reset battle outcome after position is set
global.battleOutcome = "";

// Keep trying to reset position for a few frames
alarm[2] = 5; // Try again in 5 frames 