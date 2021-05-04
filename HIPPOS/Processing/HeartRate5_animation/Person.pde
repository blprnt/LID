class Person {
  String name;
  ArrayList<Record> records = new ArrayList();

  PVector pos = new PVector();
  PVector tpos = new PVector();

  float currentRate = 1.5;
  float targetRate = 1.0;

  int binSize = 5;

  int c = 0;
  int tailLength = 2000 / binSize;
  float[] avBin = new float[binSize];
  float[] avs = new float[tailLength];
  long[] tavs = new long[tailLength];


  void update() {
    pos.lerp(tpos, 0.4); 
    currentRate = lerp(currentRate, targetRate, 0.1);
    if (c < records.size() - 1) {
      targetRate = records.get(c).hr;
      try {
        while (records.get (c).timeStamp < currentTime) {
          bin();
          c++;
        }
      } 
      catch(Exception e) {
      }
    }

    if (c >= records.size()) c = records.size() - 1;

    //if (c == records.size()) c = 0;
  }

  void render() {
    pushMatrix();

    translate(pos.x, pos.y);

    pushMatrix();

    rotate(-0.5);

    renderTail();
    stroke(255, 50);
    //line(-30, 0, 1000, 0);
    popMatrix();

    fill(colorFromHR(currentRate));



    noStroke();
    ellipse(0, 0, sqrt(currentRate) * 30, sqrt(currentRate) * 30);

    fill(255);
    textFont(label);
    textAlign(CENTER);
    textSize(18);
    text(name, 0, 50);

    Date d = records.get(c).time;
    //text(d.toString(), 0, 60);


    popMatrix();
    colorMode(RGB);
  }

  void bin() {

    if (c % binSize == 0) {
      float t = 0;
      for (int i = 0; i < avBin.length; i++) {
        t+= avBin[i];
      }
      if (c < tailLength * binSize) {
        avs[floor(c/binSize)] = t / binSize;
        tavs[floor(c/binSize)] = records.get(c).timeStamp;
      }
    }
    if (c < tailLength * binSize) avBin[c % binSize] = records.get(c).hr;
  }

  void renderTail() {



    //Short tail
    colorMode(RGB);
    int count = 0;
    for (int i = 0; i < tailLength; i++) {
      int ii = c - i;
      if (ii >= 0) {
        Record r = records.get(ii);
        float a = map((r.hr), 0, (2), 5, 200);
        float s = map((r.hr), 1, (2), 0, 30);
        stroke(255, a);
        //ellipse(count * 5, -s, 3, 3);
        //line(count * 5, 3, count * 5, s);
      }
      count ++;
    }



    //Long tail
    count = 0;
    colorMode(RGB);
    for (int i = 0; i < tailLength; i++) {

      float hr = avs[i];
      float a = map((hr), 0.5, (3), 5, 450);
      float s = map((hr), 0.5, (3), 0, 650);

      //fill(a, 255, 255);
      color col = colorFromHR(hr);
      fill(col);
      //noStroke();
      stroke(255);
      //ellipse(count * 5, -s, 3, 3);
      //float x = map((float) tavs[i], (float) startTime, (float) endTime, 0, 1000);
      //float x = ((float) (tavs[i] - startTime) / (float) (endTime - startTime)) * 1000;
      if (s > 0) {
        float rad = 50;
        float th = map(tavs[i], startTime, endTime, 0, TAU) ;//+ PI/2;
        //float th = map();//((float) (tavs[i] - startTime) / (float) (endTime - startTime)) * TAU;
        //println(i + ":" + tavs[i] + ":" + th);
        float x = cos(th) * rad;
        float y = sin(th) * rad;
        pushMatrix();
        translate(x, y);
        //rotate((th * 1.1) + PI/2);
        rotate(th + PI/2);
        //rectMode(CENTER);
        rect(0, 0, 3, -s);
   
        popMatrix();
      }

      count ++;
    }
  }
}