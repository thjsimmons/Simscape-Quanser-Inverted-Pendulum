% D_IP01_2_ACTUATOR_DYNAMICS
%
% Adds the actuator dynamics based on the type of power amplifier being
% used, i.e. voltage-controlled (UPM) or current-controlled (Q3).
% 
% Inputs:
% A, B:         State-space matrices relative to Fc.
% UPM_TYPE:     Type of amplifier (e.g. UPM or Q3)
%
% Copyright (C) 2008 Quanser Consulting Inc.
% Quanser Consulting Inc.
%
function [ An, Bn ] = d_ip01_2_actuator_dynamics( A, B, UPM_TYPE, Rm, Kt, Eff_m, Km, Kg, Eff_g, Mc, r_mp )
%
% Voltage-based amplifier: need to incorporate back-emf element.
if ( strcmp( UPM_TYPE, 'UPM_1503' ) || strcmp( UPM_TYPE, 'UPM_2405' ) )
    Bn = Eff_g*Kg*Eff_m*Kt/r_mp/Rm*B;
    An = A;
    An(3,3) = A(3,3) - B(3)*Eff_g*Kg^2*Eff_m*Kt*Km/r_mp^2/Rm;
    An(4,3) = A(4,3) - B(4)*Eff_g*Kg^2*Eff_m*Kt*Km/r_mp^2/Rm;
elseif ( strcmp( UPM_TYPE, 'Q3') )
    % Current-controlled: Fc directly proportional to current Im.
    An = A;
    Bn = Eff_g*Kg*Eff_m*Kt/r_mp*B;
else
    error( 'Error: Set the UPM type.' );
end
