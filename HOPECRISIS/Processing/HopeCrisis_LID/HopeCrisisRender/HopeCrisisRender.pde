import processing.pdf.*;

Table hope;
Table crisis;

color red = #7D312E;
color beige = color(218, 196, 190);

PFont label;
PFont mono;

boolean outting = false;

float start = PI/8;

void setup() {
  size(2000, 825, P2D);
  smooth(3);

  label = createFont("Montserrat-Bold", 36);
  mono = createFont("AndaleMono", 36);

  hope = loadData("hope.csv");
  crisis = loadData("crisis.csv");
}

void draw() {

  background(red);
  randomSeed(0);


  if (outting) {
    beginRecord(PDF, "hope.pdf");
  }
  pushMatrix();

  translate(width/2, height/2);
  stroke(255, 85);
  for (int i = 0; i < 37; i++) {
    pushMatrix();
    rotate(start + (i * ((TAU - start)/37)));
    line(0, (i % 4 == 0) ? -60:-70, 0, -80); 
    if (i % 4 == 0 && i != 0) {
      fill(255, 100);
      textFont(label);
      textSize(10);
      translate(0, -60);
      rotate(PI/2);
      text(i + 1984, 0, 4);
    }
    popMatrix();
  }

  scale(0.5);
  fill(255);
  noStroke();
  renderRadial(hope, color(255));
  popMatrix();
  if (outting) {
    endRecord();
  }


  if (outting) {
    beginRecord(PDF, "crisis.pdf");
  }
  pushMatrix();
  noStroke();
  translate(width/2, height/2);
  scale(0.5);
  fill(0);
  renderRadial(crisis, color(0));
  popMatrix();
  if (outting) {
    endRecord();
    outting = false;
  }
}

void renderRadial(Table t, color c) {
  int tot = t.getRowCount();
  int chunk = 4;
  int rtot = 0;
  float rad = 150;
  int[] view = new int[21];
  textFont(mono);
  for (int i = 0; i < tot; i++) {
    float theta = map(i, 0, tot, start, TAU);
    int count = t.getRow(i).getInt("count");

    //fill views
    if (i > 10 && i < tot - 10) {
      for (int j = 0; j < view.length; j++) {
        view[j] = t.getRow(i - 10 + j).getInt("count");
      }
    }
    //if (i % 51 == 0) count *= 0.3;
    rtot += count;
    if (i % chunk == chunk - 1) {
      pushMatrix();
      rotate(theta);
      translate(0, -rad);
      fill(c, random(150, 230));
      rect(0, 0, 3, -rtot * 0.3);

      //fill(255);
      //text(i,0,0);
      if (frameCount == 1) println(i);
      if (max(view) == count || i == tot - 1 || i == 1863 || i == 1867 || i == 1295 || i == 1275) {
        try {
          if (i == 1873) fill(#FFFF00);
          translate(0, -rtot * 0.3);
          rotate(-PI/2);
          textSize(12);
          text(t.getRow(i).getString("quote1"), 0, 3);
        } 
        catch (Exception e) {
        }
      }
      popMatrix();
      rtot = 0;
    }
  }
}

Table loadData(String _file) {
  Table t = loadTable("../data/" + _file, "header");
  return(t);
}

void keyPressed() {
  if (key == 'o') outting = true;
}