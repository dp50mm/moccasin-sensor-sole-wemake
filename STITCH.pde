int PREFSTITCH = 20; //preferred substitch size, eg 20
      
//class Stitch, essential for class Stitchway
//big stitches, ie > MINSTITCH (in .1mm) to be split in substeps
//, the substeps being somehwere between 0 and PREFSTITCH.
//note that the units dx and dy in stitching are .1 mm
//whereas the Stitchway and Oogway notation xcor() and ycor() is in mm (I hope).

class Stitch {
      boolean jumpstitch = false;
      boolean colourstop = false;
      boolean endpattern = false;
      int dx;
      int dy;
      Stitch(int dx, int dy, boolean jmp){
             this.dx = dx;
             this.dy = dy;
             this.jumpstitch = jmp;
             //print("new Stitch( "); print(dx); print(" , "); print(dy); print(" , "); print(jmp); println(" );");
      }
      private byte setbit(int pos){
              return (byte)(1 << pos);
      }
      void insert(Brother t){
           //add to bytes of t at bytecount
           //println("attempting insert(t) ");
           Byte b0 = 0;
           Byte b1 = 0;
           Byte b2 = 0;
           if (dx > 121 || dx < -121) 
               println("ERROR: dx MUST BE BETWEEN -121 AND 121");
           if (dy > 121 || dy < -121) 
               println("ERROR: dy MUST BE BETWEEN -121 AND 121");
           int prevdx = dx;
           int prevdy = dy;
           //encode ternary number:
           //thanks embroidermodder at github
           if (dx >= +41) { b2 += setbit(2); dx -= 81; }
           if (dx <= -41) { b2 += setbit(3); dx += 81; }
           if (dx >= +14) { b1 += setbit(2); dx -= 27; }
           if (dx <= -14) { b1 += setbit(3); dx += 27; }
           if (dx >=  +5) { b0 += setbit(2); dx -= 9; }
           if (dx <=  -5) { b0 += setbit(3); dx += 9; }
           if (dx >=  +2) { b1 += setbit(0); dx -= 3; }
           if (dx <=  -2) { b1 += setbit(1); dx += 3; }
           if (dx >=  +1) { b0 += setbit(0); dx -= 1; }
           if (dx <=  -1) { b0 += setbit(1); dx += 1; }
           //now idem for y
           if (dy >= +41) { b2 += setbit(5); dy -= 81; }
           if (dy <= -41) { b2 += setbit(4); dy += 81; }
           if (dy >= +14) { b1 += setbit(5); dy -= 27; }
           if (dy <= -14) { b1 += setbit(4); dy += 27; }
           if (dy >=  +5) { b0 += setbit(5); dy -= 9; }
           if (dy <=  -5) { b0 += setbit(4); dy += 9; }
           if (dy >=  +2) { b1 += setbit(7); dy -= 3; }
           if (dy <=  -2) { b1 += setbit(6); dy += 3; }
           if (dy >=  +1) { b0 += setbit(7); dy -= 1; }
           if (dy <=  -1) { b0 += setbit(6); dy += 1; }
           if (dx != 0 || dy != 0)
               println("CODING ERROR: TERNARY CODING WENT WRONG");
           //repair x and y:
           dx = prevdx;
           dy = prevdy;
           //two LSB only set in last byte:
           b2 |= (char) 3;
           //handle flags:
           if (jumpstitch == true)
               b2 |= 0x83;
           if (colourstop == true)
               b2 |= 0xC3;//??
           if (endpattern == true){
               b0 = byte( 0x00 );
               b1 = byte( 0x00 ); 
               b2 = byte( 0xF3 );
           }
           //print("Stitch.insert(t): bytecount = "); println(t.bytecount);
           t.bytes[t.bytecount++] = b0;
           t.bytes[t.bytecount++] = b1;
           t.bytes[t.bytecount++] = b2;
      }
      void mkMultiStitch(Brother t){
           //print("Stitch.mkMultiStitch(t): x,y,dx,dy = "); print(t.xcor()); print(","); print (t.ycor()); print(",");  print(dx); print(","); print (dy); println();
           //recursive multiple shooting
           if  (PREFSTITCH > 121) 
                println("ERROR: IMPOSSIBLE PREFSTITCH VALUE");
           if  (abs(dx) <= PREFSTITCH && abs(dy) <= PREFSTITCH)
                t.stitches[t.stitchcount++] = new Stitch(dx,dy,jumpstitch);
           else if (abs(dx) > abs(dy)){
                    //one well-directed small stitch, mostly x
                    int ddx = (dx > 0? PREFSTITCH : -PREFSTITCH);
                    int ddy = round((float(dy)/float(dx)) * ddx);
                    t.stitches[t.stitchcount++] = new Stitch(ddx,ddy,jumpstitch);
                    //and do the ret recursively
                    dx -= ddx;
                    dy -= ddy;
                    mkMultiStitch(t);

           } else { //abs(dy) > abs(x)
                    //one well-directed small stitch, mostly y
                    int ddy = (dy > 0? PREFSTITCH : -PREFSTITCH);
                    int ddx = round((float(dx)/float(dy)) * ddy);
                    t.stitches[t.stitchcount++] = new Stitch(ddx,ddy,jumpstitch);
                    //and do the ret recursively
                    dx -= ddx;
                    dy -= ddy;
                    mkMultiStitch(t);
           }
      }
}//end class Stitch
