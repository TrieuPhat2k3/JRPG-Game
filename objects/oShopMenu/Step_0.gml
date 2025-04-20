// oShopMenu Step Event
// Handle user input and menu navigation

// Update error message timer
if (errorTimer > 0) {
    errorTimer--;
}

// Handle ESC key to exit menu from any mode
if (keyboard_check_pressed(vk_escape)) {
    instance_destroy();
    return;
}

// Handle menu navigation based on current mode
switch (currentMode) {
    case SHOP_MODE.MAIN:
        // Main menu navigation (Buy/Sell/Exit)
        if (keyboard_check_pressed(vk_up)) {
            menuIndex = max(0, menuIndex - 1);
        }
        else if (keyboard_check_pressed(vk_down)) {
            menuIndex = min(array_length(mainMenuOptions) - 1, menuIndex + 1);
        }
        
        // Select an option
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(ord("F"))) {
            switch (menuIndex) {
                case 0: // Buy
                    currentMode = SHOP_MODE.BUY;
                    menuIndex = 0;
                    scrollOffset = 0;
                    break;
                case 1: // Sell
                    currentMode = SHOP_MODE.SELL;
                    menuIndex = 0;
                    scrollOffset = 0;
                    break;
                case 2: // Exit
                    instance_destroy();
                    break;
            }
        }
        
        // Exit with X key
        if (keyboard_check_pressed(ord("X"))) {
            instance_destroy();
        }
        break;
        
    case SHOP_MODE.BUY:
        // Shopping mode - browsing items to buy
        var buyableItems = GetBuyableItems();
        maxMenuIndex = array_length(buyableItems) + 1; // +1 for Return option
        
        // Navigate the item list
        if (keyboard_check_pressed(vk_up)) {
            menuIndex = max(0, menuIndex - 1);
            
            // Scroll up if needed
            if (menuIndex < scrollOffset) {
                scrollOffset = menuIndex;
            }
        }
        else if (keyboard_check_pressed(vk_down)) {
            menuIndex = min(maxMenuIndex - 1, menuIndex + 1);
            
            // Scroll down if needed
            if (menuIndex >= scrollOffset + maxVisibleItems) {
                scrollOffset = menuIndex - maxVisibleItems + 1;
            }
        }
        
        // Adjust quantity for item purchase (only if not on Return option)
        if (menuIndex < array_length(buyableItems)) {
            if (keyboard_check_pressed(vk_left)) {
                selectedQuantity = max(1, selectedQuantity - 1);
            }
            else if (keyboard_check_pressed(vk_right)) {
                selectedQuantity = min(99, selectedQuantity + 1);
            }
        }
        
        // Buy the selected item or return to main menu
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(ord("F"))) {
            // Check if user selected the Return option
            if (menuIndex >= array_length(buyableItems)) {
                // Return to main menu
                currentMode = SHOP_MODE.MAIN;
                menuIndex = 0;
                selectedQuantity = 1; // Reset quantity
            } else if (array_length(buyableItems) > 0) {
                // Try to buy the item
                if (BuyItem(menuIndex, selectedQuantity)) {
                    errorMessage = "Purchased " + string(selectedQuantity) + "x " + buyableItems[menuIndex].name + "!";
                    errorTimer = errorDuration;
                    selectedQuantity = 1; // Reset quantity
                }
            }
        }
        
        // Return to main menu with X key
        if (keyboard_check_pressed(ord("X"))) {
            currentMode = SHOP_MODE.MAIN;
            menuIndex = 0;
            selectedQuantity = 1; // Reset quantity
        }
        break;
        
    case SHOP_MODE.SELL:
        // Sell mode - choosing items to sell
        var sellableItems = GetSellableItems();
        maxMenuIndex = array_length(sellableItems) + 1; // +1 for Return option
        
        // Navigate the item list
        if (keyboard_check_pressed(vk_up)) {
            menuIndex = max(0, menuIndex - 1);
            
            // Scroll up if needed
            if (menuIndex < scrollOffset) {
                scrollOffset = menuIndex;
            }
        }
        else if (keyboard_check_pressed(vk_down)) {
            menuIndex = min(maxMenuIndex - 1, menuIndex + 1);
            
            // Scroll down if needed
            if (menuIndex >= scrollOffset + maxVisibleItems) {
                scrollOffset = menuIndex - maxVisibleItems + 1;
            }
        }
        
        // Adjust quantity for item selling (only if not on Return option)
        if (menuIndex < array_length(sellableItems)) {
            if (keyboard_check_pressed(vk_left)) {
                selectedQuantity = max(1, selectedQuantity - 1);
            }
            else if (keyboard_check_pressed(vk_right)) {
                selectedQuantity = min(sellableItems[menuIndex].count, selectedQuantity + 1);
            }
        }
        
        // Sell the selected item or return to main menu
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(ord("F"))) {
            // Check if user selected the Return option
            if (menuIndex >= array_length(sellableItems)) {
                // Return to main menu
                currentMode = SHOP_MODE.MAIN;
                menuIndex = 1; // Set to Sell option
                selectedQuantity = 1; // Reset quantity
            } else if (array_length(sellableItems) > 0) {
                // Try to sell the item
                if (SellItem(menuIndex, selectedQuantity)) {
                    errorMessage = "Sold " + string(selectedQuantity) + "x " + sellableItems[menuIndex].name + "!";
                    errorTimer = errorDuration;
                    selectedQuantity = 1; // Reset quantity
                    
                    // Refresh sellable items
                    sellableItems = GetSellableItems();
                    maxMenuIndex = array_length(sellableItems) + 1; // +1 for Return option
                    
                    // Adjust menu index if needed
                    if (menuIndex >= array_length(sellableItems)) {
                        menuIndex = max(0, array_length(sellableItems) - 1);
                    }
                }
            }
        }
        
        // Return to main menu with X key
        if (keyboard_check_pressed(ord("X"))) {
            currentMode = SHOP_MODE.MAIN;
            menuIndex = 1; // Set to Sell option
            selectedQuantity = 1; // Reset quantity
        }
        break;
    
    case SHOP_MODE.CONFIRM:
        // Currently unused - could be expanded for purchase confirmations
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(ord("F")) || keyboard_check_pressed(ord("X"))) {
            currentMode = SHOP_MODE.BUY;
        }
        break;
} 