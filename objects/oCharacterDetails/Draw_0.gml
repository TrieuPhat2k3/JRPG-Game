if (!visible) exit;

// Get camera view position and dimensions
var camX = camera_get_view_x(view_camera[0]);
var camY = camera_get_view_y(view_camera[0]);
var camWidth = camera_get_view_width(view_camera[0]);
var camHeight = camera_get_view_height(view_camera[0]);

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

// Get character data
var data = characterData[$ selectedCharacter];

// Draw title
draw_set_font(fnOpenSansPX);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(menuX + menuWidth / 2, menuY + 10, data.name + "'s Stats");

// Draw stats
draw_set_font(fnM5x7);
draw_set_halign(fa_left);
var currentY = menuY + 40;
var lineHeight = 25;

// Level
draw_text(menuX + 40, currentY, "Level: " + string(data.level));
currentY += lineHeight;

// HP
draw_text(menuX + 40, currentY, "HP: " + string(data.hp) + "/" + string(data.hpMax));
currentY += lineHeight;

// MP
draw_text(menuX + 40, currentY, "MP: " + string(data.mp) + "/" + string(data.mpMax));
currentY += lineHeight;

// Attack
draw_text(menuX + 40, currentY, "ATK: " + string(data.attack));
currentY += lineHeight;

// Defense
draw_text(menuX + 40, currentY, "DEF: " + string(data.defense)); 