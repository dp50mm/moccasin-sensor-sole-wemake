//Welcome to SOLEMAKER, version which saves in  file too
//(C) Loe Feijs, Troy Nachtigall and Bart Pruijmboom at TU/e 2016           
//move mouse and click at successive interesting points  
//first make contour, then insole seed points (type i)
//then, create tread insole points (t) and set density (d)
//and then stop + print (type p).



import megamu.mesh.*;
import processing.pdf.*;
import geomerative.*;
import AULib.*;

AUCurve MyCurve;
RShape grp;
RPoint[][] pointPaths;
RShape grp2; 
RPoint[][] pointPaths2;
String SVGShape2 = "Lonneke_Left3.svg";

float[][] insolePoints = new float[2000][2];
int nrInsolePoints = 0;

//a few utilities for generating filenames based on day and time:
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

//coding of the contour
final int MAXNRCOPOINTS = 2000;
float[][] coPoints = new float[MAXNRCOPOINTS][2];
int nrCoPoints = 0;

//coding of the insole
final int MAXNRINPOINTS = 2000;
float[][] inPoints = new float[MAXNRINPOINTS][2];
int nrInPoints = 0;

//coding of the insole
final int MAXNRTRPOINTS = 2000;
float[][] trPoints = new float[MAXNRTRPOINTS][2];
int nrTrPoints = 0;

final int numCoPointSteps = 70; //Number of points around the contour

PImage sole, empty;
PImage grid1, grid2, grid3, grid4;
PGraphicsPDF pdf;
PrintWriter txt;
Brother b;

import java.util.Locale;
float PIXELPITCH = 0.343*1.02;//Printed adjustment for the Prusa
float DPMM = 1/PIXELPITCH;//dots per mm (OLD WAS 2.834646, then .277)

int sensorsX=29;
int sensorsY=61;
float sensorSize = (300/60) * DPMM;
int xSizeBuildplate =int( 223 * DPMM);
int ySizeBuildplate =int( 223 * DPMM);
int xSizePrintArea = int(210*DPMM);
int ySizePrintArea = int(210*DPMM);

int XSIZE = max(int(sensorSize*sensorsX), xSizeBuildplate);
int YSIZE = max(int(sensorSize*sensorsY), ySizeBuildplate);

//Printer settings
float ext = 0; //extrusion step   
final float speed1 = 1500;
final float speedCo2= 2.0;
final float speedCo3= 3.0;
final float speed2 = speed1*speedCo2;
final float speed3 = speed1*speedCo3;
float speed = speed1;
final float layerHeight = 0.25;
float currentLayer = 0;
final float extrusionCoefficient1 = .3;
final float exCo2 = 1.5;
final float extrusionCoefficient2 = extrusionCoefficient1 * exCo2;
float extrusionCoefficient = extrusionCoefficient1;
float IMLayer = 1;

final int heightProfile = 16; //in mm
final int layersProfileTotal = int(heightProfile / (layerHeight));
final int layersProfileBottom = 2;
final int layersProfileTop = layersProfileTotal - layersProfileBottom;

final float heightBase = 0.3;
final int layersBaseTotal = int(heightBase / (layerHeight));
final int layersBaseBottom = 1;
final int layersBaseTop = layersBaseTotal - layersBaseBottom;

final float heightEdges = 7; //in mm
final int layersEdgesTotal = int(heightEdges / (layerHeight));
final int layersEdgesBottom = 2;
final int layersEdgesTop = layersEdgesTotal - layersEdgesBottom;

final int heightContour = 1;
final int layersContourTotal = int(heightContour / (layerHeight));
final int heightContourBottom = 5;
final int layersContourBottom = int(heightContourBottom / layerHeight);
final int layersContourTop = layersContourTotal - layersContourBottom;


final int heightUppersBottom = 17;
final int layersUppersBottom = int(heightUppersBottom / layerHeight);
final int heightUppersMid = 35;
final int layersUppersMid = int(heightUppersMid / layerHeight);
final int heightUppersTop = 30;
final int layersUppersTop = int(heightUppersTop / layerHeight);
final int heightUppersTotal = heightUppersBottom+heightUppersMid+heightUppersTop;
final int layersUppersTotal = int((heightUppersTotal) / (layerHeight));

int layersSensor = 8;
int infillSensor = 3;
int pauseState = 0;

final int layersTotal = layersProfileTotal + layersBaseTotal + layersEdgesTotal + layersContourTotal+layersUppersTotal;

final float retraction = 0;
final float nozzleDiameter =0.8*DPMM;
final float slicedistance1 = 1.6 * DPMM;//Nozzel Diameter x 2
final float slicedistance2 = 5;
float slicedistance;
float polygonScale = 0.75;
float polygonScaleCurrent = polygonScale;
float polygonOffSet = 4*DPMM;
float stitchingWall= 5*DPMM;
float densitySliderLength = 30;
float densityLowerLimit = 0.2;
float densityUpperLimit = 0.3;
int selectedTrPolygon = 0;
float[] fitShoe = new float[3];
int layersProfileAtOnce = 3;

int layerCountProfile = 0;
int layerCountProfileMod = 0;
String state;

String SVGShape = "RightToe4.svg";
String SensorJSON = "json Lonneke_Right.txt"; 

float prevX = 10;
float prevY = 10;

float prevMidX=0;
float prevMidY=0;

float x0 = 0;
float y0 = 0;

void setup() {  
  Locale.setDefault(Locale.US);//so it writes 0.1 instead of 0,1 even in Netherlands
  sole = loadImage("Sole_42_illustrator_scale.jpg");
  empty = loadImage("empty.jpg");
  grid1 = loadImage("grid1.jpg");
  grid2 = loadImage("grid2.jpg");
  grid3 = loadImage("grid3.jpg");
  grid4 = loadImage("grid4.jpg");
  size(XSIZE, YSIZE);

  image(sole, 0, 0);

  println("Welcome to SOLEMAKER, version which saves gcode files                     ");
  println("(C) Loe Feijs and Troy Nachtigall, Bart Pruijmboom at TU/e 2016           ");
  println("move mouse and click at successive interesting points                     ");
  println("first make contour, then insole seed points..                             ");
  println("                                                                          ");
  println("ENTERING CONTOUR MODE");
  println("TYPE 'c' TO ENTER INSOLE MODE");
  println("TYPE 't' TO ENTER TREAD MODE");
  println("TYPE 'd' TO ENTER TREAD MODE");
  RG.init(this);
  RG.setPolygonizer(RG.ADAPTATIVE); 
  grp = RG.loadShape(SVGShape);
  grp.centerIn(g, 0, 0, 0);

  grp2 = RG.loadShape(SVGShape2);
  grp2.centerIn(g, 0, 0, 0);
  pointPaths = grp.getPointsInPaths();
  pointPaths2 = grp2.getPointsInPaths();
}

void mouseClicked() {
  ellipse(mouseX, mouseY, 3, 3);
  if (mode == INSOLE && nrInPoints < MAXNRINPOINTS) {
    for (int i = 0; i<sensorsX; i++) {
      for (int j = 0; j<sensorsY; j++) {
        inPoints[nrInPoints  ][0] = int((i * sensorSize) + .5 * sensorSize);
        inPoints[nrInPoints++][1] = int((j * sensorSize) + .5 * sensorSize);
      }
    }
    update();
  }
  if (mode == TREAD && nrTrPoints < MAXNRTRPOINTS) {
    if (pointPaths[1] != null) {
      for (int j = 0; j<pointPaths[1].length; j++) {
        trPoints[j][0] = pointPaths[1][j].x;
        trPoints[j][1] = pointPaths[1][j].y;
        nrTrPoints= j;
      }
    }
    update();
  }
}

final int CONTOUR = 1;
final int INSOLE = 2;
final int TREAD =3;
final int DENSITY =4;
final int UPPERS = 5;
int mode = CONTOUR; 
int grid = 0;

void draw() {
  if (mousePressed && mode == UPPERS) {
  }
  if (mousePressed && mode == DENSITY && nrTrPoints > 1) {
    //find the seed point closest to the mouse.
    //and aha (the place in the array where this best minimum was found).
    float[] mousePoint = {
      mouseX, mouseY
    };

    if (isInside(coEdges, mousePoint)) {
      for (int i =0; i<tsTrPolygons.length; i++) {
        if (tsTrPolygons[i] != null ) {
          if (isInside(tsTrPolygons[i], mousePoint)) {
            //            float[] MaxMin = MaxMinPolygon(tsTrPolygons[i]);
            //            tsTrDensity[i] = map(mouseY, MaxMin[1], MaxMin[3], densityLowerLimit, densityUpperLimit);
            //            println("waddup " + tsTrDensity[i]);
            selectedTrPolygon = i;
            //            update2(tsTrDensity);
          }
        }
      }
    } else {
      tsTrDensity[selectedTrPolygon] = map(height - mouseY, 0, height, densityLowerLimit, densityUpperLimit);
      update2(tsTrDensity);
    }
    //    println(tsTrDensity);
  }   //end if mousepressed

  if (mousePressed && mode == TREAD && nrTrPoints > 1) {
    //find the seed point closest to the mouse.
    //and aha (the place in the array where this best minimum was found).
    float min = 10000;
    int aha = -1;
    for (int i = 0; i < nrTrPoints; i++) {
      float d = dist(trPoints[i][0], trPoints[i][1], mouseX, mouseY);
      if (d < min) {
        min = d;
        aha = i;
      }
    }
    //if there is one point really "near" the mouse then drag it:
    int near = (nrTrPoints > 5? 20 : 40);
    if (min < near) {
      trPoints[aha][0] = mouseX;
      trPoints[aha][1] = mouseY;
      update();
    }
  }   //end if mousepressed

  if (mousePressed && mode == INSOLE && nrInPoints > 1) {
    //find the seed point closest to the mouse.
    //and aha (the place in the array where this best minimum was found).
    float min = 10000;
    int aha = -1;
    for (int i = 0; i < nrInPoints; i++) {
      float d = dist(inPoints[i][0], inPoints[i][1], mouseX, mouseY);
      if (d < min) {
        min = d;
        aha = i;
      }
    }
    //if there is one point really "near" the mouse then drag it:
    int near = (nrInPoints > 5? 20 : 40);
    if (min < near) {
      inPoints[aha][0] = mouseX;
      inPoints[aha][1] = mouseY;
      update();
    }
  }   //end if mousepressed
}

void update() {
  //kind of draw, only do it after mouse or key event
  switch (grid) {
  case 0:  
    image(empty, 0, 0); 
    break;
  case 1:  
    image(grid1, 0, 0); 
    break;
  case 2:  
    image(grid2, 0, 0); 
    break;
  case 3:  
    image(grid3, 0, 0); 
    break;
  case 4:  
    image(grid4, 0, 0); 
    break;
  default: 
    image(empty, 0, 0);
  } //end switch
  //rect(10 * DPMM, 10 * DPMM, 100 * DPMM, 10 * DPMM);//test for calibration
  strokeWeight(2); 
  if (nrCoPoints < 2) return;  
  if (mode == CONTOUR)
    contourDraw(coPoints);
  else {
    insolePrep();
    contourDraw(coEdges);
    treadDraw();
    if (nrTrPoints > 0) {
      for (int i =0; i<tsTrPolygons.length; i++) {
        //        drawEdgesDensity(cppTrEdges);
        if (tsTrPolygons[i]!= null) {
          if (slicePolygonX(scalePolygon(tsTrPolygons[i], polygonScale)) !=null) {
            //            drawEdges(slicePolygonX(scalePolygon(tsTrPolygons[i], polygonScale)));//“stp” = sliced tread polygons
          }
        }
      }
    }
  }
} 

