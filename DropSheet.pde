class DropSheet {
  //Lists of attributes of each dot in a drop sheet
  ArrayList<PVector> points = new ArrayList();
  ArrayList<Integer> colors = new ArrayList();
  ArrayList<Float> radius = new ArrayList();
  ArrayList<PVector> velocity = new ArrayList();

  long sheetStartTime;
  final float maxY = .1, minY = -.1, maxX = .1, minX = -.1;

  DropSheet(long start) {
    sheetStartTime = start;
  }

  void tick() {
    if (millis()-sheetStartTime <= lifetime ) {

    for (int i = 0; i < points.size(); i ++) {

      velocity.get(i).x += random(timeValue(minX, 0, millis()-frameStartTime, frameTime), timeValue(maxX, 0, millis()-frameStartTime, frameTime));
      velocity.get(i).y += random(timeValue(minY, 0, millis()-frameStartTime, frameTime), timeValue(maxY, 0, millis()-frameStartTime, frameTime));
      points.get(i).x += velocity.get(i).x;
      points.get(i).y += velocity.get(i).y;


      fill(red(colors.get(i)), green(colors.get(i)), blue(colors.get(i)), 
        timeValue(startAlpha, endAlpha, millis()-sheetStartTime, lifetime)
        + (random(-1, 1) * timeValue(startAlphaDelta, endAlphaDelta, millis()-sheetStartTime, lifetime)));


      float r =  timeValue(0, radius.get(i), millis()-sheetStartTime, lifetime);
      ellipse(points.get(i).x, points.get(i).y, r, r);
    }
  }
  }
}
