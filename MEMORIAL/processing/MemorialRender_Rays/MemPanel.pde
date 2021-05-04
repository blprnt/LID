class MemPanel {



  ArrayList<MemName> names = new ArrayList();
  MemPool pool;
  boolean added = false;

  int id;

  color col;

  PVector screenPoint = new PVector();
  float rot;
  int sal;

  int medianSalary = 0;
  int medianAdj = 0;

  int[] salaries;
  int[] adjs;

  int totalAdj = 0;

  MemPanel() {
    col = color(random(255), random(255), random(255));
  }


  void report(PrintWriter pw) {
    pw.println("-------:" + id);
    pw.println(medianSalary);
    pw.println(totalAdj);
    pw.println(medianAdj);
    for (int i = 0; i < names.size(); i++) {
      pw.println("  " + names.get(i).name + ":" + names.get(i).job + "    " + salaries[i] + "    " + adjs[i]);
    }
  }


  void calcMedians() {
    //find nonNulls;
    ArrayList<MemName> tempNames = new ArrayList();
    for (MemName mn : names) {
      if (!mn.job.equals("null")) {
        tempNames.add(mn);
      }
    }

    //File all sals, adjs
    if (names.size() > 0) {
      salaries = new int[names.size()];
      adjs = new int[names.size()];


      for (int i = 0; i < names.size(); i++) {
        try {
          salaries[i] = int(salaryMap.get(names.get(i).job).replaceAll(",", ""));
          adjs[i] = names.get(i).adjCount;
          totalAdj += names.get(i).adjCount;
        } 
        catch (Exception e) {
        }
      }


      int[] tsalaries = new int[tempNames.size()];
      int[] tadjs = new int[tempNames.size()];
      for (int i = 0; i < tempNames.size(); i++) {

        tsalaries[i] = int(salaryMap.get(tempNames.get(i).job).replaceAll(",", ""));
        tadjs[i] = tempNames.get(i).adjCount;
      }

      sort(tsalaries);
      sort(tadjs);
      medianSalary = tsalaries[round(tsalaries.length/2)];
      medianAdj = tadjs[round(tadjs.length/2)];
    }
    
    println(totalAdj);
  }

  void renderDot() {
    stroke(col);
    point(0, 0);
  }

  void render(PGraphics _g) {
    fill(255, map(medianSalary, 20000, 200000, 0, 255), 0);
    rect(0, 0, panelWidth, -10);

    for (int i = 0; i < names.size(); i++) {
      float x = map(i, 0, names.size(), 0, panelWidth);
      pushMatrix();
      translate(x, 0);
      translate(0, -10);

      //is there a salary?
      if (salaryMap.containsKey(names.get(i).job) && !names.get(i).job.equals("null")) {
        float salAdj = pool.adjLengthMap.get(names.get(i)).x;
        stroke(255, map(sal, 20000, 200000, 0, 255), 0, 100);
        line(0, 0, 0, -salAdj);
        pushMatrix();
        translate(0, -sal);
        fill(0);
        //text(names.get(i).job, 0, 0);
        popMatrix();
      } else {
        //println(id);
      }
      stroke(0, 100);
      line(0, 0, 0, -names.get(i).adjCount * 10);
      popMatrix();
    }
  }

  void renderFlat() {

    float mapAdj = map(medianAdj, 0, 3, 0, 255 );
    //float mapAdj = map(totalAdj, 0, 40, 0, 255 );
    float mapSalary = map(medianSalary, 10000, 200000, 0, 255);
    rot = screenPoint.z;

    //edges
    PVector center = new PVector();//new PVector(width/2, height/2);
    PVector l = screenPoint;
    PVector r = new PVector();

    r.y = screenPoint.y + (sin(rot) * (panelWidth - 2));
    r.x = screenPoint.x + (cos(rot) * (panelWidth - 2));

    //outer
    //square edges
    float mag = 1 + mapSalary/100;
    PVector r2 = r.copy();

    r2.sub(center).mult(mag).add(center);
    PVector l2 = l.copy();
    l2.sub(center).mult(mag).add(center);

    fill(0, mapSalary);
    noStroke();

    beginShape();
    vertex(l2.x, l2.y);
    vertex(r2.x, r2.y);
    vertex(r.x, r.y);
    vertex(l.x, l.y);
    endShape();

    pushMatrix();
    translate(r2.x, r2.y);
    float rot2 = atan2(r2.y - center.y, r2.x - center.x);
    rotate(rot2);
    fill(red);
    textFont(mono);
    textSize(18);
    if (medianSalary > 0) {
      text("$" + nfc(medianSalary), 10, 0);
    } else {
      text("---" + id, 50, 0);
    }
    popMatrix();

    fill(255);
    noStroke();

    //inner

    beginShape();
    vertex(l.x, l.y);
    vertex(r.x, r.y);
    vertex(center.x, center.y);
    endShape();


    fill(red, mapAdj);
    noStroke();


    //inner
    beginShape();
    vertex(l.x, l.y);
    vertex(r.x, r.y);
    vertex(center.x, center.y);
    endShape();

    //blocks
    pushMatrix();
    translate(screenPoint.x, screenPoint.y);
    rotate(screenPoint.z);
    //fill(255);
    //rect(1, 1, panelWidth - 2, -8);
    popMatrix();

    for (int i = 0; i < names.size(); i++) {
      //Salary
      float salAdj = pool.adjLengthMap.get(names.get(i)).x;
      float ext = map(i, 0, names.size(), 0, panelWidth);
      float reach = salAdj;
      float y = screenPoint.y + (sin(rot) * ext);
      float y2 = y + (sin(rot - PI/2) * reach);
      float x = screenPoint.x + (cos(rot) * ext);
      float x2 = x + (cos(rot - PI/2) * reach);
      if (!added) pool.salaryPoints.add(new PVector(x2, y2));
      stroke(255, 5);
      //line(x,y,x2, y2);

      //Adjacencies
      float adjAdj = pool.adjLengthMap.get(names.get(i)).y;
      reach = adjAdj;
      y2 = y + (sin(rot - PI/2) * reach);
      x2 = x + (cos(rot - PI/2) * reach);
      if (!added) pool.adjPoints.add(new PVector(x2, y2));
      stroke(255, 255, 0, 50);
      //line(x,y,x2, y2);
    }
    added = true;
  }
}