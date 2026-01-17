function params = init_params()
    params.goal = [10, 3.2];
    params.u_max = 0.05;         % car speed (m/s)
    params.dt = 0.1;             % time step (s)
    params.theta_limits = [-180, 180]; % physical limits (degrees)
    
    % Define obstacles as list of [x, y] corner points (walls)
    params.obstacles = [5 0; 5 1; 6 1; 6 2; 7 2; 7 3; 10 3];
end
