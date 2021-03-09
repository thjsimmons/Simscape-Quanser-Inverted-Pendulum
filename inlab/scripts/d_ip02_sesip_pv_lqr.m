% D_IP02_SESIP_PV_LQR
%
% Control Lab: Design of both PV Controller and LQR 
% for the SESIP-plus-IP02 system:
% PV control is to track the cart position setpoint and self-erect the pendulum.
% LQR is to maintain the pendulum in the upright (i.e. inverted) position.
%
% D_IP02_SESIP_PV_LQR returns the corresponding controller feedback gains: Kp, Kv, and K
%
% Copyright (C) 2003 Quanser Consulting Inc.
% Quanser Consulting Inc.


function [ Kp, Kv, K ] = d_ip01_2_sesip_pv_lqr( IP02_NUM, IP02_DEN, A, B, C, D, PO, tp, Q, R, UPM_TYPE )
% SYS_ANALYSIS = 'YES';
SYS_ANALYSIS = 'NO';

% I) PV controller design
% open-loop IP02 system alone
IP02_OL_SYS = tf( IP02_NUM, IP02_DEN );
% calculate the required PV controller gains
% meeting the desired specifications
% i) spec #1: maximum Percent Overshoot (PO)
if ( PO > 0 )
    zeta_min = abs( log( PO / 100 ) ) / sqrt( pi^2 + log( PO / 100)^2 );
    zeta = zeta_min;
else
    error( 'Error: Set Percentage Overshoot.' )
end
% ii) spec #2: tp
wn = pi / ( tp * sqrt( 1 - zeta^2 ) );
% iii) using the control law: Vm = Kp * ( xc_des - xc ) - Kv * xc_dot
% PV controller gain settings (see Maple worksheet):
Kp = ( wn^2 * IP02_DEN(1) - IP02_DEN(3) ) / IP02_NUM(1);
Kv = ( 2 * zeta * wn * IP02_DEN(1) - IP02_DEN(2) ) / IP02_NUM(1);

% PV closed-loop system
IP02_PV_CL_SYS = feedback( Kp * feedback( IP02_OL_SYS, tf( [ Kv 0 ], [ 1 ] ) ), 1 );

% II) LQR design
% Open-Loop SIP-plus-IP02 system
IP02_SIP_OL_SYS = ss( A, B, C, D, 'statename', { 'xc' 'alpha_u' 'xc_dot' 'alpha_f_dot' }, 'inputname', 'Vm', 'outputname', { 'xc' 'alpha_u' 'xc_dot' 'alpha_f_dot' } );
C = eye( 4 );
D = zeros( 4, 1 );

% calculate the LQR gain vector, K
[ K, S, EIG_CL ] = lqr( A, B, Q, R );

% Closed-Loop State-Space Model
A_CL = A - B * K;
B_CL = B * K( 1 );  % corresponds to the first state: xc
C_CL = eye(4);
D_CL = zeros( 4, 1 );
IP02_SIP_LQR_CL_SYS = ss( A_CL, B_CL, C_CL, D_CL, 'statename', { 'xc' 'alpha_u' 'xc_dot' 'alpha_f_dot' }, 'inputname', 'Vm', 'outputname', { 'xc' 'alpha_u' 'xc_dot' 'alpha_f_dot' } );

% carry out some additional system analysis
if strcmp( SYS_ANALYSIS, 'YES' )
    % normalization of the IP02 transfer function
    IP02_NUM = IP02_NUM / IP02_DEN(1);
    IP02_DEN = IP02_DEN / IP02_DEN(1);
    % print the OLTF
    printsys( IP02_NUM, IP02_DEN, 's' )
    % Closed-Loop poles, damping, and natural frequency
    damp( IP02_PV_CL_SYS )
    % Simulated Unit Step Response
    figure ( 1 )
    step( IP02_PV_CL_SYS )
    if ( strcmp( UPM_TYPE, 'UPM_1503' ) || strcmp( UPM_TYPE, 'UPM_2405' ) )
        set( 1, 'name', strcat( 'IP02 with PV Controller: Kp_c = ', num2str( Kp ), ' V/m, Kv_c = ', num2str( Kv ), ' V.s/m') )
    elseif ( strcmp( UPM_TYPE, 'Q3') )
        set( 1, 'name', strcat( 'IP02 with PV Controller: Kp_c = ', num2str( Kp ), ' A/m, Kv_c = ', num2str( Kv ), ' A.s/m') )
    else
        error( 'Error: Set the UPM type.' );
    end
    %
    grid on
    % SIP-plus-IP02 system
    ULABELS = [ 'V_m' ];
    XLABELS = [ 'xc alpha_u xc_dot alpha_f_dot' ];
    YLABELS = [ 'xc alpha_u xc_dot alpha_f_dot' ];
    % print the Open-Loop State-Space Matrices
    disp( 'Open-Loop System' )
    printsys( A, B, C, D, ULABELS, YLABELS, XLABELS )
    % open-loop poles
    OL_poles = eig( A )
    % print the Closed-Loop State-Space Matrices
    disp( 'Closed-Loop System' )
    printsys( A_CL, B_CL, C_CL, D_CL, ULABELS, YLABELS, XLABELS )
    % Closed-Loop poles, damping, and natural frequency
    damp( IP02_SIP_LQR_CL_SYS )
end
% end of function 'd_ip02_sesip_pv_lqr( )'