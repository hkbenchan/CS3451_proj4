//*********************************************************************
//      project 4B, 3D velocity field curve, particle simulation and collision
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
  addDynamic=true,
  addGravity=false,
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
obstacle O = new obstacle();
float dynamicBlendParameter=.5;
float gravitationalParameter=10000;
float TT;

// String SCC = "-"; // info on current corner
   
// ****************************** VIEW PARAMETERS *******************************************************
pt F = P(0,0,0); pt T = P(0,0,0); pt E = P(0,0,1000); vec U=V(0,1,0);  // focus  set with mouse when pressing ';', eye, and up vector
pt Q=P(0,0,0); vec I=V(1,0,0); vec J=V(0,1,0); vec K=V(0,0,1); // picked surface point Q and screen aligned vectors {I,J,K} set when picked
void initView() {Q=P(0,0,0); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1); F = P(0,0,0); E = P(0,0,1000); U=V(0,1,0); } // declares the local frames

// ******************************** MESHES ***********************************************
//Mesh M=new Mesh(); // meshes for models M0 and M1

float volume1=0, volume0=0;
float sampleDistance=1;
// ******************************** CURVES & SPINES ***********************************************
Curve C0 = new Curve(500); //S0 = new Curve(), C1 = new Curve(5), S1 = new Curve();  
Curve mainC = new Curve(500);// control points and spines 0 and 1
//Curve C= new Curve(11,130,P());
//int nsteps=250; // number of smaples along spine
//float sd=10; // sample distance for spine
pt sE = P(), sF = P(); vec sU=V(); //  view parameters (saved with 'j'

// *******************************************************************************************************************    SETUP
void setup() {
  size(1200, 700, OPENGL);
  //frameRate(5);
  setColors(); sphereDetail(6); 
  PFont font = loadFont("GillSans-24.vlw"); textFont(font, 20);  // font for writing labels on //  PFont font = loadFont("Courier-14.vlw"); textFont(font, 12); 
  // ***************** OpenGL and View setup
  glu= ((PGraphicsOpenGL) g).glu;  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  gl = pgl.beginGL();  pgl.endGL();
  initView(); // declares the local frames for 3D GUI

  // ***************** Load meshes
//  M.declareVectors().loadMeshVTS("data/horse.vts");
//  M.resetMarkers().computeBox().updateON(); // makes a cube around C[8]
  // ***************** Load Curve
  C0.loadPts();
 //  C0.empty().append(C.Pof(0)).append(C.Pof(1)).append(C.Pof(2)).append(C.Pof(3)).append(C.Pof(4));
  redrawMainCurve();
  // ***************** Set view
  
  // ***************** Generator Init
  G.init();
  G.loadInfo();
  
 // G.setCenter(P(width/2, height/2, 0));
  randomSeed(10);
 
  O.init().loadInfo();
  
  F=P(); E=P(0,0,500);
  for(int i=0; i<10; i++) vis[i]=true; // to show all types of triangles
  }

// ******************************************************************************************************************* DRAW      
void draw() {  
  TT=1./30;
  background(white);
  //fill(black); 
  
  //noFill();
  // -------------------------------------------------------- Help ----------------------------------
  if(showHelpText) {
    camera(); // 2D display to show cutout
    lights();
    fill(black); writeHelp();
    return;
    } 
    
  fill(black);
  camera();
  specular(0,0,0); shininess(0);
  if (addDynamic)
     text("Add Dynamic: Yes ; Blend Parameter: "+dynamicBlendParameter,10,20);
  else
     text("Add Dynamic: No",10,20);
  text("Emission rate: "+(int)G.emit_rate,10,40);
  text("Press ?: HELP ",10,60);
  if (addGravity)
     text("Add Gravity: Yes; Gravitational constant: "+gravitationalParameter,10,80);
  else
     text("Add Gravity: No",10, 80);
  text("No. of particles: "+G.active_p,width-200,20);
  text("FPS: "+frameRate, width-200,40);
  
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
       //println(Pick().x+" "+Pick().y+" "+Pick().z);
       if(key=='c') { C0.delete();  G.resetQueue();redrawMainCurve();} //delete selected pt
       if(key=='a') { C0.append(Pick());   G.resetQueue();redrawMainCurve();}// C0.append(Pick());} //append pt at the end
       if(key=='i') { C0.insert();  G.resetQueue();redrawMainCurve();} // insert control pt
       if(key==',') { G.setCenter(Pick());} // insert control pt
      
      
       }
     }
     

  // -------------------------------------------------------- create control curves  ----------------------------------   
    stroke(black); noFill(); C0.showSamples(4);
    
    stroke(blue);  mainC.showSamples(3);mainC.drawEdges(); 

   // -------------------------------------------------------- create and show spines  ----------------------------------   
