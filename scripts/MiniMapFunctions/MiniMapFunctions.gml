/// @function DrawMapContents()
/// @description Draws all elements of the mini-map to the map surface
function DrawMapContents() {
    // Make sure we have a valid player and surface
    if (!instance_exists(oPlayer) || !surface_exists(mapSurface)) return;
    
    // Set the surface as target
    surface_set_target(mapSurface);
    
    // Clear the surface
    draw_clear_alpha(colorBackground, 0);
    
    // Camera view info for reference
    var camX = camera_get_view_x(view_camera[0]);
    var camY = camera_get_view_y(view_camera[0]);
    var camW = camera_get_view_width(view_camera[0]);
    var camH = camera_get_view_height(view_camera[0]);
    
    // Calculate center offsets to position player in center
    var offsetX = (mapWidth / 2) - (oPlayer.x * mapScale);
    var offsetY = (mapHeight / 2) - (oPlayer.y * mapScale);
    
    // Draw walls from collision layer if available
    var collisionLayerId = layer_get_id("Tiles_Collision");
    if (collisionLayerId != -1) {
        var tilemapId = layer_tilemap_get_id(collisionLayerId);
        if (tilemap_get_width(tilemapId) > 0) {
            // Calculate the visible range in tilemap coordinates
            var tileSize = tilemap_get_tile_width(tilemapId);
            var startX = max(0, floor((camX - 200) / tileSize));
            var startY = max(0, floor((camY - 200) / tileSize));
            var endX = min(tilemap_get_width(tilemapId), ceil((camX + camW + 200) / tileSize));
            var endY = min(tilemap_get_height(tilemapId), ceil((camY + camH + 200) / tileSize));
            
            // Draw each collision tile
            for (var tx = startX; tx < endX; tx++) {
                for (var ty = startY; ty < endY; ty++) {
                    var tileData = tilemap_get(tilemapId, tx, ty);
                    if (tileData != 0) { // If there's a collision tile
                        var drawX = (tx * tileSize * mapScale) + offsetX;
                        var drawY = (ty * tileSize * mapScale) + offsetY;
                        var tileW = tileSize * mapScale;
                        
                        // Draw wall
                        draw_rectangle_color(
                            drawX, drawY, 
                            drawX + tileW, drawY + tileW,
                            colorWall, colorWall, colorWall, colorWall, 
                            false
                        );
                    }
                }
            }
        }
    }
    
    // Draw floor - simple background for walkable areas
    // Optional - can be skipped if not needed or too performance heavy
    
    // Draw NPCs
    for (var i = 0; i < ds_list_size(npcList); i++) {
        var npc = npcList[| i];
        if (instance_exists(npc)) {
            var drawX = (npc.x * mapScale) + offsetX;
            var drawY = (npc.y * mapScale) + offsetY;
            
            // Draw NPC dot (reduced from 2 to 1.5)
            draw_circle_color(
                drawX, drawY, 
                1.5, colorNPC, colorNPC, 
                false
            );
        }
    }
    
    // Draw enemies
    for (var i = 0; i < ds_list_size(enemyList); i++) {
        var enemy = enemyList[| i];
        if (instance_exists(enemy)) {
            var drawX = (enemy.x * mapScale) + offsetX;
            var drawY = (enemy.y * mapScale) + offsetY;
            
            // Draw enemy dot (reduced from 2 to 1.5)
            draw_circle_color(
                drawX, drawY, 
                1.5, colorEnemy, colorEnemy, 
                false
            );
        }
    }
    
    // Draw player
    var playerX = (oPlayer.x * mapScale) + offsetX;
    var playerY = (oPlayer.y * mapScale) + offsetY;
    
    // Draw player marker (reduced from 3 to 2)
    draw_circle_color(
        playerX, playerY, 
        2, colorPlayer, colorPlayer, 
        false
    );
    
    // Reset surface target
    surface_reset_target();
}

/// @function CreateMiniMap()
/// @description Creates the mini-map object if it doesn't exist
function CreateMiniMap() {
    if (!instance_exists(oMiniMap)) {
        instance_create_layer(0, 0, "Instances", oMiniMap);
        return true;
    }
    return false;
}

/// @function ToggleMiniMap()
/// @description Toggles the mini-map visibility
function ToggleMiniMap() {
    if (instance_exists(oMiniMap)) {
        with (oMiniMap) {
            isMinimized = !isMinimized;
            isAnimating = true;
            animCounter = 0;
            animatingIn = !isMinimized;
            
            return isMinimized;
        }
    }
    return false;
} 