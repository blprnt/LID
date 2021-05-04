import processing.pdf.*;


import toxi.geom.*;
import java.util.Arrays;

String dataPath = "/Users/jerthorp/Downloads/wordMap.json";
ArrayList<WordPoint> words = new ArrayList();

HashMap<String, ArrayList<WordPoint>> wordMap = new HashMap();
HashMap<String, WordPoint> labelMap = new HashMap();

Vec3D rot = new Vec3D();
Vec3D trot = new Vec3D();

Vec3D focus = new Vec3D();
Vec3D tfocus = new Vec3D();

float zoom = 1;
float tzoom = 1.2;

PFont displayFont;

PFont label;
PFont mono;

Lorenz attractor;
boolean lorenzing = false;

float scale = 600;

String lastWord = "";
String display = "";

WordPoint closest;

PrintWriter writer;

HashMap<String, String> posMap = new HashMap();

PosSequence sequence;

PVector lrot = new PVector();
String poet;

float speed;

boolean poeting = false;

boolean PDFing = false;

PGraphics canvas;
int canvasScale = 4;

boolean framing = false;

WordPoint[] showing;

void setup() {
  //fullScreen(P3D);
  size(1225, 850, P3D);
  canvas = createGraphics(width * canvasScale, height * canvasScale, P3D);
  canvas.smooth(4);


  smooth(4);
  frameRate(30);

  displayFont = createFont("Helvetica", 200);
  label = createFont("Montserrat-Bold", 200);
  mono = loadFont("ProximaNova-Medium-200.vlw");
  textFont(displayFont);

  poet = "frost";
  speed = 0.015;

  writer = createWriter("out" + "_" + poet + "_" +  hour() + "_" + minute() + "_" + ".txt");

  attractor = new Lorenz();
  attractor.init();
  attractor.sf = scale / 120;

  lrot.x = 0;
  lrot.y = PI;
  lrot.z = 0;

  init();
}

void init() {

  //Load POS sequence
  sequence = new PosSequence();
  sequence.loadFromFile(poet + ".txt");

  //Load POS map
  String[] rows = loadStrings("pos.csv");
  for (int i = 0; i < rows.length; i++) {
    String[] cols = rows[i].split(",");
    posMap.put(cols[0], cols[1]);
  }

  //Load word vectors
  JSONArray wordJSON = loadJSONArray(dataPath);

  for (int i = 0; i < wordJSON.size(); i++) {
    JSONObject jo = wordJSON.getJSONObject(i);
    JSONArray pos = jo.getJSONArray("pos");
    float x = pos.getFloat(0);
    float y = pos.getFloat(1);
    float z = pos.getFloat(2);
    WordPoint w = new WordPoint();
    String l = jo.getString("label");
    if (l.equals(l.toLowerCase())) {
    }
    labelMap.put(l, w);
    w.word = l;
    String part = posMap.get(l);
    //File into appropriate array
    if (!wordMap.containsKey(part)) {
      wordMap.put(part, new ArrayList());
      wordMap.get(part).add(w);
    } else {
      wordMap.get(part).add(w);
    }


    if (w.word.length() > 3) words.add(w);
    w.set(x * scale, y * scale, z * scale);
  }
}

int dc = 0;


