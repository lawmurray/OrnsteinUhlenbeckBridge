/**
 * Ornstein---Uhlenbeck model.
 *
 * The model is set up for bridge sampling, where the observation block
 * provides the weighting p(x(n)|x(n-1)). The state variable mu holds the mean
 * of x(n) at each time, without the noise term w(n) having yet been
 * added. This is then used in the observation block to weight appropriately.
 */
model OrnsteinUhlenbeckBridge {
  const h = 0.01;
  const theta1 = 0.0187;
  const theta2 = 0.2610;
  const theta3 = 0.0224;
  const sigma = sqrt(theta3**2.0*(1.0 - exp(-2.0*theta2*h))/(2.0*theta2));

  noise w;
  state mu, x;
  obs y;

  sub initial {
    mu <- theta1/theta2;
    x <- theta1/theta2;
  }

  sub transition(delta = h) {
    mu <- theta1/theta2 + (x - theta1/theta2)*exp(-theta2*h);
    w ~ gaussian(0.0, sigma);
    x <- (t_now < t_next_obs && t_next_obs <= t_now + 1.01*h) ? y : mu + w;
  }

  sub bridge {
    inline bdelta = t_next_obs - t_now;
    inline bmu = theta1/theta2 + (x - theta1/theta2)*exp(-theta2*bdelta);
    inline bsigma = sqrt(theta3**2.0*(1.0 - exp(-2.0*theta2*bdelta))/(2.0*theta2));

    y ~ gaussian(bmu, bsigma);
  }

  sub observation {
    y ~ gaussian(mu, sigma);
  }
}
