/*

 ITP Data Art
 NYTimes Article Search v2 Simple Example
 
 **Note - you must put your API key in the first field for this to work!
 
 Article Search v2 docs: http://developer.nytimes.com/docs/read/article_search_api_v2 
 
 */

import java.util.Calendar;


String apiKey = "EyrQvpwBt7CXAsFvWnEKbiD6fkksblIX";
String baseURL = "http://api.nytimes.com/svc/search/v2/articlesearch.json?";

String term = "crisis";

Calendar cal;

int queryDelay = 1200;

void setup() {
  size(1280, 720, P3D);
  smooth(8);
  background(255);

  cal = Calendar.getInstance();
  cal.set(1999, 0, 1);

  int c = 0;
  String q = term;

  Table outTable = new Table();
  outTable.addColumn("startDate", Table.STRING);
  outTable.addColumn("count", Table.INT);
  outTable.addColumn("quote1", Table.STRING);
  outTable.addColumn("quote2", Table.STRING);
  outTable.addColumn("quote3", Table.STRING);

  while (cal.getTime().getTime() < Calendar.getInstance().getTime().getTime() && c < 10000) {
    String startString = "" + cal.get(Calendar.YEAR) + nf(cal.get(Calendar.MONTH) + 1, 2) + nf(cal.get(Calendar.DAY_OF_MONTH), 2);
    cal.roll(Calendar.WEEK_OF_YEAR, 1);
    
    c++;
    String endString = "" + cal.get(Calendar.YEAR) + nf(cal.get(Calendar.MONTH) + 1, 2) + nf(cal.get(Calendar.DAY_OF_MONTH), 2);

    ASResult r = doASearch(q, startString, endString);
    TableRow tr = outTable.addRow();
    tr.setString(0, startString);
    tr.setInt(1, r.hits);
    tr.setString(2, r.docs[floor(random(r.docs.length))].headline);
    
    if (cal.get(Calendar.WEEK_OF_YEAR) == 52) {
      saveTable(outTable, q + "-" + cal.get(Calendar.YEAR) + ".csv");
      cal.roll(Calendar.YEAR, 1);
      cal.set(Calendar.DAY_OF_YEAR, 1);
    }

    println("GOT WEEK FOR :" + endString);
    delay(queryDelay * 5);
  }

  saveTable(outTable, q + ".csv");


  /*
  //This function returns a list of integers, counting a search term per year
   //int[] issCounts = doASearchYears(term, 2014, 2015);
   int[] issCounts = doASearchMonths(term, 2016, 1,12);
   
   //Which we can draw a bar chart from:
   for (int i = 0; i < issCounts.length; i++) {
   fill(0,150);
   float x = map(i,0, issCounts.length,100, width - 100);
   float y = height - 100;
   float w = (width - 200)/issCounts.length;
   float h = -map(issCounts[i], 0, max(issCounts), 0, height - 200);
   rect(x, y, w, h);
   fill(255);
   pushMatrix();
   translate(x,y);
   rotate(PI/2);
   textSize(10);
   text(i + 1901, 0, 8);
   popMatrix();
   }
   
   //It's often useful to save data like this (so we don't have to call the API every time once we're visualizing)
   PrintWriter writer = createWriter("data/" + term + ".csv");
   for (int i:issCounts) writer.println(i);
   writer.flush();
   writer.close();
   */

  /*
  //There is really a lot more we can do with this.
   //Here, a search for 'bin laden' on the day he was killed
   ASResult osama = doASearch("bin laden", "20110502", "20110502");
   //Find out how many articles
   println(osama.hits);
   //Get the headline of the fourth one
   println(osama.docs[3].headline);
   //And a snippet from the second one
   println(osama.docs[2].snippet);
   //We can get access to any of the fields that are returned (see API docs). For example the URL to the first story:
   println(osama.docs[0].docJSON.getString("web_url"));
   //Or, a JSON list of the keywords associated with the story
   JSONArray keyWords = osama.docs[0].docJSON.getJSONArray("keywords");
   for(int i =0; i < keyWords.size(); i++) {
   JSONObject keyWord = keyWords.getJSONObject(i); 
   println(keyWord.getString("name"), keyWord.getString("value"));
   }
   */
}

void draw() {
}