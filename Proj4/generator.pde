// class: generator

class generator {
  pt center = new pt(0,0,0);
  float radius = 50;
  float x = width/2, y = height/2, z = 0;
  int max_p = 1024;
  int active_p = 0;
  float emit_rate = 1; // 1 particle per second
  particle p[] = new particle[max_p];
  
  generator() {};
  generator init() { for (int i=0; i<max_p; i++) { p[i] = new particle(); } return this; }
  generator renderNewParticle() {
    if (active_p >= max_p) return this;
    //boolean neg_x = (random(1)-0.5)<0?true:false, neg_y = (random(1)-0.5)<0?true:false, neg_z = (random(1)-0.5)<0?true:false;
    float alpha_a = random(0, 2*PI), beta_a = random(0, 2*PI);
    float temp_r = this.radius + p[active_p].radius;
    float random_x  = temp_r*cos(alpha_a)*cos(beta_a), random_y = temp_r*sin(alpha_a), random_z = temp_r*cos(alpha_a)*sin(beta_a);
    float magnitude = random(1,4*temp_r)/temp_r;
    p[active_p].setPosition(random_x,random_y,random_z).setVelocity(magnitude*random_x,magnitude*random_y,magnitude*random_z);
    active_p++;
    return this;
  }
  
  generator setCenter(pt C) {
     this.center.set(C);
     active_p = 0;
     return this;
  }
  
  generator resize(float r) {
    this.radius = r; 
    active_p = 0;
    return this;
  }
  
  generator displayG() {
    pushMatrix();
    noStroke();
    lights();
    translate(this.center.x,this.center.y,this.center.z);
    sphereDetail(50);
    sphere(this.radius);
    popMatrix();
    return this;
  }
  
  generator displayGP() {
    pushMatrix();
    noStroke();
    stroke(green);
    fill(yellow);
    lights();
    translate(this.center.x,this.center.y,this.center.z);
    sphereDetail(50);
    sphere(this.radius);
    for (int i=0; i<active_p; i++) { p[i].display(); }
    popMatrix();
    return this;
    
  }
  
  generator dragCenter(vec V) {
    this.center.set(P(this.center, V));
    active_p = 0;
    return this; 
  }
  
  generator gTexture() {
    
    return this; 
  }
  
  generator updateParticles(float t) {
    updateVelocity();
    for (int i=0; i<active_p; i++) {
      p[i].updateRelPos(t);
    } 
    return this;
  }
 
  generator updateVelocity() {
    for (int i=0; i<active_p; i++) { //for each particle do
        int closestPos=findClosestPtC(P(p[i].x,p[i].y,p[i].z));
        stroke(black);
        show(P(p[i].x,p[i].y,p[i].z),mainC.P[closestPos]);
     
    } 
    return this;
  }
  
  int findClosestPtC(pt particle){
     int nearestPos=0;
     for(int i=0; i<mainC.n;i++){
        if(d(particle, mainC.P[i])<d(particle, mainC.P[nearestPos]))
            nearestPos=i;
     }
     return nearestPos;
  }
  

}