void update2(float[] density) {
  //kind of draw, only do it after mouse or key event
  for (int i =0; i<tsTrPolygons.length; i++) {
    //        drawEdgesDensity(cppTrEdges);
    if (tsTrPolygons[i]!= null && tsTrPolygons[i].length>1) {
      if (slicePolygonX(unionPolygon(tsTrPolygons[i], -polygonOffSet)) !=null) {
        drawEdgesDensity(slicePolygonX(unionPolygon(tsTrPolygons[i], -polygonOffSet)), density[i]);//“stp” = sliced tread polygons
      }
    }
  }
} 

void contourDraw(float[][] points) {
  //show the contour as a set of edges (based on the point representation in coPoints)
  if (points.length > 1) {
    float startX = points[0][0];
    float startY = points[0][1];
    for (int i=1; i < points.length; i++) {
      float endX   = points[i][0];
      float endY   = points[i][1];
      //dark green contour
      stroke(0, 128, 0);
      ellipse(startX, startY, 3, 3);
      ellipse(endX, endY, 3, 3);
      line( startX, startY, endX, endY );
      startX = endX;
      startY = endY;
    }
    float endX   = points[0][0];
    float endY   = points[0][1];
    if (mode == CONTOUR) stroke(200, 200, 200); 
    else stroke(0, 128, 0);
    line( startX, startY, endX, endY );
  } //end if
}

void edgeWrite(float startX, float startY, float endX, float endY) {
  //auxiliary for contourWrite and insoleWrite
  //write coordinates in mm
  if (startX > (0.05*DPMM) && endX > (0.05*DPMM)) {
    int L = 4;//digits before dot
    int R = 2;//digits after dot
    ext = ext + dist(startX, startY, endX, endY)*extrusionCoefficient;
    //    if (dist(prevX, prevY, startX, startY) <= 50) {
    if (prevX == endX && prevY == endY) {
    } else if (prevX==startX && prevY ==startY) {
      txt.println(" G1 X "+nf(endX / DPMM, L, R)+" Y "+nf(endY / DPMM, L, R)+" E "+nf(ext / DPMM, L, R)+ " Z " + nf(currentLayer));
    } else {
      txt.println("G1 X "+nf(startX / DPMM, L, R)+" Y "+nf(startY / DPMM, L, R)+ " Z " + nf(currentLayer));
      txt.println(" G1 X "+nf(endX / DPMM, L, R)+" Y "+nf(endY / DPMM, L, R)+" E "+nf(ext / DPMM, L, R) + " Z " + nf(currentLayer));
    }
    //    } else {
    //      txt.println(" G0 X "+nf(prevX / DPMM, L, R)+" Y "+nf(prevY / DPMM, L, R)+" E "+nf(ext-retraction / DPMM, L, R) + " Z " + nf(currentLayer+1)) ;
    //      txt.println(" G0 X "+nf(startX / DPMM, L, R)+" Y "+nf(startY / DPMM, L, R)+" E "+nf(ext-retraction / DPMM, L, R) + " Z " + nf(currentLayer+1)) ;
    //      txt.println(" G0 X "+nf(startX / DPMM, L, R)+" Y "+nf(startY / DPMM, L, R)+" E "+nf(ext-retraction / DPMM, L, R) + " Z " + nf(currentLayer)) ;
    //      txt.println(" G1 X "+nf(endX / DPMM, L, R)+" Y "+nf(endY / DPMM, L, R)+" E "+nf(ext-retraction / DPMM, L, R) + " Z " + nf(currentLayer)) ;
    //    }

    prevX = endX;
    prevY = endY;
  }
}

void edgeMove(float startX, float startY, float endX, float endY) {
  //auxiliary for contourWrite and insoleWrite
  //write coordinates in mm
  int L = 4;//digits before dot
  int R = 2;//digits after dot
  if (startX > (0.05*DPMM) && endX > (0.05*DPMM)) {
    txt.println(" F"+(speed1*5));
    txt.println(" G0 X "+nf(endX / DPMM, L, R)+" Y "+nf(endY / DPMM, L, R)+ " Z " + nf(currentLayer));
    txt.println(" F"+speed);
  }
}


void edgeWriteRounded(float startX, float startY, float endX, float endY, int state) {
  //auxiliary for contourWrite and insoleWrite
  //write coordinates in mm
  int L = 4;//digits before dot
  int R = 2;//digits after dot
  float maxMid=6*DPMM;
  ext = ext + dist(startX, startY, endX, endY)*extrusionCoefficient;
  float midX = (((endX-startX) / DPMM)/2);
  float midY = (((endY-startY) / DPMM)/2);
  if (midX!=0 || midX<=maxMid || midX>= -maxMid) {
    prevMidX=midX;
  }
  if (midY!=0 || midY<=maxMid || midY>= -maxMid) {
    prevMidY=midY;
  }

  if (midX==0 || midX>maxMid || midX< -maxMid) {
    midX=prevMidX;
  }
  if (midY==0 || midY>maxMid || midY< -maxMid) {
    midY=prevMidY;
  }
  //  if (dist(prevX, prevY, startX, startY) <= 50) {
  if (prevX==startX && prevY ==startY && dist(startX, startY, endX, endY)/DPMM<100) {
    if (startX > (0.05*DPMM)) {
      if (state ==0) {
        txt.println(" G3 X "+nf(endX / DPMM, L, R)+" Y "+nf(endY / DPMM, L, R)+" E "+nf(ext / DPMM, L, R)+" I "+nf(midX, L, R)+" J "+nf(midY, L, R) +" Z " + nf(currentLayer));
        ext = ext + dist(startX, startY, endX, endY)*extrusionCoefficient;
        txt.println(" G3 X "+nf(startX / DPMM, L, R)+" Y "+nf(startY / DPMM, L, R)+" E "+nf(ext / DPMM, L, R)+" I "+nf(-midX, L, R)+" J "+nf(-midY, L, R) +" Z " + nf(currentLayer));
        ext = ext + dist(startX, startY, endX, endY)*extrusionCoefficient;
        txt.println(" G3 X "+nf(endX / DPMM, L, R)+" Y "+nf(endY / DPMM, L, R)+" E "+nf(ext / DPMM, L, R)+" I "+nf(midX, L, R)+" J "+nf(midY, L, R) +" Z " + nf(currentLayer));
      } else if (state==1) {
        txt.println(" G3 X "+nf(endX / DPMM, L, R)+" Y "+nf(endY / DPMM, L, R)+" E "+nf(ext / DPMM, L, R)+" I "+nf(midX, L, R)+" J "+nf(midY, L, R) +" Z " + nf(currentLayer));
      } else if (state==2) {
        txt.println(" G2 X "+nf(endX / DPMM, L, R)+" Y "+nf(endY / DPMM, L, R)+" E "+nf(ext / DPMM, L, R)+" I "+nf(midX, L, R)+" J "+nf(midY, L, R) +" Z " + nf(currentLayer));
      }
    }
  } else {
    if (startX > (0.05*DPMM)) {
      txt.println("G1 X "+nf(startX / DPMM, L, R)+" Y "+nf(startY / DPMM, L, R)+" E "+nf((ext) / DPMM, L, R) + " Z " + nf(currentLayer));
      txt.println(" G1 X "+nf(endX / DPMM, L, R)+" Y "+nf(endY / DPMM, L, R)+" E "+nf(ext / DPMM, L, R) + " Z " + nf(currentLayer));
    }
  }
  //  } else {
  //    txt.println(" G0 X "+nf(prevX / DPMM, L, R)+" Y "+nf(prevY / DPMM, L, R)+" E "+nf(ext-retraction / DPMM, L, R) + " Z " + nf(currentLayer+1)) ;
  //    txt.println(" G0 X "+nf(startX / DPMM, L, R)+" Y "+nf(startY / DPMM, L, R)+" E "+nf(ext-retraction / DPMM, L, R) + " Z " + nf(currentLayer+1)) ;
  //    txt.println(" G0 X "+nf(startX / DPMM, L, R)+" Y "+nf(startY / DPMM, L, R)+" E "+nf(ext-retraction / DPMM, L, R) + " Z " + nf(currentLayer)) ;
  //    txt.println(" G1 X "+nf(endX / DPMM, L, R)+" Y "+nf(endY / DPMM, L, R)+" E "+nf(ext-retraction / DPMM, L, R) + " Z " + nf(currentLayer)) ;
  //  }
  prevX = endX;
  prevY = endY;
}

void edgeWrite2(float endX, float endY) {
  //auxiliary for contourWrite and insoleWrite
  //write coordinates in mm
  int L = 4;//digits before dot
  int R = 2;//digits after dot
  ext = ext + dist(prevX, prevY, endX, endY)*extrusionCoefficient;
  //  if (dist(prevX, prevY, endX, endY) <= 50) { 
  if (prevX > (0.05*DPMM)) {
    txt.println(" G1 X "+nf(endX / DPMM, L, R)+" Y "+nf(endY / DPMM, L, R)+" E "+nf(ext / DPMM, L, R) + " Z " + nf(currentLayer));
  }
  //  } else {
  //    txt.println(" G0 X "+nf(prevX / DPMM, L, R)+" Y "+nf(prevY / DPMM, L, R)+" E "+nf(ext-retraction / DPMM, L, R) + " Z " + nf(currentLayer+3)) ;
  //    txt.println(" G0 X "+nf(endX / DPMM, L, R)+" Y "+nf(endY / DPMM, L, R)+" E "+nf(ext-retraction / DPMM, L, R) + " Z " + nf(currentLayer+3)) ;
  //    txt.println(" G0 X "+nf(endX / DPMM, L, R)+" Y "+nf(endY / DPMM, L, R)+" E "+nf(ext-retraction / DPMM, L, R) + " Z " + nf(currentLayer)) ;
  //  }
  prevX = endX;
  prevY = endY;
}

void contourWrite() {
  //write the contour as a set of edges
  //essentially a variation on contourDraw
  if (nrCoPoints > 1) {
    txt.println(";CONTOUR EDGES");
    float startX = coPoints[0][0];
    float startY = coPoints[0][1];
    for (int i=1; i < nrCoPoints; i++) {
      float endX   = coPoints[i][0];
      float endY   = coPoints[i][1];
      //write the contour
      edgeWrite(startX, startY, endX, endY);
      startX = endX;
      startY = endY;
    }
    float endX   = coPoints[0][0];
    float endY   = coPoints[0][1];
    edgeWrite(startX, startY, endX, endY);
  }   //end if
}

