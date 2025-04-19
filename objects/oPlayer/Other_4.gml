// Room Start event - handles transitions between rooms
show_debug_message("Player room start in: " + room_get_name(room));

if (instance_number(oPlayer) > 1) {
    // Keep only the one with the right ID
    if (id != instance_find(oPlayer, 0).id) {
        show_debug_message("Extra player instance found - destroying to prevent duplicates");
        instance_destroy();
        exit;
    }
}

// Set this object as persistent to maintain its existence between rooms
persistent = true;

// Check if we're returning from battle
if (variable_global_exists("battleOutcome") && (global.battleOutcome == "win" || global.battleOutcome == "lose")) {
    
    show_debug_message("BATTLE OUTCOME DETECTED: " + global.battleOutcome + " - Current room: " + room_get_name(room));
    show_debug_message("Pre-battle room was: " + room_get_name(global.playerPreBattleRoom)); 
    show_debug_message("Pre-battle X: " + string(global.playerPreBattleX));
    show_debug_message("Pre-battle Y: " + string(global.playerPreBattleY));
    
    // CRITICAL: Force position right away and with persistence
    x = global.playerPreBattleX;
    y = global.playerPreBattleY;
    
    // Create a 2-frame alarm to position player after room is fully loaded
    alarm[1] = 2;
    
    // Apply invincibility
    alarm[0] = 60; // 1 second invincibility 
    invincible = true;
    
    // Force enemy clearing as last resort
    global.forceClearEnemies = true;
    
    // CRITICAL: Check and restore XP data after battle if it exists in backup
    if (variable_global_exists("party") && variable_global_exists("partyXPBackup")) {
        show_debug_message("===== CHECKING POST-BATTLE XP DATA =====");
        
        var needToRestore = false;
        // First check if XP was lost
        for (var i = 0; i < array_length(global.party); i++) {
            // Check if a backup exists for this party member
            if (i < array_length(global.partyXPBackup) && 
                variable_struct_exists(global.partyXPBackup[i], "xp") &&
                global.party[i].name == global.partyXPBackup[i].name) {
                
                // Compare current XP with backup
                show_debug_message("XP Check - " + global.party[i].name + 
                                 " Current: " + string(global.party[i].xp) + 
                                 ", Backup: " + string(global.partyXPBackup[i].xp));
                
                // If current XP is less than backup, we need to restore
                if (global.party[i].xp < global.partyXPBackup[i].xp || 
                    global.party[i].level < global.partyXPBackup[i].level) {
                    needToRestore = true;
                    show_debug_message("XP LOSS DETECTED for " + global.party[i].name + 
                                     ": Current XP=" + string(global.party[i].xp) + 
                                     ", Backup XP=" + string(global.partyXPBackup[i].xp));
                }
            }
        }
        
        // If XP loss was detected, restore from backup
        if (needToRestore) {
            show_debug_message("===== RESTORING XP FROM BACKUP =====");
            for (var i = 0; i < array_length(global.party); i++) {
                if (i < array_length(global.partyXPBackup) && 
                    variable_struct_exists(global.partyXPBackup[i], "xp") &&
                    global.party[i].name == global.partyXPBackup[i].name) {
                    
                    // Store original values for logging
                    var origLevel = global.party[i].level;
                    var origXP = global.party[i].xp;
                    
                    // Restore XP and level data
                    global.party[i].level = global.partyXPBackup[i].level;
                    global.party[i].xp = global.partyXPBackup[i].xp;
                    global.party[i].xpToNextLevel = global.partyXPBackup[i].xpToNextLevel;
                    
                    show_debug_message("RESTORED: " + global.party[i].name + 
                                     " from Level " + string(origLevel) + " to " + string(global.party[i].level) + 
                                     ", XP from " + string(origXP) + " to " + string(global.party[i].xp));
                }
            }
        } else {
            show_debug_message("No XP loss detected - data is consistent");
        }
    } else {
        if (variable_global_exists("party")) {
            show_debug_message("WARNING: No XP backup data available to verify");
        }
    }
}

// Check if we just came back from a battle and need to restore player position
if (global.fromBattle) {
    global.fromBattle = false;
    x = global.preBattleX;
    y = global.preBattleY;
    invincible = true;
    alarm[0] = room_speed * 2;
    
    // Emergency XP Check - ensure XP wasn't lost after battle
    if (global.battleOutcome == "win" && variable_global_exists("battleXPEarned")) {
        var xpPerMember = global.battleXPEarned;
        show_debug_message("EMERGENCY XP CHECK - Battle XP earned: " + string(xpPerMember));
        
        for (var i = 0; i < array_length(global.party); i++) {
            var oldXP = global.party[i].xp;
            
            // Check if they should have received XP but didn't
            if (global.party[i].inBattle && (global.party[i].xp < (oldXP + xpPerMember))) {
                show_debug_message("EMERGENCY XP RESTORE: " + global.party[i].name + 
                                " had " + string(global.party[i].xp) + 
                                " XP, should have " + string(oldXP + xpPerMember));
                                
                // Restore the XP they should have gained
                global.party[i].xp = oldXP + xpPerMember;
                
                // Check for level up
                var requiredXP = (global.party[i].level * 10) * global.party[i].level;
                if (global.party[i].xp >= requiredXP) {
                    show_debug_message(global.party[i].name + " EMERGENCY LEVEL UP!");
                    global.party[i].level += 1;
                    global.party[i].maxHP += 5;
                    global.party[i].maxMP += 3;
                    global.party[i].baseATK += 2;
                    global.party[i].baseDEF += 1;
                    global.party[i].hp = global.party[i].maxHP;
                    global.party[i].mp = global.party[i].maxMP;
                }
            }
        }
        
        // Clear the emergency backup variable
        variable_global_delete("battleXPEarned");
    }
}

// Make sure inventory is initialized
if (!variable_global_exists("inventory")) {
    InitInventory();
}

// Make sure inventory menu exists (create only once as it's persistent)
if (!instance_exists(oInventoryMenu)) {
    instance_create_depth(0, 0, -10000, oInventoryMenu);
    show_debug_message("Created inventory menu");
}