PImage photo;
String[] paths;
String mainPath = "";
int currentImage = 0;

void setup() {
  size(800, 600);
  
  selectFolder("Select a folder of PNGs or JPGs of the CT Scans: ","updateMainPath");
  
}

void draw() {
  background(20);
  imageMode(CENTER);
  if(mainPath != "" && paths != null){
    photo = loadImage(mainPath+"/"+paths[currentImage]);
    photo.loadPixels();
    photo.resize(width,height);
    image(photo, width/2, height/2);
  }
}

void keyPressed() {
  if(keyCode == 37){
    previousImage();
  } else if(keyCode == 39) {
    nextImage();
  }
}

void updateMainPath(File selection) {
  mainPath = selection.getAbsolutePath();
  
  File folder = new File(mainPath);
  paths = folder.list();
  
  photo = loadImage(mainPath+"/"+paths[currentImage]);
  photo.loadPixels();
}

void nextImage() {
  if(currentImage == paths.length-1){
    currentImage = 0;
  } else {
    currentImage++;
  }
}

void previousImage() {
  if(currentImage == 0){
    currentImage = paths.length - 1;
  } else {
    currentImage--;
  }
}
