import java.awt.Color;
import java.awt.Robot;
import java.awt.PointerInfo;
import java.awt.MouseInfo;
import java.awt.Point;
import java.awt.AWTException;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;

Robot robot;

void setup(){
  size(400,400);
  try {
      robot = new Robot();
  } catch (AWTException e) {
      e.printStackTrace();
  }
}

void draw(){
  PointerInfo pi = MouseInfo.getPointerInfo();
  Point p = pi.getLocation();
  
  BufferedImage screencapture = robot.createScreenCapture(
  new Rectangle( (int)p.getX() - width/2, (int)p.getY() - height/2, width, height));
  
  PImage im = new PImage(screencapture);
  im = edgeDetect(im);
  background(im);
}

PImage edgeDetect(PImage im){
  float outer = -0.12;
  float inner = 0.9;
  float[][] pointSpread = {{outer, outer, outer}, 
                           {outer, inner, outer}, 
                           {outer, outer, outer}};
  return pointSpread3(im, pointSpread);
}

PImage pointSpread3(PImage im, float[][] pointSpread){
   PImage copy = im.get();
   copy.filter(GRAY);
   copy.loadPixels();
   int[] transformed = new int[copy.pixels.length];
   for(int x = 0; x < copy.width; x++){
    for(int y = 0; y < copy.height; y++){
      float sum = 0;
      for(int dx = -1; dx <= 1; dx++){
        for(int dy = -1; dy <= 1; dy++){
          if(x + dx >= 0 && x + dx < copy.width && y + dy >= 0 && y + dy < copy.height){
            sum += pointSpread[dy+1][dx+1] * gray(copy.pixels[(x+dx) + (y+dy)*im.width]);
          }
        }
      }
      transformed[x + y * copy.width] = color(sum > 0 ? sum : 0);
    }
  }
  PImage p = createImage(im.width, im.height, RGB);
  arrayCopy(transformed, p.pixels);
  p.loadPixels();
  return p;
}

static final int gray(color p) { 
  return max((p >> 16) & 0xff, (p >> 8 ) & 0xff, p & 0xff);  
}
