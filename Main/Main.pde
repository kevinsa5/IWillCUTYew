import g4p_controls.*;

// requires the window to be in the upper left corner
// makes assumptions about window title bar height, etc.

Bot bot;
int state;
void setup() {
  size(450, 300);
  createGUI();
  frameRate(20);
  bot = new Bot();
  state = 1;
}

void draw() {
  background(200);
  bot.updateGui();/*
  if(state == 1 && bot.isIdle()){
    bot.dropItems();
    state = 2;
  } else if(state == 2 && bot.isIdle()){
    state = 1;
    bot.chopTree();
  }*/
}

