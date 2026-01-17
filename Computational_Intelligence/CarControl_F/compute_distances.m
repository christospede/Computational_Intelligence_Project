function [dv, dh] = compute_distances(x, y)
    % Vertical (dv) and horizontal (dh) distances from known obstacles
    if x <= 5
        dv = y;
    elseif x <= 6
        dv = y - 1;
    elseif x <= 7
        dv = y - 2;
    else
        dv = y - 3;
    end

    if y <= 1
        dh = 5 - x;
    elseif y <= 2
        dh = 6 - x;
    elseif y <= 3
        dh = 7 - x;
    else
        dh = 20 - x;
    end

    % Normalize for FIS [0,1]
    dv = min(max(dv, 0), 1);
    dh = min(max(dh, 0), 1);
end