void raftWrite(float[][] raft) {
  //write the contour as a set of edges
  //essentially a variation on contourDraw
  if (raft.length > 1) {
    txt.println(";CONTOUR EDGES");
    float startX = raft[0][0];
    float startY = raft[0][1];
    for (int i=1; i < raft.length; i++) {
      float endX   = raft[i][0];
      float endY   = raft[i][1];
      //write the contour
      edgeWrite(startX, startY, endX, endY);
      startX = endX;
      startY = endY;
    }
    float endX   = raft[0][0];
    float endY   = raft[0][1];
    edgeWrite(startX, startY, endX, endY);
  }   //end if
}

void raftWriteRounded(float[][] raft) {
  //write the contour as a set of edges
  //essentially a variation on contourDraw
  if (raft.length > 1) {
    txt.println(";CONTOUR EDGES");
    float startX = raft[0][0];
    float startY = raft[0][1];
    for (int i=1; i < raft.length; i++) {
      float endX   = raft[i][0];
      float endY   = raft[i][1];
      //write the contour
      edgeWriteRounded(startX, startY, endX, endY, 0);
      startX = endX;
      startY = endY;
    }
    float endX   = raft[0][0];
    float endY   = raft[0][1];
    edgeWriteRounded(startX, startY, endX, endY, 0);
  }   //end if
}

float[][] raftRoundFill(float totalWidth, float totalHeight, float current, float startLayer, float[][] contour) {
  float rX = totalWidth*DPMM;//mm
  float rY = totalHeight;//layers
  float y = current;//layer
  int x = int((-1* sqrt(sq(rX) * (1-((sq(y-rY))/sq(rY))))) + rX);
  float[][] raftRound = new float[0][]; 
  for (int i = 1; i< (x+startLayer)/slicedistance; i++) {
    float[][] raftRoundTemp = unionPolygon(contour, -(i*slicedistance));
    raftRound = concat(raftRound, raftRoundTemp);
  }
  return raftRound;
}

float[][] raftRound(float totalWidth, float totalHeight, float current, float startLayer, float[][] contour) {
  float rX = totalWidth*DPMM;//mm
  float rY = totalHeight;//layers
  float y = current;//layer
  float x = ((-1* sqrt(sq(rX) * (1-((sq(y-rY))/sq(rY))))) + rX);
  float[][] raftRound = unionPolygon(contour, -(x+startLayer));
  return raftRound;
}

float[][] curveEdges(float[][]edges1, float[][] edges2, float totalHeight, float current) {
  float[][] returnEdges = new float[edges1.length][4];
  float[][] returnPoints = new float[edges1.length][2];

  float rY = totalHeight;//layers
  float y = current;//layer
  float s = ((-1* sqrt(1 * (1-((sq(y-rY))/sq(rY))))) + 1)/1;
  for (int i = 0; i<edges1.length; i++) {
    int edge =0;
    if (edges1.length != edges2.length) {
      float dist =1000;
      for (int j = 0; j+1<edges2.length; j++) {
        if (dist(edges1[i][0], edges1[i][1], edges2[j][0], edges2[j][1]) < dist) {
          dist = dist(edges1[i][0], edges1[i][1], edges2[j][0], edges2[j][1]);
          edge = j;
        }
      }
    } else {
      edge = i;
    }
    returnPoints[i][0] = edges1[i][0] - (edges1[i][0]-edges2[edge][0])*(s);
    returnPoints[i][1] = edges1[i][1] - (edges1[i][1]-edges2[edge][1])*(s);
  }

  returnEdges = points2edges(returnPoints, returnPoints.length);

  return returnEdges;
};

float[][] raft(int raftlayers, int raftlayer, float[][] contour) {
  float[][]coPointsCopy = new float[contour.length+3][2];
  float[] raftPointsX = new float[0];
  float[] raftPointsY = new float[0];
  float[][] contourEdges = points2edges(contour, contour.length);




  for (int i = 0; i<coPoints.length+3; i++) {
    if (i<coPoints.length) {
      coPointsCopy[i][0] = contour[i][0];
      coPointsCopy[i][1] = contour[i][1];
    } else if (i>=coPoints.length) {
      coPointsCopy[i][0] = contour[i-(coPoints.length)][0];
      coPointsCopy[i][1] = contour[i-(coPoints.length)][1];
    }
  }
  for (int j = raftlayer+1; j <= raftlayers+1; j++) {
    for (int k = 0; k< (coPointsCopy.length)-3; k++) {
      float a;

      float x = curvePoint(coPointsCopy[k][0], coPointsCopy[k+1][0], coPointsCopy[k+2][0], coPointsCopy[k+3][0], 1);
      float y = curvePoint(coPointsCopy[k][1], coPointsCopy[k+1][1], coPointsCopy[k+2][1], coPointsCopy[k+3][1], 1);
      if (k==coPointsCopy.length-3) {
        a = atan2(curveTangent(coPointsCopy[k][1], coPointsCopy[k+1][1], coPointsCopy[k+2][1], coPointsCopy[k+3][1], 1), curveTangent(coPointsCopy[k][0], coPointsCopy[k+1][0], coPointsCopy[k+2][0], coPointsCopy[k+3][0], 1)) + PI/2.0;
      } else {
        a = atan2(curveTangent(coPointsCopy[k][1], coPointsCopy[k+1][1], coPointsCopy[k+2][1], coPointsCopy[k+3][1], 1), curveTangent(coPointsCopy[k][0], coPointsCopy[k+1][0], coPointsCopy[k+2][0], coPointsCopy[k+3][0], 1)) + PI/2.0;
      };
      float xc = cos(a)*slicedistance*j + x;
      float yc = sin(a)*slicedistance*j + y;
      float[] checkPoint = {
        xc, yc
      };
      if (xc > 2 && yc > 2) {
        if (isInside(contourEdges, checkPoint)) {
          raftPointsX = append(raftPointsX, xc);
          raftPointsY = append(raftPointsY, yc);
        }
      }
    };
  };

  float[][] raftPoints = new float[raftPointsX.length][2];

  for (int i =0; i < raftPointsX.length; i++) {
    raftPoints[i][0] = raftPointsX[i];
    raftPoints[i][1] = raftPointsY[i];
  }

  return raftPoints;
};



//edges-based representations of contour and voronoi cells
float[][] coPointsCurve = new float[numCoPointSteps][2];
float[][] coEdges; //contour edges, later fill eg = points2edges(coPoints, nrCoPoints);

float[][] coInEdges; //contour edges, later fill eg = points2edges(coPoints, nrCoPoints);
float[][] inEdges; //insole edges, later fill eg = myVoronoi.getEdges();
float[][] allInEdges; //combined coEdges and inEdges;
float[][] cppInEdges; //all edges organised in a chinese postman tour (with duplicates and more)
float[][][] tsInPolygons; //tread polygons (each tread is described by its contour which is a polygon (which is a set of edges)
float[][] stpInEdges; //sliced tread polygon edges (each polygon is scaled and then sliced and these are the edges of that)
float[][][] InPolygonsHard;
float[][][] InPolygonsSoft;

float[][] coTrEdges; //contour edges, later fill eg = points2edges(coPoints, nrCoPoints);
float[][] trEdges; //insole edges, later fill eg = myVoronoi.getEdges();
float[][] allTrEdges; //combined coEdges and inEdges;
float[][] cppTrEdges; //all edges organised in a chinese postman tour (with duplicates and more)
float[][][] tsTrPolygons; //tread polygons (each tread is described by its contour which is a polygon (which is a set of edges)
float[][] stpTrEdges; //sliced tread polygon edges (each polygon is scaled and then sliced and these are the edges of that)
float[] tsTrDensity;


float
[][] points2edges(float[][] points, int howmany) {
  //convert from point-based representation into edges
  float[][] edges = new float[howmany][4];
  float startX = points[0][0];
  float startY = points[0][1];
  for (int i = 1; i < howmany; i++) {
    float endX   = points[i][0];
    float endY   = points[i][1];
    edges[i - 1][0] = startX;
    edges[i - 1][1] = startY;
    edges[i - 1][2] = endX;
    edges[i - 1][3] = endY;
    startX = endX;
    startY = endY;
  }
  //close the loop
  edges[howmany - 1][0] = startX;
  edges[howmany - 1][1] = startY;
  edges[howmany - 1][2] = points[0][0];
  edges[howmany - 1][3] = points[0][1];
  return edges;
}

void insolePrep() {
  //fill the edge-based representation arrays 
  //so everything is ready for drawing or writing
  Voronoi myInVoronoi; 
  Voronoi myTrVoronoi;

  print("nrInPoints = "); 
  println(nrInPoints);
  //copy myPoints into voPoints
  float[][] voInPoints = new float[nrInPoints][2];
  for (int i = 0; i < nrInPoints; i++) {
    voInPoints[i][0] = inPoints[i][0];
    voInPoints[i][1] = inPoints[i][1];
  }

  float[][] voTrPoints = new float[nrTrPoints][2];
  for (int i = 0; i<nrTrPoints; i++) {
    voTrPoints[i][0] = trPoints[i][0];
    voTrPoints[i][1] = trPoints[i][1];
  }


  myInVoronoi = new Voronoi( voInPoints );
  myTrVoronoi = new Voronoi( voTrPoints );

  coEdges = points2edges(coPointsCurve, numCoPointSteps);

  //  println("coEdges().length = " + coEdges.length);
  if (!noNullEdges(coEdges)) println("ERROR 77.2: NULL EDGE FOUND IN COEDGES"); 

  //get the edges and get rid of what is outside the contour
  //warning: already for three points the voronoi finds nine edges (some far-way outer contour)
  inEdges = myInVoronoi.getEdges();
  //  println("myInVoronoi.getEdges().length = " + myInVoronoi.getEdges().length);
  if (!noNullEdges(inEdges)) println("ERROR 77.1: NULL EDGE FOUND IN INEDGES"); 
  coInEdges = refineEdges(coEdges, inEdges);
  //  println("refined coInEdges().length = " + coEdges.length);
  if (!noNullEdges(coInEdges)) println("ERROR 77.3: NULL EDGE FOUND IN REFINED COEDGES"); 
  inEdges = pruneEdges(coInEdges, inEdges); 
  //  println("pruned inEdges().length = " + inEdges.length);
  if (!noNullEdges(inEdges)) println("ERROR 77.4: NULL EDGE FOUND IN PRUNED INEDGES");
  allInEdges = allEdges(coInEdges, inEdges);
  //  println("allInEdges().length = " + allInEdges.length);
  if (!noNullEdges(allInEdges)) println("ERROR 77.5: NULL EDGE FOUND IN ALLEDGES");
  cppInEdges = allPrepChinese(allInEdges);
  //  println("cppInEdges().length = " + cppInEdges.length);
  if (!noNullEdges(cppInEdges)) println("ERROR 77.5: NULL EDGE FOUND IN CPPEDGES"); 
  float[][][] inPolygons = makePolygons(allInEdges);
  if (!noNullPolygons(inPolygons)) println("ERROR 77.5: NULL POLYGON FOUND IN POLYGONS"); 
  tsInPolygons = travelingSalesmanProblem(inPolygons);//tread polygons 
  //  println("tsInPolygons().length = " + tsInPolygons.length);
  slicedistance = slicedistance1;
  stpInEdges = slicePolygonsX(scalePolygons(inPolygons, polygonScale));//scliced tread polygon edges
  //  println("stpEdges().length = " + stpInEdges.length);
  //  float[][] coEdgeslol = shapeOffset(coEdges, polygonOffSet);
  //  coEdges = points2edges(coEdgeslol, coEdgeslol.length);
  trEdges = myTrVoronoi.getEdges();
  //  println("myTrVoronoi.getEdges().length = " + myTrVoronoi.getEdge).length);
  //  if (!noNullEdges(inEdges)) println("ERROR 77.1: NULL EDGE FOUND IN INEDGES"); 
  coTrEdges = refineEdges(coEdges, trEdges);
  //  println("refined coTrEdges().length = " + coTrEds.length);
  //  if (!noNullEdges(coTrEdges)) println("ERROR 77.3: NULL EDGE FOUND IN REFINED COTREDGES"); 
  trEdges = pruneEdges(coTrEdges, trEdges); 
  //  println("pruned trEdges().length = " + trEds.length);
  //  if (!noNullEdges(inEdges)) println("ERROR 77.4: NULL EDGE FOUND IN PRUNED INEDGES");
  allTrEdges = allEdges(coTrEdges, trEdges);
  //  println("allTrEdges().length = " + allTrEds.length);
  //  if (!noNullEdges(allTrEdges)) println("ERROR 77.5: NULL EDGE FOUND IN ALLEDGES");
  cppTrEdges = allPrepChinese(allTrEdges);
  //  println("cppTrEdges().length = " + cppTrEds.length);
  //  if (!noNullEdges(cppTrEdges)) println("ERROR 77.5: NULL EDGE FOUND IN CPPEDGES"); 
  float[][][] trPolygons = makePolygons(allTrEdges);
  //  if (!noNullPolygons(trPolygons)) println("ERROR 77.5: NULL POLYGON FOUND IN POLYGONS"); 
  tsTrPolygons = scalePolygons(travelingSalesmanProblem(trPolygons), 1);//tread polygons 
  //  println("tsTrPolygons().length = " + tsTrPolygons.length);
  slicedistance = slicedistance1;
  stpTrEdges = slicePolygonsX(unionPolygons(trPolygons, polygonOffSet));//scliced tread pygon edges
  //  println("stpEdges().length = " + stpTrEdges.length);
  //  coEdgeslol = shapeOffset(coEdges, -polygonOffSet);
  //  coEdges = points2edges(coEdgeslol, coEdgeslol.length);
  coEdges = topPoint(coEdges);
}    //end insolePrep

