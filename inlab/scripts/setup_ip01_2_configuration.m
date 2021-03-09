% SETUP_IP01_2_CONFIGURATION
%
% SETUP_IP01_2_CONFIGURATION accepts the user-defined configuration 
% of the Quanser IP01 or IP02 system. SETUP_IP01_2_CONFIGURATION then sets up 
% the IP01 or IP02 configuration-dependent model variables accordingly,
% and finally returns the calculated model parameters of the IP01 or IP02 Quanser plant.
%
% IP01 and IP02 system nomenclature:
% Rm        Motor Armature Resistance                                   (Ohm)
% Kt        Motor Torque Constant                                       (N.m/A)
% Eff_m     Motor Efficiency
% Km        Motor Back-EMF Constant                                     (V.s/rad)
% Kg        Planetary Gearbox Gear Ratio
% Eff_g     Planetary Gearbox Efficiency
% Jm        Rotor Inertia                                               (kg.m^2)
% M         Total Mass of the Cart System (i.e. moving parts)           (kg)
% r_mp      Motor Pinion Radius                                         (m)
% Beq       Equivalent Viscous Damping Coefficient 
%                       as seen at the Motor Pinion                     (N.s/m)
% K_PC      if IP01: Cart Potentiometer Sensitivity                     (m/V)
% K_PP      if IP01: Pendulum Potentiometer Sensitivity                 (rad/V)
% K_EC      if IP02: Cart Encoder Resolution                            (m/count)
% K_EP      if IP02: Pendulum Encoder Resolution                        (rad/count)
% VMAX_UPM  UPM Maximum Output Voltage                                  (V)
% IMAX_UPM  UPM Maximum Output Current                                  (A)
%
% Copyright (C) 2003 Quanser Consulting Inc.
% Quanser Consulting Inc.


%% returns the model parameters accordingly to the USER-DEFINED IP01 or IP02 system configuration
function [ Rm, Jm, Kt, Eff_m, Km, Kg, Eff_g, M, r_mp, Beq ] = setup_ip01_2_configuration( CART_TYPE, IP02_LOAD_TYPE, UPM_TYPE )
% Calculate useful conversion factors
calc_conversion_constants;
% Calculate IP01 or IP02 model parameters
[ Rm, Jm, Kt, Eff_m, Km, Kg, Eff_g, M, r_mp, Beq ] = calc_IP01_2_parameters( CART_TYPE, IP02_LOAD_TYPE, UPM_TYPE );
% end of 'setup_ip01_2_configuration( )'


%% Calculate the IP01 or IP02 model parameters 
function [ Rm, Jm, Kt, Eff_m, Km, Kg, Eff_g, M, r_mp, Beq ] = calc_IP01_2_parameters( CART_TYPE, IP02_LOAD_TYPE, UPM_TYPE )
global K_IN2M K_D2R K_RDPS2RPM K_OZ2N
% Set these variables (used in Simulink Diagrams)
global VMAX_UPM IMAX_UPM ALPHA_MAX ALPHA_MIN
% Motor Armature Resistance (Ohm)
Rm = 2.6;
% Motor Armature Inductance (H)
Lm = 180e-6;
% Motor Torque Constant (N.m/A)
Kt = 1.088 * K_OZ2N * K_IN2M; % = .00767
% Motor ElectroMechanical Efficiency [ = Tm * w / ( Vm * Im ) ]
Eff_m = 1;
% Motor Back-EMF Constant (V.s/rad)
Km = 0.804e-3 * K_RDPS2RPM; % = .00767
% Rotor Inertia (kg.m^2)
Jm = 5.523e-5 * K_OZ2N * K_IN2M; % = 3.9e-7
% IP01 Cart Mass, with 2 cable connectors (kg)
Mc1 = 0.52;
% IP02 Cart Mass, with 3 cable connectors (kg)
Mc2 = 0.57;
% Cart Weight Mass (kg)
Mw = 0.37;
% Planetary Gearbox (a.k.a. Internal) Gear Ratio
Kg = 3.71;
% Planetary Gearbox Efficiency
Eff_g = 1;
% Cart Motor Pinion number of teeth
N_mp = 24;
% Motor Pinion Radius (m)
r_mp = 0.5 / 2 * K_IN2M;  %  = 6.35e-3
% Cart Position Pinion number of teeth
N_pp = 56;
% Position Pinion Radius (m)
r_pp = 1.167 /2 * K_IN2M; %  = 14.8e-3
% Rack Pitch (m/teeth)
Pr = 1e-2 / 6.01; % = 0.0017
% Cart Travel (m)
Tc = 0.814;
% Set the following calibration constants/parameters: K_EC, K_EP, K_PC, K_PP, M, Beq
% also checks the values of: ALPHA_MAX, ALPHA_MIN
if strcmp( CART_TYPE, 'IP01')
    % Inverted Pendulum Mechanical Range:
    % Pendulum Angle Maximum Mechanical Limit (deg)
    Alpha_Max_Mech_Lim = 32;
    % Pendulum Angle Minimum Mechanical Limit (deg)
    Alpha_Min_Mech_Lim = - Alpha_Max_Mech_Lim;
    % Override the "soft" Watchdog Safety Limits
    if ( ALPHA_MAX > Alpha_Max_Mech_Lim )
        ALPHA_MAX = Alpha_Max_Mech_Lim;
    end
    if ( ALPHA_MIN < Alpha_Min_Mech_Lim )
        ALPHA_MIN = Alpha_Min_Mech_Lim;
    end
    % Cart Potentiometer Sensitivity (m/V)
    global K_PC K_PP
    % the cart position potentiometer goes from -5V to +5V in 10 turns
    K_PC = 2 * pi * r_pp * 10 / 10; % = 0.0931
    % Pendulum Potentiometer Sensitivity (rad/V)
    % the pendulum potentiometer has a range of 4.5V over (2*Alpha_Max_Mech_Lim) degrees
    % K_PP is negative, since CCW is the positive sense of rotation
    K_PP = - 2 * Alpha_Max_Mech_Lim * K_D2R / 4.5; % = - 0.2482
    % the IP01 has no encoders
    K_EC = 0; K_EP = 0;
    M = Mc1;
    Beq = 0.9;
