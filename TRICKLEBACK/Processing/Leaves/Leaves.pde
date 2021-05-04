import java.text.SimpleDateFormat;
import java.util.Date;

String dataPath = "../../data/";
ArrayList<Entry> allEntries = new ArrayList();

color red = #7D312E;
color beige = color(218, 196, 190);

PFont label;
PFont mono;

HashMap<String, String> countryMap = new HashMap();

PImage ebony;
PImage oak;
PImage ginko;
PImage chestnut;

PGraphics leafCanvas;
boolean exporting = false;

HashMap<String, ArrayList<PImage>> leafMap;
String[] leafTypes = {"ebony", "oak", "ginko", "chestnut", "maple", "baobab", "jacaranda"};
int [] leafNums = {3, 3, 1, 1, 2, 1, 1};



void setup() {
  size(600, 800, P2D);
  leafCanvas = createGraphics(3125, 4062, P2D);
  println(leafCanvas);
  background(200);
  smooth(4);

  //set up leaves
  leafMap = new HashMap();
  for (int i = 0; i < leafTypes.length; i++) {
    String lt = leafTypes[i];
    ArrayList<PImage> leafList = new ArrayList();
    leafMap.put(lt, leafList);
    int leafNum = leafNums[i];
    for (int j = 0; j < leafNum; j++) {
      PImage img = loadImage("leaves/" + lt + (j + 1) + ".png");
      leafList.add(img);
    }
  }

  label = createFont("ProximaNova-Regular", 36);

  loadData();
  setContinents();
  putCourseOnScreen();

  drawLeaves();
}

PImage getLeaf(String _type) {
  println(_type);
  ArrayList<PImage> leaves = leafMap.get(_type);
  return(leaves.get(floor(random(leaves.size()))));
}

void draw() {
  if (exporting) drawLeaves();
}

