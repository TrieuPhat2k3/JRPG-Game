// Draw the menu background with a nicer appearance
draw_sprite_stretched(sBox, 0, x, y, widthFull, heightFull);

// Add a semi-transparent darkening layer
draw_set_alpha(0.2);
draw_rectangle_color(x+2, y+2, x+widthFull-2, y+heightFull-2, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);

// Setup text drawing properties
draw_set_color(c_white);
draw_set_font(fnM5x7);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _desc = !(description == -1);
var _scrollPush = max(0, hover - (visibleOptionsMax-1));

// Draw the description if it exists
if (_desc) {
	// Make the title/description stand out more
	draw_set_color(c_white);
	draw_set_font(fnOpenSansPX);
	draw_set_halign(fa_center);
	draw_text(x + widthFull/2, y + ymargin, description);
	
	// Reset font and alignment for menu items
	draw_set_font(fnM5x7);
	draw_set_halign(fa_left);
}

// Draw all options
for (var l = _desc; l < min(visibleOptionsMax + _desc, array_length(options) + _desc); l++)
{
	var _optionToShow = l - _desc + _scrollPush;
	var _str = options[_optionToShow][0];
	var _yPos = y + ymargin + l * heightLine;
	
	// Determine if this option is currently selected
	var isSelected = (hover == _optionToShow);
	
	// Set text color based on selection state and availability
	if (isSelected) {
		// Use a softer yellow for selected text - more gold/amber tone
		draw_set_color(make_color_rgb(255, 215, 0)); // Gold color
	} else {
		// Use white for normal text
		draw_set_color(c_white);
	}
	
	// Gray out unavailable options
	if (options[_optionToShow][3] == false) {
		draw_set_color(c_gray);
	}
	
	// Draw the option text with a small indicator for selected item
	if (isSelected) {
		draw_text(x + xmargin, _yPos, "> " + _str);
	} else {
		draw_text(x + xmargin, _yPos, "  " + _str);
	}
}

// Show scroll indicators if needed
if (visibleOptionsMax < array_length(options)) {
	if (_scrollPush > 0) {
		// Show up arrow if scrolled down
		draw_sprite(sUpArrow, 0, x + widthFull * 0.5, y + 7);
	}
	
	if (hover < array_length(options) - 1) {
		// Show down arrow if more options below
		draw_sprite(sDownArrow, 0, x + widthFull * 0.5, y + heightFull - 7);
	}
}