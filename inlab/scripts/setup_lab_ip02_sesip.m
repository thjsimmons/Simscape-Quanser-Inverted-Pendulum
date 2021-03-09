% SETUP_LAB_IP02_SESIP
%
% IP02 Self-Erecting Single Inverted Pendulum (SESIP) Control Lab:
% Design of a cart position setpoint to self-erect the pendulum:
%   PV position control
% Design of a LQR position controller to maintain the inverted pendulum balanced.
% Design of a switching mode strategy between the two controllers.
% 
% SETUP_LAB_IP02_SESIP sets the SESIP-plus-IP02 system's 
% model parameters accordingly to the user-defined configuration.
% SETUP_LAB_IP02_SESIP can also set the controllers' parameters, 
% accordingly to the user-defined desired specifications.
%
% Copyright (C) 2003 Quanser Consulting Inc.
% Quanser Consulting Inc.

%clear all
IC_ALPHA0 = 0;
% ##### USER-DEFINED SESIP-plus-IP02 CONFIGURATION #####
% Type of motorized cart: set to 'IP02'
CART_TYPE = 'IP02';
% if IP02: Type of Cart Load: set to 'NO_WEIGHT', 'WEIGHT'
%IP02_WEIGHT_TYPE = 'NO_WEIGHT';
IP02_WEIGHT_TYPE = 'WEIGHT';
% Type of single pendulum: set to 'LONG_24IN', 'MEDIUM_12IN'
% PEND_TYPE = 'MEDIUM_12IN'; 
%PEND_TYPE = 'LONG_24IN'; 
% Turn on or off the safety watchdog on the cart position: set it to 1 , or 0 
X_LIM_ENABLE = 1;       % safety watchdog turned ON
%X_LIM_ENABLE = 0;      % safety watchdog turned OFF
% Safety Limits on the cart displacement (m)
X_MAX = 0.35;            % cart displacement maximum safety position (m)
X_MIN = - X_MAX;        % cart displacement minimum safety position (m)
% Cable Gain used: set to 1
K_CABLE = 1;
% Universal Power Module (UPM) Type: set to 'UPM_1503', 'UPM_2405', or 'UPM_1503x2'
% UPM_TYPE = 'UPM_1503';
UPM_TYPE = 'UPM_2405';
% UPM_TYPE = 'UPM_1503';
% Digital-to-Analog Maximum Voltage (V); for MultiQ cards set to 10
VMAX_DAC = 10;
% ##### END OF USER-DEFINED SESIP-plus-IP02 CONFIGURATION #####


% ##### USER-DEFINED CONTROLLER DESIGN #####
% Type of Controller: set it to 'PV_LQR_AUTO', 'MANUAL'  
CONTROLLER_TYPE = 'PV_LQR_AUTO';    % PV and LQR controller design: automatic mode
%CONTROLLER_TYPE = 'MANUAL';    % controller design: manual mode
% PV Controller Design Specifications
PO = 5;       % spec #1: maximum percent overshoot (%)
tp = 0.25;     % spec #2: peak time (s)
% Cart Encoder Resolution
global K_EC K_EP
% Specifications of a second-order low-pass filter
wcf = 2 * pi * 5;  % filter cutting frequency
zetaf = 0.9;        % filter damping ratio
% ##### END OF USER-DEFINED CONTROLLER DESIGN #####

% variables required in the Simulink diagrams
global VMAX_UPM IMAX_UPM

if strcmp ( CART_TYPE, 'IP01')
    error( 'Error: The self-erecting single inverted pendulum experiment is not possible with the IP01 cart.' )
end

% Set the model parameters accordingly to the user-defined IP02 system configuration.
% These parameters are used for model representation and controller design.
[ Rm, Jm, Kt, Eff_m, Km, Kg, Eff_g, Mc, r_mp, Beq ] = setup_ip01_2_configuration( CART_TYPE, IP02_WEIGHT_TYPE, UPM_TYPE );

% Lumped Mass of the Cart System (accounting for the rotor inertia)
Mc = Mc + Eff_g * Kg^2 * Jm / r_mp^2;

% Set the model parameters for the single pendulum accordingly to the user-defined configuration.
[ g, Mp, Lp, lp, Ip, Bp ] = setup_sp_configuration( PEND_TYPE );
%
% IP02 Open Loop Transfer Function (see Maple worksheet)
if ( strcmp( UPM_TYPE, 'UPM_1503' ) || strcmp( UPM_TYPE, 'UPM_2405' ) )
    % TF of Motor Voltage Input (Vm) to Cart Position (xc).
    IP02_NUM(1) = Eff_g * Kg * Eff_m * Kt * r_mp;
    IP02_DEN(1) = Mc * Rm * r_mp^2 + Rm * Eff_g * Kg^2 * Jm;
    IP02_DEN(2) = Beq * Rm * r_mp^2 + Eff_g * Kg^2 * Eff_m * Kt * Km;
    IP02_DEN(3) = 0;
