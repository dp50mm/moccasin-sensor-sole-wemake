float[] fitPointsTranslation(float[][] Shape) {
  int steps = 180;
  int stepSize = 1;
  float[] X1 = new float[Shape.length];
  float[] Y1 = new float[Shape.length];
  for (int i = 0; i<Shape.length; i++) {
    X1[i] = Shape[i][0];
    Y1[i] = Shape[i][1];
  };
  float[] X2;
  float[] Y2;
  float[] X3 = new float[X1.length];
  float[] Y3 = new float[Y1.length];
  float[] sizeX = new float[steps/stepSize];
  float[] sizeY = new float[steps/stepSize];
  float[] sizeXY = new float[steps/stepSize];
  float[] translation = new float[3];

  for (int j = 0; j< steps/stepSize; j++) {
    float angle1= j*stepSize;
    X2 = rotatePointsX(X1, Y1, angle1);
    Y2 = rotatePointsY(X1, Y1, angle1);
    sizeXY[j] =dist( min(X2), min(Y2), max(X2), max(Y2));
    sizeX[j] = max(X2) - min(X2);
    sizeY[j] = max(Y2) - min(Y2);
  }

  for (int i = 0; i<sizeXY.length; i++) {
    if (sizeX[i] <= xSizePrintArea && sizeY[i] <= ySizePrintArea) {
      X3 = rotatePointsX(X1, Y1, i*stepSize);
      Y3 = rotatePointsY(X1, Y1, i*stepSize);
      float minX3 = min(X3)-((xSizePrintArea-(max(X3)-min(X3)))/2);
      float minY3 = min(Y3)-((ySizePrintArea-(max(Y3)-min(Y3)))/2);
      translation[0] = i;
      translation[1] = minX3-((xSizeBuildplate-xSizePrintArea)/2);
      translation[2] = minY3-((ySizeBuildplate-ySizePrintArea)/2);
    }
    if (i==sizeXY.length && X3 == null) {
      println("No way to fit this object");
    }
  }


  return translation;
}

float[][] translatePoints(float[][] Shape, float[] translation) {
  float[] X1 = new float[Shape.length];
  float[] Y1 = new float[Shape.length];
  float[] X2 = new float[Shape.length];
  float[] Y2 = new float[Shape.length];
  for (int i = 0; i<Shape.length; i++) {
    X1[i] = Shape[i][0];
    Y1[i] = Shape[i][1];
    X2[i] = Shape[i][2];
    Y2[i] = Shape[i][3];
  };  

  float angle1= translation[0];
  float[] X3 = rotatePointsX(X1, Y1, angle1);
  float[] Y3 = rotatePointsY(X1, Y1, angle1);
  float[] X4 = rotatePointsX(X2, Y2, angle1);
  float[] Y4 = rotatePointsY(X2, Y2, angle1);

  for (int j = 0; j<X2.length; j++) {
    X3[j] = X3[j]-translation[1];
    Y3[j] = Y3[j]-translation[2];
    X4[j] = X4[j]-translation[1];
    Y4[j] = Y4[j]-translation[2];
  }

  float[][] shapePoints = new float[X3.length][4];

  for (int i = 0; i<X3.length; i++) {
    shapePoints[i][0] = X3[i];
    shapePoints[i][1] = Y3[i];
    shapePoints[i][2] = X4[i];
    shapePoints[i][3] = Y4[i];
  };

  return shapePoints;
}

float[][] fitPoints(float[][] Shape) {
  int steps = 180;
  int stepSize = 1;
  float[] X1 = new float[Shape.length];
  float[] Y1 = new float[Shape.length];
  for (int i = 0; i<Shape.length; i++) {
    X1[i] = Shape[i][0];
    Y1[i] = Shape[i][1];
  };
  float[] X2;
  float[] Y2;
  float[] X3 = new float[X1.length];
  float[] Y3 = new float[Y1.length];
  float[] sizeX = new float[steps/stepSize];
  float[] sizeY = new float[steps/stepSize];
  float[] sizeXY = new float[steps/stepSize];


  for (int j = 0; j< steps/stepSize; j++) {
    float angle1= j*stepSize;
    X2 = rotatePointsX(X1, Y1, angle1);
    Y2 = rotatePointsY(X1, Y1, angle1);
    sizeXY[j] =dist( min(X2), min(Y2), max(X2), max(Y2));
    sizeX[j] = max(X2) - min(X2);
    sizeY[j] = max(Y2) - min(Y2);
  }

  for (int i = 0; i<sizeXY.length; i++) {
    if (sizeX[i] <= xSizePrintArea && sizeY[i] <= ySizePrintArea) {
      X3 = rotatePointsX(X1, Y1, i*stepSize);
      Y3 = rotatePointsY(X1, Y1, i*stepSize);
      float minX3 = min(X3)-((xSizePrintArea-(max(X3)-min(X3)))/2);
      float minY3 = min(Y3)-((ySizePrintArea-(max(Y3)-min(Y3)))/2);
      for (int j = 0; j<X3.length; j++) {
        X3[j] = X3[j]-(minX3-((xSizeBuildplate-xSizePrintArea)/2));
        Y3[j] = Y3[j]-(minY3-((ySizeBuildplate-ySizePrintArea)/2));
      }
    }
    if (i==sizeXY.length && X3 == null) {
      println("No way to fit this object");
    }
  }

  float[][] shapePoints = new float[X3.length][2];

  for (int i = 0; i<X3.length; i++) {
    shapePoints[i][0] = X3[i];
    shapePoints[i][1] = Y3[i];
  };

  return shapePoints;
}


float[] rotatePointsX(float[] X, float[] Y, float angle) {
  float[] X2 = new float[X.length];
  float[] Y2 = new float[Y.length];
  float angle3;
  for (int i =0; i<X.length; i++) {
    float AB=dist(x0, y0, X[i], Y[i]);
    float angle2 =degrees( atan((Y[i]-y0)/(X[i]-x0)));
    if (X[i]>=x0) {
      angle3= 90-angle-angle2;
    } else {
      angle3= -90-angle-angle2;
    }
    X2[i]= x0 + AB*sin(radians(angle3));
  }
  return X2;
}

float[] rotatePointsY(float[] X, float[] Y, float angle) {
  float[] X2 = new float[X.length];
  float[] Y2 = new float[Y.length];
  float angle3;
  for (int i =0; i<Y.length; i++) {
    float AB=dist(x0, y0, X[i], Y[i]);
    float angle2 =degrees( atan((Y[i]-y0)/(X[i]-x0)));
    if (X[i]>=x0) {
      angle3= 90-angle-angle2;
    } else {
      angle3= -90-angle-angle2;
    }
    Y2[i]= y0 + AB*cos(radians(angle3));
  }
  return Y2;
}

