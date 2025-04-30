/// @description Draw mini-map on GUI layer

// Skip drawing if in battle
if (!visible || (variable_global_exists("inBattle") && global.inBattle)) {
    return;
}

// Calculate animation
var currentWidth = mapWidth;
var currentHeight = mapHeight;

if (isAnimating) {
    var animRatio = animatingIn ? animCounter / animFrames : 1 - (animCounter / animFrames);
    currentWidth = mapWidth * animRatio;
    currentHeight = mapHeight * animRatio;
} else if (isMinimized) {
    // If minimized and not animating, don't draw
    return;
}

// Draw background with transparency
draw_set_alpha(bgAlpha);
draw_rectangle_color(mapX, mapY, mapX + currentWidth, mapY + currentHeight, 
                    colorBackground, colorBackground, colorBackground, colorBackground, false);

// Reset alpha for other drawing
draw_set_alpha(1);

// Draw the map border
draw_rectangle_color(mapX, mapY, mapX + currentWidth, mapY + currentHeight, 
                    colorBorder, colorBorder, colorBorder, colorBorder, true);

// Draw the map contents on surface
if (surface_exists(mapSurface)) {
    DrawMapContents();
    draw_surface_part(mapSurface, 0, 0, currentWidth, currentHeight, mapX, mapY);
} else {
    // Recreate surface if it doesn't exist
    mapSurface = surface_create(mapWidth, mapHeight);
}

// Draw map title
draw_set_font(fnM3x6);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text(mapX + currentWidth/2, mapY + 2, room_get_name(room));

// Draw mini help text
draw_set_halign(fa_right);
draw_set_font(fnM3x6);
draw_text_color(mapX + currentWidth - 2, mapY + currentHeight - 8, 
               "Press M to " + (isMinimized ? "show" : "hide"),
               c_white, c_white, c_white, c_white, 0.8);

// Reset drawing settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1); 