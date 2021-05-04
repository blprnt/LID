int[] slist = {358000, 350000, 310000, 215500, 215500, 200000, 200000, 170000, 150000, 150000};

Square[] squares;

int seed = 0;


void setup() {
  size(800, 800);
  int[] libs = {2, 3};
  squares = squarePack(slist, libs, 3);
}

void draw() {
  background(0);
  randomSeed(seed);
  translate(width/2, height/2);
  
  stroke(255,0,0);
  line(0,-1000, 0, 1000);
  line(-1000, 0, 1000, 0);
  noStroke();
  
  int[] libs = {0, 1};
  squares = squarePack(slist, libs, 3);
  for (Square s : squares) {
    s.render();
  }
  
  int[] libs2 = {1, 2};
  squares = squarePack(slist, libs2, 3);
  for (Square s : squares) {
    s.render();
  }
  
  int[] libs3 = {2, 3};
  squares = squarePack(slist, libs3, 3);
  for (Square s : squares) {
    s.render();
  }
  
  int[] libs4 = {3, 0};
  squares = squarePack(slist, libs4, 3);
  for (Square s : squares) {
    s.render();
  }
}

Square[] squarePack(int[] _list, int[] libs, float gap) {
  Square[] returns = new Square[_list.length];
  for (int i = 0; i < _list.length; i++) {
    Square s = new Square();
    s.size.x = s.size.y = sqrt(_list[i]) * 0.1;
    returns[i] = s;
  }
  
  Square first = returns[0];
  switch("" + libs[0]) {
    case("0"):
    first.pos.y -= (first.size.y + gap);
    break;
    case("1"):
    break;
    case("2"):
    first.pos.x -= (first.size.x + gap);
    break;
    case("3"):
    first.pos.y -= (first.size.y + gap);
    first.pos.x -= (first.size.x + gap);
    break;
  }

  ArrayList<String> avails = new ArrayList();
  avails.add("0" + ":" + libs[0]);
  avails.add("0" + ":" + libs[1]);

  for (int i = 1; i < returns.length; i++) {
    Square s = returns[i];
    String a = avails.get(floor(random(avails.size())));
    avails.remove(a);
    Square base = returns[int(a.split(":")[0])];
    s.pos = base.pos.copy();
    String lib = a.split(":")[1];
    switch(lib) {
      case("0"):
      s.pos.y -= (base.size.y + gap);
      break;
      case("1"):
      s.pos.x += (base.size.x + gap);
      break;
      case("2"):
      s.pos.y += (base.size.y + gap);
      break;
      case("3"):
      s.pos.x -= (base.size.x + gap);
      break;
    }
    avails.add(i + ":" + libs[0]);
    avails.add(i + ":" + libs[1]);
  }


  return(returns);
}

void keyPressed() {
  seed = frameCount;
}