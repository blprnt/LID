class MemName implements Comparable {
  String name;
  String job;
  int adjCount;
  int sal;


  PVector panelPos = new PVector();

  String panelID;
  int panelNum = -1;

  boolean isNorth = false;
  float poolPosition = -1;

  MemPool pool;

  MemName() {
  }

  MemName fromTableRow(TableRow tr) {
    name = tr.getString(1);
    job = tr.getString(2);

    //This is super hacky but it's what had to happen
    //find the index of the panel position
    int pp = 0;
    int lc = 0;
    while (tr.getString(pp).indexOf("-") != 1 && lc < 6) {
      pp++;
      lc++;
    }


    //println(name);
    panelID = tr.getString(pp);
    adjCount = tr.getInt(pp + 1);

    panelPos.x = tr.getFloat(pp + 2);
    panelPos.y = tr.getFloat(pp + 3);

    // println(panelID);
    isNorth = panelID.indexOf("N") != -1;

    try {
      int poolCount = int(panelID.split("-")[1]);
      panelNum = poolCount;
      poolPosition = poolCount + (panelPos.x / 1000);
    } 
    catch(Exception e) {
    }

    return(this);
  }

  void setLengths() {
    //println(job);
    try {
      sal = int(salaryMap.get(job).replaceAll(",", "")) * 2;
      PVector l = new PVector(sal/1000, adjCount * 100);
      pool.lengthMap.put(this, l);
    } 
    catch (Exception e) {
      println("MISSING: " + job);
    }
  }

  int compareTo(Object b) {
    return(int(1000 * (this.poolPosition - ((MemName) b).poolPosition)));
  }
}