void treadDraw() {
  //show the points
  for (int i = 0; i < nrTrPoints; i++) {
    float X = trPoints[i][0];
    float Y = trPoints[i][1];
    //light red points
    stroke(245, 80, 80);
    ellipse(X, Y, 3, 3);
  }    
  //show the edges
  for (int i=0; i<trEdges.length; i++) {
    if (trEdges[i] != null) {
      float startX = trEdges[i][0];
      float startY = trEdges[i][1];
      float endX = trEdges[i][2];
      float endY = trEdges[i][3];
      //red egdges
      stroke(225, 0, 0);
      ellipse(startX, startY, 2, 2);
      ellipse(endX, endY, 2, 2);
      line( startX, startY, endX, endY );
    }   //end if non null
  }    //end for
}//end insoleDraw

void drawEdges(float[][] edges) {
  //send them to the screen
  for (int i = 0; i< edges.length; i++) {
    float startX = edges[i][0];
    float startY = edges[i][1];
    float endX   = edges[i][2];
    float endY   = edges[i][3];
    strokeWeight(.50);//thin
    stroke(0);//black for test
    line( startX, startY, endX, endY );
  }    //end for
}    //   end drawEdges 

void drawEdgesDensity(float[][] edges, float density) {
  //send them to the screen
  for (int i = 0; i< edges.length; i++) {
    float startX = edges[i][0];
    float startY = edges[i][1];
    float endX   = edges[i][2];
    float endY   = edges[i][3];
    strokeWeight(.50);//thin
    stroke(map(density, densityLowerLimit, densityUpperLimit, 255, 0));//black for test
    line( startX, startY, endX, endY );
  }    //end for
}    //   end drawEdges 

void writeEdges(float[][] edges) {
  //send them to the 3D printer, preserve the order of the edges: 0,1,...,edges.length-1
  for (int i = 0; i< edges.length; i++) {
    float startX = edges[i][0];
    float startY = edges[i][1];
    float endX   = edges[i][2];
    float endY   = edges[i][3];
    edgeWrite(startX, startY, endX, endY);
  }    //end for
}    //end writeEdges


void writeEdgesWiggle2Translated(float[][] edges1, float[][] edges2, float[] translation, float startPercentage, float endPercentage) {
  float[] topPointEdges = MaxMinPolygon(edges1);
  int topPoint =0 ;
  int checkpoint=0;
  int state = 0;
  while (state == 0 && checkpoint <= edges1.length-1) {
    if (edges1[checkpoint][0] == topPointEdges[0] && edges1[checkpoint][1] == topPointEdges[1]) {
      topPoint = checkpoint;
      state = 1;
    }
    checkpoint++;
  }
  float[][] edges3 = translatePoints(edges1, translation);
  float[][] edges4 = translatePoints(edges2, translation);
  if (startPercentage<endPercentage) {
    //send them to the 3D printer, preserve the order of the edges: 0,1,...,edges.length-1
    for (int i = int (edges3.length*startPercentage); i+1<edges3.length*endPercentage; i=i+2) {
      float startX = edges3[i][0];
      float startY = edges3[i][1];
      float minDist = 1000;
      int wigglePoint =0;
      for (int j =0; j+1<edges4.length; j++) {
        if (dist(edges3[i][2], edges3[i][3], edges4[j][0], edges4[j][1])<minDist) {
          minDist = dist(edges3[i][2], edges3[i][3], edges4[j][0], edges4[j][1]);
          wigglePoint = j;
        }
      }
      float endX = edges4[wigglePoint][0];
      float endY = edges4[wigglePoint][1];
      edgeWrite(startX, startY, endX, endY);
      startX = edges4[wigglePoint][0];
      startY = edges4[wigglePoint][1];
      endX = edges3[i+1][2];
      endY = edges3[i+1][3];
      edgeWrite(startX, startY, endX, endY);
    }
    for (int i = int (edges3.length*endPercentage); i>edges3.length*startPercentage; i=i-2) {
      float startX = edges3[i][2];
      float startY = edges3[i][3];
      float minDist = 1000;
      int wigglePoint =0;
      for (int j =0; j+1<edges4.length; j++) {
        if (dist(edges3[i][0], edges3[i][1], edges4[j][0], edges4[j][1])<minDist) {
          minDist = dist(edges3[i][0], edges3[i][1], edges4[j][0], edges4[j][1]);
          wigglePoint = j;
        }
      }
      float endX = edges4[wigglePoint][0];
      float endY = edges4[wigglePoint][1];
      edgeWrite(startX, startY, endX, endY);
      startX = edges4[wigglePoint][0];
      startY = edges4[wigglePoint][1];
      endX = edges3[i-1][0];
      endY = edges3[i-1][1];
      edgeWrite(startX, startY, endX, endY);
    }
  } else if (endPercentage<startPercentage) {
    for (int i = int (edges3.length*startPercentage); i>edges3.length*endPercentage; i=i-2) {
      float startX = edges3[i][0];
      float startY = edges3[i][1];
      float minDist = 1000;
      int wigglePoint =0;
      for (int j =0; j+1<edges4.length; j++) {
        if (dist(edges3[i][2], edges3[i][3], edges4[j][0], edges4[j][1])<minDist) {
          minDist = dist(edges3[i][2], edges3[i][3], edges4[j][0], edges4[j][1]);
          wigglePoint = j;
        }
      }
      float endX = edges4[wigglePoint][0];
      float endY = edges4[wigglePoint][1];
      edgeWrite(startX, startY, endX, endY);
      startX = edges4[wigglePoint][0];
      startY = edges4[wigglePoint][1];
      endX = edges3[i-1][0];
      endY = edges3[i-1][1];
      edgeWrite(startX, startY, endX, endY);
    }
    for (int i = int (edges3.length*endPercentage); i+1<edges3.length*startPercentage; i=i+2) {
      float startX = edges3[i][2];
      float startY = edges3[i][3];
      float minDist = 1000;
      int wigglePoint =0;
      for (int j =0; j+1<edges4.length; j++) {
        if (dist(edges3[i][0], edges3[i][1], edges4[j][0], edges4[j][1])<minDist) {
          minDist = dist(edges3[i][0], edges3[i][1], edges4[j][0], edges4[j][1]);
          wigglePoint = j;
        }
      }
      float endX = edges4[wigglePoint][0];
      float endY = edges4[wigglePoint][1];
      edgeWrite(startX, startY, endX, endY);
      startX = edges4[wigglePoint][0];
      startY = edges4[wigglePoint][1];
      endX = edges3[i+1][0];
      endY = edges3[i+1][1];
      edgeWrite(startX, startY, endX, endY);
    }
  }

  ellipse(edges1[topPoint][0], edges1[topPoint][1], 10, 10);
  ellipse(edges1[0][0], edges1[0][1], 10, 10);
}    //end writeEdges

void writeEdgesWiggle4Translated(float[][] edges1, float[][] edges2, float[] translation, float startPercentage, float endPercentage) {
  float[] topPointEdges = MaxMinPolygon(edges1);
  int topPoint;
  int checkpoint=0;
  int state = 0;
  while (state == 0 && checkpoint <= edges1.length-1) {
    if (edges1[checkpoint][0] == topPointEdges[0] && edges1[checkpoint][1] == topPointEdges[1]) {
      topPoint = checkpoint;
      state = 1;
    }
    checkpoint++;
  }

  float[][] edges3 = translatePoints(edges1, translation);
  float[][] edges4 = translatePoints(edges2, translation);
  //send them to the 3D printer, preserve the order of the edges: 0,1,...,edges.length-1
  if (startPercentage<endPercentage) {
    //send them to the 3D printer, preserve the order of the edges: 0,1,...,edges.length-1
    for (int i = int (edges3.length*startPercentage); i+1<edges3.length*endPercentage; i=i+2) {
      float startX = edges3[i][0];
      float startY = edges3[i][1];
      float endX = edges4[i][2];
      float endY = edges4[i][3];
      edgeWrite(startX, startY, endX, endY);
      startX = edges4[i][2];
      startY = edges4[i][3];
      endX = edges3[i+1][2];
      endY = edges3[i+1][3];
      edgeWrite(startX, startY, endX, endY);
    }
    for (int i = int (edges3.length*endPercentage)-1; i>edges3.length*startPercentage; i=i-2) {
      float startX = edges3[i][2];
      float startY = edges3[i][3];
      float endX = edges4[i][0];
      float endY = edges4[i][1];
      edgeWrite(startX, startY, endX, endY);
      startX = edges4[i][0];
      startY = edges4[i][1];
      endX = edges3[i-1][0];
      endY = edges3[i-1][1];
      edgeWrite(startX, startY, endX, endY);
    }
  } else if (endPercentage<startPercentage) {
    for (int i = 1+ edges3.length+int (edges3.length*endPercentage); i>int(edges3.length*startPercentage); i=i-2) {
      float startX = edges3[(i%(edges3.length-1))][2];
      float startY = edges3[(i%(edges3.length-1))][3];
      float endX = edges4[(i%(edges3.length-1))][0];
      float endY = edges4[(i%(edges3.length-1))][1];
      edgeWrite(startX, startY, endX, endY);
      startX = edges4[(i%(edges3.length-1))][0];
      startY = edges4[(i%(edges3.length-1))][1];
      endX = edges3[((i-1)%(edges3.length-1))][0];
      endY = edges3[((i-1)%(edges3.length-1))][1];
      edgeWrite(startX, startY, endX, endY);
    }
    for (int i = int (edges3.length*startPercentage); i< (edges3.length + int(edges3.length*endPercentage)); i= i+2 ) { 
      float startX = edges3[(i%(edges3.length-1))][0];
      float startY = edges3[(i%(edges3.length-1))][1];
      float endX = edges4[(i%(edges3.length-1))][2];
      float endY = edges4[(i%(edges3.length-1))][3];
      edgeWrite(startX, startY, endX, endY);
      startX = edges4[(i%(edges3.length-1))][2];
      startY = edges4[(i%(edges3.length-1))][3];
      endX = edges3[((i+1)%(edges3.length-1))][2];
      endY = edges3[((i+1)%(edges3.length-1))][3];
      edgeWrite(startX, startY, endX, endY);
    }
  }
}    //end writeEdges

