// server.js
// where your node app starts

// we've started you off with Express (https://expressjs.com/)
// but feel free to use whatever libraries or frameworks you'd like through `package.json`.
const express = require("express");
const app = express();
const fs = require("fs");
const request = require("async-request");

const API_KEY = "6801efea100ddeb1d8601ff7957df5df";

let st = "congo rainforest";

//Elsevier test
// Read users.json file 
let endPoint = new URL("https://api.elsevier.com/content/search/scopus");
endPoint.searchParams.append("apiKey", API_KEY);
endPoint.searchParams.append("query", "TITLE-ABS-KEY(" + st + ")");


async function getData(_page) {
  let response = await request(endPoint.href);
  endPoint.searchParams.delete("start");
  endPoint.searchParams.append("start", _page * 25);
  console.log(endPoint.href);
  return(response.body);
}

async function dataChain() {

  var count = 0;
  var total = 0;
  var current = 0;
  var entries = [];
  while (count == 0 || (current * 25) < total ) {
    
    var d = await getData(current);
    var j = JSON.parse(d);
    total = j['search-results']['opensearch:totalResults'];
    current ++;
    console.log(total + ":" + j['search-results']['opensearch:startIndex']);
    entries = entries.concat(j['search-results']['entry']);
    console.log(entries.length);
    count++;
  }

    storeData(entries, "data/" + st + ".json");
  
} 

console.log("1.0");
dataChain();

const storeData = (data, path) => {
  try {
    fs.writeFileSync(path, JSON.stringify(data))
  } catch (err) {
    console.error(err)
  }
}




/*

app.use(express.static("public"));

// https://expressjs.com/en/starter/basic-routing.html
app.get("/", (request, response) => {
  response.sendFile(__dirname + "/views/index.html");
});

// listen for requests :)
const listener = app.listen(process.env.PORT, () => {
  console.log("Your app is listening on port " + listener.address().port);
});

*/
