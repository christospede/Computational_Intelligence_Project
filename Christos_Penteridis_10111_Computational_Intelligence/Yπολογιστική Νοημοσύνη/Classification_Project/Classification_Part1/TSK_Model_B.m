clear; clc;
data = load('haberman.data');
[trainSet, validSet, testSet] = partition_and_normalize(data, 1);
class_distribution(trainSet, validSet, testSet);

radii = [0.3, 0.7];
for i = 1:2
    [c1, s1] = subclust(trainSet(trainSet(:,end)==1,:), radii(i));
    [c2, s2] = subclust(trainSet(trainSet(:,end)==2,:), radii(i));

    fis = sugfis('Name','TSK_Model');
    for j = 1:3
        fis = addInput(fis,[0 1],'Name',sprintf('in%d',j));
    end
    fis = addOutput(fis,[1 2],'Name','out1');

    for j = 1:3
        for k = 1:size(c1,1)
            fis = addMF(fis,sprintf('in%d',j),'gaussmf',[s1(j) c1(k,j)],'Name',sprintf('A%d',k));
        end
        for k = 1:size(c2,1)
            fis = addMF(fis,sprintf('in%d',j),'gaussmf',[s2(j) c2(k,j)],'Name',sprintf('B%d',k));
        end
    end

    params = [ones(1,size(c1,1)) 2*ones(1,size(c2,1))];
    for k = 1:length(params)
        fis = addMF(fis,'out1','constant',params(k),'Name',sprintf('C%d',k));
    end

    nr = length(params);
    rules = zeros(nr,6);
    for k = 1:nr
        rules(k,:) = [k k k k 1 1];
    end
    fis = addRule(fis,rules);

    [fisTrained, trErr, ~, fisVal, valErr] = anfis(trainSet, fis, [100 0 0.01 0.9 1.1], [], validSet);
    preds = round(evalfis(fisVal, testSet(:,1:end-1)));

    classes = unique(data(:,end));
    confMat = zeros(numel(classes), numel(classes));
    for j = 1:size(testSet,1)
        x = find(classes==preds(j));
        y = find(classes==testSet(j,end));
        confMat(x,y) = confMat(x,y) + 1;
    end

    % Learning curve
    figure;
    plot(trErr,'r','LineWidth',1.5); hold on;
    plot(valErr,'b--','LineWidth',1.5);
    title(['Model B',num2str(i)]); legend('Train','Validation');

    % Membership Function Plots
    figure('Name',sprintf('MFs for TSK Model B%d',i));
    for j = 1:3
        subplot(1,3,j);
        [x, mf] = plotmf(fisTrained, 'input', j);
        plot(x, mf, 'LineWidth', 1.5);
        title(sprintf('Input %d', j)); xlabel('τιμή'); ylabel('MF');
    end

    % Console results
    fprintf('\n--- TSK Model B%d ---\n', i);
    disp(confMat);
end