void draw() {

  PGraphics drawOn = (PDFing ? canvas: g);

  if (PDFing) {
    //beginRecord(PDF,"universe.pdf"); 

    drawOn.beginDraw();
    drawOn.scale(canvasScale);
    
  }

  drawOn.blendMode(ADD);

  rot.interpolateToSelf(trot, 0.01);
  focus.interpolateToSelf(tfocus, 0.01);
  zoom = lerp(zoom, tzoom, 0.01);

  if (mousePressed) {
    trot.x += (mouseY - pmouseY) * 0.003;
    trot.y += (mouseX - pmouseX) * 0.003;
  }

  //background(#330000);
  drawOn.background(0);

  drawOn.textFont(displayFont);
  drawOn.textSize(180);
  drawOn.fill(#CC0000);

  if (!PDFing) {
    drawOn.fill(255);
    //drawOn.text(rot.x + ":" + rot.y + ":" + rot.z, 0, 0);
  }

  drawOn.fill(255);


  try {
    drawOn.text(display, 50, 75, width - 100, height - 100);
  } 
  catch(Exception e) {
    println(e);
  }


  //Find closest word
  //closest = getClosestWord(words, attractor.points.get(attractor.points.size() - 1));
  if (poeting) {
    String pos = sequence.getNext(); 
    //text(pos, 350, 75, width - 100, height - 100);
    String n;
    try {
      closest = getClosestWord(wordMap.get(pos), attractor.points.get(attractor.points.size() - 1));
      n = closest.word;
    } 
    catch(Exception e) {
      n = pos;
    }
    if (!n.equals(lastWord)) {
      lastWord = n;
      writer.print(n + " ");
      display = n + " " + display;
    }
  }

  drawOn.translate(width/3.75, height/2);
  drawOn.scale(zoom);


  drawOn.rotateX(rot.x);
  drawOn.rotateY(rot.y);
  drawOn.rotateZ(rot.z);

  drawOn.translate(-focus.x, -focus.y, -focus.z);

  drawOn.pushMatrix();
  drawOn.textFont(label);
  drawOn.textSize(48);
  drawOn.fill(#AA5252);
  drawOn.rotateZ(-rot.z);
  drawOn.rotateY(-rot.y);
  drawOn.rotateX(-rot.x);
  //rotate(-PI/2);
  drawOn.noStroke();
  //if (!PDFing || dc == 1) 
  drawOn.ellipse(0, 0, 10, 10);
  //drawOn.text("Data", 0, 0);
  drawOn.popMatrix();

  //axes
  /*
  stroke(0, 0, 255);
   line(-5000, 0, 5000, 0);
   
   stroke(255, 255, 0);
   line(0, 0, -5000, 0, 0, 5000);
   
   stroke(0, 255, 0);
   line(0, -5000, 0, 5000);
   //*/


  if (poeting) {
    //Attractor
    attractor.update();
    attractor.render();
  }



  if (showing != null) {
    for (WordPoint w : showing) {
      w.texting = false;
    }
  }

  if (!poeting) {
    showing = getClosestWords(words, focus, 2000);
    for (WordPoint w : showing) {
      w.texting = true;
    }
  }

  drawOn.strokeWeight(1);
  for (int i = 0; i < words.size(); i++) {
    drawOn.pushMatrix();
    WordPoint w = words.get(i);
    drawOn.translate(w.x, w.y, w.z);
    drawOn.fill(255);

    drawOn.rotateZ(-rot.z);
    drawOn.rotateY(-rot.y);
    drawOn.rotateX(-rot.x);

    //drawOn.scale(1.0 / zoom);
  
    /*
    if (PDFing) {
      //drawOn.noStroke();
      //drawOn.rect(0, 0, 1, 1);
      drawOn.stroke(255); 
      drawOn.point(0, 0);
    } else {
      drawOn.stroke(255); 
      drawOn.point(0, 0);
    }
    */

    if (w.texting && (!PDFing || i % 10 == dc)) {
      drawOn.stroke(255); 
      drawOn.point(0, 0);
      drawOn.fill(255);
      //rotate(-PI/2);
      drawOn.textFont(mono);
      drawOn.textSize(2 + (300.0/pow(w.best, 0.6)));
      drawOn.text(w.word, 0, 0);
      //
    }
    
    if (!w.texting && (!PDFing || i % 10 == dc)) {
      drawOn.fill(255); 
      drawOn.noStroke();
      drawOn.rect(0, 0,0.5,0.5);
    }

    drawOn.popMatrix();
  }

  if (PDFing) {
    canvas.endDraw();
    canvas.save("outs/" + dc + ".png");
    dc++;
    if (dc == 10) exit();//PDFing = false;
  }
  
  if (framing) {
    saveFrame("frames/Universe-######.png");
  }
}

void focusPoint(WordPoint w) {
  tfocus = new Vec3D(w.x, w.y, w.z);
}

WordPoint getClosestWord(ArrayList<WordPoint> wordList, Vec3D v) {
  float best = 1000000000;
  WordPoint bestPoint = null;
  int c = 0;
  for (WordPoint wp : wordList) {
    float d = pow(v.x - wp.x, 2) + pow(v.y - wp.y, 2) + pow(v.z - wp.z, 2);

    if (abs(d) < best) {
      bestPoint = wp;
      best = abs(d);
    }
    c++;
  }
  return(bestPoint);
}

WordPoint[] getClosestWords(ArrayList<WordPoint> wordList, Vec3D v, int n) {
  WordPoint[] words = new WordPoint[n];
  for (int i = 0; i < words.length; i++) {
    words[i] = wordList.get(i);
  }

  for (WordPoint wp : wordList) {
    float d = pow(v.x - wp.x, 2) + pow(v.y - wp.y, 2) + pow(v.z - wp.z, 2);
    int i = 0;
    while (i < words.length) {
      if (abs(d) < words[i].best) {
        words[i] = wp;
        wp.best = abs(d);
        break;
      }
      i++;
    }
  }


  return(words);
}

void keyPressed() {

  if (key == ' ') PDFing = true;
  if (key == 'f') framing = !framing;
  if (key == 'i') save("out" + hour() + "_" + minute() + "_" + second() + ".png"); 
  if (key == 'z') println(trot);
  if (key == 's') {
    writer.flush();
    writer.close();
    exit();
  }
  if (key == '0') {
    trot = new Vec3D(-0.02999979, -1.9979991,0); 
    //{x:-0.02999979, y:-1.9979991, z:0.0}
    tzoom = 2.06;
    tfocus = new Vec3D();
    framing = true;
  }
  if (keyCode == UP) {
    tzoom += 0.1;
  }
  if (key == 'r') {
    focusPoint(words.get(floor(random(words.size()))));
  }
  if (key == '1') {
    WordPoint w = labelMap.get("whimsy");
    focusPoint(w);
  }
  if (key == 'd') {

    WordPoint w = labelMap.get("data");
    closest = w;
    focusPoint(w);
  }
  if (key == '2') {
    WordPoint w = labelMap.get("love");
    focusPoint(w);
  }
  if (key == '3') {
    WordPoint w = labelMap.get("statistics");
    focusPoint(w);
  }
  if (key == 'l') {
    lorenzing = !lorenzing;
  }
  if (key == 'p') {
    poeting = !poeting;
    if (poeting) {
      writer = createWriter("out" + "_" + poet + "_" +  hour() + "_" + minute() + "_" + ".txt");
      tzoom = 0.7;
    } else {
      writer.flush();
      writer.close();
      tzoom = 1;
    }
  }
}