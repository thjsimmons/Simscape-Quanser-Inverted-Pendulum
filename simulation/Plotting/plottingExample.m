%======================================================================
% Author: Ted Simmons
% Github: https://github.com/thjsimmons/
% Date: May 1, 2020
%======================================================================

% Output data of the simulation over time is:
%{
1) Cart position (m) -> position.mat as array positionData
2) Pendulum angle (rad) -> angle.mat as array angleData
3) Pendulum tip position (m) -> tipPostion.mat as as array tipPositionData
4) Motor voltage (v) -> voltage.mat as array voltageData
%}
% These arrays are plotted below
% 

my_stopTime = simulationStopTime;
addpath('../Data');
load('../Data/position.mat');
load('../Data/angle.mat');
load('../Data/voltage.mat');

t = positionData(1,:);
p = positionData(2,:);
%tip = tipPositionData(2,:);
a = angleData(2,:);
v = voltageData(2,:);

figure(1);
plot(t, p, 'r-');
xlim([0, my_stopTime]);
ylim([-1, 1]);
title('position vs. time');
xlabel('time (s)');
ylabel('position (m)');
%save('positionVtime.fig');

figure(2);
plot(t, a, 'r-');
xlim([0, my_stopTime]);
ylim([-0.3, 0.3]);
title('angle vs. time');
xlabel('time (s)');
ylabel('angle (rad)');



figure(3);
plot(t, a, 'r-');
xlim([0, my_stopTime]);
ylim([-15, 15]);
title('voltage vs. time');
xlabel('time (s)');
ylabel('voltage (v)');



