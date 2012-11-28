//*********************************************************************
//**                            3D template                          **
//**                 Jarek Rossignac, Oct  2012                      **   
//*********************************************************************
import processing.opengl.*;                // load OpenGL libraries and utilities
import javax.media.opengl.*; 
import javax.media.opengl.glu.*; 
import java.nio.*;
GL gl; 
GLU glu; 

// ****************************** GLOBAL VARIABLES FOR DISPLAY OPTIONS *********************************
Boolean 
  showMesh=true,
  translucent=false,   
  showSilhouette=true, 
  showNMBE=true,
  showSpine=true,
  showControl=true,
  showTube=true,
  showFrenetQuads=false,
  showFrenetNormal=false,
  filterFrenetNormal=true,
  showTwistFreeNormal=false, 
  showHelpText=false; 

int numRotation=10;
char lastShapeKey='1';
// String SCC = "-"; // info on current corner

d_sphere DS = new d_sphere();

// ****************************** VIEW PARAMETERS *******************************************************
pt F = P(0,0,0); pt T = P(0,0,0); pt E = P(0,0,1000); vec U=V(0,1,0);  // focus  set with mouse when pressing ';', eye, and up vector
pt Q=P(0,0,0); vec I=V(1,0,0); vec J=V(0,1,0); vec K=V(0,0,1); // picked surface point Q and screen aligned vectors {I,J,K} set when picked
void initView() {Q=P(0,0,0); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1); F = P(0,0,0); E = P(0,0,1000); U=V(0,1,0); } // declares the local frames

// ******************************** MESHES ***********************************************
//Mesh M=new Mesh(); // meshes for models M0 and M1
Mesh S0=new Mesh();//meshes for Soilid 1
Mesh S1=new Mesh();//meshes for Soilid 2
Mesh S2=new Mesh();//meshes for Soilid 3
Mesh S3=new Mesh();//meshes for Soilid 4

float volume1=0, volume0=0;
float sampleDistance=1;
// ******************************** CURVES & SPINES ***********************************************
Curve C0=new Curve();
Curve CC0[]=new Curve[100];

Curve C1=new Curve();
Curve CC1[]=new Curve[100];

Curve C2=new Curve();
Curve CC2[]=new Curve[100];

Curve C3=new Curve();
Curve CC3[]=new Curve[100];

//Curve C0 = new Curve(5), S0 = new Curve(), C1 = new Curve(5), S1 = new Curve();  // control points and spines 0 and 1
//Curve C= new Curve(11,130,P());
//int nsteps=250; // number of smaples along spine
//float sd=10; // sample distance for spine
pt sE = P(), sF = P(); vec sU=V(); //  view parameters (saved with 'j'

// *******************************************************************************************************************    SETUP
void setup() {
  size(1000, 700, OPENGL);  
  setColors(); sphereDetail(6); 
  PFont font = loadFont("GillSans-24.vlw"); textFont(font, 20);  // font for writing labels on //  PFont font = loadFont("Courier-14.vlw"); textFont(font, 12); 
  // ***************** OpenGL and View setup
  glu= ((PGraphicsOpenGL) g).glu;  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  gl = pgl.beginGL();  pgl.endGL();
  initView(); // declares the local frames for 3D GUI

  // ***************** Load meshes
  S0.declareVectors();
  S0.resetMarkers().computeBox().updateON();
  
  S1.declareVectors();
  S1.resetMarkers().computeBox().updateON();
  
  S2.declareVectors();
  S2.resetMarkers().computeBox().updateON();
  
  S3.declareVectors();
  S3.resetMarkers().computeBox().updateON();
  //M.declareVectors().loadMeshVTS("data/horse.vts");
 // M.resetMarkers().computeBox().updateON(); // makes a cube around C[8]
  // ***************** Load Curve
 // C.loadPts();
  
  // ***************** Set view
  for(int i=0;i<numRotation;i++){
     CC0[i]=new Curve();
     CC1[i]=new Curve();
     CC2[i]=new Curve();
     CC3[i]=new Curve();
 }
  F=P(); E=P(0,0,500);
//  for(int i=0; i<10; i++) vis[i]=true; // to show all types of triangles
 DS.init();
 }
  
