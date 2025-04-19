// Room End event - save necessary data before room change
if (room == rm_battle && variable_global_exists("battleEnemyInstance") && instance_exists(global.battleEnemyInstance)) {
    // Store the enemy ID for when we return to the overworld
    currentBattleEnemyID = global.battleEnemyInstance;
    
    // Also store the enemy position
    with(global.battleEnemyInstance) {
        other.currentBattleEnemyX = x;
        other.currentBattleEnemyY = y;
        other.currentBattleEnemyRoom = global.playerPreBattleRoom;
    }
    
    show_debug_message("Saved battle enemy position: " + string(currentBattleEnemyX) + ", " + string(currentBattleEnemyY) + 
                       " in room " + room_get_name(currentBattleEnemyRoom));
}