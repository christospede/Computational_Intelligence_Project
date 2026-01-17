% Εμφάνιση πλέγματος κλειστού βρόχου
figure;
plot(out.r.Time, out.r.Data, "-b", DisplayName="setpoint");
hold on;
plot(out.y.Time, out.y.Data, "-r", DisplayName="satellite angle");
grid on;
legend("Location","best");
title("Response (ke=5,ki=0.5,k=20)");
xlabel("Time (s)");
ylabel("Angle (deg)");
ylim([0, max(out.y.Data)*1.1]);

% Χρήση stepinfo αν υπάρχει Control Toolbox
if exist("stepinfo","file")
    S = stepinfo(out.y.Data, out.y.Time);
    fprintf("\nRise Time: %.3f s\n", S.RiseTime);
    fprintf("Overshoot: %.2f %%\n", S.Overshoot);
else
    % fallback: χειροκίνητος υπολογισμός
    rt = risetime(out.y.Data, out.y.Time);
    os = overshoot(out.y.Data, out.y.Time);
    fprintf("\nManual Rise Time: %.3f s\n", rt);
    fprintf("Manual Overshoot: %.2f %%\n", os);
end
