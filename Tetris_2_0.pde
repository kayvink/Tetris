//GLOBAL VARIABLES
//Array of brick objects to represent the falling shapes.
brick[] myShape;
//Arraylist of bricks. An arraylist is used here as we need to be able to dynamically add
//items to the array and remove items from anywhere in the array. The arraylist allows for
//these kind of steps to occur.
ArrayList<brick> myBricks = new ArrayList<brick>(); 
boolean falling; 
boolean keepPlaying = true;
//Int variables for use throughout the program
int shapeType;
int shapeRotate;
int count;
//Variable creation for the fonts used throught the game.
PFont scoreFont;
PFont countFont;
PFont loseFont;

/* 
The way the audio is imported is an adaptation of the manual on 
// http://code.compartmental.net/tools/minim/quickstart/

Import loads the minim library. You have to download and install this library
first. Check http://code.compartmental.net/tools/minim/ on how to install.
*/
import ddf.minim.*;

//This creates a minim object called minim.
Minim minim;

/*
This creates two playable audiofiles, you first have to store the files you want to 
play in the data folder.
*/
AudioPlayer background;
AudioPlayer tetrisRotate;
AudioPlayer success;
AudioPlayer touchDown;
AudioPlayer move;

// LIBRARY

void setup() {
  size(400,600);
  count = 0;
  scoreFont = loadFont("scoreFont.vlw");
  countFont = loadFont("countFont.vlw");
  loseFont = loadFont("HelveticaNeue-Bold-60.vlw");
  myShape = new brick[4];
  myShape = pickAShape();
  
  // instantiate a Minim object
  minim = new Minim(this);
  
  // This load the files stored earlier in the data folder.
  // These sounds were found with google and edited to fit
  // with Audacity.
  background = minim.loadFile("tetrisSoundtrack.mp3");
  tetrisRotate = minim.loadFile("tetrisRotate.wav");
  success = minim.loadFile("tetrisSuccess1.wav");
  touchDown = minim.loadFile("tetrisTouchDown.wav");
  move = minim.loadFile("tetrisMove.wav");
 // 
  
  // The ambience music should be playing from the begining and can thus be called in setup().
 background.loop();
}

void draw() {
  background(0);
   fill(255);
  textFont (scoreFont, 25);
     text ("SCORE", 307, 25);
  textFont (countFont, 25);
     text (count, 307, 50);
  fill(255);
//Draws the grid that is displayed on every frame
  for(int i=0; i < 11; i++) {
    stroke(50);
    line(i*((width-100)/10), 0, i*((width-100)/10), height);  
  }
  for(int i=0; i < 20; i++) {
    stroke(50);
    line(0, i*(height/20), width-100, i*(height/20));
  }
//Checks for an intersection of the current shape with the bottom or another block
//When one is found, the program checks for complete rows and then generates a new shape.
//The function is only called while game play is active. After a shape is rotated the program
//checks to see if the newly rotated shape has any blocks inside of another block or hanging
//off the side of the board. If either case is found to be true, the rotate function is called 3 
//more times to bring the shape back to it's original position, making it a appear to not move.
  if(keepPlaying){
    if(intersection()) {
      // Plays touchdown sounds.
      touchDown.rewind();
      touchDown.play();
      for(int i=0; i<myShape.length; i++) {
        myBricks.add(myShape[i]);
        if(myShape[i].getY() <= 0) {
          keepPlaying = false;
        }
      }
      checkCompleteRows();
      myShape= new brick[4];
      if(keepPlaying) {
        myShape = pickAShape();
      }
    }
  }
 //Moves the shape down and draws it.
 if(keepPlaying){
    for(int i=0; i<myShape.length; i++) {
      myShape[i].moveDown();
      myShape[i].draw();
    }
  }
 //Draws all of the bricks that are no longer moving.
  if(myBricks.size()>0) {
    for(int i=0; i<myBricks.size(); i++) {
      brick temp = myBricks.get(i);
      temp.draw();
    }
  }
 //When the keepPlaying variable is false text and a button is drawn on the screen.
  if(!keepPlaying) {
    fill(255);
    textFont(loseFont, 60);
      text("Try Again",17, 200);
    fill(255,0,0);
    rect(50,225, 200, 50);
    fill(255);
    textFont(loseFont, 40);
    text("Restart", 80,265);
      
  }
}

