// oShopMenu Create Event
// Initialize the shop menu interface

// Get current shop inventory from the shopkeeper that created this menu
shopItems = [];
if (instance_exists(oShopKeeper)) {
    shopItems = oShopKeeper.shopItems;
}

// Initialize inventory if it doesn't exist yet
if (!variable_global_exists("inventory")) {
    global.inventory = ds_list_create();
    show_debug_message("Created new inventory list");
}
// Make sure inventory exists and is a valid ds_list
else if (!ds_exists(global.inventory, ds_type_list)) {
    global.inventory = ds_list_create();
    show_debug_message("Recreated inventory list (was invalid)");
}

// Menu state variables
enum SHOP_MODE {
    MAIN,    // Main shop menu (Buy/Sell/Exit)
    BUY,     // Buying items from shop
    SELL,    // Selling items to shop
    CONFIRM  // Confirmation dialog
}

// Menu positioning and size
// Calculate menu size proportional to screen resolution
var displayWidth = display_get_gui_width();
var displayHeight = display_get_gui_height();

// Calculate menu dimensions based on screen resolution
// Using golden ratio (1.618) for width:height proportion
var baseRatio = 1.618;
var screenRatio = displayWidth / displayHeight;

// Scale based on screen resolution with better aspect ratio
menuWidth = clamp(displayWidth * 0.35, 260, 340);  // 35% of screen width, min 260, max 340
menuHeight = clamp(menuWidth / baseRatio, 180, 280);  // Use golden ratio for natural proportions

// Center the menu on screen
menuX = (displayWidth - menuWidth) / 2;
menuY = (displayHeight - menuHeight) / 2;

// Menu navigation variables
currentMode = SHOP_MODE.MAIN;
menuIndex = 0;
maxMenuIndex = 2; // Buy, Sell, Exit
scrollOffset = 0;
// Adjust visible items based on new menu height
maxVisibleItems = floor((menuHeight - 90) / 20); // Subtract space for header and footer, divide by item height
maxVisibleItems = clamp(maxVisibleItems, 3, 8); // Ensure between 3-8 items visible

// Items being viewed or selected
selectedItem = noone;
selectedQuantity = 1;

// Player gold
if (!variable_global_exists("playerGold")) {
    global.playerGold = 100; // Default starting gold
}

// Initialize menu options for main menu
mainMenuOptions = [
    "Buy Items",
    "Sell Items",
    "Exit"
];

// Message variables
confirmMessage = "";
errorMessage = "";
errorTimer = 0;
errorDuration = 120; // 2 seconds at 60 FPS

// Support functions
function GetBuyableItems() {
    var items = [];
    for (var i = 0; i < array_length(shopItems); i++) {
        array_push(items, shopItems[i]);
    }
    return items;
}

function GetSellableItems() {
    var items = [];
    // Check if inventory exists
    if (variable_global_exists("inventory") && ds_exists(global.inventory, ds_type_list)) {
        // Go through player inventory to find sellable items
        for (var i = 0; i < ds_list_size(global.inventory); i++) {
            var item = global.inventory[| i];
            
            // Skip invalid items
            if (!is_struct(item)) {
                show_debug_message("WARNING: Invalid inventory item found at index " + string(i));
                continue;
            }
            
            // Handle different inventory formats
            if (variable_struct_exists(item, "id") && variable_global_exists("itemLibrary")) {
                // Modern format with ID that references itemLibrary
                var itemId = item.id;
                if (variable_struct_exists(global.itemLibrary, itemId)) {
                    var libraryItem = global.itemLibrary[$ itemId];
                    var sellPrice = 0;
                    
                    // Look up the item in the shopkeeper's inventory to find sell price
                    for (var j = 0; j < array_length(shopItems); j++) {
                        if (variable_struct_exists(shopItems[j], "name") && 
                            variable_struct_exists(libraryItem, "name") && 
                            shopItems[j].name == libraryItem.name) {
                            
                            sellPrice = shopItems[j].sellPrice;
                            break;
                        }
                    }
                    
                    // If item isn't in shop but has a value in the library, use half that
                    if (sellPrice == 0 && variable_struct_exists(libraryItem, "value")) {
                        sellPrice = libraryItem.value / 2;
                    }
                    
                    // Skip unsellable items
                    if (sellPrice <= 0) continue;
                    
                    // Add to sellable items list
                    array_push(items, {
                        name: libraryItem.name,
                        description: variable_struct_exists(libraryItem, "description") ? libraryItem.description : "No description",
                        price: sellPrice,
                        type: variable_struct_exists(libraryItem, "type") ? libraryItem.type : "item",
                        count: variable_struct_exists(item, "quantity") ? item.quantity : 1
                    });
                }
            }
            // Legacy format with name directly on the item
            else if (variable_struct_exists(item, "name")) {
                // Only add if it has a sell price
                for (var j = 0; j < array_length(shopItems); j++) {
                    if (variable_struct_exists(shopItems[j], "name") && 
                        shopItems[j].name == item.name) {
                        
                        array_push(items, {
                            name: item.name,
                            description: variable_struct_exists(item, "description") ? item.description : "No description",
                            price: shopItems[j].sellPrice,
                            type: variable_struct_exists(item, "type") ? item.type : "item",
                            count: variable_struct_exists(item, "count") ? item.count : 1
                        });
                        break;
                    }
                }
            }
        }
    }
    return items;
}

