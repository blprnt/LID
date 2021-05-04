const appRoot = require('app-root-path');
const fs = require('fs'); 
const parse = require('csv-parse/lib/sync')
const assert = require('assert')
const locations = require(appRoot + '/data/locations.json');
const polyline = require( 'google-polyline' )


const googleMapsClient = require('@google/maps').createClient({
  key: 'AIzaSyDdnHBIWJEdwobMHH4p0wGV45EYEC5lz9g',
  Promise: Promise
});

var outs = [];
var canfield = [38.738695, -90.274060];
var catMap = {};
var locMap = {};

function loadLocations() {
  //Get local file
   console.log(appRoot + "/data/St_Louis_all.csv");
   fs.readFile(appRoot + "/data/St_Louis_all.csv", function(err, buf) { 
    processLocations(buf.toString()); 
  });
}

function processLocations(_text) {
  const records = parse(_text, {
    columns: true,
    skip_empty_lines: true,
    skip_lines_with_error: true
  })
  writeFile(records, appRoot + "/data/locations.json");
}


/*
 { name: 'Miracle Revival Center',
    place_id: 'ChIJIwht0_DN2IcRkhvmKyE4_rM',
    lng: '-90.445416',
    lat: '38.5809209',
    vicinity: '123 North Ballas Road, St. Louis',
    category: 'church',
    category_2: 'place_of_worship',
    category_3: 'point_of_interest',
    category_4: 'establishment' }

*/

function parseLocations() {
  for (var i = 0; i < locations.length; i++) {
    var l = locations[i];
    if (!catMap[l.category]) catMap[l.category] = [];
    catMap[l.category].push(l);
    //'38.632859,-90.4446535'
    locMap[l.lat + "," + l.lng] = l;
  }
  console.log("PARSE DONE");
}

function getRoutes(_list, _name, _mode) {

  outs = [];

  for (let i = 0; i < _list.length; i++) {

  googleMapsClient.directions({origin:starts[i], destination:canfield}).asPromise()
    .then((response) => {
    	console.log('success');
    	//console.log(response.json.routes[0].legs);
    	outs.push(response.json.routes[0]);
    	if (outs.length == _list.length) {
  	  	var path = appRoot + "/routes.json";
  	  	writeFile(outs, path);
      }
      //console.log(response.json.routes);
    })
    .catch((err) => {
    	console.log('fail');
      console.log(err);
    });
  }

}

var tot = 0;
var toGetNum = 0;
var currentCat;
var currentMode;

function getRoutesForCategory(_cat, _mode) {
  tot = 0;
  currentCat = _cat;
  currentMode = _mode;
  var toGet = catMap[_cat];
  toGetNum = toGet.length;
  for (var i = 0; i < toGet.length; i++) {
    addRoute(toGet[i], _mode)
  }
}

function fillPolyLines(_json) {
  //console.log(_json);
  for (var i = 0; i < _json.json.routes[0].legs.length; i++) {
    var steps = _json.json.routes[0].legs[i].steps;
    for (var j = 0; j < steps.length; j++) {
      steps[j].polyline.newPoints = polyline.decode(steps[j].polyline.points);
      //console.log(steps[j].polyline);
    }
  }
}

function addRoute(_json, _mode) {

  googleMapsClient.directions({origin:[_json.lat,_json.lng], destination:canfield, mode:_mode}).asPromise()
    .then((response) => {
      console.log('success' + tot);
      locMap[response.query.origin].routeData = response;
      fillPolyLines(response);
      tot ++;
      console.log(tot + ":" + toGetNum);
      if (tot == toGetNum) {
        console.log("DONE " + toGetNum);
        writeFile(catMap[currentCat], appRoot + "/data/routes/" + currentCat + currentMode + ".JSON");
      }
    })
    .catch((err) => {
      tot++;
      console.log('fail');
      console.log(err);
      if (tot == toGetNum) {
        console.log("DONE " + toGetNum);
        writeFile(catMap[currentCat], appRoot + "/data/routes/" + currentCat + currentMode + ".JSON");
      }
    });
}

function repairFile(url) {

    var fileContents = fs.readFileSync(url, 'utf8')

    try {
      var data = JSON.parse(fileContents);
      //console.log(data);
      for (var i = 0; i < data.length; i++) {
        var ro = data[i];
        //console.log(ro);
        if (ro.routeData) {
          //console.log(ro.routeData);
          fillPolyLines(ro.routeData);
        }
      }
      writeFile(data, url.replace("routes", "newroutes"));
    } catch(err) {
      console.error(err)
    }

}


function writeFile(json, path) {
	var json = JSON.stringify(json, null, 2);
	//Write
	console.log("WRITING." + json.length);
	//File prefix is defined on line 26
	fs.writeFile(path, json, 'utf8', function() {
		console.log("Saved JSON.");
	});
}

//parseLocations();
//console.log(catMap['church'].length)
//getRoutesForCategory('police', 'driving');
repairFile(appRoot + "/data/routes/" + "churchwalking.json");
repairFile(appRoot + "/data/routes/" + "mosquewalking.json");



