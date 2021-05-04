import processing.pdf.*;

import java.util.Date;
import java.text.SimpleDateFormat;

import java.io.IOException;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;

SimpleDateFormat sdfFull = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss.SSS");
SimpleDateFormat sdfTime = new SimpleDateFormat("hh:mm:ss.SSS");

Dive testDive;
String alvinServer = "http://dlacruisedata.whoi.edu/NDSF/alvin/dive/";
String pathToUSBL = "/USBL/";
String pathToTopLab = "/Toplab_DVL/";
String pathToDepthFile = "/c+c/";
//String cruiseID = "archive/AT26-13/";
String cruiseID = "AT26-15/";
String localPath = "paths/";

PVector rot = new PVector();
PVector trot = new PVector();

PVector focus = new PVector();
PVector tfocus = new PVector();

float ppm = 0.8;

PVector alvin = new PVector();
PVector talvin = new PVector();

float zoom = 0;
float tzoom = 1;

float deep = 0;

String debug = "";
boolean playing = false;

Dive focusDive = null;

int curveStep = 10;


int focusIndex = -1;

ArrayList<Dive> allDives = new ArrayList();
ArrayList<Dive> activeDives = new ArrayList();

boolean getting = false;
int start = 4600;

color red = #7D312E;
color beige = color(218, 196, 190);

boolean outting = false;


void setup() {

  size(618, 825, P3D);
  smooth(4);

  if (!getting) {
    loadDivesLocal(4679, 5000);
    //activeDives = allDives;
    //activeDives.add(allDives.get(0));
    int minDepth = -40;
    for (int i = 0; i < allDives.size(); i++) {
      boolean surfaceCheck = (allDives.get(i).simplePath[0].z > minDepth && allDives.get(i).simplePath[allDives.get(i).simplePath.length - 1].z > minDepth);
      PVector expanse = allDives.get(i).maxBounds.copy().sub(allDives.get(i).minBounds);
      boolean boundsCheck = (sqrt(expanse.x * expanse.y) < 1200);
      if (surfaceCheck && boundsCheck) {
        activeDives.add(allDives.get(i));
      }
    }
  }
}

void draw() {

  background(beige);
  //blendMode(ADD);

  fill(255);
  if (focusDive != null) {
    textSize(24);
    text(activeDives.size(), 50, 20);
    text(focusDive.diveNo, 50, 50);
  }

  if (outting) {
    beginRaw(PDF, "Descent" + curveStep + ".pdf");
  }

  //Down segments
  pushMatrix();

  strokeWeight(2);

  translate(width/2, 0);
  fill(255, 50);
  noStroke();
  //ellipse(0,0,100,100);
  scale(0.15);
  rotateX(PI/2);
  //rotateZ(map(mouseX, 0, width, -PI, PI));
  rotateZ(0.01 *  frameCount);

  for (Dive d : activeDives) {

    if (focusDive == null || d == focusDive) {
      //d.renderSimple();
      PVector ball = d.longDown.get(1);

      pushMatrix();
      rotate(-d.downAngle);
      translate(-ball.x, -ball.y, -ball.z);

      fill(255);
      noStroke();

      pushMatrix();
      translate(ball.x, ball.y, ball.z);
      //box(50);
      popMatrix();  


      stroke(red, 150);
      d.renderSegment(d.longDown);
      popMatrix();
    }
  }
  popMatrix();

  if (outting) {
    endRaw();
  }
  
  if (outting) {
    beginRaw(PDF, "Ascent" + curveStep + ".pdf");
  }

  /*
  //Up segments
  pushMatrix();
  translate(width/2 + 300, 0);
  fill(255, 50);
  noStroke();
  //ellipse(0,0,100,100);
  scale(0.15);
  rotateX(PI/2);
  rotateZ(map(mouseX, 0, width, -PI, PI));

  translate(0, 0, -0);

  for (Dive d : activeDives) {
    if (focusDive == null || d == focusDive) {

      PVector ball = d.longUp.get((d.longUp.size() - 1));

      //d.renderSimple();
      pushMatrix();
      rotate(-d.downAngle);
      translate(-ball.x, -ball.y, -ball.z);

      fill(255);
      noStroke();

      pushMatrix();
      translate(ball.x, ball.y, ball.z);
      //box(50);
      popMatrix();  

      //rotate(-d.upAngle);
      stroke(255, 150);
      d.renderSegment(d.longUp);
      popMatrix();
    }
  }
  popMatrix();

  if (outting) {
    endRaw();
    outting = false;
  }


  //Load stuff
  if (getting) {
    try {
      testDive = loadDive("" + start);
      testDive.renderSimple();
    } 
    catch(Exception e) {
    }
    start ++;
  }
  
  */
  
  
}

void loadDivesLocal(int start, int end) {
  for (int i = start; i < end; i++) {

    try {
      String url = localPath + i + ".csv";
      Dive d = new Dive();
      d.diveNo = "" + i;
      d.importPath(url);
      allDives.add(d);
    } 
    catch (Exception e) {
    }
  }

  println("LOADED:" + allDives.size() + " DIVES");
}

Dive loadDive(String diveNo) {
  Dive d = new Dive();
  d.diveNo = diveNo;

  //http://dlacruisedata.whoi.edu/NDSF/alvin/dive/4717/AL4717/

  //Get depth file
  String depthFileURL = alvinServer + diveNo + "/AL" + diveNo  + pathToDepthFile + "AL" + diveNo + ".dep";
  d.loadDepthFile(depthFileURL);

  //Get filenames in USBL 
  ArrayList<String> files = new ArrayList();// = listFileNames(alvinServer + diveNo + "/AL" + diveNo  + pathToUSBL);
  try {
    Document doc = Jsoup.connect(alvinServer + diveNo + "/AL" + diveNo  + pathToUSBL).get();
    for (Element file : doc.select("a")) {
      String a = file.attr("href");
      println(a);
      if (a.indexOf(".csv") != -1) files.add(a);
    }
  } 
  catch (Exception e) {
  }

  for (String f : files) {
    String url = alvinServer + diveNo + "/AL" + diveNo  + pathToUSBL + f;
    loadUSBLFile(url, d);
  }

  //Create simple path
  d.simplify();

  return(d);
}

void loadUSBLFile(String url, Dive d) {
  println("LOAD USBL:" + url);
  String[] rows = loadStrings(url);
  for (String row : rows) {
    d.fileUSBL(row);
  }
}

String[] listFileNames(String dir) {
  println(dir);
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

void keyPressed() {
  if (key == ' ') {
    focusDive = null;
  }
  if (keyCode == RIGHT) {
    focusIndex++;
    if (focusIndex == activeDives.size()) focusIndex = 0;
    focusDive = activeDives.get(focusIndex);
  }
  if (key == 'o') {
    outting = true;
  }
  if (key == 'f') {
    //framing = true; 
  }
}