// Full cleanup triggered at battle end
if (global.forceClearEnemies) {
    show_debug_message("Force clearing enemies triggered!");
    global.forceClearEnemies = false;

    // Tag-based removal
    var enemyTag = "";
    if (instance_exists(oBattleManager) && variable_instance_exists(oBattleManager, "currentBattleEnemyTag")) {
        enemyTag = oBattleManager.currentBattleEnemyTag;
    }
    if (enemyTag != "") {
        ds_map_add(global.defeatedEnemies, enemyTag, true);
        show_debug_message("Marked enemy tag as defeated: " + enemyTag);
        with (oSlime) {
            if (variable_instance_exists(id, "enemyTag") && self.enemyTag == enemyTag) instance_destroy();
        }
        with (oBat) {
            if (variable_instance_exists(id, "enemyTag") && self.enemyTag == enemyTag) instance_destroy();
        }
    }

    // Direct ID removal
    if (variable_global_exists("battleEnemyInstance") && instance_exists(global.battleEnemyInstance)) {
        with (global.battleEnemyInstance) {
            show_debug_message("DESTROYER destroying enemy: " + string(id));
            instance_destroy();
        }
        global.battleEnemyInstance = noone;
    }

    // Position-based removal
    var x_pos = oBattleManager.currentBattleEnemyX;
    var y_pos = oBattleManager.currentBattleEnemyY;
    with (oSlime) {
        if (point_distance(x, y, x_pos, y_pos) < 20) instance_destroy();
    }
    with (oBat) {
        if (point_distance(x, y, x_pos, y_pos) < 20) instance_destroy();
    }
}

// Check again in 5 steps
alarm[0] = 5;