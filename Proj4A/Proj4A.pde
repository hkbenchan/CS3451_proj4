//*********************************************************************
//      project 4A, 3D velocity field curve and particle simulation
//      Author(s): Yik Wai Ng (GTID: 902954691) ; Ho Pan Chan (GTID: 902956511)
//      Class: CS3451 
//      Last update on: November 3, 2012
//      Usage: refer to help text ... display help text by pressing shift + ?, to toggle, press shift + ? again                                                        
//*********************************************************************
import processing.opengl.*;                // load OpenGL libraries and utilities
import javax.media.opengl.*; 
import javax.media.opengl.glu.*; 
import java.nio.*;
GL gl; 
GLU glu; 

// ****************************** GLOBAL VARIABLES FOR DISPLAY OPTIONS *********************************
Boolean 
  addDynamic=false,
  showMesh=false,
  translucent=false,   
  showSilhouette=false, 
  showNMBE=true,
  showSpine=false,
  showControl=true,
  showTube=true,
  showFrenetQuads=false,
  showFrenetNormal=false,
  filterFrenetNormal=true,
  showTwistFreeNormal=false, 
  showHelpText=false; 

//**************************** global variables ****************************
float t=0, f=0, emit_timer = 0, STANDARD_TIMER = 0.01;
generator G = new generator();
float dynamicBlendParameter=.5;
float TT;
   
// ****************************** VIEW PARAMETERS *******************************************************
pt F = P(0,0,0); pt T = P(0,0,0); pt E = P(0,0,1000); vec U=V(0,1,0);  // focus  set with mouse when pressing ';', eye, and up vector
pt Q=P(0,0,0); vec I=V(1,0,0); vec J=V(0,1,0); vec K=V(0,0,1); // picked surface point Q and screen aligned vectors {I,J,K} set when picked
void initView() {Q=P(0,0,0); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1); F = P(0,0,0); E = P(0,0,1000); U=V(0,1,0); } // declares the local frames

float volume1=0, volume0=0;
float sampleDistance=1;
// ******************************** CURVES & SPINES ***********************************************
Curve C0 = new Curve(500); //S0 = new Curve(), C1 = new Curve(5), S1 = new Curve();  
Curve mainC = new Curve(500);// control points and spines 0 and 1
pt sE = P(), sF = P(); vec sU=V(); //  view parameters (saved with 'j'

// *******************************************************************************************************************    SETUP
void setup() {
  size(1200, 700, OPENGL);  
  setColors(); sphereDetail(6); 
  PFont font = loadFont("GillSans-24.vlw"); textFont(font, 20);  // font for writing labels on //  PFont font = loadFont("Courier-14.vlw"); textFont(font, 12); 
  // ***************** OpenGL and View setup
  glu= ((PGraphicsOpenGL) g).glu;  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  gl = pgl.beginGL();  pgl.endGL();
  initView(); // declares the local frames for 3D GUI

  C0.loadPts();
  redrawMainCurve();
  // ***************** Set view
  
  // ***************** Generator Init
  G.init();
  G.loadInfo();
  randomSeed(10);
 
  F=P(); E=P(0,0,500);
  for(int i=0; i<10; i++) vis[i]=true; // to show all types of triangles
  }
  
