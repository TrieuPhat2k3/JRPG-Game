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

// Initialize XP tracking variables
totalBattleXP = 0;
xpPerMember = 0;
totalXP = 0;
defeatedEnemyCount = 0;
currentPartyIndex = 0;

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
show_debug_message("========== SPAWNING PARTY MEMBERS ==========");

// Add verification of party data before spawning battle units
if (variable_global_exists("party")) {
    show_debug_message("Verifying party data before battle:");
    for (var i = 0; i < array_length(global.party); i++) {
        show_debug_message("PRE-BATTLE CHECK: " + global.party[i].name + 
                         " (Lv: " + string(global.party[i].level) + 
                         ", XP: " + string(global.party[i].xp) + "/" + 
                         string(global.party[i].xpToNextLevel) + ")");
    }
} else {
    show_error("Critical error: global.party does not exist before battle!", true);
}

// Create a global variable to pass template data
if (!variable_global_exists("currentUnitTemplate")) {
    global.currentUnitTemplate = noone;
}

for (var i = 0; i < array_length(global.party); i++) {
    var posX = x + PARTY_START_X + (i * PARTY_SPACING_X);
    var posY = y + PARTY_START_Y + (i * PARTY_SPACING_Y);

    // Log party member details before creating battle unit
    var member = global.party[i];
    show_debug_message("Party member data: " + member.name + 
                     ", Level: " + string(member.level) + 
                     ", HP: " + string(member.hp) + "/" + string(member.hpMax) +
                     ", XP: " + string(member.xp) + "/" + string(member.xpToNextLevel));
    
    // Use a global variable to pass the template data
    global.currentUnitTemplate = member;
    show_debug_message("Set global.currentUnitTemplate to: " + global.currentUnitTemplate.name);
    
    // Create battle unit instance (template will be accessed via global var)
    var partyInstance = instance_create_depth(posX, posY, depth - 10, oBattleUnitPC);
    partyUnits[i] = partyInstance;
    array_push(units, partyInstance);
    
    // Verify the battle unit was created with correct stats
    if (instance_exists(partyInstance)) {
        show_debug_message("Battle unit created: " + partyInstance.name + 
                         ", Level: " + string(partyInstance.level) + 
                         ", HP: " + string(partyInstance.hp) + "/" + string(partyInstance.hpMax) +
                         ", Actions: " + string(array_length(partyInstance.actions)));
    } else {
        show_debug_message("ERROR: Failed to create battle unit for " + member.name);
    }
}

// Clear the template to avoid memory issues
global.currentUnitTemplate = noone;

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
				var _available = true; // Default to available
				
				// Check if action has MP cost and if player has enough MP
				if (variable_struct_exists(_action, "mpCost")) {
					if (_unit.mp < _action.mpCost) {
						_available = false; // Not enough MP to use this action
					}
				}
				
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
				
				// Add an Items option to the main menu
				array_push(_menuOptions, ["Items", MenuSelectItem, [global.inventory, _unit], true]);
				
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
		
        totalBattleXP = 0;
		xpPerMember = 0;
		totalXP = 0;
		defeatedEnemyCount = 0;
		currentPartyIndex = 0;
		
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
        
        // Calculate total XP gained from all defeated enemies
        totalXP = 0;
        defeatedEnemyCount = 0;
        currentPartyIndex = 0; // Start with the first party member
        
        // Count defeated enemies and accumulate total XP
        for (var i = 0; i < array_length(unitTurnOrder); i++) {
            var unit = unitTurnOrder[i];
            if (unit.object_index == oBattleUnitEnemy && unit.hp <= 0) {
                totalXP += unit.xpValue; // XP from defeated enemies
                defeatedEnemyCount++;
            }
        }
        
        // Apply a multiplier based on number of enemies defeated
        // More enemies = more XP per enemy
        var xpMultiplier = 1.0;
        if (defeatedEnemyCount >= 3) xpMultiplier = 1.3;
        else if (defeatedEnemyCount >= 2) xpMultiplier = 1.15;
        
        // Apply the multiplier to total XP
        totalXP = round(totalXP * xpMultiplier);
        
        // Calculate XP per party member (equal distribution)
        var alivePartyCount = 0;
        for (var i = 0; i < array_length(partyUnits); i++) {
            if (partyUnits[i].hp > 0) alivePartyCount++;
        }
        
        // Store both total and per-member XP
        totalBattleXP = totalXP;
        xpPerMember = (alivePartyCount > 0) ? totalXP : 0;
        
        battleState = BattleStateDistributeXP;
    } else {
        battleState = BattleStateTurnProgression;
    }
};