// ******************************************************************************************************************* DRAW      
void draw() {  
  
  background(white);
/*  // -------------------------------------------------------- Help ----------------------------------
  if(showHelpText) {
    camera(); // 2D display to show cutout
    lights();
    fill(black); writeHelp();
    return;
    } */
    
  if (keyPressed)
     if(key=='1'||key=='2'||key=='3'||key=='4')
        lastShapeKey=key;
  if(pressed) {
     
     if (keyPressed&&(key=='d'||key=='i')) {
       
        if(lastShapeKey=='1'){
           C0.pick(P(mouseX,mouseY,0));
           if(key=='d') { C0.delete();}
           if(key=='i') { C0.insert();} 
        }
         if(lastShapeKey=='2'){
           C1.pick(P(mouseX,mouseY,0));
           if(key=='d') { C1.delete();}
           if(key=='i') { C1.insert();} 
        }
           if(lastShapeKey=='3'){
           C2.pick(P(mouseX,mouseY,0));
           if(key=='d') { C2.delete();}
           if(key=='i') { C2.insert();} 
        }
           if(lastShapeKey=='4'){
           C3.pick(P(mouseX,mouseY,0));
           if(key=='d') { C3.delete();}
           if(key=='i') { C3.insert();} 
        }

      }

  }
    
  fill(black);
  camera();
  specular(0,0,0); shininess(0);
  text("Number of sample (change by pressed s and mouse left click): "+numRotation,10,20);
  text("Current selected shape: Shape "+lastShapeKey,10,50);
  text("Press ?: HELP ",10,80);
  
  noFill();
  stroke(green);
  C0.drawEdges() ;
  stroke(black);
  C0.showSamples(2);
  stroke(red);
  C1.drawEdges() ;
  stroke(black);
  C1.showSamples(2);
  stroke(cyan);
  C2.drawEdges() ;
  stroke(black);
  C2.showSamples(2);
  stroke(magenta);
  C3.drawEdges() ;
  stroke(black);
  C3.showSamples(2);
  
  
  // -------------------------------------------------------- 3D display : set up view ----------------------------------
  camera(E.x, E.y, E.z, F.x, F.y, F.z, U.x, U.y, U.z); // defines the view : eye, ctr, up
  vec Li=U(A(V(E,F),0.1*d(E,F),J));   // vec Li=U(A(V(E,F),-d(E,F),J)); 
  directionalLight(255,255,255,Li.x,Li.y,Li.z); // direction of light: behind and above the viewer
  specular(255,255,0); shininess(5);
  
  //***************** display the directional sphere*****************************//
  vec EF = V(E,F);
  vec tmp = R(U,PI/2,I,J);
  vec REF = R(U(EF),-PI/2,U(EF), N(U,U(EF)));
  DS.setCenter(P(E, A(V(250,U(EF)),A(V(150,REF), V(-100,U))))).displayG();
  
//  println("EF: "+EF.x+" "+EF.y+" "+EF.z);
//  println("REF: "+REF.x+" "+REF.y+" "+REF.z);

  //***************** END of display the directional sphere*****************************//  
  
  noFill();
  BuildShape();
 // buildSurface();
  
 if(showMesh) {
   makeMesh();
   if(lastShapeKey=='1'){stroke(white);  fill(green);S0.showFront();}
   if(lastShapeKey=='2'){stroke(white);  fill(red);S1.showFront();}
   if(lastShapeKey=='3'){stroke(white);  fill(cyan);S2.showFront();}
   if(lastShapeKey=='4'){stroke(white);  fill(magenta );S3.showFront();}
 }
  // -------------------------- display and edit control points of the spines and box ----------------------------------   
 /*   if(pressed) {
     if (keyPressed&&(key=='a'||key=='s')) {
  //     fill(white,0); noStroke(); if(showControl) C.showSamples(20);
   //    C.pick(Pick());
       println(Pick().x+" "+Pick().y+" "+Pick().z);
       }
     }
     */
  // -------------------------------------------------------- create control curves  ----------------------------------   
  // C0.empty().append(C.Pof(0)).append(C.Pof(1)).append(C.Pof(2)).append(C.Pof(3)).append(C.Pof(4)); 

   // -------------------------------------------------------- create and show spines  ----------------------------------   
//   S0=S0.makeFrom(C0,500).resampleDistance(sampleDistance);
 //  stroke(blue); noFill(); if(showSpine) S0.drawEdges(); 
   
   // -------------------------------------------------------- compute spine normals  ----------------------------------   
 //  S0.prepareSpine(0);
  
   // -------------------------------------------------------- show tube ----------------------------------   
  // if(showTube) S0.showTube(10,4,10,orange); 
   
   // -------------------------------------------------------- create and move mesh ----------------------------------   
//   pt Q0=C.Pof(10); fill(red); show(Q0,4);
//   M.moveTo(Q0);
  
     // -------------------------------------------------------- show mesh ----------------------------------   
  // if(showMesh) { fill(yellow); if(M.showEdges) stroke(white);  else noStroke(); M.showFront();} 
   
    // -------------------------- pick mesh corner ----------------------------------   
//   if(pressed) if (keyPressed&&(key=='.')) M.pickc(Pick());
 
 
     // -------------------------------------------------------- show mesh corner ----------------------------------   
  // if(showMesh) { fill(red); noStroke(); M.showc();} 
 
    // -------------------------------------------------------- edit mesh  ----------------------------------   
  //if(pressed) {
  //   if (keyPressed&&(key=='x'||key=='z')) M.pickc(Pick()); // sets M.sc to the closest corner in M from the pick point
   //  if (keyPressed&&(key=='X'||key=='Z')) M.pickc(Pick()); // sets M.sc to the closest corner in M from the pick point
  //   }
 
  // -------------------------------------------------------- graphic picking on surface and view control ----------------------------------   
  if (keyPressed&&key==' ') T.set(Pick()); // sets point T on the surface where the mouse points. The camera will turn toward's it when the ';' key is released
  SetFrame(Q,I,J,K);  // showFrame(Q,I,J,K,30);  // sets frame from picked points and screen axes
  // rotate view 
  if(!keyPressed&&mousePressed) {E=R(E,  PI*float(mouseX-pmouseX)/width,I,K,F); E=R(E,-PI*float(mouseY-pmouseY)/width,J,K,F); } // rotate E around F 
  if(keyPressed&&key=='D'&&mousePressed) {E=P(E,-float(mouseY-pmouseY),K); }  //   Moves E forward/backward
  if(keyPressed&&key=='d'&&mousePressed) {E=P(E,-float(mouseY-pmouseY),K);U=R(U, -PI*float(mouseX-pmouseX)/width,I,J); }//   Moves E forward/backward and rotatees around (F,Y)
   
  // -------------------------------------------------------- Disable z-buffer to display occluded silhouettes and other things ---------------------------------- 
   hint(DISABLE_DEPTH_TEST);  // show on top
//  stroke(black); if(showControl) {C0.showSamples(2);}
//  if(showMesh&&showSilhouette) {stroke(dbrown); M.drawSilhouettes(); }  // display silhouettes
//  strokeWeight(2); stroke(red);if(showMesh&&showNMBE) M.showMBEs();  // manifold borders
  camera(); // 2D view to write help text
//  writeFooterHelp();
  hint(ENABLE_DEPTH_TEST); // show silouettes

  // -------------------------------------------------------- SNAP PICTURE ---------------------------------- 
   if(snapping) snapPicture(); // does not work for a large screen
    pressed=false;

 } // end draw
 
 
 // ****************************************************************************************************************************** INTERRUPTS
