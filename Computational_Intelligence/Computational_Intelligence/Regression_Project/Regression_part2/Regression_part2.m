%% Final TSK Training with Optimal Parameters
clearvars; clc;

load('matlab_results.mat');  % Πρέπει να περιέχει: Index, optimum_chkData, chkData, trnData

% --- Ορισμός των βέλτιστων τιμών ---
opt_radius = 0.4;
opt_features = 25;
feature_idx = Index(1:opt_features);

% --- Δημιουργία σετ εκπαίδευσης και ελέγχου ---
trnOpt = trnData(:, [feature_idx, end]);
chkOpt = chkData(:, [feature_idx, end]);

% --- Δημιουργία FIS με Subtractive Clustering ---
opt = genfisOptions("SubtractiveClustering", ClusterInfluenceRange=opt_radius);
fis0 = genfis(trnOpt(:,1:end-1), trnOpt(:,end), opt);

% --- Εκπαίδευση με ANFIS ---
anfisOpt = anfisOptions('InitialFIS', fis0, 'EpochNumber', 100, ...
                        'ValidationData', chkOpt);
[fisTrained, trnErr, ~, fisVal, valErr] = anfis(trnOpt, anfisOpt);

% --- Πρόβλεψη και σφάλμα στο validation set ---
Y_pred = evalfis(fisVal, chkOpt(:,1:end-1));
true_Y = chkOpt(:,end);
err = true_Y - Y_pred;

% --- Μετρικές Απόδοσης ---
RMSE = sqrt(mean(err.^2));
R2 = 1 - sum(err.^2)/sum((true_Y - mean(true_Y)).^2);
NMSE = 1 - R2;
NDEI = sqrt(NMSE);

fprintf('\n✅ Optimum TSK Model Performance:\n');
fprintf('RMSE = %.4f | R² = %.4f | NMSE = %.4f | NDEI = %.4f\n', RMSE, R2, NMSE, NDEI);

% --- Διαγράμματα ---
figure;
plot(err); title('Prediction Error'); xlabel('Sample'); ylabel('Error');

figure;
plot(trnErr,'b','linewidth',1.5); hold on;
plot(valErr,'r','linewidth',1.5); grid on;
legend('Train', 'Validation');
xlabel('Epoch'); ylabel('Error'); title('Learning Curves');

figure;
subplot(1,2,1); plotmf(fis0, 'input', 1:opt_features); title('Initial Membership Functions');
subplot(1,2,2); plotmf(fisTrained, 'input', 1:opt_features); title('Trained Membership Functions');