elseif strcmp ( CART_TYPE, 'IP02')
    % the IP02 has 2 quadrature encoders
    global K_EC K_EP
    % Cart Encoder Resolution (m/count)
    K_EC = Pr * N_pp / ( 4 * 1024 ); % = 22.7485 um/count
    % Pendulum Encoder Resolution (rad/count)
    % K_EP is positive, since CCW is the positive sense of rotation
    K_EP = 2 * pi / ( 4 * 1024 ); % = 0.0015
    % the IP02 has no potentiometers
    K_PC = 0; K_PP = 0;
    if strcmp( IP02_LOAD_TYPE, 'NO_LOAD')
        M = Mc2;
        Beq = 4.3;
    elseif strcmp ( IP02_LOAD_TYPE, 'WEIGHT')
        M = Mc2 + Mw;
        Beq = 5.4;
    else 
        error( 'Error: Set the IP02 load configuration.' )
    end
else 
    error( 'Error: Set the type of motorized cart.' )
end
% Set the UPM Maximum Output Voltage (V) and Output Current (A)
% rm: for low values of K_CABLE, VMAX_UPM is limited by VMAX_DAC
if  strcmp( UPM_TYPE, 'UPM_2405' )
    VMAX_UPM = 22;
    IMAX_UPM = 5;
elseif ( strcmp( UPM_TYPE, 'UPM_1503' ) | strcmp( UPM_TYPE, 'UPM_1503x2' ) ) 
    VMAX_UPM = 13;
    IMAX_UPM = 3;
elseif ( strcmp( UPM_TYPE, 'Q3' ) )
     IMAX_UPM = 1.6;
     VMAX_UPM = 2.6 * IMAX_UPM; % Multiply times resistance of SRV02
else
    error( 'Error: Set the UPM type.' )
end
% end of 'calc_IP01_2_parameters( )'


%% Calculate Useful Conversion Factors w.r.t. Units
function calc_conversion_constants ()
global K_D2R K_IN2M K_RDPS2RPM K_OZ2N
% from radians to degrees
K_R2D = 180 / pi;
% from degrees to radians
K_D2R = 1 / K_R2D;
% from Inch to Meter
K_IN2M = 0.0254;
% from Meter to Inch
K_M2IN = 1 / K_IN2M;
% from rad/s to RPM
K_RDPS2RPM = 60 / ( 2 * pi );
% from RPM to rad/s
K_RPM2RDPS = 1 / K_RDPS2RPM;
% from oz-force to N
K_OZ2N = 0.2780139;
% from N to oz-force
K_N2OZ = 1 / K_OZ2N;
% end of 'calc_conversion_constants( )'