Boolean pressed=false;

void mousePressed() {pressed=true;
 if (keyPressed) {
   if (key=='1' ) {  //done avoid nonconvex here when user is going to insert new point
     boolean validTurn=false;
     if(C0.n>=3){
         float det1=(C0.P[C0.n-2].x-C0.P[C0.n-3].x)*(-(C0.P[C0.n-1].y-C0.P[C0.n-2].y))+(C0.P[C0.n-2].y-C0.P[C0.n-3].y)*(C0.P[C0.n-1].x-C0.P[C0.n-2].x);
         float det2=(C0.P[C0.n-1].x-C0.P[C0.n-2].x)*(-(mouseY-C0.P[C0.n-1].y))+(C0.P[C0.n-1].y-C0.P[C0.n-2].y)*(mouseX-C0.P[C0.n-1].x);
         if((det1>0&&det2>0)||(det1<0&&det2<0)) validTurn=true;
       
     }else
        validTurn=true;
     if(C0.n<1) C0.addPt(new pt(mouseX,mouseY,0)); else if(d(new pt(mouseX,mouseY,0),C0.P[C0.n-1])>10 && C0.n<500 && validTurn) C0.addPt(new pt(mouseX,mouseY,0));
 
     lastShapeKey='1';
   }
   
   if (key=='2' ) { 
        boolean validTurn=false;
       if(C1.n>=3){
           float det1=(C1.P[C1.n-2].x-C1.P[C1.n-3].x)*(-(C1.P[C1.n-1].y-C1.P[C1.n-2].y))+(C1.P[C1.n-2].y-C1.P[C1.n-3].y)*(C1.P[C1.n-1].x-C1.P[C1.n-2].x);
           float det2=(C1.P[C1.n-1].x-C1.P[C1.n-2].x)*(-(mouseY-C1.P[C1.n-1].y))+(C1.P[C1.n-1].y-C1.P[C1.n-2].y)*(mouseX-C1.P[C1.n-1].x);
           if((det1>0&&det2>0)||(det1<0&&det2<0)) validTurn=true;
         
       }else
          validTurn=true;
       if(C1.n<1) C1.addPt(new pt(mouseX,mouseY,0)); else if(d(new pt(mouseX,mouseY,0),C1.P[C1.n-1])>10 && C1.n<500 && validTurn) C1.addPt(new pt(mouseX,mouseY,0));
       lastShapeKey='2';
   }
   if (key=='3' ) {
          boolean validTurn=false;
         if(C2.n>=3){
             float det1=(C2.P[C2.n-2].x-C2.P[C2.n-3].x)*(-(C2.P[C2.n-1].y-C2.P[C2.n-2].y))+(C2.P[C2.n-2].y-C2.P[C2.n-3].y)*(C2.P[C2.n-1].x-C2.P[C2.n-2].x);
             float det2=(C2.P[C2.n-1].x-C2.P[C2.n-2].x)*(-(mouseY-C2.P[C2.n-1].y))+(C2.P[C2.n-1].y-C2.P[C2.n-2].y)*(mouseX-C2.P[C2.n-1].x);
             if((det1>0&&det2>0)||(det1<0&&det2<0)) validTurn=true;
           
         }else
          validTurn=true;
       if(C2.n<1) C2.addPt(new pt(mouseX,mouseY,0)); else if(d(new pt(mouseX,mouseY,0),C2.P[C2.n-1])>10 && C2.n<500 && validTurn) C2.addPt(new pt(mouseX,mouseY,0));
       lastShapeKey='3';
     
   }
   if (key=='4' ) {  
         boolean validTurn=false;
         if(C3.n>=3){
             float det1=(C3.P[C3.n-2].x-C3.P[C3.n-3].x)*(-(C3.P[C3.n-1].y-C3.P[C3.n-2].y))+(C3.P[C3.n-2].y-C3.P[C3.n-3].y)*(C3.P[C3.n-1].x-C3.P[C3.n-2].x);
             float det2=(C3.P[C3.n-1].x-C3.P[C3.n-2].x)*(-(mouseY-C3.P[C3.n-1].y))+(C3.P[C3.n-1].y-C3.P[C3.n-2].y)*(mouseX-C3.P[C3.n-1].x);
             if((det1>0&&det2>0)||(det1<0&&det2<0)) validTurn=true;
           
         }else
          validTurn=true;
        if(C3.n<1) C3.addPt(new pt(mouseX,mouseY,0)); else if(d(new pt(mouseX,mouseY,0),C3.P[C3.n-1])>10 && C3.n<500 && validTurn) C3.addPt(new pt(mouseX,mouseY,0));
        lastShapeKey='4';
   }
   
   
 }
  if (keyPressed && key=='s') {numRotation+=1; if (numRotation<=5) numRotation=5; if (numRotation>=50) numRotation=50;
       for(int i=0;i<numRotation;i++){
         CC0[i]=new Curve();
         CC1[i]=new Curve();
         CC2[i]=new Curve();
         CC3[i]=new Curve();
      }
    }  


}


