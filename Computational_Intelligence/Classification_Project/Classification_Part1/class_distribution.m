% Εκτυπώνει ποσοστά κλάσεων σε train/valid/test

function class_distribution(trainSet,validSet,testSet)
    sets = {trainSet,validSet,testSet};
    names = {'Train','Valid','Test'};
    for k=1:3
        S = sets{k};
        cls = unique(S(:,end));
        fprintf('\n[%s]\n', names{k});
        for c=cls'
            pct = sum(S(:,end)==c) / size(S,1) * 100;
            fprintf(' Κλάση %d: %.2f%%\n', c, pct);
        end
    end
end