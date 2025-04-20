// oShopMenu Draw GUI Event
// Draw the shop menu interface

// Set text defaults
draw_set_font(fnM5x7);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Calculate padding based on menu dimensions
var paddingX = menuWidth * 0.05; // 5% of menu width
var paddingY = menuHeight * 0.05; // 5% of menu height
var lineHeight = 14;
var itemHeight = 19; // Increased for better spacing

// Define sell price ratio here in case it's not set elsewhere
var SELL_PRICE_RATIO = 0.5; // Default to selling at 50% of buy price if not defined

// Draw menu background
draw_sprite_stretched(sBox, 0, menuX, menuY, menuWidth, menuHeight);

// Draw error message if timer is still active
if (errorTimer > 0) {
    var errorY = menuY - 30;
    draw_set_halign(fa_center);
    draw_text(menuX + menuWidth/2, errorY, errorMessage);
    draw_set_halign(fa_left);
}

// Draw gold amount in top right of all screens
draw_set_color(c_yellow);
var goldText = "Gold: " + string(global.playerGold) + "G";
draw_set_halign(fa_right);
draw_text(menuX + menuWidth - paddingX, menuY + paddingY, goldText);
draw_set_halign(fa_left);
draw_set_color(c_white);

// Content area variables
var contentX = menuX + paddingX;
var contentY = menuY + paddingY*2 + lineHeight;
var contentWidth = menuWidth - (paddingX * 2);
var contentHeight = menuHeight - paddingY*3 - lineHeight;

