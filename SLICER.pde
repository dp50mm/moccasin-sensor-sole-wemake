float[][]
slicePolygonX(float[][] polygon) {
  //assume constant slicedistance.
  //The polygon can be either a sole's contour or a tread.
  //We cannot work with polygons if one horzontal line has three or more intersects.
  //Convex polygons are safe, however.
  //The polygon must be given as an EQ-closed set of {x1,y1,x2,y2} edges.
  //Return a set of parallef edges to be printed with distance slicedistance
  if (polygon == null) return null;
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
  //one horizontal edge for each Y:
  float[] scanline = new float[4];
  int maxNrEdges=1;
  int nrEdges = 0;

  for (float X = minX; X < maxX; X += slicedistance) { 
    scanline[0] = X; 
    scanline[1] = minY -100;
    scanline[2] = X;
    scanline[3] = maxY + 100;
    maxNrEdges= maxNrEdges + floor( intersects(polygon, scanline)/2);
  }    //end for

  float[][] edges = new float[maxNrEdges][];//amount of lines (edges) that are being sliced

  for (float X = minX; X < maxX; X += slicedistance) { 
    scanline[0] = X; 
    scanline[1] = minY -100;
    scanline[2] = X;
    scanline[3] = maxY + 100;
    int ISP = intersects(polygon, scanline);
    for (int i = 0; i+1<ISP; i=i+2) {
      float IP1 = givenintersectionpoint(polygon, scanline, i, 1);
      float IP2 = givenintersectionpoint(polygon, scanline, i+1, 1);
      if (IP1 != 0 && IP2 != 0) {
        float Y1 = IP1;//0 is X, 1 is Y
        float Y2 = IP2;
        //should we check order? perhaps not
        float[] edge = new float[4];
        edge[0] = X;
        edge[1] = Y1;
        edge[2] = X;
        edge[3] = Y2;
        edges[nrEdges++] = edge;
      }    //end if
    }
  }    //end for
  //repack
  float[][] packed = new float[nrEdges][];
  for (int i = 0; i < nrEdges; i++)
    packed[i] = edges[i];
  return packed;
}    //end sclicePolygon

float[][]
slicePolygonY(float[][] polygon) {
  //assume constant slicedistance.
  //The polygon can be either a sole's contour or a tread.
  //We cannot work with polygons if one horzontal line has three or more intersects.
  //Convex polygons are safe, however.
  //The polygon must be given as an EQ-closed set of {x1,y1,x2,y2} edges.
  //Return a set of parallef edges to be printed with distance slicedistance
  if (polygon == null) return null;
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
  float[] scanline = new float[4];
  int maxNrEdges=1;
  int nrEdges = 0;

  for (float Y = minY; Y < maxY; Y += slicedistance) { 
    scanline[0] = minX -100; 
    scanline[1] = Y;
    scanline[2] = maxX + 100;
    scanline[3] = Y;
    maxNrEdges= maxNrEdges + floor( intersects(polygon, scanline)/2);
  }    //end for

  float[][] edges = new float[maxNrEdges][];//amount of lines (edges) that are being sliced

  for (float Y = minY; Y < maxY; Y += slicedistance) { 
    scanline[0] = minX -100; 
    scanline[1] = Y;
    scanline[2] = maxX + 100;
    scanline[3] = Y;
    int ISP = intersects(polygon, scanline);
    for (int i = 0; i+1<ISP; i=i+2) {
      float IP1 = givenintersectionpoint(polygon, scanline, i, 0);
      float IP2 = givenintersectionpoint(polygon, scanline, i+1, 0);
      if (IP1 != 0 && IP2 != 0) {
        float X1 = IP1;//0 is X, 1 is Y
        float X2 = IP2;
        //should we check order? perhaps not
        float[] edge = new float[4];
        edge[0] = X1;
        edge[1] = Y;
        edge[2] = X2;
        edge[3] = Y;
        edges[nrEdges++] = edge;
      }    //end if
    }
  }    //end for
  //repack
  float[][] packed = new float[nrEdges][];
  for (int i = 0; i < nrEdges; i++)
    packed[i] = edges[i];
  return packed;
}    //end sclicePolygon

float[][]
slicePolygonsX(float[][][] polygons) {
  //slice them all, return one flattened array of edges
  float[][][] sliceds = new float[polygons.length][][];
  for (int i = 0; i < polygons.length; i++)
    sliceds[i] = slicePolygonX(polygons[i]); 
  int howmany = 0;
  for (int i = 0; i < sliceds.length; i++)
    if (sliceds[i] != null)
      howmany += sliceds[i].length; 
  float[][] edges = new float[howmany][];
  int e = 0;
  for (int i = 0; i < sliceds.length; i++)
    if (sliceds[i] != null)
      for (int j = 0; j < sliceds[i].length; j++)
        edges[e++] = sliceds[i][j];
  return edges;
}    //end  slicePolygons

float[][]
slicePolygonsY(float[][][] polygons) {
  //slice them all, return one flattened array of edges
  float[][][] sliceds = new float[polygons.length][][];
  for (int i = 0; i < polygons.length; i++)
    sliceds[i] = slicePolygonY(polygons[i]); 
  int howmany = 0;
  for (int i = 0; i < sliceds.length; i++)
    if (sliceds[i] != null)
      howmany += sliceds[i].length; 
  float[][] edges = new float[howmany][];
  int e = 0;
  for (int i = 0; i < sliceds.length; i++)
    if (sliceds[i] != null)
      for (int j = 0; j < sliceds[i].length; j++)
        edges[e++] = sliceds[i][j];
  return edges;
}    //end  slicePolygons

