clc; clear;
params = init_params();
fisFile = 'FIS_car.fis';

% Initial state
x = 3.8; y = 0.5; theta = 0;
u = params.u_max;
dt = params.dt;

track = [x, y];

while x < params.goal(1)
    [dv, dh] = compute_distances(x, y);
    dtheta = compute_dtheta(fisFile, dv, dh, theta);
    [x, y, theta] = update_car(x, y, theta, dtheta, u, dt);
    track(end+1,:) = [x, y]; %#ok<AGROW>
end

plotCarTrajectory(track, params.goal, params.obstacles);