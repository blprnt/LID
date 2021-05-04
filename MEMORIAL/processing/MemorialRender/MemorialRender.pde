import java.util.Collections;

PGraphics canvas;

String dataPath = "../../data/";
String imagePath = "../../images/";

ArrayList<MemName> allNames = new ArrayList();
MemPool southPool = new MemPool();
MemPool northPool = new MemPool();

HashMap<String, String> salaryMap = new HashMap();

void setup() {
  size(1200, 800, P2D);
  smooth(4);
  canvas = createGraphics(3250, 4250, JAVA2D);
  loadSalaries(dataPath + "salaries.json");
  loadNames(dataPath + "memdata-clean.tsv");
  northPool.calcPaths();
  southPool.calcPaths();
}

void draw() {
  background(30);


  MemPool pool = northPool;

  pushMatrix();
  translate(width/2 - 200, 200);
  if (frameCount == 1) pool.render(g);
  popMatrix();



  pool.renderFlat(g);

  fill(255,150);
  noStroke();
  //pool.renderCurve(northPool.salaryPoints);
  pool.renderInnerRays(north);

  fill(255, 255, 0, 150);
  noStroke();
  //pool.renderCurve(northPool.adjPoints);

  fill(0);
  translate(width/2 - 200, 200);
  //rect(0, 10, 370, 370);
}

void loadNames(String path) {
  Table nTable = loadTable(path, "tsv");
  for (int i = 0; i < nTable.getRowCount(); i++) {
    TableRow tr = nTable.getRow(i);
    MemName mn = new MemName().fromTableRow(tr);
    if (mn.poolPosition > 0) {
      allNames.add(mn);
      (mn.isNorth ? northPool:southPool).addName(mn);
    }
  }  
  southPool.sortPanels();
  northPool.sortPanels();
}


void loadSalaries(String path) {
  JSONArray salaries = loadJSONArray(path);
  for (int i = 0; i < salaries.size(); i++) {
    JSONObject sal = salaries.getJSONObject(i);
    salaryMap.put(sal.getString("job"), sal.getString("salary"));
  }
}

void keyPressed() {
  if (key == 'o') {
  }
}