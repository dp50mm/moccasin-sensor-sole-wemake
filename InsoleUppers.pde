float[] lineLine(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {

  // find uA and uB
  float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

  // note: if the below equations is true, the lines are parallel
  // ... this is the denominator of the above equations
  // (y4-y3)*(x2-x1) - (x4-x3)*(y2-y1)

  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {

    // find intersection point, if desired
    //float intersectionX = x1 + (uA * (x2-x1));
    float intersectionY = y1 + (uA * (y2-y1));
    float intersectionX = x1+ (uB * (x2-x1));
    noStroke();
    fill(0, 0, 255);
    //ellipse(intersectionX, intersectionY, 2, 2);

    float[] intersectionPoint = {
      intersectionX, intersectionY
    };
    return intersectionPoint;
  } else return null;
}

float[][] insoleContour (float[][] contour, float[][] foot) {
  float[][] returnArray = new float[0][2];
  float[][] reverseContour = scalePolygon(contour, -2);

  float[] maxMinContour = MaxMinPolygon(contour);
  float[] maxMinFoot = MaxMinPolygon(foot);

  float inset = 20;

//  for (int i = 0; i<foot.length; i++) {
//    stroke(0);
//    line(foot[i][0], foot[i][1], foot[i][2], foot[i][3]);
//  }

  for (int k = 0; k< contour.length; k++) {
    float x1 = contour[k][0];
    float y1 = contour[k][1];
    float y2 = map(y1, maxMinContour[1], maxMinContour[3], maxMinFoot[1]+inset, maxMinFoot[3]-inset);
    float[] IXxPoints = new float[0];
    for (int i = 0; i<foot.length; i++) {
      float[] xPoints = lineLine(foot[i][0], foot[i][1], foot[i][2], foot[i][3], maxMinFoot[0]-inset, y2, maxMinFoot[2]+inset, y2);
      if (xPoints != null) {
        if (xPoints[1] != 0 && xPoints[0] != 0) {
          IXxPoints = append(IXxPoints, xPoints[0]);
        }
      }
    }
    float sumIXxPoints =0;
    for (int i = 0; i<IXxPoints.length; i++) {
      sumIXxPoints = sumIXxPoints+IXxPoints[i];
    }
    float x2 = sumIXxPoints/IXxPoints.length;

//    stroke(0);
//    line(x1, y1, x2, y2);

    float[] IYPoints = new float[0];
    float[] IXPoints = new float[0];
    for (int i = 0; i<foot.length; i++) {
      float[] Points = lineLine(foot[i][0], foot[i][1], foot[i][2], foot[i][3], x1, y1, x2, y2);
      if (Points != null) {
        if (Points[1] != 0 && Points[0] != 0) {
          IYPoints = append(IYPoints, Points[1]);
          IXPoints = append(IXPoints, Points[0]);
        }
      }
    }
    if (IXPoints.length>0) {
      int whichPoint = 0;
      float minDist =1000;
      for (int i =0; i<IXPoints.length; i++) {
        if (dist(contour[k][0], contour[k][1], IXPoints[i], IYPoints[i]) < minDist) {
          minDist = dist(contour[k][0], contour[k][1], IXPoints[i], IYPoints[i]);
          whichPoint = i;
        }
      }
      float[][] tmpArray = new float[1][2];
      tmpArray[0][0] = IXPoints[whichPoint];
      tmpArray[0][1] = IYPoints[whichPoint];
      returnArray = concat(returnArray, tmpArray);
    } /*else {
     println(k);
     int whichPoint = 0;
     float minDist =1000;
     for (int i=0; i<foot.length; i++) {
     if (dist(contour[k][0], contour[k][1], foot[i][0], foot[i][1]) < minDist) {
     minDist = dist(contour[k][0], contour[k][1], foot[i][0], foot[i][1]);
     whichPoint = i;
     }
     }
     float[][] tmpArray = new float[1][2];
     tmpArray[0][0] = foot[whichPoint][0];
     tmpArray[0][1] = foot[whichPoint][1];
     returnArray = concat(returnArray, tmpArray);
     }*/
  }

//  for (int i = 0; i<returnArray.length; i++) {
//    ellipse(returnArray[i][0], returnArray[i][1], 5, 5);
//  }

  float[][] returnEdges = points2edges(returnArray, returnArray.length);

  //  println(contour.length);
//  println(returnArray.length);
  return returnEdges;
}

float[][] topPoint(float[][] Shape) {
  int steps = 180;
  float stepSize = .5;
  float optimalStep =0;
  float optimalRatio = 10000;
  int optimalTopPoint = 0 ;

  for (int j = 0; j< steps/stepSize; j++) {
    float[] translation = {
      j*stepSize, 0, 0
    };
    float[][] tempShape = translatePoints(Shape, translation);
    float[] maxMinTempShape = MaxMinPolygon(tempShape);
    float sizeX = maxMinTempShape[2]-maxMinTempShape[0];
    float sizeY = maxMinTempShape[3] - maxMinTempShape[1];
    float ratio = sizeX/sizeY;
    if (ratio<optimalRatio) {
      optimalRatio = ratio;
      optimalStep = j*stepSize;
    }
  }

  float[] optimalTranslation = {
    optimalStep, 0, 0
  };
  float[][] optimalShape = translatePoints(Shape, optimalTranslation);
  float optY = 0;

  for (int i = 0; i+1<optimalShape.length; i++) {
    if (optimalShape[i][1]>optY) {
      optimalTopPoint = i;
      optY = optimalShape[i][1];
    }
  }

  float[][] returnArray = new float[Shape.length][4];

  System.arraycopy(Shape, optimalTopPoint, returnArray, 0, Shape.length-optimalTopPoint);
  System.arraycopy(Shape, 0, returnArray, Shape.length-optimalTopPoint, optimalTopPoint);

  return returnArray;
}

