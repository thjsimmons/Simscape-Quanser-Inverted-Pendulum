% Matlab equation file: "SIP_ABCD_eqns.m"
% Open-Loop State-Space Matrices: A, B, C, and D
% for the Quanser Single Inverted Pendulum Experiment.

A( 1, 1 ) = 0;
A( 1, 2 ) = 0;
A( 1, 3 ) = 1;
A( 1, 4 ) = 0;
A( 2, 1 ) = 0;
A( 2, 2 ) = 0;
A( 2, 3 ) = 0;
A( 2, 4 ) = 1;
A( 3, 1 ) = 0;
A( 3, 2 ) = Mp^2*lp^2*g/(Ip*Mc+Mc*Mp*lp^2+Mp*Ip);
A( 3, 3 ) = -Beq*(Ip+Mp*lp^2)/(Ip*Mc+Mc*Mp*lp^2+Mp*Ip);
A( 3, 4 ) = -Mp*lp*Bp/(Ip*Mc+Mc*Mp*lp^2+Mp*Ip);
A( 4, 1 ) = 0;
A( 4, 2 ) = Mp*g*lp*(Mc+Mp)/(Ip*Mc+Mc*Mp*lp^2+Mp*Ip);
A( 4, 3 ) = -Beq*Mp*lp/(Ip*Mc+Mc*Mp*lp^2+Mp*Ip);
A( 4, 4 ) = -Bp*(Mc+Mp)/(Ip*Mc+Mc*Mp*lp^2+Mp*Ip);

B( 1, 1 ) = 0;
B( 2, 1 ) = 0;
B( 3, 1 ) = (Ip+Mp*lp^2)/(Ip*Mc+Mc*Mp*lp^2+Mp*Ip);
B( 4, 1 ) = Mp*lp/(Ip*Mc+Mc*Mp*lp^2+Mp*Ip);

C( 1, 1 ) = 1;
C( 1, 2 ) = 0;
C( 1, 3 ) = 0;
C( 1, 4 ) = 0;
C( 2, 1 ) = 0;
C( 2, 2 ) = 1;
C( 2, 3 ) = 0;
C( 2, 4 ) = 0;
C( 3, 1 ) = 0;
C( 3, 2 ) = 0;
C( 3, 3 ) = 1;
C( 3, 4 ) = 0;
C( 4, 1 ) = 0;
C( 4, 2 ) = 0;
C( 4, 3 ) = 0;
C( 4, 4 ) = 1;

D( 1, 1 ) = 0;
D( 2, 1 ) = 0;
D( 3, 1 ) = 0;
D( 4, 1 ) = 0;
