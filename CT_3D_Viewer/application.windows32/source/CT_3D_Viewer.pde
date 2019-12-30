PImage[] scans;

String[] paths;
String mainPath = "C:/Users/wegos/Documents/GitHub/CT 3D/MANIX PNG";

PVector dims;
PShape render;

float layerHeight = 2.5;

float threshold = -14000000;

PVector[][] points;

float xmag, ymag = 0;
float newXmag, newYmag = 0; 

void setup(){
  size(1000, 800, P3D);
  background(0);
  stroke(255);
  
  File folder = new File(mainPath);
  paths = folder.list();
  
  scans = new PImage[paths.length];
  
  for(int i = 0; i < scans.length; i++) {
    scans[i] = loadImage(mainPath+"/"+paths[i]);
    scans[i].loadPixels();
  } 
  
  renderMarchingCubes();
}

void draw(){
  background(0);
  
  newXmag = mouseX/float(width) * TWO_PI;
  newYmag = mouseY/float(height) * TWO_PI;
  
  float diff = xmag-newXmag;
  if (abs(diff) >  0.01) { 
    xmag -= diff/4.0; 
  }
  
  diff = ymag-newYmag;
  if (abs(diff) >  0.01) { 
    ymag -= diff/4.0; 
  }
  beginCamera();
  camera();
  endCamera();
  
  directionalLight(0, 0, 100, 0, 0, 0);
  
  translate(width/2,height*4/5);
  rotateX(-ymag); 
  rotateY(-xmag); 
  shape(render);
}

void renderPointMap(){
  points = new PVector[scans.length][256];
  
  for(int i = 0; i < points.length; i++){
    for(int j = 0; j < points[i].length; j++){
      points[i][j] = new PVector(random(-256,256),-1*layerHeight*i,random(-256,256));
      if(!(scans[i].pixels[((int)points[i][j].z+256)*512+((int)points[i][j].x+256)] >= threshold)){
        j--;
      }
    }
  }
  
  render = createShape();
  render.beginShape(POINTS);
  for(int i = 0; i < points.length; i++){
    for(int j = 0; j < points[i].length; j++){
      render.vertex(points[i][j].x,points[i][j].y,points[i][j].z);
    }
  }
  render.endShape();
}

void renderMarchingCubes() {
  render = createShape();
  render.beginShape(TRIANGLES);
  for(int i = 0; i < scans.length; i++){
    for(int j = 0; j < floor(512/layerHeight); j++){
      for(int k = 0; k < floor(512/layerHeight); k++){
        float cubes = floor(512/layerHeight)-1;
        float newj = (512*j)/cubes - 256;
        float newk = (512*k)/cubes - 256;
        
        PVector[] cube = cubePoints(new PVector(newk,i*layerHeight,newj));
        PVector[] midpoints = interpolatedMidpoints(cube);
        
        int sum = 0;
    
        for(int x = cube.length-1; x >= 0 ; x--) {
          if(densityAtPoint(cube[x]) >= threshold) {
            sum += Math.pow(2,x);
          }
        }
                
        if(sum > 0){      
          int currentVertex = 0;
          while(currentVertex < 16 && triangulation[sum][currentVertex] != -1) {
            PVector v = midpoints[triangulation[sum][currentVertex]];
            render.vertex(v.x,v.y,v.z);
            currentVertex++;
          }
        }
      }
    }
  }
  render.endShape();
}

PVector[] cubePoints(PVector p) {
  // Return points on a cube starting from the bottom left corner
  float w = layerHeight;
  PVector[] points = new PVector[8];
  
  points[0] = new PVector(p.x,p.y,p.z);
  points[1] = new PVector(p.x+w,p.y,p.z);
  points[2] = new PVector(p.x+w,p.y,p.z-w);
  points[3] = new PVector(p.x,p.y,p.z-w);
  points[4] = new PVector(p.x,p.y-w,p.z);
  points[5] = new PVector(p.x+w,p.y-w,p.z);
  points[6] = new PVector(p.x+w,p.y-w,p.z-w);
  points[7] = new PVector(p.x,p.y-w,p.z-w);
  
  return points;
}

public PVector interpolateMidpoint(PVector a, float aVal, PVector b, float bVal){
  float factor = (threshold - aVal)/(bVal - aVal);
  return PVector.lerp(a,b,abs(factor));
}

PVector[] interpolatedMidpoints(PVector[] cube) {
  PVector[] newMidpoints = new PVector[12];
  newMidpoints[0] = interpolateMidpoint(cube[0],densityAtPoint(cube[0]),cube[1],densityAtPoint(cube[1]));
  newMidpoints[1] = interpolateMidpoint(cube[1],densityAtPoint(cube[1]),cube[2],densityAtPoint(cube[2]));
  newMidpoints[2] = interpolateMidpoint(cube[2],densityAtPoint(cube[2]),cube[3],densityAtPoint(cube[3]));
  newMidpoints[3] = interpolateMidpoint(cube[0],densityAtPoint(cube[0]),cube[3],densityAtPoint(cube[3]));
  newMidpoints[4] = interpolateMidpoint(cube[4],densityAtPoint(cube[4]),cube[5],densityAtPoint(cube[5]));
  newMidpoints[5] = interpolateMidpoint(cube[5],densityAtPoint(cube[5]),cube[6],densityAtPoint(cube[6]));
  newMidpoints[6] = interpolateMidpoint(cube[6],densityAtPoint(cube[6]),cube[7],densityAtPoint(cube[7]));
  newMidpoints[7] = interpolateMidpoint(cube[7],densityAtPoint(cube[7]),cube[4],densityAtPoint(cube[4]));
  newMidpoints[8] = interpolateMidpoint(cube[0],densityAtPoint(cube[0]),cube[4],densityAtPoint(cube[4]));
  newMidpoints[9] = interpolateMidpoint(cube[1],densityAtPoint(cube[1]),cube[5],densityAtPoint(cube[5]));
  newMidpoints[10] = interpolateMidpoint(cube[2],densityAtPoint(cube[2]),cube[6],densityAtPoint(cube[6]));
  newMidpoints[11] = interpolateMidpoint(cube[3],densityAtPoint(cube[3]),cube[7],densityAtPoint(cube[7]));
  return newMidpoints;
}


int densityAtPoint(PVector p){
  int scan = (int)(abs(p.y)/layerHeight);
  if(((int)p.z+256)*512+((int)p.x+256) >= (512*512) || ((int)p.z+256)*512+((int)p.x+256) < 0){
    return -16777216;
  }
  return scans[scan].pixels[((int)p.z+256)*512+((int)p.x+256)] ;
}
