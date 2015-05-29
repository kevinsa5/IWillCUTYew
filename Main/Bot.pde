import java.awt.Robot;
import java.awt.AWTException;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;
import java.awt.Point;
import java.awt.MouseInfo;
import java.awt.PointerInfo;
import java.awt.event.InputEvent;


class Bot
{
  Robot robot;
  OCR ocr;
  final int ACTION_BAR_HEIGHT = 17;
  final int ACTION_BAR_WIDTH = 300;
  final int COMPASS_WIDTH = 42;
  final int VIEW_WIDTH = 520;
  final int VIEW_HEIGHT = 340;
  final int COMPASS_X = 540;
  final int COMPASS_Y = 0; 
  final int INVENTORY_X = 550;
  final int INVENTORY_Y = 210;
  final String[] knownWords = {
    "",
    "Chop down Tree / 2 more options", 
    "Chop down Oak / 2 more options", 
    "Chop down Willow / 2 more options", 
    "Chop down Yew / 2 more options", 
    "Walk here", 
    "Walk here / 1 more option",
    "Wield Rune axe / 3 more options", 
    "Use Logs / 2 more options",
    "Use Oak logs / 2 more options",
    "Use Willow logs / 2 more options",
    "Use Yew logs / 2 more options",
    "Attack Goblin (level-2) / 2 more options",
    "Take Coins / 4 more options",
    "Chop down Dead tree / 6 more options",
    "Take Body rune / 4 more options"
  };

  float currentHeading = 0;
  String currentAction = "";
  String closestMatch = "";
  float scanRadius = 1;
  float scanAngle = 0;
  int clickDelay = 5000;
  int lastClick = -clickDelay;
  PVector origin;

  Bot() {
    try {
      robot = new Robot();
    }
    catch (AWTException e) {
      e.printStackTrace();
    }
    ocr = new OCR();
    origin = findWindowOrigin();
    //scanVelocity = new PVector(4,-4);
  }
  
  void updateGui() {
    fill(0);
    String s = updateAction();
    lblAction.setText(s);
    closestMatch = closestMatch(s);
    lblMatch.setText(closestMatch);
    updateHeading();
    updateGameScreen();
    if(frameCount % 30 == 0)
      lblFPS.setText(frameRate + " FPS");
  }
  
  void updateGameScreen(){
    PImage im = getImage(0,0,VIEW_WIDTH,VIEW_HEIGHT);
    im.resize(VIEW_WIDTH/2,VIEW_HEIGHT/2);
    PGraphics graph = createGraphics(VIEW_WIDTH/2, VIEW_HEIGHT/2);
    graph.beginDraw();
    graph.image(im,0,0);
    graph.endDraw();
    padGame.setGraphic(graph);
  }
  
  void dropItems(){
    Point p = MouseInfo.getPointerInfo().getLocation();
    PVector o = windowOrigin();
    if(closestMatch.equals("Use Oak logs / 2 more options")){
      robot.mousePress(InputEvent.BUTTON3_MASK);
      robot.delay(100);
      robot.mouseRelease(InputEvent.BUTTON3_MASK);
      robot.delay(100);
      robot.mouseMove((int)p.getX(), (int)p.getY()+40);
      robot.delay(100);
      robot.mousePress(InputEvent.BUTTON1_MASK);
      robot.delay(100);
      robot.mouseRelease(InputEvent.BUTTON1_MASK);
      robot.delay(200);
      robot.mouseMove((int)p.getX(), (int)p.getY());
      robot.delay(500);
      return ;
    } else {
      if(p.getX() < o.x + INVENTORY_X + 180){
        robot.mouseMove((int)p.getX() + 5,(int) p.getY()); 
      } else {
        robot.mouseMove((int) o.x + INVENTORY_X + 20, (int) p.getY() + 35);
      }
      if(p.getX() < o.x + INVENTORY_X || p.getY() > INVENTORY_Y + 320 || p.getY() < INVENTORY_Y){
        robot.mouseMove((int) o.x + INVENTORY_X + 20, (int) o.y + INVENTORY_Y + 20);
      }
    }
  }

