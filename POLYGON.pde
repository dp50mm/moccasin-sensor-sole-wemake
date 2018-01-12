//Darsh Ranjan, May 8, '10: I'll assume the graph is connected, and that you have the clockwise or 
//counterclockwise ordering of the edges around each vertex. Then it's easy, given a directed edge e, 
//to walk around the face whose counterclockwise boundary contains e. 
//So make a list of all directed edges (i. e., two copies of each undirected edge). 
//Pick one directed edge, walk counterclockwise around its face, and cross off all the directed edges you traverse. 
//That's one face. Pick a directed edge you haven't crossed off yet and walk around its face the same way. 
//Keep doing that until you've crossed off all of the edges. 
//(Note that the "counterclockwise" boundary of the exterior unbounded face actually goes 
//clockwise around the outside of the graph.) From: http://mathoverflow.net/questions/23811/reporting-all-faces-in-a-planar-graph

boolean noNullEdges(float[][] edges) {
  boolean found = false;
  for (int i = 0; i < edges.length; i++)
    if (edges[i] == null)
      found = true;
  return  !found;
}       //for debug testing and quality assurance

boolean noNullPolygons(float[][][] polygons) {
  boolean found = false;
  for (int i = 0; i < polygons.length; i++)
    if (polygons[i] == null)
      found = true;
  return  !found;
}       //for debug testing and quality assurance

boolean noDuplicateEdges(float[][] allEdges) {
  boolean found = false;
  for (int i = 0; i < allEdges.length; i++) {
    float xi1 = allEdges[i][0];
    float yi1 = allEdges[i][1];
    float xi2 = allEdges[i][2];
    float yi2 = allEdges[i][3];
    for (int j = 0; j < allEdges.length; j++) {
      float xj1 = allEdges[j][0];
      float yj1 = allEdges[j][1];
      float xj2 = allEdges[j][2];
      float yj2 = allEdges[j][3];
      if (EQ(xi1, xj1) && EQ(yi1, yj1) && EQ(xi2, xj2) && EQ(yi2, yj2))
        if (i != j) 
          found = true;
    }
  }
  return !found;
}       //for debug testing and quality assurance

float [][][]
makePolygons(float[][] allEdges) {
  float[][] allEdgesTwice = new float[2 * allEdges.length][];
  //embed a flipped twin copy
  for (int i = 0; i < allEdges.length; i++) {
    float x1 = allEdges[i][0];
    float y1 = allEdges[i][1];
    float x2 = allEdges[i][2];
    float y2 = allEdges[i][3];
    float[] copied = new float[4];
    copied[0] = x1;
    copied[1] = y1;
    copied[2] = x2;
    copied[3] = y2;  
    float[] flipped = new float[4];                  
    flipped[0] = x2;
    flipped[1] = y2;
    flipped[2] = x1;
    flipped[3] = y1;
    allEdgesTwice[i] = copied;
    allEdgesTwice[allEdges.length + i] = flipped;
    //each edge now occurs twice, once for each direction,
    //later nullify each (directed) edge when added to polygon
  }     // end for i

  //first give a sneak preview of numbered copieds and twins on the screen for debugging
  boolean DISPLAYNUMBERS = false;//VERBOSE
  if (DISPLAYNUMBERS)
    for (int i = 0; i < allEdgesTwice.length; i++) {
      float x1 = allEdgesTwice[i][0];
      float y1 = allEdgesTwice[i][1];
      float x2 = allEdgesTwice[i][2];
      float y2 = allEdgesTwice[i][3]; 
      fill(0); 
      textSize(14);
      int offset = 14;
      text(str(i), (2*x1 + x2)/3, offset + (2*y1 + y2)/3);//number appears near begin edge
    }     

  //lets hope the number of polygons is less than number of edges:
  float[][][] polygons = new float[allEdges.length][][];
  //try to get rid of the very first one, it hopefully is the outer face:
  float[][] outer_face = makePolygon(allEdgesTwice, 0);
  //look for other available edges:
  int nrPolygons = 0;
  boolean found = true;
  while (found) {
    int aha = -1;
    for (int i = 0; i < allEdgesTwice.length; i++)
      if (allEdgesTwice[i] != null)
        aha = i;
    found = (aha > -1);
    if (found)
      polygons[nrPolygons++] = makePolygon(allEdgesTwice, aha);
  }        
  return polygons;
}     //end akePolygons

