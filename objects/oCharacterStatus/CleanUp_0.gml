/// @description Clean up resources

// Free the portrait surface if it exists
if (surface_exists(portraitSurface)) {
    surface_free(portraitSurface);
    portraitSurface = -1;
} 