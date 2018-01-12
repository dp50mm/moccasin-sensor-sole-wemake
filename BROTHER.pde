//A "Brother" executes in essence one command, namely line(x1,y1,x2,y2) but writes the
//result not to the screen, but to a Tajima (.dst) file.
//Syntax description of file taken from KDE Community Wiki, "Tajima Ternary DST", "Header" and "Stitch".
//Coding of stitches adapted from
//github.com/Embroidermodder/Embroidermodder/blob/master/libembroidery/format-dst.c
//Attention: there is a scaling factor between pixels (Processing's unit) and millimeters (related to the 0.1mm of Tajima files.
//Attention: the screen image and the Tajima files appear mirrored along the x axis. 
//Need constant float PIXELSPERMILLIMETER (= 3.6???);
//Uses constant int YSIZE(eg = 845) to put things upside down, like Processing

//(C) Loe Feijs and TU/e 2014 - 2016

float PIXELSPERMILLIMETER = DPMM;//for Brother

class Brother {
      float xcor;    //current x coordinate, in pixels
      float ycor;   //idem y
      int red = 0;  //< 128
      int green = 0;//idem
      int blue = 0; //idem
      int MINX, MAXX;//units of .1mm
      int MINY, MAXY;//idem
      int xneedle;//embroidery needle, like xcor, but in .1mm units 
      int yneedle;//idem
      int stitchcount; 
      Stitch[] stitches;
      int bytecount;
      byte[] bytes; 
      String filename; 
      int MAXNRSTITCHES = 10 * 1000 * 1000;//eg 2 * 1000 * 1000
      Brother(PApplet p, int MINX, int MAXX, int MINY, int MAXY){
             xcor = 0.0;
             ycor = 0.0;
             this.MINX = MINX; this.MAXX = MAXX;
             bytecount = 0;
             bytes = new byte[512 + 3*MAXNRSTITCHES + 1]; 
             stitchcount = 0;//HERSTEL NAAR 0
             stitches = new Stitch[MAXNRSTITCHES];
             xneedle = floor(10 * xcor);
             yneedle = floor(10 * ycor);     
      }
      //only a few commands implemented at Tajima:
      //(PS the screen and pdf turtle work anyway)
      void setPosition(float x, float y){
           if (xcor == x && ycor == y) 
               return; //dont stitch for no reason
           xcor = x;
           ycor = y;
           int newxneedle = floor(10 * xcor/PIXELSPERMILLIMETER);
           int newyneedle = floor(10 * ycor/PIXELSPERMILLIMETER);
           Stitch s = new Stitch(newxneedle - xneedle, newyneedle - yneedle, true);
           s.mkMultiStitch(this);
           xneedle = newxneedle;
           yneedle = newyneedle;
      }
      void forward(float dx, float dy){
           xcor += dx;//work in pixels
           ycor += dy;//work in pixels
           int newxneedle = floor(10 * xcor/PIXELSPERMILLIMETER);//newxneedle in units of .1 mm
           int newyneedle = floor(10 * ycor/PIXELSPERMILLIMETER);//newyneedle in units of .1 mm
           Stitch s = new Stitch(newxneedle - xneedle, newyneedle - yneedle, false);
           s.mkMultiStitch(this);
           xneedle = newxneedle;
           yneedle = newyneedle;
      }
      void rect(float x, float y, float w, float h){
           line(x,y,x + w,y);
           line(x + w,y,x + w,y + h);
           line(x + w,y + h,x,y + h);
           line(x, y + h,x,y);      
      }
      void line(float x1, float y1, float x2, float y2){
           upsideDownLine(x1,YSIZE - y1,x2,YSIZE - y2);
      }
      void upsideDownLine(float x1, float y1, float x2, float y2){
           if  (x1 < 5 && y1 < 5) return; //dont go exiled corner
           if  (x1 != xcor || y1 != ycor){
                setPosition(x1,y1);
                float dx = x2 - x1;//just a tiny step first
                float dy = y2 - y1;//to get it going
                if (dx != 0) dx = dx/abs(dx);//-1 or +1
                if (dy != 0) dy = dy/abs(dy);
                forward(dx,dy);
                forward(x2 - x1 -dx, y2 - y1 - dy);   
           }
           else forward(x2 - x1, y2 - y1);   
       }
       
