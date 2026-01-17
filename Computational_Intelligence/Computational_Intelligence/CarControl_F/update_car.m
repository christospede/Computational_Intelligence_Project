function [x, y, theta] = update_car(x, y, theta, dtheta, u, dt)
    theta = theta + dtheta;
    theta = max(min(theta, 180), -180); % clamp

    x = x + u * cosd(theta) * dt;
    y = y + u * sind(theta) * dt;
end