BattleStateDistributeXP = function() {
    if (currentPartyIndex >= array_length(global.party)) {
        // All party members have been processed; properly sync data
        SyncPartyDataWithUnits();
        
        // Create XP backup after XP has been distributed
        SaveXPBackup();
        
        // Show XP gain message before proceeding
        battleText = "Gained " + string(totalBattleXP) + " XP!";
        battleWaitTimeRemaining = 120;
        battleState = BattleStateShowXPGain;
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
        // Store initial XP for logging
        var initialXP = partyMember.xp;
        
        // Add XP to this party member
        partyMember.xp += xpPerMember;
        
        // Debug log XP gain explicitly
        show_debug_message("XP GAIN: " + partyMember.name + " gained " + string(xpPerMember) + 
                         " XP (" + string(initialXP) + " -> " + string(partyMember.xp) + ")");
        
        // CRITICAL: Update battle unit XP to match party XP
        if (currentPartyIndex < array_length(partyUnits) && instance_exists(partyUnits[currentPartyIndex])) {
            show_debug_message("UPDATING BATTLE UNIT XP: " + partyUnits[currentPartyIndex].name + 
                            " from " + string(partyUnits[currentPartyIndex].xp) + 
                            " to " + string(partyMember.xp));
            partyUnits[currentPartyIndex].xp = partyMember.xp;
        }
        
        // Check for level ups
        var leveledUp = false;
        while (partyMember.xp >= partyMember.xpToNextLevel) {
            // Save XP overflow before level up
            var overflow = partyMember.xp - partyMember.xpToNextLevel;
            
            // Reset XP to overflow amount only
            partyMember.xp = 0;
            
            // Perform level up
            LevelUp(partyMember);
            leveledUp = true;
            
            // Restore overflow XP after updating XP to next level
            partyMember.xp = overflow;
            
            // Also update the corresponding battle unit
            if (currentPartyIndex < array_length(partyUnits)) {
                // Copy the updated stats from global.party to the battle unit
                partyUnits[currentPartyIndex].level = partyMember.level;
                partyUnits[currentPartyIndex].hp = partyMember.hp;
                partyUnits[currentPartyIndex].hpMax = partyMember.hpMax;
                partyUnits[currentPartyIndex].mp = partyMember.mp;
                partyUnits[currentPartyIndex].mpMax = partyMember.mpMax;
                partyUnits[currentPartyIndex].strength = partyMember.strength;
                partyUnits[currentPartyIndex].xp = partyMember.xp;
                partyUnits[currentPartyIndex].xpToNextLevel = partyMember.xpToNextLevel;
            }
        }
        
        if (leveledUp) {
            // Show level-up text and pause
            battleText = partyMember.name + " leveled up to level " + string(partyMember.level) + "!";
            battleWaitTimeRemaining = 180;
            battleState = BattleStateShowText;
            
            // Make sure to sync data immediately
            SyncPartyDataWithUnits();
            
            return;
        }
    }
    
    // Move to the next party member
    currentPartyIndex++;
}

BattleStateShowText = function() {
    battleWaitTimeRemaining--;
    if (battleWaitTimeRemaining <= 0) {
        battleState = BattleStateDistributeXP; // Return to XP distribution
    }
}

