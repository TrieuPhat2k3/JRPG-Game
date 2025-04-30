/// @description Draw in world space (if needed)
// This is only used if drawOnGUI = false
// Most of the drawing happens in Draw GUI event

if (!drawOnGUI && visible && !global.inBattle) {
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
    
    // Draw background/frame
    draw_set_alpha(bgAlpha);
    draw_rectangle_color(mapX, mapY, mapX + currentWidth, mapY + currentHeight, 
                        colorBackground, colorBackground, colorBackground, colorBackground, false);
    
    // Draw border
    draw_set_alpha(1);
    draw_rectangle_color(mapX, mapY, mapX + currentWidth, mapY + currentHeight, 
                        colorBorder, colorBorder, colorBorder, colorBorder, true);
    
    // Draw contents
    if (surface_exists(mapSurface)) {
        DrawMapContents();
        draw_surface_part(mapSurface, 0, 0, currentWidth, currentHeight, mapX, mapY);
    }
} 