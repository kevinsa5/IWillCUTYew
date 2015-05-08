import java.awt.Robot;
import java.awt.AWTException;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;

class Bot
{
  Robot robot;
  OCR ocr;
  final int ACTION_BAR_HEIGHT = 17;
  final int ACTION_BAR_WIDTH = 300;
  final int COMPASS_WIDTH = 42;
  
  float currentHeading = 0;
  String currentAction = "";
  
  Bot() {
    try {
      robot = new Robot();
    }
    catch (AWTException e) {
      e.printStackTrace();
    }
    ocr = new OCR();
  }

  void updateGui() {
    fill(0);
    lblAction.setText(getCurrentAction());
    updateHeading();
  }

  void updateHeading() {
    PVector origin = getWindowOrigin();
    BufferedImage screencapture = robot.createScreenCapture(
      new Rectangle((int)origin.x+537, (int)origin.y -4 , COMPASS_WIDTH, COMPASS_WIDTH));

    PImage im = new PImage(screencapture);
    stroke(0);
    fill(0);
    int row = 0;

    float x0 = 100 + im.width/2;
    float y0 = (row-1)*COMPASS_WIDTH + im.height/2;
    ArrayList<PVector> points = new ArrayList<PVector>();
    for (float rad = 10; rad < 17; rad += 0.2) {
      for (float theta = 0; theta < TWO_PI; theta += TWO_PI/100) {
        int x = (int)(im.width/2+rad*cos(theta));
        int y = (int)(im.height/2+rad*sin(theta));
        color c = im.get(x, y);
        if (red(c) > 100 && green(c) < 100 && blue(c) < 100) {
          points.add(new PVector(x, y));
        }
      }
    }
    ArrayList<PVector> filtered = new ArrayList<PVector>();
    for (PVector p : points) {
      boolean different = true;
      for (PVector o : filtered) {
        if (p.dist(o) < 5) {
          different = false;
          break;
        }
      }
      if (different) filtered.add(p);
    }
    PGraphics graph = createGraphics(COMPASS_WIDTH,COMPASS_WIDTH);
    graph.beginDraw();
    graph.image(im,0,0);
    graph.stroke(color(0, 255, 0));
    graph.noFill();
    for (PVector p : filtered) {
      graph.ellipse(p.x, p.y, 5, 5);
    }
    
    PVector center = new PVector(im.width/2, im.height/2);
    float a = PVector.sub(filtered.get(0), center).heading();
    float b = PVector.sub(filtered.get(1), center).heading();
    float c = PVector.sub(filtered.get(2), center).heading();
    if (a < 0) a += TWO_PI;
    if (b < 0) b += TWO_PI;
    if (c < 0) c += TWO_PI;
    float[] angles = {
      a, b, c
    };
    angles = sort(angles);
    float theta;
    if (abs((angles[1] - angles[0]) - PI) < PI / 10)
      theta = (angles[1] + angles[0]) / 2;
    else if (abs((angles[2] - angles[1]) - PI) < PI / 10)
      theta = (angles[2] + angles[1]) / 2;
    else
      theta = (angles[2] + angles[0]) / 2 - PI;

    if (theta > TWO_PI) theta -= TWO_PI;

    x0 = COMPASS_WIDTH/2;
    y0 = COMPASS_WIDTH/2;
    graph.line(x0, y0, x0+20*cos(theta), y0+20*sin(theta));
    graph.ellipse(x0+20*cos(theta), y0+20*sin(theta), 5, 5);
    graph.endDraw();
    compass.setGraphic(graph);
    float degrees = 180*theta/PI;
    lblHeading.setText(str(degrees).substring(0,5));
    currentHeading = theta;
  }

  String updateAction() {
    PVector o = getWindowOrigin();
    BufferedImage screencapture = robot.createScreenCapture(new Rectangle((int)o.x-1, (int)o.y+3, ACTION_BAR_WIDTH, ACTION_BAR_HEIGHT));
    currentAction = ocr.matchString(new PImage(screencapture));
    return currentAction;
  }

  PVector getWindowOrigin() {
    return new PVector(34, 27);
  }
  
  String getCurrentAction(){
    return currentAction;
  }
  float getCurrentHeading(){
    return currentHeading;
  }
}

