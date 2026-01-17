% Plot model comparison results (RMSE, NMSE, NDEI, R²)

% Αν προέρχονται από CSV:
% T = readtable('results/metrics_summary.csv', 'ReadRowNames', true);

% Ή ορισμός με το χέρι για επίδειξη:
model_names = {'Model 1', 'Model 2', 'Model 3', 'Model 4'};
RMSE = [0.85, 0.77, 0.69, 0.72];  % Παράδειγμα τιμών
NMSE = [0.40, 0.33, 0.27, 0.29];
NDEI = sqrt(NMSE);
R2   = [0.60, 0.67, 0.73, 0.71];

% --- 1ο διάγραμμα: RMSE, NMSE, NDEI ---
figure;
metrics = [RMSE(:), NMSE(:), NDEI(:)];
bar(metrics);
legend({'RMSE', 'NMSE', 'NDEI'}, 'Location', 'northoutside', 'Orientation','horizontal');
xticks(1:4); xticklabels(model_names);
ylabel('Error value'); title('Comparison of Model Errors');
grid on;

% --- 2ο διάγραμμα: R² ---
figure;
bar(R2);
xticks(1:4); xticklabels(model_names);
ylabel('R²'); title('Coefficient of Determination (R²) by Model');
ylim([0 1]);
grid on;