event_inherited();

// Check if the unit is alive
if (hp <= 0)
{
	try {
		// Try to set the down sprite
		sprite_index = sprites.down;
	}
	catch(e) {
		// If we get an error (down sprite doesn't exist), use the idle sprite with a red tint
		sprite_index = sprites.idle;
		image_blend = c_red;
		image_alpha = 0.7;
		show_debug_message("Warning: Missing down sprite for " + name);
	}
}
