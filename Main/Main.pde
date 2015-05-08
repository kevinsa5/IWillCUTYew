import g4p_controls.*;

// requires the window to be in the upper left corner
// makes assumptions about window title bar height, etc.

Bot bot;

void setup() {
  size(600, 500);
  createGUI();
  frameRate(40);
  bot = new Bot();
}

void draw() {
  background(200);
  bot.updateGui();
  bot.mouseGrid();
}

