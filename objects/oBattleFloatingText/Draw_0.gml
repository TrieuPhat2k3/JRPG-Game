// Set the font and color
draw_set_font(font);
draw_set_color(color);
draw_set_alpha(alpha);

// Draw the text
draw_text(x, y - yOffset, text);

// Reset drawing settings
draw_set_alpha(1);