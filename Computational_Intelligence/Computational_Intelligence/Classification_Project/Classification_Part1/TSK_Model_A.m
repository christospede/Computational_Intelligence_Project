% Εκπαίδευση δύο TSK μοντέλων με το dataset Haberman
% Χρήση Subtractive Clustering (class-independent)

clear; clc;

% Φόρτωση και ταξινόμηση dataset
raw = load('haberman.data');
raw = sortrows(raw, 4);

% Κατανομή και κανονικοποίηση δεδομένων
[trainSet, validSet, testSet] = partition_and_normalize(raw, 1);

% Επιλογή ακτίνας clustering
fisOpts(1) = genfisOptions('SubtractiveClustering','ClusterInfluenceRange',0.3);
fisOpts(2) = genfisOptions('SubtractiveClustering','ClusterInfluenceRange',0.7);

for idx = 1:2
    % Δημιουργία αρχικού FIS
    fis0 = genfis(trainSet(:,1:end-1), trainSet(:,end), fisOpts(idx));
    
    % Εκπαίδευση με ANFIS
    [fisTrained, trErr, ~, fisVal, valErr] = anfis(trainSet, fis0, [120 0 0.01 0.9 1.1], [], validSet);
    
    % Αξιολόγηση μοντέλου
    outputPred = round(evalfis(fisVal, testSet(:,1:end-1)));
    
    % Καμπύλες εκμάθησης
    figure;
    plot(valErr,'b--', 'LineWidth',1.5); hold on;
    plot(trErr,'r-', 'LineWidth',1.5);
    xlabel('Επανάληψη'); ylabel('Σφάλμα');
    legend('Validation','Training'); 
    title(sprintf('TSK Model %d: Learning Curves', idx));

    figure('Name', sprintf('TSK Model %d - MFs after Training', idx));
    for j = 1:3
    subplot(1,3,j);
    [x, mf] = plotmf(fisTrained, 'input', j);
    plot(x, mf, 'LineWidth', 1.5);
    title(sprintf('Input %d', j));
    xlabel('τιμή'); ylabel('MF');
    end
    
    % Πίνακας σφαλμάτων (Confusion Matrix)
    classes = unique(raw(:,end));
    confMat = zeros(numel(classes), numel(classes));
    for i=1:size(testSet,1)
        predIdx = find(classes==outputPred(i));
        trueIdx = find(classes==testSet(i,end));
        confMat(predIdx,trueIdx) = confMat(predIdx,trueIdx) + 1;
    end
    
    % Υπολογισμός δεικτών απόδοσης
    OA = trace(confMat)/sum(confMat,'all');
    PA = diag(confMat)./sum(confMat,2);
    UA = diag(confMat)./sum(confMat,1)';
    kappa = (sum(diag(confMat))*size(testSet,1) - sum(PA.*UA)) / ...
            (size(testSet,1)^2 - sum(PA.*UA));
    
    % Εκτύπωση αποτελεσμάτων
    fprintf('\n========== TSK Model %d ==========\n', idx);
    disp('Confusion Matrix:'); disp(confMat);
    fprintf('Overall Accuracy (OA): %.3f\n', OA);
    fprintf('Producer Accuracy (PA): %.3f\n', mean(PA));
    fprintf('User Accuracy (UA): %.3f\n', mean(UA));
    fprintf('Kappa Coefficient (κ): %.3f\n', kappa);
end
