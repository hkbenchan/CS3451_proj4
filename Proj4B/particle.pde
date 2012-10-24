// class: particle

class particle {
  int closestPos=0;
  float radius = 10; // default radius size
  pt pos = P(0,0,0); // position
  vec velocity = new vec(0,0,0);
  
  particle() {}
  particle(int r) { radius = r; }
  
  particle setPosition(float x, float y, float z) { this.pos.x = x; this.pos.y = y; this.pos.z = z; return this; }
  particle setPosition(pt P) { this.pos.set(P); return this; }
  particle setVelocity(float vx, float vy, float vz) { this.velocity.x = vx; this.velocity.y = vy; this.velocity.z = vz; return this;}
  particle setTo(particle p) { this.setPosition(p.x,p.y,p.z); this.radius = p.radius; this.velocity.set(p.velocity); return this; }
  particle updatePos(float t) { this.pos.add(V(t,this.velocity)); return this; }
  
  particle display() {
    
    noStroke();
    fill(green);
    pushMatrix();
    translate(this.pos.x, this.pos.y, this.pos.z);
    sphereDetail(50);
    sphere(this.radius);
    popMatrix();
    return this;
  }
  
  particle Ptexture() {
    
    return this;
  }
}

float next_collision_time() {
  float time = 1<<31-1; // Infinite time  
  int a = -1, b = -1;
  for (int i=0; i<G.max_p-1;i++) {
     if (G.display[i]) {
       for (int j=i+1; j<G.max_p; j++) {
         if (G.display[j]) {
           particle A = G.p[i], B = G.p[j];
           vec U = A.velocity, V = B.velocity, UV = M(V,U), AB = V(A.pos,B.pos);
           float tot_r = A.radius + B.radius;
           float q_A = n2(UV), q_B = 2*d(AB,UV), q_C = n2(AB)-pow(tot_r,2);
           float delta = pow(q_B,2)- 4*q_A*q_C;
           if (delta<0) break;
           if (abs(q_C) <0.00000001) {
             float s1 = 0, s2 = -q_A/q_B;
           } else {
             float s1 = (-q_b+sqrt(delta))/2*q_C, s2 =  (-q_b-sqrt(delta))/2*q_C;
           }
           
           if (0<s1 && s1<time) { 
             time = s1;
             a = i;
             b = j;
           }
           if (0<s2 && s2<time) { 
             time = s2;
             a = i;
             b = j;
           }
           
         }
       }
     } 
  }
  if (a!=-1)
    collision[0] = a;
  if (b!=-1)
    collision[1] = b;
  return time;
}
