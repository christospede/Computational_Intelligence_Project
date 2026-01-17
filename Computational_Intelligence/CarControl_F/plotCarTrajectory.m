function plotCarTrajectory(track, goal, obstacles)
    figure; hold on; grid on;
    plot(obstacles(:,1), obstacles(:,2), 'k-', 'LineWidth', 2);
    plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
    plot(track(:,1), track(:,2), 'b.-', 'LineWidth', 1.5);
    xlabel('X [m]'); ylabel('Y [m]');
    title('Car Path with Fuzzy Controller');
    xlim([0 12]); ylim([0 4]);
end