void mouseDragged() {
      if(lastShapeKey=='1'&&keyPressed&&key=='m') {C0.pick(P(mouseX,mouseY,0));C0.P[C0.p].x+=(mouseX-pmouseX);C0.P[C0.p].y+=(mouseY-pmouseY); } 
       if(lastShapeKey=='2'&&keyPressed&&key=='m') {C1.pick(P(mouseX,mouseY,0));C1.P[C1.p].x+=(mouseX-pmouseX);C1.P[C1.p].y+=(mouseY-pmouseY); } 
        if(lastShapeKey=='3'&&keyPressed&&key=='m') {C2.pick(P(mouseX,mouseY,0));C2.P[C2.p].x+=(mouseX-pmouseX);C2.P[C2.p].y+=(mouseY-pmouseY); } 
         if(lastShapeKey=='4'&&keyPressed&&key=='m') {C3.pick(P(mouseX,mouseY,0));C3.P[C3.p].x+=(mouseX-pmouseX);C3.P[C3.p].y+=(mouseY-pmouseY); } 
  // adjust the obstacle size
//  if(keyPressed&&key=='a') {C.dragPoint( V(.5*(mouseX-pmouseX),I,.5*(mouseY-pmouseY),K) ); } // move selected vertex of curve C in screen plane
//  if(keyPressed&&key=='s') {C.dragPoint( V(.5*(mouseX-pmouseX),I,-.5*(mouseY-pmouseY),J) ); } // move selected vertex of curve C in screen plane
//  if(keyPressed&&key=='b') {C.dragAll(0,5, V(.5*(mouseX-pmouseX),I,.5*(mouseY-pmouseY),K) ); } // move selected vertex of curve C in screen plane
//  if(keyPressed&&key=='v') {C.dragAll(0,5, V(.5*(mouseX-pmouseX),I,-.5*(mouseY-pmouseY),J) ); } // move selected vertex of curve Cb in XZ
//  if(keyPressed&&key=='x') {M.add(float(mouseX-pmouseX),I).add(-float(mouseY-pmouseY),J); M.normals();} // move selected vertex in screen plane
//  if(keyPressed&&key=='z') {M.add(float(mouseX-pmouseX),I).add(float(mouseY-pmouseY),K); M.normals();}  // move selected vertex in X/Z screen plane
//  if(keyPressed&&key=='X') {M.addROI(float(mouseX-pmouseX),I).addROI(-float(mouseY-pmouseY),J); M.normals();} // move selected vertex in screen plane
//  if(keyPressed&&key=='Z') {M.addROI(float(mouseX-pmouseX),I).addROI(float(mouseY-pmouseY),K); M.normals();}  // move selected vertex in X/Z screen plane 
  }

