function GameInit(){
    // Set the starting room (for new game or after reset)
    global.startRoom = room_first; // Default to the first room
    // You could set this to a specific room like: global.startRoom = rm_village;
    
    // Set default spawn coordinates for the player
    global.defaultSpawnX = 160;
    global.defaultSpawnY = 120;
    
    // Initialize defeated enemies map if it doesn't exist
    if (!variable_global_exists("defeatedEnemies") || !ds_exists(global.defeatedEnemies, ds_type_map)) {
        global.defeatedEnemies = ds_map_create();
        show_debug_message("Created new defeatedEnemies map during game initialization");
    }
    
    // Initialize battle state variables
    global.inBattle = false;
    global.battleOutcome = "";
    global.fromBattle = false; // Initialize fromBattle flag
    
    // Initialize player pre-battle position trackers
    global.playerPreBattleX = 0;
    global.playerPreBattleY = 0;
    global.playerPreBattleRoom = -1;
    global.preBattleX = 0; // Initialize pre-battle X position
    global.preBattleY = 0; // Initialize pre-battle Y position
    
    // Initialize XP backup system
    if (!variable_global_exists("partyXPBackup")) {
        global.partyXPBackup = [];
        show_debug_message("Initialized partyXPBackup array for XP recovery system");
    }
    
    // Initialize emergency XP tracking
    if (!variable_global_exists("battleXPEarned")) {
        global.battleXPEarned = 0;
        show_debug_message("Initialized battleXPEarned for emergency XP recovery");
    }
    
    // Make sure inventory is initialized
    if (!variable_global_exists("inventory")) {
        InitInventory();
    }
    
    // Use a flag to ensure party data is only initialized once per game session
    if (!variable_global_exists("partyInitialized")) {
        global.partyInitialized = true;
        show_debug_message("GAME INIT: Setting partyInitialized flag to protect party data");
    }
    
    show_debug_message("Game initialization complete");
}

// Call this function to restart the game when coming from the menu
// or after a game over
function GameRestart() {
    // Clear all defeated enemies
    if (variable_global_exists("defeatedEnemies") && ds_exists(global.defeatedEnemies, ds_type_map)) {
        ds_map_clear(global.defeatedEnemies);
    }
    
    // Reset battle outcome
    global.battleOutcome = "";
    global.inBattle = false;
    global.fromBattle = false; // Reset fromBattle flag
    
    // Reset pre-battle positions
    global.preBattleX = 0;
    global.preBattleY = 0;
    global.playerPreBattleX = 0;
    global.playerPreBattleY = 0;
    global.playerPreBattleRoom = -1;
    
    // Reset player data (HP, MP, etc)
    if (variable_global_exists("party")) {
        for (var i = 0; i < array_length(global.party); i++) {
            // Reset HP and MP to max
            global.party[i].hp = global.party[i].hpMax;
            global.party[i].mp = global.party[i].mpMax;
            
            // Optionally reset other stats like XP if starting a completely new game
            if (argument_count > 0 && argument[0] == "new_game") {
                global.party[i].xp = 0;
                global.party[i].level = 1;
                global.party[i].xpToNextLevel = 50;
                global.party[i].hpMax = (global.party[i].name == "Lulu") ? 89 : 44;
                global.party[i].mpMax = (global.party[i].name == "Lulu") ? 15 : 30;
                global.party[i].strength = (global.party[i].name == "Lulu") ? 6 : 4;
                
                show_debug_message("NEW GAME: Reset " + global.party[i].name + " to level 1 defaults");
            } else {
                show_debug_message("GAME RESTART: Preserved " + global.party[i].name + 
                                " Level: " + string(global.party[i].level) + 
                                ", XP: " + string(global.party[i].xp) + "/" + 
                                string(global.party[i].xpToNextLevel));
            }
        }
        
        // Handle XP backup for new games vs. continues
        if (argument_count > 0 && argument[0] == "new_game") {
            // For new games, clear XP backup to match reset character stats
            if (variable_global_exists("partyXPBackup")) {
                array_resize(global.partyXPBackup, 0); // Clear the array
                array_resize(global.partyXPBackup, array_length(global.party)); // Resize to match party
                
                // Initialize with default values
                for (var i = 0; i < array_length(global.party); i++) {
                    global.partyXPBackup[i] = {
                        name: global.party[i].name,
                        level: global.party[i].level,
                        xp: global.party[i].xp,
                        xpToNextLevel: global.party[i].xpToNextLevel,
                        inBattle: false
                    };
                }
                
                // Reset emergency XP backup
                global.battleXPEarned = 0;
                
                show_debug_message("NEW GAME: Reset XP backup system");
            }
        } else {
            // For continues, ensure XP backup matches current party data
            if (variable_global_exists("partyXPBackup")) {
                // Make sure backup array is the right size
                array_resize(global.partyXPBackup, array_length(global.party));
                
                // Update backup with current values
                for (var i = 0; i < array_length(global.party); i++) {
                    if (!is_struct(global.partyXPBackup[i])) {
                        global.partyXPBackup[i] = {};
                    }
                    
                    global.partyXPBackup[i].name = global.party[i].name;
                    global.partyXPBackup[i].level = global.party[i].level;
                    global.partyXPBackup[i].xp = global.party[i].xp;
                    global.partyXPBackup[i].xpToNextLevel = global.party[i].xpToNextLevel;
                    global.partyXPBackup[i].inBattle = false;
                }
                
                show_debug_message("GAME RESTART: Updated XP backup to match current party");
            }
        }
    } else {
        show_debug_message("No party data exists - will be initialized on first load");
    }
    
    // Reset inventory if needed
    if (variable_global_exists("inventory") && ds_exists(global.inventory, ds_type_list)) {
        ds_list_clear(global.inventory);
        InitInventory(); // Re-initialize with starting items
    }
    
    // Reset gold
    if (variable_global_exists("playerGold")) {
        global.playerGold = 0; // Or set to starting amount
    }
    
    // Reset the partyInitialized flag for a clean game start
    if (argument_count > 0 && argument[0] == "new_game") {
        global.partyInitialized = false;
        show_debug_message("NEW GAME: Reset partyInitialized flag");
    }
    
    show_debug_message("Game reset complete");
}