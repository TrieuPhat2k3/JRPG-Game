//Description menu - Makes a menu, options are provided in the form [["name", function, argument], [...]]
function Menu(_x, _y, _options, _description = -1, _width = undefined, _height = undefined)
{
	with (instance_create_depth(_x, _y, -99999, oMenu))
	{
		options = _options;
		description = _description;
		var _optionsCount = array_length(_options);
		visibleOptionsMax = _optionsCount;
		
		// Initialize submenu variables
		subMenuLevel = 0;
		optionsAbove = [];
		
		// Set up size
		xmargin = 10;
		ymargin = 8;
		draw_set_font(fnM5x7);
		heightLine = 12;
		
		// Auto width
		if (_width == undefined)
		{
			width = 1;
			if (description != -1) width = max(width, string_width(_description));
			for (var i = 0; i < _optionsCount; i++)
			{
				width = max(width, string_width(_options[i][0]));
			}
			widthFull = width + xmargin * 2;
		}
		else
		widthFull = _width;
		
		// Auto height
		if (_height == undefined)
		{
			height = heightLine * (_optionsCount + !(description != -1));
			heightFull = height + ymargin * 2;
		}
		else
		{
			heightFull = _height;
			// Scrolling
			if (heightLine * (_optionsCount + !(description == -1)) > _height - (ymargin*2))
			{
				scrolling = true;
				visibleOptionsMax = (_height - ymargin * 2) div heightLine;
			}
		}
	}
}

function SubMenu(_options)
{
	// Stores old options in array and increase submenu level.
	optionsAbove[subMenuLevel] = options;
	subMenuLevel++;
	options = _options;
	hover = 0;
}

function MenuGoBack()
{
	// Check if we have any previous menus to go back to
	if (subMenuLevel > 0) {
		subMenuLevel--;
		options = optionsAbove[subMenuLevel];
		hover = 0;
	} else {
		// If at the top level, just destroy the menu
		instance_destroy();
	}
}

function MenuSelectAction(_user, _action)
{
	// Make the menu inactive but don't destroy it yet
	with (oMenu) active = false;
	
	// Double-check MP cost before proceeding
	if (variable_struct_exists(_action, "mpCost") && _user.mp < _action.mpCost) {
		// Not enough MP, show message and return to action selection
		with (oBattle) {
			battleText = "Not enough MP!";
			battleWaitTimeRemaining = 60;
			battleState = BattleStateShowText;
		}
		with (oMenu) instance_destroy();
		return;
	}
	
	//Activate the targetting cursor if needed, or simply begin the action
	with (oBattle) 
	{
		if (_action.targetRequired)
		{
			// Set cursor as active for targeting
			with (cursor)
			{
				active = true;
				activeAction = _action;
				targetAll = _action.targetAll;
				if (targetAll == MODE.VARIES) targetAll = true;
				activeUser = _user;
				
				// Force attack actions to only target enemies
				var isRegularAttack = (_action.name == "Attack");
				
				// Always target enemies by default for regular attack
				if (isRegularAttack || _action.targetEnemyByDefault) {
					targetIndex = 0;
					targetSide = oBattle.enemyUnits;
					
					// Make sure we have a valid enemy target
					targetSide = array_filter(targetSide, function(_element, _index) {
						return _element.hp > 0;
					});
					
					// If there are enemies available, set the active target
					if (array_length(targetSide) > 0) {
						activeTarget = targetSide[targetIndex];
					}
				}
				else { // For non-attack actions that can target allies
					targetSide = oBattle.partyUnits;
					activeTarget = activeUser;
					var _findSelf = function(_element) {
						return (_element == activeTarget);
					}
					targetIndex = array_find_index(oBattle.partyUnits, _findSelf);
				}
			}
		}
		else
		{
			//if no target needed, begin the action and end the menu
			BeginAction(_user, _action, -1);
			with (oMenu) instance_destroy();
		}
	}
}

// Function to select items during battle
function MenuSelectItem(_inventory, _user) {
	// Destroy any existing menus first
	with (oMenu) instance_destroy();
	
	// If no inventory exists or it's empty, do nothing
	if (!variable_global_exists("inventory") || ds_list_size(global.inventory) == 0) {
		show_debug_message("No items to select");
		// Return to main battle menu
		with (oBattle) {
			battleState = BattleStateSelectAction;
		}
		return;
	}
	
	// Filter for usable items in battle
	var usableItems = [];
	
	// Get all usable items in inventory
	for (var i = 0; i < ds_list_size(global.inventory); i++) {
		var item = global.inventory[| i];
		var itemData = global.itemLibrary[$ item.id];
		
		if (itemData.canUseInBattle) {
			array_push(usableItems, [
				itemData.name + " x" + string(item.quantity), 
				MenuSelectItemTarget, 
				[item.id, _user],
				true
			]);
		}
	}
	
	// If no usable items, return to main menu
	if (array_length(usableItems) == 0) {
		show_debug_message("No usable items in battle");
		with (oMenu) {
			MenuGoBack();
		}
		return;
	}
	
	// Add "Back" option
	array_push(usableItems, ["Back", MenuGoBack, -1, true]);
	
	// Create an item selection menu with enhanced appearance
	with (oBattle) {
		var menuX = x + 10;
		var menuY = y + 60;
		var menuTitle = "Select an item to use"; // Add a descriptive title
		Menu(menuX, menuY, usableItems, menuTitle, 200, 110);
	}
}