void writeEdgesWiggle5Translated(float[][] edges1, float[][] edges2, float[] translation) {
  float[][] edges3 = translatePoints(edges1, translation);
  float[][] edges4 = translatePoints(edges2, translation);
  for (int i = 0; i<edges3.length; i=i+2) {
    float startX = edges3[i][0];
    float startY = edges3[i][1];
    float endX = edges4[i][2];
    float endY = edges4[i][3];
    edgeWrite(startX, startY, endX, endY);
    startX = edges4[i][2];
    startY = edges4[i][3];
    endX = edges3[i+1][2];
    endY = edges3[i+1][3];
    edgeWrite(startX, startY, endX, endY);
  }
  for (int i = edges3.length-2; i>0; i=i-2) {
    float startX = edges3[i][2];
    float startY = edges3[i][3];
    float endX = edges4[i][0];
    float endY = edges4[i][1];
    edgeWrite(startX, startY, endX, endY);
    startX = edges4[i][0];
    startY = edges4[i][1];
    endX = edges3[i-1][0];
    endY = edges3[i-1][1];
    edgeWrite(startX, startY, endX, endY);
  }
}    //end writeEdges

void writeEdgesWiggleTranslated(float[][] edges1, float[][] edges2, float[] translation) {
  float[][] edges3 = translatePoints(edges1, translation);
  float[][] edges4 = translatePoints(edges2, translation);
  //send them to the 3D printer, preserve the order of the edges: 0,1,...,edges.length-1
  for (int i = 0; i+1<edges3.length; i=i+2) {
    float startX = edges3[i][0];
    float startY = edges3[i][1];
    float minDist = 1000;
    int wigglePoint =0;
    for (int j =0; j+1<edges4.length; j++) {
      if (dist(edges3[i][2], edges3[i][3], edges4[j][0], edges4[j][1])<minDist) {
        minDist = dist(edges3[i][2], edges3[i][3], edges4[j][0], edges4[j][1]);
        wigglePoint = j;
      }
    }
    float endX = edges4[wigglePoint][0];
    float endY = edges4[wigglePoint][1];
    edgeWrite(startX, startY, endX, endY);
    startX = edges4[wigglePoint][0];
    startY = edges4[wigglePoint][1];
    endX = edges3[i+1][2];
    endY = edges3[i+1][3];
    edgeWrite(startX, startY, endX, endY);
  }
  for (int i = 1; i+1<edges3.length; i=i+2) {
    float startX = edges3[i][0];
    float startY = edges3[i][1];
    float minDist = 1000;
    int wigglePoint =0;
    for (int j =0; j+1<edges4.length; j++) {
      if (dist(edges3[i][2], edges3[i][3], edges4[j][0], edges4[j][1])<minDist) {
        minDist = dist(edges3[i][2], edges3[i][3], edges4[j][0], edges4[j][1]);
        wigglePoint = j;
      }
    }
    float endX = edges4[wigglePoint][0];
    float endY = edges4[wigglePoint][1];
    edgeWrite(startX, startY, endX, endY);
    startX = edges4[wigglePoint][0];
    startY = edges4[wigglePoint][1];
    endX = edges3[i+1][2];
    endY = edges3[i+1][3];
    edgeWrite(startX, startY, endX, endY);
  }
}    //end writeEdges

void writeEdgesWiggle3Translated(float[][] edges1, float[][] edges2, float[] translation) {
  float[][] edges3 = translatePoints(edges1, translation);
  float[][] edges4 = translatePoints(edges2, translation);
  float maxEdgeLength = 6*DPMM;
  //send them to the 3D printer, preserve the order of the edges: 0,1,...,edges.length-1
  for (int i = 1; i+1<edges3.length; i=i+2) {
    if (edges3[i][2] == edges3[i+1][0] && edges3[i][3] == edges3[i+1][1] && edges3[i-1][2] == edges3[i][0] && edges3[i-1][3] == edges3[i][1]) {
      float startX = edges3[i][0];
      float startY = edges3[i][1];
      float endX = edges4[i][2];
      float endY = edges4[i][3];
      edgeWrite(startX, startY, endX, endY);
      startX = edges4[i][2];
      startY = edges4[i][3];
      endX = edges3[i+1][2];
      endY = edges3[i+1][3];
      edgeWrite(startX, startY, endX, endY);
    } else {
      edgeMove(edges3[i][0], edges3[i][1], edges3[i+1][2], edges3[i+1][3]);
    }
  }
  for (int i = 2; i+1<edges3.length; i=i+2) {
    if (edges3[i][2] == edges3[i+1][0] && edges3[i][3] == edges3[i+1][1] && edges3[i-1][2] == edges3[i][0] && edges3[i-1][3] == edges3[i][1]) {
      float startX = edges3[i][0];
      float startY = edges3[i][1];
      float endX = edges4[i][2];
      float endY = edges4[i][3];
      edgeWrite(startX, startY, endX, endY);
      startX = edges4[i][2];
      startY = edges4[i][3];
      endX = edges3[i+1][2];
      endY = edges3[i+1][3];
      edgeWrite(startX, startY, endX, endY);
    } else {
      edgeMove(edges3[i][0], edges3[i][1], edges3[i+1][2], edges3[i+1][3]);
    }
  }
}    //end writeEdges//end writeEdges


void writeEdgesTroyTranslated(float[][] edges1, float[][] edges2, int stLayer, int enLayer, int cuLayer, float[] translation) {
  float[][] edges3 = translatePoints(edges1, translation);
  float[][] edges4 = translatePoints(edges2, translation);
  int skipEdges = 1;
  //send them to the 3D printer, preserve the order of the edges: 0,1,...,edges.length-1

    for (int i = 0; i+skipEdges<edges3.length; i= i+1+skipEdges) {
    float minDist1 = 1000;
    int wigglePoint1 =0;
    for (int j =0; j+1<edges4.length; j++) {
      if (dist(edges3[i][0], edges3[i][1], edges4[j][0], edges4[j][1])<minDist1) {
        minDist1 = dist(edges3[i][0], edges3[i][1], edges4[j][0], edges4[j][1]);
        wigglePoint1 = j;
      }
    }
    float minDist2 = 1000;
    int wigglePoint2 =0;
    for (int j =0; j+1<edges4.length; j++) {
      if (dist(edges3[i+skipEdges][2], edges3[i+skipEdges][3], edges4[j][2], edges4[j][3])<minDist2) {
        minDist2 = dist(edges3[i+skipEdges][2], edges3[i+skipEdges][3], edges4[j][2], edges4[j][3]);
        wigglePoint2 = j;
      }
    }
    float edges3X1 = map(cuLayer, stLayer, enLayer, edges3[i][0], edges3[i][0]-(edges3[i][0]-edges3[i+skipEdges][2])*0.5);
    float edges3Y1 = map(cuLayer, stLayer, enLayer, edges3[i][1], edges3[i][1]-(edges3[i][1]-edges3[i+skipEdges][3])*0.5);
    float edges4X1 = map(cuLayer, stLayer, enLayer, edges4[wigglePoint1][0]-(edges4[wigglePoint1][0]-edges4[wigglePoint2][2])*0.5, edges4[wigglePoint1][0]);
    float edges4Y1 = map(cuLayer, stLayer, enLayer, edges4[wigglePoint1][1]-(edges4[wigglePoint1][1]-edges4[wigglePoint2][3])*0.5, edges4[wigglePoint1][1]);
    float edges4X2 = map(cuLayer, stLayer, enLayer, edges4[wigglePoint2][2]-(edges4[wigglePoint2][2]-edges4[wigglePoint1][0])*0.5, edges4[wigglePoint2][2]);
    float edges4Y2 = map(cuLayer, stLayer, enLayer, edges4[wigglePoint2][3]-(edges4[wigglePoint2][3]-edges4[wigglePoint1][1])*0.5, edges4[wigglePoint2][3]);
    float edges3X2 = map(cuLayer, stLayer, enLayer, edges3[i+skipEdges][2], edges3[i+skipEdges][2]-(edges3[i+skipEdges][2]-edges3[i][0])*0.5);
    float edges3Y2 = map(cuLayer, stLayer, enLayer, edges3[i+skipEdges][3], edges3[i+skipEdges][3]-(edges3[i+skipEdges][3]-edges3[i][1])*0.5);

    //    int sliceLines= int((max(dist(edges3X1, edges3Y1, edges3X2, edges3Y2), dist(edges4X1, edges4Y1, edges4X2, edges4Y2))/nozzleDiameter)/2);
    //    println(sliceLines);

    float[][] treadPoints = new float[5][2];

    treadPoints[0][0] =  edges4X1;
    treadPoints[0][1] =  edges4Y1;
    treadPoints[2][0] =  edges3X2;
    treadPoints[2][1] =  edges3Y2;
    treadPoints[3][0] =  edges4X2;
    treadPoints[3][1] =  edges4Y2;
    treadPoints[1][0] =  edges3X1;
    treadPoints[1][1] =  edges3Y1;
    treadPoints[4][0] =  edges4X1;
    treadPoints[4][1] =  edges4Y1;
    if (cuLayer%2 == 0) {
      float[][] slicedTreadEdges = arrangeEdges(slicePolygonX(points2edges(treadPoints, treadPoints.length)));
      writeEdges(slicedTreadEdges);
    } else {
      float[][] slicedTreadEdges = arrangeEdges(slicePolygonY(points2edges(treadPoints, treadPoints.length)));
      writeEdges(slicedTreadEdges);
    }
    float[][] treadEdges = points2edges(treadPoints, treadPoints.length);
    writeEdges(treadEdges);

    //    for (int j = 1; j<sliceLines; j++) {
    //      if (j%2 ==0) {
    //        float startX = map(j, 1, sliceLines, edges3X1,edges3X2);
    //        float startY = map(j, 1, sliceLines,edges3Y1,edges3Y2);
    //        float endX = map(j, 1, sliceLines,edges4X1,edges4X2);
    //        float endY = map(j, 1, sliceLines,edges4Y1,edges4Y2);
    //        edgeWrite(startX, startY, endX, endY);
    //      } else {
    //        float startX = map(j, 1, sliceLines,edges4X1,edges4X2);
    //        float startY = map(j, 1, sliceLines,edges4Y1,edges4Y2);
    //        float endX = map(j, 1, sliceLines,edges3X1,edges3X2);;
    //        float endY = map(j, 1, sliceLines,edges3Y1,edges3Y2);
    //        edgeWrite(startX, startY, endX, endY);
    //      }
    //    }
  }
}    //end writeEdges