elseif ( strcmp( UPM_TYPE, 'Q3') )
    % TF of Motor Voltage Input (Vm) to Cart Position (xc).
    IP02_NUM(1) = Eff_g * Kg * Eff_m * Kt * r_mp;
    IP02_DEN(1) = Mc * r_mp^2 + Eff_g * Kg^2 * Jm;
    IP02_DEN(2) = Beq * r_mp^2;
    IP02_DEN(3) = 0;
else
    error( 'Error: Set the UPM type.' );
end     
%
% For the State Vector: X = [ xc; alpha; xc_dot; alpha_dot ]
% Initialization of the State-Space Representation of the Open-Loop System
% Call the following Maple-generated file to initialize the State-Space Matrices: A, B, C, and D
% the SIP model used for LQR tuning
SIP_ABCD_eqns;
% Add actuator dynamics
[ An, Bn ] = d_ip01_2_actuator_dynamics( A, B, UPM_TYPE, Rm, Kt, Eff_m, Km, Kg, Eff_g, Mc, r_mp );
%
%
if strcmp ( CONTROLLER_TYPE, 'PV_LQR_AUTO' )
    % LQR Controller Design Specifications
    if strcmp( IP02_WEIGHT_TYPE, 'WEIGHT' )
        if strcmp( PEND_TYPE, 'LONG_24IN' )
            if ( strcmp( UPM_TYPE, 'UPM_1503' ) || strcmp( UPM_TYPE, 'UPM_2405' ) )                   
                Q = diag( [ 0.75 4 0 0 ] );
                R(1,1) = [ 0.0003 ];
            elseif ( strcmp( UPM_TYPE, 'Q3') )
               Q = diag( [ 0.75 4 0 0 ] );
               R(1,1) = [ 0.002 ];
            else
                error( 'Error: Set the UPM type.' );
            end                
        elseif strcmp( PEND_TYPE, 'MEDIUM_12IN' )
            if ( strcmp( UPM_TYPE, 'UPM_1503' ) || strcmp( UPM_TYPE, 'UPM_2405' ) )                   
                Q = diag( [ 1 6 0 0 ] );
                R(1,1) = [ 0.0004 ];    
            elseif ( strcmp( UPM_TYPE, 'Q3') )
                Q = diag( [ 0.5 4 0 0 ] );
                R(1,1) = [ 0.01 ];
            else
                error( 'Error: Set the UPM type.' );
            end            
        else
            error( 'Error: Set the type of pendulum.' )
        end
    else
        error( 'Error: Tune the LQR for your configuration.' )
    end
    % Automatically calculate the PV and LQR controller gains
    [ Kp_c, Kv_c, K ] = d_ip02_sesip_pv_lqr( IP02_NUM, IP02_DEN, An, Bn, C, D, PO, tp, Q, R, UPM_TYPE );
    % script to initializes the swing-up and mode control parameters
    d_se_configuration_auto
    % Display the calculated gains    
    disp( ' ' )
    if ( strcmp( UPM_TYPE, 'UPM_1503' ) || strcmp( UPM_TYPE, 'UPM_2405' ) )                   
        disp( 'Calculated cart PV controller gains: ' )
        disp( [ 'Kp_c = ' num2str( Kp_c ) ' V/m' ] )
        disp( [ 'Kv_c = ' num2str( Kv_c ) ' V.s/m' ] )
        disp( 'Calculated LQR controller gain elements: ' )
        disp( [ 'K(1) = ' num2str( K(1) ) ' V/m' ] )
        disp( [ 'K(2) = ' num2str( K(2) ) ' V/rad' ] )
        disp( [ 'K(3) = ' num2str( K(3) ) ' V.s/m' ] )
        disp( [ 'K(4) = ' num2str( K(4) ) ' V.s/rad' ] )
    elseif ( strcmp( UPM_TYPE, 'Q3') )
        disp( 'Calculated cart PV controller gains: ' )
        disp( [ 'Kp_c = ' num2str( Kp_c ) ' A/m' ] )
        disp( [ 'Kv_c = ' num2str( Kv_c ) ' A.s/m' ] )
        disp( 'Calculated LQR controller gain elements: ' )
        disp( [ 'K(1) = ' num2str( K(1) ) ' A/m' ] )
        disp( [ 'K(2) = ' num2str( K(2) ) ' A/rad' ] )
        disp( [ 'K(3) = ' num2str( K(3) ) ' A.s/m' ] )
        disp( [ 'K(4) = ' num2str( K(4) ) ' A.s/rad' ] )
    else
        error( 'Error: Set the UPM type.' );
    end   
    
elseif strcmp ( CONTROLLER_TYPE, 'MANUAL' )
    Kp_c = 0;
    Kv_c = 0;
    K = [ 0 0 0 0 ];
    d_se_configuration_manual
    disp( ' ' )
    disp( 'STATUS: manual mode' ) 
    disp( 'The model parameters of your SESIP and IP02 system have been set.' )
    disp( 'You can now design your position controller(s).' )
    disp( ' ' )
else
    error( 'Error: Please set the type of controller that you wish to implement.' )
end


