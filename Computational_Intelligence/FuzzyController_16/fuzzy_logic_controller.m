fis = mamfis("Name", "fis_satellite_mod", ...
    "AndMethod", "min", ...
    "OrMethod", "max", ...
    "ImplicationMethod", "min", ...
    "AggregationMethod", "max", ...
    "DefuzzificationMethod", "mom");

% Προσθήκη εισόδων
fis = addInput(fis, [-1 1], "Name", "Err");
fis = addInput(fis, [-1 1], "Name", "dErr");

% Προσθήκη εξόδου
fis = addOutput(fis, [-1 1], "Name", "uDelta");

% Ορισμός MF για "Err" και "uDelta"
labels = ["NL", "NM", "NS", "ZR", "PS", "PM", "PL"];
centers = [-1 -0.75 -0.4 0 0.4 0.75 1];

for i = 1:numel(labels)
    c = centers(i);
    if i == 1
        p = [-1 -1 (centers(2)+c)/2];
    elseif i == numel(labels)
        p = [(centers(i-1)+c)/2 1 1];
    else
        p = [(centers(i-1)+c)/2 c (centers(i+1)+c)/2];
    end
    fis = addMF(fis, "Err", "trimf", p, "Name", labels(i));
    fis = addMF(fis, "uDelta", "trimf", p, "Name", labels(i));
end

% Μειωμένα MF για "dErr"
labels_dErr = ["NL", "NM", "NS", "ZR", "PS", "PM", "PL"];
centers_dErr = [-1 -0.7 -0.35 0 0.35 0.7 1];

for i = 1:numel(labels_dErr)
    c = centers_dErr(i);
    if i == 1
        p = [-1 -1 (centers_dErr(2)+c)/2];
    elseif i == numel(labels_dErr)
        p = [(centers_dErr(i-1)+c)/2 1 1];
    else
        p = [(centers_dErr(i-1)+c)/2 c (centers_dErr(i+1)+c)/2];
    end
    fis = addMF(fis, "dErr", "trimf", p, "Name", labels_dErr(i));
end

% Περιορισμένο σύνολο κανόνων
rules = [
    "Err==NL & dErr==NL => uDelta=NL";
    "Err==NM & dErr==NM => uDelta=NM";
    "Err==NS & dErr==NS => uDelta=NS";
    "Err==ZR & dErr==ZR => uDelta=ZR";
    "Err==PS & dErr==PS => uDelta=PS";
    "Err==PM & dErr==PM => uDelta=PM";
    "Err==PL & dErr==PL => uDelta=PL";
    "Err==NS & dErr==PM => uDelta=ZR";
    "Err==ZR & dErr==PL => uDelta=PM";
    "Err==PM & dErr==ZR => uDelta=PM";
];

fis = addRule(fis, rules);

% Αποθήκευση σε αρχείο .fis
writefis(fis, "fis_satellite.fis");

% Γραφική απεικόνιση MF (προαιρετικά)
figure(1), plotmf(fis, "input", 1);
figure(2), plotmf(fis, "input", 2);
figure(3), plotmf(fis, "output", 1);