void writeEdgesTranslated(float[][] edges, float[] translation) {
  float[][] edges2 = translatePoints(edges, translation);
  //send them to the 3D printer, preserve the order of the edges: 0,1,...,edges.length-1
  for (int i = 0; i+1< edges2.length; i++) {
    float startX = edges2[i][0];
    float startY = edges2[i][1];
    float endX   = edges2[i][2];
    float endY   = edges2[i][3];
    edgeWrite(startX, startY, endX, endY);
  }    //end for
}    //end writeEdges

void writeEdgesRoundedTranslated(float[][] edges, float[] translation) {
  float[][] edges2 = translatePoints(edges, translation);
  //send them to the 3D printer, preserve the order of the edges: 0,1,...,edges.length-1
  for (int i = 0; i< edges2.length; i++) {
    float startX = edges2[i][0];
    float startY = edges2[i][1];
    float endX   = edges2[i][2];
    float endY   = edges2[i][3];
    edgeWriteRounded(startX, startY, endX, endY, (i%2)+1);
  }    //end for
}    //end writeEdges

void writeEdgesRounded2Translated(float[][] edges, float[] translation) {
  //send them to the 3D printer, preserve the order of the edges: 0,1,...,edges.length-1
  float[][] edges2 = translatePoints(edges, translation);
  for (int i = 0; i< edges2.length; i++) {
    float finishDistance=slicedistance-(nozzleDiameter/DPMM);
    float startX = edges2[i][0];
    float startY = edges2[i][1];
    float endX   = edges2[i][2];
    float endY   = edges2[i][3];
    float amount = dist (startX, startY, endX, endY)/finishDistance;
    for (int j = 0; j+1 < amount; j = j+1) {
      float startX1 = lerp(startX, endX, j/amount);
      float startY1 = lerp(startY, endY, j/amount);
      float endX1 = lerp(startX, endX, (j+1)/amount);
      float endY1 = lerp(startY, endY, (j+1)/amount);
      edgeWriteRounded(startX1, startY1, endX1, endY1, 0);
    }
  }    //end for
}    //end writeEdges


void writeEdges2(float[][] edges) {
  //send them to the 3D printer, preserve the order of the edges: 0,1,...,edges.length-1
  float X=0;
  float Y=0;
  for (int i = 0; i< edges.length; i++) {
    X = X + ((edges[i][0]+edges[i][2])/2);
    Y = Y + ((edges[i][1]+edges[i][3])/2);
  }
  float endX   = X/edges.length;
  float endY   = Y/edges.length;
  edgeWrite2(endX, endY);
}    //end writeEdges

float[][]
allPrepChinese(float[][] allEdges) {
  //work from data in float[][] allEdges
  //show the points and the draw all edges, both contour and insole but
  //produce an optimal path through all of them using a chinese postman algorithm 
  //show the points
  for (int i = 0; i < nrInPoints; i++) {
    float X = inPoints[i][0];
    float Y = inPoints[i][1];
    //light red points
    stroke(255, 100, 100);
    ellipse(X, Y, 3, 3);
  }    
  //sh the edges
  //  print("ALLDRAWCHINESE WILL BEGIN NOW.. "); 
  float[][] vertices = vertices(allEdges);
  if (vertices.length < 2) return null;//otherwise the chinese postman crashes

  ChinesePostmanProblem G = new ChinesePostmanProblem(vertices.length);
  //add the arcs to the chines postman graph
  for (int i = 0; i < allEdges.length; i++) {
    float x1 = allEdges[i][0];
    float y1 = allEdges[i][1];
    float x2 = allEdges[i][2];
    float y2 = allEdges[i][3];
    float[] xy1 = new float[2]; 
    xy1[0] = x1; 
    xy1[1] = y1;
    float[] xy2 = new float[2]; 
    xy2[0] = x2; 
    xy2[1] = y2;
    boolean exiled1 = abs(xy1[0]) < 1 && abs(xy1[1]) < 1;
    boolean exiled2 = abs(xy2[0]) < 1 && abs(xy2[1]) < 1;
    if (!exiled1 && !exiled2) {
      int n1 = vertexNr(xy1, vertices);
      int n2 = vertexNr(xy2, vertices);
      int cost = 1;
      if (n1 < 0 || n2 < 0) println("ERROR 88, VERTEXNR CANNOT BE FOUND");
      G.addArc("new", n1, n2, cost);
      G.addArc("new", n2, n1, cost);//this is how we deploy an algorithm for @#$% directed graphs, just double every arc
    }
  }    //end for
  //G.showGraph();//only for debug
  G.solve();
  int[][] cppIndexEdges = G.printShoeCPT(vertices, 0);//startVertex 0
  //convert them to get rid of the vertex indexes
  //package in cppEdges
  float[][] cppEdges = new float[cppIndexEdges.length][];
  for (int i = 0; i< cppIndexEdges.length; i++) {
    //lookup the XY of the vertex from its index
    float startX = vertices[cppIndexEdges[i][0]] [0];
    float startY = vertices[cppIndexEdges[i][0]] [1];
    float endX   = vertices[cppIndexEdges[i][1]] [0];
    float endY   = vertices[cppIndexEdges[i][1]] [1];
    float edge[] = new float[4];
    edge[0] = startX;
    edge[1] = startY;
    edge[2] = endX;
    edge[3] = endY;
    cppEdges[i] = edge;
  }    //end for     
  return cppEdges;
} //end allDrawChinese

void insoleWrite() {
  //essentially a copy of insoleDraw, but this writes to  file

    //write the result as a set of edges
  txt.println(";INSOLE EDGES");

  for (int i=0; i<inEdges.length; i++) {
    if (inEdges[i] != null) {
      float startX = inEdges[i][0];
      float startY = inEdges[i][1];
      float endX = inEdges[i][2];
      float endY = inEdges[i][3];
      edgeWrite(startX, startY, endX, endY);
    }   //end if non null
  }    //end for
}//end insoleWrite

boolean isInside(float[][] contour, float[] point) {
  //draw a line from point to a very far-away point and then test for an odd number of intersects
  float[] edge = new float[4];
  edge[0] = point[0];
  edge[1] = point[1];
  edge[2] = -1.0;
  edge[3] = -1.0;
  return (intersects(contour, edge) % 2 == 1);
}

float
[][] pruneEdgesOLDSTUFF(float[][]coEdges, float[][] inEdges) {
  //shorten all inEdges so that they do not stick outside of the contour coEdges
  //this function modifies inEdges, not touching the contour (=coEdges)
  for (int i = 0; i < inEdges.length; i++) {
    float[] P1 = new float[2];//first point
    float[] P2 = new float[2];//second point
    P1[0] = inEdges[i][0];
    P1[1] = inEdges[i][1];
    P2[0] = inEdges[i][2];
    P2[1] = inEdges[i][3];
    if (!isInside(coEdges, P1) && !isInside(coEdges, P2)) {
      inEdges[i][0] = 0.1;
      inEdges[i][1] = 0.2;
      inEdges[i][2] = 0.1;
      inEdges[i][3] = 0.2;//exile them in some corner
    } else if (isInside(coEdges, P1) && isInside(coEdges, P2)) {
      //no pruning necessary
    } else if (!isInside(coEdges, P1) && isInside(coEdges, P2)) {
      float[] XY = intersectionpoint(coEdges, inEdges[i]);   
      inEdges[i][0] = XY[0];
      inEdges[i][1] = XY[1];
    }    //end if not inside
    else if (isInside(coEdges, P1) && !isInside(coEdges, P2)) {
      float[] XY = intersectionpoint(coEdges, inEdges[i]);   
      inEdges[i][2] = XY[0];
      inEdges[i][3] = XY[1];
    }   //end if not inside
  }    //    end for
  return inEdges;
}    //   end pruneEdgesOldStuff

float
[][] pruneEdges(float[][]coEdges, float[][] inEdges) {
  //shorten all inEdges so that they do not stick outside of the contour coEdges
  //this function modifies inEdges, not touching the contour (=coEdges)
  for (int i = 0; i < inEdges.length; i++) {
    boolean useful = false;
    float[] P1 = new float[2];//first point
    float[] P2 = new float[2];//second point
    P1[0] = inEdges[i][0];
    P1[1] = inEdges[i][1];
    P2[0] = inEdges[i][2];
    P2[1] = inEdges[i][3];
    if (isInside(coEdges, P1) && isInside(coEdges, P2)) {
      //good edge, dont touch
      useful = true;
    }

    if (!isInside(coEdges, P1) && !isInside(coEdges, P2)) {
      float[] XY1 = intersectionpoint(coEdges, inEdges[i]); 
      float[] XY2 = anotherintersectionpoint(coEdges, inEdges[i]);
      if (XY1 != null && XY2 != null) {
        inEdges[i][0] = XY1[0];
        inEdges[i][1] = XY1[1]; 
        inEdges[i][2] = XY2[0];
        inEdges[i][3] = XY2[1];
        //procrustes was here
        useful = true;
      }
      //pray there are no three intersection points
      //please, please, keep the contour convex
    }
    if (!isInside(coEdges, P1) && isInside(coEdges, P2)) {
      float[] XY = intersectionpoint(coEdges, inEdges[i]); 
      if (XY != null) {  
        inEdges[i][0] = XY[0];
        inEdges[i][1] = XY[1];
        useful = true;
      }
    }    //end if not inside
    if (isInside(coEdges, P1) && !isInside(coEdges, P2)) {
      float[] XY = intersectionpoint(coEdges, inEdges[i]);   
      if (XY != null) { 
        inEdges[i][2] = XY[0];
        inEdges[i][3] = XY[1];
        useful = true;
      }
    }   //end if not inside
    //perhaps it still really outside, despite all the repair work,
    //in which case it is really not useful indeed (exile it).
    if (!useful) {
      inEdges[i][0] = 0.11;
      inEdges[i][1] = 0.21;
      inEdges[i][2] = 0.10;
      inEdges[i][3] = 0.20;//exile them in some corner
    }
  }    //    end for
  return inEdges;
}    //   end pruneEdges

