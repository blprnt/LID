import processing.pdf.*;

float mag = 1;
float hmag = 1;

float base = 10;

int[] window = {0, 1770000};

boolean advancing = false;
boolean framing = false;
int adSpeed = 100;

float[] maxMin = {1000000, -1000000};

//String baseURL = "https://calgary.ocr.nyc/listener-files/";
//String baseURL = "/Users/jerthorp/Downloads/output/";
String baseURL = "data/";//"https://calgary-data.ocr.nyc/";
String remoteURL = "https://calgary-data.ocr.nyc/";

ArrayList<PVector> allPoints = new ArrayList();

int hourCount = 0;
int hourMax = 0;
int currentHour = 0;
int currentDay = 0;
int currentYear = 0;
int currentMonth = 0;
boolean drawing = false;

String dString;

PVector total = new PVector();
PFont labelFont;

ArrayList<PVector> renderData;

color red = #7D312E;
color beige = color(218, 196, 190);

boolean outting = false;

int step = 1858;

void setup() {
  size(625, 825, P3D);
  
  hint(ENABLE_NATIVE_FONTS);
  background(255);
  smooth(4);

  labelFont = createFont("Palatino", 24);
  textFont(labelFont);

  renderData = loadHour(2018, 6, 2, 13, false);
}

void draw() {

  if (outting) {
    textMode(SHAPE);
    beginRaw(PDF, "glacier.pdf");
  } else {
    textMode(MODEL);
    background(0);
  }
  
  if (advancing) step++;

  String out = join(loadStrings("bow.txt"), " ");
  textFont(labelFont);
  textSize(16);
  fill(0);

  translate(50, 100);
  //ellipse(0,0,100,100);
  String[] chars = out.split("");
  String full = "";
  float xstack = 0;
  float ystack = 0;
  int per = 18;
  float lastWidth = 0;

  ArrayList<PVector> points = new ArrayList();

  for (int i = 0; i < chars.length; i++) {
    PVector off = new PVector();
    String c = chars[i];
    for (int j = 0; j < per; j++) {
      int ind = (i * per) + j + 20000 - (step * 5);
      off = off.add(renderData.get(ind));
    }

    off = off.mult(0.0003);

    float mag = off.mag();
    color col = lerpColor(color(255), #000000, map(abs(mag), 0, 5, 1, 0));
    fill(col);


    //fill(hue(red), saturation(red) + (abs(mag) * 5), brightness(red) + (abs(mag) * 10));

    pushMatrix();
    translate(xstack, ystack, 0);
    translate(off.x, off.y, off.z * 5);
    //textSize(map(abs(mag), 0, 50, 10, 24));
    if (!c.equals("~") && !c.equals("`")) text(c, 0, 0);
    popMatrix();

    points.add(new PVector(off.x + xstack, off.y + ystack, off.z * 3));
    full = full + c;

    float w = textWidth(full);
    xstack += (w - lastWidth);
    lastWidth = w;
    if (xstack > width - 100 || c.equals("~") || c.equals("`")) {
      xstack = 0;
      ystack += (c.equals("~")) ? 40:20;
      //drawLine
      noFill();
      stroke(255, 100);
      beginShape();
      for (PVector v : points) {
        vertex(v.x, v.y, v.z);
      }
      endShape();
      points = new ArrayList();
    }
  }

  if (outting) {
    endRaw();
    outting = false;
  }
  
  if (framing) {
    saveFrame("frames/HR-######.png");
  }
}

void drawLine(ArrayList<PVector> points) {

  colorMode(HSB);
  float y = map(hourCount, 0, hourMax, 50, height - 50);
  pushMatrix();
  translate(0, y);
  fill(0);
  text(nf(currentHour, 2) + ":00", 50, -20);
  for (int i = 0; i < points.size(); i++) {
    float x = map(i, 0, 1800000, 0, width);
    float v = points.get(i).x;
    stroke(map(pow(abs(v), 1), 0, pow(40, 1), 0, 360), 255, 255, 50);
    line(x, 0, x, v);
  }
  popMatrix();
}

void startSonifiers() {

}

void populateSonifiers() {
  float[] x = new float[allPoints.size()]; 
  float[] y = new float[allPoints.size()]; 
  float[] z = new float[allPoints.size()]; 

  for (int i = 0; i < allPoints.size(); i++) {
    PVector v = allPoints.get(i);
    x[i] = trans(v.x);
    y[i] = trans(v.y);
    z[i] = trans(v.z);
  }

 
}

void skip(int i) {
  window[0] += i;
  window[1] += i;

}

float trans(float n) {
  float p = 1;
  float flip = n / abs(n);
  return(pow(n, p) * ((p > 1) ? flip:1));
}

void drawHours(int y, int m, int d, int h, int t) {
  hourCount = 0;
  hourMax = t;
  currentYear = y;
  currentMonth = m;
  currentHour = h;
  currentDay = d;
  drawing = true;
}

ArrayList<PVector> loadHour(int y, int m, int d, int h, boolean isRemote) {
  String fn = "glacier_raw-" + y + nf(m, 2) + nf(d, 2) + "T" +  nf(h, 2) + "00Z.csv";
  dString = fn;
  String url = (!isRemote) ? baseURL + fn : remoteURL + y + "/" + nf(m, 2) + "/" + nf(d, 2) + "/" + fn; 
  return(loadData(url));
}

ArrayList<PVector> loadData(String url) {
  ArrayList<PVector> a = new ArrayList();

  try {
    println("LOADING");
    String[] rows = loadStrings(url);
    saveStrings(dString, rows);
    println("PROCESSING");
    int i = 0;

    for (String row : rows) {
      String[] r = split(row, ",");

      PVector vec = new PVector(float(r[2]), float(r[3]), float(r[4]));
      //total.add(vec);

      maxMin[0] = min(vec.x, maxMin[0]);
      maxMin[1] = max(vec.x, maxMin[1]);

      a.add(vec);
    }
    println("FINISHED");
    println(maxMin);
    println(total);
  } 
  catch (Exception e) {
    println("FAILED TO LOAD:" + url);
  }
  return(a);
}

void keyPressed() {
  if (key == ' ') {
    advancing = !advancing;
    println("STEP:" + step);
  }
  if (key == 's') save("out/glacier" + hour() + "_" + minute() + "_" + second() + ".png");
  if (key == 'o') outting = true;
  if (key == 'f') framing = !framing;
}