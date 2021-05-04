//COURSE STUFF

ArrayList<PVector> filledPoints = new ArrayList();
ArrayList<PVector> screenPoints = new ArrayList();

void putCourseOnScreen() {
  float heading = 0;
  float speed = 18;
  PVector pos = new PVector(250, 100);
  float turn = PI/13;
  float turnLimit = PI;
  float turnTotal = 0;
  
  float buffer = 130;


  float edge = 100;
  
  boolean out = false;

  int c =0 ;
  float nf = 0;
  while (!out) {
    screenPoints.add(new PVector(pos.x, pos.y, heading));
    PVector move = new PVector(cos(heading + ((noise(c * 0.01) - 0.5) * nf)) * speed, sin(heading + ((noise(c * 0.01) - 0.5) * nf)) * speed);
    pos = pos.add(move);

    if (heading < PI && pos.x > width - buffer && turnTotal < turnLimit ) {
      heading += turn;//(turn + (0.1 * noise(c * 0.01)));
      turnTotal += turn;
    } else if (heading > 0  && pos.x < buffer && turnTotal > -turnLimit) {
      heading -= turn;//(turn + (0.1 * noise(c * 0.01)));
      turnTotal -= turn;
    } else {
      turnTotal = 0;
    }
    out = (pos.y > height - 50);
    c++;
    
  }
}