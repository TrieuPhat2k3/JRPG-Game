function NewEncounter(_enemies, _bg)
{	
	// Music plays
	audio_play_sound(snd_battle, true, true);
	instance_create_depth(0, 0, -9999, oTransition);
	
	instance_create_depth
	(
		camera_get_view_x(view_camera[0]),
		camera_get_view_y(view_camera[0]),
		-9999,
		oBattle,
		{enemies: _enemies, creator: id, battleBackground: _bg}
	);
}

function BattleChangeHP(_target, _amount, _AliveDeadOrEither = 0)
{
	//_AliveDeadOrEither: 0 = alive only, 1 = dead only, 2 = any
	var _failed = false;
	if (_AliveDeadOrEither == 0) && (_target.hp <= 0) _failed = true;
	if (_AliveDeadOrEither == 1) && (_target.hp > 0) _failed = true;
	
	var _col = c_white;
	if (_amount > 0) _col = c_lime;
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