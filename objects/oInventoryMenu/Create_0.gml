// Inventory menu properties
visible = false;
depth = -10000; // Ensure it's drawn on top

// Get screen dimensions for centering
var displayWidth = display_get_width();
var displayHeight = display_get_height();
var displayAspect = displayWidth / displayHeight;
var guiWidth = display_get_gui_width();
var guiHeight = display_get_gui_height();

// Menu dimensions - use a percentage of screen size for better scaling
menuWidth = min(guiWidth * 0.6, 400); // 60% of screen width, max 400px
menuHeight = min(guiHeight * 0.7, 300); // 70% of screen height, max 300px

// Center the menu on screen
menuX = (guiWidth - menuWidth) / 2;
menuY = (guiHeight - menuHeight) / 2;

// Pagination and selection variables
itemsPerPage = 8;
currentPage = 0;
selectedIndex = 0;
selectedItem = noone;
targetIndex = 0; // New variable for target selection

// State management
enum INVENTORY_STATE {
    CLOSED,
    SELECTING_ITEM,
    SELECTING_ACTION,
    SELECTING_TARGET
}
currentState = INVENTORY_STATE.CLOSED;

// Item action buttons
actionButtons = ["Use", "Discard"];
selectedAction = 0;

// Menu animations
opening = false;
closing = false;
animationProgress = 0;
animationSpeed = 0.1;

// Handle opening the inventory
function Open() {
    if (currentState == INVENTORY_STATE.CLOSED) {
        visible = true;
        opening = true;
        closing = false; // Ensure closing is false
        currentState = INVENTORY_STATE.SELECTING_ITEM;
        selectedIndex = 0;
        UpdateSelectedItem();
        
        // Update position - in case window was resized
        var guiWidth = display_get_gui_width();
        var guiHeight = display_get_gui_height();
        menuX = (guiWidth - menuWidth) / 2;
        menuY = (guiHeight - menuHeight) / 2;
    }
}

// Handle closing the inventory
function Close() {
    if (currentState != INVENTORY_STATE.CLOSED) {
        closing = true;
        opening = false; // Ensure opening is false
        currentState = INVENTORY_STATE.CLOSED;
        
        // Unpause the game (if applicable)
    }
}

// Update the currently selected item
function UpdateSelectedItem() {
    if (variable_global_exists("inventory") && ds_list_size(global.inventory) > 0) {
        var effectiveIndex = selectedIndex + (currentPage * itemsPerPage);
        
        // Check if the index is valid
        if (effectiveIndex < ds_list_size(global.inventory)) {
            selectedItem = global.inventory[| effectiveIndex];
        } else {
            selectedItem = noone;
        }
    } else {
        selectedItem = noone;
    }
}

// Use the currently selected item on a target
function UseSelectedItem(target) {
    if (selectedItem != noone) {
        var result = UseItem(selectedItem.id, target);
        if (result) {
            // Item was used successfully
            // Update the selected item in case it was removed
            UpdateSelectedItem();
        }
        return result;
    }
    return false;
}

// Discard the currently selected item
function DiscardSelectedItem() {
    if (selectedItem != noone) {
        RemoveItemFromInventory(selectedItem.id, 1);
        UpdateSelectedItem();
        return true;
    }
    return false;
}

// Toggle the inventory's visibility
function Toggle() {
    if (currentState == INVENTORY_STATE.CLOSED) {
        Open();
    } else {
        Close();
    }
} 