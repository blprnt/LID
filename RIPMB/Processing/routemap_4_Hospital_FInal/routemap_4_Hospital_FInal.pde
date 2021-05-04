import processing.pdf.*;


import toxi.geom.*;
import java.lang.reflect.Method;
/*
 
 √ 1. Fix gaps in data
 2. Fix locations not giving data
 3. Pretty render
 √ 4. Proper rectify
 5. Key
 
 */

JSONArray locations;

float[] bounds = {-90.6182574957, 38.4650494317, -90.091085407, 38.9671184401};//{-90.4728656738,38.5603829371,-90.1683866708,38.8744896261};//{-90.59783, 38.492829, -89.980316, 38.840398};//{-90.567993,38.491042,-90.166292,38.831667};

//

PVector canfield = new PVector(-90.274060, 38.738695);
ArrayList<Route> allRoutes = new ArrayList();
PVector can;
float maxDuration = 0;

PFont label;

PImage back;

ArrayList<PVector> features = new ArrayList();

int featureCount = 0;


void setup() {
  size(650, 850, P3D);
  background(0);
  smooth(4);

  back = loadImage("bbox.png");

  loadLocations("../../data/newroutes/hospital.json");

  label = createFont("Avenir", 24);
  textFont(label);

  can = getScreenCoords(canfield);
  
}

void writePDF() {
  beginRaw(PDF, "test.pdf");
  for (Route r : allRoutes) {
    r.writeStripToGraphics(g);
  }
  endRaw();
}

void draw() {
  background(222);

  randomSeed(0);

  pushMatrix();
  float sc = (float) height / back.height;
  scale(sc * 1.35);
  //image(back, -400 + mouseX, -400 + mouseY);
  popMatrix();
  //println(mouseY);

  lights();

  translate(0,-100);

  for (Route r : allRoutes) {
    r.update();
    if (random(100) < 100)r.render();
  }

  fill(255, 0, 0);
  noStroke();
  ellipse(can.x, can.y, 5, 5);

  fill(0);
  textSize(24);
  text(floor(maxDuration/60) + ":" + maxDuration % 60, 50, 50);
  //println(floor(maxDuration/60) + ":" + maxDuration % 60);
}

boolean checkFeature(PVector v, float dist) {
 boolean chk = true;
   for (PVector f:features) {
     float d = f.dist(v);
     if (abs(d) < dist) chk = false;
   }
 return(chk);
 
}

void drawRoute(JSONObject _route) {
}


void loadLocations(String _url) {
  locations = loadJSONArray(_url);
  for (int i = 0; i < locations.size(); i++) {
    JSONObject loc = locations.getJSONObject(i);
    try {
      JSONObject route = loc.getJSONObject("routeData").getJSONObject("json");
      String name = name = loc.getString("name");
      Route r = new Route(route, name);
      r.id = i;
      //if (name.toLowerCase().indexOf("hospital") != -1) 
      allRoutes.add(r);
    } 
    catch (Exception e) {
      println(e);
    }
  }


  int c = 0;
  for (Route r : allRoutes) {

    r.processRoute();
    r.makeStrip(3, 1, c);
    c++;
  }
}

PVector getScreenCoords(PVector lonLat) {
  //println((bounds[2] - bounds[0]) / (bounds[3] - bounds[1]));
  float sc = width / (bounds[2] - bounds[0]);

  float x = map(lonLat.x, bounds[0], bounds[2], 0, width);
  float y = map(lonLat.y, bounds[1], bounds[3], height, 0) * 1.13;
  return(new PVector(x, y));
}

class Route {
  int id;
  String name;
  JSONObject json;
  JSONArray steps;
  ArrayList<PVector> route = new ArrayList();
  ArrayList<PVector> strip = new ArrayList();

  PShape stripShape;

  float z = 100;
  float tz;

  int duration;

  color col = 255;

  float shapedness = 0;

  float firstAngle = -100;
  float firstWidth = 0;

  boolean feature = false;
 

  Route(JSONObject _route, String _name) {
    json = _route;
    name = _name;
  }

