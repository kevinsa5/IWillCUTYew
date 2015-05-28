import java.awt.Robot;
import java.awt.AWTException;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;

Robot robot;
PImage door;
PImage screen;
int xcoord;
int ycoord;
Boolean testbool;
PImage test;

void setup(){
  size(200,200);
  
  try {
      robot = new Robot();
  }
  catch (AWTException e) {
      e.printStackTrace();
  }
  
  door = loadImage("door.png");
  BufferedImage screencapture = robot.createScreenCapture(new Rectangle(0, 0, displayWidth, displayHeight));
  screen = new PImage(screencapture);
  //test = findDoor(door, screen);
  test = screen;
  testbool = (test == screen);
  System.out.println(testbool);
}

void draw(){
  background(0);
}

int findDoor(PImage door, PImage screen) {
  int screenIndex = 0;
  Boolean match;
  door.loadPixels();
  screen.loadPixels();
  for (int i = 0; i < (screen.width*screen.height-door.width*door.height); i++) {
    match = true;
    for (int j = 0; j < door.width*door.height; j++) {
      if (door.pixels[j] != screen.pixels[i+j]) {
        match = false;
      }
    }
    if (match == true) {
      screenIndex = i;
      break;
    }
  }
  System.out.println("done");
  return screenIndex;
}
