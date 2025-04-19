function NewEncounter(_enemies, _bg)
{
    // Store player position and current room before battle
    global.playerPreBattleX = oPlayer.x;
    global.playerPreBattleY = oPlayer.y;
    global.playerPreBattleRoom = room;
    
    // Force oPlayer to be persistent
    oPlayer.persistent = true;
    
    // Double-check player position is saved correctly
    show_debug_message("!!! CRITICAL !!! SAVED PLAYER POSITION: " + 
                      string(global.playerPreBattleX) + ", " + 
                      string(global.playerPreBattleY) + 
                      " in room " + room_get_name(global.playerPreBattleRoom));
    
    // Store player position in a backup variable as well
    oPlayer.lastX = global.playerPreBattleX;
    oPlayer.lastY = global.playerPreBattleY;
    oPlayer.lastRoom = global.playerPreBattleRoom;
    
    // Store enemy ID directly as a global variable
    global.battleEnemyInstance = id; // This is the ID of the enemy that called this function
    
    // Double check we're saving the right instance
    var enemyObjectName = object_get_name(object_index);
    show_debug_message("Starting battle with enemy: " + enemyObjectName + " (ID: " + string(id) + ")");
    
    // Verify that the enemy instance is valid
    if (!instance_exists(global.battleEnemyInstance)) {
        show_debug_message("WARNING: battleEnemyInstance is not valid in NewEncounter!");
    }
    
    // Store the instance ID in the battle manager for reliable tracking
    if (instance_exists(oBattleManager)) {
        oBattleManager.currentBattleEnemyID = id;
        oBattleManager.currentBattleEnemyX = x;
        oBattleManager.currentBattleEnemyY = y;
        oBattleManager.currentBattleEnemyRoom = room;
        
        // Save the enemy tag if available
        if (variable_instance_exists(id, "enemyTag")) {
            oBattleManager.currentBattleEnemyTag = enemyTag;
            show_debug_message("Saved enemy tag to battle manager: " + enemyTag);
        }
        
        show_debug_message("Saved enemy ID to oBattleManager: " + string(id));
    } else {
        show_debug_message("WARNING: oBattleManager does not exist!");
    }
    
    // Music plays
    audio_play_sound(mus_battle1, true, true);
    audio_sound_gain(mus_battle1, 0.2, 0);
    
    // Create battle room - this should save all the globals we just set
    room_goto(rm_battle);
}

function BattleChangeHP(_target, _amount, _AliveDeadOrEither = 0)
{
	//_AliveDeadOrEither: 0 = alive only, 1 = dead only, 2 = any
	var _failed = false;
	if (_AliveDeadOrEither == 0) && (_target.hp <= 0) _failed = true;
	if (_AliveDeadOrEither == 1) && (_target.hp > 0) _failed = true;
	
	var _col = c_white;
	if (_amount > 0) _col = c_lime;
	// Apply defense reduction if the unit is defending
	/*
	if (_amount < 0 && variable_instance_exists(_target, "defenseBoost") && _target.defenseBoost) 
	{
		_amount = floor(_amount * 0.5); // Halve incoming damage
	}
	*/
	// Show floating text for feedback
	if (_failed)
	{
		_col = c_white;
		_amount = "failed";
	}
	instance_create_depth
	(
		_target.x,
		_target.y,
		_target.depth-1,
		oBattleFloatingText,
		{font: fnM5x7, col: _col, text: string(_amount)}
	);
	// Apply the HP change if valid.
	if (!_failed) _target.hp = clamp(_target.hp + _amount, 0, _target.hpMax);
}

function BattleChangeMP(_unit, _amount) {
    // Check if the unit exists and has an mp variable
    if (variable_instance_exists(_unit, "mp")) {
        _unit.mp += _amount; // Add (or subtract) MP by _amount

        // Ensure MP does not go below 0 or exceed the maximum allowed
        if (_unit.mp < 0) {
            _unit.mp = 0;
        } else if (_unit.mp > _unit.mpMax) {
            _unit.mp = _unit.mpMax;
        }
    }
}

function LevelUp(_character) {
    _character.level += 1;
    _character.hpMax += 10; // Increase max HP
    _character.mpMax += 5;  // Increase max MP
    _character.strength += 2; // Increase strength
    
    // Don't subtract XP here, it's already handled in the battle state
    // instead, just update the XP needed for next level
    _character.xpToNextLevel = ceil(_character.xpToNextLevel * 1.5); // Increase XP requirement
    
    _character.hp = _character.hpMax; // Heal fully
    _character.mp = _character.mpMax; // Restore MP
    
    // Debug message
    show_debug_message("LEVEL UP: " + _character.name + " is now level " + 
                        string(_character.level) + " with " + 
                        string(_character.hpMax) + " max HP and " + 
                        string(_character.strength) + " strength");
    show_debug_message("XP Progress: " + string(_character.xp) + "/" + 
                        string(_character.xpToNextLevel) + " to next level");
    
    // Force update the global party data directly to ensure it persists
    if (variable_global_exists("party")) {
        for (var i = 0; i < array_length(global.party); i++) {
            if (global.party[i].name == _character.name) {
                global.party[i].level = _character.level;
                global.party[i].hpMax = _character.hpMax;
                global.party[i].mpMax = _character.mpMax;
                global.party[i].strength = _character.strength;
                global.party[i].xpToNextLevel = _character.xpToNextLevel;
                global.party[i].hp = _character.hp;
                global.party[i].mp = _character.mp;
                global.party[i].xp = _character.xp;
                
                show_debug_message("Updated global party data for " + _character.name);
                show_debug_message("PERSISTENT DATA: " + _character.name + 
                                 " (Lv: " + string(global.party[i].level) + 
                                 ", XP: " + string(global.party[i].xp) + "/" + 
                                 string(global.party[i].xpToNextLevel) + ")");
                break;
            }
        }
    } else {
        show_error("Critical error: global.party does not exist during level up!", false);
    }
}