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
  strokeWeight(2);
}

void draw() {
  PointerInfo pi = MouseInfo.getPointerInfo();
  Point p = pi.getLocation();

  BufferedImage screencapture = robot.createScreenCapture(
  new Rectangle( (int)p.getX() - width/(2*factor), (int)p.getY() - height/(2*factor), width/factor, height/factor));
  PImage im = new PImage(screencapture);
  im.loadPixels();
  loadPixels();
  for (int i = 0; i < im.width; i++) {
    for (int j = 0; j < im.height; j++) {
      //don't draw under the text box
      if((i+1)*factor <= 50 && (j+1)*factor <=60)
        continue;
      for (int a = 0; a < factor; a++) {
        for (int b = 0; b < factor; b++) {
          pixels[(i*factor+a) + (j*factor+b)*width] = im.pixels[j*im.width + i];
        }
      }
    }
  }
  updatePixels();
  stroke(color(200,200));
  line(0, height/2, width, height/2);
  line(0, height/2 + factor, width, height/2 + factor);
  line(width/2, 0, width/2, height);
  line(width/2+factor, 0, width/2+factor, height);
  color c = im.get(im.width/2,im.height/2);
  fill(255);
  rect(0,0,50,60);
  fill(0);
  text("R: " + (int)red(c),5,15);
  text("G: " + (int)green(c),5,35);
  text("B: " + (int)blue(c),5,55);
}

