// Item Database - Defines all items in the game

// Enum for item types
enum ITEM_TYPE {
    CONSUMABLE,
    KEY_ITEM,
    EQUIPMENT
}

// Item Library
global.itemLibrary = {
    // Consumable items
    healthPotion: {
        name: "Health Potion",
        description: "Restores 30 HP to one party member.",
        type: ITEM_TYPE.CONSUMABLE,
        sprite: sBox, // Replace with actual potion sprite when available
        value: 20,    // Gold value for shop
        canUseInBattle: true,
        canUseInField: true,
        targetParty: true,
        targetAll: false,
        effect: function(target) {
            if (is_array(target)) {
                // Handle multiple targets if needed
                for (var i = 0; i < array_length(target); i++) {
                    target[i].hp = min(target[i].hp + 30, target[i].hpMax);
                }
            } else {
                // Single target
                target.hp = min(target.hp + 30, target.hpMax);
            }
            return true; // Successfully used
        }
    },
    
    manaPotion: {
        name: "Mana Potion",
        description: "Restores 15 MP to one party member.",
        type: ITEM_TYPE.CONSUMABLE,
        sprite: sBox, // Replace with actual mana potion sprite
        value: 30,
        canUseInBattle: true,
        canUseInField: true,
        targetParty: true,
        targetAll: false,
        effect: function(target) {
            if (is_array(target)) {
                for (var i = 0; i < array_length(target); i++) {
                    target[i].mp = min(target[i].mp + 15, target[i].mpMax);
                }
            } else {
                target.mp = min(target.mp + 15, target.mpMax);
            }
            return true;
        }
    },
    
    // More powerful healing item
    elixir: {
        name: "Elixir",
        description: "Restores 50 HP and 20 MP to one party member.",
        type: ITEM_TYPE.CONSUMABLE,
        sprite: sBox, // Replace with elixir sprite
        value: 100,
        canUseInBattle: true,
        canUseInField: true,
        targetParty: true,
        targetAll: false,
        effect: function(target) {
            if (is_array(target)) {
                for (var i = 0; i < array_length(target); i++) {
                    target[i].hp = min(target[i].hp + 50, target[i].hpMax);
                    target[i].mp = min(target[i].mp + 20, target[i].mpMax);
                }
            } else {
                target.hp = min(target.hp + 50, target.hpMax);
                target.mp = min(target.mp + 20, target.mpMax);
            }
            return true;
        }
    },
    
    // Area of effect healing item
    herbPoultice: {
        name: "Herb Poultice",
        description: "Restores 20 HP to all party members.",
        type: ITEM_TYPE.CONSUMABLE,
        sprite: sBox, // Replace with herb sprite
        value: 60,
        canUseInBattle: true,
        canUseInField: true,
        targetParty: true,
        targetAll: true,
        effect: function(targets) {
            for (var i = 0; i < array_length(targets); i++) {
                targets[i].hp = min(targets[i].hp + 20, targets[i].hpMax);
            }
            return true;
        }
    },
    
    // Status recovery item (for future status effects)
    antidote: {
        name: "Antidote",
        description: "Cures poison status.",
        type: ITEM_TYPE.CONSUMABLE,
        sprite: sBox, // Replace with antidote sprite
        value: 15,
        canUseInBattle: true,
        canUseInField: true,
        targetParty: true,
        targetAll: false,
        effect: function(target) {
            // Placeholder for poison status removal
            // For future implementation when status effects are added
            return true;
        }
    },
    
    // Key items - For quests and story progression
    ancientKey: {
        name: "Ancient Key",
        description: "A rusted key that seems to be very old. Might open something important.",
        type: ITEM_TYPE.KEY_ITEM,
        sprite: sBox, // Replace with key sprite
        value: 0, // Cannot be sold
        canUseInBattle: false,
        canUseInField: true,
        targetParty: false,
        targetAll: false,
        effect: function() {
            // This would be used for special interactions in the game world
            // For example: opening a specific door
            return false; // Cannot be used directly
        }
    },
    
    mysteriousAmulet: {
        name: "Mysterious Amulet",
        description: "An amulet with strange inscriptions. It seems important.",
        type: ITEM_TYPE.KEY_ITEM,
        sprite: sBox, // Replace with amulet sprite
        value: 0,
        canUseInBattle: false,
        canUseInField: false,
        targetParty: false,
        targetAll: false,
        effect: function() {
            return false; // Cannot be used directly
        }
    }
};