// ******************************************************************************************************************* DRAW      
void draw() {  
  TT=1./30;
  background(white);
 
  // -------------------------------------------------------- Help ----------------------------------
  if(showHelpText) {
    camera(); // 2D display to show cutout
    lights();
    fill(black); writeHelp();
    return;
    } 
    
  fill(black);
  specular(0,0,0); shininess(0);
  text("Emission rate: "+(int)G.emit_rate,10,40);
  text("Press ?: HELP ",10,60);
  if (addDynamic)
     text("Add Dynamic: Yes ; Blend Parameter: "+dynamicBlendParameter,10,20);
  else
     text("Add Dynamic: No",10,20);
  
  // -------------------------------------------------------- 3D display : set up view ----------------------------------
  camera(E.x, E.y, E.z, F.x, F.y, F.z, U.x, U.y, U.z); // defines the view : eye, ctr, up
  vec Li=U(A(V(E,F),0.1*d(E,F),J));   // vec Li=U(A(V(E,F),-d(E,F),J)); 
  directionalLight(255,255,255,Li.x,Li.y,Li.z); // direction of light: behind and above the viewer
  specular(255,255,0); shininess(5);
  
  

  // -------------------------- display and edit control points of the spines and box ----------------------------------   
    if(pressed) {
     if (keyPressed&&(key=='z'||key=='x'||key=='c'||key=='a'||key=='i'||key==',')) {
       fill(white,0); noStroke(); if(showControl) C0.showSamples(20);
       C0.pick(Pick());
        println(Pick().x+" "+Pick().y+" "+Pick().z);
       if(key=='c') { C0.delete();  G.resetQueue();redrawMainCurve();} //delete selected pt
       if(key=='a') { C0.append(Pick());   G.resetQueue();redrawMainCurve();}// C0.append(Pick());} //append pt at the end
       if(key=='i') { C0.insert(); redrawMainCurve();} // insert control pt
       if(key==',') { G.setCenter(Pick());} // insert control pt
      
      
       }
     }
     

  // -------------------------------------------------------- create control curves  ----------------------------------   
    stroke(black); noFill(); C0.showSamples();
    stroke(blue);  mainC.showSamples();mainC.drawEdges(); 
  
   // -------------------------------------------------------- show tube ----------------------------------   
   if(showTube) {   mainC.prepareSpine(0); mainC.showTube(10,4,10,orange); }
   

 
  // -------------------------------------------------------- graphic picking on surface and view control ----------------------------------   
  if (keyPressed&&key==' ') T.set(Pick()); // sets point T on the surface where the mouse points. The camera will turn toward's it when the ';' key is released
  SetFrame(Q,I,J,K);  // showFrame(Q,I,J,K,30);  // sets frame from picked points and screen axes
  // rotate view 
  if(!keyPressed&&mousePressed) {E=R(E,  PI*float(mouseX-pmouseX)/width,I,K,F); E=R(E,-PI*float(mouseY-pmouseY)/width,J,K,F); } // rotate E around F 
  if(keyPressed&&key=='D'&&mousePressed) {E=P(E,-float(mouseY-pmouseY),K); }  //   Moves E forward/backward
  if(keyPressed&&key=='d'&&mousePressed) {E=P(E,-float(mouseY-pmouseY),K);U=R(U, -PI*float(mouseX-pmouseX)/width,I,J); }//   Moves E forward/backward and rotatees around (F,Y)
  
 
  // generator animate
     
  emit_timer = 1.0/G.emit_rate;
  G.displayGP();
  t+=STANDARD_TIMER; f+=STANDARD_TIMER;
  G.updateParticles(TT);
  if (f>= emit_timer) { f = 0; G.renderNewParticle(); }
  
  
   
  // -------------------------------------------------------- Disable z-buffer to display occluded silhouettes and other things ---------------------------------- 
  hint(DISABLE_DEPTH_TEST);  // show on top
  stroke(black); if(showControl) {C0.showSamples(2);}
  camera(); // 2D view to write help text
  hint(ENABLE_DEPTH_TEST); // show silouettes

  // -------------------------------------------------------- SNAP PICTURE ---------------------------------- 
   if(snapping) snapPicture(); // does not work for a large screen
    pressed=false;
    

  
 } // end draw
 
 
 // ****************************************************************************************************************************** INTERRUPTS
Boolean pressed=false;

void mousePressed() {pressed=true;
    
}
  
