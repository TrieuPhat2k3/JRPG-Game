/// @description Draw Status Screen on GUI layer

// First, check if we have party data
if (!variable_global_exists("party") || array_length(global.party) == 0) {
    // Draw an error message on screen using sBox
    draw_sprite_ext(sBox, 0, 10, 10, 200/sprite_get_width(sBox), 60/sprite_get_height(sBox), 0, c_red, 0.8);
    draw_set_color(c_white);
    draw_set_font(fnM5x7);
    draw_text(20, 20, "ERROR: No party data found!");
    draw_text(20, 40, "Press G again to close");
    return;
}

// Calculate animation scale
var scaleMultiplier = 1;
if (isAnimating) {
    if (alarm[0] > 0) {
        // Closing animation
        scaleMultiplier = 1 - (animFrames - alarm[0]) / animFrames;
    } else {
        // Opening animation
        scaleMultiplier = animCounter / animFrames;
    }
}

// Calculate panel dimensions with animation
var currentPanelWidth = panelWidth * scaleMultiplier;
var currentPanelHeight = panelHeight * scaleMultiplier;
var currentPanelX = panelX + (panelWidth - currentPanelWidth) / 2;
var currentPanelY = panelY + (panelHeight - currentPanelHeight) / 2;

// Skip if panel is too small during animation
if (currentPanelWidth < 10 || currentPanelHeight < 10) return;

// Draw main panel background using sBox sprite
draw_sprite_ext(
    sBox, 0,
    currentPanelX, currentPanelY,
    currentPanelWidth/sprite_get_width(sBox), currentPanelHeight/sprite_get_height(sBox),
    0, c_white, bgAlpha
);

// Get current character data
var currentChar = global.party[selectedCharIndex];

// Draw title with character name - use smaller font
draw_set_font(fnM3x6);  // Changed from fnM5x7
draw_set_color(titleColor);
draw_set_halign(fa_center);
draw_text(
    currentPanelX + currentPanelWidth / 2,
    currentPanelY + 5, // Further reduced from 8
    currentChar.name + " - " + tabs[selectedTab]
);

// Reset text alignment
draw_set_halign(fa_left);

// Calculate inner panel positions - further reduced spacing
var innerPadding = 8; // Further reduced from 12
var charPanelX = currentPanelX + innerPadding/2;
var charPanelY = currentPanelY + 20; // Further reduced from 30
var charPanelCurrentWidth = (charPanelWidth * scaleMultiplier);
var charPanelCurrentHeight = (charPanelHeight * scaleMultiplier);

var statsPanelX = charPanelX + charPanelCurrentWidth + innerPadding/2;
var statsPanelY = charPanelY;
var statsPanelCurrentWidth = statsPanelWidth * scaleMultiplier;
var statsPanelCurrentHeight = statsPanelHeight * scaleMultiplier;

// Draw character panel using sBox
draw_sprite_ext(
    sBox, 0,
    charPanelX, charPanelY,
    charPanelCurrentWidth/sprite_get_width(sBox), charPanelCurrentHeight/sprite_get_height(sBox),
    0, c_white, bgAlpha
);

// Draw stats panel using sBox
draw_sprite_ext(
    sBox, 0,
    statsPanelX, statsPanelY,
    statsPanelCurrentWidth/sprite_get_width(sBox), statsPanelCurrentHeight/sprite_get_height(sBox),
    0, c_white, bgAlpha
);

// Draw character sprite
var spriteIndex = charSprites[selectedCharIndex];
var spriteWidth = sprite_get_width(spriteIndex);
var spriteHeight = sprite_get_height(spriteIndex);
var spriteScale = min(charPanelCurrentWidth / spriteWidth, charPanelCurrentHeight / spriteHeight) * 0.7; // Further reduced from 0.75
var spriteX = charPanelX + charPanelCurrentWidth / 2;
var spriteY = charPanelY + charPanelCurrentHeight / 2;

draw_sprite_ext(
    spriteIndex, 0,
    spriteX, spriteY,
    spriteScale, spriteScale,
    0, c_white, 1
);

// Draw tab content based on selected tab
switch (selectedTab) {
    case 0: // Stats tab
        DrawStatsTab(statsPanelX, statsPanelY, statsPanelCurrentWidth, statsPanelCurrentHeight, currentChar);
        break;
    case 1: // Equipment tab
        DrawEquipmentTab(statsPanelX, statsPanelY, statsPanelCurrentWidth, statsPanelCurrentHeight, currentChar);
        break;
    case 2: // Abilities tab
        DrawAbilitiesTab(statsPanelX, statsPanelY, statsPanelCurrentWidth, statsPanelCurrentHeight, currentChar);
        break;
}

// Draw controls at the bottom - even more compact
var controlY = currentPanelY + currentPanelHeight - 15; // Further reduced from 20
draw_set_font(fnM3x6);
draw_set_color(c_ltgray);
draw_set_halign(fa_center);

for (var i = 0; i < array_length(controls); i++) {
    var controlX = currentPanelX + (i + 1) * currentPanelWidth / (array_length(controls) + 1);
    draw_text(controlX, controlY, controls[i]);
}

