// If the menu is not active, don't process input
if (!active) exit;

// If battle targeting cursor is active, don't process menu input
if (instance_exists(oBattle) && oBattle.cursor.active) exit;

// Control menu with keyboard
var prevHover = hover;
hover += keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);

// Wrap around the menu
if (hover > array_length(options)-1) hover = 0;
if (hover < 0) hover = array_length(options)-1;

// Execute selected option
if (keyboard_check_pressed(vk_enter))
{
	if (array_length(options[hover]) > 1 ) && (options[hover][3] == true)
	{
		if (options[hover][1] != -1)
		{
            // Play confirm sound if enabled
            if (playMenuSounds) {
                // Uncomment below when you have a selection sound
                // audio_play_sound(sndMenuSelect, 1, false);
            }
            
			var _func = options[hover][1];
			if (options[hover][2] != -1) script_execute_ext(_func,options[hover][2]);
			else
			_func();
		}
	}
}

// Handle ESC key for going back or destroying menu
if (keyboard_check_pressed(vk_escape))
{
    // Play back/cancel sound if enabled
    if (playMenuSounds) {
        // Uncomment below when you have a cancel sound
        // audio_play_sound(sndMenuBack, 1, false);
    }
    
	// Check if we're in a submenu
	if (subMenuLevel > 0) {
		MenuGoBack();
	} else {
		// If at the top level in battle, check if it's an item menu
		if (instance_exists(oBattle)) {
			// Get the text of the first menu option to check if it's an item menu
			var firstOption = "";
			if (array_length(options) > 0 && array_length(options[0]) > 0) {
				firstOption = options[0][0];
			}
			
			// If this appears to be an item menu (first item usually has "x" for quantity)
			if (string_pos(" x", firstOption) > 0 || description == "Select an item to use") {
				instance_destroy();
				// Return control to battle menu
				with (oBattle) {
					battleState = BattleStateSelectAction;
				}
			} else {
				// Otherwise just destroy the menu
				instance_destroy();
			}
		} else {
			// If not in battle, just destroy the menu
			instance_destroy();
		}
	}
}	