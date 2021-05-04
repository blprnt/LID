import processing.pdf.*;

ArrayList<Company> allCompanies = new ArrayList();
HashMap<String, Company> companyMap = new HashMap();

ArrayList<Territory> allTerritories = new ArrayList();
HashMap<String, Territory> territoryMap = new HashMap();

ArrayList<DataCenter> allDataCenters = new ArrayList();

int seed = 0;
int tindex = 0;

PFont label;
PFont mono;

color red = #7D312E;
color beige = #A77268;

boolean outting = false;


void setup() {
  randomSeed(2);
  size(1400,800,P3D);
  smooth(4);
  
  label = createFont("Montserrat-Bold", 36);
  mono = createFont("AndaleMono", 36);
     
  
  loadData("datacenters_native.csv");
  for (Company c:allCompanies) {
   c.init(); 
  }
  
  for (Territory t:allTerritories) {
   t.init(); 
  }
  
   java.util.Collections.sort(allTerritories);
   java.util.Collections.reverse(allTerritories);
  
}
 
void draw() {
  randomSeed(seed);
  background(30,20,20);
  
  fill(255);
  text(allTerritories.get(tindex).name, 50, 50);
  
  if (outting) {
   beginRecord(PDF,  "outs/" + allTerritories.get(tindex).name + ".pdf");
  }
  
  
  
  translate(width/2, height/2);
  scale(0.5);
  renderTerritory();
  
  if (outting) {
   endRecord();
   outting = false;
  }
}

void renderTerritory() {
 pushMatrix();
    territoryMap.get(allTerritories.get(tindex).name).render();
  popMatrix(); 
}

void drawKey() {
 
  for (int i = 0; i < allTerritories.size(); i++) {
   fill(allTerritories.get(i).col);
   noStroke();
   rect(0,i * 20, 18, 18);
   text(allTerritories.get(i).name, 22, (i * 20) + 10);
  }
}


void drawGraph(Company c, int rad) {
  rad = int(sqrt(c.totalSqft) * 0.1);
  String[] theKeys = c.territoryDict.keyArray();
  int tot = c.totalSqft;
  float rot = 0;
  for (int i = 0; i < theKeys.length; i++) {
    String ter = theKeys[i];
    float th = map(c.territoryDict.get(ter), 0, tot, 0, TAU);
    fill(territoryMap.get(ter).col);
    arc(0,0,rad,rad,rot, rot + th);
    rot += th;
  }
}


void loadData(String _url) {
  Table t = loadTable(_url, "header");
  for (int i = 0; i < t.getRowCount(); i++) {
    TableRow tr = t.getRow(i);
    
    //Make the datacenter
    String name = tr.getString("Place") + ":" + tr.getString("Details");
    String corp = tr.getString("Company");
    String ter = tr.getString("NativeLand");
    int sqft = tr.getInt("Size");
    if (sqft == 0) sqft = int(random(100000,200000));
    DataCenter dc = new DataCenter(name, sqft);
    allDataCenters.add(dc);
    
    //Link to a company
    //Is there already a company? If not, make one.
    if (!companyMap.containsKey(corp)) {
      Company org = new Company(corp);
      allCompanies.add(org);
      companyMap.put(corp, org);
    }
    companyMap.get(corp).dataCenters.add(dc);
    companyMap.get(corp).totalSqft += dc.sqft;
    dc.company = companyMap.get(corp);
    
    
    //Link to a territory
    //Is there already a territory? If not, make one.
    if (!territoryMap.containsKey(ter)) {
      Territory land = new Territory(ter);
      allTerritories.add(land);
      territoryMap.put(ter, land);
    }
    territoryMap.get(ter).dataCenters.add(dc);
    territoryMap.get(ter).totalSqft += dc.sqft;
    
    dc.territory = territoryMap.get(ter);
    
    
  }
}

void keyPressed() {
 if (key == ' ') seed = frameCount; 
 if (keyCode == RIGHT) {
   tindex ++;
   seed++;
 }
 if (key == 'o') {
   outting = true;  
 }
 
}