instance_deactivate_all(true); // Deactivate all instances except self (oBattle)

// Add a variable to track if we're in a battle, to avoid confusion
global.inBattle = true;

units = [];
turn = 0;
unitTurnOrder = [];
unitRenderOrder = [];

turnCount = 0;
roundCount = 0;
battleWaitTimeFrames = 30;
battleWaitTimeRemaining = 0; // Fixed typo here
battleText = "";
currentUser = noone;
currentAction = -1;
currentTargets = noone;
action_perform_timer = 0; // Initialize the action timer

//Make targetting cursor
cursor =
{
	activeUser: noone,
	activeTarget : noone,
	activeAction : -1,
	targetSide : -1,
	targetIndex : 0,
	targetAll : false,
	confirmDelay : 0,
	active : false
};

// Define constants for enemy positioning
#macro ENEMY_START_X 250
#macro ENEMY_START_Y 68
#macro ENEMY_SPACING_X 40
#macro ENEMY_SPACING_Y 20
#macro ROW_HEIGHT_LIMIT 120 // Limit height to avoid overlapping menu
#macro MAX_ENEMIES 6 // Maximum number of enemies that can spawn
#macro MIN_ENEMIES 1 // Minimum number of enemies

// Define constants for party positioning
#macro PARTY_START_X 70
#macro PARTY_START_Y 68
#macro PARTY_SPACING_X 10
#macro PARTY_SPACING_Y 20

// Initialize battle units
enemyUnits = [];
partyUnits = [];
units = [];

// Randomize number of enemies
var enemyCount = irandom_range(MIN_ENEMIES, MAX_ENEMIES);

// Spawn enemies
for (var i = 0; i < enemyCount; i++) {
    // Randomly choose enemy type
    var enemyType = choose(global.enemies.slimeG, global.enemies.bat);

    // Calculate position
    var posX = x + ENEMY_START_X + ((i div 3) * ENEMY_SPACING_X); // Move horizontally after 3 enemies
    var posY = y + ENEMY_START_Y + ((i mod 3) * ENEMY_SPACING_Y); // Stack vertically

    // Ensure enemies don't overlap the UI
    if (posY > y + ROW_HEIGHT_LIMIT) {
        posX += ENEMY_SPACING_X; // Shift horizontally for new row
        posY = y + ENEMY_START_Y; // Reset Y position for new row
    }

    // Create enemy instance
    var enemyInstance = instance_create_depth(posX, posY, depth - 10, oBattleUnitEnemy, enemyType);

    // Add enemy to arrays
    enemyUnits[i] = enemyInstance;
    array_push(units, enemyInstance);
}

// Spawn party members
for (var i = 0; i < array_length(global.party); i++) {
    var posX = x + PARTY_START_X + (i * PARTY_SPACING_X);
    var posY = y + PARTY_START_Y + (i * PARTY_SPACING_Y);

    var partyInstance = instance_create_depth(posX, posY, depth - 10, oBattleUnitPC, global.party[i]);
    partyUnits[i] = partyInstance;
    array_push(units, partyInstance);
}

/*
// Define enemy and party positioning constants
#macro ENEMY_START_X 250
#macro ENEMY_START_Y 68
#macro ENEMY_SPACING_X 10
#macro ENEMY_SPACING_Y 20

#macro PARTY_START_X 70
#macro PARTY_START_Y 68
#macro PARTY_SPACING_X 10
#macro PARTY_SPACING_Y 15

#macro MAX_ENEMIES 3 // Maximum number of enemies that can spawn
#macro MIN_ENEMIES 1 // Minimum number of enemies

// Array to store battle units
enemyUnits = [];
partyUnits = [];
units = [];


// Randomize number of enemies
var enemyCount = irandom_range(MIN_ENEMIES, MAX_ENEMIES);

// Spawn enemies with randomized count
for (var i = 0; i < enemyCount; i++) {
    var posX = x + ENEMY_START_X + (i * ENEMY_SPACING_X);
    var posY = y + ENEMY_START_Y + (i * ENEMY_SPACING_Y);
    
    enemyUnits[i] = instance_create_depth(posX, posY, depth - 10, oBattleUnitEnemy, enemies[i mod array_length(enemies)]);
    array_push(units, enemyUnits[i]);
}

// Spawn party members
for (var i = 0; i < array_length(global.party); i++) {
    var posX = x + PARTY_START_X + (i * PARTY_SPACING_X);
    var posY = y + PARTY_START_Y + (i * PARTY_SPACING_Y);
    
    partyUnits[i] = instance_create_depth(posX, posY, depth - 10, oBattleUnitPC, global.party[i]);
    array_push(units, partyUnits[i]);
}
*/
// Shuffle turn order
unitTurnOrder = array_shuffle(units);