void mouseReleased() {
    U.set(M(J)); // reset camera up vector
    
    }
  
void keyReleased() {
   if(key==' ') F=P(T);                           //   if(key=='c') M0.moveTo(C.Pof(10));
   U.set(M(J)); // reset camera up vector
   } 

 
void keyPressed() {
  if(key=='a') {} // drag curve control point in xz (mouseDragged)
  if(key=='b') {}  // move S2 in XZ
  if(key=='c') {} // load curve
  if(key=='d') {} 
  if(key=='e') {}
 // if(key=='f') {filterFrenetNormal=!filterFrenetNormal; if(filterFrenetNormal) println("Filtering"); else println("not filtering");}
  if(key=='g') {} // change global twist w (mouseDrag)
  if(key=='h') {} // hide picked vertex (mousePressed)
  if(key=='i') {}
  if(key=='j') {}
  if(key=='k') {}
  if(key=='l') {}
 // if(key=='m') {showMesh=!showMesh;}
  if(key=='n') {showNMBE=!showNMBE;}
  if(key=='o') {}
  if(key=='p') {}
  if(key=='q') {}
  if(key=='r') {}
  if(key=='s') {} // drag curve control point in xz (mouseDragged)
  if(key=='t') {showTube=!showTube;}
  if(key=='u') {}
  if(key=='v') {} // move S2
  if(key=='w') {}
  if(key=='x') {} // drag mesh vertex in xy (mouseDragged)
  if(key=='y') {}
  if(key=='z') {} // drag mesh vertex in xz (mouseDragged)
   
//  if(key=='A') {C.savePts();}
  if(key=='B') {}
//  if(key=='C') {C.loadPts();} // save curve
  if(key=='D') {} //move in depth without rotation (draw)
 // if(key=='E') {M.smoothen(); M.normals();}
  if(key=='F') {}
  if(key=='G') {}
  if(key=='H') {}
  if(key=='I') {}
  if(key=='J') {}
  if(key=='K') {}
//  if(key=='L') {M.loadMeshVTS().updateON().resetMarkers().computeBox(); F.set(M.Cbox); E.set(P(F,M.rbox*2,K)); for(int i=0; i<10; i++) vis[i]=true;}
  if(key=='M') {}
  //if(key=='N') {M.next();}
  if(key=='O') {}
  if(key=='P') {}
  if(key=='Q') {exit();}
  if(key=='R') {}
 // if(key=='S') {M.swing();}
  if(key=='T') {}
  if(key=='U') {}
  if(key=='V') {} 
//  if(key=='W') {M.saveMeshVTS();}
  if(key=='X') {} // drag mesh vertex in xy and neighbors (mouseDragged)
//  if(key=='Y') {M.refine(); M.makeAllVisible();}
  if(key=='Z') {} // drag mesh vertex in xz and neighbors (mouseDragged)

 // if(key=='`') {M.perturb();}
 // if(key=='~') {showSpine=!showSpine;}
//  if(key=='!') {snapping=true;}
  if(key=='@') {}
  if(key=='#') {}
//  if(key=='$') {M.moveTo(C.Pof(10));} // ???????
  if(key=='%') {}
  if(key=='&') {}
//  if(key=='*') {sampleDistance*=2;}
  if(key=='(') {}
//  if(key==')') {showSilhouette=!showSilhouette;}
//  if(key=='_') {M.flatShading=!M.flatShading;}
//  if(key=='+') {M.flip();} // flip edge of M
//  if(key=='-') {M.showEdges=!M.showEdges;}
//  if(key=='=') {C.P[5].set(C.P[0]); C.P[6].set(C.P[1]); C.P[7].set(C.P[2]); C.P[8].set(C.P[3]); C.P[9].set(C.P[4]);}
//  if(key=='{') {showFrenetQuads=!showFrenetQuads;}
  if(key=='}') {}
  if(key=='|') {}
//  if(key=='[') {initView(); F.set(M.Cbox); E.set(P(F,M.rbox*2,K));}
 // if(key==']') {F.set(M.Cbox);}
//  if(key==':') {translucent=!translucent;}
  if(key==';') {showControl=!showControl;}
  if(key=='<') {}
  if(key=='>') {if (shrunk==0) shrunk=1; else shrunk=0;}
  if(key=='?') {showHelpText=!showHelpText;}
  if(key=='.') {} // pick corner
  if(key==',') {}
  if(key=='^') {} 
  if(key=='/') {} 
  //if(key==' ') {} // pick focus point (will be centered) (draw & keyReleased)

  if(key=='0') {w=0;}
//  for(int i=0; i<10; i++) if (key==char(i+48)) vis[i]=!vis[i];
  
  } //------------------------------------------------------------------------ end keyPressed

