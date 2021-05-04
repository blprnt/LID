class MemPool {

  int totalPanels = 76;
  MemPanel[] panels = new MemPanel[totalPanels];
  ArrayList<MemName> names = new ArrayList(); 

  ArrayList<PVector> salaryLengths = new ArrayList();
  ArrayList<PVector> adjLengths = new ArrayList();

  ArrayList<PVector> salaryPoints = new ArrayList();
  ArrayList<PVector> adjPoints = new ArrayList();

  HashMap<MemName, PVector> lengthMap = new HashMap();
  HashMap<MemName, PVector> adjLengthMap = new HashMap();

  ArrayList<Integer>[] salStack = new ArrayList[4];
  ArrayList<String>[] titleStack = new ArrayList[4];

  MemPool() {
    for (int i = 0; i < 4; i++) {
      salStack[i] = new ArrayList(); 
      titleStack[i] = new ArrayList();
    }
    for (int i = 0; i < totalPanels; i++) {
      panels[i] = new MemPanel();
      panels[i].pool = this;
      panels[i].id = i;
    }
  }

  void report() {
    PrintWriter pw = createWriter("PoolReport.txt"); 
    for (int i = 0; i < panels.length; i++) {
      panels[i].report(pw);
    }
    pw.flush();
    pw.close();
  }

  void calcPaths() {
    int range = 15;
    for (int i = 0; i < names.size(); i++) {

      try {

        //println(names.get(i));
        names.get(i).sal = int(lengthMap.get(names.get(i)).x);
        float salTot = lengthMap.get(names.get(i)).x; 
        float adjTot = lengthMap.get(names.get(i)).y; 
        for (int j = 0; j < range; j++) {
          int li = i - j;
          if (li < 0) li += names.size();
          int ri = i + j;
          if (ri > names.size() - 1) ri -= names.size();
          salTot += lengthMap.get(names.get(li)).x; 
          adjTot += lengthMap.get(names.get(ri)).y;
        }
        adjLengthMap.put(names.get(i), new PVector(salTot / ((range * 2) + 1), adjTot / ((range * 2) + 1)));
      } 
      catch (Exception e) {
      }
    }
  }

  void renderDots() {
    pushMatrix();
    float rot = 0;
    for (int i = 0; i < totalPanels; i++) {
      panels[i].renderDot(); 


      translate(panelWidth, 0);
      if (i % 19 == 17 || i % 19 == 18) {
        rotate(PI/4);
        rot += PI/4;
      }
    }
    popMatrix();
  }

  void render(PGraphics _g) {
    pushMatrix();
    float rot = 0;
    for (int i = 0; i < totalPanels; i++) {
      fill(255, 0, 05);
      panels[i].render(_g);
      panels[i].screenPoint.x = modelX(0, 0, 0);
      panels[i].screenPoint.y = modelY(0, 0, 0);
      panels[i].screenPoint.z = rot;

      translate(panelWidth, 0);
      if (i % 19 == 17 || i % 19 == 18) {
        rotate(PI/4);
        rot += PI/4;
      }
    }
    popMatrix();
  }

  void renderCurve(ArrayList<PVector> points) {
    beginShape();
    int step = 10;
    for (int i = 0; i < points.size(); i+= step) {
      curveVertex(points.get(i).x, points.get(i).y);
    }
    endShape();
  }

  void renderFlat(PGraphics g) {
    for (int i = 0; i < totalPanels; i++) {
      fill(255, 255, 0);
      //ellipse(panels[i].screenPoint.x, panels[i].screenPoint.y, 5, 5);
      panels[i].renderFlat();
    }
  }

  void addName(MemName mn) {
    names.add(mn);
    if (mn.name.equals("Gerard J. Coppola")) {
      //println("GERRY");
      //println(mn.panelNum);
    }
    if (mn.panelNum > 0) {
      panels[mn.panelNum - 1].names.add(mn);
      mn.pool = this;
      mn.setLengths();
    }
  }

  void sortPanels() {
    Collections.sort(names);
    for (MemPanel p : panels) {
      Collections.sort(p.names); 
      p.calcMedians();
    }
  }
}