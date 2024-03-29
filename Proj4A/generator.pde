// class: generator

class generator {

  pt center = new pt(0,0,0);
  float radius = 50;
  float x = width/2, y = height/2, z = 0;
  int max_p = 1024;
  int active_p = 0;
  float emit_rate = 5; // 5 particle per second
  particle p[] = new particle[max_p];
  LinkedList queue = new LinkedList(); // for recycle particles
  boolean display[] = new boolean[max_p]; // for checking display condition
  
  generator() {};
  generator init() { for (int i=0; i<max_p; i++) { p[i] = new particle(); queue.offer(i); display[i] = false;} return this; }
  generator renderNewParticle() {
    if (active_p >= max_p) return this;
    //boolean neg_x = (random(1)-0.5)<0?true:false, neg_y = (random(1)-0.5)<0?true:false, neg_z = (random(1)-0.5)<0?true:false;
    float alpha_a = random(0, 2*PI), beta_a = random(0, 2*PI);
    float temp_r = this.radius + p[active_p].radius;
    float random_x  = temp_r*cos(alpha_a)*cos(beta_a), random_y = temp_r*sin(alpha_a), random_z = temp_r*cos(alpha_a)*sin(beta_a);
    //float magnitude = random(1,4*temp_r)/temp_r;
    int new_p = (Integer) queue.pop();
    p[new_p].setPosition(this.center.x + random_x,this.center.y + random_y,this.center.z + random_z).setVelocity(0,0,0);
    p[new_p].closestPos=0;
    active_p++;
    display[new_p] = true;
    return this;
  }
  
  generator resetQueue() {
    while(!queue.isEmpty()) { queue.pop(); }
    for (int i=0; i<max_p; i++) { queue.offer(i); display[i] = false;}
    return this; 
  }
  
  generator removeParticle(int index) {
    active_p--;
    queue.offer(index);
    display[index] = false;
    return this;
  }
  
  generator setCenter(pt C) {
     this.center.set(C);
     active_p = 0;
     resetQueue();
     return this;
  }
  
  generator resize(float r) {
    this.radius = r; 
    active_p = 0;
    resetQueue();
    return this;
  }
  
  generator displayG() {
    pushMatrix();
    noStroke();
    fill(orange);
    lights();
    translate(this.center.x,this.center.y,this.center.z);
    sphereDetail(15);
    sphere(this.radius);
    popMatrix();
    return this;
  }
  
  generator displayGP() {
    this.displayG();
    for (int i=0; i<max_p; i++) { 
      if (display[i]) p[i].display(); 
    }
    return this;
    
  }
  
  generator dragCenter(vec V) {
    this.center.set(P(this.center, V));
    active_p = 0;
    resetQueue();
    return this; 
  }
  
  generator gTexture() {
    
    return this; 
  }
  
  generator updateParticles(float t) {
    updateVelocity();
    for (int i=0; i<max_p; i++) {
      if (display[i])
        p[i].updatePos(t);
    } 
    return this;
  }
 
  generator updateVelocity() {
    //println(mainC.n);
    for (int i=0; i<max_p; i++) { //for each particle do
        if (display[i]) {
          //findClosestPtC(P(p[i].x,p[i].y,p[i].z));
          if (p[i].closestPos == mainC.n-1) { removeParticle(i); continue; }
          stroke(black);
          show(P(p[i].x,p[i].y,p[i].z),mainC.P[p[i].closestPos]);
          vec newVel;
          if(d(P(p[i].x,p[i].y,p[i].z), mainC.P[p[i].closestPos+1])<d(P(p[i].x,p[i].y,p[i].z), mainC.P[p[i].closestPos]))
          {
             p[i].closestPos++;
          }
          float distanceParticileClosestC=d(P(p[i].x,p[i].y,p[i].z), mainC.P[p[i].closestPos]);
          if(p[i].closestPos==0){
             newVel=V(mainC.P[p[i].closestPos],mainC.P[p[i].closestPos+1]);
             //p[i].setVelocity(V(mainC.P[closestPos],mainC.P[closestPos+1]));
          }else{
            // p[i].setVelocity(V(mainC.P[closestPos-1],mainC.P[closestPos+1]));
              newVel=V(mainC.P[p[i].closestPos-1],mainC.P[p[i].closestPos+1]);    
          }
          //newVel=U(newVel);
          float decayRatio=0;
          if(distanceParticileClosestC<310)
             //cosine square decay function,  decay according to distance from 0 to 300
             decayRatio=sq(cos(distanceParticileClosestC*PI/300));
          newVel=V(decayRatio,newVel);
          if (addDynamic){
                if(p[i].closestPos==0)
                       p[i].setVelocity(newVel.x,newVel.y,newVel.z);
                else{
                       p[i].setVelocity(average(newVel,p[i].velocity,dynamicBlendParameter));
                }
            
          }else{
                  
                  p[i].setVelocity(newVel.x,newVel.y,newVel.z);
                 
          }
       }
       
    } 
    return this;
  }
  
 /* int findClosestPtC(pt particle){
     int nearestPos=0;
     for(int i=0; i<mainC.n;i++){
        if(d(particle, mainC.P[i])<d(particle, mainC.P[nearestPos]))
            nearestPos=i;
     }
     return nearestPos;
  }
  */
  
  
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