float [] Volume = new float [3];
float [] Area = new float [3];
float dis = 0;
  
Boolean prev=false;

void showGrid(float s) {
  for (float x=0; x<width; x+=s*20) line(x,0,x,height);
  for (float y=0; y<height; y+=s*20) line(0,y,width,y);
  }
  
  // Snapping PICTURES of the screen
PImage myFace; // picture of author's face, read from file pic.jpg in data folder
int pictureCounter=0;
Boolean snapping=false; // used to hide some text whil emaking a picture
void snapPicture() {saveFrame("PICTURES/P"+nf(pictureCounter++,3)+".jpg"); snapping=false;}


void BuildShape(){
    pt O=P(0,0,0);
    vec I=V(1,0,0);
    vec J=V(0,1,0);
    vec K=V(0,0,1);
    vec originalAxis=V(0,0,0);
    float angle=0;
    
    //C0
    if(C0.n>1){
       originalAxis=V(C0.P[0],C0.P[C0.n-1]);
    }
    println(originalAxis.x+"  "+originalAxis.y+"  "+originalAxis.z);
    angle=0;
    for(int i=0;i<numRotation;i++){
      vec axis;
      axis=R(I,angle,I,J);
      CC0[i].n=C0.n;
      for(int j=0;j<C0.n;j++){
        pt newP=P();
        newP.set(O);
        float x= d(originalAxis,V(C0.P[0],C0.P[j]))/n(originalAxis);
        println(d(C0.P[0],C0.P[j]));
        float y=sqrt(d(C0.P[0],C0.P[j])*d(C0.P[0],C0.P[j])-x*x);
     //   println(x+" "+y);
        CC0[i].P[j]=newP.add(V(x,K,y,axis));
      }
      angle=(i+1)*2*PI/(numRotation-1);
    }
    
    //C1
    if(C1.n>1){
       originalAxis=V(C1.P[0],C1.P[C1.n-1]);
    }
    println(originalAxis.x+"  "+originalAxis.y+"  "+originalAxis.z);
    angle=0;
    for(int i=0;i<numRotation;i++){
      vec axis;
      axis=R(I,angle,I,J);
      CC1[i].n=C1.n;
      for(int j=0;j<C1.n;j++){
        pt newP=P();
        newP.set(O);
        float x= d(originalAxis,V(C1.P[0],C1.P[j]))/n(originalAxis);
        println(d(C1.P[0],C1.P[j]));
        float y=sqrt(d(C1.P[0],C1.P[j])*d(C1.P[0],C1.P[j])-x*x);
     //   println(x+" "+y);
        CC1[i].P[j]=newP.add(V(x,K,y,axis));
      }
      angle=(i+1)*2*PI/(numRotation-1);
    }
    
     //C2
    if(C2.n>1){
       originalAxis=V(C2.P[0],C2.P[C2.n-1]);
    }
    println(originalAxis.x+"  "+originalAxis.y+"  "+originalAxis.z);
    angle=0;
    for(int i=0;i<numRotation;i++){
      vec axis;
      axis=R(I,angle,I,J);
      CC2[i].n=C2.n;
      for(int j=0;j<C2.n;j++){
        pt newP=P();
        newP.set(O);
        float x= d(originalAxis,V(C2.P[0],C2.P[j]))/n(originalAxis);
        println(d(C2.P[0],C2.P[j]));
        float y=sqrt(d(C2.P[0],C2.P[j])*d(C2.P[0],C2.P[j])-x*x);
     //   println(x+" "+y);
        CC2[i].P[j]=newP.add(V(x,K,y,axis));
      }
      angle=(i+1)*2*PI/(numRotation-1);
    }
    
     //C3
    if(C3.n>1){
       originalAxis=V(C3.P[0],C3.P[C3.n-1]);
    }
    println(originalAxis.x+"  "+originalAxis.y+"  "+originalAxis.z);
    angle=0;
    for(int i=0;i<numRotation;i++){
      vec axis;
      axis=R(I,angle,I,J);
      CC3[i].n=C3.n;
      for(int j=0;j<C3.n;j++){
        pt newP=P();
        newP.set(O);
        float x= d(originalAxis,V(C3.P[0],C3.P[j]))/n(originalAxis);
        println(d(C3.P[0],C3.P[j]));
        float y=sqrt(d(C3.P[0],C3.P[j])*d(C3.P[0],C3.P[j])-x*x);
     //   println(x+" "+y);
        CC3[i].P[j]=newP.add(V(x,K,y,axis));
      }
      angle=(i+1)*2*PI/(numRotation-1);
    }
    
}

