float[] sensorVal() {
  String lines[] = loadStrings(SensorJSON);
  String lines2 = " ";

  for (int i = 0; i < lines.length; i++) {
    lines2 = lines2 + lines[i];
  }

  String[] rawVal = split(lines2, "data");
  rawVal = split(rawVal[6], "[");
  rawVal = split(rawVal[1], "]");
  rawVal = split(rawVal[0], ",");

  String[] range = split(lines2, "range");
  range = split(range[2], "[");
  range = split(range[1], "]");
  range = split(range[0], ",");
  int min = int(range[0]);
  int max = int(range[1])-min;

  String[] binary = split(lines2, "binary_threshold");
  binary = split(binary[1], ":");
  binary = split(binary[1], ",");
  int minClip = int(binary[0]);

  // creating new array for sensor values, that can be remapped
  float[] sensorVal = new float[rawVal.length];
  for (int i = 0; i+1<rawVal.length; i++) {
    sensorVal[i] = float(rawVal[i]);
  }

  for (int i =0; i<sensorVal.length; i++) {
    sensorVal[i]=sensorVal[i]-min;
    sensorVal[i]= constrain(sensorVal[i], minClip, max);
    sensorVal[i]=sensorVal[i]/max;
  }
  
  return sensorVal;
}

float[][][]
sensorInsole(float[][][]polygons2, float currentlayer, int infill) {
  // reading values from JSON array
  float[][] heightVal = new float[sensorsX][sensorsY];

  float[] sensorVal = sensorVal();
  
  for (int i =0; i<sensorVal.length; i++) {
    sensorVal[i]=sensorVal[i]*layersEdgesTotal;
  }


  // creating array that shows the distribution of values
  int[] arrayDistribution = new int[layersEdgesTotal];

  int stateD =0;
  int stateCounter = 0;
  int distStart=0;
  int distStop=0;
  int OK =0;
  int loop =0;


  // redistributing, contraining and mapping 
  while (OK==0) {
    //checking distribution
    for (int i = 0; i<layersEdgesTotal; i++) {
      for (int j=0; j<sensorVal.length; j++) {
        if (int(sensorVal[j]) == i) {
          arrayDistribution[i]++;
        }
      }
    };

    //    println(arrayDistribution);
    stateCounter =0;

    for (int i = 0; i <arrayDistribution.length; i++) {

      float k = arrayDistribution[i];
      float l = int(k*100/sensorVal.length);
      //      println("[" + i + "] k " + k + " l "+ l); 

      if (l!=0 && stateD==0) {
        if (stateD==0) {
          if (stateCounter==0) {
            distStart = i;
          }
          stateCounter++;
        }
        if (stateD==1) {
          distStop= i;
        }
        stateD=1;
      } else {
        if (stateD==1) {
          stateCounter++;
          if (stateCounter>=0) {
            distStop= i;
          }
        };
        stateD = 0;
      }
    };

    //    println("ds" + distStart + " " + distStop + " " + stateCounter);

    if (stateCounter >1) {
      // correcting distribution
      for (int i=0; i<sensorVal.length; i++) {
        sensorVal[i] = constrain(sensorVal[i], distStart, distStop);
        sensorVal[i] = map(sensorVal[i], distStart, distStop, 0, layersEdgesTotal);
      }
    }
    //checking if redistribution was sufficient
    if (distStart<=3 && distStop >= arrayDistribution.length-3) {
      OK = 1;
    }

    if (loop>=50) {
      OK = 1;
    }
    loop++;
  }


  // putting redistributed data in array with correct dimensions
  int counter=0;
  for (int i = 0; i<sensorsX; i++) {
    for (int j = 0; j<sensorsY; j++) {
      heightVal[i][j] = sensorVal[counter];
      counter++;
    }
  }


  int[] nrDones = new int[0];
  for (int i = 0; i+1<polygons2.length; i++) {
    if (polygons2[i] != null) {
      float[] gCenterPolygon = gCenter(polygons2[i]);
      int k = (floor((sensorsX*gCenterPolygon[0])/XSIZE));
      int l = (floor((sensorsY*gCenterPolygon[1])/YSIZE));
      float m = heightVal[k][l];
      if (infill==0) {
        if (m >= currentlayer) {
          nrDones = append(nrDones, i);
        }
      } else if (infill ==1) {
        if (m <= currentlayer) {
          nrDones = append(nrDones, i);
        }
      }
    }
  };

  //  println(nrDones.length);



  float[][][] dones = new float[nrDones.length][][];

  for (int i = 0; i<nrDones.length; i++) {
    dones[i]=polygons2[nrDones[i]];
  }

  dones = travelingSalesmanProblem(dones);
  return dones;
}


float sensorDensity(float[][] polygon) {//tread concentric infill
  float[][] densVal = new float[sensorsX][sensorsY];
  float[] sensorVal = sensorVal();

  int counter=0;
  for (int i = 0; i<sensorsX; i++) {
    for (int j = 0; j<sensorsY; j++) {
      densVal[i][j] = sensorVal[counter];
      counter++;
    }
  }

  int densCounter = 0;
  float density1 = 0;
  for(int i = 0; i<sensorsX; i++) {
    for(int j = 0; j<sensorsY; j++) {
      float sensorPointX = i*sensorSize + sensorSize/2;
      float sensorPointY = j*sensorSize + sensorSize/2;
      float[] sensorPoint = {sensorPointX,sensorPointY};
      if(isInside(polygon, sensorPoint)) {
        densCounter++;
        density1 = density1 + densVal[i][j];
      }
    }
  }
  float density = 1-(density1/densCounter);
  map(density,0,1,densityLowerLimit, densityUpperLimit);
//  float[] gCenterPolygon = gCenter(polygon);
//  int k = (floor((sensorsX*gCenterPolygon[0])/XSIZE));
//  int l = (floor((sensorsY*gCenterPolygon[1])/YSIZE));
//  float density = 1-densVal[k][l];

  return density;
}

