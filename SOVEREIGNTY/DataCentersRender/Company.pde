class Company {
 String name;
 ArrayList<DataCenter> dataCenters = new ArrayList();
 int totalSqft = 0;
 
 IntDict territoryDict = new IntDict();
 
 Company(String _name) {
   name = _name;
 }
 
 void init() {
   //Calc the bins for territories
   // territory: sqft
   for (DataCenter dc:dataCenters) {
     territoryDict.add(dc.territory.name, dc.sqft);
   }
   
 }
}