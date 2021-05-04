class DataCenter implements Comparable {
  
 String name;
 Company company;
 int sqft;
 Territory territory;
 
 
 DataCenter(String _name, int _sqft) {
   name = _name;
   sqft = _sqft;
 }
 
 int compareTo(Object _b) {
   return(sqft - ((DataCenter) _b).sqft); 
  }
  
  
}