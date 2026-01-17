%% TSK_Model_C - Grid Search for Optimal TSK on Epileptic Dataset
clear; clc;

% Load dataset
data = csvread('epileptic_seizure_data.csv', 1, 1);
[trainSet, valSet, testSet] = partition_and_normalize(data, 1);

% Grid parameters
radiusList = [0.2, 0.3, 0.4, 0.5, 0.6];
featureCounts = [5, 10, 15, 20, 25];
cvFolds = 5;

% Feature ranking
[featureRanks, ~] = relieff(trainSet(:,1:end-1), trainSet(:,end), 10);

% Grid search loop
gridErrors = zeros(length(featureCounts), length(radiusList));
cv = cvpartition(size(trainSet,1), 'KFold', cvFolds);

totalTrainings = length(featureCounts) * length(radiusList) * cvFolds;
trainCount = 0;

for f = 1:length(featureCounts)
    for r = 1:length(radiusList)
        foldErrors = zeros(1, cvFolds);
        for k = 1:cvFolds
            idx = featureRanks(1:featureCounts(f));
            foldTrain = trainSet(training(cv,k), [idx end]);
            foldVal = trainSet(test(cv,k), [idx end]);
            opts = genfisOptions('SubtractiveClustering', 'ClusterInfluenceRange', radiusList(r));
            fis = genfis(foldTrain(:,1:end-1), foldTrain(:,end), opts);
            [~, ~, ~, ~, valErr] = anfis(foldTrain, fis, [30 0 0.01 0.9 1.1], [], foldVal);
            foldErrors(k) = min(valErr);
            trainCount = trainCount + 1;
            fprintf('Training %d of %d completed (Remaining: %d)\n', ...
            trainCount, totalTrainings, totalTrainings - trainCount);
        end
        gridErrors(f, r) = mean(foldErrors);
    end
end

% Plot 3D surface
[R, F] = meshgrid(radiusList, featureCounts);
figure;
surf(R, F, gridErrors);
xlabel('Radius'); ylabel('Feature Count'); zlabel('Mean Validation Error');
title('Grid Search: Radius vs Feature Count vs Error');

% Best combination
[minErr, idx] = min(gridErrors(:));
[bestFIdx, bestRIdx] = ind2sub(size(gridErrors), idx);
bestRadius = radiusList(bestRIdx);
bestFeatureCount = featureCounts(bestFIdx);
bestFeatures = featureRanks(1:bestFeatureCount);

% Train final model
trData = trainSet(:, [bestFeatures end]);
chkData = valSet(:, [bestFeatures end]);
tsData = testSet(:, [bestFeatures end]);

opt = genfisOptions('SubtractiveClustering', 'ClusterInfluenceRange', bestRadius);
fis0 = genfis(trData(:,1:end-1), trData(:,end), opt);
[fisTr, trnErr, ~, fisVal, valErr] = anfis(trData, fis0, [100 0 0.01 0.9 1.1], [], chkData);

% Prediction and Error
predictions = round(evalfis(fisVal, tsData(:,1:end-1)));
realLabels = tsData(:,end);
predError = realLabels - predictions;

figure; plot(predError);
title('Prediction Error (Test Set)'); xlabel('Sample Index'); ylabel('Error');

figure; plot([trnErr valErr],'LineWidth',2);
xlabel('Iterations'); ylabel('Error');
legend('Training', 'Validation'); title('Learning Curve');

% Plot MFs before training
figure('Name','MFs Before Training');
for i = 1:bestFeatureCount
    subplot(ceil(sqrt(bestFeatureCount)), ceil(bestFeatureCount/ceil(sqrt(bestFeatureCount))), i);
    [x, mf] = plotmf(fis0, 'input', i);
    plot(x, mf); xlabel(sprintf('Feature %d', i)); title('Before');
end

% Plot MFs after training
figure('Name','MFs After Training');
for i = 1:bestFeatureCount
    subplot(ceil(sqrt(bestFeatureCount)), ceil(bestFeatureCount/ceil(sqrt(bestFeatureCount))), i);
    [x, mf] = plotmf(fisTr, 'input', i);
    plot(x, mf); xlabel(sprintf('Feature %d', i)); title('After');
end

% Evaluation
classes = unique(realLabels);
confMat = zeros(length(classes));
for i = 1:length(realLabels)
    x = find(classes == predictions(i));
    y = find(classes == realLabels(i));
    confMat(x, y) = confMat(x, y) + 1;
end

% Metrics
OA = trace(confMat)/length(realLabels);
PA = diag(confMat)./sum(confMat,1)';
UA = diag(confMat)./sum(confMat,2);
K = (length(realLabels)*trace(confMat) - sum(PA.*UA)) / (length(realLabels)^2 - sum(PA.*UA));

% Display
fprintf('\n==== Final Model Evaluation ====\n');
disp(confMat);
fprintf('Overall Accuracy: %.2f\n', OA);
fprintf('Producer Accuracy: %.2f\n', mean(PA));
fprintf('User Accuracy: %.2f\n', mean(UA));
fprintf('Kappa: %.2f\n', K);
