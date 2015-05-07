// requires the window to be in the upper left corner
// makes assumptions about window title bar height, etc.

import java.awt.Color;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;

Robot robot;

int barHeight = 17;
int barWidth = 300;

void setup(){
  size(400,400);
  frameRate(30);
  try {
      robot = new Robot();
  } catch (AWTException e) {
      e.printStackTrace();
  }
}

void draw(){
  BufferedImage screencapture = robot.createScreenCapture(
  new Rectangle(33, 29, barWidth, barHeight));
  
  PImage im = new PImage(screencapture);
  PImage edge = edgeDetect(im);
  PImage amp  = amplify(edge);
  PImage inv = invert(amp);
  PImage iso = removeIsolates(inv);
  PImage bar = removeBars(iso);
  
  
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
  text("No Isolates:      ",0,12+(row)*barHeight);
  image(iso, 100,(row++)*barHeight);
  text("No Bars:      ",0,12+(row)*barHeight);
  image(bar, 100,(row++)*barHeight);
  //text("Space Separation:      ",0,12+(row)*barHeight);
  //image(bar, 100,(row++)*barHeight);
  
  stroke(255,0,0);
  int characterStart = -1;
  int ncleans = 0;
  ArrayList<PImage> characters = new ArrayList<PImage>();
  for(int x = 0; x < bar.width; x++){
    boolean clean = true;
    for(int y = 0; y < bar.height; y++){
      if(bar.get(x,y) == color(0)){
        clean = false;
        break;
      }
    }
    if(!clean && characterStart == -1){
      characterStart = x;
      if(ncleans > 3){
        PImage temp = bar.get(x-ncleans,0,ncleans,bar.height);
        characters.add(temp);
      }
      ncleans = 0;
    }
    if(clean && characterStart != -1){
      PImage temp = bar.get(characterStart,0,(x-characterStart),bar.height);
      if(temp.width > 1)
        characters.add(temp);
      characterStart = -1;
    }
    if(clean && characterStart == -1){
      ncleans++;
    }
    
    
    
  }
  int tx = 0;
  row++;
  for(int i = 0; i < characters.size(); i++){
     image(characters.get(i), tx, row*barHeight);
     tx += characters.get(i).width + 5;
  }
  row++;

  if(characters.size() > 0){
    PImage raw = characters.get(0);
    PImage p = createImage(8,10,RGB);
    p.filter(THRESHOLD,0.0);
    int wide = raw.width > 8 ? 8 : raw.width;
    int high = raw.height > 10 ? 10 : raw.height;
    println(wide + " " + high);
    p.set((8 - wide)/2,0,raw.get(0,3,wide,high));
    image(p,70,row*barHeight);
    if(p.width == 8 && p.height == 10){
      text(match(p),100,(row+1)*barHeight);
    }
  }
  row++;
  
  row++;
  PImage sim = simplify(im);
  edge = edgeDetect(sim);
  amp  = amplify(edge);
  inv = invert(amp);
  text("Simplified:    ",0,12+(row)*barHeight);
  image(sim, 100,(row++)*barHeight);
  text("Edge Detected: ",0,12+(row)*barHeight);
  image(edge,100,(row++)*barHeight);
  text("Amplified:     ",0,12+(row)*barHeight);
  image(amp, 100,(row++)*barHeight);
  text("Inverted:      ",0,12+(row)*barHeight);
  image(inv, 100,(row++)*barHeight);
  
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
  Removes isolated black pixels (black pixels with no black neighbors)
*/
PImage removeIsolates(PImage im){
  PImage copy = im.get();
  copy.loadPixels();
  for(int x = 0; x < copy.width; x++){
    for(int y = 0; y < copy.height; y++){
      if(im.get(x,y) != color(0)) continue;
      int numNeighbors = 0;
      for(int dx = -1; dx <= 1; dx++){
        for(int dy = -1; dy <= 1; dy++){
          if(dx == 0 && dy == 0) continue;
          if(x + dx >= 0 && x + dx < copy.width && y + dy >= 0 && y + dy < copy.height){
            numNeighbors += im.get(x+dx,y+dy) == color(0) ? 1 : 0;
          }
        }
      }
      if(numNeighbors < 2) copy.set(x,y,color(255));
    }
  }
  copy.updatePixels();
  return copy;
}

/**
  Reduces the color values of an image to n possibles for R,G,B (from 256)
*/
PImage simplify(PImage im){
  int n = 4;
  int p = 256 / n;
  PImage copy = im.get();
  copy.loadPixels();
  for(int i = 0; i < copy.pixels.length; i++){
    int r = ((((((int)red(copy.pixels[i]))*256)/p)/256)*p);
    int g = ((((((int)green(copy.pixels[i]))*256)/p)/256)*p);
    int b = ((((((int)blue(copy.pixels[i]))*256)/p)/256)*p);
    copy.pixels[i] = color(r,g,b);
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