function BuyItem(itemIndex, quantity) {
    var buyableItems = GetBuyableItems();
    if (itemIndex < 0 || itemIndex >= array_length(buyableItems)) return false;
    
    var item = buyableItems[itemIndex];
    var totalCost = item.price * quantity;
    
    // Check if player has enough gold
    if (global.playerGold < totalCost) {
        errorMessage = "Not enough gold!";
        errorTimer = errorDuration;
        return false;
    }
    
    // Map shop item name to item library ID
    var itemLibraryId = "";
    
    // This maps the shop item names to the corresponding itemLibrary keys
    switch(item.name) {
        case "Potion": itemLibraryId = "healthPotion"; break;
        case "Hi-Potion": itemLibraryId = "elixir"; break;
        case "Ether": itemLibraryId = "manaPotion"; break;
        case "Phoenix Down": itemLibraryId = "herbPoultice"; break;
        case "Antidote": itemLibraryId = "antidote"; break;
        default: 
            // If no match, create a default key based on name
            itemLibraryId = string_lower(string_replace_all(item.name, " ", ""));
            break;
    }
    
    // Add to player's inventory using the proper inventory function
    if (variable_global_exists("AddItemToInventory")) {
        // Use the global AddItemToInventory function if it exists
        AddItemToInventory(itemLibraryId, quantity);
        
        // Deduct gold
        global.playerGold -= totalCost;
        return true;
    }
    else {
        // Manual fallback if the function doesn't exist
        if (variable_global_exists("inventory") && ds_exists(global.inventory, ds_type_list)) {
            // Check if item already exists in inventory
            var itemExists = false;
            for (var i = 0; i < ds_list_size(global.inventory); i++) {
                var invItem = global.inventory[| i];
                
                // Skip invalid items
                if (!is_struct(invItem)) continue;
                
                if (variable_struct_exists(invItem, "id") && invItem.id == itemLibraryId) {
                    // Update quantity if the item exists
                    if (variable_struct_exists(invItem, "quantity")) {
                        invItem.quantity += quantity;
                    } else {
                        invItem.quantity = quantity;
                    }
                    itemExists = true;
                    break;
                }
            }
            
            // If not found, add new item with the proper structure
            if (!itemExists) {
                ds_list_add(global.inventory, {
                    id: itemLibraryId,
                    quantity: quantity
                });
            }
            
            // Deduct gold
            global.playerGold -= totalCost;
            return true;
        }
    }
    
    return false;
}

