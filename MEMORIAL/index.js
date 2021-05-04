const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  let currentURL;
  let personId = 0;
  let out = [];

  let saveGuard = 100;
  let se = [4300,5600];

  let pages = []; 
  for (let i = se[0]; i < se[1]; i++) {
    pages.push({
      "url":'https://names.911memorial.org/#lang=en_US&page=person&id=' + i,
      "id":i
    });
  }

  for (p of pages) {

    console.log("getting page for " + p.id + ". Waiting for 10 seconds.");
    await page.goto(p.url);
    await page.waitFor(10000);
    const scrape = await page.evaluate(() => {

      var r = {};

      try {
        console.log("WHATS");
        var affil = document.querySelector("#person_affiliation").innerText;
        var name = document.querySelector("#person_name").innerText;
        var panel = document.querySelector("#victim_panel").innerText;
        var adjobj = document.querySelectorAll(".adjacency_box");
        var src = document.querySelector("#mainPanelImage1").getAttribute("src");
        var adj = [];
        adjobj.forEach(a => {
          adj.push(a.innerText)
        })
        r = {"name":name, "panel":panel, "affiliation":affil, "adjacencies":adj, "img":src };
        //console.log(r);
     } catch(e) {
        console.log("CATCH");
     }

      return(r);

    }).catch(function(err) {
      console.log(err);
    });

    console.log(scrape);
    if (scrape.name) {
      out.push(scrape);
      console.log("fetch image:" + scrape.img);
      var viewSource = await page.goto(scrape.img);
        fs.writeFile("images/" + p.id + ".png", await viewSource.buffer(), function (err) {
        if (err) {
            return console.log(err);
        }
     });
    }

    if (p.id % saveGuard == 0) {
      console.log("write JSON");
      try {
        fs.writeFileSync("data/guard" + se[0] + "-" + p.id + ".json",JSON.stringify(out))
      } catch (err) {
       console.error(err)
      }
    }

   }

  await browser.close();

  console.log("write JSON");
    try {
      fs.writeFileSync("data/" + "full" + se[0] + "-" + se[1] + ".json",JSON.stringify(out))
    } catch (err) {
     console.error(err)
    }


})();


/*

const axios = require('axios');
const cheerio = require('cheerio');

axios('https://names.911memorial.org/#lang=en_US&page=person&id=2897')
  .then((response) => {
    console.log(response.data);
    const $ = cheerio.load(response.data);
    const n = $('#person_affiliation').text();
    console.log(n)

  })
  .catch(() => console.log('something went wrong!'))

  */


/*
const { Scraper, Root, OpenLinks, CollectContent, DownloadContent } = require('nodejs-web-scraper');
const fs = require('fs');
 
(async () => {
 

    config = {
        baseSiteUrl: `https://names.911memorial.org/`,
        startUrl: `https://names.911memorial.org/#lang=en_US&page=person&id=2897`,
        filePath: './images/',
        logPath: './logs/',
        delay: 100
    }
 
    var scraper = new Scraper(config);
 
    var root = new Root();
  
    var name = new CollectContent('div#person_name', { name: 'person'});
 
    //var employer = new CollectContent('#person_affiliation', { name: 'employer' });

    //var adjacencies = new CollectContent('.adjacency_box', { name: 'adjacencies'});


 
    root.addOperation(name);
   //root.addOperation(employer);
   //root.addOperation(adjacencies);
 
    await scraper.scrape(root);
    
    fs.writeFile('./pages.json', JSON.stringify(root.getData()), () => { });
})()
*/