float [][]
makePolygon(float[][] allEdgesTwice, int STARTI) {     
  //serious algorithmics, PolygonTheory.pptx
  //just do one polygon at a time
  //when ready, return one polygon

  print("MAKEPOLYGON WILL BEGIN NOW.. "); 
  print("allEdgesTwice.length = "); 
  //  println(allEdgesTwice.length);
  //  if (!noNullEdges(allEdgesTwice)) println("ERROR 88: NULL EDGE FOUND IN ALLEDGESTWICE");

  float[][] edges = new float[allEdgesTwice.length][]; //polygon of edges going round, counter clockwise, fill now
  int[] indxs = new int[2*allEdgesTwice.length]; //idem indexes thereof
  int nrEdges = 0;//howmany edges (= howmany edges) in this polygon 

  int i = STARTI;
  boolean back_home;
  do { 
    //    println("DO");
    //    println("   i is " + i);

    //copy current edge i into local edge
    float[] edge = new float[4];
    for (int k = 0; k < 4; k++)
      edge[k] = allEdgesTwice[i][k];
    //add that to the polygon 
    indxs[nrEdges] = i;
    edges[nrEdges++] = edge;
    //tell what we have got so far
    //    print("indxs: "); 
    //    for (int j = 0; j < nrEdges; j++) print(" " + indxs[j] + " "); 
    //    println();

    //take the end vertex of inserted edge, looking around from (cx,cy) who's next (if not back home)

    float cx = edge[2];
    float cy = edge[3];

    float[] first_edge = edges[0];
    back_home = EQ(cx, first_edge[0]) && EQ(cy, first_edge[1]);
    if (back_home == false) {
      //flip edge, later to be nullified anyhow
      allEdgesTwice[i][2] = edge[0];
      allEdgesTwice[i][3] = edge[1];
      allEdgesTwice[i][0] = cx;
      allEdgesTwice[i][1] = cy;
      //find all (indexes j of) neighbours cx,cy, testing for (cx,cy)-begin match
      int[] neighbours = new int[allEdgesTwice.length / 2];//should be enough
      int nrNeighbours = 0;
      //will automatically include flipped self
      for (int j = 0; j < allEdgesTwice.length; j++)
        if (allEdgesTwice[j] != null)    
          //look for edges beginning at (cx,cy)
          if (EQ(allEdgesTwice[j][0], cx) && EQ(allEdgesTwice[j][1], cy))
            if (abs(i - j) != allEdgesTwice.length / 2)//skip one's own twin
              neighbours[nrNeighbours++] = j; 
      //      println("   nrNeighbours is " + nrNeighbours);     

      //we assembled the edge end points from (cx,cy) perspective, now
      //sort them with respect to heir outgoing direction arctan
      //use a classical selection sort algorithm
      int tmp;
      for (int k = 0; k < nrNeighbours; k++) {
        // when here: k smallest values are sorted in 0..k-1
        int min_k = k;
        for (int l = k; l < nrNeighbours; l++) {
          // when here: mink is index of smallest in k..l-1
          if ( atan2(allEdgesTwice[neighbours[    l]][3] - cy, allEdgesTwice[neighbours[    l]][2] - cx) 
            < atan2(allEdgesTwice[neighbours[min_k]][3] - cy, allEdgesTwice[neighbours[min_k]][2] - cx)
            )
            min_k = l;
        }
        // swap intersection points at indexes k and mink
        tmp = neighbours[k]; 
        neighbours[k] = neighbours[min_k]; 
        neighbours[min_k] = tmp;
      }

      //      for (int j = 0; j < nrNeighbours; j++)
      //        println("   neighbour " + neighbours[j]);

      //find flipped self among the sorted neighbours
      int aha = 0;
      for (int j = 0; j < nrNeighbours; j++)
        if (neighbours[j] == i)
          aha = j;

      allEdgesTwice[i] = null; //done

      //take the successor of this edge, going clockwise around the face
      int new_i = neighbours[(aha + 1) % nrNeighbours];
      //      println("  new_i is " + new_i);
      edge = allEdgesTwice[new_i];
      //      if (edge == null) println("ERROR 44 (OEPS): NULL edge in POLYGON MAKING");
      i = new_i;
    } //end if back_home == false
    else allEdgesTwice[i] = null; //done
  }    
  while (back_home == false);

  //copy the edges into a fresh array and return that
  float[][] polygon = new float[nrEdges][];
  for (int j = 0; j < nrEdges; j++) {
    polygon[j] = new float[4];
    for (int k = 0; k < 4; k++)
      polygon[j][k] = edges[j][k];
  }    //end for
  return polygon;
}     //end makePolygon  

