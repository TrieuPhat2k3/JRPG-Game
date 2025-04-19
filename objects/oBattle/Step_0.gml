//Run state machine
battleState();

//Cursor control
if (cursor.active)
{
	with (cursor)
	{
		//input
		var _keyUp = keyboard_check_pressed(vk_up);
		var _keyDown = keyboard_check_pressed(vk_down);
		var _keyLeft = keyboard_check_pressed(vk_left);
		var _keyRight = keyboard_check_pressed(vk_right);
		var _keyToggle = keyboard_check_pressed(vk_shift);
		var _keyConfirm = keyboard_check_pressed(vk_enter);
		var _keyCancel = keyboard_check_pressed(vk_escape);
		
		// Increment confirm delay to prevent accidental inputs
		confirmDelay++;
		if (confirmDelay <= 1) {
			_keyConfirm = false;
			_keyCancel = false;
			_keyToggle = false;
		}
		
		// Get horizontal movement input
		var _moveH = (_keyRight ? 1 : 0) - (_keyLeft ? 1 : 0);
		// Get vertical movement input
		var _moveV = (_keyDown ? 1 : 0) - (_keyUp ? 1 : 0);
		
		// Check if the current action is an attack action
		var isAttackAction = (activeAction.name == "Attack");
		
		// Handle side switching with left/right keys
		// For attacks, only allow targeting enemies
		if (_moveH != 0) {
			if (isAttackAction) {
				// For attacks, always stay on enemy side
				targetSide = oBattle.enemyUnits;
			} else {
				// For other actions, allow switching sides
				if (_moveH < 0) targetSide = oBattle.partyUnits;
				if (_moveH > 0) targetSide = oBattle.enemyUnits;
			}
			
			// Reset target index when switching sides
			targetIndex = 0;
		}
		
		// For attack actions, always ensure we're targeting enemies
		if (isAttackAction && targetSide != oBattle.enemyUnits) {
			targetSide = oBattle.enemyUnits;
			targetIndex = 0;
		}
		
		// Create a clean list of valid targets (only living units)
		var validTargets = [];
		for (var i = 0; i < array_length(targetSide); i++) {
			if (targetSide[i].hp > 0) {
				array_push(validTargets, targetSide[i]);
			}
		}
		
		// Handle vertical movement (up/down) between targets
		if (_moveV != 0 && array_length(validTargets) > 0) {
			// Update target index based on input
			targetIndex += _moveV;
			
			// Wrap around when reaching the end
			var targetCount = array_length(validTargets);
			if (targetIndex < 0) targetIndex = targetCount - 1;
			if (targetIndex >= targetCount) targetIndex = 0;
		}
		
		// Make sure targetIndex is valid
		if (array_length(validTargets) > 0) {
			targetIndex = clamp(targetIndex, 0, array_length(validTargets) - 1);
			// Set active target to the currently selected unit
			activeTarget = validTargets[targetIndex];
		} else {
			// No valid targets - this shouldn't happen in normal gameplay
			// but handling it gracefully just in case
			targetIndex = 0;
			activeTarget = noone;
		}
		
		// Handle toggling between single target and all targets
		if (activeAction.targetAll == MODE.VARIES && _keyToggle) {
			targetAll = !targetAll;
			if (targetAll) {
				// When targeting all, our activeTarget becomes the array
				activeTarget = validTargets;
			} else {
				// When going back to single target, select the first valid target
				if (array_length(validTargets) > 0) {
					targetIndex = 0;
					activeTarget = validTargets[targetIndex];
				}
			}
		}
		
		// Handle multi-target mode (when targeting all)
		if (targetAll) {
			activeTarget = validTargets;
		}
		
		//Confirm action
		if (_keyConfirm && activeTarget != noone)
		{
			with (oBattle) BeginAction(cursor.activeUser, cursor.activeAction, cursor.activeTarget);
			with (oMenu) instance_destroy();
			active = false;
			confirmDelay = 0;
		}
		
		//Cancel & return to menu
		if (_keyCancel && !_keyConfirm)
		{
			// Re-enable menu and disable cursor
			with (oMenu) {
				active = true;
			}
			active = false;
			confirmDelay = 0;
		}
	}
}