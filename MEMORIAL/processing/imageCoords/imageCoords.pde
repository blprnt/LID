import me.xdrop.fuzzywuzzy.*;

String dataPath = "../../data/";
String imagePath = "../../images/";

JSONArray jobs;
HashMap<String, String> jobMap = new HashMap();
ArrayList<String> validNames = new ArrayList();

PrintWriter pw;

void setup() {
  size(500, 500);

  jobs = loadJSONArray(dataPath + "jobsCNN.json");
  println("JOBS:" + jobs.size());
  for (int i = 0; i < jobs.size(); i++) {
    JSONObject jo = jobs.getJSONObject(i);
    String n = jo.getString("name");
    String j = jo.getString("job");
    validNames.add(n);
    jobMap.put(n, j);
  }
  pw = createWriter(dataPath + "memdata.csv");
  doImageCalc("guard5-700.json");
  doImageCalc("guard701-800.json");
  doImageCalc("guard2752-4100.json");
  doImageCalc("guard4100-4300.json");
  doImageCalc("guard4300-5000.json");
  pw.flush();
  pw.close();
  exit();
}

void draw() {
}

void doImageCalc(String file) {
  JSONArray people = loadJSONArray(dataPath + file);
  PImage img;
  for (int i = 0; i < people.size(); i++ ) {
    JSONObject p = people.getJSONObject(i);
    String imgString = p.getString("img");
    String id = split(imgString, "person_")[1].split(".png")[0];

    img = loadImage(imagePath + id + ".png");
    img.loadPixels();

    boolean first = false;
    int last = 0;

    int[] tl = {0, 0};
    int[] br = {0, 0};
    for (int j = 0; j < img.pixels.length; j++) {
      if (img.pixels[j] == color(255)) {
        if (!first) {
          first = true;
          tl[0] = (j % img.width);
          tl[1] = (int) Math.floor(j / img.width);
        } else {
          last = j;
        }
      }
    }

    br[0] = (last % img.width);
    br[1] = (int) Math.floor(last / img.width);

    String name = p.getString("name");
    String[] nameSplit = name.split(" ");
    String nameTrimmed = nameSplit[0] + " " + nameSplit[nameSplit.length - 1];
    String panel = p.getString("panel");
    String job = "unknown";
    try {
      job = jobMap.get(nameTrimmed);
      //if (i < 100) println(job);
      if (job == null) {
        //println("try:" + name);
        job = jobMap.get(name);
      }
      if (job == null) {
       String fuzzName = getFuzzyName(name); 
       job = jobMap.get(fuzzName);
       //println(name + ":" + fuzzName);
      }
    } 
    catch(Exception e) {
    }
    JSONArray adjList = p.getJSONArray("adjacencies");
    pw.println(id + "," + name + "," + job + "," + panel + "," + adjList.size() + "," + tl[0] + "," + tl[1] + "," + br[0] + "," + br[1]);
  }
}

String getFuzzyName(String matchName) {
  String outName = null;
  int bestScore = 0;
  for (String n:validNames) {
    int dist = FuzzySearch.tokenSortRatio(matchName, n);
    if (dist > 70 && dist > bestScore) {
     bestScore = dist;
     outName = n;
    }
  }
  return(outName);
}