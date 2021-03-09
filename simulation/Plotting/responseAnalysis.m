%======================================================================
% Author: Ted Simmons
% Github: https://github.com/thjsimmons/
% Date: May 1, 2020
%======================================================================

addpath('../Data');
load('../Data/position.mat');
load('../Data/angle.mat');
load('../Data/voltage.mat');

time_s = positionData(1,:);
position_mm = positionData(2,:);
angle_rad = angleData(2,:);
voltage_v = voltageData(2,:);

t = time_s;
p = position_mm;
a = angle_rad;

t_impulse  = -1;
i_impulse = 0;

t_xsettle = -1;
t_xpeak = 0;
t_xrise = 0;

t_asettle = -1;
i_asettle = -1;
t_apeak = 0;
t_arise1 = -1;
t_arise2 = -1;

x_peak = 0;
a_peak = -1;

p_detect = 10;
a_detect = 0.01;

p_absMax = max(abs(p));
p_settle = 0;
for i = 1:length(a)
    % Find start of impulse: 
    if abs(a(i)) > abs(a_detect)
        if t_impulse == -1
            t_impulse = t(i);
            i_impulse = i;
        end
    end
    
    % Find peak angle, peak time:
    if abs(a(i)) == max(abs(a))
        t_apeak = t(i);
        a_peak = a(i);
        disp("set apeak");
    end
    a_mean = movmean(abs(a),600);
    if a_peak ~= -1 && abs(a_mean(i)) < 0.05 * abs(a_peak) && t_asettle == -1
        t_asettle = t(i);
        i_asettle = i;
    end
   
     
      
end

for i = 1:length(a)
    if t(i) > t_impulse && t(i) < t_apeak
        if a(i) > 0.1 * a_peak && t_arise1 == -1
            t_arise1 = t(i);
        end
        if a(i) > 0.9 * a_peak && t_arise2 == -1
            t_arise2 = t(i);
        end
    end
end

t_arise = t_arise2 - t_arise1;

timeEnd = length(t)-1;
tindex = 0;
for i = 1:length(t)-1
    if abs(t(i) - timeEnd) < 0.05
        tindex = i;
        break;
    end
end

figure(1);
plot(t, p/1000, 'r-');
xlim([1, 3]);
ylim([-1*2 1*2]);
title('position vs. time');
xlabel('time (s)');
ylabel('position (m)');
%save('positionVtime.fig');

amax = abs(max(a));
figure(2);
plot(t, a, 'r-');
xlim([0,10]);
ylim([-0.05 0.05]);
title('angle vs. time');
xlabel('time (s)');
ylabel('angle (rad)');



disp("Final angle (rad): ");
disp(a(end));
disp("Peak time (s): ");
disp(t_apeak);
disp("Peak angle (rad): ");
disp(a_peak);
disp("Settle time (s): ");
disp(t_asettle);
disp("Rise time (s): ");
disp(t_arise);
disp("Abs Max x: ");
disp(p_absMax);

%p_settle = p(i_asettle);
disp("Settled @ x (cm) = ");
%disp(p_settle/10);

