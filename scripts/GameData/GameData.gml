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
		name : "Ice Blast",
		description : "{0} casts Ice Blast!",
		subMenu : "Magic",
		mpCost : 4,
		targetRequired : true,
		targetEnemyByDefault : true,
		targetAll : MODE.VARIES,
		userAnimation : "cast",
		effectSprite : sAttackIce,
		effectOnTarget : MODE.ALWAYS,
		sound : mus_sfx_spellcast,
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
		name : "Fire Ball",
		description : "{0} casts Fire Ball!",
		subMenu : "Magic",
		mpCost : 12,
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
				var _damage = irandom_range(18,22);
				if (array_length(_targets) > 1) _damage = ceil(_damage*0.75);
				BattleChangeHP(_targets[i], -_damage);
			}
			BattleChangeMP(_user, -global.actionLibrary.fire.mpCost);
			
		}
	 },
	 heal :
	 {
		name : "Cat Food",	
		description : "{0} uses the Cat Food!",
		subMenu : "Magic",
		mpCost : 10,
		targetRequired : true,
		targetEnemyByDefault : true,
		targetAll : MODE.VARIES,
		userAnimation : "cast",
		effectSprite : sAttackHeal,
		effectOnTarget : MODE.ALWAYS,
		func : function(_user, _targets)
		{
			// Heal logic can be added here.
		}
	 },
	 defend :
	 {
		name : "Defend",
		description : "{0} takes a defensive stance!",
		subMenu : -1,
		targetRequired : false,
		targetEnemyByDefault : false,
		targetAll : MODE.NEVER,
		userAnimation : "defend",
		effectSprite : sLuluDefend,
		effectOnTarget : MODE.NEVER,
		func : function(_user, _targets)
		{
			// Defend logic can be added here.
		}
},
	escape :
	{
		name : "Escape",
		description : "{0} attempts to flee!",
		subMenu : -1,
		targetRequired : false,
		targetEnemyByDefault : false,
		targetAll : MODE.NEVER,
		userAnimation : "idle", // No special animation
		effectOnTarget : MODE.NEVER,
		func : function(_user, _targets)
    {
		// Escape logic can be added here.
    },
	
}
	
}

enum MODE
{
	NEVER = 0,
	ALWAYS = 1,
	VARIES = 2
}

// Only initialize party data if it doesn't exist yet AND it hasn't been initialized before
if (!variable_global_exists("party") && (!variable_global_exists("partyInitialized") || !global.partyInitialized)) {
    show_debug_message("INITIALIZING PARTY DATA FOR THE FIRST TIME");
    
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
            level: 1,
            xp: 0,
            xpToNextLevel: 50, // XP needed to reach level 2
            sprites : { idle: sLuluIdle, attack: sLuluAttack, defend: sLuluDefend, down: sLuluDown},
            actions : [global.actionLibrary.attack, global.actionLibrary.defend]
        }
        ,
        {
            name: "Questy",
            hp: 44,
            hpMax: 44,
            mp: 30,
            mpMax: 30,
            strength: 4,
            level: 1,
            xp: 0,
            xpToNextLevel: 50,
            sprites : { idle: sQuestyIdle, attack: sQuestyCast, cast: sQuestyCast, down: sQuestyDown},
            actions : [global.actionLibrary.attack, global.actionLibrary.ice, global.actionLibrary.fire]
        }
    ];
    
    // Mark that party has been initialized to prevent reinitializing
    global.partyInitialized = true;
    show_debug_message("PARTY DATA INITIALIZED - Set partyInitialized flag");
} else if (variable_global_exists("party")) {
    // Log existing party stats for debugging
    show_debug_message("PARTY DATA ALREADY EXISTS - PRESERVING EXISTING DATA");
    for (var i = 0; i < array_length(global.party); i++) {
        show_debug_message("PRESERVED: " + global.party[i].name + 
                         " (Lv: " + string(global.party[i].level) + 
                         ", XP: " + string(global.party[i].xp) + "/" + 
                         string(global.party[i].xpToNextLevel) + ")");
    }
}

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
		hp: 24,
		hpMax: 24,
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
