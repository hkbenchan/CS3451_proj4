// class: generator

class generator {

  pt center = new pt(0,0,0);
  float radius = 50;
  float x = width/2, y = height/2, z = 0;
  int max_p = 1024;
  int active_p = 0;
  float emit_rate = 1; // 1 particle per second
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
    popMatrix();
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
    println(mainC.n);
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
          float decayRatio=sq(cos(distanceParticileClosestC*PI/1000));//cosine square decay function,  decay according to distance from 0 to 1000
          if (i==0 ||i==1)
             println(i+"  "+decayRatio);
          newVel=V(5*decayRatio,newVel);
          if (addDynamic){
                if(p[i].closestPos==0)
                       p[i].setVelocity(newVel.x,newVel.y,newVel.z);
                else{
                       p[i].setVelocity((p[i].velocity.x+dynamicBlendParameter*(newVel.x-p[i].velocity.x)),(p[i].velocity.y+dynamicBlendParameter*(newVel.y-p[i].velocity.y)),(p[i].velocity.z+dynamicBlendParameter*(newVel.z-p[i].velocity.z)));
                       
                }
            
          }else{
                    if(p[i].closestPos==0)
                       p[i].setVelocity(newVel.x,newVel.y,newVel.z);
                    else{
                      // println("in here"+p[i].velocity.x+"  "+p[i].velocity.y+"  "+p[i].velocity.z);
                      //calculate geometric mean
                 /*     float x,y,z;
                      if(p[i].velocity.x*newVel.x<0)
                          x=-sqrt(-p[i].velocity.x*newVel.x);
                      else
                          x=sqrt(p[i].velocity.x*newVel.x);
                      
                      if(p[i].velocity.y*newVel.y<0)
                          y=-sqrt(-p[i].velocity.y*newVel.y);
                      else
                          y=sqrt(p[i].velocity.y*newVel.y);
                          
                      if(p[i].velocity.z*newVel.z<0)
                          z=-sqrt(-p[i].velocity.z*newVel.z);
                      else
                          z=sqrt(p[i].velocity.z*newVel.z);  */
                      
                      p[i].setVelocity((p[i].velocity.x+newVel.x)/2,(p[i].velocity.y+newVel.y)/2,(p[i].velocity.z+newVel.z)/2);
                       
                    }
                  //  println(p[i].velocity.x+"  "+p[i].velocity.y+"  "+p[i].velocity.z);
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

}