float[] 
gCenter(float[][] polygon) {
  //return x,y point which is center of gravity 
  //i.e. center of gravity of the contour points, 
  //not the mass of the surface area.
  float gx = 0;
  float gy = 0;
  for (int j = 0; j < polygon.length; j++) {
    gx += polygon[j][0];
    gy += polygon[j][1];
  }

  gx = gx / polygon.length;
  gy = gy / polygon.length;
  //pack results
  float[] g = new float[2];
  g[0] = gx;
  g[1] = gy;
  return g;
}

float[]
mCenter(float[][] polygon) {
  //return x,y point where x is midrange of the x coordinates of vertices, idem y
  float minX = 1000000;
  float maxX = -1000000;
  float minY = 1000000;
  float maxY = -1000000;
  //first search for the extremes X and Y:
  for (int i = 0; i < polygon.length; i++) {
    float startX = polygon[i][0];
    float startY = polygon[i][1];
    float endX   = polygon[i][2];
    float endY   = polygon[i][3];

    if (startX <= minX) minX = startX;
    if (startX >= maxX) maxX = startX;
    if (endX   <= minX) minX = endX;
    if (endX   >= maxX) maxX = endX;

    if (startY <= minY) minY = startY;
    if (startY >= maxY) maxY = startY;
    if (endY   <= minY) minY = endY;
    if (endY   >= maxY) maxY = endY;
  }
  float mx = (minX + maxX) /2;
  float my = (minY + maxY) /2;
  //pack results
  float[] m = new float[2];
  m[0] = mx;
  m[1] = my;
  return m;
}

float[][]
scalePolygon(float[][] polygon, float scale) {
  float[] g = mCenter(polygon);
  float gx = g[0];
  float gy = g[1];
  //now we have (gx,gy) being the midrange center
  //shrink everything towards the center
  float[][] scaled = new float[polygon.length][];
  for (int j = 0; j < polygon.length; j++) {
    float[] edge = new float[4];
    edge[0] = scale * polygon[j][0] + (1 - scale) * gx;
    edge[1] = scale * polygon[j][1] + (1 - scale) * gy;
    edge[2] = scale * polygon[j][2] + (1 - scale) * gx;
    edge[3] = scale * polygon[j][3] + (1 - scale) * gy; 
    scaled[j] = edge;//test only, was edge;
  }    //end for
  return scaled;
}    //end displayPolygon

float[][][]
scalePolygons(float[][][] polygons, float scale) {
  //scale them all, return an array of polygons
  float[][][] scaleds = new float[polygons.length][][];
  for (int i = 0; i < polygons.length; i++)
    if (polygons[i] != null)
      scaleds[i] = scalePolygon(polygons[i], scale); 
  return scaleds;
}

float[][] scaleStartEndLine(float[][] polygon, float startPercentage, float endPercentage, float scale) {
  int startPoint;
  int endPoint; 
  if (startPercentage < endPercentage) {
    startPoint = int(polygon.length*startPercentage); 
    endPoint = int(polygon.length*endPercentage);
  } else {
    startPoint = int(polygon.length*endPercentage);
    endPoint = int(polygon.length*startPercentage);
  }

  float[] topPointEdges = MaxMinPolygon(polygon);
  int topPoint;
  int checkpoint=0;
  int state = 0;
  while (state == 0 && checkpoint <= polygon.length-1) {
    if (polygon[checkpoint][0] == topPointEdges[0] && polygon[checkpoint][1] == topPointEdges[1]) {
      topPoint = checkpoint;
      state = 1;
    }
    checkpoint++;
  }
  float[][] returnArray = polygon;

  return returnArray;
}

float[] sizePolygon(float[][] polygon) {
  float[] sizes = new float[2];
  float minX=10000;
  float maxX=0;
  float minY=10000;
  float maxY=0;

  for (int i =0; i<polygon.length; i++) {
    if (polygon[i][0] < minX) {
      minX = polygon[i][0];
    }
    if (polygon[i][0] > maxX) {
      maxX = polygon[i][0];
    }

    if (polygon[i][1] < minY) {
      minY = polygon[i][1];
    }
    if (polygon[i][1] > maxY) {
      maxY = polygon[i][1];
    }
  }
  sizes[0] = maxX-minX;
  sizes[1] = maxY-minY;


  return sizes;
}