      void nextColor(){
            Stitch s = new Stitch(0,0,false);
            s.jumpstitch = false;
            s.colourstop = true;
            s.endpattern = false;
            s.dx = 0;
            s.dy = 0;
            this.stitches[this.stitchcount++] = s;
      }
      
      void stroke(int r, int g, int b){
           //if the color changes, we offer the next color (at least it changes)
           if (r != red || g != green || b != blue){
               Stitch s = new Stitch(0,0,false);
               s.jumpstitch = false;
               s.colourstop = true;
               s.endpattern = false;
               s.dx = 0;
               s.dy = 0;
               this.stitches[this.stitchcount++] = s;            
           }
           red = r;
           green = g;
           blue = b;
      }
      
      void ellipse(float xc, float yc, float ra, float rb){
           //xc,yc coordinates of centre
           //works like ellipseMode(RADIUS)
           int steps = 10;
           if (ra > 10 || rb > 10) steps = 20;
           float a = ra; //half-diameter horizontally
           float b = rb; //half-diameter vertically
           float dphi = 2*PI/steps;
           float prevx = xc + a;
           float prevy = yc;
           for (int i=0; i<steps + 1; i++){
                float x = xc + a * cos(i * dphi);
                float y = yc + b * sin(i * dphi);
                this.line(prevx,prevy,x,y);
                prevx = x;
                prevy = y;
           }
      }
      