//   S0=S0.makeFrom(C0,500).resampleDistance(sampleDistance);
//   stroke(blue); noFill(); if(showSpine) S0.drawEdges(); 
   
   // -------------------------------------------------------- compute spine normals  ----------------------------------   
   // -------------------------------------------------------- show tube ----------------------------------   
   if(showTube) { mainC.prepareSpine(0); mainC.showTube(10,4,10,orange); }
   
   // -------------------------------------------------------- create and move mesh ----------------------------------   
 //  pt Q0=C.Pof(10); //fill(white); show(Q0,4);
  // M.moveTo(Q0);
  
     // -------------------------------------------------------- show mesh ----------------------------------   
 //  if(showMesh) { fill(yellow); if(M.showEdges) stroke(white);  else noStroke(); M.showFront();} 
   
    // -------------------------- pick mesh corner ----------------------------------   
 //  if(pressed) if (keyPressed&&(key=='.')) M.pickc(Pick());
 
 
     // -------------------------------------------------------- show mesh corner ----------------------------------   
  // if(showMesh) { fill(red); noStroke(); M.showc();} 
 
    // -------------------------------------------------------- edit mesh  ----------------------------------   
 // if(pressed) {
 //    if (keyPressed&&(key=='x'||key=='z')) M.pickc(Pick()); // sets M.sc to the closest corner in M from the pick point
 //    if (keyPressed&&(key=='X'||key=='Z')) M.pickc(Pick()); // sets M.sc to the closest corner in M from the pick point
 //    }
 
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
  O.display();
  t+=STANDARD_TIMER; f+=STANDARD_TIMER;
  G.updateVelocity();
  //*********************************************Collision TEST ************************************************//
  collisionTracker cT = runCollisionTest();
  
  // collision happens here
  while (cT.next_ct <= TT) {
     //println(cT2.next_ct+" "+cT2.A);
   //  G.updateParticles(cT.next_ct);
     //G.removeParticle(cT.A);
     
     if (cT.obstacle_involved){
      
       // check if the particle is leaving the obstacle, false if vec from center of particle to center of obstacle is 'married' with veclocity of particle
      if (d(V(G.p[cT.A].pos,O.pos), G.p[cT.A].velocity) >0) {
         G.updateParticles(cT.next_ct);
        // println(G.p[cT.A].velocity.x+" "+G.p[cT.A].velocity.y+" "+G.p[cT.A].velocity.z);
         vec N=U(G.p[cT.A].pos,O.pos);
         vec U1=V(d(G.p[cT.A].velocity,N),N);
         G.p[cT.A].setVelocity(A(G.p[cT.A].velocity,-2,U1));
        // G.p[cT.A].setVelocity(V(4,G.p[cT.A].velocity));
         println("in");
       }
      else {
        if(cT.next_ct<0.00001){
           G.updateParticles(0.00001);
         }else
           G.updateParticles(cT.next_ct);
       // vec N=U(G.p[cT.A].pos,O.pos);
    //   println("out"+cT.next_ct+"  "+angle(G.p[cT.A].velocity,N)); 
     
      }
     }else{ 
      
       
              if(cT.next_ct<0.00001){
                G.updateParticles(0.00001);
             }else
                G.updateParticles(cT.next_ct);
           
             println("particle collision");
             vec N=U(G.p[cT.A].pos,G.p[cT.B].pos);
             vec U1=V(d(G.p[cT.A].velocity,N),N);
             vec U2=V(d(G.p[cT.B].velocity,N),N);
             G.p[cT.A].setVelocity(A(A(G.p[cT.A].velocity,-1,U1),1,U2));
             G.p[cT.B].setVelocity(A(A(G.p[cT.B].velocity,-1,U2),1,U1));
       
            
      
       
       
     //  G.removeParticle(cT.A).removeParticle(cT.B);
     } 
     
     TT -= cT.next_ct;
     cT = runCollisionTest(); 
  }
  
  /*if (cT2.next_ct <= TT) 
    println("collision Time: "+cT2.next_ct+" id: "+cT2.A);
  */
  
  // end of collision test
  
  G.updateParticles(TT);
  if (f>= emit_timer) { f = 0; G.renderNewParticle(); }
  
  
   
  // -------------------------------------------------------- Disable z-buffer to display occluded silhouettes and other things ---------------------------------- 
  hint(DISABLE_DEPTH_TEST);  // show on top
  stroke(black); if(showControl) {C0.showSamples(2);}