// New state to show total XP gain
BattleStateShowXPGain = function() {
    battleWaitTimeRemaining--;
    if (battleWaitTimeRemaining <= 0) {
        // Do one final verification of XP just before battle end
        show_debug_message("FINAL XP VERIFICATION BEFORE MAP RETURN:");
        for (var i = 0; i < array_length(global.party); i++) {
            if (i < array_length(partyUnits) && instance_exists(partyUnits[i])) {
                if (global.party[i].xp != partyUnits[i].xp) {
                    show_debug_message("XP MISMATCH DETECTED! Fixing: " + global.party[i].name + 
                                    " Party: " + string(global.party[i].xp) + 
                                    ", Battle Unit: " + string(partyUnits[i].xp));
                    global.party[i].xp = partyUnits[i].xp;
                } else {
                    show_debug_message("XP VERIFIED: " + global.party[i].name + 
                                    " XP: " + string(global.party[i].xp) + 
                                    " (Expected total: " + string(xpPerMember) + ")");
                }
            }
        }
        
        // Create XP backup one more time after verification
        SaveXPBackup();
        
        // Then proceed with drop processing
        global.battleOutcome = "win";
        show_debug_message("SET BATTLE OUTCOME TO WIN");
        
        // Process enemy drops - ONLY ONCE PER BATTLE
        // Use a regular variable instead of static - will reset for each new battle
        if (!variable_instance_exists(id, "dropsProcessed")) {
            dropsProcessed = false;
        }
        
        if (!dropsProcessed) {
            dropsProcessed = true; // Mark drops as processed to prevent loops
            var droppedItems = [];
            var totalGold = 0;
            
            // Go through all defeated enemy units
            for (var i = 0; i < array_length(unitTurnOrder); i++) {
                var unit = unitTurnOrder[i];
                if (unit.object_index == oBattleUnitEnemy && unit.hp <= 0) {
                    // For each enemy type, calculate drops
                    var enemyType = "";
                    if (unit.name == "Slime") enemyType = "slimeG";
                    else if (unit.name == "Bat") enemyType = "bat";
                    
                    if (enemyType != "") {
                        // Get drops for this enemy
                        var drops = DropItemFromEnemy(enemyType);
                        
                        // Combine drops
                        for (var j = 0; j < array_length(drops.items); j++) {
                            array_push(droppedItems, drops.items[j]);
                        }
                        
                        totalGold += drops.gold;
                    }
                }
            }
            
            // Show drop message
            var dropMessage = "";
            if (array_length(droppedItems) > 0) {
                dropMessage = "Got items: " + string_join(", ", droppedItems);
            }
            
            if (totalGold > 0) {
                if (dropMessage != "") dropMessage += ", ";
                dropMessage += "Got " + string(totalGold) + " gold!";
            }
            
            if (dropMessage != "") {
                show_debug_message("DROP MESSAGE: " + dropMessage);
                battleText = dropMessage;
                battleWaitTimeRemaining = 180; // Longer pause to see the drops
                battleState = BattleStateShowDrops;
                return;
            }
        }
        
        // If no drops, move to cleanup and return to map
        EndBattleAndReturnToMap();
    }
}

// Add this after BattleStateShowText function
BattleStateShowDrops = function() {
    battleWaitTimeRemaining--;
    if (battleWaitTimeRemaining <= 0) {
        // Sync party data with battle units then end battle
        EndBattleAndReturnToMap();
    }
}

// New function to handle the cleanup and return to map
function EndBattleAndReturnToMap() {
    // Sync party data with battle units
    SyncPartyDataWithUnits();
    
    // Final emergency XP backup before map return
    SaveXPBackup();
    
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
        }
    }
    
    // Force position update - CRITICAL
    global.forceClearEnemies = true;
    
    // Direct enemy destruction before returning to the map
    if (variable_global_exists("battleEnemyInstance") && instance_exists(global.battleEnemyInstance)) {
        // Destroy the enemy directly before returning to the map
        with(global.battleEnemyInstance) {
            show_debug_message("DIRECTLY destroying enemy from battle: " + string(id));
            instance_destroy();
        }
    }
    
    // Clean up battle UI elements
    with (oMenu) instance_destroy();
    with (oBattleFloatingText) instance_destroy();
    with (oBattleEffect) instance_destroy();
    
    // Final XP verification before leaving battle
    if (global.battleOutcome == "win" && variable_global_exists("party")) {
        show_debug_message("========= FINAL XP VERIFICATION BEFORE MAP RETURN =========");
        
        // Create emergency XP backup if it doesn't exist
        if (!variable_global_exists("partyXPBackup")) {
            global.partyXPBackup = [];
            array_resize(global.partyXPBackup, array_length(global.party));
            show_debug_message("Created missing partyXPBackup in EndBattleAndReturnToMap");
        }
        
        // Explicitly save current XP values for each party member
        for (var i = 0; i < array_length(global.party); i++) {
            if (i >= array_length(global.partyXPBackup)) {
                global.partyXPBackup[i] = {};
            }
            
            // Save essential XP data
            global.partyXPBackup[i].name = global.party[i].name;
            global.partyXPBackup[i].level = global.party[i].level;
            global.partyXPBackup[i].xp = global.party[i].xp;
            global.partyXPBackup[i].xpToNextLevel = global.party[i].xpToNextLevel;
            
            show_debug_message("FINAL XP SAVE: " + global.party[i].name + 
                             " Level: " + string(global.party[i].level) + 
                             ", XP: " + string(global.party[i].xp) + "/" + 
                             string(global.party[i].xpToNextLevel));
        }
        
        // Also save the total XP earned as a backup reference
        if (variable_instance_exists(id, "xpPerMember")) {
            global.battleXPEarned = xpPerMember;
            show_debug_message("FINAL XP BACKUP: " + string(global.battleXPEarned) + " per member");
        }
        
        show_debug_message("========= XP VERIFICATION COMPLETE =========");
    }
    
    // Mark that we're no longer in battle
    global.inBattle = false;
    
    // Reactivate all instances before leaving the battle
    instance_activate_all();
    
    // Return to previous room
    room_goto(global.playerPreBattleRoom);
}

