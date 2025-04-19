// Store the tilemap layer ID for collision checking
collisionLayer = layer_tilemap_get_id("Tiles_Collision");
spdWalk = 2;
animIndex = 0;

// Make player persistent across rooms
persistent = true;

// Initialize the game if this is the first instance
if (instance_number(oPlayer) <= 1) {
	// Initialize game data
	GameInit();
	show_debug_message("Game initialized on first player creation");
}

// Initialize invincibility variables
invincible = false;

function FourDirectionAnimate() {
	// Update Sprite
	var _animLength = sprite_get_number(sprite_index) / 4;
	image_index = animIndex + (((direction div 90) mod 4) * _animLength);
	animIndex += sprite_get_speed(sprite_index) / 60;

	// If animation would loop on next game step
	if (animIndex >= _animLength)
	{
		animationEnd = true;	
		animIndex -= _animLength;
	}
	else animationEnd = false;
}