  void makeStrip(float rad, int skip, int ind) {

    float cv = map(duration, 0, maxDuration, 255, 0);
    col = color(cv, sqrt(cv), sqrt(cv));
    
    float trad = map(duration, 0, maxDuration, 4, 1);
    
    
    z = pow(map(duration, 0, maxDuration, 10, 1), 1) + random(0.1);// * shapedness;
    tz = z;//-map(duration, 0, maxDuration, 10, 1);

    int c = 0;
    PrintWriter book = createWriter("paths/path" + ind + ".csv");
    book.println(rad);
    book.println("#" + hex(col, 6));

    //splinify
    ArrayList<Vec3D> toxiVecs = new ArrayList();
    for (PVector pv : route) {
      toxiVecs.add(new Vec3D(pv.x, pv.y, pv.z));
    }
    
    feature = name.toLowerCase().indexOf("hospital") != -1 && checkFeature(route.get(0), 18);
    if (feature) {
      features.add(route.get(0));
      println(id + ":" + name.toLowerCase());
    }
    book.println(feature);
    
    rad = (feature) ? trad: 0;
    

    toxi.geom.Spline3D spline = new toxi.geom.Spline3D(toxiVecs);
    //println(spline.getNumPoints());

    Class cl = spline.getClass();
    for (Method method : cl.getDeclaredMethods()) {
      
        //System.out.println(method.getName());
      
    }


    java.util.List<Vec3D> decimated = spline.getDecimatedVertices(1f);
    //println(decimated.size());

    for (int i = 0; i < decimated.size() - skip; i++) {
      //Speed toward target 
      z += (tz - z) * ((decimated.size() - i < 100) ? 0.1:0.02);
      rad += (trad - rad) * 0.03;
      if (i % skip == 0) {
        Vec3D v1 = decimated.get(i);

        Vec3D v2 = decimated.get(i + skip);
        float theta = atan2(v2.y - v1.y, v2.x - v1.x);
        if (firstAngle == -100) {
          firstAngle = theta;
          firstWidth = rad * 2;
        }
        PVector w1 = new PVector(v1.x - (sin(theta) * rad), (v1.y + (cos(theta) * rad)), z);
        PVector w2 = new PVector(v1.x + (sin(theta) * rad), (v1.y - (cos(theta) * rad)), z);

        if (i == 0) {
          strip.add(w2);
          //strip.add(w1);
          book.print(w2.x + "," + w2.y + "," + z + ((i == route.size() - 1) ? "":","));
          //book.print(w2.x + "," + w2.y + "," + z + ((i == route.size() - 1) ? "":","));
        } else {
          PVector v = c % 2 == 0 ? w1:w2;
          book.print(v.x + "," + v.y + "," + z + ((i == route.size() - 1) ? "":","));
          strip.add(v);
        }
        c++;
      }
    }
    book.flush();
    book.close();



    PShape s = createShape();
    writeStripToShape(s, col);
    stripShape = s;
  }

  void writeStripToShape(PShape s, color col) {
    //colorMode(HSB);
    s.beginShape(TRIANGLE_STRIP);
    s.noStroke();
    s.fill(col);
    for (int i = 0; i < strip.size(); i++) {
      s.vertex(strip.get(i).x, strip.get(i).y, strip.get(i).z);
    }
    s.endShape();
  }

  void writeStripToGraphics(PGraphics s) {
    s.beginShape(TRIANGLE_STRIP);
    s.noStroke();
    s.fill(col);
    for (int i = 0; i < strip.size(); i++) {
      s.vertex(strip.get(i).x, strip.get(i).y, strip.get(i).z);
    }
    s.endShape();
  }

  void processRoute() {

    JSONArray routes = json.getJSONArray("routes");
    JSONArray legs = routes.getJSONObject(0).getJSONArray("legs");

    steps = legs.getJSONObject(0).getJSONArray("steps");
    duration = legs.getJSONObject(0).getJSONObject("duration").getInt("value");
    if (duration > maxDuration) maxDuration = duration;

    for (int i = 0; i < steps.size(); i++) {
      JSONObject step = steps.getJSONObject(i);

      JSONArray poly = step.getJSONObject("polyline").getJSONArray("newPoints");
      for (int j = 0; j < poly.size(); j++) {
        JSONArray p = poly.getJSONArray(j);
        PVector screen = getScreenCoords(new PVector(p.getFloat(1), p.getFloat(0)));
        route.add(screen);
      }
    }
  }

  void update() {
  }

  void render() {
    fill(0);
    noFill();
    stroke(col);
    //strokeWeight((265 - red(col)) * 0.03);

    PVector tip = strip.get(0);
    pushMatrix();
    translate(tip.x, tip.y, tip.z);
    //rotate(firstAngle + PI);
    fill(220);
    if (feature) {
      noStroke();
      scale(1);
      fill(255);
      

      pushMatrix();
      translate(0,0,10);
      scale(2);
      
      rectMode(CENTER);
      //stroke(col);
      noStroke();
      fill(0, 25);
      //strokeWeight(3);
      rect(1, 1, 6, 6);
      
      translate(0,0,1);
      noStroke();
      //stroke(200);
      fill(255);
      rect(0, 0, 6, 6);
      
      
      popMatrix();

      pushMatrix();
      translate(0, 0, 0.5);
      rotate(-firstAngle + PI);
      fill(0);
      textSize(firstWidth * 3);
      text(floor(duration / 60), -firstWidth/2 + 10, firstWidth);
      popMatrix();
    } else {
     fill(col);
     noStroke();
     pushMatrix();
     //ellipse(0,0, firstWidth * 2, firstWidth * 2);
     popMatrix();
    }
    fill(0);
    textSize(18);
    //text(name, 0, -9);
    noStroke();
    //sphere(5);
    popMatrix();

    shape(stripShape, 0, 0);
  }
}

void keyPressed() {
  if (key == 'p') writePDF();
}