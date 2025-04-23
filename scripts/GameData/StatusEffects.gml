// Status Effects System
global.statusEffects = {
    // Status effect definitions
    poison: {
        name: "Poison",
        duration: 3,  // turns
        damage: 0.1,  // 10% of max HP per turn
        description: "Takes damage over time",
        color: c_green
    },
    sleep: {
        name: "Sleep",
        duration: 2,
        skipTurn: true,
        description: "Cannot act",
        color: c_blue
    },
    paralysis: {
        name: "Paralysis",
        duration: 2,
        skipTurnChance: 0.5,  // 50% chance to skip turn
        description: "May be unable to act",
        color: c_yellow
    }
};

// Function to apply a status effect to a unit
function apply_status_effect(_unit, _effectName, _duration = -1) {
    if (!variable_struct_exists(global.statusEffects, _effectName)) {
        show_debug_message("Error: Unknown status effect " + _effectName);
        return;
    }
    
    // Initialize status effects array if it doesn't exist yet
    if (!variable_instance_exists(_unit, "statusEffects")) {
        _unit.statusEffects = [];
    }
    
    // Check if unit already has this effect
    var existingEffect = -1;
    for (var i = 0; i < array_length(_unit.statusEffects); i++) {
        if (_unit.statusEffects[i].name == _effectName) {
            existingEffect = i;
            break;
        }
    }
    
    // If effect exists, refresh duration, otherwise add new effect
    if (existingEffect != -1) {
        _unit.statusEffects[existingEffect].duration = _duration != -1 ? _duration : global.statusEffects[$ _effectName].duration;
    } else {
        var effect = global.statusEffects[$ _effectName];
        var newEffect = {
            name: _effectName,
            duration: _duration != -1 ? _duration : effect.duration,
            properties: effect
        };
        array_push(_unit.statusEffects, newEffect);
    }
    
    // Show status effect message
    instance_create_depth(_unit.x, _unit.y - 20, _unit.depth - 1, oBattleFloatingText, {
        text: global.statusEffects[$ _effectName].name + "!",
        color: global.statusEffects[$ _effectName].color
    });
}

// Function to process status effects at the start of a unit's turn
function process_status_effects(_unit) {
    if (!variable_instance_exists(_unit, "statusEffects")) return;
    
    var effectsToRemove = [];
    
    // Process each status effect
    for (var i = 0; i < array_length(_unit.statusEffects); i++) {
        var effect = _unit.statusEffects[i];
        effect.duration--;
        
        // Apply effect damage if applicable
        if (variable_struct_exists(effect.properties, "damage")) {
            var damage = floor(_unit.hpMax * effect.properties.damage);
            _unit.hp -= damage;
            // Show damage text
            instance_create_depth(_unit.x, _unit.y - 20, _unit.depth - 1, oBattleFloatingText, {
                text: string(damage) + " " + effect.properties.name + " damage!",
                color: effect.properties.color
            });
        }
        
        // Check if effect should be removed
        if (effect.duration <= 0) {
            // Show effect removal text
            instance_create_depth(_unit.x, _unit.y - 20, _unit.depth - 1, oBattleFloatingText, {
                text: effect.properties.name + " wears off!",
                color: c_white
            });
            array_push(effectsToRemove, i);
        }
    }
    
    // Remove expired effects (in reverse order to maintain array integrity)
    for (var i = array_length(effectsToRemove) - 1; i >= 0; i--) {
        array_delete(_unit.statusEffects, effectsToRemove[i], 1);
    }
}

// Function to check if a unit should skip their turn due to status effects
function should_skip_turn(_unit) {
    if (!variable_instance_exists(_unit, "statusEffects")) return false;
    
    for (var i = 0; i < array_length(_unit.statusEffects); i++) {
        var effect = _unit.statusEffects[i];
        
        // Check for guaranteed skip turn effects
        if (variable_struct_exists(effect.properties, "skipTurn") && effect.properties.skipTurn) {
            return true;
        }
        
        // Check for chance-based skip turn effects
        if (variable_struct_exists(effect.properties, "skipTurnChance")) {
            if (random(1) < effect.properties.skipTurnChance) {
                return true;
            }
        }
    }
    
    return false;
} 