randomize();

// Create the battle manager if it doesn't exist
// THIS IS CRUCIAL
if (!instance_exists(oBattleManager)) {
    // Create using instance_create_depth which doesn't require a layer
    instance_create_depth(0, 0, -10000, oBattleManager);
    show_debug_message("Created oBattleManager at game initialization");
}

// Create the enemy destroyer if it doesn't exist
if (!instance_exists(oEnemyDestroyer)) {
    // Create using instance_create_depth which doesn't require a layer
    instance_create_depth(0, 0, -10000, oEnemyDestroyer);
    show_debug_message("Created oEnemyDestroyer at game initialization");
}

// Initialize global variables if they don't exist
if (!variable_global_exists("battleOutcome")) {
    global.battleOutcome = "";
}

if (!variable_global_exists("battleEnemyInstance")) {
    global.battleEnemyInstance = noone;
}

if (!variable_global_exists("playerPreBattleX")) {
    global.playerPreBattleX = 0;
}

if (!variable_global_exists("playerPreBattleY")) {
    global.playerPreBattleY = 0;
}

if (!variable_global_exists("playerPreBattleRoom")) {
    global.playerPreBattleRoom = rm_zone1; // Default starting room
}

if (!variable_global_exists("inBattle")) {
    global.inBattle = false;
}

// Add flag to force enemy clearing after battle
if (!variable_global_exists("forceClearEnemies")) {
    global.forceClearEnemies = false;
}

// Initialize the defeatedEnemies map if it doesn't exist
if (!variable_global_exists("defeatedEnemies") || !ds_exists(global.defeatedEnemies, ds_type_map)) {
    global.defeatedEnemies = ds_map_create();
    show_debug_message("Initialized defeatedEnemies map at game start");
}