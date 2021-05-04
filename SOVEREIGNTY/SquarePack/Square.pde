class Square {
   PVector pos = new PVector();
   PVector size = new PVector();
   
   //T,R,B,L
   int[] liberties = {0,0,0,0};
   
   Square() {
     
   }
   
   void render() {
    pushMatrix();
      translate(pos.x, pos.y);
      rect(0,0,size.x, size.y);
    popMatrix();
   }
}