float[] MaxMinPolygon(float[][] polygon) {
  float[] sizes = new float[4];
  float minX=10000;
  float maxX=0;
  float minY=10000;
  float maxY=0;

  for (int i =0; i<polygon.length; i++) {
    if (polygon[i][0] < minX) {
      minX = polygon[i][0];
    }
    if (polygon[i][0] > maxX) {
      maxX = polygon[i][0];
    }

    if (polygon[i][1] < minY) {
      minY = polygon[i][1];
    }
    if (polygon[i][1] > maxY) {
      maxY = polygon[i][1];
    }
  }
  sizes[0] = minX;
  sizes[1] = minY;
  sizes[2] = maxX;
  sizes[3] = maxY;

  return sizes;
}



float[][][] arrangePolygonsTB(float[][][] polygons) {
  float[][][] arrangedPolygons = new float[polygons.length][][];
  int counter = 0;
  int directionCounter =0;
  for (float i = 0; i< XSIZE; i = i + sensorSize) {
    if (directionCounter%2 == 0) {
      for (float k = 0; k< YSIZE; k = k + sensorSize) {
        for (int j =0; j<polygons.length; j++) {
          if (polygons[j] != null) {
            float[] center = gCenter(polygons[j]);
            if (center[0] >= i - (0.5*sensorSize) && center[0] <= i + (0.5*sensorSize)) {
              if (center[1] >= k - (0.5*sensorSize) && center[1] <= k + (0.5*sensorSize)) {
                arrangedPolygons[counter]= polygons[j];
                arrangedPolygons[counter]= polygons[j];
                counter++;
              }
            }
          }
        }
      }
    } else if ( directionCounter%2 ==1) {
      for (float k = YSIZE; k>0; k = k - sensorSize) {
        for (int j =0; j<polygons.length; j++) {
          if (polygons[j] != null) {
            float[] center = gCenter(polygons[j]);
            if (center[0] >= i - (0.5*sensorSize) && center[0] <= i + (0.5*sensorSize)) {
              if (center[1] >= k - (0.5*sensorSize) && center[1] <= k + (0.5*sensorSize)) {
                arrangedPolygons[counter]= polygons[j];
                arrangedPolygons[counter]= polygons[j];
                counter++;
              }
            }
          }
        }
      }
    }
    directionCounter++;
  }
  return arrangedPolygons;
}

float[][][] arrangePolygonsLR(float[][][] polygons) {
  float[][][] arrangedPolygons = new float[polygons.length][][];
  int counter = 0;  
  int directionCounter =0;
  for (float k = 0; k< YSIZE; k = k + sensorSize) {
    if (directionCounter%2 ==0) {
      for (float i = 0; i< XSIZE; i = i + sensorSize) {
        for (int j =0; j<polygons.length; j++) {
          if (polygons[j] != null) {
            float[] center = gCenter(polygons[j]);
            if (center[0] >= i - (0.5*sensorSize) && center[0] <= i + (0.5*sensorSize)) {
              if (center[1] >= k - (0.5*sensorSize) && center[1] <= k + (0.5*sensorSize)) {
                arrangedPolygons[counter]= polygons[j];
                arrangedPolygons[counter]= polygons[j];
                counter++;
              }
            }
          }
        }
      }
    } else if (directionCounter%2 == 1) {
      for (float i = XSIZE; i > 0; i = i - sensorSize) {
        for (int j =0; j<polygons.length; j++) {
          if (polygons[j] != null) {
            float[] center = gCenter(polygons[j]);
            if (center[0] >= i - (0.5*sensorSize) && center[0] <= i + (0.5*sensorSize)) {
              if (center[1] >= k - (0.5*sensorSize) && center[1] <= k + (0.5*sensorSize)) {
                arrangedPolygons[counter]= polygons[j];
                arrangedPolygons[counter]= polygons[j];
                counter++;
              }
            }
          }
        }
      }
    }
    directionCounter++;
  }
  return arrangedPolygons;
}

float[][][] arrangePolygons(float[][][] polygons, int direction) {
  float[][][] arrangedPolygons = new float[polygons.length][][];
  if (direction ==0) {
    arrangedPolygons = arrangePolygonsTB(polygons);
  } else if (direction ==1) {
    arrangedPolygons = arrangePolygonsLR(polygons);
  }


  return arrangedPolygons;
}  

