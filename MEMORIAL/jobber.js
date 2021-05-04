let {PythonShell} = require('python-shell');
const serp = require("serp");
const request = require("request");
const cheerio = require('cheerio');
const puppeteer = require('puppeteer');
const fs = require('fs');

let pyshell = new PythonShell('python/jobfinder.py');

const getAllCNN = async () =>  {

	let people = [];

	//make the url list
	let URLs = ["http://www.cnn.com/SPECIALS/2001/memorial/lists/by-name/index.html"];
	for (var i = 0; i < 111; i++ ) {
		URLs.push("http://www.cnn.com/SPECIALS/2001/memorial/lists/by-name/page" + (i + 1) + ".html");
	}

	const browser = await puppeteer.launch();
	const page = await browser.newPage();


	await asyncForEach(URLs, async (url) => {

	 	// open the browser and prepare a page
	  
	  // open the page to scrape
	  await page.goto(url);
	  console.log("LOAD PAGE:" + url);

	  // execute the JS in the context of the page to get all the links
	  const links = await page.evaluate(() => 
	    // let's just get all links and create an array from the resulting NodeList
	     Array.from(document.querySelectorAll("td a")).map(anchor => [anchor.href, anchor.textContent]));

	  // output all the links
	  await asyncForEach(links, async (plink) => {
	  	 if (plink[0].indexOf('/people/') != -1) {
	  	 await page.goto(plink[0]);
	  	 const plinks = await page.evaluate(() => 
	    // let's just get all links and create an array from the resulting NodeList
	     Array.from(document.querySelectorAll(".recordentry")).map(anchor => [anchor.href, anchor.textContent]));
	  	 
	  	 let name = plinks[0];
	  	 let job = plinks[3];

	  	 people.push({"name":name[1].trim(), "job":job[1].trim()});

	  	 //console.log({"name":name[1].trim(), "job":job[1].trim()});
	  	 
	  	}
	  }).catch(function(err) {
	  	console.log("ERROR:" + err)
	  });

}).catch(function(err) {

})

  // close the browser 
  await browser.close();

  //write the json
  console.log("write JSON");
      try {
        fs.writeFileSync("data/jobsCNN.json",JSON.stringify(people))
      } catch (err) {
       console.error(err)
      }
}

async function asyncForEach(array, callback) {
  for (let index = 0; index < array.length; index++) {
    await callback(array[index], index, array);
  }
}

async function jobify(url) {

	let json = require(url).slice(0,1);

	console.log(json);

	
	json.forEach(person => {
		resolveTitle(person.name);
	});
	
}

async function resolveTitle(name) {
	console.log("resolve:" + name);
	let splits = name.split(" ");
	let shortName = splits[0] + " " + splits[splits.length - 1];
	console.log("short:" + shortName)
	//Google search for the name on the CNN memorial site
	var options = {
	  host : "google.com",
	  qs : {
	    q : name,
	    as_sitesearch: "http://www.cnn.com/specials/2001/memorial/"
	  },
	  num : 10,
	  delay : 2000,
	};
	 
	
	const links = await serp.search(options);

	/*

	//Visit the first result and use Cheerio to get the title
	let surl = links[0].url;
	var t = await getTitle(surl);

 	return(t);
 	*/

};


async function getTitle(surl) {

  try {
    request({
		    method: 'GET',
		    url: surl
		}, (err, res, body) => {

		    if (err) return console.error(err);

		    let $ = cheerio.load(body);

		    let titleText = $('.recordentry');

		    let title = $(titleText)[3].children[0].data;

		    var t = processTitle(titleCase(title));
		    return(t);
		    
	});
  } catch(err) {
    alert(err); // TypeError: failed to fetch
  }
}




async function processTitle(t) {
	console.log("Processing title:" + t);

	pyshell.send(t);

	pyshell.on('message', function (message) {
	  // received a message sent from the Python script (a simple "print" statement)
	  console.log("Message from python:" + message);
	  return(eval(message)[0].match);
	});


	/*


	let options = {
	  args: [t]
	};


 
	PythonShell.run('python/jobfinder.py', options, function (err, results) {
	  if (err) throw err;
	  // results is an array consisting of messages collected during execution
	  //console.log('results: %j', results);
	  return(eval(results)[0].match)
	});
	*/

}

var fromCharCode = String.fromCharCode;
var firstLetterOfWordRegExp = /\b[a-z]|['_][a-z]|\B[A-Z]/g;

function toLatin1UpperCase(x){ // avoid frequent anonymous inline functions
    var charCode = x.charCodeAt(0);
    return charCode===39 ? x : fromCharCode(charCode^32);
}
function titleCase(string){
    return string.replace(firstLetterOfWordRegExp, toLatin1UpperCase);
}

//jobify(__dirname + "/data/guard701-800.json");
getAllCNN();

