char match(PImage im){
  if(im.width != 8 || im.height != 10){
    throw new RuntimeException("Image is wrong dimensions:"+im.width+" "+im.height);
  }
  im.loadPixels();
  int[] pix = new int[im.pixels.length];
  for(int i = 0; i < pix.length; i++)
    pix[i] = im.pixels[i] == color(0) ? 1 : 0;
  float[] ranks = new float[characterArrays.size()];
  for(int i = 0; i < ranks.length; i++){
    ranks[i] = multiplyAndSum(characterArrays.get(i), pix) / total(characterArrays.get(i));
  }
  return characterValues.get(arrayMaxIndex(ranks));
}

int arrayMaxIndex(float[] a){
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

float multiplyAndSum(float[] a, int[] b){
  float s = 0;
  for(int i = 0; i < a.length; i++)
    s += a[i] * b[i];
  return s;
}

float total(float[] a){
  float s = 0;
  for(int i = 0; i < a.length; i++) s += a[i];
  return s;
}
