function dtheta = compute_dtheta(fisFile, dv, dh, theta)
    % Normalize theta from [-180,180] -> [-1,1]
    theta_norm = theta / 180;
    fis = readfis(fisFile);
    dtheta_norm = evalfis(fis, [dv dh theta_norm]);
    % Scale back to degrees 
    dtheta = dtheta_norm * 130;
end