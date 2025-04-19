// Room Start event - handle post-battle cleanup and battle initialization
show_debug_message("Room start event - room: " + room_get_name(room) + " (oBattleManager)");

if (room == rm_battle) {
    // Ensure we have a battle manager in this room
    if (!instance_exists(oBattleManager)) {
        // Create using depth instead of layer
        instance_create_depth(0, 0, -10000, oBattleManager);
        show_debug_message("Created oBattleManager in battle room");
    }
    
    // We're entering the battle room, create the battle instance
    if (variable_global_exists("battleEnemyInstance")) {
        // Get the enemy type from battleEnemyInstance by checking its object_index
        var enemyType = [global.enemies.slimeG]; // Default to slime if something goes wrong
        var bgToUse = sBgField; // Default background
        var validEnemy = false;
        
        // Check if the enemy instance exists and is valid
        if (instance_exists(global.battleEnemyInstance)) {
            with (global.battleEnemyInstance) {
                // Store enemy position for tracking
                other.currentBattleEnemyX = x;
                other.currentBattleEnemyY = y;
                other.currentBattleEnemyRoom = room;
                if (variable_instance_exists(id, "enemyTag")) {
                    other.currentBattleEnemyTag = enemyTag;
                }
                
                if (object_index == oSlime) {
                    enemyType = [global.enemies.slimeG];
                    bgToUse = sBgField;
                    validEnemy = true;
                } else if (object_index == oBat) {
                    enemyType = [global.enemies.bat, global.enemies.bat];
                    bgToUse = sBgField;
                    validEnemy = true;
                }
                // Add more enemy types as needed
            }
        } else {
            // Added a debug message if enemy doesn't exist
            show_debug_message("Warning: battleEnemyInstance does not exist, using default enemy");
        }
        
        // Create the battle instance with proper configuration
        var battleInst = instance_create_depth(
            camera_get_view_x(view_camera[0]),
            camera_get_view_y(view_camera[0]),
            -9999,
            oBattle,
            {enemies: enemyType, creator: global.battleEnemyInstance, battleBackground: bgToUse}
        );
        
        // Set camera position for battle
        camera_set_view_pos(view_camera[0], 
            camera_get_view_x(view_camera[0]), 
            camera_get_view_y(view_camera[0]));
    } else {
        // If no battle enemy is set, create a default battle (for testing purpose)
        show_debug_message("No battleEnemyInstance set, creating default battle");
        var enemyType = [global.enemies.slimeG];
        var battleInst = instance_create_depth(
            camera_get_view_x(view_camera[0]),
            camera_get_view_y(view_camera[0]),
            -9999,
            oBattle,
            {enemies: enemyType, creator: noone, battleBackground: sBgField}
        );
    }
} else {
    // Handle returning to the overworld after battle
    if (variable_global_exists("battleOutcome")) {
        if (global.battleOutcome == "win") {
            show_debug_message("Returning to overworld with victory outcome - Room: " + room_get_name(room));
            
            // Mark the enemy as defeated using its tag
            if (currentBattleEnemyTag != "") {
                // Verify the tag isn't empty and the map exists
                if (ds_exists(global.defeatedEnemies, ds_type_map)) {
                    if (ds_map_exists(global.defeatedEnemies, currentBattleEnemyTag)) {
                        show_debug_message("NOTICE: Enemy already marked as defeated: " + currentBattleEnemyTag);
                    } else {
                        ds_map_add(global.defeatedEnemies, currentBattleEnemyTag, true);
                        show_debug_message("SUCCESS: Marked enemy with tag '" + currentBattleEnemyTag + "' as defeated");
                    }
                } else {
                    show_debug_message("ERROR: defeatedEnemies map doesn't exist!");
                    // Recreate the map if it doesn't exist
                    global.defeatedEnemies = ds_map_create();
                    ds_map_add(global.defeatedEnemies, currentBattleEnemyTag, true);
                    show_debug_message("RECOVERY: Recreated defeatedEnemies map and added enemy tag");
                }
            } else {
                show_debug_message("WARNING: Cannot mark enemy as defeated - no tag available");
            }
            
            // Reset battle outcome
            global.battleOutcome = "";
        }
        else if (global.battleOutcome == "lose") {
            show_debug_message("Returning to overworld after defeat - Room: " + room_get_name(room));
            
            // TODO: Handle player defeat consequences
            // For now, we'll just restore some HP to allow the player to continue
            with (global.party[0]) {
                hp = max(1, floor(hpMax * 0.1)); // Restore at least 1 HP, or 10% of max
            }
            
            show_debug_message("Restored minimal HP to player after defeat");
            
            // Reset battle outcome
            global.battleOutcome = "";
        }
    }
}

// Check and destroy any enemies that have already been defeated
show_debug_message("Checking for defeated enemies in room: " + room_get_name(room));

// Make sure the defeatedEnemies map exists
if (!variable_global_exists("defeatedEnemies") || !ds_exists(global.defeatedEnemies, ds_type_map)) {
    show_debug_message("WARNING: defeatedEnemies map doesn't exist or is invalid!");
    // Create it if it doesn't exist
    global.defeatedEnemies = ds_map_create();
    show_debug_message("Created new defeatedEnemies map");
}

// Get the size of the map to check if it has entries
var mapSize = ds_map_size(global.defeatedEnemies);
show_debug_message("Current defeated enemies map size: " + string(mapSize));

// Check all slimes in this room
with (oSlime) {
    // Make sure the enemy has a tag
    if (!variable_instance_exists(id, "enemyTag")) {
        // Create a tag if it doesn't exist
        enemyTag = "slime_" + string(room) + "_" + string(x) + "_" + string(y);
        show_debug_message("Created missing tag for existing slime: " + enemyTag);
    }
    
    // Debug info
    show_debug_message("Checking slime with tag: " + enemyTag);
    
    // Check if this enemy has been defeated
    if (ds_exists(global.defeatedEnemies, ds_type_map) && ds_map_exists(global.defeatedEnemies, enemyTag)) {
        show_debug_message("DESTROYING previously defeated slime with tag: " + enemyTag);
        instance_destroy();
    } else {
        show_debug_message("Keeping active slime with tag: " + enemyTag);
    }
}

// Check all bats in this room
with (oBat) {
    // Make sure the enemy has a tag
    if (!variable_instance_exists(id, "enemyTag")) {
        // Create a tag if it doesn't exist
        enemyTag = "bat_" + string(room) + "_" + string(x) + "_" + string(y);
        show_debug_message("Created missing tag for existing bat: " + enemyTag);
    }
    
    // Debug info
    show_debug_message("Checking bat with tag: " + enemyTag);
    
    // Check if this enemy has been defeated
    if (ds_exists(global.defeatedEnemies, ds_type_map) && ds_map_exists(global.defeatedEnemies, enemyTag)) {
        show_debug_message("DESTROYING previously defeated bat with tag: " + enemyTag);
        instance_destroy();
    } else {
        show_debug_message("Keeping active bat with tag: " + enemyTag);
    }
}