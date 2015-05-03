// kinda crappy detection of which direction is north on the map
// requires the window to be in the upper left corner
// makes assumptions about window title bar height, etc.

import java.awt.Color;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;

Robot robot;
int barHeight = 42;

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
  new Rectangle(570, 22, barHeight, barHeight));
  
  PImage im = new PImage(screencapture);
  PImage edge = edgeDetect(im);
  PImage amp  = amplify(edge);
  PImage inv = invert(amp);
  PImage bar = removeBars(inv);
  PImage cir = removeOutside(bar);
  
  
  background(200);
  stroke(0);
  fill(0);
  int row = 0;
  text("Original Image:",0,12+(row)*barHeight);
  image(im,100,(row++)*barHeight);
  text("Edge Detected: ",0,12+(row)*barHeight);
  image(edge,100,(row++)*barHeight);
  text("Amplified:     ",0,12+(row)*barHeight);
  image(amp, 100,(row++)*barHeight);
  text("Inverted:      ",0,12+(row)*barHeight);
  image(inv, 100,(row++)*barHeight);
  text("No Bars:      ",0,12+(row)*barHeight);
  image(bar, 100,(row++)*barHeight);
  text("Only Center",   0,12+(row)*barHeight);
  image(cir, 100,(row++)*barHeight);
  
  float maxTheta = 0;
  float maxRadius = 0;
  float x0 = cir.width/2.0;
  float y0 = cir.height/2.0;
  for(int x = 0; x < cir.width; x++){
    for(int y = 0; y < cir.height; y++){
      if(cir.get(x,y) == color(255)) continue;
      float testRadius = sqrt((x-x0)*(x-x0) + (y-y0)*(y-y0));
      if(testRadius > maxRadius){
        maxRadius = testRadius;
        maxTheta = new PVector(x-x0,y-y0).heading();
      }
    }
  }
  
  text("Heading:"+maxTheta,   0,12+(row)*barHeight);
  image(cir, 100,(row++)*barHeight);
  stroke(255,0,0);
  line(100+x0,(row-1)*barHeight+y0,100+x0+20*cos(maxTheta),(row-1)*barHeight+y0+20*sin(maxTheta));
   
}

/**
  Removes top and bottom rows of pixels
*/
PImage removeBars(PImage im){
  PGraphics copy = createGraphics(im.width,im.height);
  copy.beginDraw();
  copy.background(im);
  copy.stroke(color(255));
  copy.line(0,0,copy.width,0);
  copy.line(0,copy.height-1,copy.width,copy.height-1);
  copy.endDraw();
  return copy;
}

/**
  Removes pixels farther from the center than a radius r
*/
PImage removeOutside(PImage im){
  float x0 = im.width/2.0;
  float y0 = im.height/2.0;
  float radius = 9;
  PImage copy = im.get();
  copy.loadPixels();
  for(int x = 0; x < copy.width; x++){
    for(int y = 0; y < copy.height; y++){
      if((x-x0)*(x-x0) + (y-y0)*(y-y0) > radius*radius) copy.set(x,y,color(255));
    }
  }
  copy.updatePixels();
  return copy;
}

/**
  Change white to black, black to white.  Assumes input is ONLY white and black.
*/

PImage invert(PImage im){
  PImage copy = im.get();
  copy.loadPixels();
  for(int i = 0; i < copy.pixels.length; i++){
    copy.pixels[i] = gray(copy.pixels[i]) == 255 ? color(0) : color(255);
  }
  copy.updatePixels();
  return copy;
}

/**
  Changes all grayscale pixels above threshold to white, all below to black.
*/
PImage amplify(PImage im){
  int threshold = 20;
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


/**
  Run a given 3x3 point spread function on an image
*/
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

/**
  return the grayscale equivalent of a color
*/
static final int gray(color p) { 
  return max((p >> 16) & 0xff, (p >> 8 ) & 0xff, p & 0xff);  
}
