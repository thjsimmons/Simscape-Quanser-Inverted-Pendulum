
%======================================================================
% Author: Ted Simmons
% Github: github.com/thjsimmons/Simscape-Quanser-Inverted-Pendulum
% Date: May 1, 2020
%======================================================================

% Script populates workspace with variables used by QIP.slx
% User can enter controller and other parameters below:

clear;
addpath('setup');

%=================== User's Choice Parameters ==========================
simulationStopTime = 10;
PEND_TYPE = "LONG_24IN";
impulse_data = [50, 0.005, 1];
friction_data = [1.2, 0.01 0 0];
controllerTF = zpk([-10, -63], [-0.1, -60], 750);
[ctf_num, ctf_den] = tfdata(controllerTF, 'v');
%=================== Manufacturer's Parameters ==========================
% Type of motorized cart: set to 'IP01', 'IP02'
CART_TYPE = 'IP02';
IP02_LOAD_TYPE = 'NO_LOAD';
UPM_TYPE = 'UPM_1503';
IMAX_UPM = 3;
% Digital-to-Analog Maximum Voltage (V); for MultiQ cards set to 10
VMAX_DAC = 10;
[ Rm, Jm, Kt, Eff_m, Km, Kg, Eff_g, Mc, r_mp, Beq ] = ...
    setup_ip01_2_configuration( CART_TYPE, IP02_LOAD_TYPE, UPM_TYPE );
% Lumped Mass of the Cart System (accounting for the rotor inertia)
Mc = Mc + Eff_g * Kg^2 * Jm / r_mp^2;
% Set the model parameters for the single pendulum according
% to the user-defined system configuration.
[ g, Mp, Lp, lp, Ip, Bp ] = setup_sp_configuration( PEND_TYPE );

%======================================================================
