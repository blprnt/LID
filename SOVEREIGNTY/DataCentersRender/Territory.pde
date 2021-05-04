class Territory implements Comparable {

  String name;
  int totalSqft = 0;
  ArrayList<DataCenter> dataCenters = new ArrayList();
  color col;

  HashMap<String, ArrayList<DataCenter>> companyMap = new HashMap();
  
  int gap = 5;
  int mainGap = 100;

  Territory(String _name) {
    name = _name;
    col = color(random(255), random(255), random(255));
  }

  void render() {
    
    pushMatrix();
    
    
    stroke(255);
    line(-300,0,300,0);
    line(0,-300,0,300);
    
    noStroke();
    fill(255,50);
    float rad = sqrt(totalSqft) * 0.4;
    ellipse(0,0,rad,rad);
    
    translate(mainGap/2, mainGap/2);
    
    
    
    color[] cols = {red, beige, #FFFFFF, #666666};
    int[][] libs = {{0, 1}, {1, 2}, {2, 3}, {3, 0}};
    for (int i = 0; i < allCompanies.size(); i++) {
      if (companyMap.containsKey(allCompanies.get(i).name)) {
        ArrayList<DataCenter> centerList = companyMap.get(allCompanies.get(i).name);
        int[] tots = new int[centerList.size()];
        for (int j = 0; j < tots.length; j++) {
          tots[j] = centerList.get(j).sqft;
        }
        Square[] squares = squarePack(tots, libs[i], gap, mainGap);

        int c = 0;
        for (Square s : squares) {
          fill(cols[i]);
          noStroke();
          s.render();
          //rect(s.pos.x, s.pos.y, s.size.x, s.size.y);          

          /*
          text(allCompanies.get(i).name, s.pos.x + 15, s.pos.y + 15);
          text(centerList.get(c).name, s.pos.x + 15, s.pos.y + 27);
          text(centerList.get(c).sqft, s.pos.x + 15, s.pos.y + 39);
          */
          c++;
        }
      }
    }
    
    popMatrix();
  }

  int compareTo(Object _b) {
    return(totalSqft - ((Territory) _b).totalSqft);
  }

  void init() {
    //Make company bins
    for (DataCenter d : dataCenters) {
      String n = d.company.name;
      if (!companyMap.containsKey(n)) {
        companyMap.put(n, new ArrayList());
      }
      companyMap.get(n).add(d);
    }

    for (Company c : allCompanies) {
      if (companyMap.containsKey(c.name)) {
        java.util.Collections.sort( companyMap.get(c.name) );
        java.util.Collections.reverse( companyMap.get(c.name) );
      }
      
    }
  }
}