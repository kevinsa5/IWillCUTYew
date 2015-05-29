import g4p_controls.*;

// requires the window to be in the upper left corner
// makes assumptions about window title bar height, etc.

Bot bot;

void setup() {
  size(450, 300);
  createGUI();
  frameRate(40);
  bot = new Bot();
}

void draw() {
  background(200);
  bot.updateGui();
  if(frameCount % (4800+400) < 4800)
    bot.mouseGrid();
  else
    bot.dropItems();
}