void buildSurface(){
  //C0
    fill(green);stroke(black);
    for(int i=0;i<numRotation;i++)
    {
      int j=i+1;
      if(j>numRotation-1) j=0;
      for(int k=0;k<CC0[i].n-1;k++){
        beginShape();
        vertex(CC0[i].P[k]); 
        vertex(CC0[i].P[k+1]); 
        vertex(CC0[j].P[k+1]); 
        vertex(CC0[j].P[k]); 
        endShape();
      }
    }
    
    //C1
    fill(red);stroke(black);
    for(int i=0;i<numRotation;i++)
    {
      int j=i+1;
      if(j>numRotation-1) j=0;
      for(int k=0;k<CC1[i].n-1;k++){
        beginShape();
        vertex(CC1[i].P[k]); 
        vertex(CC1[i].P[k+1]); 
        vertex(CC1[j].P[k+1]); 
        vertex(CC1[j].P[k]); 
        endShape();
      }
    }
    
    //C2
    fill(cyan);stroke(black);
    for(int i=0;i<numRotation;i++)
    {
      int j=i+1;
      if(j>numRotation-1) j=0;
      for(int k=0;k<CC2[i].n-1;k++){
        beginShape();
        vertex(CC2[i].P[k]); 
        vertex(CC2[i].P[k+1]); 
        vertex(CC2[j].P[k+1]); 
        vertex(CC2[j].P[k]); 
        endShape();
      }
    }
    
    //C3
    fill(magenta);stroke(black);
    for(int i=0;i<numRotation;i++)
    {
      int j=i+1;
      if(j>numRotation-1) j=0;
      for(int k=0;k<CC3[i].n-1;k++){
        beginShape();
        vertex(CC3[i].P[k]); 
        vertex(CC3[i].P[k+1]); 
        vertex(CC3[j].P[k+1]); 
        vertex(CC3[j].P[k]); 
        endShape();
      }
    }
    
}