// Get render order
RefreshRenderOrder = function() {
    unitRenderOrder = [];
    array_copy(unitRenderOrder, 0, units, 0, array_length(units));
    array_sort(unitRenderOrder, function(_1, _2) {
        return _1.y - _2.y;
    });
}
RefreshRenderOrder();

// Define battle states
function BattleStateSelectAction() 
{
	if (!instance_exists(oMenu))
	{
	    // Get current unit
	    var _unit = unitTurnOrder[turn];
    
	    // Check if the unit is dead or unable to act
	    if (!instance_exists(_unit) || (_unit.hp <= 0)) {
	        battleState = BattleStateVictoryCheck;
	        return;
	    }
	    // Select an action to perform
	    //BeginAction(_unit.id, global.actionLibrary.attack, _unit.id);
	
		//If unit is player being controlled.
		if (_unit.object_index == oBattleUnitPC)
		{
			//Compile the action menu
			var _menuOptions = [];
			var _subMenus = {};
			
			var _actionList = _unit.actions;
			
			for (var i = 0; i < array_length(_actionList); i++)
			{
				var _action = _actionList[i];
				var _available = true; // later we'll check mp cost here..
				var _nameAndCount = _action.name; //later we'll modify the name to include the item count, if the action is a item.
				if (_action.subMenu == -1)
				{
					array_push(_menuOptions, [_nameAndCount, MenuSelectAction, [_unit, _action], _available]);
				}
				else
				{
					//create or add to a submenu
					if (is_undefined(_subMenus[$ _action.subMenu]))
					{
						// Initialize the submenu array if it doesn't exist
						variable_struct_set(_subMenus, _action.subMenu, [[_nameAndCount, MenuSelectAction, [_unit, _action], _available]]);
					}
					else
					{
						// Add to the existing submenu array
						array_push(_subMenus[$ _action.subMenu], [_nameAndCount, MenuSelectAction, [_unit, _action], _available]);
					}
					
				}
			}
				//turn sub menus into an array
				var _subMenusArray = variable_struct_get_names(_subMenus);
				for (var i = 0; i < array_length(_subMenusArray); i++)
				{
					// sort submenu if needed
					// (here)
						
					//add back option at the end of each submenu
					array_push(_subMenus[$ _subMenusArray[i]], ["Back", MenuGoBack, -1, true]);
					//add submenu into main menu
					array_push(_menuOptions, [_subMenusArray[i], SubMenu, [_subMenus[$ _subMenusArray[i]]], true]);
				}
				
				Menu(x+10, y+110, _menuOptions, , 74, 60);
		}
		else
		{
			var _enemyAction = _unit.AIscript();
			if (_enemyAction != 1) BeginAction(_unit.id, _enemyAction[0], _enemyAction[1]);
		}
	}
}

BeginAction = function(_user, _action, _targets) {
    currentUser = _user;
    currentAction = _action;
    currentTargets = _targets;
	battleText = string_ext(_action.description, [_user.name]);
    if (!is_array(currentTargets)) currentTargets = [_targets];
    battleWaitTimeRemaining = battleWaitTimeFrames;
    action_perform_timer = battleWaitTimeFrames; // Set the action timer
    with (_user) {
        acting = true;
        // Play user animation if defined
        if (!is_undefined(_action[$ "userAnimation"]) && !is_undefined(sprites[$ _action.userAnimation])) {
            sprite_index = sprites[$ _action.userAnimation];
            image_index = 0;
        }
    }
    battleState = BattleStatePerformAction;
}

