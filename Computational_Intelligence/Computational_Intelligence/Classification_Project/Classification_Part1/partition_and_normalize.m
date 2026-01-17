
function [trainSet, validSet, testSet] = partition_and_normalize(data, mode)
    n = size(data,1);
    idx = randperm(n);
    L = round([0.6 0.8]*n);

    trainSet = data(idx(1:L(1)),:);
    validSet = data(idx(L(1)+1:L(2)),:);
    testSet  = data(idx(L(2)+1:end),:);

    % Κανονικοποίηση βάσει του trainSet
    Xtr = trainSet(:,1:end-1);
    Xval = validSet(:,1:end-1);
    Xtst = testSet(:,1:end-1);

    switch mode
        case 1
            xmin = min(Xtr);
            xmax = max(Xtr);
            trainSet(:,1:end-1) = (Xtr - xmin) ./ (xmax - xmin);
            validSet(:,1:end-1) = (Xval - xmin) ./ (xmax - xmin);
            testSet(:,1:end-1)  = (Xtst - xmin) ./ (xmax - xmin);
        case 2
            mu = mean(Xtr);
            sigma = std(Xtr);
            trainSet(:,1:end-1) = (Xtr - mu) ./ sigma;
            validSet(:,1:end-1) = (Xval - mu) ./ sigma;
            testSet(:,1:end-1)  = (Xtst - mu) ./ sigma;
        otherwise
            error('Unknown normalization mode');
    end
end