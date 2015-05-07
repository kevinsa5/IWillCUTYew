char match(PImage im){
  if(im.width != 8 || im.height != 10){
    throw new RuntimeException("Image is wrong dimensions:"+im.width+" "+im.height);
  }
  im.loadPixels();
  int[] pix = new int[im.pixels.length];
  for(int i = 0; i < pix.length; i++)
    pix[i] = im.pixels[i] == color(0) ? 1 : 0;
  float c = multiplyAndSum(C_arr, pix) / total(C_arr);
  float u = multiplyAndSum(U_arr, pix) / total(U_arr);
  float w = multiplyAndSum(W_arr, pix) / total(W_arr);
  println("C: "+c +" W: "+w+" U:"+u);
  float m = max(max(c,w),u);
  if(c == m) return 'C';
  if(u == m) return 'U';
  if(w == m) return 'W';
  return '?';
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
