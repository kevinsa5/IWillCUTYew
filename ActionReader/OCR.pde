class OCR
{
  ArrayList<float[]> characterArrays = new ArrayList<float[]>();
  ArrayList<Character> characterValues = new ArrayList<Character>();

  OCR(){
    generateCharacterArrays();
  }
  
  char match(PImage im){
    if(im.width != 8 || im.height != 17){
      throw new RuntimeException("Image is wrong dimensions:"+im.width+" "+im.height);
    }
    im.loadPixels();
    float[] pix = new float[im.pixels.length];
    for(int i = 0; i < pix.length; i++)
      pix[i] = im.pixels[i] == color(0) ? 1 : 0;
    if(total(pix) == 0) return ' ';
    float[] ranks = new float[characterArrays.size()];
    for(int i = 0; i < ranks.length; i++){
      ranks[i] = multiplyAndSum(characterArrays.get(i), pix)/ sqrt(total(characterArrays.get(i)));
    }
    return characterValues.get(arrayMaxIndex(ranks));
  }
  
  private void generateCharacterArrays(){
    PImage template = createImage(8,17,RGB);
    for(char c = 'a'; c <= 'z'; c++){
      float[] arr = makeArray(c + ".png");
      if(arr == null) continue;
      characterArrays.add(arr);
      characterValues.add(c);
    }
    for(char c = 'A'; c <= 'Z'; c++){
      float[] arr = makeArray(c + ".png");
      if(arr == null) continue;
      characterArrays.add(arr);
      characterValues.add(c);
    }
    for(char c = '0'; c <= '9'; c++){
      float[] arr = makeArray(c + ".png");
      if(arr == null) continue;
      characterArrays.add(arr);
      characterValues.add(c);
    }
    characterArrays.add(makeArray("hyphen.png"));
    characterValues.add('-');
    characterArrays.add(makeArray("slash.png"));
    characterValues.add('/');
  }

  private float[] makeArray(String s){
    PImage p = loadImage(s);
    if(p == null) return null;
    PImage template = createImage(8,17,RGB);
    template.filter(THRESHOLD, 0.0);
    template.set(0,0,p);
    float[] arr = new float[template.width*template.height];
    template.loadPixels();
    for(int i = 0; i < template.pixels.length; i++){
      arr[i] = template.pixels[i] == color(0) ? 1.0 : 0.0;
    }
    return arr;
  }
  private int arrayMaxIndex(float[] a){
    float val = a[0];
    int imax = 0;
    for(int i = 0; i < a.length; i++){
      if(a[i] > val){
        val = a[i];
        imax = i;
      }
    }
    return imax;
  }
  
  private float multiplyAndSum(float[] a, float[] b){
    float s = 0;
    for(int i = 0; i < a.length; i++)
      s += a[i] * b[i];
    return s;
  }
  
  private float total(float[] a){
    float s = 0;
    for(int i = 0; i < a.length; i++) s += a[i];
    return s;
  } 
}
