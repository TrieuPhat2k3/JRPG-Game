// Don't draw if the inventory is closed and not closing
if (currentState == INVENTORY_STATE.CLOSED && !closing) return;

// Check if window size changed and update menu position if needed
var guiWidth = display_get_gui_width();
var guiHeight = display_get_gui_height();
if (menuX != (guiWidth - menuWidth) / 2 || menuY != (guiHeight - menuHeight) / 2) {
    menuX = (guiWidth - menuWidth) / 2;
    menuY = (guiHeight - menuHeight) / 2;
}

// Apply animation
var drawWidth = menuWidth * animationProgress;
var drawHeight = menuHeight * animationProgress;
var drawX = menuX + (menuWidth - drawWidth) / 2;
var drawY = menuY + (menuHeight - drawHeight) / 2;

// Draw the menu background with a semi-transparent overlay behind it
draw_set_alpha(0.5 * animationProgress);
draw_rectangle_color(0, 0, guiWidth, guiHeight, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);

// Draw the menu background 
draw_sprite_stretched(sBox, 0, drawX, drawY, drawWidth, drawHeight);

// Exit early if still animating open/close
if (opening || closing) return;

// Make sure we don't draw if fully closed
if (currentState == INVENTORY_STATE.CLOSED) return;

// Draw title
draw_set_font(fnOpenSansPX);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(menuX + menuWidth / 2, menuY + 10, "INVENTORY");

// Draw gold amount
draw_set_halign(fa_right);
draw_text(menuX + menuWidth - 10, menuY + 10, "Gold: " + string(global.playerGold));

// Draw inventory contents
if (variable_global_exists("inventory") && ds_list_size(global.inventory) > 0) {
    draw_set_font(fnM5x7);
    draw_set_halign(fa_left);
    
    // Calculate items to display on current page
    var startIndex = currentPage * itemsPerPage;
    var endIndex = min(startIndex + itemsPerPage - 1, ds_list_size(global.inventory) - 1);
    
    // Draw each item in the current page
    for (var i = startIndex; i <= endIndex; i++) {
        var item = global.inventory[| i];
        var itemData = global.itemLibrary[$ item.id];
        var displayIndex = i - startIndex;
        
        // Determine if this item is selected
        var isSelected = (displayIndex == selectedIndex && currentState == INVENTORY_STATE.SELECTING_ITEM);
        
        // Set color based on selection
        draw_set_color(isSelected ? c_yellow : c_white);
        
        // Draw item name and quantity
        var yPos = menuY + 40 + (displayIndex * 20);
        draw_text(menuX + 20, yPos, itemData.name + " x" + string(item.quantity));
        
        // Draw item type indicator
        var typeText = "";
        switch (itemData.type) {
            case ITEM_TYPE.CONSUMABLE: typeText = "Use"; break;
            case ITEM_TYPE.KEY_ITEM: typeText = "Key"; break;
            case ITEM_TYPE.EQUIPMENT: typeText = "Equip"; break;
        }
        draw_text(menuX + menuWidth - 60, yPos, typeText);
    }
    
    // Draw page indicator
    var totalItems = ds_list_size(global.inventory);
    var maxPage = max(0, floor((totalItems - 1) / itemsPerPage));
    
    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_text(menuX + menuWidth / 2, menuY + menuHeight - 20, 
              "Page " + string(currentPage + 1) + "/" + string(maxPage + 1));
              
    // Draw item description if an item is selected
    if (selectedItem != noone) {
        var itemData = global.itemLibrary[$ selectedItem.id];
        draw_set_font(fnM3x6);
        draw_set_halign(fa_left);
        draw_text_ext(menuX + 20, menuY + menuHeight - 40, itemData.description, 12, menuWidth - 40);
    }
    
    // Draw action selection if in that state
    if (currentState == INVENTORY_STATE.SELECTING_ACTION) {
        // Draw action menu background
        var actionMenuWidth = 160;
        var actionMenuHeight = 80;
        var actionMenuX = menuX + menuWidth / 2 - actionMenuWidth / 2;
        var actionMenuY = menuY + menuHeight / 2 - actionMenuHeight / 2;
        
        draw_sprite_stretched(sBox, 0, actionMenuX, actionMenuY, actionMenuWidth, actionMenuHeight);
        
        // Draw action options
        draw_set_font(fnOpenSansPX);
        draw_set_halign(fa_center);
        
        for (var i = 0; i < array_length(actionButtons); i++) {
            draw_set_color(selectedAction == i ? c_yellow : c_white);
            draw_text(actionMenuX + actionMenuWidth / 2, 
                     actionMenuY + 20 + (i * 30), 
                     actionButtons[i]);
        }
    }
    
    // Draw target selection if in that state
    if (currentState == INVENTORY_STATE.SELECTING_TARGET) {
        // Draw target menu background
        var targetMenuWidth = 220;
        var targetMenuHeight = 140;
        var targetMenuX = menuX + menuWidth / 2 - targetMenuWidth / 2;
        var targetMenuY = menuY + menuHeight / 2 - targetMenuHeight / 2;
        
        draw_sprite_stretched(sBox, 0, targetMenuX, targetMenuY, targetMenuWidth, targetMenuHeight);
        
        // Draw title
        draw_set_font(fnOpenSansPX);
        draw_set_halign(fa_center);
        draw_set_color(c_white);
        draw_text(targetMenuX + targetMenuWidth / 2, targetMenuY + 10, "Select Target");
        
        // Draw party members as targets
        draw_set_font(fnM5x7);
        draw_set_halign(fa_left);
        
        for (var i = 0; i < array_length(global.party); i++) {
            var partyMember = global.party[i];
            // Set color based on selection
            draw_set_color(targetIndex == i ? c_yellow : c_white);
            
            // Draw name and stats
            var yPos = targetMenuY + 40 + (i * 25);
            draw_text(targetMenuX + 20, yPos, partyMember.name + 
                      " - HP: " + string(partyMember.hp) + "/" + string(partyMember.hpMax));
        }
        
        // Draw instructions
        draw_set_font(fnM3x6);
        draw_set_halign(fa_center);
        draw_set_color(c_white);
        draw_text(targetMenuX + targetMenuWidth / 2, targetMenuY + targetMenuHeight - 20, 
                  "Press ENTER to confirm, ESC to cancel");
    }
} else {
    // Draw message if inventory is empty
    draw_set_font(fnOpenSansPX);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text(menuX + menuWidth / 2, menuY + menuHeight / 2, "Inventory is empty");
} 