// Initialize player inventory
function InitInventory() {
    // Create the inventory if it doesn't exist
    if (!variable_global_exists("inventory")) {
        global.inventory = ds_list_create();
        show_debug_message("Initialized inventory");
        
        // Add some starter items
        AddItemToInventory("healthPotion", 2);
        AddItemToInventory("manaPotion", 1);
    }
    
    // Initialize money system if it doesn't exist
    if (!variable_global_exists("playerGold")) {
        global.playerGold = 100; // Starting gold
    }
}

// Add an item to the inventory
function AddItemToInventory(itemId, quantity = 1) {
    if (!variable_global_exists("inventory")) {
        InitInventory();
    }
    
    // Check if item already exists in inventory
    var itemExists = false;
    for (var i = 0; i < ds_list_size(global.inventory); i++) {
        var item = global.inventory[| i];
        if (item.id == itemId) {
            item.quantity += quantity;
            itemExists = true;
            show_debug_message("Added " + string(quantity) + " " + global.itemLibrary[$ itemId].name + " to inventory (now have " + string(item.quantity) + ")");
            break;
        }
    }
    
    // If item doesn't exist, add it
    if (!itemExists) {
        var newItem = {
            id: itemId,
            quantity: quantity
        };
        ds_list_add(global.inventory, newItem);
        show_debug_message("Added new item to inventory: " + global.itemLibrary[$ itemId].name + " x" + string(quantity));
    }
}

// Remove an item from the inventory
function RemoveItemFromInventory(itemId, quantity = 1) {
    if (!variable_global_exists("inventory")) {
        show_debug_message("Cannot remove item - inventory doesn't exist");
        return false;
    }
    
    for (var i = 0; i < ds_list_size(global.inventory); i++) {
        var item = global.inventory[| i];
        if (item.id == itemId) {
            if (item.quantity >= quantity) {
                item.quantity -= quantity;
                show_debug_message("Removed " + string(quantity) + " " + global.itemLibrary[$ itemId].name + " from inventory");
                
                // If quantity reached zero, remove the item completely
                if (item.quantity <= 0) {
                    ds_list_delete(global.inventory, i);
                    show_debug_message("Item removed completely from inventory");
                }
                return true;
            } else {
                show_debug_message("Not enough of this item to remove");
                return false;
            }
        }
    }
    
    show_debug_message("Item not found in inventory");
    return false;
}

// Use an item on a target
function UseItem(itemId, target) {
    // Check if we have the item
    var hasItem = false;
    for (var i = 0; i < ds_list_size(global.inventory); i++) {
        var item = global.inventory[| i];
        if (item.id == itemId && item.quantity > 0) {
            hasItem = true;
            break;
        }
    }
    
    if (!hasItem) {
        show_debug_message("Cannot use item - not in inventory or quantity is 0");
        return false;
    }
    
    // Get the item data
    var itemData = global.itemLibrary[$ itemId];
    
    // Use the item effect
    var success = itemData.effect(target);
    
    // If successfully used, remove it from inventory
    if (success) {
        RemoveItemFromInventory(itemId, 1);
        show_debug_message("Successfully used " + itemData.name);
    }
    
    return success;
}

// Drop items from enemies
function DropItemFromEnemy(enemyType) {
    // Define drop tables for each enemy type
    var dropTable = {};
    
    // Slime drops
    if (enemyType == "slimeG") {
        dropTable = {
            items: ["healthPotion", "manaPotion"],
            chances: [0.3, 0.15], // 30% chance for health potion, 15% for mana potion
            goldMin: 5,
            goldMax: 15
        };
    }
    // Bat drops
    else if (enemyType == "bat") {
        dropTable = {
            items: ["healthPotion", "elixir"],
            chances: [0.2, 0.05], // 20% chance for health potion, 5% for elixir
            goldMin: 10,
            goldMax: 20
        };
    }
    // Default drops if enemy type is not recognized
    else {
        dropTable = {
            items: ["healthPotion"],
            chances: [0.1], // 10% chance
            goldMin: 1,
            goldMax: 10
        };
    }
    
    // Process item drops
    var droppedItems = [];
    for (var i = 0; i < array_length(dropTable.items); i++) {
        if (random(1) < dropTable.chances[i]) {
            var itemId = dropTable.items[i];
            AddItemToInventory(itemId, 1);
            array_push(droppedItems, global.itemLibrary[$ itemId].name);
        }
    }
    
    // Process gold drop
    var goldAmount = irandom_range(dropTable.goldMin, dropTable.goldMax);
    if (variable_global_exists("playerGold")) {
        global.playerGold += goldAmount;
    } else {
        global.playerGold = goldAmount;
    }
    
    // Return information about what was dropped
    return {
        items: droppedItems,
        gold: goldAmount
    };
}

// Initialize the inventory system on game start
InitInventory();