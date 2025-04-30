/// @description Handle input and animation

// Don't process input during battles
if (variable_global_exists("inBattle") && global.inBattle) {
    visible = false;
    return;
} else {
    visible = true;
}

// Toggle mini-map with the M key
if (keyboard_check_pressed(toggleKey)) {
    isMinimized = !isMinimized;
    isAnimating = true;
    animCounter = 0;
    animatingIn = !isMinimized;
    
    // Play a sound effect if available
    if (audio_exists(snd_select)) {
        audio_play_sound(snd_select, 1, false);
    }
}

// Handle animation
if (isAnimating) {
    animCounter++;
    
    if (animCounter >= animFrames) {
        isAnimating = false;
    }
}

// Update object lists once every 10 frames for performance
if (current_time % 10 == 0) {
    // Clear previous lists
    ds_list_clear(enemyList);
    ds_list_clear(npcList);
    
    // Get enemies in the room
    with (oSlime) {
        ds_list_add(other.enemyList, id);
    }
    
    with (oBat) {
        ds_list_add(other.enemyList, id);
    }
    
    // Add NPCs
    with (oShopKeeper) {
        ds_list_add(other.npcList, id);
    }
}

// Recreate the surface if it was lost
if (!surface_exists(mapSurface)) {
    mapSurface = surface_create(mapWidth, mapHeight);
    mapSurfaceExists = true;
} 