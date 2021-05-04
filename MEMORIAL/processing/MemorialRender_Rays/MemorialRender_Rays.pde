import processing.pdf.*;

import java.util.Collections;

PGraphics canvas;

String dataPath = "../../data/";
String imagePath = "../../images/";

ArrayList<MemName> allNames = new ArrayList();
MemPool southPool = new MemPool();
MemPool northPool = new MemPool();
PFont label;
PFont mono;

HashMap<String, String> salaryMap = new HashMap();

float poolWidth;

boolean PDFing = false;

color red;
color beige;

float panelWidth = 30;

void setup() {
  size(1200, 2000, P2D);
  smooth(4);


  red = #7D312E;
  beige = color(218, 196, 190);

  poolWidth = 18 * panelWidth;

  label = createFont("Montserrat-Bold", 36);
  mono = createFont("AndaleMono", 36);

  canvas = createGraphics(3250, 4250, JAVA2D);
  loadSalaries(dataPath + "salaries.json");
  loadNames(dataPath + "memdata-clean5.csv");
  northPool.calcPaths();
  //southPool.calcPaths();

  //Print average salary

  for (MemName mn : northPool.names) {
    if (mn.sal > 0) {
      //println(mn.name);
      //println(mn.job + ":" + mn.sal + ":" + mn.adjCount);
      if (!mn.job.equals("null")) {
       // println("GOOD" + mn.job);
        northPool.salStack[min(mn.adjCount, 3)].add(mn.sal);
        northPool.titleStack[min(mn.adjCount, 3)].add(mn.job);
      }
    } else {
      if (!mn.job.equals("null") && mn.adjCount > 0) println("NO SAL FOR:" + mn.job);
    }
  }

  for (int i = 0; i < 4; i++) {
    println(northPool.salStack[i].size());
    Collections.sort(northPool.salStack[i]);
    for (Integer s: northPool.salStack[i]) {
     //print(s + ":" + northPool.salStack[i] + ","); 
    }
    
    //median
    println("");
    println(floor((float)northPool.salStack[i].size()/2));
    println("MEDIAN " + i + ":" + northPool.salStack[i].get(1 + floor((float)northPool.salStack[i].size()/2)));
  }
}

void draw() {
  background(beige);
  MemPool pool = northPool;

  if (PDFing) {
    beginRecord(PDF, "memOut.pdf"); 
    println("START PDF");
  }

  pushMatrix();
  translate(-poolWidth/2, -poolWidth/2 - 14);
  if (frameCount == 1) pool.render(g);
  popMatrix();

  translate(width/2, height/2);
  scale(0.4);
  pool.renderFlat(g);

  rectMode(CENTER);
  fill(255);
  stroke(0);
  rect(0, 0, poolWidth * 0.9, poolWidth * 0.9, 10);
  rectMode(CORNER);

  if (PDFing) {
    println("END PDF");
    endRecord();
    PDFing = false;
    println("END PDF");
    exit();
  }
}

void loadNames(String path) {
  Table nTable = loadTable(path, "tsv");
  for (int i = 0; i < nTable.getRowCount(); i++) {
    TableRow tr = nTable.getRow(i);
    MemName mn = new MemName().fromTableRow(tr);

    if (mn.poolPosition > 0) {
      allNames.add(mn);
      (mn.isNorth ? northPool:southPool).addName(mn);
    } else {
      //println(mn.name + mn.poolPosition);
    }
  }  
  southPool.sortPanels();
  northPool.sortPanels();
}


void loadSalaries(String path) {
  JSONArray salaries = loadJSONArray(path);
  for (int i = 0; i < salaries.size(); i++) {
    JSONObject sal = salaries.getJSONObject(i);

    salaryMap.put(sal.getString("job"), sal.getString("salary"));
  }
}

void keyPressed() {
  if (key == 'p') {
    PDFing = true;
  }
  if (key == 'r') {
   northPool.report(); 
  }
}