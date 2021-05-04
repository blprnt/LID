class Entry {

  int citations;
  String[] countries;
  String dateString;
  String[] institutions;
  Date d;

  Entry() {
  }

  Entry fromJSON(JSONObject _j) {

    //println(_j);

    citations = _j.getInt("citedby-count");
    dateString = _j.getString("prism:coverDisplayDate");

    //Process date
    //28 May 2020
    //2020
    //September 2020
    int dn = dateString.split(" ").length;
    long inc;

    SimpleDateFormat sdf = null;
    d = new Date(0);
    try {

      switch(dn) {
      case 1:
        //2020
        sdf = new SimpleDateFormat("dd MM yyyy");
        d = sdf.parse(ceil(random(30)) + " " + ceil(random(12)) + " " + dateString);
        break;
      case 2:
        sdf = new SimpleDateFormat("dd MMMMM yyyy");
        d = sdf.parse(ceil(random(30)) + " " + dateString);
        inc = new Float(random(1000 * 60 * 60 * 24 * 30)).longValue();
        d = new Date(d.getTime() + inc);
        //September 2020
        break;
      case 3:
        sdf = new SimpleDateFormat("dd MMMMMM yyyy");
        d = sdf.parse(dateString);
        //28 May 2020
        break;
      }
    } 
    catch(Exception e) {

      println(e);
    }

    //println(dateString);
    //println(d);

    try {
      //println(_j);
      JSONArray affiliations = _j.getJSONArray("affiliation");
      countries = new String[affiliations.size()];
      institutions = new String[affiliations.size()];
      for (int i = 0; i < affiliations.size(); i++) {
        JSONObject ja = affiliations.getJSONObject(i);
        try {
          String a = ja.getString("affiliation-country");
          countries[i] = a;
          institutions[i] = ja.getString("affilname");
          if (!countryMap.containsKey(a)) {
           countryMap.put(a, "");
           //println("countryMap.put(" + a + ",\"\")");
          }
          //println(a);
        } 
        catch (Exception e) {
        }
      }
    } 
    catch (Exception e) {
      /*
      console.log("Affiliation error");
      println(e);
      */
    }


    return(this);
  }
}