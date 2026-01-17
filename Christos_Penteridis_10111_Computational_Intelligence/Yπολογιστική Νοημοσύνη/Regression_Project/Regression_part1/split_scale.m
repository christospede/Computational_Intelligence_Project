
function [trnData, chkData, tstData] = split_scale(data, preproc)
    % Split dataset into train/val/test: 60/20/20 and preprocess
    
    % --- Split ---
    idx = randperm(size(data,1));
    n = length(idx);
    trnIdx = idx(1:round(0.6*n));
    chkIdx = idx(round(0.6*n)+1:round(0.8*n));
    tstIdx = idx(round(0.8*n)+1:end);
    
    trnX = data(trnIdx,1:end-1);
    chkX = data(chkIdx,1:end-1);
    tstX = data(tstIdx,1:end-1);

    % --- Preprocessing ---
    switch preproc
        case 1  % Normalize to [0,1]
            xmin = min(trnX);
            xmax = max(trnX);
            trnX = (trnX - xmin) ./ (xmax - xmin);
            chkX = (chkX - xmin) ./ (xmax - xmin);
            tstX = (tstX - xmin) ./ (xmax - xmin);
        case 2  % Standardize to 0 mean, unit var
            mu = mean(trnX);
            sig = std(trnX);
            trnX = (trnX - mu) ./ sig;
            chkX = (chkX - mu) ./ sig;
            tstX = (tstX - mu) ./ sig;
        otherwise
            error('Invalid preprocessing option.');
    end

    % --- Final output ---
    trnData = [trnX data(trnIdx,end)];
    chkData = [chkX data(chkIdx,end)];
    tstData = [tstX data(tstIdx,end)];
end
