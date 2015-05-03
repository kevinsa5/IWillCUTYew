// pretty good detection of which direction is north on the map
// requires the window to be in the upper left corner
// makes assumptions about window title bar height, etc.

import java.awt.Color;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;
import java.awt.event.KeyEvent;
import java.io.IOException;

Robot robot;
int barHeight = 42;
boolean shouldTurn = false;

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

  background(200);
  stroke(0);
  fill(0);
  int row = 0;
  text("Original Image:",0,12+(row)*barHeight);
  image(im,100,(row++)*barHeight);
  text("All Points:",0,12+(row)*barHeight);
  image(im,100,(row++)*barHeight);
  
  float x0 = 100 + im.width/2;
  float y0 = (row-1)*barHeight + im.height/2;
  noFill();
  ArrayList<PVector> points = new ArrayList<PVector>();
  for(float rad = 10; rad < 17; rad += 0.2){
    for(float theta = 0; theta < TWO_PI; theta += TWO_PI/100){
      int x = (int)(im.width/2+rad*cos(theta));
      int y = (int)(im.height/2+rad*sin(theta));
      color c = im.get(x,y);
      if(red(c) > 100 && green(c) < 100 && blue(c) < 100){
        stroke(color(0,255,0));
        ellipse(x0+rad*cos(theta), y0+rad*sin(theta),5,5);
        points.add(new PVector(x,y));
      }
    }
  }
  ArrayList<PVector> filtered = new ArrayList<PVector>();
  for(PVector p: points){
    boolean different = true;
    for(PVector o: filtered){
      if(p.dist(o) < 5){
        different = false;
        break;
      } 
    }
    if(different) filtered.add(p);
  }
  text("Filtered:" + filtered.size(),0,12+(row)*barHeight);
  image(im,100,(row++)*barHeight);
  stroke(color(0,255,0));
  for(PVector p: filtered){
    ellipse(100+p.x, (row-1)*barHeight + p.y,5,5);
  }
  
  text("Lines:" ,0,12+(row)*barHeight);
  image(im,100,(row++)*barHeight);

  PVector center = new PVector(im.width/2,im.height/2);
  float a = PVector.sub(filtered.get(0),center).heading();
  float b = PVector.sub(filtered.get(1),center).heading();
  float c = PVector.sub(filtered.get(2),center).heading();
  if(a < 0) a += TWO_PI;
  if(b < 0) b += TWO_PI;
  if(c < 0) c += TWO_PI;
  float[] angles = {a,b,c};
  angles = sort(angles);
  float theta;
  if(abs((angles[1] - angles[0]) - PI) < PI / 10)
    theta = (angles[1] + angles[0]) / 2;
  else if(abs((angles[2] - angles[1]) - PI) < PI / 10)
    theta = (angles[2] + angles[1]) / 2;
  else
    theta = (angles[2] + angles[0]) / 2 - PI;
 
  if(theta > TWO_PI) theta -= TWO_PI;
 
  x0 = 100 + im.width/2;
  y0 = (row-1)*barHeight + im.height/2;
  line(x0,y0,x0+20*cos(theta),y0+20*sin(theta));
  ellipse(x0+20*cos(theta),y0+20*sin(theta),5,5);
  
  stroke(0);
  fill(shouldTurn ? color(0,255,0) : color(255,0,0));
  rect(20,height-25,100,20);
  fill(0);
  text("turning:" + (shouldTurn ? "yes" : "no"),30,height-10);
  
  if(shouldTurn){
    if(abs(theta + PI/2) > TWO_PI/120){
      robot.keyPress(KeyEvent.VK_RIGHT);
      println("turning..." + theta);
    } else {
      robot.keyRelease(KeyEvent.VK_RIGHT);
      shouldTurn = false;
    }
  }
  
}

void mouseClicked(){
  if(mouseX > 20 && mouseX < 120 && mouseY > height-25 && mouseY < height-5)
    shouldTurn = !shouldTurn;
}
