// Destroy the surface when the object is destroyed
if (surface_exists(surface)) {
    surface_free(surface);
} 