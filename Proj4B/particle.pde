// class: particle

class particle {
  int closestPos=0;
  float radius = 10; // default radius size
  pt pos = P(0,0,0);  // position
  vec velocity = new vec(0,0,0);
  
  particle() {}
  particle(int r) { radius = r; }
  
  particle setPosition(float x, float y, float z) { this.pos.x = x; this.pos.y = y; this.pos.z = z; return this; }
  particle setPosition(pt P) { this.pos.set(P); return this; }
  particle setVelocity(float vx, float vy, float vz) { this.velocity.x = vx; this.velocity.y = vy; this.velocity.z = vz; return this;}
  particle setVelocity(vec V) { this.velocity.set(V); return this; }
  particle setTo(particle p) { this.setPosition(p.pos); this.radius = p.radius; this.velocity.set(p.velocity); return this; }
  particle updatePos(float t) { this.pos.add(t,this.velocity); return this; }
  
  particle display() {
    
    noStroke();
    fill(green);
    pushMatrix();
    translate(this.pos.x, this.pos.y, this.pos.z);
    sphereDetail(5);
    sphere(this.radius);
    popMatrix();
    return this;
  }
  
  particle Ptexture() {
    
    return this;
  }
}
