//Action Library
global.actionLibrary =
{
	attack :
	{
		name : "Attack",
		description : "{0} attacks!",
		subMenu : -1,
		targetRequired : true,
		targetEnemyByDefault : true,
		targetAll : MODE.NEVER,
		userAnimation : "attack",
		effectSprite : sAttackBonk,
		effectOnTarget : MODE.ALWAYS,
		func : function(_user, _targets)
		{
			var _damage = ceil(_user.strength + random_range(-_user.strength * 0.25, _user.strength * 0.25));
			BattleChangeHP(_targets[0], -_damage, 0);
		}
	},
	ice :
	{
		name : "Ice",
		description : "{0} casts Ice!",
		subMenu : "Magic",
		mpCost : 4,
		targetRequired : true,
		targetEnemyByDefault : true,
		targetAll : MODE.VARIES,
		userAnimation : "cast",
		effectSprite : sAttackFire,
		effectOnTarget : MODE.ALWAYS,
		func : function(_user, _targets)
		{
			for (var i = 0; i < array_length(_targets); i++)
			{
				var _damage = irandom_range(15,20);
				if (array_length(_targets) > 1) _damage = ceil(_damage*0.75);
				BattleChangeHP(_targets[i], -_damage);
			}
			BattleChangeMP(_user, -global.actionLibrary.ice.mpCost);
			
		}
	},
	fire :
	{
		name : "Fire",
		description : "{0} casts Fire!",
		subMenu : "Magic",
		mpCost : 10,
		targetRequired : true,
		targetEnemyByDefault : true,
		targetAll : MODE.VARIES,
		userAnimation : "cast",
		effectSprite : sAttackIce,
		effectOnTarget : MODE.ALWAYS,
		func : function(_user, _targets)
		{
			for (var i = 0; i < array_length(_targets); i++)
			{
				var _damage = irandom_range(18,22);
				if (array_length(_targets) > 1) _damage = ceil(_damage*0.75);
				BattleChangeHP(_targets[i], -_damage);
			}
			BattleChangeMP(_user, -global.actionLibrary.fire.mpCost);
			
		}
	 },
	 heal :
	 {
		name : "Heal",
		description : "{0} casts Heal!",
		subMenu : "Magic",
		mpCost : 10,
		targetRequired : true,
		targetEnemyByDefault : true,
		targetAll : MODE.VARIES,
		userAnimation : "cast",
		effectSprite : sAttackIce,
		effectOnTarget : MODE.ALWAYS,
		func : function(_user, _targets)
		{
			for (var i = 0; i < array_length(_targets); i++)
			{
				var _damage = irandom_range(15,20);
				if (array_length(_targets) > 1) _damage = ceil(_damage*0.75);
				BattleChangeHP(_targets[i], -_damage);
			}
			BattleChangeMP(_user, -global.actionLibrary.heal.mpCost);
			
		}
	 }
	
}

enum MODE
{
	NEVER = 0,
	ALWAYS = 1,
	VARIES = 2
}



//Party data
global.party = 
[
	{
		name: "Lulu",
		hp: 89,
		hpMax: 89,
		mp: 15,
		mpMax: 15,
		strength: 6,
		sprites : { idle: sLuluIdle, attack: sLuluAttack, defend: sLuluDefend, down: sLuluDown},
		actions : [global.actionLibrary.attack]
	}
	,
	{
		name: "Questy",
		hp: 44,
		hpMax: 44,
		mp: 30,
		mpMax: 30,
		strength: 4,
		sprites : { idle: sQuestyIdle, attack: sQuestyCast, cast: sQuestyCast, down: sQuestyDown},
		actions : [global.actionLibrary.attack, global.actionLibrary.ice]
	}
]

//Enemy Data
global.enemies =
{
	slimeG: 
	{
		name: "Slime",
		hp: 30,
		hpMax: 30,
		mp: 0,
		mpMax: 0,
		strength: 5,
		sprites: { idle: sSlime, attack: sSlimeAttack},
		actions: [global.actionLibrary.attack],
		xpValue : 15,
		AIscript : function()
		{
			//Attack on random party member.
			var _action = actions[0];
			var _possibleTargets = array_filter(oBattle.partyUnits, function(_unit, _index)
			{
				return (_unit.hp > 0);
			});
			var _target = _possibleTargets[irandom(array_length(_possibleTargets)-1)];
			return [_action, _target];
		}
	}
	,
	bat: 
	{
		name: "Bat",
		hp: 15,
		hpMax: 15,
		mp: 0,
		mpMax: 0,
		strength: 4,
		sprites: { idle: sBat, attack: sBatAttack},
		actions: [global.actionLibrary.attack],
		xpValue : 18,
		AIscript : function()
		{
			//Attack on random party member.
			var _action = actions[0];
			var _possibleTargets = array_filter(oBattle.partyUnits, function(_unit, _index)
			{
				return (_unit.hp > 0);
			});
			var _target = _possibleTargets[irandom(array_length(_possibleTargets)-1)];
			return [_action, _target];
		}
	}
}





