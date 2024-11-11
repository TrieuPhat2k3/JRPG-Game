// Get input
var _inputH = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var _inputV = keyboard_check(ord("S")) - keyboard_check(ord("W"));
var _inputD = point_direction(0,0,_inputH,_inputV);
var _inputM = point_distance(0,0,_inputH,_inputV);

// Calculate new position
var _newX = x + lengthdir_x(spdWalk * _inputM, _inputD);
var _newY = y + lengthdir_y(spdWalk * _inputM, _inputD);

// Fetch the tilemap layer (if not fetched in create event)
if (!variable_instance_exists(self, "collisionLayer")) {
    collisionLayer = layer_tilemap_get_id("CollisionLayerName");
}

// Perform collision checks in both the X and Y directions separately
var _collisionTileX = tilemap_get_at_pixel(collisionLayer, _newX, y);
var _collisionTileY = tilemap_get_at_pixel(collisionLayer, x, _newY);

// Allow movement in Y and X if there’s no collision in both directions
if (_collisionTileY == 0) {
    y = _newY;
}
if (_collisionTileX == 0) {
    x = _newX;
}

// Check if there is any movement in either direction
if (_inputM != 0 && (_collisionTileX == 0 || _collisionTileY == 0)) {
    // Checks if there's movement in any direction (X or Y) and no collision in that direction, will continue animation
    image_speed = 1;
    direction = _inputD;
} else if (_inputM != 0) {
    // Also checks if there's movement but blocked in one direction, still keep the animation playing
    image_speed = 1;
} else {
    image_speed = 0;
    animIndex = 0;
}

FourDirectionAnimate();