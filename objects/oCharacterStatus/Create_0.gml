/// @description Initialize the character status screen

// Make sure we're visible
visible = true;

// Check if we have party data
if (!variable_global_exists("party")) {
    show_debug_message("ERROR: Cannot create status screen - no party data exists!");
    instance_destroy();
    exit;
}

// Panel dimensions and position - USE GUI DIMENSIONS instead of room dimensions
// Further reduced panel size
panelWidth = 250;        // Reduced from 300
panelHeight = 180;       // Reduced from 220
panelX = (display_get_gui_width() - panelWidth) / 2;
panelY = (display_get_gui_height() - panelHeight) / 2;

// Character panel dimensions
charPanelWidth = 80;     // Reduced from 100
charPanelHeight = panelHeight - 30;  // Reduced from -40
statsPanelWidth = panelWidth - charPanelWidth - 15;  // Reduced spacing
statsPanelHeight = charPanelHeight;

// Animation
isAnimating = true;
animCounter = 0;
animFrames = 15;

// Colors
bgColor = c_black;
borderColor = c_white;
titleColor = c_yellow;
textColor = c_white;
statBarBgColor = c_dkgray;
hpBarColor = c_red;
mpBarColor = c_blue;
xpBarColor = c_lime;

// Alpha values
bgAlpha = 0.85;
borderAlpha = 1.0;

// Current selected character index
selectedCharIndex = 0;
characterCount = array_length(global.party);

// Tabs and selection
tabs = ["Stats", "Equipment", "Abilities"];
selectedTab = 0;

// Input cooldown to prevent too fast navigation
inputCooldown = 0;
inputCooldownMax = 10;

// Create surface for character portrait
portraitSurface = -1;

// Controls help text
controls = [
    "Left/Right: Switch Character",
    "Up/Down: Change Tab",
    "G: Close"
];

// Tab content
statsFields = [
    "Level",
    "HP",
    "MP",
    "Strength",
    "XP",
    "Next Level"
];

// Get character portrait sprite based on name
function GetCharacterPortrait(charName) {
    switch (charName) {
        case "Lulu": return sLuluIdle;
        case "Questy": return sQuestyIdle;
        default: return sLuluIdle; // Default fallback
    }
}

// Store sprites for each character
charSprites = [];
for (var i = 0; i < characterCount; i++) {
    charSprites[i] = GetCharacterPortrait(global.party[i].name);
} 