% SETUP_SP_CONFIGURATION
%
% SETUP_SP_CONFIGURATION accepts the user-defined configuration 
% of the Quanser Single Pendulum (SP) module. 
% SETUP_SP_CONFIGURATION then sets up 
% the Single Pendulum configuration-dependent model variables accordingly,
% and finally returns the calculated model parameters of the Single Pendulum Quanser module.
%
% Single Pendulum system nomenclature:
% g       Gravitational Constant                         (m/s^2)
% Mp      Pendulum Mass with T-fitting                   (kg)
% Lp      Full Length of the Pendulum (with T-fitting)   (m)
% lp      Distance from Pivot to Centre Of Gravity       (m)
% Ip      Pendulum Moment of Inertia                     (kg.m^2)
% Bp      Viscous Damping Coefficient 
%                       as seen at the Pendulum Axis     (N.m.s/rad)
%
% Copyright (C) 2003 Quanser Consulting Inc.
% Quanser Consulting Inc.


%% returns the model parameters accordingly to the USER-DEFINED Single Pendulum (SP) configuration
function [ g, Mp, Lp, lp, Ip, Bp ] = setup_sp_configuration( PEND_TYPE )
% Calculate useful conversion factors
calc_conversion_constants;
% Gravity Constant
g = 9.81;
% Calculate the pendulum model parameters
[ Mp, Lp, lp, Ip, Bp ] = calc_sp_parameters( PEND_TYPE );
% end of 'setup_sp_configuration( )'


%% Calculate the Single Pendulum (SP) model parameters 
function [ Mp, Lp, lp, Ip, Bp ] = calc_sp_parameters( PEND_TYPE )
global K_IN2M
% Set these variables (used in Simulink Diagrams)
if strcmp( PEND_TYPE, 'LONG_24IN')
    % Pendulum Mass (with T-fitting)
    Mp = 0.230;
    % Pendulum Full Length (with T-fitting, from axis of rotation to tip)
    Lp = ( 25 + 1 / 4 ) * K_IN2M;  % = 0.6413;
    % Distance from Pivot to Centre Of Gravity
    lp = 13 * K_IN2M;  % = 0.3302
    % Pendulum Moment of Inertia (kg.m^2) - approximation
    Ip = Mp * Lp^2 / 12;  % = 7.8838 e-3
    % Equivalent Viscous Damping Coefficient (N.m.s/rad)
    Bp = 0.0024;
elseif strcmp( PEND_TYPE, 'MEDIUM_12IN')
    % Pendulum Mass (with T-fitting)
    Mp = 0.127;
    % Pendulum Full Length (with T-fitting, from axis of rotation to tip)
    Lp = ( 13 + 1 / 4 ) * K_IN2M;  % = 0.3365
    % Distance from Pivot to Centre Of Gravity
    lp = 7 * K_IN2M;  % = 0.1778
    % Pendulum Moment of Inertia (kg.m^2) - approximation
    Ip = Mp * Lp^2 / 12;  % = 1.1987 e-3
    % Equivalent Viscous Damping Coefficient (N.m.s/rad)
    Bp = 0.0024;
else 
    error( 'Error: Set the type of pendulum.' )
end
% end of 'calc_sp_parameters( )'


%% Calculate Useful Conversion Factors w.r.t. Units
function calc_conversion_constants ()
global K_D2R K_IN2M K_RADPS2RPM K_OZ2N
% from radians to degrees
K_R2D = 180 / pi;
% from degrees to radians
K_D2R = 1 / K_R2D;
% from Inch to Meter
K_IN2M = 0.0254;
% from Meter to Inch
K_M2IN = 1 / K_IN2M;
% from rad/s to RPM
K_RADPS2RPM = 60 / ( 2 * pi );
% from RPM to rad/s
K_RPM2RADPS = 1 / K_RADPS%% LATEST CONTROLLER DESIGN STUFF:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Ka_i2 = 0;
Ka_i = 40000; % 40000
Ka_d = 40; % 40
Ka_p = 12000; % 12000
again = 0.002775; % 0.004, 0.0027
Kx_i = 0;
my_Gx = tf(0, 1); %G_xLQR + tf(Kx_i, [1 0]);

zero1 =  2.5; % 3.371, 2.5
zero2 = 400; % 300, 400
mygain =  1.2* 0.108; % 0.108
%}
%my_Ga = mygain * tf([1 zero1+zero2 zero1*zero2], [1 0]);