// New function to select which party member to use the item on
function MenuSelectItemTarget(_itemId, _user) {
	// Destroy current menu
	with (oMenu) instance_destroy();
	
	// Get item data to check if it targets all party members
	var itemData = global.itemLibrary[$ _itemId];
	var itemName = itemData.name;
	
	// If the item targets all party members, use it immediately
	if (itemData.targetAll == true) {
		MenuUseItem(_itemId, oBattle.partyUnits, _user);
		return;
	}
	
	// Otherwise create a menu to select which party member to use it on
	var targetOptions = [];
	
	// Add each party member as a target option
	for (var i = 0; i < array_length(oBattle.partyUnits); i++) {
		var partyMember = oBattle.partyUnits[i];
		
		// Only include living party members
		if (partyMember.hp > 0) {
			// Show HP and MP info to help player decide who needs the item
			var hpPercentage = (partyMember.hp / partyMember.hpMax) * 100;
			var mpPercentage = (partyMember.mp / partyMember.mpMax) * 100;
			
			// Format HP information with color indicators
			var hpColor = c_lime;
			if (hpPercentage < 30) hpColor = c_red;
			else if (hpPercentage < 70) hpColor = c_yellow;
			
			// Basic stat display - HP with percentage
			var statsText = string(partyMember.hp) + "/" + string(partyMember.hpMax) + " HP";
			
			// Show MP with percentage for relevant items
			if (string_pos("MP", itemData.description) > 0 || string_pos("Mana", itemData.name) > 0) {
				statsText += ", " + string(partyMember.mp) + "/" + string(partyMember.mpMax) + " MP";
			}
			
			// Add an indicator for the current user
			var nameText = partyMember.name;
			if (partyMember.id == _user.id) {
				nameText += " (current)";
			}
			
			array_push(targetOptions, [
				nameText + " - " + statsText,
				MenuUseItem,
				[_itemId, partyMember, _user],
				true
			]);
		}
	}
	
	// Add "Back" option
	array_push(targetOptions, ["Back", MenuGoBack, -1, true]);
	
	// Create the target selection menu with clear description
	with (oBattle) {
		var menuX = x + 10;
		var menuY = y + 60;
		var menuTitle = "Use " + itemName + " on which party member?";
		Menu(menuX, menuY, targetOptions, menuTitle, 280, 110);
	}
}

// Function to use a selected item on a target
function MenuUseItem(_itemId, _target, _user) {
	// First destroy the current menu to avoid UI overlap
	with (oMenu) instance_destroy();
	
	// Get the item data
	var itemData = global.itemLibrary[$ _itemId];
	var itemName = itemData.name;
	
	// Try to use the item
	var result = UseItem(_itemId, _target);
	
	if (result) {
		// If item used successfully, show notification and continue turn
		with (oBattle) {
			// Create a more detailed message based on what was used and on whom
			var message = "";
			
			// Show who used the item
			message += _user.name + " used " + itemName;
			
			// Show who received the item
			if (is_array(_target)) {
				message += " on the party!";
			} else {
				if (_target.id == _user.id) {
					message += " on self!";
				} else {
					message += " on " + _target.name + "!";
				}
			}
			
			// Display the notification
			battleText = message;
			
			// Create a floating notification on the target(s)
			if (is_array(_target)) {
				// If targeting all party members
				for (var i = 0; i < array_length(_target); i++) {
					if (_target[i].hp > 0) { // Only if they're alive
						var floatText = "+" + itemName;
						instance_create_depth(
							_target[i].x,
							_target[i].y - 10,
							_target[i].depth - 1,
							oBattleFloatingText,
							{font: fnM5x7, col: c_lime, text: floatText}
						);
					}
				}
			} else {
				// Single target
				var floatText = "+" + itemName;
				instance_create_depth(
					_target.x,
					_target.y - 10,
					_target.depth - 1,
					oBattleFloatingText,
					{font: fnM5x7, col: c_lime, text: floatText}
				);
			}
			
			battleWaitTimeRemaining = 90; // Give more time to see the notification
			battleState = BattleStateVictoryCheck;
		}
	} else {
		// If failed, go back to menu
		with (oBattle) {
			battleText = "Cannot use " + itemName + "!";
			battleWaitTimeRemaining = 60;
			battleState = BattleStateShowText;
		}
	}
}