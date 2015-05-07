// requires the window to be in the upper left corner
// makes assumptions about window title bar height, etc.

import java.awt.Color;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;

Robot robot;

int startx, starty = 50;

void setup(){
  size(400,400);
  try {
      robot = new Robot();
  } catch (AWTException e) {
      e.printStackTrace();
  }
  startx = 2;
  Color c = robot.getPixelColor(startx,100);
  while(startx < 300 &&  color(c.getRed(), c.getGreen(), c.getBlue()) == color(0)){
    startx++;
    c = robot.getPixelColor(startx,100);
  }
  if(startx >= 300){
    println("Couldn't find the window!!!");
  }
  starty = 100;
  c = robot.getPixelColor(startx-1,starty);
  while(starty > 0 && color(c.getRed(), c.getGreen(), c.getBlue()) == color(0)){
    starty--;
    c = robot.getPixelColor(startx-1,starty);
  }
  if(starty <= 0){
    println("Couldn't find the window!!!");
  }
  
}

void draw(){
  BufferedImage screencapture = robot.createScreenCapture(
  new Rectangle(startx, starty, 100, 100));
  PImage im = new PImage(screencapture);
  
  background(200);
  image(im,100,0);
 
}