//  if(showMesh&&showSilhouette) {stroke(dbrown); M.drawSilhouettes(); }  // display silhouettes
//  strokeWeight(2); stroke(red);if(showMesh&&showNMBE) M.showMBEs();  // manifold borders
  //camera(); // 2D view to write help text
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
  if(keyPressed&&key=='b') {C0.dragAll(0,5, V(.5*(mouseX-pmouseX),I,.5*(mouseY-pmouseY),K) ); redrawMainCurve();} // move selected vertex of curve C in screen plane
  if(keyPressed&&key=='v') {C0.dragAll(0,5, V(.5*(mouseX-pmouseX),I,-.5*(mouseY-pmouseY),J) );redrawMainCurve() ;} // move selected vertex of curve Cb in XZ
 // if(keyPressed&&key=='x') {M.add(float(mouseX-pmouseX),I).add(-float(mouseY-pmouseY),J); M.normals();} // move selected vertex in screen plane
//  if(keyPressed&&key=='z') {M.add(float(mouseX-pmouseX),I).add(float(mouseY-pmouseY),K); M.normals();}  // move selected vertex in X/Z screen plane
//  if(keyPressed&&key=='X') {M.addROI(float(mouseX-pmouseX),I).addROI(-float(mouseY-pmouseY),J); M.normals();} // move selected vertex in screen plane
//  if(keyPressed&&key=='Z') {M.addROI(float(mouseX-pmouseX),I).addROI(float(mouseY-pmouseY),K); M.normals();}  // move selected vertex in X/Z screen plane 
    if(keyPressed&&key=='m') {G.dragCenter( V(.5*(mouseX-pmouseX),I,.5*(mouseY-pmouseY),K) );  } // move Generator in screen plane
    if(keyPressed&&key=='n') {G.dragCenter( V(.5*(mouseX-pmouseX),I,-.5*(mouseY-pmouseY),J) );} // move Generator  in screen plane 
  
  // geneator related
  if(keyPressed && key=='g') {G.resize(G.radius+float(mouseX-pmouseX)); if (G.radius <= 1) {G.resize(1);} } // adjust generator size
  if(keyPressed && key=='G') {G.emit_rate += float(int(mouseX-pmouseX))/10; if (G.emit_rate<=0) { G.emit_rate = 0; } if (G.emit_rate>=20) {G.emit_rate = 20; } }
  
  // obstacle related
  if (keyPressed && key=='e') {O.resize(O.radius+float(mouseX-pmouseX)); if (O.radius <=1) { O.resize(1); } } // adjust the obstacle size
    if(keyPressed&&key=='o') {O.dragCenter( V(.5*(mouseX-pmouseX),I,.5*(mouseY-pmouseY),K) );  } // move obstacle in screen plane
  if(keyPressed&&key=='O') {O.dragCenter( V(.5*(mouseX-pmouseX),I,-.5*(mouseY-pmouseY),J) );} // move obstacle in screen plane 
  
  if(keyPressed && key=='s') {dynamicBlendParameter+=float(mouseX-pmouseX)/1000 ;if(dynamicBlendParameter>=1) dynamicBlendParameter=1; if(dynamicBlendParameter<=0) dynamicBlendParameter=0;}//ajust blend parameter
  if(keyPressed && key=='U') {
    gravitationalParameter+=float(mouseX-pmouseX);
    if(gravitationalParameter>=50000) gravitationalParameter=50000;
    if(gravitationalParameter<=0) gravitationalParameter=0;
  }//ajust gravitational parameter
  
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
 // if(key=='f') {filterFrenetNormal=!filterFrenetNormal; if(filterFrenetNormal) println("Filtering"); else println("not filtering");}
 // if(key=='g') {} // change global twist w (mouseDrag)
  if(key=='h') {} // hide picked vertex (mousePressed)
  if(key=='i') {}
  if(key=='j') {}
  if(key=='k') {G.renderNewParticle();}
  if(key=='l') {}
 // if(key=='m') {showMesh=!showMesh;}
 // if(key=='n') {showNMBE=!showNMBE;}
  if(key=='o') {}
  if(key=='p') {}
  if(key=='q') {}
  if(key=='r') {}
  if(key=='s') {} // drag curve control point in xz (mouseDragged)
  if(key=='t') {showTube=!showTube;}
  if(key=='u') { addGravity = !addGravity; }
  if(key=='v') {} // move S2
  if(key=='w') {}
  if(key=='x') {} // drag mesh vertex in xy (mouseDragged)
  if(key=='y') {}
  if(key=='z') {} // drag mesh vertex in xz (mouseDragged)
   
