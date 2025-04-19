// Room Start event - handles transitions between rooms
show_debug_message("Player room start in: " + room_get_name(room));

if (instance_number(oPlayer) > 1) {
    // Keep only the one with the right ID
    if (id != instance_find(oPlayer, 0).id) {
        show_debug_message("Extra player instance found - destroying to prevent duplicates");
        instance_destroy();
        exit;
    }
}

// Set this object as persistent to maintain its existence between rooms
persistent = true;

// Check if we're returning from battle
if (variable_global_exists("battleOutcome") && (global.battleOutcome == "win" || global.battleOutcome == "lose")) {
    
    show_debug_message("BATTLE OUTCOME DETECTED: " + global.battleOutcome + " - Current room: " + room_get_name(room));
    show_debug_message("Pre-battle room was: " + room_get_name(global.playerPreBattleRoom)); 
    show_debug_message("Pre-battle X: " + string(global.playerPreBattleX));
    show_debug_message("Pre-battle Y: " + string(global.playerPreBattleY));
    
    // CRITICAL: Force position right away and with persistence
    x = global.playerPreBattleX;
    y = global.playerPreBattleY;
    
    // Create a 2-frame alarm to position player after room is fully loaded
    alarm[1] = 2;
    
    // Apply invincibility
    alarm[0] = 60; // 1 second invincibility 
    invincible = true;
    
    // Force enemy clearing as last resort
    global.forceClearEnemies = true;
    
}