// requires the window to be in the upper left corner
// makes assumptions about window title bar height, etc.

import java.awt.Color;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;

Robot robot;

int barHeight = 16;
int barWidth = 300;

void setup(){
  size(400,400);
  try {
      robot = new Robot();
  } catch (AWTException e) {
      e.printStackTrace();
  }
}

void draw(){
  BufferedImage screencapture = robot.createScreenCapture(
  new Rectangle(33, 30, barWidth, barHeight));
  
  PImage im = new PImage(screencapture);
  PImage edge = edgeDetect(im);
  PImage amp  = amplify(edge);
  PImage inv = invert(amp);
  
  background(200);
  stroke(0);
  fill(0);
  
  text("Original Image:",0,12);
  image(im,100,0);
  text("Edge Detected: ",0,12+barHeight);
  image(edge,100,barHeight);
  text("Amplified:     ",0,12+2*barHeight);
  image(amp, 100,2*barHeight);
  text("Inverted:      ",0,12+3*barHeight);
  image(inv, 100,3*barHeight);
  /*
  stroke(255,0,0);
  for(int i = 0; i < width; i++){
    int sum = 0;
    for(int j = 0; j < barHeight; j++){
      sum += gray(im.get(i,j));
    }

    if(sum == 0){
      point(i,barHeight+3);
      point(i,barHeight+2);
      point(i,barHeight+1);
    }
  }
  */
}

PImage invert(PImage im){
  PImage copy = im.get();
  copy.loadPixels();
  for(int i = 0; i < copy.pixels.length; i++){
    copy.pixels[i] = gray(copy.pixels[i]) == 255 ? color(0) : color(255);
  }
  copy.updatePixels();
  return copy;
}

PImage amplify(PImage im){
  int threshold = 25;
  PImage copy = im.get();
  copy.loadPixels();
  for(int i = 0; i < copy.pixels.length; i++){
    if(gray(copy.pixels[i]) > threshold)
      copy.pixels[i] = color(255);
    else
      copy.pixels[i] = color(0);
  }
  copy.updatePixels();
  return copy;
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
