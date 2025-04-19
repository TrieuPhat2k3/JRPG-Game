// Initialize battle unit from party member template
event_inherited();

// Get the template data from the global variable
var template = noone;
if (variable_global_exists("currentUnitTemplate") && is_struct(global.currentUnitTemplate)) {
    template = global.currentUnitTemplate;
    show_debug_message("Retrieved template from global var: " + template.name);
}

// Default values in case template is missing
name = "Unknown";
hp = 1;
hpMax = 1;
mp = 0;
mpMax = 0;
level = 1;
strength = 1;
xp = 0;
xpToNextLevel = 100;
actions = [];
sprites = {
    idle: sLuluIdle,
    attack: sLuluIdle,  // Default attack sprite
    defend: sLuluIdle,  // Default defend sprite
    down: sLuluIdle     // Default down sprite
}; 

// If we have a valid template, copy data from it
if (is_struct(template)) {
    show_debug_message("TEMPLATE: Creating battle unit from template: " + template.name);
    
    // Directly copy critical properties to avoid any potential issues
    name = template.name;
    hp = template.hp;
    hpMax = template.hpMax;
    mp = template.mp;
    mpMax = template.mpMax;
    level = template.level;
    strength = template.strength;
    
    // Make sure to properly copy XP data
    xp = template.xp;
    xpToNextLevel = template.xpToNextLevel;
    show_debug_message("Loaded XP data: " + string(xp) + "/" + string(xpToNextLevel));
    
    // Handle actions array - create a deep copy
    if (variable_struct_exists(template, "actions") && is_array(template.actions)) {
        actions = [];
        var actionCount = array_length(template.actions);
        array_resize(actions, actionCount);
        for (var i = 0; i < actionCount; i++) {
            actions[i] = template.actions[i];
        }
        show_debug_message("Copied " + string(actionCount) + " actions for " + name);
    } else {
        show_debug_message("WARNING: Template has no actions array!");
        actions = [];
    }
    
    // Handle sprites struct - create a deep copy
    if (variable_struct_exists(template, "sprites") && is_struct(template.sprites)) {
        sprites = {};
        var spriteKeys = variable_struct_get_names(template.sprites);
        for (var i = 0; i < array_length(spriteKeys); i++) {
            var key = spriteKeys[i];
            variable_struct_set(sprites, key, variable_struct_get(template.sprites, key));
        }
        
        // Make sure all required sprite keys exist
        if (!variable_struct_exists(sprites, "idle")) sprites.idle = sLuluIdle;
        if (!variable_struct_exists(sprites, "attack")) sprites.attack = sprites.idle;
        if (!variable_struct_exists(sprites, "defend")) sprites.defend = sprites.idle;
        if (!variable_struct_exists(sprites, "down")) sprites.down = sprites.idle;
        
        show_debug_message("Copied sprites struct for " + name);
    } else {
        show_debug_message("WARNING: Template has no sprites struct!");
    }
    
    // Debug output to verify level and actions
    show_debug_message("VERIFICATION: " + name + " is level " + string(level) + 
                      " with " + string(hp) + "/" + string(hpMax) + " HP and " +
                      string(array_length(actions)) + " actions");
}
else {
    show_debug_message("WARNING: oBattleUnitPC created without valid template data!");
}

// Set up sprite from sprites struct
sprite_index = sprites.idle;