// Draw different content based on current mode
switch (currentMode) {
    case SHOP_MODE.MAIN:
        // Draw shop title with larger font and centered
        draw_set_halign(fa_center);
        draw_set_color(c_yellow);
        draw_text_transformed(menuX + menuWidth/2, menuY + paddingY, "SHOP", 1.2, 1.2, 0);
        draw_set_halign(fa_left);
        draw_set_color(c_white);
        
        // Draw hint text in top left, like in buy/sell menus
        draw_set_color(c_ltgray);
        draw_text(contentX, menuY + paddingY, "F: Select");
        draw_set_color(c_white);
        
        // Draw main menu options
        var options = ["Buy", "Sell", "Exit"];
        
        // Center the main menu options vertically
        var totalHeight = array_length(options) * lineHeight * 1.5; // Adjusted for larger text
        var startY = menuY + (menuHeight - totalHeight) / 2;
        
        for (var i = 0; i < array_length(options); i++) {
            var optionX = menuX + menuWidth * 0.3; // Indent for better appearance
            var optionY = startY + i * lineHeight * 1.5; // Spaced further for larger text
            
            // Highlight selected option with larger text
            if (i == menuIndex) {
                draw_set_color(c_yellow);
                draw_text_transformed(optionX, optionY, "> " + options[i], 1.3, 1.3, 0); // Increased size
            } else {
                draw_set_color(c_white);
                draw_text_transformed(optionX, optionY, "  " + options[i], 1.3, 1.3, 0); // Increased size
            }
        }
        
        break;
        
    case SHOP_MODE.BUY:
        // Draw title
        draw_set_halign(fa_center);
        draw_set_color(c_yellow);
        draw_text_transformed(menuX + menuWidth/2, menuY + paddingY, "BUY ITEMS", 1.1, 1.1, 0);
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        
        // Draw back control in top left
        draw_set_color(c_ltgray);
        draw_text(contentX, menuY + paddingY, "X: Back");
        draw_set_color(c_white);
        
        // Get buyable items
        var buyableItems = GetBuyableItems();
        var itemCount = array_length(buyableItems);
        
        if (itemCount > 0) {
            // Make sure Return to Main Menu is included in total count
            var totalCount = itemCount + 1;
            
            // Determine visible items (3 at a time)
            var visibleCount = min(3, totalCount);
            
            // Adjust scrollOffset to ensure selected item is visible
            if (menuIndex < scrollOffset) {
                scrollOffset = menuIndex;
            } else if (menuIndex >= scrollOffset + visibleCount) {
                scrollOffset = menuIndex - visibleCount + 1;
            }
            
            // Draw list area background - using lighter transparent background 
            var listStartY = menuY + paddingY*2 + lineHeight*2;
            var listHeight = itemHeight * visibleCount + 10;
            
            // Calculate column positions
            var nameX = contentX + 20;
            var priceX = contentX + contentWidth - 70; // Adjusted position
            var actionX = contentX + contentWidth - 20;
            
            // Draw column headers
            var headerY = listStartY - lineHeight - 2;
            draw_set_color(c_ltgray);
            draw_text(nameX, headerY, "Item");
            
            draw_set_halign(fa_right);
            draw_text(priceX, headerY, "Price");
            draw_text(actionX, headerY, "Action");
            draw_set_halign(fa_left);
            
            // Draw visible items
            for (var i = 0; i < visibleCount; i++) {
                var itemIdx = i + scrollOffset;
                if (itemIdx >= totalCount) break;
                
                var yPos = listStartY + i * itemHeight + 5;
                
                // Draw item or return option
                if (itemIdx < itemCount) {
                    var item = buyableItems[itemIdx];
                    
                    // Draw item name (with selection indicator)
                    if (itemIdx == menuIndex) {
                        draw_set_color(c_yellow);
                        // Limit name width to prevent overlap
                        var maxNameWidth = priceX - nameX - 15;
                        var displayName = item.name;
                        if (string_width(displayName) > maxNameWidth) {
                            var shortenedName = "";
                            for (var c = 1; c <= string_length(displayName); c++) {
                                var testName = string_copy(displayName, 1, c) + "...";
                                if (string_width(testName) > maxNameWidth) {
                                    shortenedName = string_copy(displayName, 1, c-1) + "...";
                                    break;
                                }
                            }
                            displayName = shortenedName;
                        }
                        draw_text(nameX, yPos, "> " + displayName);
                    } else {
                        draw_set_color(c_white);
                        // Limit name width to prevent overlap
                        var maxNameWidth = priceX - nameX - 15;
                        var displayName = item.name;
                        if (string_width(displayName) > maxNameWidth) {
                            var shortenedName = "";
                            for (var c = 1; c <= string_length(displayName); c++) {
                                var testName = string_copy(displayName, 1, c) + "...";
                                if (string_width(testName) > maxNameWidth) {
                                    shortenedName = string_copy(displayName, 1, c-1) + "...";
                                    break;
                                }
                            }
                            displayName = shortenedName;
                        }
                        draw_text(nameX, yPos, "  " + displayName);
                    }
                    
                    // Draw price
                    draw_set_halign(fa_right);
                    draw_text(priceX, yPos, string(item.price) + "G");
                    
                    // Draw buy action for selected item
                    if (itemIdx == menuIndex) {
                        draw_text(actionX, yPos, "F: Buy");
                    }
                    draw_set_halign(fa_left);
                } else {
                    // Draw return option
                    if (itemIdx == menuIndex) {
                        draw_set_color(c_yellow);
                        draw_text(nameX, yPos, "> Return to Main Menu");
                        
                        // Draw action
                        draw_set_halign(fa_right);
                        draw_text(actionX, yPos, "F: Select");
                        draw_set_halign(fa_left);
                    } else {
                        draw_set_color(c_white);
                        draw_text(nameX, yPos, "  Return to Main Menu");
                    }
                }
                
                draw_set_color(c_white);
            }
            
            // Draw separator line
            var separatorY = listStartY + listHeight + 15;
            draw_set_color(c_dkgray);
            draw_line(contentX, separatorY, contentX + contentWidth, separatorY);
            
            // Show selected item details below separator
            if (menuIndex >= 0 && menuIndex < itemCount) {
                var item = buyableItems[menuIndex];
                
                // Section header
                var detailsY = separatorY + 10;
                draw_set_color(c_yellow);
                draw_text(contentX + 10, detailsY, "Item Details:");
                draw_set_color(c_white);
                
                // Draw item description with better wrapping
                var descY = detailsY + lineHeight + 5;
                var desc = item.description;
                
                // Split description into lines if needed 
                if (string_width(desc) > contentWidth - 20) {
                    var maxChars = floor((contentWidth - 20) / string_width("M")) * 2;
                    var line1 = string_copy(desc, 1, maxChars);
                    var line2 = string_copy(desc, maxChars + 1, string_length(desc) - maxChars);
                    
                    if (string_length(line2) > maxChars) {
                        line2 = string_copy(line2, 1, maxChars - 3) + "...";
                    }
                    
                    draw_text(contentX + 10, descY, line1);
                    draw_text(contentX + 10, descY + lineHeight, line2);
                } else {
                    draw_text(contentX + 10, descY, desc);
                }
                
                // Purchase UI
                if (variable_instance_exists(id, "inPurchaseMode") && inPurchaseMode) {
                    draw_set_color(c_yellow);
                    draw_text(contentX + 10, descY + lineHeight*3, "Quantity: " + string(purchaseQty));
                    draw_text(contentX + 10, descY + lineHeight*4, "Total Cost: " + string(purchaseQty * item.price) + "G");
                    
                    // Draw purchase controls
                    draw_set_color(c_white);
                    draw_set_halign(fa_center);
                    draw_text(menuX + menuWidth/2, menuY + menuHeight - paddingY, "←→: Adjust Qty  F: Buy  X: Cancel");
                    draw_set_halign(fa_left);
                }
            }
        } else {
            // No items available
            draw_set_halign(fa_center);
            draw_text(menuX + menuWidth/2, menuY + menuHeight/2, "No items available for purchase.");
            draw_set_halign(fa_left);
        }
        break;
        
    case SHOP_MODE.SELL:
        // Check if SELL_PRICE_RATIO is defined in the instance, if so use that instead
        if (variable_instance_exists(id, "SELL_PRICE_RATIO")) {
            SELL_PRICE_RATIO = self.SELL_PRICE_RATIO;
        }
        
        // Draw title
        draw_set_halign(fa_center);
        draw_set_color(c_yellow);
        draw_text_transformed(menuX + menuWidth/2, menuY + paddingY, "SELL ITEMS", 1.1, 1.1, 0);
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        
        // Draw back control in top left
        draw_set_color(c_ltgray);
        draw_text(contentX, menuY + paddingY, "X: Back");
        draw_set_color(c_white);
        
        // Get sellable items
        var sellableItems = GetSellableItems();
        var itemCount = array_length(sellableItems);
        
        if (itemCount > 0) {
            // Make sure Return to Main Menu is included in total count
            var totalCount = itemCount + 1;
            
            // Determine visible items (3 at a time)
            var visibleCount = min(3, totalCount);
            
            // Adjust scrollOffset to ensure selected item is visible
            if (menuIndex < scrollOffset) {
                scrollOffset = menuIndex;
            } else if (menuIndex >= scrollOffset + visibleCount) {
                scrollOffset = menuIndex - visibleCount + 1;
            }
            
            // Draw list area background - using lighter transparent background
            var listStartY = menuY + paddingY*2 + lineHeight*2;
            var listHeight = itemHeight * visibleCount + 10;
            
            // Calculate column positions
            var nameX = contentX + 20;
            var countX = contentX + contentWidth - 120;
            var valueX = contentX + contentWidth - 70;
            var actionX = contentX + contentWidth - 20;
            
            // Draw column headers
            var headerY = listStartY - lineHeight - 2;
            draw_set_color(c_ltgray);
            draw_text(nameX, headerY, "Item");
            
            draw_set_halign(fa_right);
            draw_text(countX, headerY, "Qty");
            draw_text(valueX, headerY, "Value");
            draw_text(actionX, headerY, "Action");
            draw_set_halign(fa_left);
            
            // Draw visible items
            for (var i = 0; i < visibleCount; i++) {
                var itemIdx = i + scrollOffset;
                if (itemIdx >= totalCount) break;
                
                var yPos = listStartY + i * itemHeight + 5;
                
                // Draw item or return option
                if (itemIdx < itemCount) {
                    var item = sellableItems[itemIdx];
                    
                    // Draw item name (with selection indicator)
                    if (itemIdx == menuIndex) {
                        draw_set_color(c_yellow);
                        // Limit name width to prevent overlap
                        var maxNameWidth = countX - nameX - 15;
                        var displayName = item.name;
                        if (string_width(displayName) > maxNameWidth) {
                            var shortenedName = "";
                            for (var c = 1; c <= string_length(displayName); c++) {
                                var testName = string_copy(displayName, 1, c) + "...";
                                if (string_width(testName) > maxNameWidth) {
                                    shortenedName = string_copy(displayName, 1, c-1) + "...";
                                    break;
                                }
                            }
                            displayName = shortenedName;
                        }
                        draw_text(nameX, yPos, "> " + displayName);
                    } else {
                        draw_set_color(c_white);
                        // Limit name width to prevent overlap
                        var maxNameWidth = countX - nameX - 15;
                        var displayName = item.name;
                        if (string_width(displayName) > maxNameWidth) {
                            var shortenedName = "";
                            for (var c = 1; c <= string_length(displayName); c++) {
                                var testName = string_copy(displayName, 1, c) + "...";
                                if (string_width(testName) > maxNameWidth) {
                                    shortenedName = string_copy(displayName, 1, c-1) + "...";
                                    break;
                                }
                            }
                            displayName = shortenedName;
                        }
                        draw_text(nameX, yPos, "  " + displayName);
                    }
                    
                    // Draw count and value
                    draw_set_halign(fa_right);
                    draw_text(countX, yPos, "x" + string(item.count));
                    
                    var sellValue = floor(item.price * SELL_PRICE_RATIO);
                    draw_text(valueX, yPos, string(sellValue) + "G");
                    
                    // Draw sell action for selected item
                    if (itemIdx == menuIndex) {
                        draw_text(actionX, yPos, "F: Sell");
                    }
                    draw_set_halign(fa_left);
                } else {
                    // Draw return option
                    if (itemIdx == menuIndex) {
                        draw_set_color(c_yellow);
                        draw_text(nameX, yPos, "> Return to Main Menu");
                        
                        // Draw action
                        draw_set_halign(fa_right);
                        draw_text(actionX, yPos, "F: Select");
                        draw_set_halign(fa_left);
                    } else {
                        draw_set_color(c_white);
                        draw_text(nameX, yPos, "  Return to Main Menu");
                    }
                }
                
                draw_set_color(c_white);
            }
            
            // Draw separator line
            var separatorY = listStartY + listHeight + 15;
            draw_set_color(c_dkgray);
            draw_line(contentX, separatorY, contentX + contentWidth, separatorY);
            
            // Show selected item details below separator
            if (menuIndex >= 0 && menuIndex < itemCount) {
                var item = sellableItems[menuIndex];
                
                // Section header
                var detailsY = separatorY + 10;
                draw_set_color(c_yellow);
                draw_text(contentX + 10, detailsY, "Item Details:");
                draw_set_color(c_white);
                
                // Draw item description with better wrapping
                var descY = detailsY + lineHeight + 5;
                var desc = item.description;
                
                // Split description into lines if needed 
                if (string_width(desc) > contentWidth - 20) {
                    var maxChars = floor((contentWidth - 20) / string_width("M")) * 2;
                    var line1 = string_copy(desc, 1, maxChars);
                    var line2 = string_copy(desc, maxChars + 1, string_length(desc) - maxChars);
                    
                    if (string_length(line2) > maxChars) {
                        line2 = string_copy(line2, 1, maxChars - 3) + "...";
                    }
                    
                    draw_text(contentX + 10, descY, line1);
                    draw_text(contentX + 10, descY + lineHeight, line2);
                } else {
                    draw_text(contentX + 10, descY, desc);
                }
                
                // Sell UI
                var sellValue = floor(item.price * SELL_PRICE_RATIO);
                if (variable_instance_exists(id, "inSellMode") && inSellMode) {
                    draw_set_color(c_yellow);
                    draw_text(contentX + 10, descY + lineHeight*3, "Quantity: " + string(sellQty));
                    draw_text(contentX + 10, descY + lineHeight*4, "Total Value: " + string(sellQty * sellValue) + "G");
                    
                    // Draw sell controls
                    draw_set_color(c_white);
                    draw_set_halign(fa_center);
                    draw_text(menuX + menuWidth/2, menuY + menuHeight - paddingY, "←→: Adjust Qty  F: Sell  X: Cancel");
                    draw_set_halign(fa_left);
                }
            }
        } else {
            // No items available
            draw_set_halign(fa_center);
            draw_text(menuX + menuWidth/2, menuY + menuHeight/2, "No items available to sell.");
            draw_set_halign(fa_left);
        }
        break;
    
    case SHOP_MODE.CONFIRM:
        // Draw confirmation dialog
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_text(menuX + menuWidth/2, menuY + menuHeight/2, confirmMessage);
        
        draw_text(menuX + menuWidth/2, menuY + menuHeight - paddingY, "F: Confirm  X: Cancel");
        draw_set_halign(fa_left);
        break;
}

// Draw error/notification message if active
if (errorTimer > 0) {
    // Calculate alpha based on remaining time
    var alpha = min(1.0, errorTimer / 30);
    if (errorTimer < 30) alpha = errorTimer / 30;
    
    // Draw message with fading effect
    draw_set_alpha(alpha);
    
    // Get dimensions for message box
    var msgWidth = string_width(errorMessage) + 40;
    var msgHeight = string_height(errorMessage) + 20;
    var msgX = display_get_gui_width() / 2;
    var msgY = display_get_gui_height() / 2 - 50;
    
    // Draw background using sBox sprite
    draw_sprite_stretched(sBox, 0, msgX - msgWidth/2, msgY - msgHeight/2, msgWidth, msgHeight);
    
    // Center the text both horizontally and vertically within the box
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text(msgX, msgY, errorMessage);
    
    // Reset drawing properties
    draw_set_alpha(1.0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
} 