float
[][] refineEdges(float[][] coEdges, float[][] inEdges) {
  //split the contour edges which meet an insole edge so later we can have good cells. Not modify coEdges
  //this function returns a kind of modified contour, not touching inEdges, run it BEFORE pruning inEdges

    //first accumulate things in a fresh array (which is sufficiently large, even larger)
  float[][] newCoEdges = new float[coEdges.length + inEdges.length][4];
  int nrNewCoEdges = 0;
  for (int i = 0; i < coEdges.length; i++) {
    //  consider contour edge indexed i:
    float[] PB = new float[2];//begin point
    PB[0] = coEdges[i][0];
    PB[1] = coEdges[i][1];
    //be prepared to find many intersection points: 
    float IPTS[][] = new float[inEdges.length][2];
    int nrIPTS = 0;
    for (int j = 0; j < inEdges.length; j++) {
      float[] IP = intersectionpoint(coEdges[i], inEdges[j]);
      if (IP != null)
        IPTS[nrIPTS++] = IP;
    }
    //sort them with respect to distance from PB
    //use a classical selection sort algorithm
    float[] tmp;
    for (int k = 0; k < nrIPTS; k++) {
      // when here: k smallest values are sorted in 0..k-1
      int mink = k;
      for (int l = k; l < nrIPTS; l++) {
        // when here: mink is index of smallest in k..l-1
        if (dist(PB[0], PB[1], IPTS[l][0], IPTS[l][1]) <  dist(PB[0], PB[1], IPTS[mink][0], IPTS[mink][1]))  
          //so point at l is more near to PB than point at mink
          mink = l;
      }
      // swap intersection points at indexes k and mink
      tmp = IPTS[k]; 
      IPTS[k] = IPTS[mink]; 
      IPTS[mink] = tmp;
    }
    //next use all of these to add nrIPTS + 1 edges
    float[] PE = new float[2];//end point
    PE[0] = coEdges[i][2];
    PE[1] = coEdges[i][3];   
    float PBx = PB[0];
    float PBy = PB[1];
    float PEx;
    float PEy;
    for (int m = 0; m < nrIPTS; m++) {
      PEx = IPTS[m][0];
      PEy = IPTS[m][1];
      float newEdge[] = new float[4];
      newEdge[0] = PBx;
      newEdge[1] = PBy;
      newEdge[2] = PEx;
      newEdge[3] = PEy;
      newCoEdges[nrNewCoEdges++] = newEdge; 
      PBx = PEx;
      PBy = PEy;
    }
    PEx = PE[0];
    PEy = PE[1];
    float newEdge[] = new float[4];
    newEdge[0] = PBx;
    newEdge[1] = PBy;
    newEdge[2] = PEx;
    newEdge[3] = PEy;           
    newCoEdges[nrNewCoEdges++] = newEdge;
  }    //end for each contour edge indexed i
  //repack everything in coEdges fitting precisely
  coEdges = new float[nrNewCoEdges][];
  for (int i = 0; i < nrNewCoEdges; i++) 
    coEdges[i] = newCoEdges[i];
  return coEdges;
}    //end refineEdges

//allEdges, vertexNr, vertices etc: prepare for doing some graph theory

float
[][] allEdges(float[][] coEdges, float[][] inEdges) {
  //combine both sets of edges into a single array,
  //do not include exiled edges, repack so it fits precisely
  float[][] all = new float[coEdges.length + inEdges.length][];
  int nrAll = 0;
  for (int i = 0; i < coEdges.length; i++) 
    if (coEdges[i] != null)
      if (abs(coEdges[i][0]) > 1 && abs(coEdges[i][1]) > 1)
        all[nrAll++] = coEdges[i];      
  for (int j = 0; j < inEdges.length; j++) 
    if (inEdges[j] != null)
      if (abs(inEdges[j][0]) > 1 && abs(inEdges[j][1]) > 1)
        all[nrAll++] = inEdges[j];  
  //repack all into an array allall of correct size
  float[][] allall = new float[nrAll][];
  for (int j = 0; j < nrAll; j++)
    allall[j] = all[j];
  return allall;
}


int vertexNr(float[] xy, float[][] vertices) {
  //find the position of coordinate pair xy in given table of vertices.
  //An alternative approach would be to build a real graph structure (later perhaps).
  //Now everything is in these {x,y} and {x1,y1,x2,y2} arrays of type float[][].
  int aha = -1;
  boolean found = false;
  for (int i = 0; !found && i < vertices.length; i++)
    if (EQ(vertices[i][0], xy[0]) && EQ(vertices[i][1], xy[1])) {
      found = true;
      aha = i;
    } 
  return aha;
}

float
[][] vertices(float[][] edges) {
  //derive a table of vertices for the graph whose edges are given,
  //first insert in a local array v which is sufficienly large, then pack in fitting array
  int nrV = 0;
  float[][] v = new float[2*edges.length][];
  for (int i = 0; i < edges.length; i++) {
    //look if the begin (x,y) is in the table already
    boolean found = false;
    for (int j = 0; !found && j < nrV; j++)
      if (EQ(edges[i][0], v[j][0]) && EQ(edges[i][1], v[j][1]))
        found = true; 
    if (!found) {
      //begin (x,y) is not in the table yet, add it
      float[] xy = new float[2];
      xy[0] = edges[i][0];
      xy[1] = edges[i][1];
      boolean exiled = abs(xy[0]) < 1 && abs(xy[1]) < 1;
      if (!exiled) v[nrV++] = xy;
    }   //end if
    //next look if the end (x,y) is in the table already
    found = false;
    for (int j = 0; !found && j < nrV; j++)
      if (EQ(edges[i][2], v[j][0]) && EQ(edges[i][3], v[j][1]))
        found = true; 
    if (!found) {
      //begin (x,y) is not in the table yet, add it
      float[] xy = new float[2];
      xy[0] = edges[i][2];
      xy[1] = edges[i][3];
      boolean exiled = abs(xy[0]) < 1 && abs(xy[1]) < 1;
      if (!exiled) v[nrV++] = xy;
    }   //end if
  }    //end for
  //repack v into an array vv of correct size
  float[][] vv = new float[nrV][];
  for (int j = 0; j < nrV; j++)
    vv[j] = v[j];
  return vv;
}

public String nf(float num) {
  //hmm, somehow this was not in processing 2.x
  //found at github.com/processing/processing/blob/master/core/src/processing/core/PApplet.java
  int inum = (int) num;
  if (num == inum) {
    return str(inum);
  }
  return str(num);
}

boolean EQ(float A, float B) {
  //"almost equal" test (yes, I know it is tricky, see Bruce Dawson's blog)
  //use for pixel indexes or screen mm, not for arbitrary scientific math
  float epsilon = 0.01;
  if (A == B) return true; 
  else return abs(A - B) < epsilon;
} 

void startGcode() {// currently for a Prusa i3 mk2 multimat 
  txt.println(";FLAVOR:Marlin");
  txt.println("; TIME:400");
  txt.println(";MATERIAL:160");
  txt.println("; MATERIAL2: 0");
  txt.println(";NOZZLE_DIAMETER: " +nozzleDiameter);
  //  txt.println(";NOZZLE_DIAMETER2: 0.800000");
  txt.println(";Layer count: " + nf(layersTotal));
  txt.println(";LAYER:0");
  txt.println("M82 ; absolute extrusion mode");
  txt.println("G21 ; set units to millimeters");
  txt.println("G90 ; use absolute positioning");
  txt.println("M82 ; absolute extrusion mode");
  txt.println("M104 S210 ; set extruder temp");
  txt.println("M140 S60 ; set bed temp");
  txt.println("M190 S60 ; wait for bed temp");
  txt.println("M109 S210 ; wait for extruder temp");
  txt.println("G28 W ; home all without mesh bed level");
  txt.println("G80 ; mesh bed leveling");
  txt.println("G92 E0.0 ; reset extruder distance position");
  txt.println("G1 Y-3.0 F1000.0 ; go outside print area");
  txt.println("G1 X60.0 E9.0 F1000.0 ; intro line");
  txt.println("G1 X100.0 E21.5 F1000.0 ; intro line");
  txt.println("G92 E0.0 ; reset extruder distance position");
  txt.println("M107");
  txt.println("G0 F9000 X10 Y110");
  txt.println("G0  F"+nf(speed)); //Start Layer
  txt.println(";Generated with:" + SVGShape);
  txt.println(";Copyright 2017 Troy Nachtigall, Loe Feijs and Bart Pruijmboom");
}

