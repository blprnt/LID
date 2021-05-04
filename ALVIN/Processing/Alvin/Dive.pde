class Dive {

  String diveNo;
  String dateString;
  int dc = 0;

  PVector minBounds = new PVector(100000, 100000, 100000);
  PVector maxBounds = new PVector(-100000, -100000, -100000);

  ArrayList<TPDRPoint> TPDRPoints = new ArrayList();
  ArrayList<DepthRecord> depthRecords = new ArrayList();

  ArrayList<PVector> longDown = new ArrayList();
  ArrayList<PVector> longUp = new ArrayList();

  float upAngle = 0;
  float downAngle = 0;

  PVector[] complexPath;
  PVector[] simplePath;

  ArrayList<Marker> markers = new ArrayList();

  Date startDate;
  Date endDate;
  Date currentDate = new Date();

  float maxDepth = 0;
  float currentDepth = 0;

  float lineComplete = 0;
  float tlineComplete = 1;

  PVector markerOff;
  PVector centroid = new PVector();

  int rc = 0;

  HashMap<String, Marker> markerMap = new HashMap();

  void simplify() {
    int t = TPDRPoints.size();
    println("BEFORE SIMPLIFICATION:" + t);
    complexPath = new PVector[t];
    for (int i = 0; i < t; i++) {
      complexPath[i] = TPDRPoints.get(i).pos;
    }

    simplePath = Simplify.runningAverage(complexPath, 10);

    //Calculate average
    for (PVector p : simplePath) {
      centroid.add(p);
    }
    centroid.div(simplePath.length);
    centroid.z = -(maxDepth * 0.7) * ppm;

    //simplePath = Simplify.simplify(simplePath, 50, true);
    //println("AFTER SIMPLIFICATION" + simplePath.length);
    exportPath();
  }

  void update() {


    if (lineComplete < 1 && tlineComplete == 1) lineComplete += 0.01;
    if (lineComplete > 0 && tlineComplete == 0) lineComplete -= 0.01;
    lineComplete = constrain(lineComplete, 0, 1);
  }

  void renderSegment(ArrayList<PVector> seg) {

    PVector start = seg.get(0);
    PVector end = seg.get(min(rc, seg.size() - 1));
    noFill();
    beginShape();
    //curveVertex(start.x, start.y, start.z);
    //println(simplePath.length * lineComplete);
    for (int i = 1; i < min(seg.size(), rc); i+=curveStep) {
      PVector p = seg.get(i);
      PVector mag = p.copy().sub(seg.get(i - 1));
      if (mag.z > 0) {
        //stroke(255, mag.mag() * 10, 0);
      } else {
        //stroke(0, mag.mag() * 10, 255);
      }
      strokeWeight(min(40, mag.mag()) + 1);
      curveVertex(p.x, p.y, p.z);
    }
    //curveVertex(end.x, end.y, end.z);
    endShape();
    rc++;
  }

  void renderSimple() {

    //Draw ends 
    fill(255);
    noStroke();
    PVector start = simplePath[0];
    PVector end = simplePath[simplePath.length - 1];
    pushMatrix();
    translate(start.x, start.y, start.z);
    box(5);
    popMatrix(); 
    pushMatrix();
    translate(end.x, end.y, end.z);
    box(5);
    popMatrix(); 
    //Draw simple path   
    noFill();
    beginShape();
    curveVertex(start.x, start.y, start.z);
    //println(simplePath.length * lineComplete);
    for (int i = 1; i < simplePath.length; i+= 5) {
      PVector p = simplePath[i];
      PVector mag = p.copy().sub(simplePath[i - 1]);
      color c = (simplePath[i - 1].z > p.z) ? #FF0000:#0000FF; //ascent = red, descent = blue
      float sc = 25;
      //color c = color(abs(mag.x) * sc, abs(mag.y) * sc, abs(mag.z) * sc);
      stroke(c, 170);
      curveVertex(p.x * ppm, p.y * ppm, p.z * ppm );
    }
    curveVertex(end.x, end.y, end.z);
    endShape();
  }

  void render() {
    if (TPDRPoints.size() > 0) {
      if (lineComplete < 0.99 ) {
        for (int c = 0; c < TPDRPoints.size(); c++) {
          TPDRPoint tp = TPDRPoints.get(c); 
          PVector p = tp.pos;

          pushMatrix();
          translate(p.x * ppm, p.y * ppm, p.z * ppm * deep);
          rotateZ(-rot.z);
          rotateY(-rot.y);
          rotateX(-rot.x);

          noStroke();
          fill(map(c, 0, TPDRPoints.size(), 0, 180), 255, 255);
          rect(0, 0, 1, 1);


          popMatrix();
        }
      }


      TPDRPoint tp = TPDRPoints.get(dc);
      currentDate = tp.date;
      currentDepth = tp.depth;
      debug = "" + tp.rot.z;
      talvin.set(tp.pos.x * ppm, tp.pos.y * ppm, tp.pos.z * ppm * deep);

      for (Marker m : markers) {
        m.update();
        m.render();
      }


      //Draw simple path
      stroke(230);
      strokeWeight(3);
      noFill();
      beginShape();
      //println(simplePath.length * lineComplete);
      for (int i = 10; i < simplePath.length * lineComplete - 11; i++) {
        PVector p = simplePath[i];
        vertex(p.x * ppm, p.y * ppm, p.z * ppm * deep);
      }
      endShape();
      strokeWeight(1);

      //Animate Alvin
      if (playing) dc ++;
      if (dc == TPDRPoints.size()) dc = 0;

      //Draw centroid
      pushMatrix();
      fill(255, 255, 255);
      translate(centroid.x, centroid.y, centroid.z * deep);
      noStroke();
      //rect(0,0,10,50);
      //rect(0,0,50,10);

      popMatrix();
    }
  }

  void loadMarkers(String url) {
    String[] rows = loadStrings(url);
    for (String row : rows) {
      String[] cols = split(row, ",");
      if (cols[64].length() > 1 && !cols[64].equals("TGT Label")) {
        //println(cols[64], float(cols[66]), float(cols[67]), float(cols[68]));
        addMarker(cols[64], float(cols[66]), float(cols[67]), float(cols[68]));
      };
    }
  }

  void addMarker(String name, float x, float y, float d) {
    if (!markerMap.containsKey(name)) {
      Marker m = new Marker();
      m.pos.set(x * ppm, y * ppm, d * ppm);
      if (markerOff == null) {
        markerOff = new PVector(m.pos.x, m.pos.y, m.pos.z);
        println("MARKEROFF", markerOff);
      } 


      m.pos.x -= markerOff.x;
      m.pos.y -= markerOff.y;
      m.pos.z -= markerOff.z;


      if (m.pos.z <= 50) m.pos.z = maxDepth * -ppm;

      m.pos.x *= 10;
      m.pos.y *= 10;

      m.n = name;
      markers.add(m);
      markerMap.put(name, m);
    } else {
    }
  }

  void loadDepthFile(String url) {
    println("LOADING DEPTH FILE.");
    String[] rows = loadStrings(url);
    println(rows.length);
    for (String row : rows) {
      //DEP 2014/05/25 20:28:14.180 ALVI 0 504.110364 *0001751.765
      String[] cols = split(row, " ");
      if (dateString == null) dateString = cols[1];
      DepthRecord dr = new DepthRecord();
      dr.depth = float(cols[5]);
      maxDepth = max(maxDepth, dr.depth);
      try {
        dr.date = sdfFull.parse(cols[1] + " " + cols[2]);
      } 
      catch(Exception e) {
        println("ERROR ON DATE");
      }
      depthRecords.add(dr);
    }

    startDate = depthRecords.get(0).date;
    endDate = depthRecords.get(depthRecords.size() - 1).date;

    println(startDate, endDate);
  }

  void exportPath() {
    String[] outs = new String[simplePath.length];
    for (int i = 0; i < simplePath.length; i++) {
      PVector p = simplePath[i];
      outs[i] = p.x + "," + p.y + "," + p.z;
    }
    saveStrings("paths/" + diveNo + ".csv", outs);
  }

  void importPath(String url) {
    Table t = loadTable(url);
    simplePath = new PVector[t.getRowCount()];
    for (int i = 0; i < t.getRowCount(); i++) {
      TableRow tr = t.getRow(i);
      PVector v = new PVector(tr.getFloat(0), tr.getFloat(1), tr.getFloat(2));
      simplePath[i] = v;

      minBounds.x = min(v.x, minBounds.x);
      minBounds.y = min(v.y, minBounds.y);
      minBounds.z = min(v.z, minBounds.z);

      maxBounds.x = max(v.x, maxBounds.x);
      maxBounds.y = max(v.y, maxBounds.y);
      maxBounds.z = max(v.z, maxBounds.z);
    }

    //get longest ups and downs
    ArrayList<PVector> tempDowns = new ArrayList();
    ArrayList<PVector> tempUps = new ArrayList();
    float trend = 0;
    for (int i = 1; i < simplePath.length; i++) {
      PVector p = simplePath[i];
      PVector mag = p.copy().sub(simplePath[i - 1]);
      if (i == 1) trend = mag.z;
      //check for direction switch
      if (mag.z / abs(mag.z) != trend / abs(trend)) {
        tempDowns = new ArrayList();
        tempUps = new ArrayList();
        trend = mag.z;
      }
      if (mag.z > 0) {
        tempUps.add(p);
        if (tempUps.size() > longUp.size()) longUp = tempUps;
      } else {
        tempDowns.add(p);
        if (tempDowns.size() > longDown.size()) longDown = tempDowns;
      }
    }

    //Set angles
    upAngle = atan2(longUp.get(longUp.size() - 1).y - longUp.get(0).y, longUp.get(longUp.size() - 1).x - longUp.get(0).x);
    downAngle = atan2(longDown.get(longDown.size() - 1).y - longDown.get(0).y, longDown.get(longDown.size() - 1).x - longDown.get(0).x);
  }


  void fileUSBL(String usbl) {
    String[] cols = split(usbl, ",");
    if (cols[0].equals("TPDR")) parseTPDR(cols);
  }

  void parseTPDR(String[] cols) {
    //0    1    2    3     4   5    6    7     8    9       10       11      12   13    14    15    16      17      18     19    20
    //TPDR,tick,name,index,fix,flag,time,pitch,roll,bearing,residual,quality,east,north,depth,const,x_angle,y_angle,debug1,debug2,debug3
    float depth = float(cols[14]);
    float x = float(cols[12]);
    float y = float(cols[13]);
    float z = -float(cols[14]);

    float pitch = float(cols[7]);
    float roll = float(cols[8]);
    float bearing = float(cols[9]);

    float xangle = float(cols[16]);
    float yangle = float(cols[17]);

    String timeString = cols[1];

    TPDRPoint tp = new TPDRPoint();
    tp.depth = depth;
    tp.pos.set(x, y, z);
    tp.rot.set(pitch, roll, bearing);

    boolean goodDate = true;
    try {
      tp.date = sdfFull.parse(dateString + " " + timeString);
    } 
    catch (Exception e) {
      goodDate = false;
    }

    if (goodDate && tp.date.getTime() > startDate.getTime() && tp.date.getTime() < endDate.getTime() && tp.pos.x != 0) {
      TPDRPoints.add(tp);

      minBounds.x = min(x, minBounds.x);
      minBounds.y = min(y, minBounds.y);
      minBounds.z = min(z, minBounds.z);

      maxBounds.x = max(x, maxBounds.x);
      maxBounds.y = max(y, maxBounds.y);
      maxBounds.z = max(z, maxBounds.z);
    }

    //println(depth);
  }
}

class TPDRPoint implements Comparable {
  PVector pos = new PVector();
  PVector rot = new PVector();
  Date date;
  float depth;

  int compareTo(Object o) {
    return(int(date.getTime() -  ((TPDRPoint)o).date.getTime()));
  }
}

class DepthRecord {
  Date date;
  float depth;
}

class Marker {
  PVector pos = new PVector();
  String n;

  void update() {
  }

  void render() {
    pushMatrix();

    translate(-pos.x, -pos.y, pos.z * deep);

    fill(156, 255, 255);
    noStroke();
    rect(0, 0, 3, 15);
    rect(0, 0, 15, 3);

    fill(255);
    scale(rot.x / (PI * 0.5) );
    rotateX(-PI/2);
    rotateY(rot.z);
    rotateZ(-PI/2);
    //textFont(light);
    textSize(14);
    text(n, 5, -5);

    stroke(0);
    line(0, 0, textWidth(n) + 5, 0);
    popMatrix();
  }
}