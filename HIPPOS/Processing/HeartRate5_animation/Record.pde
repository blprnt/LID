/*

{
            "properties": {
                "VerticalSpeed": 0, 
                "DateTime": "2014-08-21T08:55:13+0200", 
                "t_utc": 1408604113, 
                "Temperature": 299.65, 
                "Altitude": 900, 
                "Distance": 0, 
                "SeaLevelPressure": 101070, 
                "ContentType": "ambit", 
                "Time": 0.017, 
                "SampleType": "periodic", 
                "EnergyConsumption": 83.73599999999999, 
                "Person": "Steve", 
                "HR": 1.35
            }, 
            "type": "Feature", 
            "id": 815490, 
            "geometry": null
        }, 

*/

class Record {
  
  float hr = 0;
  Date time;
  long timeStamp;
 
  Record fromJSON(JSONObject props) {
   timeStamp = props.getLong("t_utc") * 1000;
   time = new Date(timeStamp);
   try {
   hr = props.getFloat("HR");
   } catch (Exception e){
     
   }
   return(this); 
  }
  
}