// Add this new function after BattleStateShowDrops
function SyncPartyDataWithUnits() {
    show_debug_message("===== SYNCING PARTY DATA WITH BATTLE UNITS =====");
    show_debug_message("TOTAL BATTLE XP EARNED: " + string(totalBattleXP) + ", PER MEMBER: " + string(xpPerMember));
    
    // Update global party data with any stat changes from battle
    for (var i = 0; i < array_length(partyUnits); i++) {
        if (i < array_length(global.party) && instance_exists(partyUnits[i])) {
            // Store original XP values for debugging
            var originalXP = global.party[i].xp;
            var originalLevel = global.party[i].level;
            var battleUnitXP = partyUnits[i].xp;
            
            // Preserve battle damage - don't reset HP/MP to max
            global.party[i].hp = partyUnits[i].hp;
            global.party[i].mp = partyUnits[i].mp;
            
            // Copy other stats in case they changed during battle
            global.party[i].level = partyUnits[i].level;
            global.party[i].xp = partyUnits[i].xp;
            global.party[i].xpToNextLevel = partyUnits[i].xpToNextLevel;
            global.party[i].hpMax = partyUnits[i].hpMax;
            global.party[i].mpMax = partyUnits[i].mpMax;
            global.party[i].strength = partyUnits[i].strength;
            
            // Debug message to confirm we're updating stats
            show_debug_message("SYNC: " + global.party[i].name + 
                             " XP CHANGE: " + string(originalXP) + " -> " + string(global.party[i].xp) +
                             " (Battle Unit XP: " + string(battleUnitXP) + ")" +
                             ", Level: " + string(originalLevel) + " -> " + string(global.party[i].level));
        }
    }
    
    show_debug_message("===== PARTY DATA SYNC COMPLETE =====");
    
    // Save party data to ensure it persists between battles and rooms
    SavePartyData();
}