float[][] remove(float array[][], int item) {
  float outgoing[][] = new float[array.length - 1][];
  System.arraycopy(array, 0, outgoing, 0, item);
  System.arraycopy(array, item+1, outgoing, item, array.length - (item + 1));
  return outgoing;
} 

float[][] removeAfter(float array[][], int item) {
  float outgoing[][] = new float[item][];
  System.arraycopy(array, 0, outgoing, 0, item);
  return outgoing;
} 

float[][] concat(float[][] array1, float startPercentage1, float endPercentage1, float[][] array2, float startPercentage2, float endPercentage2) {
  int startPoint1 = int(array1.length*startPercentage1);
  int endPoint1 = int(array1.length*endPercentage1);
  int startPoint2 = int(array2.length*startPercentage2);
  int endPoint2 = int(array2.length*endPercentage2);

  float[][] outgoing = new float[(endPoint1-startPoint1)+((array2.length-endPoint2)+startPoint2)][];
  System.arraycopy(array2, 0, outgoing, 0, startPoint2);
  System.arraycopy(array1, startPoint1, outgoing, startPoint2, (endPoint1-startPoint1));
  System.arraycopy(array2, endPoint2, outgoing, startPoint2 + (endPoint1-startPoint1), (array2.length-endPoint2));

  for (int i = 0; i<outgoing.length; i++) {
    ellipse(outgoing[i][0], outgoing[i][1], 10, 10);
  }

  return outgoing;
}

float[][] concat(float[][] array1, float[][] array2) {
  float[][] outgoing = new float[array1.length+array2.length][];
  System.arraycopy(array1, 0, outgoing, 0, array1.length);
  System.arraycopy(array2, 0, outgoing, array1.length, array2.length);
  return outgoing;
}


float[][] arrangeEdges(float[][] edges) {
  float arrangedEdges[][] = new float[edges.length][4];
  int counter=0;
  int OK =0;
  if (edges.length >1) {
    while (OK==0) {
      if (edges[0] != null) {
        OK =1;
      }
      edges = remove(edges, 0);
    }

    /*for (int i =0; i<edges.length; i++) {
      float LOW =10000;
      int side = 2;
      int edge = 0;
      if (dist(prevX, prevY, edges[i][0], edges[i][1]) < LOW) {
        edge = i;
        side = 0;
        LOW = dist(prevX, prevY, edges[i][0], edges[i][1]);
      };
      if (dist(prevX, prevY, edges[i][2], edges[i][3]) < LOW) {
        edge = i;
        side = 1;
        LOW = dist(prevX, prevY, edges[i][2], edges[i][3]);
      };

      if (edges[edge]!=null) {
        if (side == 0) {
          arrangedEdges[counter+1][0] = edges[edge][0];
          arrangedEdges[counter+1][1] = edges[edge][1];
          arrangedEdges[counter+1][2] = edges[edge][2];
          arrangedEdges[counter+1][3] = edges[edge][3];
        } else if (side == 1) {
          arrangedEdges[counter+1][0] = edges[edge][2];
          arrangedEdges[counter+1][1] = edges[edge][3];
          arrangedEdges[counter+1][2] = edges[edge][0];
          arrangedEdges[counter+1][3] = edges[edge][1];
        }
        counter++;
      }

      edges = remove(edges, edge);
    }*/

    while (edges.length>1) {
      float LOW =10000;
      int side = 2;
      int edge = 0;
      for (int i = 0; i<edges.length; i++) {
        //      println("YUP");
        if (dist(arrangedEdges[counter][2], arrangedEdges[counter][3], edges[i][0], edges[i][1]) < LOW) {
          edge = i;
          side = 0;
          LOW = dist(arrangedEdges[counter][2], arrangedEdges[counter][3], edges[i][0], edges[i][1]);
        };
        if (dist(arrangedEdges[counter][2], arrangedEdges[counter][3], edges[i][2], edges[i][3]) < LOW) {
          edge = i;
          side = 1;
          LOW = dist(arrangedEdges[counter][2], arrangedEdges[counter][3], edges[i][2], edges[i][3]);
        };
      }

      if (edges[edge]!=null) {
        if (side == 0) {
          arrangedEdges[counter+1][0] = edges[edge][0];
          arrangedEdges[counter+1][1] = edges[edge][1];
          arrangedEdges[counter+1][2] = edges[edge][2];
          arrangedEdges[counter+1][3] = edges[edge][3];
        } else if (side == 1) {
          arrangedEdges[counter+1][0] = edges[edge][2];
          arrangedEdges[counter+1][1] = edges[edge][3];
          arrangedEdges[counter+1][2] = edges[edge][0];
          arrangedEdges[counter+1][3] = edges[edge][1];
        }
        counter++;
      }

      edges = remove(edges, edge);

      //    println(edge + " " + counter + " " + edges.length);
    }
  }

  return arrangedEdges;
}

