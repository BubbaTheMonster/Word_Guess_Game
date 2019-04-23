ArrayList<String> words = new ArrayList();  //array of words 

String currentWord = "";
String guess = ""; //player's guess
ArrayList<Integer> wordArr  = new ArrayList(); //int array representation of the currentWord

final float startDropRadius = 50; //radius of drops at the begining of a word
final float endDropRadius = 1;  //radius of drops at the end of a word;

final float startDeltaRadius = 25; //possible difference in Drop radius at beginging of a word
final float endDeltaRadius = 0; //possible different at the end

final float startAlpha = 30; //alpha value of drops at start
final float endAlpha = 255; //value at end

final float startAlphaDelta = 20; //possible difference in alpha value at start
final float endAlphaDelta = 0; //possible difference at end

final int startDropsPerSecond = 300; //drops made every second at start
final int endDropsPerSecond = 1800;//drops made every second at end
final int afterDropsPerSecond = 5000;

ArrayList<DropSheet> sheets = new ArrayList(); //array of "Drop Sheets" objects that hold all the drops created in one step;
final int cap = 30; //max number of drop sheets at once
final float lifetime = 1.5 * 1000; //how long a sheet grows for

long frameStartTime;
long lastMillis = 0; // time the last step startedat
final long frameTime = 20 * 1000; //total time until a frame expires
int bgColor = 0;
int textColor;
boolean frameStart = true;

PVector textLoc, timeLoc, scoreLoc, wpmLoc;
long time = 0;
int wordsDone = 0;

void setup() {
  frameRate(30);
  fullScreen();
  background(0);
  noStroke();
  textSize(70);
  rectMode(CENTER);

  textLoc = new PVector(width/2, 7 * height/8);
  scoreLoc = new PVector(width/16, height/8);
  timeLoc = new PVector(15*width/16, height/8);
  wpmLoc = new PVector(width/2, height/8);

  BufferedReader reader = createReader("words.txt");
  String line = null;
  try {
    while ((line = reader.readLine()) != null) {
        words.add(line);
    }
    reader.close();
  } 
  catch (IOException e) {
    e.printStackTrace();
  }

  lastMillis = millis();
}

