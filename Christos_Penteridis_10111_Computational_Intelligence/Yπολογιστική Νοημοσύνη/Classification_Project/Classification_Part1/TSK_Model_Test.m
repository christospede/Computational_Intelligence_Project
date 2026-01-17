clear; clc;

raw = load('haberman.data');
[trainSet, validSet, testSet] = partition_and_normalize(raw,1);

radius = 0.5;
[c1,s1] = subclust(trainSet(trainSet(:,end)==1,:), radius);
[c2,s2] = subclust(trainSet(trainSet(:,end)==2,:), radius);

fis = sugfis('Name','TestTSK');

% Είσοδοι
for i = 1:3
    fis = addInput(fis, [0 1], 'Name', sprintf('in%d', i));
end

% Έξοδος
fis = addOutput(fis, [1 2], 'Name', 'out1');

% Προσθήκη MF για κάθε είσοδο και κάθε cluster
for i = 1:3
    for j = 1:size(c1,1)
        fis = addMF(fis, sprintf('in%d',i), 'gaussmf', [s1(i) c1(j,i)], 'Name', sprintf('A%d', j));
    end
    for j = 1:size(c2,1)
        fis = addMF(fis, sprintf('in%d',i), 'gaussmf', [s2(i) c2(j,i)], 'Name', sprintf('B%d', j));
    end
end

% Προσθήκη σταθερών εξόδου (output MFs)
numRules = size(c1,1) + size(c2,1);
outConstants = [ones(1,size(c1,1)), 2*ones(1,size(c2,1))];
for i = 1:numRules
    fis = addMF(fis, 'out1', 'constant', outConstants(i), 'Name', sprintf('C%d', i));
end

% Κανόνες
ruleList = zeros(numRules, 6);  % [in1 in2 in3 out weight conn]
for i = 1:numRules
    ruleList(i,:) = [i i i i 1 1];  % Simple 1-to-1 rule mapping
end
fis = addRule(fis, ruleList);

% Εκπαίδευση
[trainedFIS, trErr, ~, valFIS, valErr] = anfis(trainSet, fis, [100 0 0.01 0.9 1.1], [], validSet);

% Πρόβλεψη
preds = round(evalfis(valFIS, testSet(:,1:end-1)));

% Καμπύλες
figure;
plot(valErr, 'b-', 'LineWidth', 1.5); hold on;
plot(trErr, 'r--', 'LineWidth', 1.5);
xlabel('Επανάληψη'); ylabel('Σφάλμα');
legend('Validation', 'Training'); title('TSK Model Test');
