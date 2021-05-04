
function setup() {
  createCanvas(1,1);
  randomSeed(0);
  var subs = loadJSON("subjects.json", onJSON);
}

function draw() {
  
}

function onJSON(data) {
  
  var thresh = 40;
  
  var list = [];
  for (var n in data) {
   if (data[n].count > thresh) list.push(data[n]);
  } 
  
  console.log(list.length);
  
  list.sort(function(a,b) {
    return(b.average - a.average);
  });
  
  for (var i = 0; i < list.length; i++) {
    //console.log(list[i].subject + ":" + list[i].average);
    var c = map(list[i].average, 2000, 4000, 0, 255);
    var end = i == list.length - 1 ? ".": ", "
    var d = createDiv(list[i].subject + end).addClass('sub').style('color', (random() < 0.06) ? '#B54743':'rgba(' + c + ',' + c + ',' + c + ',0)');
  }
  
 
}

