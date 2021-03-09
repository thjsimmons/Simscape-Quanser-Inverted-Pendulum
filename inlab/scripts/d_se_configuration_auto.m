% D_SE_CONFIGURATION_AUTO
% 
% Self-Erecting Single Inverted Pendulum (SESIP) experiment.
%
% D_SE_CONFIGURATION_AUTO automatically initializes 
% the self-erecting setpoint and mode-switching strategy parameters
% for both long (i.e. 24-inch) and medium (i.e. 12-inch) single pendulums. 
%
% Copyright (C) 2003 Quanser Consulting Inc.
% Quanser Consulting Inc.

%%% Self-Erecting Setpoint Parameters
if strcmp( PEND_TYPE, 'LONG_24IN' )
    if ( strcmp( UPM_TYPE, 'UPM_1503' ) || strcmp( UPM_TYPE, 'UPM_2405' ) )                   
        % pendulum "down" angle proportional gain (m/rad)
        Kp_p = 9.0;
        % cart position setpoint steady-state range (m)
        XCD_SS_LIM = 3e-2;
        % cart setpoint kick-start gain (m.s)
        K_XCD_KICK = 3e-2;
        % time constant of the kick-start first-order derivative filter  (s)
        tau_ks = 0.05;
        % additional gain ratio for the initial cart setpoint amplification
        K_ADD_START = 4.9;
        % duration of the initial cart setpoint amplification (s)
        T_START_DUR = 2.8;
    elseif ( strcmp( UPM_TYPE, 'Q3') )
        % pendulum "down" angle proportional gain (m/rad)
        Kp_p = 9.0;
        % cart position setpoint steady-state range (m)
        XCD_SS_LIM = 40e-3;
        % cart setpoint kick-start gain (m.s)
        K_XCD_KICK = 3e-2;
        % time constant of the kick-start first-order derivative filter  (s)
        tau_ks = 0.05;
        % additional gain ratio for the initial cart setpoint amplification
        K_ADD_START = 4.9;
        % duration of the initial cart setpoint amplification (s)
        T_START_DUR = 3.8;
    else
        error( 'Error: Set the UPM type.' );
    end            
elseif strcmp( PEND_TYPE, 'MEDIUM_12IN' )
    if ( strcmp( UPM_TYPE, 'UPM_1503' ) || strcmp( UPM_TYPE, 'UPM_2405' ) )                   
        % pendulum "down" angle proportional gain (m/rad)
        Kp_p = 5.5;
        % cart position setpoint steady-state range (m)
        XCD_SS_LIM = 18e-3; % 14e-3
        % cart setpoint kick start gain (m.s)
        K_XCD_KICK = 4e-3;
        % first-order derivative filter time constant (s)
        tau_ks = 0.05;
        % additional gain ratio for the initial cart setpoint amplification
        K_ADD_START = 2.2;
        % duration of the initial cart setpoint amplification (s)
        T_START_DUR = 2.3;
    elseif ( strcmp( UPM_TYPE, 'Q3') )
         % pendulum "down" angle proportional gain (m/rad)
        Kp_p = 5.5;
        % cart position setpoint steady-state range (m)
        XCD_SS_LIM = 25e-3;
        % cart setpoint kick start gain (m.s)
        K_XCD_KICK = 4e-3;
        % first-order derivative filter time constant (s)
        tau_ks = 0.05;
        % additional gain ratio for the initial cart setpoint amplification
        K_ADD_START = 2.2;
        % duration of the initial cart setpoint amplification (s)
        T_START_DUR = 3.3;
    else
        error( 'Error: Set the UPM type.' );
    end    
else 
    error( 'Error: Set the type of pendulum.' )
end

% cart setpoint slew rate range (m/s)
XCD_SLEW_RATE = 0.7; %0.8; %1;

%%% Mode-Switching Parameters
% linear cart position range (m)
CATCH_XC_LIM = 20e-2;
% linear cart position range decrement (m)
% resulting release (a.k.a. "let-go") condition: CATCH_XC_LIM - DECR_XC_LIM
DECR_XC_LIM = 10e-2;
% time constant of the first-order delay on xc (s)
tau_xc = 2.5;
% pendulum angular range (deg)
CATCH_ALPHA_UP_LIM = 15;
% pendulum angular range decrement (deg)
% resulting release (a.k.a. "let-go") condition: CATCH_ALPHA_UP_LIM - DECR_ALPHA_UP_LIM
DECR_ALPHA_UP_LIM = 13.5;
% pendulum angular velocity range (deg/s)
CATCH_ALPHA_DOT_LIM = 150;
% decrease rate on the AND gate output (s^-1)
AND_DECR_RATE = -1;
% time constant of the first-order delay on alpha_up (s)
tau_au = 0.5;
