// Special step event to handle enemy cleanup
if (global.forceClearEnemies) {
    show_debug_message("Force clearing enemies triggered!");
    global.forceClearEnemies = false;
    
    // Get the tag from battle manager
    var enemyTag = "";
    if (instance_exists(oBattleManager) && variable_instance_exists(oBattleManager, "currentBattleEnemyTag")) {
        enemyTag = oBattleManager.currentBattleEnemyTag;
    }
    
    // Tag-based approach - most reliable
    if (enemyTag != "") {
        // Mark this tag as defeated
        if (variable_global_exists("defeatedEnemies")) {
            ds_map_add(global.defeatedEnemies, enemyTag, true);
            show_debug_message("Marked enemy tag as defeated: " + enemyTag);
        }
        
        // Check all slimes for this tag
        with (oSlime) {
            if (variable_instance_exists(id, "enemyTag")) {
                show_debug_message("Comparing slime tag: " + enemyTag + " with " + self.enemyTag);
                if (self.enemyTag == enemyTag) {
                    show_debug_message("MATCH FOUND! Destroying slime with matching tag: " + enemyTag);
                    instance_destroy();
                }
            }
        }
        
        // Check all bats for this tag
        with (oBat) {
            if (variable_instance_exists(id, "enemyTag")) {
                show_debug_message("Comparing bat tag: " + enemyTag + " with " + self.enemyTag);
                if (self.enemyTag == enemyTag) {
                    show_debug_message("MATCH FOUND! Destroying bat with matching tag: " + enemyTag);
                    instance_destroy();
                }
            }
        }
    }
    
    // Direct ID approach
    if (variable_global_exists("battleEnemyInstance") && instance_exists(global.battleEnemyInstance)) {
        with (global.battleEnemyInstance) {
            show_debug_message("Direct destroy from destroyer: " + string(id));
            instance_destroy();
        }
    }
    
    // Position-based approach
    if (instance_exists(oBattleManager)) {
        var x_pos = oBattleManager.currentBattleEnemyX;
        var y_pos = oBattleManager.currentBattleEnemyY;
        
        // Check all enemies at this position
        if (x_pos != 0 && y_pos != 0) {
            with (oSlime) {
                if (point_distance(x, y, x_pos, y_pos) < 20) {
                    show_debug_message("Destroying slime at position: " + string(x) + ", " + string(y));
                    instance_destroy();
                }
            }
            
            with (oBat) {
                if (point_distance(x, y, x_pos, y_pos) < 20) {
                    show_debug_message("Destroying bat at position: " + string(x) + ", " + string(y));
                    instance_destroy();
                }
            }
        }
    }
}

alarm[0] = 5; // Start the recurring enemy destroyer alarm