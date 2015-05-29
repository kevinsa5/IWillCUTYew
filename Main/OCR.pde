class OCR
{
  ArrayList<float[]> characterArrays = new ArrayList<float[]>();
  ArrayList<Character> characterValues = new ArrayList<Character>();

  OCR() {
    generateCharacterArrays();
  }

  String matchString(PImage im) {
    PImage edge = edgeDetect(im);
    PImage amp = amplify(edge);
    PImage inv = invert(amp);
    PImage iso = removeIsolates(inv);
    PImage bar = removeBars(iso);
    ArrayList<PImage> characters = separateCharacters(bar);
    StringBuilder str = new StringBuilder("");
    for (int i = 0; i < characters.size (); i++) {
      PImage raw = characters.get(i);
      PImage p = createImage(8, 17, RGB);
      p.filter(THRESHOLD, 0.0);
      p.set(0, 0, raw);
      if (p.width == 8 && p.height == 17) {
        str.append(matchCharacter(p));
      }
    }
    return str.toString();
  }


  ArrayList<PImage> separateCharacters(PImage im) {
    int characterStart = -1;
    int ncleans = 0;
    ArrayList<PImage> characters = new ArrayList<PImage>();
    for (int x = 0; x < im.width; x++) {
      boolean clean = true;
      for (int y = 0; y < im.height; y++) {
        if (im.get(x, y) == color(0)) {
          clean = false;
          break;
        }
      }
      if (!clean && characterStart == -1) {
        characterStart = x;
        if (ncleans > 3) {
          PImage temp = im.get(x-ncleans, 0, ncleans, im.height);
          characters.add(temp);
        }
        ncleans = 0;
      }
      if (clean && characterStart != -1) {
        PImage temp = im.get(characterStart, 0, (x-characterStart), im.height);
        if (temp.width > 1)
          characters.add(temp);
        characterStart = -1;
      }
      if (clean && characterStart == -1) {
        ncleans++;
      }
    }
    return characters;
  }

  char matchCharacter(PImage im) {
    if (im.width != 8 || im.height != 17) {
      throw new RuntimeException("Image is wrong dimensions: "+im.width+" "+im.height);
    }
    im.loadPixels();
    float[] pix = new float[im.pixels.length];
    for (int i = 0; i < pix.length; i++)
      pix[i] = im.pixels[i] == color(0) ? 1 : 0;
    if (total(pix) == 0) return ' ';
    float[] ranks = new float[characterArrays.size()];
    for (int i = 0; i < ranks.length; i++) {
      ranks[i] = multiplyAndSum(characterArrays.get(i), pix) / sqrt(total(characterArrays.get(i)));
    }
    return characterValues.get(arrayMaxIndex(ranks));
  }

  void generateCharacterArrays() {
    PImage template = createImage(8, 17, RGB);
    for (char c = 'a'; c <= 'z'; c++) {
      float[] arr = makeArray(c + ".png");
      if (arr == null) continue;
      characterArrays.add(arr);
      characterValues.add(c);
    }
    for (char c = 'A'; c <= 'Z'; c++) {
      float[] arr = makeArray(c + ".png");
      if (arr == null) continue;
      characterArrays.add(arr);
      characterValues.add(c);
    }
    for (char c = '0'; c <= '9'; c++) {
      float[] arr = makeArray(c + ".png");
      if (arr == null) continue;
      characterArrays.add(arr);
      characterValues.add(c);
    }
    characterArrays.add(makeArray("hyphen.png"));
    characterValues.add('-');
    characterArrays.add(makeArray("slash.png"));
    characterValues.add('/');
  }

  float[] makeArray(String s) {
    File f = new File(dataPath(s));
    if(!f.exists()) return null;
    PImage p = loadImage(s);
    if (p == null) return null;
    PImage template = createImage(8, 17, RGB);
    template.filter(THRESHOLD, 0.0);
    template.set(0, 0, p);
    float[] arr = new float[template.width*template.height];
    template.loadPixels();
    for (int i = 0; i < template.pixels.length; i++) {
      arr[i] = template.pixels[i] == color(0) ? 1.0 : 0.0;
    }
    return arr;
  }

  int arrayMaxIndex(float[] a) {
    float val = a[0];
    int imax = 0;
    for (int i = 0; i < a.length; i++) {
      if (a[i] > val) {
        val = a[i];
        imax = i;
      }
    }
    return imax;
  }
  float multiplyAndSum(float[] a, float[] b) {
    float s = 0;
    for (int i = 0; i < a.length; i++)
      s += a[i] * b[i];
    return s;
  }
  float total(float[] a) {
    float s = 0;
    for (int i = 0; i < a.length; i++) s += a[i];
    return s;
  }
  
  /**
   Removes top and bottom rows of pixels
   */
  PImage removeBars(PImage im) {
    PGraphics copy = createGraphics(im.width, im.height);
    copy.beginDraw();
    copy.background(im);
    copy.stroke(color(255));
    copy.line(0, 0, copy.width, 0);
    copy.line(0, copy.height-1, copy.width, copy.height-1);
    copy.endDraw();
    return copy;
  }
  /**
   Removes isolated black pixels (black pixels with no black neighbors)
   */
  PImage removeIsolates(PImage im) {
    PImage copy = im.get();
    copy.loadPixels();
    for (int x = 0; x < copy.width; x++) {
      for (int y = 0; y < copy.height; y++) {
        if (im.get(x, y) != color(0)) continue;
        int numNeighbors = 0;
        for (int dx = -1; dx <= 1; dx++) {
          for (int dy = -1; dy <= 1; dy++) {
            if (dx == 0 && dy == 0) continue;
            if (x + dx >= 0 && x + dx < copy.width && y + dy >= 0 && y + dy < copy.height) {
              numNeighbors += im.get(x+dx, y+dy) == color(0) ? 1 : 0;
            }
          }
        }
        if (numNeighbors < 2) copy.set(x, y, color(255));
      }
    }
    copy.updatePixels();
    return copy;
  }
  /**
   Reduces the color values of an image to n possibles for R,G,B (from 256)
   */
  PImage simplify(PImage im) {
    int n = 4;
    int p = 256 / n;
    PImage copy = im.get();
    copy.loadPixels();
    for (int i = 0; i < copy.pixels.length; i++) {
      int r = ((((((int)red(copy.pixels[i]))*256)/p)/256)*p);
      int g = ((((((int)green(copy.pixels[i]))*256)/p)/256)*p);
      int b = ((((((int)blue(copy.pixels[i]))*256)/p)/256)*p);
      copy.pixels[i] = color(r, g, b);
    }
    copy.updatePixels();
    return copy;
  }
  /**
   Change white to black, black to white. Assumes input is ONLY white and black.
   */
  PImage invert(PImage im) {
    PImage copy = im.get();
    copy.loadPixels();
    for (int i = 0; i < copy.pixels.length; i++) {
      copy.pixels[i] = gray(copy.pixels[i]) == 255 ? color(0) : color(255);
    }
    copy.updatePixels();
    return copy;
  }
  /**
   Changes all grayscale pixels above threshold to white, all below to black.
   */
  PImage amplify(PImage im) {
    int threshold = 20;
    PImage copy = im.get();
    copy.loadPixels();
    for (int i = 0; i < copy.pixels.length; i++) {
      if (gray(copy.pixels[i]) > threshold)
        copy.pixels[i] = color(255);
      else
        copy.pixels[i] = color(0);
    }
    copy.updatePixels();
    return copy;
  }
  PImage edgeDetect(PImage im) {
    float outer = -0.12;
    float inner = 0.9;
    float[][] pointSpread = {
      {
        outer, outer, outer
      }
      , 
      {
        outer, inner, outer
      }
      , 
      {
        outer, outer, outer
      }
    };
    return pointSpread3(im, pointSpread);
  }
  /**
   Run a given 3x3 point spread function on an image
   */
  PImage pointSpread3(PImage im, float[][] pointSpread) {
    PImage copy = im.get();
    copy.filter(GRAY);
    copy.loadPixels();
    int[] transformed = new int[copy.pixels.length];
    for (int x = 0; x < copy.width; x++) {
      for (int y = 0; y < copy.height; y++) {
        float sum = 0;
        for (int dx = -1; dx <= 1; dx++) {
          for (int dy = -1; dy <= 1; dy++) {
            if (x + dx >= 0 && x + dx < copy.width && y + dy >= 0 && y + dy < copy.height) {
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
  final int gray(color p) {
    return max((p >> 16) & 0xff, (p >> 8 ) & 0xff, p & 0xff);
  }
}

