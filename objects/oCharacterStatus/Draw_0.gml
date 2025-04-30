/// @description Provide basic visibility in the room
// The character status menu is primarily drawn on the GUI layer using Draw_64
// But we'll draw a simple indicator here to ensure the object is visible

// Draw a marker to show the object exists
draw_set_alpha(0.3);
draw_circle_color(x, y, 10, c_yellow, c_yellow, false);
draw_set_alpha(1.0); 