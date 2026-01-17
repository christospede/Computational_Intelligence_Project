function [trainSet, validSet, testSet] = partition_and_normalize(data, mode)
    % Διαχωρισμός σε 60%-20%-20%
    n = size(data,1);
    idx = randperm(n);
    L1 = round(0.6 * n);
    L2 = round(0.8 * n);
    
    trainSet = data(idx(1:L1), :);
    validSet = data(idx(L1+1:L2), :);
    testSet  = data(idx(L2+1:end), :);
    
    % Κανονικοποίηση σύμφωνα με trainSet
    X = trainSet(:,1:end-1);
    
    switch mode
        case 1 % [0,1] normalization
            xmin = min(X);
            xmax = max(X);
            normF = @(X_) (X_ - xmin) ./ (xmax - xmin + eps);
        case 2 % Standardization
            mu = mean(X);
            sigma = std(X);
            normF = @(X_) (X_ - mu) ./ (sigma + eps);
        otherwise
            error('Unknown normalization mode');
    end
    
    trainSet(:,1:end-1) = normF(trainSet(:,1:end-1));
    validSet(:,1:end-1) = normF(validSet(:,1:end-1));
    testSet(:,1:end-1)  = normF(testSet(:,1:end-1));
end
