// Create event for Slime enemy

// Assign a unique tag based on position and room
enemyTag = "slime_" + string(room) + "_" + string(x) + "_" + string(y);

// Display debug info
show_debug_message("Created slime with tag: " + enemyTag);

// Destroy this slime immediately if it was already defeated
if (variable_global_exists("defeatedEnemies") && ds_exists(global.defeatedEnemies, ds_type_map) && ds_map_exists(global.defeatedEnemies, enemyTag)) {
    show_debug_message("Spawned slime is already defeated (tag: " + enemyTag + "). Destroying.");
    instance_destroy();
} 