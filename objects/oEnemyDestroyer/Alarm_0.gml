// Check if we need to destroy an enemy
if (variable_global_exists("battleOutcome") && 
    global.battleOutcome == "win" && 
    variable_global_exists("battleEnemyInstance") && 
    instance_exists(global.battleEnemyInstance)) {
    
    // Destroy the enemy
    with(global.battleEnemyInstance) {
        show_debug_message("DESTROYER destroying enemy: " + string(id));
        instance_destroy();
    }
    
    // Reset battle outcome
    global.battleOutcome = "";
    global.battleEnemyInstance = noone;
}

// Check again in 5 steps
alarm[0] = 5;