// Add at the beginning of the step event 
// Check if position was reset by something else after battle
if (variable_global_exists("battleOutcome") && 
    global.battleOutcome == "win" && 
    variable_global_exists("playerPreBattleX") && 
    variable_global_exists("playerPreBattleY")) {
    
    if (x != global.playerPreBattleX || y != global.playerPreBattleY) {
        show_debug_message("WARNING: Player position was changed from " + 
                          string(global.playerPreBattleX) + "," + string(global.playerPreBattleY) + 
                          " to " + string(x) + "," + string(y));
        
        // Force reset position again
        x = global.playerPreBattleX;
        y = global.playerPreBattleY;
    }
}

// Open inventory with 'I' key - FIXED to prevent rapid opening/closing
if (keyboard_check_pressed(ord("I")) && !global.inBattle) {
    // Check if inventory menu exists
    if (!instance_exists(oInventoryMenu)) {
        instance_create_depth(0, 0, -10000, oInventoryMenu);
    }
    
    // Toggle inventory visibility
    with (oInventoryMenu) {
        // Only toggle if animations are not in progress
        if (!opening && !closing) {
            Toggle();
        }
    }
}

// Toggle character status screen with 'G' key
if (keyboard_check_pressed(ord("G")) && !global.inBattle) {
    if (instance_exists(oCharacterStatus)) {
        // Menu is already open, let it handle its own closing
    } else {
        // Create new status menu at player's position to ensure visibility
        var statusMenu = instance_create_depth(x, y, -10000, oCharacterStatus);
        
        // Double-check creation
        if (statusMenu != noone) {
            // Ensure it's visible
            statusMenu.visible = true;
            
            // Play open sound if available
            if (audio_exists(snd_select)) {
                audio_play_sound(snd_select, 1, false);
            }
        }
    }
}

// Get input
var _inputH = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var _inputV = keyboard_check(ord("S")) - keyboard_check(ord("W"));
var _inputD = point_direction(0,0,_inputH,_inputV);
var _inputM = point_distance(0,0,_inputH,_inputV);

// Calculate new position
var _newX = x + lengthdir_x(spdWalk * _inputM, _inputD);
var _newY = y + lengthdir_y(spdWalk * _inputM, _inputD);

// Fetch the tilemap layer (if not fetched in create event)
if (!variable_instance_exists(self, "collisionLayer")) {
    collisionLayer = layer_tilemap_get_id("CollisionLayerName");
}

// Perform collision checks in both the X and Y directions separately
var _collisionTileX = tilemap_get_at_pixel(collisionLayer, _newX, y);
var _collisionTileY = tilemap_get_at_pixel(collisionLayer, x, _newY);

// Allow movement in Y and X if there's no collision in both directions
if (_collisionTileY == 0) {
    y = _newY;
}
if (_collisionTileX == 0) {
    x = _newX;
}

// Check if there is any movement in either direction
if (_inputM != 0 && (_collisionTileX == 0 || _collisionTileY == 0)) {
    // Checks if there's movement in any direction (X or Y) and no collision in that direction, will continue animation
    image_speed = 1;
    direction = _inputD;
} else if (_inputM != 0) {
    // Also checks if there's movement but blocked in one direction, still keep the animation playing
    image_speed = 1;
} else {
    image_speed = 0;
    animIndex = 0;
}

FourDirectionAnimate();