%{
%%%%%%%%%%%%%%%%%%%% PID Tuning:
Ka_p = 5;
Ka_d = 0;
Ka_i = 0;
again = 1;
integral_pole = 0.01;


Ka_i = 5;
Ka_d = 20;
Ka_p = 300;


%%%%%%%%%%%%%%%%%%%%
my_Ga = again * tf([Ka_d Ka_p Ka_i], [1 0]);

xgain = 1;


%%%% Controller Variables for Simulink TF Implementation %%%%%%%%
[ua_num_init, ua_den_init] = tfdata(my_Ga, 'v');

nonzero_index = 0;

for i = 1:length(ua_num_init)
    if ua_num_init(i) ~= 0
        nonzero_index = i;
    end
end

lastden_index = length(ua_den_init) - (length(ua_num_init) - nonzero_index);
ua_num = ua_num_init(1:nonzero_index);
ua_den = ua_den_init(1:lastden_index);
ua_long_num = zeros(1, 11);




for i = 1:length(ua_num)
    ua_long_num(i) = ua_num(length(ua_num) - i + 1);
end
Avec = zeros(1,11);
Avec = ua_long_num;





%%%% Fixed User-defined TF %%%%%%

ua_long_den = zeros(1, 11);

ua_den_FIRST_INDEX = 0;

for i = 1:length(ua_den)
    if ua_den(i) ~= 0
        ua_den_FIRST_INDEX = i;
        break
    end
end


for i = 1:length(ua_den)
    ua_long_den(i) = ua_den(length(ua_den) - (i-1));
end

last_nonzero_index = 0;

for i  = length(ua_long_den):-1:1
    if ua_long_den(i) ~= 0
        last_nonzero_index = i;
        break;
    end
end
Bvec = zeros(1, 11);

for i = 1:last_nonzero_index - 1
    Bvec(i) = ua_long_den(i);
end

mi_den = zeros(1, last_nonzero_index);
mi_den(1) = 1;
invb0 = 0;

for i = 1:length(ua_den)
    if ua_den(i) ~= 0
        invb0 = 1 / ua_den(i);
        break
    end
end
%}
%multiple_integral = tf(1, mi_den);
w_cut = 2*pi*5;
damping_ratio = 0.9;

derivative_filter = tf([w_cut * w_cut 0], [1 2*w_cut*damping_ratio w_cut*w_cut]); % unused 


% Defining the user's TF controller:
%{
K0 = K;
AGAIN = 1;
XGAIN = 1;
Kpx = K(1);
Kdx = K(3);
Kpa = K(2);
Kda = K(4);
G_xLQR = XGAIN * tf([Kdx Kpx], 1);
G_aLQR = AGAIN * tf([Kda Kpa], 1);
myGx = G_xLQR;
myGa = G_aLQR;
[Ga_num, Ga_den] = tfdata(myGa, 'v');
[Gx_num, Gx_den] = tfdata(myGx, 'v');
Ga_num_full = zeros(1, 12);
Ga_den_full = zeros(1, 12);
Gx_num_full = zeros(1, 12);
Gx_den_full = zeros(1, 12);

for i = 1:length(Ga_num)
    Ga_num_full(i) = Ga_num(length(Ga_num) - i + 1);
end
inputA = Ga_num_full;
for i = 1:length(Gx_num)
    Gx_num_full(i) = Gx_num(length(Gx_num) - i + 1);
end
inputX = Gx_num_full;
for i = 1:length(Ga_den)
    Ga_den_full(i) = Ga_den(length(Ga_den) - i + 1);
end
outputA = Ga_den_full;
for i = 1:length(Gx_den)
    Gx_den_full(i) = Gx_den(length(Gx_den) - i + 1);
end
outputX = Gx_den_full;

for i = 1:12
    set_param(['controller1/ControllerA/InputDerivatives/Gain', int2str(i-1)], 'Gain',num2str(inputA(i)));
    set_param(['controller1/ControllerX/InputDerivatives/Gain', int2str(i-1)],'Gain',num2str(inputX(i)));
    if i == 1
        set_param('controller1/ControllerA/invb0','Gain', num2str(1 / outputA(i)));
        set_param('controller1/ControllerX/invb0','Gain',num2str(1 / outputX(i)));
    else
        set_param(['controller1/ControllerA/OutputDerivatives/Gain', int2str(i-1)],'Gain',num2str(outputA(i)));
        set_param(['controller1/ControllerX/OutputDerivatives/Gain', int2str(i-1)],'Gain',num2str(outputX(i)));
    end
end

%}
2RPM;
% from oz-force to N
K_OZ2N = 0.2780139;
% from N to oz-force
K_N2OZ = 1 / K_OZ2N;
% end of 'calc_conversion_constants( )'
