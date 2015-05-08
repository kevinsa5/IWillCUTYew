class Bot
{
  Robot robot;
  OCR ocr;
  
  Bot(){
    try {
      robot = new Robot();
    } catch (AWTException e) {
        e.printStackTrace();
    }
    ocr = new OCR();
    //ArrayList<PImage> foo = new ArrayList<PImage>();
    println(ocr.match(loadImage("I.png")));
  }
  void act(){
    BufferedImage screencapture = robot.createScreenCapture(
    new Rectangle(33, 30, barWidth, barHeight));
    PImage im = new PImage(screencapture);
    PImage edge = edgeDetect(im);
    PImage amp  = amplify(edge);
    PImage inv = invert(amp);
    PImage iso = removeIsolates(inv);
    PImage bar = removeBars(iso);
    
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
    
    ArrayList<PImage> characters = separateCharacters(bar);
    int tx = 0;
    for(PImage p : characters){
      image(p, tx, row*barHeight);
      tx += p.width+5; 
    }
    row++;
    
    String str = recognizeCharacters(characters);
    text(str,0,(row+1)*barHeight);
  }
  
  private String recognizeCharacters(ArrayList<PImage> characters){
    StringBuilder builder = new StringBuilder("");
    for(int i = 0; i < characters.size(); i++){
       PImage raw = characters.get(i);
       PImage p = createImage(8,17,RGB);
       p.filter(THRESHOLD,0.0);
       p.set(0,0,raw);
       if(p.width == 8 && p.height == 17){
         char c = ocr.match(p);
         builder.append(c);
       }
     }
     return builder.toString();
  }
  
  private ArrayList<PImage> separateCharacters(PImage im){
    int characterStart = -1;
    int ncleans = 0;
    ArrayList<PImage> characters = new ArrayList<PImage>();
    for(int x = 0; x < im.width; x++){
      boolean clean = true;
      for(int y = 0; y < im.height; y++){
        if(im.get(x,y) == color(0)){
          clean = false;
          break;
        }
      }
      if(!clean && characterStart == -1){
        characterStart = x;
        if(ncleans > 3){
          PImage temp = im.get(x-ncleans,0,ncleans,im.height);
          characters.add(temp);
        }
        ncleans = 0;
      }
      if(clean && characterStart != -1){
        PImage temp = im.get(characterStart,0,(x-characterStart),im.height);
        if(temp.width > 1)
          characters.add(temp);
        characterStart = -1;
      }
      if(clean && characterStart == -1){
        ncleans++;
      }
    }
    return characters;
  }
  
  private PImage getRect(int x, int y, int wide, int high){
    BufferedImage screencapture = robot.createScreenCapture(
    new Rectangle(33, 30, barWidth, barHeight));
    return new PImage(screencapture);
  }
  
  
}
