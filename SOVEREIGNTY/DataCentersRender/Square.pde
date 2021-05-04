class Square {
  PVector pos = new PVector();
  PVector size = new PVector();

  ArrayList<Square> decorations = new ArrayList();

  //T,R,B,L
  int[] liberties = {0, 0, 0, 0};

  Square() {
  }

  void render() {
    pushMatrix();
    translate(pos.x, pos.y);
    rect(0, 0, size.x, size.y);
    for (Square d : decorations) {
      d.render();
    }
    popMatrix();
  }

  void decorate(int _lib) {

    int dnum = ceil(random(3));
    for (int i = 0; i < dnum; i++) {
      float w = 0;
      float h = 0;
      float x = 0;
      float y = 0;
      Square ds = new Square();
      switch(_lib) {
        //top
      case 0:
        w = random(size.x);
        h = random(size.y * 0.25);
        x = random(size.x - w);
        y = -h/2;
        break;
        
        //right
      case 1:
        h = random(size.y);
        w = random(size.x * 0.25);
        x = size.x - (w/2);
        y = random(size.y - h);
        break;

      case 2:
        //bottom
        w = random(size.x);
        h = random(size.y * 0.25);
        x = random(size.x - w);
        y = size.y - h/2;
        break;

      case 3:
        //left
        h = random(size.y);
        w = random(size.x * 0.25);
        x = - (w/2);
        y = random(size.y - h);
        break;
      }


      ds.pos.x = x;
      ds.pos.y = y;
      ds.size.x = w;
      ds.size.y = h;
      decorations.add(ds);
    }
  }


  boolean overlap(Square b) {
    PVector TR = b.pos.copy().add(new PVector(b.size.x, 0));
    PVector BR = b.pos.copy().add(new PVector(b.size.x, b.size.y));
    PVector BL = b.pos.copy().add(new PVector(0, b.size.y));
    PVector C = b.pos.copy().add(b.size.copy().mult(0.5));
    return(contains(b.pos) || contains(TR) || contains(BR) || contains(BL) || contains(C));
  }

  boolean contains(PVector v) {
    return((v.x >= pos.x && v.x < pos.x + size.x) && (v.y >= pos.y && v.y < pos.y + size.y));
  }
}

Square[] squarePack(int[] _list, int[] libs, float gap, float mainGap) {
  Square[] returns = new Square[_list.length];
  for (int i = 0; i < _list.length; i++) {
    Square s = new Square();
    float sq = sqrt(_list[i]) * 0.2;
    s.size.x = random(0.5 * sq, sq * 1.5);
    s.size.y = (sq * sq) / s.size.x;
    returns[i] = s;
  }

  Square first = returns[0];
  
  switch("" + libs[0]) {
    case("0"):
    first.pos.y -= (first.size.y + (mainGap));
    break;
    case("1"):
    break;
    case("2"):
    first.pos.x -= (first.size.x + (mainGap));
    break;
    case("3"):
    first.pos.y -= (first.size.y + (mainGap));
    first.pos.x -= (first.size.x + (mainGap));
    break;
  }

  ArrayList<String> avails = new ArrayList();
  avails.add("0" + ":" + libs[0]);
  avails.add("0" + ":" + libs[1]);

  for (int i = 1; i < returns.length; i++) {

    Square s = returns[i];

    boolean chk = false;
    String a = "";

    int tryCount = 0;

    ArrayList<String> tempAvails = new ArrayList();
    for (String as : avails) tempAvails.add(as);

    while (chk == false && tempAvails.size() > 0) {
      //if (tryCount > 0) println("try:" + tryCount);
      a = tempAvails.get(floor(random(tempAvails.size())));
      Square base = returns[int(a.split(":")[0])];

      //Shift the square to an available liberty
      s.pos = base.pos.copy();
      String lib = a.split(":")[1];
      switch(lib) {
        case("0"):
        s.pos.y -= (s.size.y + gap);
        break;
        case("1"):
        s.pos.x += (base.size.x + gap);
        break;
        case("2"):
        s.pos.y += (base.size.y + gap);
        break;
        case("3"):
        s.pos.x -= (s.size.x + gap);
        break;
      }

      chk = true;

      //Once it's shifted, check if it overlaps with anything else
      for (Square cs : returns) {
        //Go to every other square
        if (cs != s && chk) {
          //Check if this square overlap the others or if the others overlap it
          boolean tck = s.overlap(cs) || cs.overlap(s);
          //if we don't overlap in either case, set the boolean to get us out of here
          //println("overlap");
          if (tck) {
            chk = false;
          }
          //println(chk);
        }
      }

      //Overlapped so let's try again
      tryCount ++;
      tempAvails.remove(a);
      if (tempAvails.size() == 0) {
        println("Tried out");
      }
    }

    ArrayList<String> eAvails = new ArrayList();
    for (String es : avails) {
      if (!es.equals(a)) eAvails.add(es);
    }
    avails = eAvails;


    avails.add(i + ":" + libs[0]);
    avails.add(i + ":" + libs[1]);
  }

  //pass avails to decorations
  for (String s : avails) {
    int sq = int(s.split(":")[0]);
    int lib = int(s.split(":")[1]);
    returns[sq].decorate(lib);
  }


  return(returns);
}