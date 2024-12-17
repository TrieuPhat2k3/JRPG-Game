instance_deactivate_all(true); // Deactivate all instances except self (oBattle)

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

// Make enemies
for (var i = 0; i < array_length(enemies); i++) {
    enemyUnits[i] = instance_create_depth(x + 250 + (i * 10), y + 68 + (i * 20), depth - 10, oBattleUnitEnemy, enemies[i]);
    array_push(units, enemyUnits[i]);    
}

// Make party members
for (var i = 0; i < array_length(global.party); i++) {
    partyUnits[i] = instance_create_depth(x + 70 + (i * 10), y + 68 + (i * 15), depth - 10, oBattleUnitPC, global.party[i]);
    array_push(units, partyUnits[i]);    
}

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
            battleWaitTimeRemaining--;
            if (battleWaitTimeRemaining == 0) {
                battleState = BattleStateVictoryCheck;
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
        
        battleState = BattleStateDistributeXP; // Start XP distribution
    } else {
        battleState = BattleStateTurnProgression;
    }
};

BattleStateDistributeXP = function() {
    if (currentPartyIndex >= array_length(global.party)) {
        // All party members have been processed; return to map
        global.battleOutcome = "win";
        room_goto(rm_testzone);
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
            battleWaitTimeRemaining = 180; // Wait ~3 seconds (60 frames per second)
            battleState = BattleStateShowText; // Change state to show text
            return; // Pause here and wait for the next state
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
