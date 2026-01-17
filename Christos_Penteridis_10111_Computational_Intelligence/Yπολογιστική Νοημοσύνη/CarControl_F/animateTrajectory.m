function animateTrajectory(track, goal, obstacles)
    figure('Color','w'); hold on; grid on;
    plot(obstacles(:,1), obstacles(:,2), 'k-', 'LineWidth', 2);
    plot(goal(1), goal(2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    
    carPlot = plot(track(1,1), track(1,2), 'bo', 'MarkerSize', 6, 'MarkerFaceColor','b');
    trajectoryLine = animatedline('Color','b','LineWidth',1.5);
    
    xlim([0 12]); ylim([0 4]);
    xlabel('X [m]'); ylabel('Y [m]');
    title('Car Obstacle Avoidance — Animation');

    for i = 1:size(track,1)
        addpoints(trajectoryLine, track(i,1), track(i,2));
        carPlot.XData = track(i,1);
        carPlot.YData = track(i,2);
        drawnow;
    end
end