float[][][] unionPolygons(float[][][] polygons, float d) {
  float[][][] uniPolygons = new float[polygons.length][][];
  for (int i =0; i+1<polygons.length; i++) {
    if (polygons[i]!= null && polygons[i].length >1) {
      uniPolygons[i] = unionPolygon(polygons[i], d);
    }
  }

  return uniPolygons;
}

float[][] unionPolygon(float[][] edges, float d) {

  RShape pol;
  RG.init(this);
  RG.setPolygonizer(RG.ADAPTATIVE);
  pol = new RShape();
  pol.addMoveTo(edges[0][0], edges[0][1]);

  for (int i =0; i<edges.length; i++) {
    pol.addLineTo(edges[i][0], edges[i][1]);
  }

  float[][] uniPoints = shapeOffset(edges, d);
  float[][] uniPolygon = points2edges(uniPoints, uniPoints.length);

  return uniPolygon;
}



// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// shapeOutset
// 
float[][] shapeOffset(float[][] edges, float d) {
  boolean inset = false;

  RShape s;
  RG.init(this);
  RG.setPolygonizer(RG.ADAPTATIVE);
  s = new RShape();
  s.addMoveTo(edges[0][0], edges[0][1]);
  float ofs = d;

  for (int i =0; i<edges.length; i++) {
    s.addLineTo(edges[i][0], edges[i][1]);
  }

  int ast = 15; // number of "steps" while translating clockwise
  // affects: -speed, +smoothness, +number of points
  // becomes less critical if "ts" is simlifyed

  RShape mks;
  RShape ts = new RShape();
  RPoint[][] pointPaths;

  if (ofs<0) { //inset required
    inset = true;
    ofs = -ofs;
    mks = RG.diff(RG.getRect(s.getX()-ofs, s.getY()-ofs, s.getWidth()+2*ofs, s.getHeight()+2*ofs), s);
  } else { //outset required
    mks = s;
  }

  for (int i = 0; i<ast*2; i++) {
    float tx = cos(PI/float(ast)*float(i))*ofs;
    float ty = sin(PI/float(ast)*float(i))*ofs;

    mks.translate( tx, ty );
    ts = ts.union( mks );
    // SIMPLIFY SHAPE HERE!!!
    // .polygonize(), .update()... ?
    mks.translate( -tx, -ty );
  }

  if (inset) {
    ts = RG.intersection(ts, s);
  } else
    ts = RG.diff(ts, s);

  //  ts.draw();

  // REMOVE s PATHS FROM ts
  pointPaths = ts.getPointsInPaths();
  float[][] uniPolygon = new float[0][];

  if (d<0) {
    //    println("pP " + pointPaths.length);
    uniPolygon = new float[pointPaths[1].length][2];

    if (pointPaths[1] != null) {
      for (int j = 0; j<pointPaths[1].length; j++) {
        uniPolygon[j][0] = pointPaths[1][j].x;
        uniPolygon[j][1] = pointPaths[1][j].y;
      }
    }
  } else {
    uniPolygon = new float[pointPaths[0].length][2];

    if (pointPaths[1] != null) {
      for (int j = 0; j<pointPaths[0].length; j++) {
        uniPolygon[j][0] = pointPaths[0][j].x;
        uniPolygon[j][1] = pointPaths[0][j].y;
      }
    }
  }

  return uniPolygon;
}