  void mouseGrid() {
    if(closestMatch.equals("Chop down Oak / 2 more options")){
      if(millis() - lastClick > clickDelay){
        lastClick = millis();
        robot.mousePress(InputEvent.BUTTON1_MASK);
        robot.delay(100);
        robot.mouseRelease(InputEvent.BUTTON1_MASK);
      }
      return;
    }
    //if(millis() % 5000 < 1000) return;
    robot.delay(10);
    if(scanRadius > VIEW_HEIGHT/2) scanRadius = 10;
    scanRadius += 0.5;
    scanAngle += 10 / scanRadius;
    PVector o = windowOrigin();
    robot.mouseMove((int) (o.x + VIEW_WIDTH/2  + scanRadius*cos(scanAngle)), 
                    (int) (o.y + VIEW_HEIGHT/2 + scanRadius*sin(scanAngle)));
                    
  }

  void updateHeading() {
    PImage im = getImage(COMPASS_X, COMPASS_Y, COMPASS_WIDTH, COMPASS_WIDTH);
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

    PGraphics graph = createGraphics(COMPASS_WIDTH, COMPASS_WIDTH);
    graph.beginDraw();
    graph.image(im, 0, 0);
    graph.stroke(color(0, 255, 0));
    graph.noFill();
    for (PVector p : filtered) {
      graph.ellipse(p.x, p.y, 5, 5);
    }
    if (filtered.size() < 3) {
      graph.endDraw();
      compass.setGraphic(graph);
      println("Couldn't find the three reference points on the compass!");
      return;
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
    lblHeading.setText(str(degrees).substring(0, 5));
    currentHeading = theta;
  }

  String updateAction() {
    PImage p = getImage(9,7,ACTION_BAR_WIDTH,ACTION_BAR_HEIGHT); 
    currentAction = ocr.matchString(p);
    return currentAction;
  }

  PVector windowOrigin() {
    return origin;
  }
  
  PVector findWindowOrigin() {
    BufferedImage screencapture = robot.createScreenCapture(
    new Rectangle(0, 0, displayWidth, displayHeight));
    PImage im = new PImage(screencapture);
    int count = 0;
    for (int i = 0; i < im.width; i++) {
      for (int j = 0; j < im.height; j++) {
        if (im.get(i,j) == color(76,189,78)) {
          count++;
          if (count == 5) {
            return new PVector(i - 644, j - 473);
          }
        }
      }
    }
    return null;
  }

  String getCurrentAction() {
    return currentAction;
  }
  float getCurrentHeading() {
    return currentHeading;
  }
  
  String closestMatch(String s){
    String closestMatch = knownWords[0];
    int distance = levenshtein(s, closestMatch);
    for (int i = 1; i < knownWords.length; i++) {
      int d = levenshtein(s, knownWords[i]);
      if (d < distance) {
        distance = d;
        closestMatch = knownWords[i];
      }
    }
    return closestMatch;
  }

  int levenshtein(String a, String b) {
    //http://en.wikipedia.org/wiki/Levenshtein_distance
    //http://rosettacode.org/wiki/Levenshtein_distance#Java
    a = a.toLowerCase();
    b = b.toLowerCase();
    // i == 0
    int [] costs = new int [b.length() + 1];
    for (int j = 0; j < costs.length; j++)
      costs[j] = j;
    for (int i = 1; i <= a.length (); i++) {
      // j == 0; nw = lev(i - 1, j)
      costs[0] = i;
      int nw = i - 1;
      for (int j = 1; j <= b.length (); j++) {
        int cj = Math.min(1 + Math.min(costs[j], costs[j - 1]), a.charAt(i - 1) == b.charAt(j - 1) ? nw : nw + 1);
        nw = costs[j];
        costs[j] = cj;
      }
    }
    return costs[b.length()];
  }
  PImage getImage(int x, int y, int wide, int high){
    PVector o = windowOrigin();
    return getImageAbsolute((int)o.x + x, (int)o.y + y, wide, high);
  }
  PImage getImageAbsolute(int x, int y, int wide, int high){
    return new PImage(robot.createScreenCapture(new Rectangle(x,y,wide,high)));
  }
}

