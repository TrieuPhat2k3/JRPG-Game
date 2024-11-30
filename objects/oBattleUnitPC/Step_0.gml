event_inherited();

// Check if the unit is alive
if (hp <= 0)
{
	sprite_index = sprites.down;
}
else
{
	// If the unit was defending and it's still not their turn, keep defend sprite
	if (defenseBoost && sprite_index != sprites.defend)
	{
		sprite_index = sprites.defend;
	}

	// When it's the unit's turn, reset the defense boost and sprite to idle
	if (id == oBattle.currentUser && defenseBoost)
	{
		defenseBoost = false;
		sprite_index = sprites.idle;
	}

	// Ensure fallen units reset to idle if revived
	if (sprite_index == sprites.down) sprite_index = sprites.idle;
}