//  if(key=='A') {C.savePts();}
  if(key=='B') {}
//  if(key=='C') {C.loadPts();} // save curve
  if(key=='D') {} //move in depth without rotation (draw)
  //if(key=='E') {M.smoothen(); M.normals();}
  if(key=='F') {}
  if(key=='G') {}
  if(key=='H') {}
  if(key=='I') {}
  if(key=='J') {}
  if(key=='K') {}
  if(key=='L') {C0.loadPts();G.loadInfo(); O.loadInfo();redrawMainCurve();}
  if(key=='M') {}
 // if(key=='N') {M.next();}
  if(key=='O') {}
  if(key=='P') {}
  if(key=='Q') {exit();}
  if(key=='R') {}
  if(key=='S') {C0.savePts();G.saveInfo(); O.saveInfo();}
  if(key=='T') {}
  if(key=='U') {}
  if(key=='V') {} 
 // if(key=='W') {M.saveMeshVTS();}
  if(key=='X') {} // drag mesh vertex in xy and neighbors (mouseDragged)
//  if(key=='Y') {M.refine(); M.makeAllVisible();}
  if(key=='Z') {} // drag mesh vertex in xz and neighbors (mouseDragged)

  //if(key=='`') {M.perturb();}
  if(key=='~') {showSpine=!showSpine;}
  if(key=='!') {snapping=true;}
  if(key=='@') { G.emit_rate = 0.1 ;}
  if(key=='#') { G.emit_rate = 0 ;}
//  if(key=='$') {M.moveTo(C.Pof(10));} // ???????
  if(key=='%') {}
  if(key=='&') {}
  if(key=='*') {sampleDistance*=2;}
  if(key=='(') {}
  if(key==')') {showSilhouette=!showSilhouette;}
  //if(key=='_') {M.flatShading=!M.flatShading;}
//  if(key=='+') {M.flip();} // flip edge of M
//  if(key=='-') {M.showEdges=!M.showEdges;}
 // if(key=='=') {C.P[5].set(C.P[0]); C.P[6].set(C.P[1]); C.P[7].set(C.P[2]); C.P[8].set(C.P[3]); C.P[9].set(C.P[4]);}
  if(key=='{') {showFrenetQuads=!showFrenetQuads;}
  if(key=='}') {}
  if(key=='|') {}
//  if(key=='[') {initView(); F.set(M.Cbox); E.set(P(F,M.rbox*2,K));}
 // if(key==']') {F.set(M.Cbox);}
  if(key==':') {translucent=!translucent;}
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

void redrawMainCurve(){
  mainC.empty();
  for(int i=0;i<C0.n;i++)
    mainC.append(C0.P[i]);
  mainC.subdivide();
  mainC.subdivide();
  mainC.subdivide();
  mainC.subdivide();
  mainC.resample(150);
}

