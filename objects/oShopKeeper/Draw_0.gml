// oShopKeeper Draw Event

// Draw the shopkeeper sprite
draw_self();

// Draw interaction prompt if player is in range and not already interacting
if (playerInRange && !isInteracting) {
    // Set text properties
    draw_set_font(fnM5x7);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    
    // Draw prompt above the shopkeeper
    var promptY = y - sprite_height - 10;
    
    // Use sBox sprite for background instead of drawing a rectangle
    var textWidth = string_width(interactionPrompt);
    var textHeight = string_height(interactionPrompt);
    var boxWidth = textWidth + 16;
    var boxHeight = textHeight + 12;
    
    // Draw the box sprite scaled to fit the text
    draw_sprite_stretched(sBox, 0, x - boxWidth/2, promptY - boxHeight/2, boxWidth, boxHeight);
    
    // Draw the text
    draw_text(x, promptY, interactionPrompt);
    
    // Reset text properties
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
} 