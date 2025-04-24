if (!visible) exit;

// Get camera view position and dimensions
var camX = camera_get_view_x(view_camera[0]);
var camY = camera_get_view_y(view_camera[0]);
var camWidth = camera_get_view_width(view_camera[0]);
var camHeight = camera_get_view_height(view_camera[0]);

// Update menu position based on current camera view
menuX = camX + (camWidth - menuWidth) / 2;
menuY = camY + (camHeight - menuHeight) / 2;

// Handle animation
if (opening) {
    animationProgress += animationSpeed;
    if (animationProgress >= 1) {
        opening = false;
        animationProgress = 1;
    }
}

if (closing) {
    animationProgress -= animationSpeed;
    if (animationProgress <= 0) {
        closing = false;
        animationProgress = 0;
        visible = false;
    }
}

// Apply animation
var drawWidth = menuWidth * animationProgress;
var drawHeight = menuHeight * animationProgress;
var drawX = menuX + (menuWidth - drawWidth) / 2;
var drawY = menuY + (menuHeight - drawHeight) / 2;

// Draw the menu background with a semi-transparent overlay behind it
draw_set_alpha(0.5 * animationProgress);
draw_rectangle_color(camX, camY, camX + camWidth, camY + camHeight, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);

// Draw the menu background 
draw_sprite_stretched(sBox, 0, drawX, drawY, drawWidth, drawHeight);

// Exit early if still animating open/close
if (opening || closing) return;

// Draw title
draw_set_font(fnOpenSansPX);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(menuX + menuWidth / 2, menuY + 10, "CHARACTER STATS");

// Draw stats
draw_set_font(fnM5x7);
draw_set_halign(fa_left);
var currentY = menuY + 40;
var lineHeight = 7.5; // Reduced line height by half for tighter spacing
var columnWidth = menuWidth / 2;
var leftColumnX = menuX + 20;
var rightColumnX = menuX + columnWidth + 20;

// Left column - LuLu
draw_set_color(c_white);
draw_text_transformed(leftColumnX, currentY, "LuLu", 0.5, 0.5, 0);
currentY += lineHeight;

// LuLu's stats
if (variable_global_exists("party")) {
    var luluData = array_find_index(global.party, function(member) { return member.name == "Lulu"; });
    if (luluData != -1) {
        draw_text_transformed(leftColumnX, currentY, "Level: " + string(global.party[luluData].level), 0.5, 0.5, 0);
        currentY += lineHeight;
        draw_text_transformed(leftColumnX, currentY, "HP: " + string(global.party[luluData].hp) + "/" + string(global.party[luluData].hpMax), 0.5, 0.5, 0);
        currentY += lineHeight;
        draw_text_transformed(leftColumnX, currentY, "MP: " + string(global.party[luluData].mp) + "/" + string(global.party[luluData].mpMax), 0.5, 0.5, 0);
        currentY += lineHeight;
        var atkValue = variable_struct_exists(global.party[luluData], "strength") ? global.party[luluData].strength : 0;
        draw_text_transformed(leftColumnX, currentY, "ATK: " + string(atkValue), 0.5, 0.5, 0);
        currentY += lineHeight;
    }
}
draw_text_transformed(leftColumnX, currentY, "Actions:", 0.5, 0.5, 0);
currentY += lineHeight;

// LuLu's actions in two columns
var luluActionX1 = leftColumnX;
var luluActionX2 = leftColumnX + 30;
var luluActionY = currentY;
draw_text_transformed(luluActionX1, luluActionY, "- Attack", 0.5, 0.5, 0);
draw_text_transformed(luluActionX2, luluActionY, "- Defend", 0.5, 0.5, 0);

// Right column - Questy
currentY = menuY + 40;
draw_set_color(c_white);
draw_text_transformed(rightColumnX, currentY, "Questy", 0.5, 0.5, 0);
currentY += lineHeight;

// Questy's stats
if (variable_global_exists("party")) {
    var questyData = array_find_index(global.party, function(member) { return member.name == "Questy"; });
    if (questyData != -1) {
        draw_text_transformed(rightColumnX, currentY, "Level: " + string(global.party[questyData].level), 0.5, 0.5, 0);
        currentY += lineHeight;
        draw_text_transformed(rightColumnX, currentY, "HP: " + string(global.party[questyData].hp) + "/" + string(global.party[questyData].hpMax), 0.5, 0.5, 0);
        currentY += lineHeight;
        draw_text_transformed(rightColumnX, currentY, "MP: " + string(global.party[questyData].mp) + "/" + string(global.party[questyData].mpMax), 0.5, 0.5, 0);
        currentY += lineHeight;
        var atkValue = variable_struct_exists(global.party[questyData], "strength") ? global.party[questyData].strength : 0;
        draw_text_transformed(rightColumnX, currentY, "ATK: " + string(atkValue), 0.5, 0.5, 0);
        currentY += lineHeight;
    }
}
draw_text_transformed(rightColumnX, currentY, "Actions:", 0.5, 0.5, 0);
currentY += lineHeight;

// Questy's actions in two columns
var questyActionX1 = rightColumnX;
var questyActionX2 = rightColumnX + 30;
var questyActionY = currentY;
draw_text_transformed(questyActionX1, questyActionY, "- Attack", 0.5, 0.5, 0);
draw_text_transformed(questyActionX2, questyActionY, "", 0.5, 0.5, 0);
questyActionY += lineHeight;
draw_text_transformed(questyActionX1, questyActionY, "- Fire", 0.5, 0.5, 0);
draw_text_transformed(questyActionX2, questyActionY, "", 0.5, 0.5, 0);
questyActionY += lineHeight;
draw_text_transformed(questyActionX1, questyActionY, "- Ice", 0.5, 0.5, 0);
draw_text_transformed(questyActionX2, questyActionY, "", 0.5, 0.5, 0); 