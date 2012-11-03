// collision tracker class

class collisionTracker {
  float next_ct = 1<<30-1; // next collision time
  int A = -1, B = -1; // collision id
  boolean obstacle_involved = false; // B will be ignore if obstacle_involved is true 
  
  collisionTracker() {}
  collisionTracker setAB(int a, int b) { this.A = a; this.B = b; return this; }
  collisionTracker setTo(collisionTracker cT) { this.next_ct = cT.next_ct; this.setAB(cT.A, cT.B); this.obstacle_involved = cT.obstacle_involved; return this; }
}

// particle collision
collisionTracker particleCollisionTest() {
    collisionTracker cT = new collisionTracker();
    particle A = new particle(), B = new particle();
    for (int i=0; i<G.max_p-1;i++) {
       if (G.display[i]) {
         for (int j=i+1; j<G.max_p; j++) {
           if (G.display[j]) {
             float s1,s2;
             A.setTo(G.p[i]); B.setTo(G.p[j]);
             vec U = A.velocity, V = B.velocity, UV = M(V,U), AB = V(A.pos,B.pos);
             float tot_r = A.radius + B.radius;
             float q_A = n2(UV), q_B = 2*d(AB,UV), q_C = n2(AB)-pow(tot_r,2);
             float delta = pow(q_B,2)- 4*q_A*q_C;
             if (delta<0) continue;
             if (abs(q_C) <0.0000000000000001) {
               s1 = 0; s2 = -q_B/q_A;
             } else {
               s1 = (-q_B+sqrt(delta))/(2*q_A); s2 =  (-q_B-sqrt(delta))/(2*q_A);
             }
             
             if (0<s1 && s1<cT.next_ct) { 
               cT.next_ct = s1;
               cT.setAB(i,j);
             }
             if (0<s2 && s2<cT.next_ct) { 
               cT.next_ct = s2;
               cT.setAB(i,j);
             }
             
           }
         }
       } 
    }
    return cT;
}

// particle collides with obstacle
collisionTracker obstacleCollisionTest() {
  collisionTracker cT = new collisionTracker();
  cT.obstacle_involved = true;
  particle A = new particle();
  for (int i=0; i<G.max_p; i++) {
    if (G.display[i]) {
      // check collision with the obstacle
      float s1, s2;
      A.setTo(G.p[i]);
      float r_total = A.radius+ O.radius;
      vec U = A.velocity, AB = V(A.pos, O.pos);
      float q_A = n2(U), q_B = -2*d(AB,U), q_C = n2(AB) - pow(r_total,2);
      float delta = pow(q_B,2)- 4*q_A*q_C;
      if (delta<0) continue;
      if (abs(q_C) <0.0000000000000001) {
        s1 = 0; s2 = -q_B/q_A;
      } else {
        s1 = (-q_B+sqrt(delta))/(2*q_A); s2 =  (-q_B-sqrt(delta))/(2*q_A);
      }
      if (0<s1 && s1<cT.next_ct) { 
        cT.next_ct = s1;
        cT.setAB(i,-1);
      }
      if (0<s2 && s2<cT.next_ct) { 
        cT.next_ct = s2;
        cT.setAB(i,-1);
      }
    }
  }
  return cT;
}

collisionTracker runCollisionTest() {
   collisionTracker ct_p = particleCollisionTest();
   collisionTracker ct_o = obstacleCollisionTest();
   if (ct_p.next_ct <= ct_o.next_ct)
     return ct_p;
   else
     return ct_o;
}
