// Update timer
timer++;

// Move text upward
yOffset += moveSpeed;

// Fade out as lifetime ends
if (timer > lifetime * 0.5) {
    alpha = 1 - ((timer - (lifetime * 0.5)) / (lifetime * 0.5));
}

// Destroy when lifetime is over
if (timer >= lifetime) {
    instance_destroy();
}