// Reset drawing settings
draw_set_halign(fa_left);
draw_set_font(fnM5x7);
draw_set_color(c_white);
draw_set_alpha(1.0);

/// Functions for drawing specific tabs

function DrawStatsTab(x, y, width, height, char) {
    var padding = 8;      // Further reduced from 10
    var barHeight = 10;   // Further reduced from 12
    var textY = y + padding;
    var barWidth = width - (padding * 2);
    
    // Use smaller font for stats
    draw_set_font(fnM3x6);
    draw_set_color(textColor);
    
    // Level
    draw_text(x + padding, textY, "Level: " + string(char.level));
    textY += 15;          // Further reduced from 20
    
    // HP Bar
    draw_text(x + padding, textY, "HP: " + string(char.hp) + " / " + string(char.hpMax));
    textY += 12;          // Further reduced from 15
    
    // HP Bar background - use sBox with dark color
    draw_sprite_ext(
        sBox, 0,
        x + padding, textY,
        barWidth/sprite_get_width(sBox), barHeight/sprite_get_height(sBox),
        0, statBarBgColor, 1
    );
    
    // HP Bar fill - use sBox with hp color
    var hpFillWidth = (char.hp / char.hpMax) * barWidth;
    if (hpFillWidth > 0) {
        draw_sprite_ext(
            sBox, 0,
            x + padding, textY,
            hpFillWidth/sprite_get_width(sBox), barHeight/sprite_get_height(sBox),
            0, hpBarColor, 1
        );
    }
    
    textY += barHeight + 10;  // Further reduced from 12
    
    // MP Bar
    draw_text(x + padding, textY, "MP: " + string(char.mp) + " / " + string(char.mpMax));
    textY += 12;          // Further reduced from 15
    
    // MP Bar background - use sBox
    draw_sprite_ext(
        sBox, 0,
        x + padding, textY,
        barWidth/sprite_get_width(sBox), barHeight/sprite_get_height(sBox),
        0, statBarBgColor, 1
    );
    
    // MP Bar fill - use sBox with mp color
    var mpFillWidth = (char.mp / char.mpMax) * barWidth;
    if (mpFillWidth > 0) {
        draw_sprite_ext(
            sBox, 0,
            x + padding, textY,
            mpFillWidth/sprite_get_width(sBox), barHeight/sprite_get_height(sBox),
            0, mpBarColor, 1
        );
    }
    
    textY += barHeight + 10;  // Further reduced from 12
    
    // Strength
    draw_text(x + padding, textY, "Strength: " + string(char.strength));
    textY += 15;          // Further reduced from 20
    
    // XP Bar
    draw_text(x + padding, textY, "XP: " + string(char.xp) + " / " + string(char.xpToNextLevel));
    textY += 12;          // Further reduced from 15
    
    // XP Bar background - use sBox
    draw_sprite_ext(
        sBox, 0,
        x + padding, textY,
        barWidth/sprite_get_width(sBox), barHeight/sprite_get_height(sBox),
        0, statBarBgColor, 1
    );
    
    // XP Bar fill - use sBox with xp color
    var xpFillWidth = (char.xp / char.xpToNextLevel) * barWidth;
    if (xpFillWidth > 0) {
        draw_sprite_ext(
            sBox, 0,
            x + padding, textY,
            xpFillWidth/sprite_get_width(sBox), barHeight/sprite_get_height(sBox),
            0, xpBarColor, 1
        );
    }
}

function DrawEquipmentTab(x, y, width, height, char) {
    var padding = 8;     // Reduced from 15
    var textY = y + padding;
    
    // Draw equipment with smaller font
    draw_set_font(fnM3x6);  // Use smaller font
    draw_set_color(textColor);
    
    // Placeholder for equipment
    draw_text(x + padding, textY, "Equipment not implemented yet");
    textY += 15;  // Reduced from 30
    
    // Equipment slots
    var slots = ["Weapon", "Armor", "Accessory"];
    
    for (var i = 0; i < array_length(slots); i++) {
        draw_text(x + padding, textY, slots[i] + ": None");
        textY += 15;  // Reduced from 30
    }
}

function DrawAbilitiesTab(x, y, width, height, char) {
    var padding = 8;  // Reduced from 15
    var textY = y + padding;
    
    // Draw abilities with smaller font
    draw_set_font(fnM3x6);  // Use smaller font
    draw_set_color(textColor);
    
    // Check if character has actions
    if (variable_struct_exists(char, "actions") && array_length(char.actions) > 0) {
        for (var i = 0; i < array_length(char.actions); i++) {
            var action = char.actions[i];
            var actionName = action.name;
            var actionDesc = "";
            
            // Add MP cost if it exists
            if (variable_struct_exists(action, "mpCost")) {
                actionName += " (" + string(action.mpCost) + " MP)";
            }
            
            draw_text(x + padding, textY, actionName);
            textY += 15;  // Reduced from 30
        }
    } else {
        draw_text(x + padding, textY, "No abilities");
    }
} 