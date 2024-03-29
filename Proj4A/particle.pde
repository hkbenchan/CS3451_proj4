// class: particle

class particle {
  int closestPos=0;
  float radius = 5; // default radius size
  float x = 0 ,y = 0 ,z = 0;  // position
  vec velocity = new vec(0,0,0);
  
  particle() {}
  particle(int r) { radius = r; }
  
  particle setPosition(float x, float y, float z) { this.x = x; this.y = y; this.z = z; return this; }
  particle setVelocity(float vx, float vy, float vz) { this.velocity.x = vx; this.velocity.y = vy; this.velocity.z = vz; return this;}
  particle setVelocity(vec V) { this.velocity.set(V); return this; }
  particle setTo(particle p) { this.setPosition(p.x,p.y,p.z); this.radius = p.radius; this.velocity.set(p.velocity); return this; }
  particle updatePos(float t) { x += velocity.x*t; y += velocity.y*t; z += velocity.z*t; return this; }
  
  particle display() {
    
    noStroke();
    fill(green);
    pushMatrix();
    translate(x, y, z);
    sphereDetail(5);
    sphere(this.radius);
    popMatrix();
    return this;
  }
  
  particle Ptexture() {
    
    return this;
  }
}
