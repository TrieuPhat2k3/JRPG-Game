/// @description Initialize mini-map
// Mini-map configuration
visible = true;
isMinimized = false;
mapScale = 0.15; // Scale factor
borderSize = 6; // Border thickness

// Position and size
mapX = 12; // Top-left position X
mapY = 12; // Top-left position Y
mapWidth = 90; // Width of minimap
mapHeight = 70; // Height of minimap

// Map surface
mapSurface = -1;
mapSurfaceExists = false;

// Map colors
colorBackground = c_black;
colorWall = c_dkgray;
colorFloor = c_gray;
colorPlayer = c_lime;
colorEnemy = c_red;
colorNPC = c_yellow;
colorBorder = c_white;
bgAlpha = 0.75; // Background transparency

// Toggle key
toggleKey = ord("M");

// Mini-map is drawn on GUI layer
drawOnGUI = true;

// Create surfaces once at the beginning
alarm[0] = 1; // Delay creation by 1 frame to ensure room is loaded

// For animation effects
animFrames = 15; // Number of frames for show/hide animation
animCounter = 0;
isAnimating = false;
animatingIn = true;

// Store object lists for performance 
enemyList = ds_list_create();
npcList = ds_list_create(); 