//Wathces the keys and performs actions on command. Whne left or right are detected
//the program checks to make sure that movement is possible, then gives the command to move.
//When up is detected the shape is rotated using the rotate function.
void keyPressed() {
  if(key == CODED) {
    if(keyCode == LEFT) {
      if(checkLeftMovement()) {
        for(int i=0; i<myShape.length; i++) {
          myShape[i].moveLeft();
        }
      }
      move.rewind();
      move.play();
    } else if(keyCode == RIGHT) {
      if(checkRightMovement()){
        for(int i=0; i<myShape.length; i++) {
          myShape[i].moveRight();
        }
      }
      move.rewind();
      move.play();
    } else if(keyCode == UP) {
      rotate();
      for(int i=0; i<myShape.length; i++) {
        if(myShape[i].getX() < 0 || myShape[i].getX() > width-130) {   
          rotate();
          rotate();
          rotate();
          return;
        }
      }
      for(int i=myBricks.size()-1; i>0; i--) {
        brick temp = myBricks.get(i);
        for(int j=0; j<myShape.length; j++) {
          if(temp.getX() == myShape[j].getX() && temp.getY() >= myShape[j].getY() && temp.getY() <= myShape[j].getY()+30) {
            rotate();
            rotate();
            rotate();
            return;
          }
        }
      }
      tetrisRotate.rewind();
      tetrisRotate.play();    
    }
  }
}

//If the game is over and the mouse is pressed, the function checks to see if the button on screen has been clicked,
//when clicked the program empties the arrays, sets game play to true, resets and count, and loads a new shape.
void mousePressed() {
  if(!keepPlaying) {
    if(mouseX >= 50 && mouseX <= 250 && mouseY>=225 && mouseY<=275){
      myBricks.clear();
      myShape = pickAShape();
      count = 0;
      keepPlaying = true;
    }
  }
}

//Randomly selects a shape to use and returns that shape as an array of brick objects.
brick[] pickAShape() {
  int temp = (int) random(1,8);
  if(temp==1) return tower();
  if(temp==2) return square();
  if(temp==3) return jShape();
  if(temp==4) return lShape();
  if(temp==5) return sShape();
  if(temp==6) return zShape();
  if(temp==7) return tShape();
  return tShape();
}

//Checks for an intersection between the shapes and the bottom of the screen or other bricks.
boolean intersection() {
 for(int i=0; i<myShape.length; i++) {
   if(myShape[i].getY() == (height-30)) {
     return true;
   }    
 }
 for(int i=myBricks.size()-1; i>=0; i--) {
   for(int j=0; j<myShape.length; j++) {
     brick temp = myBricks.get(i);
     if(myShape[j].getX() == temp.getX() && myShape[j].getY()+30 == temp.getY()) {
       return true;
     }
   }
 }
 return false;
}

//Checks for complete rows. When a complete row is found, it is erased from the board and the count is advanced.
void checkCompleteRows() {
  for(int i=0; i<myShape.length; i++) {
    if(checkRow(myShape[i].getY())){
      eraseRow(myShape[i].getY());
      count++;
    }
  }
}

//We know that a complete row could only occur given a shape landing there,
//thus we check every Y value of the shape and look for 10 bricks to have that Y value, we then know
//that row is complete
boolean checkRow( int checkY) {
  int count = 0;
  for(int i=0; i<myBricks.size(); i++) {
    brick temp = myBricks.get(i);
    if(temp.getY() == checkY){
      count ++;
    }
  }
  if(count >= 10) {
    return true;
  } else { return false;}
}

//Moves through the list of bricks and finds every one with the specified Y value and removes them from the
//array list. When it removes a brick it uses i-- to account for the shiftng of the elemetns in the array. 
//If a row is not included int he removal and sits above the row being erased then it is told to drop 30.
void eraseRow( int eraseY ) {
  for(int i=0; i<myBricks.size(); i++) {
    brick temp = myBricks.get(i);
    if(temp.getY() == eraseY) {
      myBricks.remove(i);
      i--;
    } else {
      if(temp.getY() < eraseY) {
        temp.dropARow();
      }
    }
  }
}

//Checks for the presence of the sides of the grid and for the presence of other blocks, if none are found
//the function returns true, permitting the shapes to move
boolean checkLeftMovement() {
  for(int i=0; i<myShape.length; i++) {
    if(myShape[i].getX() <= 0) return false;
  }
  for(int i=myBricks.size()-1; i >= 0; i--) {
    brick temp = myBricks.get(i);
    for(int j=0; j<myShape.length; j++) {
      if(myShape[j].getY() >= temp.getY() && myShape[j].getY() <= temp.getY()+30 && 
            temp.getX()+30 == myShape[j].getX()){
          return false;}
    }
  }
  return true;
}
boolean checkRightMovement() {
  for(int i=0; i<myShape.length; i++) {
    if(myShape[i].getX() >= width-130) return false;
  }
  for(int i=myBricks.size()-1; i >= 0; i--) {
    brick temp = myBricks.get(i);
    for(int j=0; j<myShape.length; j++) {
      if(myShape[j].getY() >= temp.getY() && myShape[j].getY() <= temp.getY()+30 && 
            temp.getX()-30 == myShape[j].getX()){
          return false;}
    }
  }
  return true;
}