// Add new function to save party data to ensure persistence
function SavePartyData() {
    // CRITICAL: Create a backup of the party data before saving
    // to ensure we don't lose XP between battles
    if (!variable_global_exists("partyBackup")) {
        global.partyBackup = [];
    }
    
    // Create a specific XP backup for recovery if needed
    if (!variable_global_exists("partyXPBackup")) {
        global.partyXPBackup = [];
    }
    
    // Verify party data exists
    if (!variable_global_exists("party")) {
        show_error("Critical error: Cannot save party data - global.party does not exist!", true);
        return;
    }
    
    // Create deep copy backup of the current party state
    array_resize(global.partyBackup, array_length(global.party));
    array_resize(global.partyXPBackup, array_length(global.party));
    
    for (var i = 0; i < array_length(global.party); i++) {
        global.partyBackup[i] = {};
        global.partyXPBackup[i] = {};
        
        // For XP backup, we only need specific XP and level related fields
        global.partyXPBackup[i].name = global.party[i].name;
        global.partyXPBackup[i].level = global.party[i].level;
        global.partyXPBackup[i].xp = global.party[i].xp;
        global.partyXPBackup[i].xpToNextLevel = global.party[i].xpToNextLevel;
        
        // For full backup, copy all scalar properties
        var keys = variable_struct_get_names(global.party[i]);
        for (var j = 0; j < array_length(keys); j++) {
            var key = keys[j];
            // Only backup scalar values
            if (!is_array(variable_struct_get(global.party[i], key)) &&
                !is_struct(variable_struct_get(global.party[i], key))) {
                variable_struct_set(global.partyBackup[i], key, variable_struct_get(global.party[i], key));
            }
        }
    }
    
    // Store the total battle XP for emergency recovery
    if (variable_instance_exists(id, "totalBattleXP") && variable_instance_exists(id, "xpPerMember")) {
        global.battleXPEarned = xpPerMember;
        show_debug_message("SAVED EMERGENCY XP BACKUP: " + string(global.battleXPEarned) + " per member");
    }
    
    // Log detailed information about party saves for debugging
    show_debug_message("===== SAVING PARTY DATA =====");
    for (var i = 0; i < array_length(global.party); i++) {
        show_debug_message(global.party[i].name + 
                         " Lv: " + string(global.party[i].level) + 
                         ", XP: " + string(global.party[i].xp) + "/" + 
                         string(global.party[i].xpToNextLevel) +
                         ", Stats: HP " + string(global.party[i].hp) + "/" + string(global.party[i].hpMax) +
                         ", MP " + string(global.party[i].mp) + "/" + string(global.party[i].mpMax) +
                         ", Str " + string(global.party[i].strength));
    }
    show_debug_message("===== PARTY DATA SAVED =====");
    
    // This could be expanded to use a more robust saving system
    // For now, we just keep the global.party data as our save
    
    // Note: In a full game, you would want to save this data to disk
    // using functions like buffer_write, file_text_write, or 
    // the built-in GameMaker save/load functions
}

// Add this new function after SavePartyData()
function SaveXPBackup() {
    show_debug_message("==== CREATING XP BACKUP DATA ====");
    
    // Create the XP backup array if it doesn't exist
    if (!variable_global_exists("partyXPBackup")) {
        global.partyXPBackup = [];
    }
    
    // Ensure party data exists
    if (!variable_global_exists("party")) {
        show_debug_message("ERROR: Cannot create XP backup - global.party does not exist!");
        return;
    }
    
    // Resize and fill the backup array
    array_resize(global.partyXPBackup, array_length(global.party));
    
    for (var i = 0; i < array_length(global.party); i++) {
        // Create or reset the struct for this party member
        if (is_undefined(global.partyXPBackup[i]) || !is_struct(global.partyXPBackup[i])) {
            global.partyXPBackup[i] = {};
        }
        
        // Save critical XP-related data
        global.partyXPBackup[i].name = global.party[i].name;
        global.partyXPBackup[i].level = global.party[i].level;
        global.partyXPBackup[i].xp = global.party[i].xp;
        global.partyXPBackup[i].xpToNextLevel = global.party[i].xpToNextLevel;
        global.partyXPBackup[i].inBattle = (i < array_length(partyUnits) && instance_exists(partyUnits[i]));
        
        show_debug_message("XP BACKUP: " + global.party[i].name + 
                         " Level: " + string(global.party[i].level) + 
                         ", XP: " + string(global.party[i].xp) + "/" + 
                         string(global.party[i].xpToNextLevel));
    }
    
    // Also save the per-member XP amount for emergency recovery
    if (variable_instance_exists(id, "xpPerMember") && xpPerMember > 0) {
        global.battleXPEarned = xpPerMember;
        show_debug_message("SAVED EMERGENCY XP VALUE: " + string(global.battleXPEarned) + " XP per member");
    }
    
    show_debug_message("==== XP BACKUP COMPLETE ====");
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

// Add new state for game over
BattleStateGameOver = function() {
    battleWaitTimeRemaining--;
    if (battleWaitTimeRemaining <= 0) {
        // Sync party data with battle units before ending
        SyncPartyDataWithUnits();
        
        // Clean up battle UI elements
        with (oMenu) instance_destroy();
        with (oBattleFloatingText) instance_destroy();
        with (oBattleEffect) instance_destroy();
        
        // Mark that we're no longer in battle
        global.inBattle = false;
        
        // Clean up any persistent objects that should be reset on game over
        with (oPlayer) {
            // Destroy player since we're returning to menu
            instance_destroy();
        }
        
        // Reactivate all instances before leaving the battle
        instance_activate_all();
        
        // Return to main menu
        show_debug_message("Game over - returning to main menu");
        room_goto(rm_menu);
    }
}
// Start the battle state machine
battleState = BattleStateSelectAction;

