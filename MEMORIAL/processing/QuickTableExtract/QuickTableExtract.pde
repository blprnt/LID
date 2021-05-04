String dataPath = "../../data/";
String imagePath = "../../images/";

HashMap<String, String> jobMap = new HashMap();

JSONArray ja = new JSONArray();
Table t = loadTable(dataPath + "memdata-clean2.tsv", "header,tsv");
for (int i = 0; i < t.getRowCount(); i++) {
 TableRow tr = t.getRow(i);
 String job = tr.getString(2);
 if (!jobMap.containsKey(job)) {
   JSONObject jo = new JSONObject();
   jo.setString("job", job);
   jobMap.put(job, job);
   ja.append(jo);
 }
}

saveJSONArray(ja, dataPath + "jobsalary.json");