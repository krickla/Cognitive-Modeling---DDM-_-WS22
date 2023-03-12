
// we can make our own functions in the function block
functions {
  // Wiener distribution for both upper and lower boundaries condition; 0=object; 1=gun
    real ddm0_lpdf(real y, real boundary_separation, real NDT, real start_point, real drift_object, int choice, int cd) {
    real lpdf;
          if (choice == 1) {
            // Upper boundary (red) - shoot
            lpdf = wiener_lpdf(y | boundary_separation, NDT, start_point, drift_object);
          } else {
            // Lower boundary (blue) - don't shoot
            lpdf = wiener_lpdf(y | boundary_separation, NDT, 1 - start_point, -drift_object);
          }
        return lpdf;
    }

  real ddm1_lpdf(real y, real boundary_separation, real NDT, real start_point, real drift_gun, int choice, int cd) {
    real lpdf;
          if (choice == 1) {
            // Upper boundary (red) - shoot
            lpdf = wiener_lpdf(y | boundary_separation, NDT, start_point, drift_gun);
          } else {
            // Lower boundary (blue) - don't shoot
            lpdf = wiener_lpdf(y | boundary_separation, NDT, 1 - start_point, -drift_gun);
          }
    return lpdf;
    
  }
  
}


data {
  int<lower=1>N;  // number of trials
  int<lower=0,upper=1> choice[N]; // shooting decisions;  1=shoot, 0=don't shoot
  int<lower=0,upper=1> cd[N]; // condition; 0=object; 1=gun
  real<lower = 0> RT[N]; // Response time

}

parameters {
real<lower = 0> boundary_separation; // 2 times the threshold
real<lower = 0> NDT; // Non-decision time
real<lower = 0, upper = 1> start_point; // ?reative start point
real drift_object; //drift rate
real drift_gun; //drift rate

}

model {

  // priors
boundary_separation ~ normal(0, 3)T[0,]; 
NDT ~ normal(0, 0.2)T[0,];
start_point ~ beta(2, 2)T[0,1];
drift_object ~ normal(0, 1);
drift_gun ~ normal(0, 1);

for (n in 1:N) { //go through every decision
  if ( cd[n] == 0) { // object condition 
    RT[n] ~ ddm0(boundary_separation,NDT, start_point, drift_object, choice[n], cd[n]);

  } else { // gun condition
    RT[n] ~ ddm1(boundary_separation,NDT, start_point, drift_gun, choice[n], cd[n]);

  }

}

}