function SellItem(itemIndex, quantity) {
    var sellableItems = GetSellableItems();
    if (itemIndex < 0 || itemIndex >= array_length(sellableItems)) return false;
    
    var item = sellableItems[itemIndex];
    var totalPrice = item.price * quantity;
    
    // Use the global RemoveItemFromInventory function if it exists
    if (variable_global_exists("RemoveItemFromInventory")) {
        // Get item id from name
        var itemId = "";
        for (var i = 0; i < ds_list_size(global.inventory); i++) {
            var invItem = global.inventory[| i];
            if (variable_struct_exists(invItem, "id") && 
                variable_struct_exists(global.itemLibrary[$ invItem.id], "name") &&
                global.itemLibrary[$ invItem.id].name == item.name) {
                
                itemId = invItem.id;
                
                // Check if we have enough
                if (invItem.quantity < quantity) {
                    errorMessage = "Not enough items to sell!";
                    errorTimer = errorDuration;
                    return false;
                }
                
                // Remove items using the global function
                RemoveItemFromInventory(itemId, quantity);
                
                // Add gold to player
                global.playerGold += totalPrice;
                return true;
            }
        }
        return false;
    }
    else {
        // Manual fallback approach
        // Check if player has the item in sufficient quantity
        var foundIndex = -1;
        for (var i = 0; i < ds_list_size(global.inventory); i++) {
            var invItem = global.inventory[| i];
            
            // Skip invalid items
            if (!is_struct(invItem)) continue;
            
            // Check for matching item by id or name
            var matchFound = false;
            
            // Try by ID first (if we have access to the item library)
            if (variable_struct_exists(invItem, "id") && 
                variable_global_exists("itemLibrary") &&
                variable_struct_exists(global.itemLibrary, invItem.id) &&
                variable_struct_exists(global.itemLibrary[$ invItem.id], "name") &&
                global.itemLibrary[$ invItem.id].name == item.name) {
                matchFound = true;
            }
            // If no ID match but we have a name field, check that
            else if (variable_struct_exists(invItem, "name") && invItem.name == item.name) {
                matchFound = true;
            }
            
            if (matchFound) {
                var itemQuantity = variable_struct_exists(invItem, "quantity") ? invItem.quantity :
                                   (variable_struct_exists(invItem, "count") ? invItem.count : 0);
                
                if (itemQuantity >= quantity) {
                    foundIndex = i;
                    break;
                } else {
                    errorMessage = "Not enough items to sell!";
                    errorTimer = errorDuration;
                    return false;
                }
            }
        }
        
        if (foundIndex == -1) return false;
        
        // Remove from inventory
        var invItem = global.inventory[| foundIndex];
        
        if (variable_struct_exists(invItem, "quantity")) {
            invItem.quantity -= quantity;
            if (invItem.quantity <= 0) {
                ds_list_delete(global.inventory, foundIndex);
            }
        } else if (variable_struct_exists(invItem, "count")) {
            invItem.count -= quantity;
            if (invItem.count <= 0) {
                ds_list_delete(global.inventory, foundIndex);
            }
        }
        
        // Add gold to player
        global.playerGold += totalPrice;
        return true;
    }
}

// Initialize Shop Menu
function InitShopMenu() {
    // Get shop inventory from shop keeper
    shopInventory = [];
    if (instance_exists(oShopKeeper)) {
        shopInventory = oShopKeeper.inventory;
    }
    
    // Set menu state
    currentMode = SHOP_MODE.MAIN;
    menuIndex = 0;
    scrollOffset = 0;
    maxVisibleItems = 5;
    errorMessage = "";
    errorTimer = 0;
    
    // Set menu dimensions based on screen resolution
    var displayWidth = display_get_width();
    var displayHeight = display_get_height();
    
    // Calculate proportional dimensions
    var menuWidthPercent = 0.5; // 50% of screen width
    var menuHeightPercent = 0.7; // 70% of screen height
    
    // Set minimum and maximum sizes
    var minWidth = 320;
    var maxWidth = 480;
    var minHeight = 280;
    var maxHeight = 400;
    
    // Calculate dimensions
    menuWidth = clamp(displayWidth * menuWidthPercent, minWidth, maxWidth);
    menuHeight = clamp(displayHeight * menuHeightPercent, minHeight, maxHeight);
    
    // Center on screen
    menuX = (display_get_width() - menuWidth) / 2;
    menuY = (display_get_height() - menuHeight) / 2;
    
    // Buy/Sell state
    inPurchaseMode = false;
    purchaseQty = 1;
    inSellMode = false;
    sellQty = 1;
    SELL_PRICE_RATIO = 0.8; // Sell at 80% of buy price
    
    // Item dimensions
    itemHeight = 20;
    lineHeight = 15;
    
    // Player inventory variables
    playerInventory = global.inventory;
    
    // Main menu options
    mainOptions = ["Buy", "Sell", "Exit"];
}

// Helper function to wrap text to a given width
function string_wrap(text, max_width) {
    var text_wrapped = "";
    var space = " ";
    var line_break = "\n";
    var char_pos = 1;
    var space_pos = 1;
    var current_text = "";
    var text_length = string_length(text);
    
    for (var i = 1; i <= text_length; i++) {
        var char = string_char_at(text, i);
        current_text += char;
        
        // If we hit a space, mark it
        if (char == space) {
            space_pos = char_pos;
        }
        
        // If the current text width exceeds max_width
        if (string_width(current_text) > max_width) {
            // We need to wrap - if we have a space, break at space
            if (space_pos != 1) {
                text_wrapped += string_copy(text, char_pos - space_pos + 1, space_pos - 1) + line_break;
                char_pos = space_pos + 1;
                i = space_pos;
            } 
            // No space found, force break at current position
            else {
                text_wrapped += string_copy(text, char_pos, char_pos - 1) + line_break;
                char_pos = i;
            }
            space_pos = 1;
            current_text = "";
        } else {
            char_pos++;
        }
    }
    
    // Add any remaining text
    if (char_pos <= text_length) {
        text_wrapped += string_copy(text, char_pos - 1, text_length - char_pos + 2);
    }
    
    return text_wrapped;
} 