int maxInsetSteps(float[][] edges, float ofsSize) {
  boolean inset = false;

  RShape s;
  RG.init(this);
  RG.setPolygonizer(RG.ADAPTATIVE);
  s = new RShape();
  s.addMoveTo(edges[0][0], edges[0][1]);

  for (int i =0; i<edges.length; i++) {
    s.addLineTo(edges[i][0], edges[i][1]);
  }

  int ast = 15; // number of "steps" while translating clockwise
  // affects: -speed, +smoothness, +number of points
  // becomes less critical if "ts" is simlifyed 

  RPoint[][] pointPaths;
  int maxInset = 1;
  float ofs= ofsSize;
  int found =0;
  while (found ==0) {
    RShape mks;
    RShape ts = new RShape();
    if (ofs<0) { //inset required
      inset = true;
      ofs = -ofs;
      mks = RG.diff(RG.getRect(s.getX()-ofs, s.getY()-ofs, s.getWidth()+2*ofs, s.getHeight()+2*ofs), s);
    } else { //outset required
      mks = s;
    }

    for (int i = 0; i<ast*2; i++) {
      float tx = cos(PI/float(ast)*float(i))*ofs;
      float ty = sin(PI/float(ast)*float(i))*ofs;

      mks.translate( tx, ty );
      ts = ts.union( mks );
      // SIMPLIFY SHAPE HERE!!!
      // .polygonize(), .update()... ?
      mks.translate( -tx, -ty );
    }

    if (inset) {
      ts = RG.intersection(ts, s);
    } else
      ts = RG.diff(ts, s);

    //  ts.draw();

    // REMOVE s PATHS FROM ts
    pointPaths = ts.getPointsInPaths();
    if (pointPaths.length>1) {
      maxInset++ ;
    } else {
      found =1;
    }
    ofs= -ofs+ofsSize;
  }
  //  println(maxInset);

  return maxInset;
}

float[][] delineateShape(float[][] Shape, float percentage) {
  float baseLineX1 = Shape[0][0];
  float baseLineY1 = Shape[0][1];
  float baseLineX2 = Shape[Shape.length-1][2];
  float baseLineY2 = Shape[Shape.length-1][3];
  int steps = 100;
  float[][] returnArray = new float[Shape.length][Shape[0].length];

  for (int i = 0; i<Shape.length; i++) {
    float minDist1 = 10000;
    float minDist2 = 10000;
    float closestPointX1 = 0;
    float closestPointY1 = 0;
    float closestPointX2 = 0;
    float closestPointY2 = 0;
    for (int j = 0; j<steps; j++) {
      float lineCheckX = lerp(baseLineX1, baseLineX2, norm(j, 0, steps));
      float lineCheckY = lerp(baseLineY1, baseLineY2, norm(j, 0, steps));
      if (dist(Shape[i][0], Shape[i][1], lineCheckX, lineCheckY) < minDist1) {
        minDist1 = dist(Shape[i][0], Shape[i][1], lineCheckX, lineCheckY);
        closestPointX1 =lineCheckX;
        closestPointY1 =lineCheckY;
      }
      if (dist(Shape[i][2], Shape[i][3], lineCheckX, lineCheckY) < minDist2) {
        minDist2 = dist(Shape[i][2], Shape[i][3], lineCheckX, lineCheckY);
        closestPointX2 =lineCheckX;
        closestPointY2 =lineCheckY;
      }
    }

    returnArray[i][0] = lerp(closestPointX1, Shape[i][0], percentage);
    returnArray[i][1] = lerp(closestPointY1, Shape[i][1], percentage);
    returnArray[i][2] = lerp(closestPointX2, Shape[i][2], percentage);
    returnArray[i][3] = lerp(closestPointY2, Shape[i][3], percentage);
  }

  return returnArray;
}

float[][] shorten(float[][] array, float startPercentage, float endPercentage, int mode) {
  int startPoint = int(array.length*startPercentage);
  int endPoint = int(array.length*endPercentage);
  float[][] outgoing = new float[0][];
  if (mode == 0) {
    outgoing = new float[(endPoint-startPoint)][];
    System.arraycopy(array, startPoint, outgoing, 0, (endPoint-startPoint));
  } else if (mode == 1) {
    outgoing = new float[(array.length-endPoint)+startPoint][];
    System.arraycopy(array, 0, outgoing, array.length-endPoint, startPoint);
    System.arraycopy(array, endPoint, outgoing, 0, array.length-endPoint);
  }
  return outgoing;
}

float[][] alternateEdges(float[][] array1, float[][] array2) {
  float[][] outgoing = new float[array1.length+array2.length][];
  for(int i = 0; i<array1.length; i++) {
    outgoing[i]=array1[i];
  }
  for(int i = 0; i<array2.length; i++) {
    outgoing[array1.length+i] = array2[array2.length-1-i];
  }
  
  return outgoing;
}

