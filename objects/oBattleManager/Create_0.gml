// Battle Manager - handles enemy persistence and battle outcomes
// Make this object persistent in the object properties

// Initialize permanent enemy tracking
// Instead of tracking by ID or position, we'll assign unique IDs to each enemy
if (!variable_global_exists("defeatedEnemies")) {
    global.defeatedEnemies = ds_map_create();
}

currentBattleEnemyID = noone;
currentBattleEnemyX = 0;
currentBattleEnemyY = 0;
currentBattleEnemyRoom = -1;
currentBattleEnemyTag = "";