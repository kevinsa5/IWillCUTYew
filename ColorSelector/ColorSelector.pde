import java.awt.Robot;
import java.awt.AWTException;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;
import java.awt.Point;
import java.awt.MouseInfo;
import java.awt.PointerInfo;

Robot robot;
int factor = 10;

void setup() {
  size(200, 200);
  try {
    robot = new Robot();
  }
  catch (AWTException e) {
    e.printStackTrace();
  }
}

void draw() {
  PointerInfo pi = MouseInfo.getPointerInfo();
  Point p = pi.getLocation();

  BufferedImage screencapture = robot.createScreenCapture(
  new Rectangle( (int)p.getX() - width/(2*factor), (int)p.getY() - height/(2*factor), width/factor, height/factor));
  PImage im = new PImage(screencapture);
    strokeWeight(1);
  noSmooth();

  for (int i = 0; i < im.width; i++) {
    for (int j = 0; j < im.height; j++) {
      stroke(im.get(i, j));
      for (int a = 0; a < factor; a++) {
        for (int b = 0; b < factor; b++) {
          point(i*factor+a, j*factor+b);
        }
      }
    }
  }
  strokeWeight(2);
  stroke(color(200,200));
  line(0, height/2, width, height/2);
  line(0, height/2 + factor, width, height/2 + factor);
  line(width/2, 0, width/2, height);
  line(width/2+factor, 0, width/2+factor, height);
  color c = im.get(im.width/2,im.height/2);
  smooth();
  fill(255);
  rect(0,0,120,20);
  fill(0);
  text(red(c) + " " + green(c) + " " + blue(c),5,15);
}