void endGcode() {// currently for a Prusa i3 mk2 multimat 
  txt.println("G0 F9000 X110.000 Y126.900 Z" + nf(currentLayer+15)");
  txt.println("M107");
  txt.println("M104 S0 ; turn off extruder");
  txt.println("M140 S0 ; turn off heatbed");
  txt.println("M107 ; turn off fan");
  txt.println("G1 X0 Y210; home X axis and push Y forward");
  txt.println("M84 ; disable motors");
  txt.println("M84 ; disable motors");
  txt.println("M82 ; absolute extrusion mode");
  txt.println("M104 S0");
  txt.println(";End of Gcode");
  
 }


void layerStart() {
  currentLayer = currentLayer + layerHeight;
  txt.println("G0  F"+nf(speed) +" Z"+nf(currentLayer));
  txt.println("M117 "+ nf(int(currentLayer/layerHeight)) + " out of " + nf(layersTotal) + "state is " + state);
}

void setSpeed() {
  txt.println("G0  F"+nf(speed));
}

void keyPressed() {
  if (key == '0') grid = 0;
  if (key == '1') grid = 1;
  if (key == '2') grid = 2;
  if (key == '3') grid = 3;
  if (key == '4') grid = 4;
  if (key == '5') grid = 5;
  if (key == '6') grid = 6;
  if (key == '7') grid = 7;
  if (key == '8') grid = 8;
  if (key == '9') grid = 9;  
  if (key == 'z' || key == ' ')
    setup();
  if (key == 'c' || key == 'C') {
    mode = CONTOUR;
    if (mode == CONTOUR && nrCoPoints < MAXNRCOPOINTS) {
      if (pointPaths[0] != null) {
        for (int j = 0; j<pointPaths[0].length; j++) {
          coPoints[j][0] = pointPaths[0][j].x;
          coPoints[j][1] = pointPaths[0][j].y;
          nrCoPoints++;
        }
      }
      if (pointPaths2[0] != null) {
        for (int j = 0; j<pointPaths2[0].length; j++) {
          insolePoints[j][0] = pointPaths2[0][j].x;
          insolePoints[j][1] = pointPaths2[0][j].y;
          nrInsolePoints++;
        }
      }
    }
    insolePoints = removeAfter(insolePoints, nrInsolePoints);
    coPoints = removeAfter(coPoints, nrCoPoints);
    update();
  }
  if (key == 'i' || key == 'I') {
    mode = INSOLE;
    println("ENTERING INSOLE MODE");
    println("TYPE 't'TO GO TO TREAD MODE");
    update();
  }
  if (key == 't' || key == 'T') {
    mode = TREAD;
    println("ENTERING TREAD MODE");
    println("TYPE 'd' TO DEFINE DENSITY");
    MyCurve = new AUCurve(coPoints, 2, true);

    for (int i = 0; i < numCoPointSteps; i++) {
      float t = norm(i, 0, numCoPointSteps);
      coPointsCurve[i][0] = MyCurve.getX(t);
      coPointsCurve[i][1] = MyCurve.getY(t);
      println(coPointsCurve[i][0]);
      println(coPointsCurve[i][1]);
    }
    update();
  }
  if (key == 'd' || key == 'D') {
    mode = DENSITY;
    tsTrDensity = new float[tsTrPolygons.length];
    for (int i = 0; i<tsTrPolygons.length; i++) {
      if (tsTrPolygons[i] != null ) {
        tsTrDensity[i] = sensorDensity(tsTrPolygons[i]);
      }
    }
    println("ENTERING DENSITY MODE");
    println("TYPE 'p' TO END AND PRINT PDF");
    update();
  }
  if (key == 'u' || key == 'U') {
    mode=UPPERS;
    println("ENTERING UPPER MODE");
    println("TYPE 'u' TO ADJUST UPPERS");
    update();
  }
  if (key == 'p'|| key == 'P') {
    // stop and print pdf and other media
    SimpleDateFormat sdf = new SimpleDateFormat("-yyyy-MM-dd/HH-mm"); 
    Date now = new Date(); 
    println("write to files SOLE"+sdf.format(now)+".pdf"
      + " and "+"SOLE"+sdf.format(now)+".txt" 
      + " and "+"SOLE"+sdf.format(now)+".dst");

    pdf =  (PGraphicsPDF) beginRecord(PDF, "SOLE"+sdf.format(now) + ".pdf");
    //    b = new Brother(this, 0, XSIZE, 0, YSIZE);
    //    b.beginRecordBrother("SOLE"+sdf.format(now) + ".dst");
    //b.rect(10 * DPMM, 10 * DPMM, 100 * DPMM, 10 * DPMM);//test for calibration
    txt = createWriter("SOLE"+sdf.format(now) + ".gcode");
    update(); 
    update2(tsTrDensity);
    startGcode();
    slicing();
    endGcode(); 
    txt.flush(); 
    txt.close(); 
    endRecord();
    exit();
  }
  if (key == 'o'|| key == 'O') { //Create a series of sample discs to test TPU Conductivity
    // stop and print pdf and other media
    SimpleDateFormat sdf = new SimpleDateFormat("-yyyy-MM-dd/HH-mm"); //create a folder with todays date
    Date now = new Date(); 
    println("write to files SOLE"+sdf.format(now)+".pdf"
      + " and "+"SOLE"+sdf.format(now)+".txt" 
      + " and "+"SOLE"+sdf.format(now)+".dst");

    pdf =  (PGraphicsPDF) beginRecord(PDF, "Test"+sdf.format(now) + ".pdf");//create a reference pdf
    //    b = new Brother(this, 0, XSIZE, 0, YSIZE);
    //    b.beginRecordBrother("SOLE"+sdf.format(now) + ".dst");
    //b.rect(10 * DPMM, 10 * DPMM, 100 * DPMM, 10 * DPMM);//test for calibration
    for (layersSensor = 4; layersSensor < 20; layersSensor=layersSensor*2) {//Create 3 Different heights of sensors
      for (infillSensor = 2; infillSensor < 5; infillSensor++) { //create 3 different infill densities
        txt = createWriter("Infill"+infillSensor+"Layers"+ layersSensor+sdf.format(now) + ".gcode");//File
        update(); //create the array
        update2(tsTrDensity);//set infill density
        startGcode();//write the gCode
        slicing();
        endGcode(); 
        txt.flush(); //close the file
        txt.close(); 
        endRecord();
      }
    }
  }
}
void pauseUM() {
  txt.println(" G0 X20 Y20 Z " + nf(currentLayer+50));
  txt.println("M0");
}

void slicing() {
  currentLayer = layerHeight/2;
  speed = speed1/2;
  slicedistance=nozzleDiameter;

  state = "base";
  for (int i = 0; i < 1; i++) {
    layerStart();
    writeEdgesTranslated(coEdges, fitShoe);
    int hoi  = maxInsetSteps(coEdges, -slicedistance);
    if (i%3 ==2) {
      for (int k = 1; k<hoi; k++) {
        float[][] sick = unionPolygon(coEdges, -k*slicedistance);
        writeEdgesTranslated(sick, fitShoe);
      }
    } else if (i%3 == 1) {
      speed = speed1;
      writeEdgesTranslated(arrangeEdges(slicePolygonX(coEdges)), fitShoe);
    } else {
      writeEdgesTranslated(arrangeEdges(slicePolygonY(coEdges)), fitShoe);
    }
  }
  state = "base infill";
  slicedistance=nozzleDiameter * 3.5 ;
  speed= speed2;
  for (int i = 0; i < layersContourBottom-2; i++) {
    layerStart();
    writeEdgesTranslated(coEdges, fitShoe);
    int hoi  = maxInsetSteps(coEdges, -slicedistance);
    if (i%2 == 1) {
      writeEdgesTranslated(arrangeEdges(slicePolygonX(coEdges)), fitShoe);
    } else {
      writeEdgesTranslated(arrangeEdges(slicePolygonY(coEdges)), fitShoe);
    }
  }

  pauseUM();

  state = "Sensor base";
  slicedistance = nozzleDiameter;
  speed = speed1/2;
  for (int i = 0; i < 2; i++) {
    layerStart();
    writeEdgesTranslated(coEdges, fitShoe);
    int hoi  = maxInsetSteps(coEdges, -slicedistance);
    if (i%3 ==2) {
      for (int k = 1; k<hoi; k++) {
        float[][] sick = unionPolygon(coEdges, -k*slicedistance);
        writeEdgesTranslated(sick, fitShoe);
      }
    } else if (i%3 == 1) {
      speed = speed2;
      writeEdgesTranslated(arrangeEdges(slicePolygonX(coEdges)), fitShoe);
    } else {
      speed = speed2;
      writeEdgesTranslated(arrangeEdges(slicePolygonY(coEdges)), fitShoe);
    }
  }
  state = "Sensor Infill";
  speed= speed1;
  slicedistance=nozzleDiameter*infillSensor;
  speed= speed2;
  for (int i = 0; i < layersSensor; i++) {
    layerStart();
    writeEdgesTranslated(coEdges, fitShoe);
    int hoi  = maxInsetSteps(coEdges, -slicedistance);
    if (i%2 == 1) {
      writeEdgesTranslated(arrangeEdges(slicePolygonX(coEdges)), fitShoe);
    } else {
      writeEdgesTranslated(arrangeEdges(slicePolygonY(coEdges)), fitShoe);
    }
  }
  pauseUM();
  state = "Sensor roof";
  slicedistance=nozzleDiameter;
  speed= speed1;
  for (int i = 0; i < 2; i++) {
    layerStart();     
    //writeEdges(stpTrEdges);
    //writeEdgesTranslated(stpInEdges, fitShoe);
    int hoi  = maxInsetSteps(coEdges, -slicedistance);
    if (i%3 ==2) {
      for (int k = 1; k<hoi; k++) {
        float[][] sick = unionPolygon(coEdges, -k*slicedistance);
        writeEdgesTranslated(sick, fitShoe);
      }
    } else if (i%3 == 1) {
      writeEdgesTranslated(arrangeEdges(slicePolygonX(coEdges)), fitShoe);
    } else {
      writeEdgesTranslated(arrangeEdges(slicePolygonY(coEdges)), fitShoe);
    }
  }
  pauseUM();
 


/*
  speed= speed2;
  state = "profile Sensor";
  float IMLayer = currentLayer+layerHeight;
  pauseUM();
  for (int i =0; i<layersProfileTotal/layersProfileAtOnce; i++) {//groups of layers at the same time
    for (int j =0; j<tsTrPolygons.length; j++) {
      if (tsTrPolygons[j] !=null&&tsTrPolygons[j].length > 1) {
        for (int n=0; n<layersProfileAtOnce; n++) {//run a group of layers
          currentLayer = IMLayer + ((i*layersProfileAtOnce)+n)*layerHeight; //intermediate Layer height calculation
          if (n%2 ==0) {
            writeEdgesTranslated(slicePolygonY(unionPolygon(tsTrPolygons[j], -polygonOffSet)), fitShoe);
          } else {
            writeEdgesTranslated(slicePolygonX(unionPolygon(tsTrPolygons[j], -polygonOffSet)), fitShoe);
          }
          println("inset", -(polygonOffSet+map((i*layersProfileAtOnce)+n, 0, layersProfileTotal, 0, 1*DPMM)));
        }
      }
    }
  }

*/
  state = "profile";
  IMLayer = currentLayer+layerHeight;
  for (int i =0; i<layersProfileTotal/layersProfileAtOnce; i++) {//groups of layers at the same time
    if ((i==layersProfileTotal/layersProfileAtOnce - 1)||(i==layersProfileTotal/layersProfileAtOnce - 2)) {//Color change on the last two layers.
      pauseUM();
    }
    for (int j =0; j<tsTrPolygons.length; j++) {
      if (tsTrPolygons[j] !=null&&tsTrPolygons[j].length > 1) {
        float[] YCenter = gCenter(tsTrPolygons[j]);
        float[] MMContour = MaxMinPolygon(coEdges);
        for (int n=0; n<layersProfileAtOnce; n++) {//run a group of layers
          currentLayer = IMLayer + ((i*layersProfileAtOnce)+n)*layerHeight; //intermediate Layer height calculation
          float[][] sick = unionPolygon(tsTrPolygons[j], -(polygonOffSet+map((i*layersProfileAtOnce)+n, 0, layersProfileTotal, 0, 1*DPMM)));
          writeEdgesTranslated(sick, fitShoe);
          float[] sizePolygon = sizePolygon(sick);
          float density= tsTrDensity[j];
          int cLines=int((((sizePolygon[1]+sizePolygon[0])/2)*tsTrDensity[j])/(2*nozzleDiameter));
          println(density + " " + cLines);

          for (int k = 1; k+1<cLines; k++) {
            writeEdgesTranslated(scalePolygon(sick, 1-map(k, 0, cLines, 0, 1)), fitShoe);
          }

          for (int l = 0; l<sick.length; l++) {
            float[][] inwardsLines1 = new float[cLines*sick.length][4];
            for (int m = 0; m<cLines; m++) {
              float[][] inwardsLines2 = scalePolygon(sick, 1-map(m+1, 0, cLines, 1, 0));
              float[][] inwardsLines3 = scalePolygon(sick, 1-map(m, 0, cLines, 1, 0));
              inwardsLines1[(l*m)+m][0] = inwardsLines3[l][0];
              inwardsLines1[(l*m)+m][1] = inwardsLines3[l][1];
              inwardsLines1[(l*m)+m][2] = inwardsLines2[l][0];
              inwardsLines1[(l*m)+m][3] = inwardsLines2[l][1];
            } 
            if (n%layersProfileAtOnce==0) {//once every n lines
              writeEdgesTranslated(inwardsLines1, fitShoe); //writes the inlines
            }
          }
        }
      }
    }
  }
}

