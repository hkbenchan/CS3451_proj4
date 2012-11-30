void writeHelp () {fill(dblue);
    int i=0;
    scribe("3D VIEWER 2012 (Jarek Rossignac)",i++);
    scribe("CS3451 Final Project",i++);
    scribe("Author: Ho Pan Chan, Yik Wai Ng", i++);
    scribe("-------View-------", i++);
    scribe("Change view: 'o' and mouse drag", i++);
    scribe("Show S1 and S2 at the same time: u", i++);
    scribe("Original Faces/Triangle Mesh: 'm'", i++); 
    scribe("-------Shape------", i++);
    scribe("Select: 1, 2, 3 or 4", i++);
    scribe("Add point: shape number and mouse click", i++);
    scribe("Modify point: 's' and mouse drag", i++);
    scribe("Delete point: 'd' and mouse click", i++);
    scribe("Insert point: 'i' and mouse click", i++);
    scribe("Remove non-convex: 'C'", i++);
    scribe("Change number of sample: inc: ','; dec: '.'", i++);
    scribe("-------Morphing----",i++);
    scribe("Display Morphing between 2 solids: '@'",i++);
    scribe("Trigger On/Off animation: 'a'", i++);
    scribe("Move time axis: 't' and mouse drag", i++);
    scribe("Trigger Red/Green Face, Blue Quad: 'R', 'G' , 'B'", i++);
    scribe("-------Other------", i++);
    scribe("Load setting: L; Save setting: W", i++);
    
//    scribe("CURVE t:show, s:move XY, a:move XZ , v:move all XY, b:move all XZ, A;archive, C.load",i++);
//    scribe("MESH L:load, .:pick corner, Y:subdivide, E:smoothen, W:write, N:next, S.swing ",i++);
//    scribe("VIEW space:pick focus, [:reset, ;:on mouse, E:save, e:restore ",i++);
//    scribe("SHOW ):silhouette, B:backfaces, |:normals, -:edges, c:curvature, g:Gouraud/flat, =:translucent",i++);
    scribe("",i++);

   }
void writeFooterHelp () {fill(dbrown);
    //scribeFooter("Jarek Rossignac's 3D template.  Press ?:help",1);
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
