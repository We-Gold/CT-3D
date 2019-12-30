import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class CT_Viewer extends PApplet {

PImage photo;
String[] paths;
String mainPath = "";
int currentImage = 0;

public void setup() {
  
  
  selectFolder("Select a folder of PNGs or JPGs of the CT Scans: ","updateMainPath");
  
}

public void draw() {
  background(20);
  imageMode(CENTER);
  if(mainPath != "" && paths != null){
    photo = loadImage(mainPath+"/"+paths[currentImage]);
    photo.loadPixels();
    photo.resize(width,height);
    image(photo, width/2, height/2);
  }
}

public void keyPressed() {
  if(keyCode == 37){
    previousImage();
  } else if(keyCode == 39) {
    nextImage();
  }
}

public void updateMainPath(File selection) {
  mainPath = selection.getAbsolutePath();
  
  File folder = new File(mainPath);
  paths = folder.list();
  
  photo = loadImage(mainPath+"/"+paths[currentImage]);
  photo.loadPixels();
}

public void nextImage() {
  if(currentImage == paths.length-1){
    currentImage = 0;
  } else {
    currentImage++;
  }
}

public void previousImage() {
  if(currentImage == 0){
    currentImage = paths.length - 1;
  } else {
    currentImage--;
  }
}
  public void settings() {  size(800, 600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "CT_Viewer" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
