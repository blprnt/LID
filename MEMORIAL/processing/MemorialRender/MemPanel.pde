class MemPanel {

  float panelWidth = 20;

  ArrayList<MemName> names = new ArrayList();
  MemPool pool;
  boolean added = false;
 

  color col;
  
  PVector screenPoint = new PVector();
  float rot;
  int sal;
  
  MemPanel() {
    col = color(random(255), random(255), random(255));
    
  }
  
  void renderDot() {
    stroke(col);
    point(0,0);
  }

  void render(PGraphics _g) {
    fill(255, 0, 0, 50);
    rect(0, 0, panelWidth, -10);

    for (int i = 0; i < names.size(); i++) {
      float x = map(i, 0, names.size(), 0, panelWidth);
      pushMatrix();
      translate(x, 0);
      translate(0, -10);

      //is there a salary?
      if (salaryMap.containsKey(names.get(i).job) && !names.get(i).job.equals("null")) {
        float salAdj = pool.adjLengthMap.get(names.get(i)).x;
        stroke(255,map(sal, 20000, 200000, 0, 255),0,100);
        line(0,0,0,-salAdj);
        pushMatrix();
          translate(0, -sal);
          fill(0);
          //text(names.get(i).job, 0, 0);
        popMatrix();
      }
      stroke(0,100);
      line(0, 0, 0, -names.get(i).adjCount * 10);
      popMatrix();
    }
  }
  
  void renderFlat() {
    rot = screenPoint.z;
    fill(255);
    rect(screenPoint.x, screenPoint.y, 10, 10);
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
      stroke(255,50);
      //line(x,y,x2, y2);
      
      //Adjacencies
      float adjAdj = pool.adjLengthMap.get(names.get(i)).y;
      reach = adjAdj;
      y2 = y + (sin(rot - PI/2) * reach);
      x2 = x + (cos(rot - PI/2) * reach);
      if (!added) pool.adjPoints.add(new PVector(x2, y2));
      stroke(255,255,0,50);
      //line(x,y,x2, y2);
      
    }
    added = true;
    
    
  }
  
  
}