void makeMesh(){
  
   //C0
   if(C0.n>2){
      S0.empty();
      S0.addVertex(CC0[0].P[0]);
      S0.addVertex(CC0[0].P[C0.n-1]);
      for(int i=0;i<numRotation;i++)
      {
        int j=i+1;
        if(j>numRotation-1) j=0;
         
        for(int k=0;k<CC0[i].n-1;k++){
        
          if(k==0){
            S0.addVertex(CC0[j].P[k+1]); 
            S0.addVertex(CC0[i].P[k+1]);
            S0.addTriangle(0,S0.nv-2,S0.nv-1);
          }else if (k==CC0[i].n-2){
            S0.addTriangle(S0.nv-1,S0.nv-2,1);
          }else
          {
            S0.addVertex(CC0[j].P[k+1]); 
            S0.addTriangle(S0.nv-3,S0.nv-1,S0.nv-2);
            S0.addVertex(CC0[i].P[k+1]); 
            S0.addTriangle(S0.nv-3,S0.nv-2,S0.nv-1);
          }
          
        }
      }
      
      
   }
     
     
     //C1
    if(C1.n>2){
        S1.empty();
        S1.addVertex(CC1[0].P[0]);
        S1.addVertex(CC1[0].P[C1.n-1]);
        for(int i=0;i<numRotation;i++)
        {
          int j=i+1;
          if(j>numRotation-1) j=0;
           
          for(int k=0;k<CC1[i].n-1;k++){
          
            if(k==0){
              S1.addVertex(CC1[j].P[k+1]); 
              S1.addVertex(CC1[i].P[k+1]);
              S1.addTriangle(0,S1.nv-2,S1.nv-1);
            }else if (k==CC1[i].n-2){
              S1.addTriangle(S1.nv-1,S1.nv-2,1);
            }else
            {
              S1.addVertex(CC1[j].P[k+1]); 
              S1.addTriangle(S1.nv-3,S1.nv-1,S1.nv-2);
              S1.addVertex(CC1[i].P[k+1]); 
              S1.addTriangle(S1.nv-3,S1.nv-2,S1.nv-1);
            }
            
          }
        }
       
    }
    
     //C2
    if(C2.n>2){
        S2.empty();
        S2.addVertex(CC2[0].P[0]);
        S2.addVertex(CC2[0].P[C2.n-1]);
        for(int i=0;i<numRotation;i++)
        {
          int j=i+1;
          if(j>numRotation-1) j=0;
           
          for(int k=0;k<CC2[i].n-1;k++){
          
            if(k==0){
              S2.addVertex(CC2[j].P[k+1]); 
              S2.addVertex(CC2[i].P[k+1]);
              S2.addTriangle(0,S2.nv-2,S2.nv-1);
            }else if (k==CC2[i].n-2){
              S2.addTriangle(S2.nv-1,S2.nv-2,1);
            }else
            {
              S2.addVertex(CC2[j].P[k+1]); 
              S2.addTriangle(S2.nv-3,S2.nv-1,S2.nv-2);
              S2.addVertex(CC2[i].P[k+1]); 
              S2.addTriangle(S2.nv-3,S2.nv-2,S2.nv-1);
            }
            
          }
        }
       
    }
    
     //C3
    if(C3.n>2){
        S3.empty();
        S3.addVertex(CC3[0].P[0]);
        S3.addVertex(CC3[0].P[C3.n-1]);
        for(int i=0;i<numRotation;i++)
        {
          int j=i+1;
          if(j>numRotation-1) j=0;
           
          for(int k=0;k<CC3[i].n-1;k++){
          
            if(k==0){
              S3.addVertex(CC3[j].P[k+1]); 
              S3.addVertex(CC3[i].P[k+1]);
              S3.addTriangle(0,S3.nv-2,S3.nv-1);
            }else if (k==CC3[i].n-2){
              S3.addTriangle(S3.nv-1,S3.nv-2,1);
            }else
            {
              S3.addVertex(CC3[j].P[k+1]); 
              S3.addTriangle(S3.nv-3,S3.nv-1,S3.nv-2);
              S3.addVertex(CC3[i].P[k+1]); 
              S3.addTriangle(S3.nv-3,S3.nv-2,S3.nv-1);
            }
            
          }
        }
       
    }
    
     
     
     
      
}



