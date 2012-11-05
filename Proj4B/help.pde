void writeHelp () {fill(dblue);
    int i=0;
    scribe("Project 4B, 3D velocity field curve and particle simulation",i++);
    scribe("VELOCITY FIELD CURVE: ",i++);
    scribe("t: show tube, x: move selected point XY, z: move selected point XZ ",i++);
    scribe("v: move all XY, b: move all XZ, S: save, L: load ",i++);
    scribe("i: insert control point, c: delete control point, a: append control point",i++);
    scribe("                   ",i++);
    scribe("PARTICLE GENERATOR: ",i++);
    scribe("pressed G and mouse drag left/ right: change emission rate",i++);
    scribe("pressed g and mouse drag left/ right: change size of the generator,  n:move XY, m:move XZ",i++);
    scribe("pressed , and mouse click on a point: move the generator to that point instantly",i++);
    scribe("                   ",i++);
    scribe("OBSTACLE (earth): ",i++);
    scribe("press e and mouse drag left/ right: change size of obstacle",i++);
    scribe("O: move XY, o: move XZ",i++);
    scribe("                   ",i++);
    scribe("GRAVITY: ",i++);
    scribe("u: turn on gravity effect ",i++);
    scribe("pressed U and mouse drag left/ right: change the strength of the gravitational force (set gravity const)",i++);
    scribe("                   ",i++);
    scribe("OTHER PARAMETERS: ",i++);
    scribe("f: add dynamic, pressed s and mouse drag left/ right: change blend parameter ",i++);
    scribe("D: Moves E forward/backward (enlarge), d: Moves E forward/backward and rotates around (F,Y) ",i++);
    scribe("Mouse Drag only: rotating the view point, Q: quit",i++);
   // scribe("SHOW ):silhouette, B:backfaces, |:normals, -:edges, c:curvature, g:Gouraud/flat, =:translucent",i++);
    scribe("",i++);

   }
void writeFooterHelp () {fill(dbrown);
    scribeFooter("Jarek Rossignac's 3D template.  Press ?:help",1);
  }
void scribeHeader(String S) {text(S,10,20);} // writes on screen at line i
void scribeHeaderRight(String S) {text(S,width-S.length()*15,20);} // writes on screen at line i
void scribeFooter(String S) {text(S,10,height-10);} // writes on screen at line i
void scribeFooter(String S, int i) {text(S,10,height-10-i*20);} // writes on screen at line i from bottom
void scribe(String S, int i) {text(S,10,i*30+20);} // writes on screen at line i
void scribeAtMouse(String S) {text(S,mouseX,mouseY);} // writes on screen near mouse
void scribeAt(String S, int x, int y) {text(S,x,y);} // writes on screen pixels at (x,y)
void scribe(String S, float x, float y) {text(S,x,y);} // writes at (x,y)
void scribe(String S, float x, float y, color c) {fill(c); text(S,x,y); noFill();}
;

