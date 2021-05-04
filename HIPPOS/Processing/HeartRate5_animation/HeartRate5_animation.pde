import processing.pdf.*;

ArrayList<Person> people = new ArrayList();
HashMap<String, Person> personMap = new HashMap();

ArrayList<Sighting> allSightings = new ArrayList();
ArrayList<Sighting> markedSightings = new ArrayList();

import java.util.Date;
import java.text.SimpleDateFormat;

long startTime = 0;
long currentTime = 0;
long endTime = 0;
long timeSpeed = 150000l;

PFont label;
PFont mono;

boolean paused = true;
boolean outting = false;
boolean framing = false;

color red = #7D312E;
color beige = color(218, 196, 190);

SimpleDateFormat sdf;

color[] colors = {#ffffe5, #f7fcb9, #d9f0a3, #addd8e, #78c679, #41ab5d, #238443, #006837, #004529};

PGraphics canvas;

void setup() {
  size(1280, 720, P2D);

  canvas = createGraphics(3250, 4250, JAVA2D);

  label = createFont("Montserrat-Bold", 36);
  mono = createFont("AndaleMono", 36);

  colors = reverse(colors);

  sdf = new SimpleDateFormat("MM/dd HH:mm");
  //loadHeartRate("http://intotheokavango.org/api/timeline?date=20140824&types=ambit");
  //loadSightings("http://intotheokavango.org/api/timeline?date=20140824&types=sighting");
  loadHeartRate("heartrate24.txt");
  loadSightings("sighting24.txt");

  filterSightings("Hippo");

  startTime = 1408604113l * 2000;
  endTime = 0;

  for (Person p : people) {
    if (p.records.get(p.records.size() - 1).timeStamp > endTime) endTime = p.records.get(p.records.size() - 1).timeStamp;
    if (p.records.get(0).timeStamp < startTime) startTime = p.records.get(0).timeStamp;
  }


  //startTime += (endTime - startTime) * 0.25;
  currentTime = startTime;
  println(new Date(startTime), new Date(endTime));




  textFont(label);
  smooth(8);
  position();
}

void draw() {
  if (!paused) currentTime += timeSpeed;

  if (outting) {
    beginRecord(PDF, "heartrate.pdf");
  }
  if (!outting) background(red);

  //if (outting) {
  //  translate(canvas.width/2, canvas.height/2);
  //  scale(2);
  //} else {
  //  translate(width/2, height/2);
  //  scale(0.5);
  //}

  translate(width/2, height/2);
  scale(0.5);

  rotate(-0.3);

  fill(255, 100);


  textFont(label);
  textAlign(LEFT);

  //Time ticks


  long hour = 1000 * 60 * 60 ;
  long st = ceil(startTime / hour) * hour;
  st += hour;
  while (st < endTime) {
    float th = map(st, startTime, endTime, 0, TAU);
    pushMatrix();
    rotate(th);
    stroke(255);
    translate(425, 0);
    line(0, 0, 30, 0);
    Date d = new Date(st);
    int h = d.getHours() + 6;

    fill(255, 150);
    textSize(24);
    text(h + ":00", 35, 12);

    st += hour;
    popMatrix();
  }
  //Hippos
  randomSeed(1);
  for (Sighting s : markedSightings) {
    long t = s.timeStamp;
    //float x = map(t, startTime, endTime, 125, 1025);
    float th = map(t, startTime, endTime, 0, TAU);
    th += random(-0.03, 0.03);

    float rad = 600 + random(25);

    float x = cos(th) * rad;
    float y = sin(th) * rad;

    if (s.name.equals("Hippo")) {
      fill(255);
      textSize(18 + s.count);
    } else {
      fill(255, 50);
      textSize(5 + s.count);
    }

    pushMatrix();
    translate(x, y);
    rotate(th);

    text(s.count + " " + s.name, s.count * 10, 0);
    popMatrix();

    noStroke();
    fill(s.name.equals("Hippo") ? (150):(255));
    ellipse(x, y, 3, 3);
  }


  //red
  fill(190, 0, 0, 150);

  pushMatrix();
  scale(4);
  //rect(-width/2,-height,width,height * 2);
  popMatrix();
  //white

  for (int i = 0; i < 6; i++) {
    pushMatrix();
    rotate(i * (TAU/6));
    fill(255, 100);
    ellipse(0, 0, 750, 850);
    popMatrix();
  }

  //HR scale
  stroke(0, 50);
  line(0, 0, 800, 0);
  for (float i = 60; i < 220; i+= 30) {
    float s = map((i/60), 0.5, (3), 0, 650); 
    stroke(0, 50);
    //line(s, -10, s, 10);
    pushMatrix();
    stroke(0, 30);
    noFill();
    //ellipse(0,0,s * 2,s * 2);
    arc (0, 0, s * 2, s * 2, 0.1, TAU);
    translate(s, 7);
    rotate(PI/2);
    textSize(16);


    noStroke();
    fill(0, 50);
    text(nf(int(i), 2) + ((i == 210) ? (" bpm"):("")), 0, 9);
    popMatrix();
  }

  //People
  textFont(mono);
  textSize(30);
  textAlign(LEFT);
  //text(sdf.format(new Date(currentTime + (6 * 60 * 60 * 1000))), 30, 50);
  for (Person p : people) {
    if (p.name.equals("Jer")) {
      p.update();
      p.render();
    }
  }

  if (outting) {
    outting = false;
    endRecord();
    exit();
    //canvas.save("out.png");
  }

  if (framing) {
    saveFrame("frames/HR-######.png");
  }
}

void position() {
  for (int i = 0; i < people.size(); i++) {
    //people.get(i).tpos.set(75, map(i, 0, people.size(), 180, height - 100) );
    people.get(i).tpos.set(0, 0);
  }
}

void filterSightings(String f) {
  markedSightings = new ArrayList();
  for (Sighting s : allSightings) {
    markedSightings.add(s);
    if (s.name.equals(f)) {

      println("ADD MARK");
    }
  }
}
void loadSightings(String file) {
  JSONObject hr = loadJSONObject(file); 
  JSONArray features = hr.getJSONArray("features");
  for (int i = 0; i < features.size(); i++) {
    JSONObject props = features.getJSONObject(i).getJSONObject("properties");
    String name = props.getString("Bird Name");
    Sighting s = new Sighting();
    s.name = name;
    s.timeStamp = props.getLong("t_utc") * 1000;
    s.count = props.getInt("Count");
    allSightings.add(s);
  }
}

void loadHeartRate(String file) {  
  JSONObject hr = loadJSONObject(file); 
  JSONArray features = hr.getJSONArray("features");
  for (int i = 0; i < features.size(); i++) {
    JSONObject props = features.getJSONObject(i).getJSONObject("properties");
    String name = props.getString("Person");
    Person p = null;

    Record r = new Record().fromJSON(props);

    if (personMap.containsKey(name)) {
      p = personMap.get(name);
    } else {
      p = new Person();
      p.name = name;
      personMap.put(name, p);
      people.add(p);
    }

    Date start = new Date(1408605922 * 1000);
    if (r.hr > 0 && r.timeStamp > start.getTime()) p.records.add(r);
  }
}

color colorFromHR (float hr) {

  //return(colors[floor(map(min(3,hr), 0, 3, 0, colors.length - 1))]);
  float g = map(hr, 1.1, 3, 0, 355);
  float b = map(hr, 0, 3, 690, 255) - (g * 0.6);
  float r = 140;

  return(hr > 2 ? color(g, 0, 0):color(g));
}

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
    //framing = !paused;
  }
  if (key == 'o') outting = !outting;
}