void mouseDragged() {
  if(keyPressed&&key=='z') {C0.dragPoint( V(.5*(mouseX-pmouseX),I,.5*(mouseY-pmouseY),K) ); redrawMainCurve();} // move selected vertex of curve C in screen plane
  if(keyPressed&&key=='x') {C0.dragPoint( V(.5*(mouseX-pmouseX),I,-.5*(mouseY-pmouseY),J) ); redrawMainCurve();} // move selected vertex of curve C in screen plane
  if(keyPressed&&key=='b') {C0.dragAll( V(.5*(mouseX-pmouseX),I,.5*(mouseY-pmouseY),K) ); redrawMainCurve();} // move selected vertex of curve C in screen plane
  if(keyPressed&&key=='v') {C0.dragAll( V(.5*(mouseX-pmouseX),I,-.5*(mouseY-pmouseY),J) ); redrawMainCurve() ;} // move selected vertex of curve Cb in XZ

  if(keyPressed&&key=='m') {G.dragCenter( V(.5*(mouseX-pmouseX),I,.5*(mouseY-pmouseY),K) );  } // move Generator in screen plane
  if(keyPressed&&key=='n') {G.dragCenter( V(.5*(mouseX-pmouseX),I,-.5*(mouseY-pmouseY),J) );} // move Generator  in screen plane 
  
  // geneator related
  if(keyPressed && key=='g') {G.resize(G.radius+float(mouseX-pmouseX));} // adjust generator size
  if(keyPressed && key=='G') {G.emit_rate += float(int(mouseX-pmouseX))/10;if (G.emit_rate<=0) G.emit_rate=0.01; if (G.emit_rate>=50) G.emit_rate=50; }
  
  if(keyPressed && key=='s') {dynamicBlendParameter+=float(mouseX-pmouseX)/1000 ;if(dynamicBlendParameter>=1) dynamicBlendParameter=1; if(dynamicBlendParameter<=0) dynamicBlendParameter=0;}//ajust blend parameter
  
}

void mouseReleased() {
     U.set(M(J)); // reset camera up vector
    }
  
void keyReleased() {
   if(key==' ') F=P(T);                           //   if(key=='c') M0.moveTo(C.Pof(10));
   U.set(M(J)); // reset camera up vector
   } 

 
void keyPressed() {
  if(key=='f') {addDynamic=!addDynamic;} 
  if(key=='b') {}  // move S2 in XZ
  if(key=='c') {} // load curve
  if(key=='d') {} 
  if(key=='e') {}
  if(key=='h') {} // hide picked vertex (mousePressed)
  if(key=='i') {}
  if(key=='j') {}

  if(key=='l') {}

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
   

  if(key=='B') {}

  if(key=='D') {} //move in depth without rotation (draw)

  if(key=='F') {}
  if(key=='G') {}
  if(key=='H') {}
  if(key=='I') {}
  if(key=='J') {}
  if(key=='K') {}
  if(key=='L') {C0.loadPts();G.loadInfo();redrawMainCurve();}
  if(key=='M') {}
 // if(key=='N') {M.next();}
  if(key=='O') {}
  if(key=='P') {}
  if(key=='Q') {exit();}
  if(key=='R') {}
  if(key=='S') {C0.savePts();G.saveInfo();}
  if(key=='T') {}
  if(key=='U') {}
  if(key=='V') {} 
 
  if(key=='X') {} // drag mesh vertex in xy and neighbors (mouseDragged)

  if(key=='Z') {} // drag mesh vertex in xz and neighbors (mouseDragged)

  //if(key=='`') {M.perturb();}
  if(key=='~') {showSpine=!showSpine;}
  if(key=='!') {snapping=true;}
  if(key=='@') {}
  if(key=='#') {}

  if(key=='%') {}
  if(key=='&') {}
  if(key=='*') {sampleDistance*=2;}
  if(key=='(') {}
  if(key==')') {showSilhouette=!showSilhouette;}

  if(key=='{') {showFrenetQuads=!showFrenetQuads;}
  if(key=='}') {}
  if(key=='|') {}

  if(key==':') {translucent=!translucent;}
  if(key==';') {showControl=!showControl;}
  if(key=='<') {}
  if(key=='>') {if (shrunk==0) shrunk=1; else shrunk=0;}
  if(key=='?') {showHelpText=!showHelpText;}
  if(key=='.') {} // pick corner
  if(key==',') {}
  if(key=='^') {} 
  if(key=='/') {} 



  
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

void redrawMainCurve(){
  mainC.empty();
  for(int i=0;i<C0.n;i++)
    mainC.append(C0.P[i]);
  mainC.subdivide();
  mainC.subdivide();
  mainC.subdivide();
  mainC.subdivide();
  mainC.resample(150);
  G.resize(G.radius);
}

