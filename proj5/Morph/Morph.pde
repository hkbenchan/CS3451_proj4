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
animate=true,
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
showHelpText=false,
showAnimateQuad = false,
showTwoEnd=false;

int[] numRotation= new int[4];
int lastShapeKey= 1;
float localTime = 0.0;
// String SCC = "-"; // info on current corner

//d_sphere DS = new d_sphere();

// ****************************** VIEW PARAMETERS *******************************************************
pt F = P(0, 0, 0); 
pt T = P(0, 0, 0); 
pt E = P(0, 0, 1000); 
vec U=V(0, 1, 0);  // focus  set with mouse when pressing ';', eye, and up vector
pt Q=P(0, 0, 0); 
vec I=V(1, 0, 0); 
vec J=V(0, 1, 0); 
vec K=V(0, 0, 1); // picked surface point Q and screen aligned vectors {I,J,K} set when picked

vec Dir = V(0, 1, 0); // rotation axis

void initView() {
  Q=P(0, 0, 0); 
  I=V(1, 0, 0); 
  J=V(0, 1, 0); 
  K=V(0, 0, 1); 
  F = P(0, 0, 0); 
  E = P(0, 0, 1000); 
  U=V(0, 1, 0);
} // declares the local frames

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

Curve QuadSet = new Curve();

//Curve C0 = new Curve(5), S0 = new Curve(), C1 = new Curve(5), S1 = new Curve();  // control points and spines 0 and 1
//Curve C= new Curve(11,130,P());
//int nsteps=250; // number of smaples along spine
//float sd=10; // sample distance for spine
pt sE = P(), sF = P(); 
vec sU=V(); //  view parameters (saved with 'j'

// *******************************************************************************************************************    SETUP
void setup() {
  size(1000, 700, OPENGL);  
  setColors(); 
  sphereDetail(6); 
  PFont font = loadFont("GillSans-24.vlw"); 
  textFont(font, 20);  // font for writing labels on //  PFont font = loadFont("Courier-14.vlw"); textFont(font, 12); 
  // ***************** OpenGL and View setup
  glu= ((PGraphicsOpenGL) g).glu;  
  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  
  gl = pgl.beginGL();  
  pgl.endGL();
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

  numRotation[0] = 10;
  numRotation[1] = 10;
  numRotation[2] = 10;
  numRotation[3] = 10;

  // ***************** Set view

  for (int i=0;i<numRotation[0];i++) {
    CC0[i]=new Curve();
  }
  for (int i=0;i<numRotation[1];i++) {
    CC1[i]=new Curve();
  }
  for (int i=0;i<numRotation[2];i++) {
    CC2[i]=new Curve();
  }
  for (int i=0;i<numRotation[3];i++) {
    CC3[i]=new Curve();
  }
  F=P(); 
  E=P(0, 0, 500);
  loadInfos();
  //  for(int i=0; i<10; i++) vis[i]=true; // to show all types of triangles
  //  DS.init();
}

