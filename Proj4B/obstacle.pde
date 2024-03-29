// class: obstacle

class obstacle {
  PImage earthImage ;//= loadImage("data/world32k.jpg");
  pt pos = new pt(0,0,0);
  float radius = 60;
  float x = width/2, y = height/2, z = 0;
  int sDetail = 13;
  
  // for display earth
  float rotationX = 0;
  float rotationY = 0;
  float velocityX = 0;
  float velocityY = 0;
  float globeRadius = 450;
  float pushBack = 0;
  
  float[] cx, cz, sphereX, sphereY, sphereZ;
  float sinLUT[];
  float cosLUT[];
  float SINCOS_PRECISION = 0.5;
  int SINCOS_LENGTH = int(360.0 / SINCOS_PRECISION);
  
  
  obstacle() {};
  obstacle init() { initializeSphere(this.sDetail); this.resize(this.radius); return this; }
  
  obstacle setCenter(pt C) {
     this.pos.set(C);
     return this;
  }
  
  obstacle resize(float r) {
    this.radius = r; 
    return this;
  }
  
  obstacle display() {
    sphereDetail(this.sDetail);
    pushMatrix();
    translate(this.pos.x,this.pos.y,this.pos.z);
    pushMatrix();
    noFill();
    stroke(255,200);
    strokeWeight(2);
    smooth();
    popMatrix();
    lights();    
    pushMatrix();
    rotateX( radians(-rotationX) );  
    rotateY( radians(270 - rotationY) );
    fill(200);
    noStroke();
    textureMode(IMAGE);  
    this.gTexture(this.radius, this.earthImage);
    popMatrix();  
    popMatrix();
    rotationX += velocityX;
    rotationY += velocityY;
    velocityX *= 0.95;
    velocityY *= 0.95;
    return this;
  }
  
  obstacle dragCenter(vec V) {
    this.pos.set(P(this.pos, V));
    return this; 
  }
  
  obstacle gTexture(float r, PImage t) {
    int v1,v11,v2;
    //r = (r + 240 ) * 0.33;
    beginShape(TRIANGLE_STRIP);
    texture(t);
    float iu=(float)(t.width-1)/(this.sDetail);
    float iv=(float)(t.height-1)/(this.sDetail);
    float u=0,v=iv;
    for (int i = 0; i < sDetail; i++) {
      vertex(0, -r, 0,u,0);
      vertex(sphereX[i]*r, sphereY[i]*r, sphereZ[i]*r, u, v);
      u+=iu;
    }
    vertex(0, -r, 0,u,0);
    vertex(sphereX[0]*r, sphereY[0]*r, sphereZ[0]*r, u, v);
    endShape();   
    
    // Middle rings
    int voff = 0;
    for(int i = 2; i < sDetail; i++) {
      v1=v11=voff;
      voff += sDetail;
      v2=voff;
      u=0;
      beginShape(TRIANGLE_STRIP);
      texture(t);
      for (int j = 0; j < sDetail; j++) {
        vertex(sphereX[v1]*r, sphereY[v1]*r, sphereZ[v1++]*r, u, v);
        vertex(sphereX[v2]*r, sphereY[v2]*r, sphereZ[v2++]*r, u, v+iv);
        u+=iu;
      }
    
      // Close each ring
      v1=v11;
      v2=voff;
      vertex(sphereX[v1]*r, sphereY[v1]*r, sphereZ[v1]*r, u, v);
      vertex(sphereX[v2]*r, sphereY[v2]*r, sphereZ[v2]*r, u, v+iv);
      endShape();
      v+=iv;
    }
    u=0;
    
    // Add the northern cap
    beginShape(TRIANGLE_STRIP);
    texture(t);
    for (int i = 0; i < sDetail; i++) {
      v2 = voff + i;
      vertex(sphereX[v2]*r, sphereY[v2]*r, sphereZ[v2]*r, u, v);
      vertex(0, r, 0,u,v+iv);    
      u+=iu;
    }
    vertex(sphereX[voff]*r, sphereY[voff]*r, sphereZ[voff]*r, u, v);
    endShape();
    
    
    
    return this; 
  }

  void initializeSphere(int res)
  {
    this.earthImage = loadImage("world32k.jpg");
    sinLUT = new float[SINCOS_LENGTH];
    cosLUT = new float[SINCOS_LENGTH];
  
    for (int i = 0; i < SINCOS_LENGTH; i++) {
      sinLUT[i] = (float) Math.sin(i * DEG_TO_RAD * SINCOS_PRECISION);
      cosLUT[i] = (float) Math.cos(i * DEG_TO_RAD * SINCOS_PRECISION);
    }
  
    float delta = (float)SINCOS_LENGTH/res;
    float[] cx = new float[res];
    float[] cz = new float[res];
    
    // Calc unit circle in XZ plane
    for (int i = 0; i < res; i++) {
      cx[i] = -cosLUT[(int) (i*delta) % SINCOS_LENGTH];
      cz[i] = sinLUT[(int) (i*delta) % SINCOS_LENGTH];
    }
    
    // Computing vertexlist vertexlist starts at south pole
    int vertCount = res * (res-1) + 2;
    int currVert = 0;
    
    // Re-init arrays to store vertices
    sphereX = new float[vertCount];
    sphereY = new float[vertCount];
    sphereZ = new float[vertCount];
    float angle_step = (SINCOS_LENGTH*0.5f)/res;
    float angle = angle_step;
    
    // Step along Y axis
    for (int i = 1; i < res; i++) {
      float curradius = sinLUT[(int) angle % SINCOS_LENGTH];
      float currY = -cosLUT[(int) angle % SINCOS_LENGTH];
      for (int j = 0; j < res; j++) {
        sphereX[currVert] = cx[j] * curradius;
        sphereY[currVert] = currY;
        sphereZ[currVert++] = cz[j] * curradius;
      }
      angle += angle_step;
    }
    this.sDetail = res;
  }
  
  
  //save
  
  void saveInfo() {saveInfo("data/O.pts");}
  void saveInfo(String fn) { String [] inppts = new String [2];
    int s=0; inppts[s++]=str(1); 
    inppts[s++]=str(pos.x)+","+str(pos.y)+","+str(pos.z);
    saveStrings(fn,inppts);  };
  void loadInfo() {loadInfo("data/O.pts");}
  void loadInfo(String fn) { String [] ss = loadStrings(fn);
    String subpts;
    int s=0; int comma1, comma2; int n = int(ss[s]);
    for(int i=0; i<n; i++) { 
      String S =  ss[++s];
      comma1=S.indexOf(',');
      float x=float(S.substring(0, comma1));
      String R = S.substring(comma1+1);
      comma2=R.indexOf(',');      
      float y=float(R.substring(0, comma2)); 
      float z=float(R.substring(comma2+1));
      pos= P(x,y,z);  
      }; 
    }
    
}
