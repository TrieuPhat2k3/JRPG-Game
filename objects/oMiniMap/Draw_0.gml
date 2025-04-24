if (!showMinimap) exit;

// Get camera view position
var camX = camera_get_view_x(view_camera[0]);
var camY = camera_get_view_y(view_camera[0]);
var camWidth = camera_get_view_width(view_camera[0]);
var camHeight = camera_get_view_height(view_camera[0]);

// Calculate position relative to camera view
var mapX = camX + 10; // 10 pixels from left edge of camera view
var mapY = camY + 10; // 10 pixels from top edge of camera view

// Calculate room dimensions
var roomWidth = room_width * scale;
var roomHeight = room_height * scale;

// Calculate the actual size of the minimap based on room proportions
var mapWidth = roomWidth;
var mapHeight = roomHeight;

// Draw background
draw_set_alpha(backgroundColorAlpha);
draw_set_color(backgroundColor);
draw_rectangle(mapX, mapY, mapX + mapWidth, mapY + mapHeight, false);
draw_set_alpha(1); // Reset alpha

// Draw border
draw_set_color(borderColor);
draw_rectangle(mapX, mapY, mapX + mapWidth, mapY + mapHeight, true);

// Draw room boundaries
draw_set_color(wallColor);
draw_rectangle(mapX, mapY, mapX + mapWidth, mapY + mapHeight, true);

// Draw land/water separation lines
var collisionLayer = layer_tilemap_get_id("Tiles_Collision");
if (collisionLayer != -1) {
    draw_set_color(c_white);
    draw_set_alpha(0.5);
    
    // Get tile size
    var tileSize = 16 * scale;
    
    // Draw lines for each tile
    for (var tx = 0; tx < room_width; tx += 16) {
        for (var ty = 0; ty < room_height; ty += 16) {
            var tile = tilemap_get_at_pixel(collisionLayer, tx, ty);
            
            // Check adjacent tiles
            var rightTile = tilemap_get_at_pixel(collisionLayer, tx + 16, ty);
            var downTile = tilemap_get_at_pixel(collisionLayer, tx, ty + 16);
            
            // Draw vertical line if there's a difference between current and right tile
            if (tile != rightTile) {
                var lineX = mapX + (tx + 16) * scale;
                var lineY1 = mapY + ty * scale;
                var lineY2 = mapY + (ty + 16) * scale;
                draw_line(lineX, lineY1, lineX, lineY2);
            }
            
            // Draw horizontal line if there's a difference between current and down tile
            if (tile != downTile) {
                var lineX1 = mapX + tx * scale;
                var lineX2 = mapX + (tx + 16) * scale;
                var lineY = mapY + (ty + 16) * scale;
                draw_line(lineX1, lineY, lineX2, lineY);
            }
        }
    }
    
    draw_set_alpha(1);
}

// Draw player position
if (instance_exists(oPlayer)) {
    draw_set_color(c_green);
    var playerX = mapX + (oPlayer.x * scale);
    var playerY = mapY + (oPlayer.y * scale);
    draw_circle(playerX, playerY, 1, true);
}

// Draw enemy positions
with (oSlime) {
    if (instance_exists(id)) {
        draw_set_color(c_red);
        var enemyX = mapX + (x * other.scale);
        var enemyY = mapY + (y * other.scale);
        draw_circle(enemyX, enemyY, 1, true);
    }
}

with (oBat) {
    if (instance_exists(id)) {
        draw_set_color(c_red);
        var enemyX = mapX + (x * other.scale);
        var enemyY = mapY + (y * other.scale);
        draw_circle(enemyX, enemyY, 1, true);
    }
}

// Draw shopkeeper position
with (oShopKeeper) {
    if (instance_exists(id)) {
        draw_set_color(c_yellow);
        var shopX = mapX + (x * other.scale);
        var shopY = mapY + (y * other.scale);
        draw_circle(shopX, shopY, 1, true);
    }
} 