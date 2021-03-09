%======================================================================
% Author: Ted Simmons
% Github: https://github.com/thjsimmons/
% Date: May 1, 2020
%======================================================================
function [G_v2a, G_v2a_comp] = ROOT_LOCUS(controller)

    
    PENDULUM_TYPE = 'LONG_24IN';  'MEDIUM_12IN';
    
  
    % Type of motorized cart: set to 'IP01', 'IP02'
    CART_TYPE = 'IP02';
    IP02_LOAD_TYPE = 'NO_LOAD';
    UPM_TYPE = 'UPM_1503';
    IMAX_UPM = 3;
    % Digital-to-Analog Maximum Voltage (V); for MultiQ cards set to 10
    VMAX_DAC = 10;
    % Physical parameters
    [ Rm, Jm, Kt, Eff_m, Km, Kg, Eff_g, Mc, r_mp, Beq ] = setup_ip01_2_configuration( CART_TYPE, IP02_LOAD_TYPE, UPM_TYPE );
    % Lumped Mass of the Cart System (accounting for the rotor inertia)
    Mc = Mc + Eff_g * Kg^2 * Jm / r_mp^2;
    % Set the model parameters for the single pendulum accordingly to the user-defined system configuration.
    [ g, Mp, Lp, lp, Ip, Bp ] = setup_sp_configuration( PENDULUM_TYPE );

    % State Space equations
    Keq = 0.0001;
    Av( 1, 1 ) = 0;
    Av( 1, 2 ) = 0;
    Av( 1, 3 ) = 1;
    Av( 1, 4 ) = 0;
    Av( 2, 1 ) = 0;
    Av( 2, 2 ) = 0;
    Av( 2, 3 ) = 0;
    Av( 2, 4 ) = 1;
    Av( 3, 2 ) = Mp^2*lp^2*g/(Mc*Ip+Mc*Mp*lp^2+Mp*Ip);
    Av( 3, 3 ) = -(Ip*Eff_g*Kg^2*Eff_m*Kt*Km + Ip*Beq*Rm*r_mp^2 + Mp*lp^2*Eff_g*Kg^2*Eff_m*Kt*Km + Mp*lp^2*Beq*Rm*r_mp^2)/Rm/r_mp^2/(Mc*Ip + Mc*Mp*lp^2+Mp*Ip);
    Av( 3, 1 ) = 0; %Keq/Beq * Av(3,3);
    Av( 3, 4 ) = -Mp*lp*Bp/(Mc*Ip+Mc*Mp*lp^2+Mp*Ip);
    Av( 4, 2 ) = Mp*g*lp*(Mc+Mp)/(Mc*Ip+Mc*Mp*lp^2+Mp*Ip);
    Av( 4, 3 ) = -Mp*lp*(Eff_g*Kg^2*Eff_m*Kt*Km+Beq*Rm*r_mp^2)/Rm/r_mp^2/(Mc*Ip+Mc*Mp*lp^2+Mp*Ip);
    Av( 4, 1 ) = 0; %Keq/Beq * Av(4,3);
    Av( 4, 4 ) = -Bp*(Mc+Mp)/(Mc*Ip+Mc*Mp*lp^2+Mp*Ip);
    Bv( 1, 1 ) = 0;
    Bv( 2, 1 ) = 0;
    Bv( 3, 1 ) = Eff_g*Kg*Eff_m*Kt/r_mp*(Ip+Mp*lp^2)/Rm/(Mc*Ip+Mc*Mp*lp^2+Mp*Ip);
    Bv( 4, 1 ) = Eff_g*Kg*Eff_m*Kt/r_mp*Mp*lp/Rm/(Mc*Ip+Mc*Mp*lp^2+Mp*Ip);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%% CONVERTING FROM STATE-SPACE TO TF %%%%%%%%%%%%%%%%%%%%%%%%%%%
    C_v2x = [1 0 0 0];
    C_v2a = [0 1 0 0];
    [N1, D1] = ss2tf(Av,Bv,C_v2x, 0);
    G_v2x = tf(N1, D1); 
    [N2, D2] = ss2tf(Av,Bv,C_v2a, 0);
    G_v2a = tf(N2, D2); 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   
    figure(1);
    rlocus(G_v2a);
    title("Voltage-Angle Root Locus");

   
    figure(2);
    rlocus(controller * G_v2a);
    title("Compensated Voltage-Angle Root Locus");
    G_v2a_comp = controller * G_v2a;
    

end