BattleStatePerformAction = function() {
    // If the animation is still playing
    if (currentUser.acting) {
        // When it ends, perform the action effects if they exist
        if (currentUser.image_index >= currentUser.image_number - 1) {
            with (currentUser) {
                sprite_index = sprites.idle;
                image_index = 0;
                acting = false;
            }
            if (variable_struct_exists(currentAction, "effectSprite")) {
                if (currentAction.effectOnTarget == MODE.ALWAYS || 
                    (currentAction.effectOnTarget == MODE.VARIES && array_length(currentTargets) <= 1)) {
                    for (var i = 0; i < array_length(currentTargets); i++) {
                        instance_create_depth(currentTargets[i].x, currentTargets[i].y, currentTargets[i].depth - 1, oBattleEffect, { sprite_index: currentAction.effectSprite });
                    }
                } else {
                    var _effectSprite = currentAction.effectSprite;
                    if (variable_struct_exists(currentAction, "effectSpriteNoTarget")) {
                        _effectSprite = currentAction.effectSpriteNoTarget;
                    }
                    instance_create_depth(x, y, depth - 100, oBattleEffect, { sprite_index: _effectSprite });
                }
            }
            currentAction.func(currentUser, currentTargets);
        }
    } else {
        if (!instance_exists(oBattleEffect)) {
            // Decrement the action timer
            action_perform_timer--;
            
            if (action_perform_timer <= 0) {
                // Check if all enemies are defeated
                var allEnemiesDefeated = true;
                for (var i = 0; i < array_length(enemyUnits); i++) {
                    if (enemyUnits[i].hp > 0) {
                        allEnemiesDefeated = false;
                        break;
                    }
                }
                
                // Check if all party members are defeated
                var allPartyDefeated = true;
                for (var i = 0; i < array_length(partyUnits); i++) {
                    if (partyUnits[i].hp > 0) {
                        allPartyDefeated = false;
                        break;
                    }
                }
                
                // If all party members are defeated, go to game over
                if (allPartyDefeated) {
                    // Player has lost the battle
                    // Stop battle music
                    audio_stop_sound(mus_battle1);
                    
                    // Set the battle outcome to lose
                    global.battleOutcome = "lose";
                    
                    // Display game over message
                    battleText = "Game Over! Your party was defeated!";
                    battleWaitTimeRemaining = 180;
                    battleState = BattleStateGameOver;
                    return;
                }
                
                if (allEnemiesDefeated) {
                    // All enemies are defeated, go straight to victory state
                    battleState = BattleStateVictoryCheck;
                } else {
                    // Normal case - continue battle
                    battleState = BattleStateTurnProgression;
                }
            }
        }
    }
}

BattleStateVictoryCheck = function() {
    // Check if all enemies are defeated
    var allEnemiesDefeated = true;
    for (var i = 0; i < array_length(unitTurnOrder); i++) {
        var unit = unitTurnOrder[i];
        if (unit.object_index == oBattleUnitEnemy && unit.hp > 0) {
            allEnemiesDefeated = false;
            break;
        }
    }
    
    // Check if all party members are defeated
    var allPartyDefeated = true;
    for (var i = 0; i < array_length(partyUnits); i++) {
        if (partyUnits[i].hp > 0) {
            allPartyDefeated = false;
            break;
        }
    }
    
    if (allPartyDefeated) {
        // Player has lost the battle
        // Stop battle music
        audio_stop_sound(mus_battle1);
        
        // Set the battle outcome to lose
        global.battleOutcome = "lose";
        
        // Display game over message
        battleText = "Game Over! Your party was defeated!";
        battleWaitTimeRemaining = 180;
        battleState = BattleStateGameOver;
        
        return;
    }
    
    if (allEnemiesDefeated) {
        // Stop battle music
        audio_stop_sound(mus_battle1);
        
        // Calculate total XP gained
        totalXP = 0; // Save total XP globally so we can process it later
        currentPartyIndex = 0; // Start with the first party member
        
        for (var i = 0; i < array_length(unitTurnOrder); i++) {
            var unit = unitTurnOrder[i];
            if (unit.object_index == oBattleUnitEnemy && unit.hp <= 0) {
                totalXP += unit.xpValue; // XP from defeated enemies
            }
        }
        
        battleState = BattleStateDistributeXP;
    } else {
        battleState = BattleStateTurnProgression;
    }
};