// ******************************************************************************************************************* DRAW      
void draw() {  

  background(white);
   // -------------------------------------------------------- Help ----------------------------------
   if(showHelpText) {
   camera(); // 2D display to show cutout
   lights();
   fill(black); writeHelp();
   return;
   }

  if (keyPressed){
    if (key=='1'||key=='2'||key=='3'||key=='4')
      lastShapeKey=(int)(key)-48;
    if(key=='C')
      removeNonConvex();
      
  }
  if (pressed) {

    if (keyPressed&&(key=='d'||key=='i')) {

      if (lastShapeKey== 1) {
        C0.pick(P(mouseX, mouseY, 0));
        if (key=='d') { 
          C0.delete();
        }
        if (key=='i') { 
          C0.insert();
        }
      }
      if (lastShapeKey== 2) {
        C1.pick(P(mouseX, mouseY, 0));
        if (key=='d') { 
          C1.delete();
        }
        if (key=='i') { 
          C1.insert();
        }
      }
      if (lastShapeKey== 3) {
        C2.pick(P(mouseX, mouseY, 0));
        if (key=='d') { 
          C2.delete();
        }
        if (key=='i') { 
          C2.insert();
        }
      }
      if (lastShapeKey== 4) {
        C3.pick(P(mouseX, mouseY, 0));
        if (key=='d') { 
          C3.delete();
        }
        if (key=='i') { 
          C3.insert();
        }
      }
    }
  }

  fill(black);
  camera();
  specular(0, 0, 0); 
  shininess(0);
  text("Number of sample (',': inc; '.': dec) : "+numRotation[lastShapeKey-1], 10, 20);
  text("Current selected shape: Shape "+lastShapeKey, 10, 50);
  text("Press ?: HELP ", 10, 80);

  noFill();
  stroke(green);
  if (lastShapeKey==1) C0.drawEdges() ;
  stroke(black);
  if (lastShapeKey==1) C0.showSamples(2);
  stroke(red);
  if (lastShapeKey==2) C1.drawEdges() ;
  stroke(black);
  if (lastShapeKey==2) C1.showSamples(2);
  stroke(cyan);
  if (lastShapeKey==3) C2.drawEdges() ;
  stroke(black);
  if (lastShapeKey==3)  C2.showSamples(2);
  stroke(magenta);
  if (lastShapeKey==4) C3.drawEdges() ;
  stroke(black);
  if (lastShapeKey==4)  C3.showSamples(2);


  // -------------------------------------------------------- 3D display : set up view ----------------------------------
  camera(E.x, E.y, E.z, F.x, F.y, F.z, U.x, U.y, U.z); // defines the view : eye, ctr, up
  vec Li=U(A(V(E, F), 0.1*d(E, F), J));   // vec Li=U(A(V(E,F),-d(E,F),J)); 
  directionalLight(255, 255, 255, Li.x, Li.y, Li.z); // direction of light: behind and above the viewer
  specular(255, 255, 0); 
  shininess(5);

  //***************** display the directional sphere*****************************//
  vec EF = V(E, F);
  vec tmp = R(U, PI/2, I, J);
  vec REF = R(U(EF), -PI/2, U(EF), N(U, U(EF)));
  //  DS.setCenter(P(E, A(V(250, U(EF)), A(V(150, REF), V(-100, U))))).displayG();

  //  println("EF: "+EF.x+" "+EF.y+" "+EF.z);
  //  println("REF: "+REF.x+" "+REF.y+" "+REF.z);

  //***************** END of display the directional sphere*****************************//  

  noFill();
  BuildShape();
 
  lights();
  if (showMesh) {
    makeMesh();
    if ((C0.n>0) && ((showTwoEnd) || (lastShapeKey==1))) {
      stroke(blue);  
      fill(green);
      pushMatrix();
      if (showTwoEnd) {
        translate(-width/4, 0, 0);
      }
      //rotateX(acos(d(I,Dir)));
      //rotateY(acos(d(J,Dir))); 
      //rotateZ(acos(d(K,Dir)));
      S0.showFront();
      S0.showTriNormal_VertexNormals();
      if (keyPressed && key=='U') S0.showLabels();
      popMatrix();
    }
    if ((C1.n>0) && ((showTwoEnd) || (lastShapeKey==2))) {
      stroke(blue);  
      fill(red);
      pushMatrix();
      if (showTwoEnd) {
        translate(width/4, 0, 0);
      }
      //rotateX(acos(d(I,Dir)));
      //rotateY(acos(d(J,Dir))); 
      //rotateZ(acos(d(K,Dir)));
      S1.showFront();
      S1.showTriNormal_VertexNormals();
      if (keyPressed && key=='U') S1.showLabels();
      popMatrix();
    }
    if ((C2.n>0) && (lastShapeKey == 3)) {
      stroke(blue);   
      fill(cyan);
      pushMatrix();
//      rotateX(acos(d(I, Dir)));
//      rotateY(acos(d(J, Dir))); 
//      rotateZ(acos(d(K, Dir)));
      S2.showFront();
      S2.showTriNormal_VertexNormals();
      if (keyPressed && key=='U') S2.showLabels();
      popMatrix();
    }
    if ((C3.n>0)  && (lastShapeKey == 4)) {
      stroke(blue);  
      fill(magenta );
      pushMatrix();
//      rotateX(acos(d(I, Dir)));
//      rotateY(acos(d(J, Dir))); 
//      rotateZ(acos(d(K, Dir)));
      S3.showFront();
       S3.showTriNormal_VertexNormals();
      if (keyPressed && key=='U') S3.showLabels();
      popMatrix();
    }
    
    if (showAnimateQuad)
    {
      S0.computeBNormalForAll();
      S1.computeBNormalForAll();
      QuadSet.makeQuad(S0, S1, localTime).BuildShapeForQuad();
    }
    
  }else {
     buildSurface();  
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
  SetFrame(Q, I, J, K);  // showFrame(Q,I,J,K,30);  // sets frame from picked points and screen axes
  // rotate view 
  if (keyPressed&&key=='o'&&mousePressed) {
    float mX = (mouseX-pmouseX);
    float mY = (mouseY-pmouseY);
    E=R(E, PI*mX/(width/2), I, K, F); 
    E=R(E, -PI*mY/(height/2), J, K, F);
    Dir = V(P(), R(P(P(), Dir), PI*mX/(width/2), I, K, F));
    Dir = V(P(), R(P(P(), Dir), -PI*mY/(height/2), J, K, F));
  } // rotate E around F 
  //if(keyPressed&&key=='D'&&mousePressed) {E=P(E,-float(mouseY-pmouseY),K); }  //   Moves E forward/backward
  //if(keyPressed&&key=='d'&&mousePressed) {E=P(E,-float(mouseY-pmouseY),K);U=R(U, -PI*float(mouseX-pmouseX)/width,I,J); }//   Moves E forward/backward and rotatees around (F,Y)

  // -------------------------------------------------------- Disable z-buffer to display occluded silhouettes and other things ---------------------------------- 
  //hint(DISABLE_DEPTH_TEST);  // show on top
  //  stroke(black); if(showControl) {C0.showSamples(2);}
  //  if(showMesh&&showSilhouette) {stroke(dbrown); M.drawSilhouettes(); }  // display silhouettes
  //  strokeWeight(2); stroke(red);if(showMesh&&showNMBE) M.showMBEs();  // manifold borders
  //camera(); // 2D view to write help text
  //  writeFooterHelp();
  //hint(ENABLE_DEPTH_TEST); // show silouettes

  // -------------------------------------------------------- SNAP PICTURE ---------------------------------- 
  if (snapping) snapPicture(); // does not work for a large screen
  pressed=false;
  if (animate)
    localTime += 0.01;
  if (localTime > 1) {
    localTime = 0.0; //reset time
  }
} // end draw


// ****************************************************************************************************************************** INTERRUPTS
Boolean pressed=false;

void mousePressed() {
  pressed=true;
  if (keyPressed) {
    if (key=='1' ) {  //done avoid nonconvex here when user is going to insert new point
      boolean validTurn=false;
      if (C0.n>=3) {
        float det1=(C0.P[C0.n-2].x-C0.P[C0.n-3].x)*(-(C0.P[C0.n-1].y-C0.P[C0.n-2].y))+(C0.P[C0.n-2].y-C0.P[C0.n-3].y)*(C0.P[C0.n-1].x-C0.P[C0.n-2].x);
        float det2=(C0.P[C0.n-1].x-C0.P[C0.n-2].x)*(-(mouseY-C0.P[C0.n-1].y))+(C0.P[C0.n-1].y-C0.P[C0.n-2].y)*(mouseX-C0.P[C0.n-1].x);
        if ((det1>0&&det2>0)||(det1<0&&det2<0)) validTurn=true;
      }
      else
        validTurn=true;
      if (C0.n<1) C0.addPt(new pt(mouseX, mouseY, 0)); 
      else if (d(new pt(mouseX, mouseY, 0), C0.P[C0.n-1])>10 && C0.n<500) C0.addPt(new pt(mouseX, mouseY, 0));

      lastShapeKey= 1;
    }

    if (key=='2' ) { 
      boolean validTurn=false;
      if (C1.n>=3) {
        float det1=(C1.P[C1.n-2].x-C1.P[C1.n-3].x)*(-(C1.P[C1.n-1].y-C1.P[C1.n-2].y))+(C1.P[C1.n-2].y-C1.P[C1.n-3].y)*(C1.P[C1.n-1].x-C1.P[C1.n-2].x);
        float det2=(C1.P[C1.n-1].x-C1.P[C1.n-2].x)*(-(mouseY-C1.P[C1.n-1].y))+(C1.P[C1.n-1].y-C1.P[C1.n-2].y)*(mouseX-C1.P[C1.n-1].x);
        if ((det1>0&&det2>0)||(det1<0&&det2<0)) validTurn=true;
      }
      else
        validTurn=true;
      if (C1.n<1) C1.addPt(new pt(mouseX, mouseY, 0)); 
      else if (d(new pt(mouseX, mouseY, 0), C1.P[C1.n-1])>10 && C1.n<500 ) C1.addPt(new pt(mouseX, mouseY, 0));
      lastShapeKey= 2;
    }
    if (key=='3' ) {
      boolean validTurn=false;
      if (C2.n>=3) {
        float det1=(C2.P[C2.n-2].x-C2.P[C2.n-3].x)*(-(C2.P[C2.n-1].y-C2.P[C2.n-2].y))+(C2.P[C2.n-2].y-C2.P[C2.n-3].y)*(C2.P[C2.n-1].x-C2.P[C2.n-2].x);
        float det2=(C2.P[C2.n-1].x-C2.P[C2.n-2].x)*(-(mouseY-C2.P[C2.n-1].y))+(C2.P[C2.n-1].y-C2.P[C2.n-2].y)*(mouseX-C2.P[C2.n-1].x);
        if ((det1>0&&det2>0)||(det1<0&&det2<0)) validTurn=true;
      }
      else
        validTurn=true;
      if (C2.n<1) C2.addPt(new pt(mouseX, mouseY, 0)); 
      else if (d(new pt(mouseX, mouseY, 0), C2.P[C2.n-1])>10 && C2.n<500) C2.addPt(new pt(mouseX, mouseY, 0));
      lastShapeKey= 3;
    }
    if (key=='4' ) {  
      boolean validTurn=false;
      if (C3.n>=3) {
        float det1=(C3.P[C3.n-2].x-C3.P[C3.n-3].x)*(-(C3.P[C3.n-1].y-C3.P[C3.n-2].y))+(C3.P[C3.n-2].y-C3.P[C3.n-3].y)*(C3.P[C3.n-1].x-C3.P[C3.n-2].x);
        float det2=(C3.P[C3.n-1].x-C3.P[C3.n-2].x)*(-(mouseY-C3.P[C3.n-1].y))+(C3.P[C3.n-1].y-C3.P[C3.n-2].y)*(mouseX-C3.P[C3.n-1].x);
        if ((det1>0&&det2>0)||(det1<0&&det2<0)) validTurn=true;
      }
      else
        validTurn=true;
      if (C3.n<1) C3.addPt(new pt(mouseX, mouseY, 0)); 
      else if (d(new pt(mouseX, mouseY, 0), C3.P[C3.n-1])>10 && C3.n<500) C3.addPt(new pt(mouseX, mouseY, 0));
      lastShapeKey= 4;
    }
  }
}


void mouseDragged() {
  if (lastShapeKey== 1&&keyPressed&&key=='s') {
    C0.pick(P(mouseX, mouseY, 0));
    C0.P[C0.p].x+=(mouseX-pmouseX);
    C0.P[C0.p].y+=(mouseY-pmouseY);
  } 
  if (lastShapeKey== 2&&keyPressed&&key=='s') {
    C1.pick(P(mouseX, mouseY, 0));
    C1.P[C1.p].x+=(mouseX-pmouseX);
    C1.P[C1.p].y+=(mouseY-pmouseY);
  } 
  if (lastShapeKey== 3&&keyPressed&&key=='s') {
    C2.pick(P(mouseX, mouseY, 0));
    C2.P[C2.p].x+=(mouseX-pmouseX);
    C2.P[C2.p].y+=(mouseY-pmouseY);
  } 
  if (lastShapeKey== 4&&keyPressed&&key=='s') {
    C3.pick(P(mouseX, mouseY, 0));
    C3.P[C3.p].x+=(mouseX-pmouseX);
    C3.P[C3.p].y+=(mouseY-pmouseY);
  }

  if (keyPressed&&key=='t') { localTime += float(mouseX-pmouseX)/width; if (localTime<0) {localTime = 0;} if (localTime>1) {localTime=1;} }

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
  if (key==' ') F=P(T);                           //   if(key=='c') M0.moveTo(C.Pof(10));
  U.set(M(J)); // reset camera up vector
} 


void keyPressed() {
  if (key=='a') {
    animate = !animate;
  } 
  if (key=='b') {
  }  // move S2 in XZ
  if (key=='c') {
  } // load curve
  if (key=='d') {
  } 
  if (key=='e') {
  }
  // if(key=='f') {filterFrenetNormal=!filterFrenetNormal; if(filterFrenetNormal) println("Filtering"); else println("not filtering");}
  if (key=='g') {
  } // change global twist w (mouseDrag)
  if (key=='h') {
  } // hide picked vertex (mousePressed)
  if (key=='i') {
  }
  if (key=='j') {
  }
  if (key=='k') {
  }
  if (key=='l') {
  }
  if(key=='m') {showMesh=!showMesh;}
  if (key=='n') {
    showNMBE=!showNMBE;
  }
  if (key=='o') {
  }
  if (key=='p') {
  }
  if (key=='q') {
  }
  if (key=='r') {
  }
  if (key=='s') {
  } // drag curve control point in xz (mouseDragged)
  if (key=='t') {
    //showTube=!showTube;
  }
  if (key=='u') {
    showTwoEnd=!showTwoEnd;
  }
  if (key=='v') {
  } // move S2
  if (key=='w') {
  }
  if (key=='x') {
  } // drag mesh vertex in xy (mouseDragged)
  if (key=='y') {
  }
  if (key=='z') {
  } // drag mesh vertex in xz (mouseDragged)

  //  if(key=='A') {C.savePts();}
  if (key=='B') {
  }
  //  if(key=='C') {C.loadPts();} // save curve
  if (key=='D') {
  } //move in depth without rotation (draw)
  // if(key=='E') {M.smoothen(); M.normals();}
  if (key=='F') {
  }
  if (key=='G') {
  }
  if (key=='H') {
  }
  if (key=='I') {
  }
  if (key=='J') {
  }
  if (key=='K') {
  }
  //  if(key=='L') {M.loadMeshVTS().updateON().resetMarkers().computeBox(); F.set(M.Cbox); E.set(P(F,M.rbox*2,K)); for(int i=0; i<10; i++) vis[i]=true;}
  if (key=='L') {loadInfos();}
  if (key=='M') {
  }
  //if(key=='N') {M.next();}
  if (key=='O') {
  }
  if (key=='P') {
  }
  if (key=='Q') {
    exit();
  }
  if (key=='R') {
  }
  // if(key=='S') {M.swing();}
  if (key=='T') {
  }
  if (key=='U') {
  }
  if (key=='V') {
  } 
  if(key=='W') { saveInfos(); }
  if (key=='X') {
  } // drag mesh vertex in xy and neighbors (mouseDragged)
  //  if(key=='Y') {M.refine(); M.makeAllVisible();}
  if (key=='Z') {
  } // drag mesh vertex in xz and neighbors (mouseDragged)

  // if(key=='`') {M.perturb();}
  // if(key=='~') {showSpine=!showSpine;}
  //  if(key=='!') {snapping=true;}
  if (key=='@') {
    showAnimateQuad =!showAnimateQuad;
  }
  if (key=='#') {
  }
  //  if(key=='$') {M.moveTo(C.Pof(10));} // ???????
  if (key=='%') {
    S0.computeBNormalForAll();
    S0.displayBn(0);
  }
  if (key=='&') {
  }
  //  if(key=='*') {sampleDistance*=2;}
  if (key=='(') {
  }
  //  if(key==')') {showSilhouette=!showSilhouette;}
  //  if(key=='_') {M.flatShading=!M.flatShading;}
  //  if(key=='+') {M.flip();} // flip edge of M
  //  if(key=='-') {M.showEdges=!M.showEdges;}
  //  if(key=='=') {C.P[5].set(C.P[0]); C.P[6].set(C.P[1]); C.P[7].set(C.P[2]); C.P[8].set(C.P[3]); C.P[9].set(C.P[4]);}
  //  if(key=='{') {showFrenetQuads=!showFrenetQuads;}
  if (key=='}') {
  }
  if (key=='|') {
  }
  //  if(key=='[') {initView(); F.set(M.Cbox); E.set(P(F,M.rbox*2,K));}
  // if(key==']') {F.set(M.Cbox);}
  //  if(key==':') {translucent=!translucent;}
  if (key==';') {
    showControl=!showControl;
  }
  if (key=='<') {
  }
  if (key=='>') {
    if (shrunk==0) shrunk=1; 
    else shrunk=0;
  }
  if (key=='?') {
    showHelpText=!showHelpText;
  }
  if (key=='.') {
    numRotation[lastShapeKey-1]--;
    if (numRotation[lastShapeKey-1]<=3) numRotation[lastShapeKey-1]=3;
    restoreNormalRotation();
  } 
  if (key==',') {
    numRotation[lastShapeKey-1]++;
    if (numRotation[lastShapeKey-1]>=50) numRotation[lastShapeKey-1]=50;
    restoreNormalRotation();
  }
  if (key=='^') {
  } 
  if (key=='/') {
  } 
  //if(key==' ') {} // pick focus point (will be centered) (draw & keyReleased)

  if (key=='0') {
    w=0;
  }
  //  for(int i=0; i<10; i++) if (key==char(i+48)) vis[i]=!vis[i];
} //------------------------------------------------------------------------ end keyPressed

float [] Volume = new float [3];
float [] Area = new float [3];
float dis = 0;

Boolean prev=false;

void showGrid(float s) {
  for (float x=0; x<width; x+=s*20) line(x, 0, x, height);
  for (float y=0; y<height; y+=s*20) line(0, y, width, y);
}

// Snapping PICTURES of the screen
PImage myFace; // picture of author's face, read from file pic.jpg in data folder
int pictureCounter=0;
Boolean snapping=false; // used to hide some text whil emaking a picture
void snapPicture() {
  saveFrame("PICTURES/P"+nf(pictureCounter++, 3)+".jpg"); 
  snapping=false;
}


void BuildShape() {
  pt O=P(0, 0, 0);
  vec I=V(1, 0, 0);
  vec J=V(0, 1, 0);
  vec K=V(0, 0, 1);
  vec originalAxis=V(0, 0, 0);
  float angle=0;

  //C0
  if (C0.n>1) {
    //println("construct CC0");
    originalAxis=V(0, C0.P[0].y-C0.P[C0.n-1].y, 0);
    //(originalAxis.x+"  "+originalAxis.y+"  "+originalAxis.z);
    angle=0;
    //println(C0.P[0].y+" "+C0.P[C0.n-1].y);
    pt StartPt = P(0, C0.P[0].y, 0);

    for (int i=0;i<numRotation[0];i++) {
      vec axis;
      axis=R(I, angle, I, K);
      CC0[i].n=C0.n+2;
      CC0[i].P[0]=P();
      for (int j=0;j<C0.n;j++) {
        pt newP=P();
        newP.set(O);
        float y= d(originalAxis, V(StartPt, C0.P[j]))/n(originalAxis);
        //println(d(C0.P[0],C0.P[j]));



        float x=sqrt(d(StartPt, C0.P[j])*d(StartPt, C0.P[j])-y*y);
        CC0[i].P[j+1]=newP.add(V(y, J, x, axis));
      }
      
      CC0[i].P[C0.n+1] = P(0, -abs(C0.P[C0.n-1].y-C0.P[0].y), 0);
      angle=(i+1)*2*PI/numRotation[0];
      //println("axis: "+axis.x+" "+axis.y+" "+axis.z);
      //      for (int j=0;j<CC0[i].n; j++) {
      //        println("Pt, i: "+i+" j: "+j+" "+CC0[i].P[j].x+" "+CC0[i].P[j].y+" "+CC0[i].P[j].z);
      //      }
    }
    //println("end of c CC0");
  }
  //C1
  if (C1.n>1) {
    originalAxis=V(0, C1.P[0].y-C1.P[C1.n-1].y, 0);
    pt StartPt = P(0, C1.P[0].y, 0);
    angle=0;
    for (int i=0;i<numRotation[1];i++) {
      vec axis;
      axis=R(I, angle, I, K);
      CC1[i].n=C1.n+2;
      CC1[i].P[0]=P();
      for (int j=0;j<C1.n;j++) {
        pt newP=P();
        newP.set(O);
        float y= d(originalAxis, V(StartPt, C1.P[j]))/n(originalAxis);
        float x=sqrt(d(StartPt, C1.P[j])*d(StartPt, C1.P[j])-y*y);
        CC1[i].P[j+1]=newP.add(V(y, J, x, axis));
      }
      CC1[i].P[C1.n+1] = P(0, -abs(C1.P[C1.n-1].y-C1.P[0].y), 0);
      angle=(i+1)*2*PI/numRotation[1];
    }
  }
  //C2
  if (C2.n>1) {
    originalAxis=V(0, C2.P[0].y-C2.P[C2.n-1].y, 0);
    pt StartPt = P(0, C2.P[0].y, 0);
    angle=0;
    for (int i=0;i<numRotation[2];i++) {
      vec axis;
      axis=R(I, angle, I, K);
      CC2[i].n=C2.n+2;
      CC2[i].P[0]=P();
      for (int j=0;j<C2.n;j++) {
        pt newP=P();
        newP.set(O);
        float y= d(originalAxis, V(StartPt, C2.P[j]))/n(originalAxis);
        float x=sqrt(d(StartPt, C2.P[j])*d(StartPt, C2.P[j])-y*y);
        CC2[i].P[j+1]=newP.add(V(y, J, x, axis));
      }
      CC2[i].P[C2.n+1] = P(0, -abs(C2.P[C2.n-1].y-C2.P[0].y), 0);
      angle=(i+1)*2*PI/numRotation[2];
    }
  }
  //C3
  if (C3.n>1) {
    originalAxis=V(0, C3.P[0].y-C3.P[C3.n-1].y, 0);
    pt StartPt = P(0, C3.P[0].y, 0);
    angle=0;
    for (int i=0;i<numRotation[3];i++) {
      vec axis;
      axis=R(I, angle, I, K);
      CC3[i].n=C3.n+2;
      CC3[i].P[0]=P();
      for (int j=0;j<C3.n;j++) {
        pt newP=P();
        newP.set(O);
        float y= d(originalAxis, V(StartPt, C3.P[j]))/n(originalAxis);
        float x=sqrt(d(StartPt, C3.P[j])*d(StartPt, C3.P[j])-y*y);
        CC3[i].P[j+1]=newP.add(V(y, J, x, axis));
      }
      CC3[i].P[C3.n+1] = P(0, -abs(C3.P[C3.n-1].y-C3.P[0].y), 0);
      angle=(i+1)*2*PI/numRotation[3];
    }
  }
}

void makeMesh() {

  //C0
  if (C0.n>1) {
    S0.empty();
    S0.addVertex(CC0[0].P[0]);
    S0.addVertex(CC0[0].P[CC0[0].n-1]);

    for (int i=0;i<numRotation[0];i++)
    {
      int j=i+1;
      if (j>numRotation[0]-1) j=0;

      for (int k=1;k<CC0[i].n;k++) {

        if (k==1) {
          S0.addVertex(CC0[j].P[k]); 
          S0.addVertex(CC0[i].P[k]);
          S0.addTriangle(0, S0.nv-2, S0.nv-1);
        }
        else if (k==CC0[i].n-1) {
          S0.addTriangle(1,S0.nv-1, S0.nv-2);
        }
        else
        {
          S0.addVertex(CC0[j].P[k]); 
          S0.addTriangle(S0.nv-3, S0.nv-1, S0.nv-2);
          S0.addVertex(CC0[i].P[k]);
          S0.addTriangle(S0.nv-3, S0.nv-2, S0.nv-1);
        }
      }
    }
    //S0.addTriangle(S0.nv-1,S0.nv-2,1);
    //for (int i=0; i<S0.nv; i++) {
    //  println("S0: i: "+i+" "+S0.G[i].x+" "+S0.G[i].y+" "+S0.G[i].z);
    //}
    //println(S0.nv);
  }


  //C1
  if (C1.n>2) {
    S1.empty();
    S1.addVertex(CC1[0].P[0]);
    S1.addVertex(CC1[0].P[CC1[0].n-1]);
    for (int i=0;i<numRotation[1];i++)
    {
      int j=i+1;
      if (j>numRotation[1]-1) j=0;

      for (int k=1;k<CC1[i].n;k++) {

        if (k==1) {
          S1.addVertex(CC1[j].P[k]); 
          S1.addVertex(CC1[i].P[k]);
          S1.addTriangle(0, S1.nv-2, S1.nv-1);
        }
        else if (k==CC1[i].n-1) {
          S1.addTriangle(1, S1.nv-1, S1.nv-2);
        }
        else
        {
          S1.addVertex(CC1[j].P[k]); 
          S1.addTriangle(S1.nv-3, S1.nv-1, S1.nv-2);
          S1.addVertex(CC1[i].P[k]); 
          S1.addTriangle(S1.nv-3, S1.nv-2, S1.nv-1);
        }
      }
    }
  }

  //C2
  if (C2.n>2) {
    S2.empty();
    S2.addVertex(CC2[0].P[0]);
    S2.addVertex(CC2[0].P[CC2[0].n-1]);
    for (int i=0;i<numRotation[2];i++)
    {
      int j=i+1;
      if (j>numRotation[2]-1) j=0;

      for (int k=1;k<CC2[i].n;k++) {

        if (k==1) {
          S2.addVertex(CC2[j].P[k]); 
          S2.addVertex(CC2[i].P[k]);
          S2.addTriangle(0, S2.nv-2, S2.nv-1);
        }
        else if (k==CC2[i].n-1) {
          S2.addTriangle(1, S2.nv-1, S2.nv-2);
        }
        else
        {
          S2.addVertex(CC2[j].P[k]); 
          S2.addTriangle(S2.nv-3, S2.nv-1, S2.nv-2);
          S2.addVertex(CC2[i].P[k]); 
          S2.addTriangle(S2.nv-3, S2.nv-2, S2.nv-1);
        }
      }
    }
  }

  //C3
  if (C3.n>2) {
    S3.empty();
    S3.addVertex(CC3[0].P[0]);
    S3.addVertex(CC3[0].P[CC3[0].n-1]);
    for (int i=0;i<numRotation[3];i++)
    {
      int j=i+1;
      if (j>numRotation[3]-1) j=0;

      for (int k=1;k<CC3[i].n;k++) {

        if (k==1) {
          S3.addVertex(CC3[j].P[k]); 
          S3.addVertex(CC3[i].P[k]);
          S3.addTriangle(0, S3.nv-2, S3.nv-1);
        }
        else if (k==CC3[i].n-1) {
          S3.addTriangle(1, S3.nv-1, S3.nv-2);
        }
        else
        {
          S3.addVertex(CC3[j].P[k]); 
          S3.addTriangle(S3.nv-3, S3.nv-1, S3.nv-2);
          S3.addVertex(CC3[i].P[k]); 
          S3.addTriangle(S3.nv-3, S3.nv-2, S3.nv-1);
        }
      }
    }
  }
}

void restoreNormalRotation() {

  if (lastShapeKey == 1) {
    for (int i=0;i<numRotation[0];i++) {
      if (CC0[i] == null)
        CC0[i]=new Curve();
      else {
        CC0[i].empty();
        CC0[i].resetPoints();
      }
    }
  } 
  else if (lastShapeKey == 2) {
    for (int i=0;i<numRotation[1];i++) {
      if (CC1[i] == null)
        CC1[i]=new Curve();
      else {
        CC1[i].empty();
        CC1[i].resetPoints();
      }
    }
  } 
  else if (lastShapeKey == 3) {
    for (int i=0;i<numRotation[2];i++) {
      if (CC2[i] == null)
        CC2[i]=new Curve();
      else {
        CC2[i].empty();
        CC2[i].resetPoints();
      }
    }
  } 
  else if (lastShapeKey == 4) {
    for (int i=0;i<numRotation[3];i++) {
      if (CC3[i] == null)
        CC3[i]=new Curve();
      else {
        CC3[i].empty();
        CC3[i].resetPoints();
      }
    }
  }
}

void saveInfos() {
  // need to save C, D, numRotation, lastShapeKey
  saveSetting("data/setting");
  C0.savePts("data/C0.pts");
  C1.savePts("data/C1.pts");
  C2.savePts("data/C2.pts");
  C3.savePts("data/C3.pts");
}

void saveSetting(String fn) {
  String [] inppts = new String [6];
  int s=0; inppts[s++]=str(Dir.x)+","+str(Dir.y)+","+str(Dir.z); 
  for (int i=0; i<4; i++)
    inppts[s++]=str(numRotation[i]);
  inppts[s++]=str(lastShapeKey);
  saveStrings(fn,inppts);
}

void loadInfos() {
  loadSetting("data/setting");
  C0.loadPts("data/C0.pts");
  C1.loadPts("data/C1.pts");
  C2.loadPts("data/C2.pts");
  C3.loadPts("data/C3.pts");
  
  for (int i=0;i<numRotation[0];i++) {
    CC0[i]=new Curve();
  }
  for (int i=0;i<numRotation[1];i++) {
    CC1[i]=new Curve();
  }
  for (int i=0;i<numRotation[2];i++) {
    CC2[i]=new Curve();
  }
  for (int i=0;i<numRotation[3];i++) {
    CC3[i]=new Curve();
  }
  
  
}

void loadSetting(String fn) {
  String [] ss = loadStrings(fn);
  String subpts;
  int s=0; int comma1, comma2;  
  String S =  ss[0];
  comma1=S.indexOf(',');
  float x=float(S.substring(0, comma1));
  String R = S.substring(comma1+1);
  comma2=R.indexOf(',');      
  float y=float(R.substring(0, comma2)); 
  float z=float(R.substring(comma2+1));
  Dir = V(x,y,z);
  s++;
  for (int i=0; i<4; i++) {
    numRotation[i] = int(ss[s]);
    s++;
  }
  lastShapeKey = int(ss[s]);
}

void removeNonConvex(){
  
  //CO
 if(lastShapeKey==1){
  if (C0.n>=3){
        boolean removeDone=false;
        
        
       //determine turning majority
         int leftTurn=0;
         int rightTurn=0;
         for(int i=0;i<C0.n-2;i++){
             if(crossProduct2D(C0.P[i],C0.P[i+1],C0.P[i+2])<0) leftTurn++;
             else rightTurn++;
         }
         if(leftTurn==0||rightTurn==0) removeDone=true;
        // println(leftTurn+"  "+rightTurn);
         
         //remove those minority
         for(int i=0;i<C0.n-2;i++){
             if(leftTurn>rightTurn){
                 if(crossProduct2D(C0.P[i],C0.P[i+1],C0.P[i+2])>0) removePoint(0,i+1);
             }
             else{
                 if(crossProduct2D(C0.P[i],C0.P[i+1],C0.P[i+2])<0) removePoint(0,i+1);
             }
           
         }
  }
 }
 
  //C1
 if(lastShapeKey==2){
  if (C1.n>=3){
        boolean removeDone=false;
        
        
       //determine turning majority
         int leftTurn=0;
         int rightTurn=0;
         for(int i=0;i<C1.n-2;i++){
             if(crossProduct2D(C1.P[i],C1.P[i+1],C1.P[i+2])<0) leftTurn++;
             else rightTurn++;
         }
         if(leftTurn==0||rightTurn==0) removeDone=true;
        // println(leftTurn+"  "+rightTurn);
         
         //remove those minority
         for(int i=0;i<C1.n-2;i++){
             if(leftTurn>rightTurn){
                 if(crossProduct2D(C1.P[i],C1.P[i+1],C1.P[i+2])>0) removePoint(1,i+1);
             }
             else{
                 if(crossProduct2D(C1.P[i],C1.P[i+1],C1.P[i+2])<0) removePoint(1,i+1);
             }
           
         }
  }
 }
 
  //C2
 if(lastShapeKey==3){
  if (C2.n>=3){
        boolean removeDone=false;
        
        
       //determine turning majority
         int leftTurn=0;
         int rightTurn=0;
         for(int i=0;i<C2.n-2;i++){
             if(crossProduct2D(C2.P[i],C2.P[i+1],C2.P[i+2])<0) leftTurn++;
             else rightTurn++;
         }
         if(leftTurn==0||rightTurn==0) removeDone=true;
        // println(leftTurn+"  "+rightTurn);
         
         //remove those minority
         for(int i=0;i<C2.n-2;i++){
             if(leftTurn>rightTurn){
                 if(crossProduct2D(C2.P[i],C2.P[i+1],C2.P[i+2])>0) removePoint(2,i+1);
             }
             else{
                 if(crossProduct2D(C2.P[i],C2.P[i+1],C2.P[i+2])<0) removePoint(2,i+1);
             }
           
         }
  }
 }
 
  //C3
 if(lastShapeKey==4){
  if (C3.n>=3){
        boolean removeDone=false;
        
        
       //determine turning majority
         int leftTurn=0;
         int rightTurn=0;
         for(int i=0;i<C3.n-2;i++){
             if(crossProduct2D(C3.P[i],C3.P[i+1],C3.P[i+2])<0) leftTurn++;
             else rightTurn++;
         }
         if(leftTurn==0||rightTurn==0) removeDone=true;
        // println(leftTurn+"  "+rightTurn);
         
         //remove those minority
         for(int i=0;i<C3.n-2;i++){
             if(leftTurn>rightTurn){
                 if(crossProduct2D(C3.P[i],C3.P[i+1],C3.P[i+2])>0) removePoint(3,i+1);
             }
             else{
                 if(crossProduct2D(C3.P[i],C3.P[i+1],C3.P[i+2])<0) removePoint(3,i+1);
             }
           
         }
  }
 }
  
}

void removePoint(int CurveNo, int ptIndex){
  if(CurveNo==0){
     C0.delete(ptIndex);
  }
  if(CurveNo==1){
     C1.delete(ptIndex);
  }
  if(CurveNo==2){
     C2.delete(ptIndex);
  }
  if(CurveNo==3){
     C3.delete(ptIndex);
  }
  
  
}

float crossProduct2D(pt A, pt B, pt C){
  return  (B.x-A.x)*(-(C.y-B.y))+(B.y-A.y)*(C.x-B.x);
}

void buildSurface(){
  //C0
  if(lastShapeKey==1){
    fill(brown);stroke(blue);  
    for(int i=0;i<numRotation[0];i++)
    {
      int j=i+1;
      if(j>numRotation[0]-1) j=0;
      for(int k=0;k<CC0[i].n-1;k++){
        beginShape();
        vertex(CC0[i].P[k]);
        vertex(CC0[i].P[k+1]);
        vertex(CC0[j].P[k+1]);
        vertex(CC0[j].P[k]);
        endShape();
      }
    }
  }
    //C1
   if(lastShapeKey==2){
     fill(brown);stroke(blue);  
    for(int i=0;i<numRotation[1];i++)
    {
      int j=i+1;
      if(j>numRotation[1]-1) j=0;
      for(int k=0;k<CC1[i].n-1;k++){
        beginShape();
        vertex(CC1[i].P[k]);
        vertex(CC1[i].P[k+1]);
        vertex(CC1[j].P[k+1]);
        vertex(CC1[j].P[k]);
        endShape();
      }
    }
   }
   
    //C2
   if(lastShapeKey==3){
     fill(brown);stroke(blue);  
    for(int i=0;i<numRotation[2];i++)
    {
      int j=i+1;
      if(j>numRotation[2]-1) j=0;
      for(int k=0;k<CC2[i].n-1;k++){
        beginShape();
        vertex(CC2[i].P[k]);
        vertex(CC2[i].P[k+1]);
        vertex(CC2[j].P[k+1]);
        vertex(CC2[j].P[k]);
        endShape();
      }
    }
   }
   
    //C3
   if(lastShapeKey==4){
     fill(brown);stroke(blue);  
    for(int i=0;i<numRotation[3];i++)
    {
      int j=i+1;
      if(j>numRotation[3]-1) j=0;
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
    
}
