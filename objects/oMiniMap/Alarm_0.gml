/// @description Create surface
if (!surface_exists(mapSurface)) {
    mapSurface = surface_create(mapWidth, mapHeight);
    mapSurfaceExists = true;
} 