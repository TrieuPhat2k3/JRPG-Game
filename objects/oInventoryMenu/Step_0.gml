// Don't process input if the inventory is closed or animating
if (currentState == INVENTORY_STATE.CLOSED && !closing) return;

// Handle animation
if (opening) {
    animationProgress += animationSpeed;
    if (animationProgress >= 1) {
        opening = false;
        animationProgress = 1;
    }
    return; // Don't process input during opening animation
}

if (closing) {
    animationProgress -= animationSpeed;
    if (animationProgress <= 0) {
        closing = false;
        animationProgress = 0;
        visible = false;
        // Make absolutely sure we're in closed state
        currentState = INVENTORY_STATE.CLOSED;
    }
    return; // Don't process input during closing animation
}

// Get input
var keyUp = keyboard_check_pressed(vk_up);
var keyDown = keyboard_check_pressed(vk_down);
var keyLeft = keyboard_check_pressed(vk_left);
var keyRight = keyboard_check_pressed(vk_right);
var keyConfirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
var keyCancel = keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace);
var keyInventory = keyboard_check_pressed(ord("I")); // 'I' key to toggle inventory

// Toggle inventory with 'I' key or Escape
if (keyInventory || (currentState != INVENTORY_STATE.SELECTING_TARGET && keyCancel)) {
    Close();
    return;
}

// Handle different states
switch (currentState) {
    case INVENTORY_STATE.SELECTING_ITEM:
        // Move selection up/down
        if (keyUp) {
            selectedIndex--;
            // Wrap around
            if (selectedIndex < 0) {
                if (currentPage > 0) {
                    currentPage--;
                    selectedIndex = itemsPerPage - 1;
                } else {
                    // Get the max valid index for the last page
                    var totalItems = ds_list_size(global.inventory);
                    var maxPage = max(0, floor((totalItems - 1) / itemsPerPage));
                    currentPage = maxPage;
                    var itemsOnLastPage = totalItems - (maxPage * itemsPerPage);
                    selectedIndex = max(0, itemsOnLastPage - 1);
                }
            }
            UpdateSelectedItem();
        }
        
        if (keyDown) {
            selectedIndex++;
            var itemsOnCurrentPage = min(itemsPerPage, 
                ds_list_size(global.inventory) - (currentPage * itemsPerPage));
                
            // Wrap around
            if (selectedIndex >= itemsOnCurrentPage) {
                selectedIndex = 0;
                var totalItems = ds_list_size(global.inventory);
                var maxPage = max(0, floor((totalItems - 1) / itemsPerPage));
                
                if (currentPage < maxPage) {
                    currentPage++;
                } else {
                    currentPage = 0;
                }
            }
            UpdateSelectedItem();
        }
        
        // Change pages with left/right
        if (keyLeft && currentPage > 0) {
            currentPage--;
            selectedIndex = 0;
            UpdateSelectedItem();
        }
        
        if (keyRight) {
            var totalItems = ds_list_size(global.inventory);
            var maxPage = max(0, floor((totalItems - 1) / itemsPerPage));
            
            if (currentPage < maxPage) {
                currentPage++;
                selectedIndex = 0;
                UpdateSelectedItem();
            }
        }
        
        // Select an item
        if (keyConfirm && selectedItem != noone) {
            var itemData = global.itemLibrary[$ selectedItem.id];
            
            if (itemData.type == ITEM_TYPE.CONSUMABLE && itemData.canUseInField) {
                // Move to action selection
                currentState = INVENTORY_STATE.SELECTING_ACTION;
                selectedAction = 0;
            }
        }
        break;
        
    case INVENTORY_STATE.SELECTING_ACTION:
        // Move selection left/right
        if (keyLeft || keyRight) {
            selectedAction = !selectedAction; // Toggle between 0 and 1
        }
        
        // Confirm action
        if (keyConfirm) {
            var itemData = global.itemLibrary[$ selectedItem.id];
            
            if (selectedAction == 0) { // "Use"
                if (itemData.targetParty) {
                    // If item affects all party members
                    if (itemData.targetAll) {
                        UseSelectedItem(global.party);
                        currentState = INVENTORY_STATE.SELECTING_ITEM;
                    } else {
                        // Move to target selection for party members
                        currentState = INVENTORY_STATE.SELECTING_TARGET;
                        targetIndex = 0; // Initialize target selection
                    }
                } else {
                    // For non-targeted items
                    UseSelectedItem(noone);
                    currentState = INVENTORY_STATE.SELECTING_ITEM;
                }
            } else { // "Discard"
                DiscardSelectedItem();
                currentState = INVENTORY_STATE.SELECTING_ITEM;
            }
        }
        
        // Cancel action selection
        if (keyCancel) {
            currentState = INVENTORY_STATE.SELECTING_ITEM;
        }
        break;
        
    case INVENTORY_STATE.SELECTING_TARGET:
        // Properly handle target selection
        if (keyUp) {
            targetIndex--;
            if (targetIndex < 0) targetIndex = array_length(global.party) - 1;
        }
        
        if (keyDown) {
            targetIndex++;
            if (targetIndex >= array_length(global.party)) targetIndex = 0;
        }
        
        // Confirm target selection
        if (keyConfirm && targetIndex < array_length(global.party)) {
            UseSelectedItem(global.party[targetIndex]);
            currentState = INVENTORY_STATE.SELECTING_ITEM;
        }
        
        // Cancel target selection
        if (keyCancel) {
            currentState = INVENTORY_STATE.SELECTING_ACTION;
        }
        break;
} 