void drawLeaves() {

  PGraphics drawTo = (exporting) ? leafCanvas:g;

  if (exporting) leafCanvas.beginDraw();

  if (!exporting) drawTo.background(200);
  randomSeed(1);

  if (exporting) drawTo.scale (5);

  //CURVE
  drawTo.noFill();
  drawTo.strokeWeight(1);
  drawTo.stroke(255, 150);
  drawTo.beginShape();
  drawTo.curveVertex(screenPoints.get(0).x, screenPoints.get(0).y);
  for (int i = 0; i < screenPoints.size(); i ++) {
    drawTo.curveVertex(screenPoints.get(i).x, screenPoints.get(i).y);
  }
  drawTo.endShape();


  //KEY
  Date start = (new Date(89, 0, 0));
  Date end = (new Date(121, 6, 0));

  for (int i = 89; i < 121; i++ ) {
    Date mid = new Date(i, 0, 0); 
    int ind = floor(map(mid.getTime(), start.getTime(), end.getTime(), 0, screenPoints.size()));
    PVector pos = screenPoints.get(ind);

    drawTo.pushMatrix();

    drawTo.translate(pos.x, pos.y);
    drawTo.rotate(-PI/4);
    drawTo.stroke(255, 100);
    drawTo.line(0, 0, 40, 0);
    drawTo.translate(50, 0);
    //translate(0,0,1);
    drawTo.fill(100);
    //rect(-10,-10,40,20);
    drawTo.fill(255);
    drawTo.textFont(label);
    drawTo.textSize(10);
    drawTo.text(i + 1900, -8, 5);
    drawTo.popMatrix();
  }

  int cc = 0;

  //LEAVES
  for (Entry e : allEntries) {
    if (e.d.getTime() > start.getTime() && e.d.getTime() < end.getTime()) {
      drawTo.pushMatrix();
      //float y = map(e.d.getTime(), start.getTime(), end.getTime(), 0, height);
      int ind = floor(map(e.d.getTime(), start.getTime(), end.getTime(), 0, screenPoints.size()));
      PVector pos = screenPoints.get(ind);
      drawTo.translate(pos.x, pos.y);
      drawTo.rotate(random(TAU));
      //drawTo.scale(max(0.3, sqrt(e.citations)/25) * 0.75);
      drawTo.noTint();

      String ltype = "None";
      float ll = map(sqrt(e.citations), 0, sqrt(600), 20, 100);

      if (e.countries != null ) {
        java.util.List<String> list = java.util.Arrays.asList(e.countries);

        if (list.contains("Cameroon")) {
          int imd = list.indexOf("Cameroon");

          cc++;
          if (imd== 0) drawTo.tint(#AB5253);
          ltype = "ebony";
        } else {
          String cont = countryMap.get(list.get(0));

          switch(cont) {
          case "Europe":
            ltype="oak";
            break;
          case "Asia":
            ltype = "ginko";
            break;
          case "North America":
            ltype = "maple";
            break;
          case "South America":
            ltype="jacaranda";
            break;
          case "Africa":
            ltype="baobab";
            break;
          case "Russia":  
            break;
          case "Australasia":
            break;
          default:
            println(cont);
          }
          //leaf();
        }
        if (!ltype.equals("None")) {
          PImage lf = getLeaf(ltype);
          float sc = ll / sqrt((lf.width * lf.width) + (lf.height * lf.height));
          drawTo.scale(sc);
          drawTo.image(lf, 0, 0);
          drawTo.noTint();
        }
      }

      drawTo.popMatrix();
    }
  }

  //println(cc + ":" + allEntries.size());

  if (exporting) {
    leafCanvas.endDraw();
    leafCanvas.save("outs/big.png");
    exporting = false;
  }
}

void loadData() {
  JSONArray entries = loadJSONArray(dataPath + "cameroon rainforest.json"); 
  for (int i = 0; i < entries.size(); i++) {
    JSONObject e = entries.getJSONObject(i);
    allEntries.add(new Entry().fromJSON(e));
  }

  int nineties = 0;
  int aughts = 0;

  int ninetiest = 0;
  int aughtst = 0;
  for (int i = 0; i < allEntries.size(); i++) {
    Entry e = allEntries.get(i);
    if (e.countries != null) {
      int y = e.d.getYear();
      if (y > 95 && y <=105) {
        ninetiest++;
        java.util.List<String> list = java.util.Arrays.asList(e.countries);

        if (list.contains("Cameroon")) {
          if (list.indexOf("Cameroon") == 0) nineties ++;
        }
      }
      if (y > 110 && y <=120) {
        aughtst++;
        java.util.List<String> list = java.util.Arrays.asList(e.countries);

        if (list.contains("Cameroon")) {
          if (list.indexOf("Cameroon") == 0) aughts ++;
        }
      }
    }
  }

  println("NINETIES:" + ((float) nineties / ninetiest));
  println("AUGHTS:" + ((float) aughts / aughtst));
}

void leaf() {
  float w = 100;
  float thick = random(25, 75);
  //stem
  float stemSize = random(0.1, 0.3);
  float bulgePoint1 = random(0.6, 0.8);
  float bulgePoint2 = bulgePoint1 + random(0.3);
  ;
  //leaf
  strokeWeight(0.1);
  beginShape();
  vertex(stemSize * w, -1);
  vertex( 0, -1);
  vertex(0, 1);
  vertex(stemSize * w, 1);
  bezierVertex(stemSize * w, 1, bulgePoint1 * w, thick, w, 0);
  bezierVertex(w, 0, bulgePoint1 * w, -thick, stemSize * w, -1);
  endShape();
  //line
  beginShape();
  vertex(w * stemSize * 1.1, 0);
  bezierVertex(bulgePoint1 * w, thick * random(0.1, 0.2), bulgePoint2 * w, thick * random(0.1, 0.2), stemSize * w * 0.9, 0);
  endShape();
}

void keyPressed() {
  if (key == 'o') exporting = true;
}