      private void mkField(int offset, int size, String label, String text){
              if (label.length() != 3) 
                  println("ERROR HEADER LABEL");
              for (int i = offset; i < offset + size; i++)
                      bytes[i] = ' ';
              for (int i = 0; i < 3 ; i++)
                   bytes[offset + i] = byte(label.charAt(i));
              for (int i = 0; i < min(text.length(),size - 4); i++)
                   bytes[offset + 3 + i] = byte(text.charAt(i));    
              byte CR = 13; //^M, carriage return (?)   
              bytes[offset + size - 1] = CR;
      }
      private void mkField(int offset, int size, String label, int number){
              if (label.length() != 3) 
                  println("ERROR HEADER LABEL"); 
              if (stitchcount > 2147483647)
                  println("ERROR NUMBER EXCEEDS MAXINT"); 
              for (int i = offset; i < offset + size; i++)
                      bytes[i] = ' ';
              for (int i = 0; i < 3; i++)
                   bytes[offset + i] = byte(label.charAt(i));  
              int nrdigits = int(1 + (float)Math.log10(max(1,number)));
              if (3 + nrdigits + 1 > size) 
                  println("ERROR NUMBER SIZE EXCEEDS FIELD SIZE"); 
              String text = nf(number,nrdigits);
              for (int i = 0; i < nrdigits; i++)
                   bytes[offset + size - 1 - nrdigits + i] = byte(text.charAt(i));    
              byte CR = 13; //^M, carriage return (?) 
              bytes[offset + size - 1] = CR; 
      }
      private void mkFieldPlus(int offset, int size, String label, int number){
              //similar to mkField but adds a "+" after the ":"
              if (label.length() != 3) 
                  println("ERROR HEADER LABEL"); 
              if (stitchcount > 2147483647)
                  println("ERROR NUMBER EXCEEDS MAXINT"); 
              for (int i = offset; i < offset + size; i++)
                      bytes[i] = ' ';
              for (int i = 0; i < 3; i++)
                   bytes[offset + i] = byte(label.charAt(i)); 
              bytes[offset + 3] = '+'; 
              int nrdigits = int(1 + (float)Math.log10(max(1,number)));
              if (4 + nrdigits + 1 > size) 
                  println("ERROR NUMBER SIZE EXCEEDS FIELD SIZE"); 
              String text = nf(number,nrdigits);
              for (int i = 0; i < nrdigits; i++)
                   bytes[offset + size - 1 - nrdigits + i] = byte(text.charAt(i));    
              byte CR = 13; //^M, carriage return (?) 
              bytes[offset + size - 1] = CR; 
      }
      void mkHeader(String title){
           for (int i = 0; i<512; i++)
                bytes[i] = ' ';
           //offset 0, size 20, ASCII = "LA:" (label) Name padded with spaces 0x20, sometimes terminated with nul 0x00
           //Offset 20, Size 11, ASCII = "ST:" (stitch count) decimal number padded with zero or space
           //Offset 31, Size 7, ASCII = "CO:" (colour count) decimal number
           //Offset 38, Size 9, ASCII = "+X:" (maximum X extent) decimal number in tenths of a millimetre
           //Offset 47, Size 9, ASCII = "-X:" (minimum X extent) decimal number in tenths of a millimetre
           //Offset 56, Size 9, ASCII = "+Y:" (maximum Y extent) decimal number in tenths of a millimetre
           //Offset 65, Size 9, ASCII = "-Y:" (minimum Y extent) decimal number in tenths of a millimetre
           //Offset 74, Size 10, ASCII = "AX:" (needle end point X) "+" or "-" decimal number in tenths of a millimetre
           //Offset 84, Size 10, ASCII = "AY:" (needle end point Y) "+" or "-" decimal number in tenths of a millimetre
           //Offset 94, Size 10, ASCII = "MX:" (previous file needle end point X) "+" or "-" decimal number in tenths of a millimetre
           //Offset 104, Size 10, ASCII = "MY:" (previous file needle end point Y) "+" or "-" decimal number in tenths of a millimetre
           //Offset 114, Size 10, ASCII = "PD:" (previous file) "******" if single file
           //Offset 124, Size 4, ASCII = 0x1a 0x20 0x20 0x20 or 0x1a 0x00 0x00 0x00 end of header data
           //Offset 128, Size 384, ASCII = spaces 0x20 or sometimes contains colour information  
           byte CR = 13; //^M, carriage return (?) 
           mkField( 0,20,"LA:",title);
           mkField(20,11,"ST:",stitchcount);
           mkField(31,7,"CO:",0);
           mkField(38,9,"+X:",int(10 * PIXELSPERMILLIMETER * 210));//ASSUMPTION: A4 LANDSCAPE
           mkField(47,9,"-X:",0);
           mkField(56,9,"+Y:",int(10 * PIXELSPERMILLIMETER * 297));//ASSUMPTION: A4 LANDSCAPE
           mkField( 65, 9,"-Y:",0);//not implemented
           mkFieldPlus( 74,10,"AX:",0);//not implemented
           mkFieldPlus( 84,10,"AY:",0);//not implemented
           mkFieldPlus( 94,10,"MX:",0);//not implemented
           mkFieldPlus(104,10,"MY:",0);//not implemented
           mkField(114,10,"PD:","******");
           byte SUB = 26;//^Z aka byte(\u001A)
           bytes[124] = SUB;
           bytecount = 512;      
      }
      void beginRecordBrother(String fn){
           //fn defines dst file
           filename = fn;
           //we do the dst later, at endRecord
      }
      void endRecordBrother(){
           //finalise header bytes:
           mkHeader(filename);
           //finalise stitches bytes:
           for (int i = 0; i < stitchcount; i++)
                stitches[i].insert(this);
           //add one more "endofpattern" stitch:
           Stitch s = new Stitch(0,0,false);
           s.endpattern = true;
           s.insert(this);
           //repack everything for saving:
           byte[] finalbytes = new byte[512 + 3*stitchcount + 1]; 
           for (int i = 0; i < 512 + 3*stitchcount; i++)
                finalbytes[i] = bytes[i];
           //add a final ^Z and save:
           byte SUB = 26;
           finalbytes[512 + 3*stitchcount] = SUB;
           saveBytes(filename , finalbytes);
      }
}//end class Brother