//Rotating the shapes a whole would present additional effor as the new bottoms and proportions would have
//to be figured. Instead the program gives the appearance of a rotation by shifting the blocks in an assigned pattern.
//Every time the function is called it determines what shape is currently falling and what orientation the shape is in.
//The program then adds and subtracts values to move the blocks into the new orientation.
void rotate() {
  if(shapeType == 1){
    if(shapeRotate == 1) {
      myShape[0].transformX(-30);
      myShape[0].transformY(30);
      myShape[2].transformX(30);
      myShape[2].transformY(-30);
      myShape[3].transformX(60);
      myShape[3].transformY(-60);
      shapeRotate = 2;
      return;
    }
    if(shapeRotate == 2) {
      myShape[0].transformX(30);
      myShape[0].transformY(-30);
      myShape[2].transformX(-30);
      myShape[2].transformY(30);
      myShape[3].transformX(-60);
      myShape[3].transformY(60);
      shapeRotate = 1;
      return;
    }
  }
  if(shapeType == 3) {
    if(shapeRotate == 1) {
      myShape[0].transformX(30);
      myShape[0].transformY(-30);
      myShape[2].transformX(-30);
      myShape[2].transformY(30);
      myShape[3].transformX(-60);
      shapeRotate = 2;
      return;
    }
    if(shapeRotate == 2) {
      myShape[0].transformX(30);
      myShape[0].transformY(30);
      myShape[2].transformX(-30);
      myShape[2].transformY(-30);
      myShape[3].transformY(-60);
      shapeRotate = 3;
      return;
    }
    if(shapeRotate == 3) {
      myShape[0].transformX(-30);
      myShape[0].transformY(30);
      myShape[2].transformX(30);
      myShape[2].transformY(-30);
      myShape[3].transformX(60);
      shapeRotate = 4;
      return;
    }
    if(shapeRotate == 4) {
      myShape[0].transformY(-30);
      myShape[0].transformX(-30);
      myShape[2].transformY(30);
      myShape[2].transformX(30);
      myShape[3].transformY(60);
      shapeRotate = 1;
      return;
    }
  }
  if(shapeType == 4) {
    if(shapeRotate == 1) {
      myShape[0].transformX(30);
      myShape[1].transformY(-30);
      myShape[3].transformY(-30);
      myShape[3].transformX(-30);
      shapeRotate = 2;
      return;
    }
    if(shapeRotate == 2) {
      myShape[0].transformX(-30);
      myShape[0].transformY(-30);
      myShape[1].transformX(60);
      myShape[3].transformX(30);
      myShape[3].transformY(30);
      shapeRotate = 3;
      return;
    }
    if(shapeRotate == 3) {
      myShape[0].transformX(30);
      myShape[0].transformY(-30);
      myShape[1].transformY(60);
      myShape[3].transformX(-30);
      myShape[3].transformY(30);
      shapeRotate = 4;
      return;
    }
    if(shapeRotate == 4) {
      myShape[0].transformX(-30);
      myShape[0].transformY(60);
      myShape[1].transformX(-60);
      myShape[1].transformY(-30);
      myShape[3].transformX(30);
      myShape[3].transformY(-30);
      shapeRotate = 1;
      return;
    }
  }
  if(shapeType == 5) { 
    if(shapeRotate == 1) {
      myShape[0].transformX(60);
      myShape[1].transformY(-60);
      shapeRotate = 2;
      return;
    }
    if(shapeRotate == 2) {
      myShape[0].transformX(-60);
      myShape[1].transformY(60);
      shapeRotate = 1;
      return;
    }
  }
  if(shapeType == 6) {
    if(shapeRotate == 1) {
      myShape[0].transformX(60);
      myShape[3].transformY(-60);
      shapeRotate = 2;
      return;
    }
    if(shapeRotate == 2) {
      myShape[0].transformX(-60);
      myShape[3].transformY(60);
      shapeRotate = 1;
      return;
    }
  }
  if(shapeType == 7) {
    if(shapeRotate == 1) {
      myShape[0].transformX(30);
      myShape[0].transformY(-60);
      myShape[3].transformY(-30);
      shapeRotate = 2;
      return;
    }
    if(shapeRotate == 2) {
      myShape[0].transformX(-30);
      myShape[0].transformY(30);
      shapeRotate = 3;
      return;
    }
    if(shapeRotate == 3) {
      myShape[3].transformX(-30);
      myShape[3].transformY(-30);
      shapeRotate = 4;
      return;
    }
    if(shapeRotate == 4) {
      myShape[0].transformY(30);
      myShape[3].transformX(30);
      myShape[3].transformY(60);
      shapeRotate = 1;
      return;
    }
  }
}

