// Final attempt at position restoration
if (variable_global_exists("playerPreBattleX") && 
    variable_global_exists("playerPreBattleY")) {
    
    // Final super-aggressive position setting
    x = global.playerPreBattleX;
    y = global.playerPreBattleY;
    
    // Direct position setting
    position_set(global.playerPreBattleX, global.playerPreBattleY);
} 