// Only trigger battle if player isn't invincible
if (!variable_instance_exists(other, "invincible") || !other.invincible) {
    global.battleEnemyInstance = id; // Directly set the global variable
    
    // Make sure enemyTag exists
    if (!variable_instance_exists(id, "enemyTag")) {
        // Create a tag if it doesn't exist yet
        enemyTag = "bat_" + string(room) + "_" + string(x) + "_" + string(y);
        show_debug_message("Created missing tag: " + enemyTag);
    }
    
    // Debug message
    show_debug_message("Bat collision with player - battleEnemyInstance set to: " + string(id) + 
                        " at position " + string(x) + ", " + string(y) + 
                        " with tag " + enemyTag);
    
    // Save data to battle manager if it exists
    if (instance_exists(oBattleManager)) {
        oBattleManager.currentBattleEnemyID = id;
        oBattleManager.currentBattleEnemyX = x;
        oBattleManager.currentBattleEnemyY = y;
        oBattleManager.currentBattleEnemyRoom = room;
        oBattleManager.currentBattleEnemyTag = enemyTag;
    }
    
    // Call the updated NewEncounter function
    NewEncounter([global.enemies.bat, global.enemies.bat], sBgField);
}