void draw() {

  textAlign(CENTER, BOTTOM);

  //get elasped time (s) 
  float delta = (millis()-lastMillis);
  lastMillis = millis();

  time += delta;

  //println(frameRate);

  if (frameStart) {
    bgColor = color(random(0, 100), random(0, 100), random(0, 100));
    textColor = color(random(155, 255), random(155, 255), random(155, 255));
    
    //if all words have been used, replenish
    if (words.size() == 0) {
      BufferedReader reader = createReader("words.txt");
      String line = null;
      try {
        while ((line = reader.readLine()) != null) {
          words.add(line);
        }
        reader.close();
      } 
      catch (IOException e) {
        e.printStackTrace();
      }
    }


    //get word

    currentWord = words.get((int)random(0, words.size()));
    println("Word:" + currentWord + "<-");
    //remove word to avoid duplicates
    words.remove(currentWord);

    //save word as PVector array

    //create image of text
    PGraphics p = createGraphics(width, height);
    p.beginDraw();
    p.background(0);
    p.textAlign(CENTER, BOTTOM);
    //get any possible font (excluding those with symbols)
    int fontNum = (int)random(0, 546);
    if (fontNum >= 110)
      fontNum++;


    p.textFont(createFont(PFont.list()[fontNum], 1));
    p.textSize((int)random(150, 400));
    while (p.textWidth(currentWord) > p.width) {
      p.textSize((int)random(150, 400));
    }
    p.noStroke();
    p.pushMatrix();//allow for transformations
    p.translate(width/2, 2*height/3);
    //p.rotate((int)random(0,2)*PI);
    p.text(currentWord, 0, 0);
    p.popMatrix();//resetTransfomrations
    p.endDraw();
    p.loadPixels();
    wordArr.clear();
    for (int i = 0; i < p.pixels.length; i++) {
      if (red(p.pixels[i]) > 20) {
        wordArr.add(i);
      }
    }

    background(bgColor);
    sheets.clear();

    frameStart = false;
    frameStartTime = millis();
  }

  //create a new dropsheet of drops and remove oldest if too many
  sheets.add(new DropSheet(millis()));
  if (sheets.size() >= cap) {
    sheets.remove(0);
  }

  if (millis()-frameStartTime < frameTime) {
    //add drops to drop sheet
    for (int i = 0; i < (timeValue(startDropsPerSecond, endDropsPerSecond, millis()-frameStartTime, frameTime) * delta)/1000; i++) {

      //random int that corresponds to a pixel
      int pixel = (int)random(0, width*height);

      //color of that pixel (text color if on the text, otherwise bgcolor)
      color col = contains(wordArr, pixel) ? textColor : bgColor;

      //radius based on change of delta radius and on time
      float r =
        (timeValue(startDropRadius, endDropRadius, millis()-frameStartTime, frameTime) + 
        (random(-1, 1) * timeValue(startDeltaRadius, endDeltaRadius, millis()-frameStartTime, frameTime)));

      //x and y of the pixel
      PVector point = new PVector(pixel%width, pixel/width);

      //add drop to lastest dropsheet
      sheets.get(sheets.size() - 1).points.add(point);
      sheets.get(sheets.size() - 1).colors.add(col);
      sheets.get(sheets.size() - 1).radius.add(r);
      sheets.get(sheets.size() - 1).velocity.add(new PVector(0, 0));
    }

    //let all of the drop sheets draw drops
    for (int i = 0; i < sheets.size(); i++) {
      sheets.get(i).tick();
    }
  } else {
    //if reveal time is up, make the text even clearer, quickly

    for (int i = 0; i < (afterDropsPerSecond * delta)/1000; i++) {

      //random int that corresponds to a pixel
      int pixel = (int)random(0, width*height);

      //color of that pixel (text color if on the text, otherwise bgcolor)
      color col = contains(wordArr, pixel) ? textColor : bgColor;

      //radius
      int r = 4;

      //x and y of the pixel
      PVector point = new PVector(pixel%width, pixel/width);

      //draw that pixel

      fill(col);
      ellipse(point.x, point.y, r, r);
    }
  }

  textAlign(CENTER);
  fill(bgColor);
  rect(wpmLoc.x, wpmLoc.y, width, 120);

  textAlign(LEFT);
  fill(textColor);
  text("" + wordsDone, scoreLoc.x, scoreLoc.y);


  textAlign(RIGHT);
  long dispTime = round(time/1000);
  fill(textColor);
  text(dispTime/60 + ":" + dispTime%60, timeLoc.x, timeLoc.y);

  textAlign(CENTER);
  if (!guess.equals("")) {
    fill(bgColor);
    rect(textLoc.x, textLoc.y, textWidth(guess), 140);
    fill(textColor);
    text(guess, textLoc.x, textLoc.y);
  }

  float wpm = wordsDone / (round(time/1000) / 60.0);
  wpm = (int)(wpm * 100)/100.0; // round to 3 sigfigs
  fill(textColor);
  text("WPM: " + wpm, wpmLoc.x, wpmLoc.y);
}

//methods

boolean contains(String[] arr, String a) {
  for (String b : arr) {
    if (b.equals(a))
      return true;
  }
  return false;
}

boolean contains(ArrayList<Integer> arr, int a) {
  for (int b : arr) {
    if (b == a)
      return true;
  }
  return false;
}

float cap(float a, float max) {
  return a > max ? max : a;
}

int wrap(int min, int max, int a) {
  return (a-min) % (max-min) + min;
}

//gets value between max and min based on time passed
float timeValue(float min, float max, float time, float total) {
  float fac = time/total; 
  fac = fac > 1 ? 1 : fac;
  return (max-min)*fac + min;
}

char randomLetterNum() {
  int rand = (int)random(48, 110);
  if (rand >= 58)
    rand += 8;
  if (rand >= 91)
    rand += 6;
  return (char)rand;
}

void keyPressed() {
  //special keys
  if (key != CODED) {
    if (key == '\b') {
      if (guess.length() > 0) {
        fill(bgColor);
        rect(textLoc.x, textLoc.y, textWidth(guess) + 10, 140);
        guess = guess.substring(0, guess.length()-1);
      }
    } else if (key == '\n') {
      if (guess.equals(currentWord)) {
        fill(50, 255, 50);
        text(guess, textLoc.x, textLoc.y);
        guess = "";
        frameStart = true;
        wordsDone++;
      } else {
        fill(255, 50, 50);
        text(guess, textLoc.x, textLoc.y);
        guess = "";
      }
    } else {
      //typed keys
      guess += key;
    }
  }
}
