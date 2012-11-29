// class: d_sphere

class d_sphere {

  pt center = new pt(0,0,0);
  float radius = 30, small_radius = 10;
  float x = width/2, y = height/2, z = 0;
  int sDetail = 20;
  
  
  d_sphere() {};
  d_sphere init() { return this; }

  d_sphere setCenter(pt C) {
     this.center.set(C);
     return this;
  }
  
  d_sphere resize(float r) {
    this.radius = r; 
    return this;
  }
  
  d_sphere displayG() {
    pushMatrix();
    fill(orange);
    translate(this.center.x,this.center.y,this.center.z);
    sphereDetail(this.sDetail);
    sphere(this.radius);
    // small sphere
    pushMatrix();
      fill(green);
      pt tran = P(P(),V(this.radius+this.small_radius,Dir));
      translate(tran.x,tran.y,tran.z);
      sphere(this.small_radius);
    popMatrix();
    // end
    popMatrix();
    return this;
  }
  
  d_sphere dragCenter(vec V) {
    this.center.set(P(this.center, V));
    return this; 
  }
  
  void saveInfo() {saveInfo("data/G.pts");}
  void saveInfo(String fn) { String [] inppts = new String [2];
    int s=0; inppts[s++]=str(1); 
    inppts[s++]=str(center.x)+","+str(center.y)+","+str(center.z);
    saveStrings(fn,inppts);  };
  void loadInfo() {loadInfo("data/G.pts");}
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
      center= P(x,y,z);  
      }; 
    }
    
    

}
