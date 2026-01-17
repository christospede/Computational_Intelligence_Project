% Unified TSK Regression Script with GridPartition and Subtractive Clustering
% Dataset: Airfoil Self-Noise
% Models 1 & 2: GridPartition (constant output)
% Models 3 & 4: Subtractive Clustering (linear output)

clc; clear; close all;

% --- Load Dataset ---
data = load('airfoil_self_noise.dat');

% --- Split and normalize ---
[trnData, chkData, tstData] = split_scale(data, 2);
X_trn = trnData(:,1:5); Y_trn = trnData(:,6);
X_chk = chkData(:,1:5); Y_chk = chkData(:,6);

% --- Loop over 4 models ---
for i = 1:4
    fprintf('\n==== Training TSK Model %d ====\n', i);

    % Choose method & options
    if i == 1 || i == 2
        % GridPartition
        nMFs = i + 1; % 2 or 3 MFs
        opt = genfisOptions("GridPartition", ...
            NumMembershipFunctions=nMFs, ...
            InputMembershipFunctionType="gbellmf", ...
            OutputMembershipFunctionType="constant");
    else
        % Subtractive Clustering (fixed radius, linear output)
        radius = 0.5 + 0.1*(i-3);  % e.g., 0.5 and 0.6 for variety
        opt = genfisOptions("SubtractiveClustering", ...
            ClusterInfluenceRange=radius);
    end

    % --- Generate initial FIS ---
    fis0 = genfis(X_trn, Y_trn, opt);

    % --- Plot initial MFs (just for input 1 for brevity) ---
    figure;
    plotmf(fis0, 'input', 1);
    title(sprintf('Model %d - Input 1 MFs (Before Training)', i));

    % --- Train using ANFIS ---
    anfisOpt = anfisOptions('InitialFIS', fis0, ...
                            'EpochNumber', 80, ...
                            'ValidationData', [X_chk Y_chk]);
    [fisTrained, trnErr, ~, fisVal, valErr] = anfis([X_trn Y_trn], anfisOpt);

    % --- Plot trained MFs for input 1 ---
    figure;
    plotmf(fisTrained, 'input', 1);
    title(sprintf('Model %d - Input 1 MFs (After Training)', i));

    % --- Learning curves ---
    figure;
    plot(trnErr, 'b', 'LineWidth', 1.5); hold on;
    plot(valErr, 'r', 'LineWidth', 1.5);
    legend('Training Error', 'Validation Error');
    xlabel('Epoch'); ylabel('Error');
    title(sprintf('Learning Curves - Model %d', i)); grid on;

    % --- Predict and compute metrics on check set ---
    Y_pred = evalfis(fisVal, X_chk);
    err = Y_chk - Y_pred;
    MSE = mean(err.^2);
    RMSE = sqrt(MSE);
    R2 = 1 - sum(err.^2) / sum((Y_chk - mean(Y_chk)).^2);
    NMSE = 1 - R2;
    NDEI = sqrt(NMSE);

    % --- Prediction error plot ---
    figure;
    plot(err); title(sprintf('Prediction Error - Model %d', i));
    xlabel('Sample'); ylabel('Error');

    % --- Print metrics ---
    fprintf('Model %d: RMSE = %.4f | R² = %.4f | NMSE = %.4f | NDEI = %.4f\n', ...
             i, RMSE, R2, NMSE, NDEI);
end