BattleStateDistributeXP = function() {
    if (currentPartyIndex >= array_length(global.party)) {
        // All party members have been processed; return to map
        global.battleOutcome = "win";
        show_debug_message("SET BATTLE OUTCOME TO WIN");
        
        // Make sure the battle manager has the correct enemy tag
        if (instance_exists(oBattleManager) && variable_global_exists("battleEnemyInstance")) {
            // Save the enemy tag to mark it as defeated
            if (instance_exists(global.battleEnemyInstance)) {
                with (global.battleEnemyInstance) {
                    // Ensure enemy has a tag
                    if (!variable_instance_exists(id, "enemyTag")) {
                        if (object_index == oSlime) {
                            enemyTag = "slime_" + string(room) + "_" + string(x) + "_" + string(y);
                        } else if (object_index == oBat) {
                            enemyTag = "bat_" + string(room) + "_" + string(x) + "_" + string(y);
                        } else {
                            enemyTag = "enemy_" + string(room) + "_" + string(x) + "_" + string(y);
                        }
                        show_debug_message("Created missing tag for enemy in battle: " + enemyTag);
                    }
                    
                    // Make sure defeatedEnemies exists
                    if (!variable_global_exists("defeatedEnemies") || !ds_exists(global.defeatedEnemies, ds_type_map)) {
                        global.defeatedEnemies = ds_map_create();
                        show_debug_message("Created defeatedEnemies map in battle victory");
                    }
                    
                    oBattleManager.currentBattleEnemyTag = enemyTag;
                    show_debug_message("Battle victory - saving enemy tag: " + enemyTag);
                    
                    // Mark as defeated right away
                    if (variable_global_exists("defeatedEnemies") && ds_exists(global.defeatedEnemies, ds_type_map)) {
                        if (!ds_map_exists(global.defeatedEnemies, enemyTag)) {
                            ds_map_add(global.defeatedEnemies, enemyTag, true);
                            show_debug_message("BATTLE VICTORY: Immediately marking enemy as defeated: " + enemyTag);
                        } else {
                            show_debug_message("NOTICE: Enemy already marked as defeated: " + enemyTag);
                        }
                    } else {
                        show_debug_message("ERROR: defeatedEnemies map doesn't exist or is invalid!");
                    }
                }
            } else {
                show_debug_message("WARNING: battleEnemyInstance does not exist at victory!");
            }
        } else {
            show_debug_message("ERROR: oBattleManager or battleEnemyInstance don't exist at victory!");
        }
        
        // Force position update - CRITICAL
        global.forceClearEnemies = true;
        
        // Direct enemy destruction before returning to the map
        // This is a failsafe in case the oBattleManager approach fails
        if (variable_global_exists("battleEnemyInstance") && instance_exists(global.battleEnemyInstance)) {
            // Destroy the enemy directly before returning to the map
            with(global.battleEnemyInstance) {
                show_debug_message("DIRECTLY destroying enemy from battle: " + string(id));
                instance_destroy();
            }
        }
        
        // Add additional logging
        show_debug_message("BATTLE VICTORY - Enemy to destroy: " + string(global.battleEnemyInstance));
        
        // Clean up battle UI elements
        with (oMenu) instance_destroy();
        with (oBattleFloatingText) instance_destroy();
        with (oBattleEffect) instance_destroy();
        
        // Mark that we're no longer in battle
        global.inBattle = false;
        
        // Reactivate all instances before leaving the battle
        instance_activate_all();
        
        // Make sure player position is properly saved
        show_debug_message("Preparing to return player to: " + 
                          string(global.playerPreBattleX) + ", " + 
                          string(global.playerPreBattleY) + 
                          " in room " + room_get_name(global.playerPreBattleRoom));
        
        // Return to previous room
        room_goto(global.playerPreBattleRoom);
        return;
    }
    
    // Safety check - if all party members have 0 HP, just go to victory screen
    var allPartyDead = true;
    for (var i = 0; i < array_length(global.party); i++) {
        if (global.party[i].hp > 0) {
            allPartyDead = false;
            break;
        }
    }
    
    if (allPartyDead) {
        // Skip XP distribution if all party members are dead
        currentPartyIndex = array_length(global.party);
        // Call this function again to trigger the end battle logic
        BattleStateDistributeXP();
        return;
    }
    
    var partyMember = global.party[currentPartyIndex];
    if (partyMember.hp > 0) { // Only alive members receive XP
        partyMember.xp += totalXP;
        
        while (partyMember.xp >= partyMember.xpToNextLevel) {
            partyMember.xp -= partyMember.xpToNextLevel;
            LevelUp(partyMember);
            
            // Show level-up text and pause
            battleText = partyMember.name + " leveled up to level " + string(partyMember.level) + "!";
            battleWaitTimeRemaining = 180;
            battleState = BattleStateShowText;
            return;
        }
    }
    
    // Move to the next party member
    currentPartyIndex++;
    
    // Continue XP distribution in the next step
    // Don't need to explicitly set the state because we're already in BattleStateDistributeXP
}

BattleStateShowText = function() {
    battleWaitTimeRemaining--;
    if (battleWaitTimeRemaining <= 0) {
        battleState = BattleStateDistributeXP; // Return to XP distribution
    }
}

BattleStateTurnProgression = function() {
    battleText = ""; // Reset battle
	turnCount++; // Total turns
    turn++;
    // Loop turns
    if (turn > array_length(unitTurnOrder) - 1) {
        turn = 0;
        roundCount++;
    }
    battleState = BattleStateSelectAction;
}

// Start the battle state machine
battleState = BattleStateSelectAction;

// Add new state for game over
BattleStateGameOver = function() {
    battleWaitTimeRemaining--;
    if (battleWaitTimeRemaining <= 0) {
        // Clean up battle UI elements
        with (oMenu) instance_destroy();
        with (oBattleFloatingText) instance_destroy();
        with (oBattleEffect) instance_destroy();
        
        // Mark that we're no longer in battle
        global.inBattle = false;
        
        // Make sure player position is properly saved
        show_debug_message("Preparing to return player to: " + 
                          string(global.playerPreBattleX) + ", " + 
                          string(global.playerPreBattleY) + 
                          " in room " + room_get_name(global.playerPreBattleRoom));
        
        // Reactivate all instances before leaving the battle
        instance_activate_all();
        
        // Return to the previous room
        room_goto(global.playerPreBattleRoom);
        return;
    }
}
