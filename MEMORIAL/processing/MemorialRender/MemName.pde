class MemName implements Comparable {
 String name;
 String job;
 int adjCount;

 
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
   panelID = tr.getString(3);
   adjCount = tr.getInt(4);
   
   panelPos.x = tr.getFloat(5);
   panelPos.y = tr.getFloat(6);
   
   isNorth = panelID.indexOf("N") != -1;
   
   try {
     int poolCount = int(panelID.split("-")[1]);
     panelNum = poolCount;
     
     poolPosition = poolCount + (panelPos.x / 1000);
   } catch(Exception e) {
     
   }
   
   
   return(this);
 }
 
 void setLengths() {
   int sal = int(salaryMap.get(job).replaceAll(",","")) * 2;
   PVector l = new PVector(sal/1000, adjCount * 100);
   pool.lengthMap.put(this, l);
 }
 
 int compareTo(Object b) {
  return(int(1000 * (this.poolPosition - ((MemName) b).poolPosition))); 
 }
}