//These functions are in charge of creating 4 brick objects in the given shape and drawing it above
//the game screen, allowing it to fall into play. These objects are returned as arrays ob bricks.
brick[] tower() {
  int startX = 120;
  int startY = -150;
  color myColor = color(0,255,255);
  brick[] myTower;
  myTower = new brick[4];
  for( int i=0; i<myTower.length; i++) {
    myTower[i] = new brick(startX, startY, myColor);
    startY += 30;
  }
  shapeType = 1;
  shapeRotate = 1;
  return myTower;
}

brick[] square() {
  int startX = 120;
  int startY = -60;
  color myColor = color(255,255,0);
  brick[] mySquare = new brick[4];
  mySquare[0] = new brick(startX, startY, myColor);
  mySquare[1] = new brick(startX + 30, startY, myColor);
  mySquare[2] = new brick(startX, startY + 30, myColor);
  mySquare[3] = new brick(startX + 30, startY + 30, myColor);
  shapeType = 2;
  shapeRotate = 1;
  return mySquare;
}

brick[] jShape() {
  int startX = 120;
  int startY = -60;
  color myColor = color(0,0,255);
  brick[] myJ = new brick[4];
  myJ[0] = new brick(startX, startY, myColor);
  myJ[1] = new brick(startX+30, startY, myColor);
  myJ[2] = new brick(startX+60, startY, myColor);
  myJ[3] = new brick(startX+60, startY+30, myColor);
  shapeType = 3;
  shapeRotate = 1;
  return myJ;
}

brick[] lShape() {
  int startX = 120;
  int startY = -30;
  color myColor = color(255,149,0);
  brick[] myL = new brick[4];
  myL[0] = new brick(startX, startY, myColor);
  myL[1] = new brick(startX, startY - 30, myColor);
  myL[2] = new brick(startX+30, startY -30, myColor);
  myL[3] = new brick(startX+60, startY -30, myColor);
  shapeType = 4;
  shapeRotate = 1;
  return myL;
}

brick[] sShape() {
  int startX = 120;
  int startY = -30;
  color myColor = color(110,255,0);
  brick[] myS = new brick[4];
  myS[0] = new brick(startX, startY, myColor);
  myS[1] = new brick(startX+30, startY, myColor);
  myS[2] = new brick(startX+30, startY-30, myColor);
  myS[3] = new brick(startX+60, startY-30, myColor);
  shapeType = 5;
  shapeRotate = 1;
  return myS;
}

brick[] zShape() {
  int startX = 120;
  int startY = -60;
  color myColor = color(255,0,0);
  brick[] myZ = new brick[4];
  myZ[0] = new brick(startX, startY, myColor);
  myZ[1] = new brick(startX+30, startY, myColor);
  myZ[2] = new brick(startX+30, startY+30, myColor);
  myZ[3] = new brick(startX+60, startY+30, myColor);
  shapeType = 6;
  shapeRotate = 1;
  return myZ;
}

brick[] tShape() {
  int startX = 120;
  int startY = -30;
  color myColor = color(108,0,110);
  brick[] myT = new brick[4];
  myT[0] = new brick(startX, startY, myColor);
  myT[1] = new brick(startX+30, startY, myColor);
  myT[2] = new brick(startX+30, startY-30, myColor);
  myT[3] = new brick(startX+60, startY, myColor);
  shapeType = 7;
  shapeRotate = 1;
  return myT;
}

//Brick objects are used to create the shapes seen on screen. They take in X and Y coordinates and a color
//The hold methods to draw the bricks, move the bricks left and right, move the bricks down, drop a row, change
//x and y position, and return the X or Y coordinates of the blocks. 
class brick {
  private int myX;
  private int myY;
  private color myC;
  private int xSize = ((width-100)/10);
  private int ySize = (height/20);
  brick(int X, int Y, color C) {
    myX = X;
    myY = Y;
    myC = C;
  }
  void draw() {
    fill(myC);
    rect(myX, myY, 30, 30);
  }
  void moveDown() {
    myY += 2;
  }
  void moveLeft() {
    myX -= 30;
  }
  void moveRight() {
    myX += 30;
  }
  void dropARow() {
    myY += 30;
  }
  void transformX(int X) {
    myX += X;
  }
  void transformY(int Y) {
    myY += Y;
  }
  int getY() {
    return myY;
  }
  int getX() {
    return myX;
  }
}


