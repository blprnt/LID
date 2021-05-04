//https://www.simplyhired.com/salaries/search?q=security+officer&l=New%20York,%20NY

const request = require("request");
const cheerio = require('cheerio');
const puppeteer = require('puppeteer');
const fs = require('fs');

const joblist = require(__dirname + "/data/jobsalary.json");

let browser, page;

const getSalaries = async(jobList) =>  {
	outSals = [];

	browser = await puppeteer.launch();
	page = await browser.newPage();

	 await asyncForEach(jobList, async (job) => {
	 	let s = await getSalary(job.job);
	 	await page.waitFor(10000)
	 	outSals.push({"job": job.job, "salary":s});
	  }).catch(function(err) {
	  	console.log("ERROR:" + err)
	  });

	  // close the browser 
  await browser.close();

  //write the json
	  	  console.log("write JSON");
	      try {
	        fs.writeFileSync("data/salaries.json",JSON.stringify(outSals))
	      } catch (err) {
	       console.error(err)
	      }

  

}

const getSalary = async (jobName) =>  {

	console.log("Getting salary for :" + jobName);
	let s = "unknown";

	try {
		let url = "https://www.simplyhired.com/salaries/search?q=" + jobName + "&l=New%20York,%20NY";
		await page.goto(url);

		const salary = await page.evaluate(() => 
		     document.querySelector(".Salaries-average-salary").innerHTML);

		s = salary.split('$')[1].split("<")[0];


		if (outSals.length % 10 == 0) {

		  //write the json
	  	  console.log("write JSON");
	      try {
	        fs.writeFileSync("data/salaries.json",JSON.stringify(outSals))
	      } catch (err) {
	       console.error(err)
	      }
		}
		console.log("Salary :$" + s);
	} catch (err) {

	}
	return(s);

	
}

async function asyncForEach(array, callback) {
  for (let index = 0; index < array.length; index++) {
    await callback(array[index], index, array);
  }
}


//let sals = ["accountant", "CEO", "Security Guard"];
getSalaries(joblist);