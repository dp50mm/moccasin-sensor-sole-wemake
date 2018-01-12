float dist(float[][] p1, float[][] p2) {
  //distance between two polygons, take between gravity centers (of contour points)
//    float[] g1 = gCenter(p1);
//  float[] g2 = gCenter(p2);
//  //these are the centers of "gravity"
//  float x1 = g1[0];
//  float y1 = g1[1];
//  float x2 = g2[0];//idem p2
//  float y2 = g2[1];
  float x1 = p1[0][0];
  float y1 = p1[0][1];
  float x2 = p2[p2.length-1][0];//idem p2
  float y2 = p2[p2.length-1][1];
  
    return dist(x1, y1, x2, y2);
}

float[][][]
travelingSalesmanProblem(float[][][] polygons) {
  //find a tour to minimize total distance of between-polygon travel
  //we just make a simple greedy approximation
  if (polygons == null) return null;
  if (polygons.length == 0) return new float[0][][];

  float[][][] todo = new float[polygons.length][][];
  //copy in fresh todo list
  for (int i = 0; i < polygons.length; i++)
    todo[i] = polygons[i];

  //collect results in tour
  //nullify what is done in todo
  float[][][] tour = new float[polygons.length][][];
  int p = 0;//count polygons
  tour[p++] = todo[0];//arbitrary starting point
  todo[0] = null;//done, nullify
  float[][] prev = tour[0];//previous polygon
  for (int k = 1; k < polygons.length; k++) {
    //find nearest compared to previous
    int aha = -1;
    float min_d = 1000000;
    for (int j = 0; j < todo.length; j++) {
      if (todo[j] != null) {
        float d = dist(todo[j], prev);
        if (d <= min_d) {
          aha = j;
          min_d = d;
        }
      }
    }    //end for
    //nearest found at aha
    if (aha > -1) {
      tour[p++] = todo[aha];
      prev = todo[aha];
      todo[aha] = null;//nullify done
    }
  }    //end for j
  return tour;
}

