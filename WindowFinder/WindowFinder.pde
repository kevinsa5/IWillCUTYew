import java.awt.Color;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;
import java.awt.PointerInfo;
import java.awt.MouseInfo;
import java.awt.Point;

Robot robot;
PImage im;
PImage door;
PImage screen;
int xfound = 0;
int yfound = 0;


void setup(){
  size(520,340);
  try {
      robot = new Robot();
  } catch (AWTException e) {
      e.printStackTrace();
  }
  door = loadImage("door2.png");
  BufferedImage screencapture = robot.createScreenCapture(
  new Rectangle(0, 0, displayWidth, displayHeight));
  im = new PImage(screencapture);
  int count = 0;
  for (int i = 0; i < im.width; i++) {
    for (int j = 0; j < im.height; j++) {
      if (im.get(i,j) == color(76,189,78)) {
        count++;
        if (count == 5) {
          xfound = i - 644;
          yfound = j - 473;
        }
      }
    }
  }
}


void draw(){
  BufferedImage activescreen = robot.createScreenCapture(
  new Rectangle(xfound, yfound, 520, 340));
  screen = new PImage(activescreen);
  screen.resize(width,height);
  background(screen);
}
