%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16592 $
%$Date: 2020-09-17 01:32:43 +0800 (Thu, 17 Sep 2020) $
%$Author: chavarri $
%$Id: get_rep_fric.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/get_rep_fric.m $
%
%get_rep_fric does this and that
%
%Cf_rep = get_rep_fric(input,x,h)
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%170404
%   -V. Added the header because Liselot does not follow the protocol :D
%

function Cf_rep = get_rep_fric(input,x,h)
% Compute the coefficient 
% The computation is performed in different parts for the main channel and
% flood planes seperately.
%
% x should be a node identifier, and h a vector with h(1,x) the location at x!


%% Get cross_sectional_area pars
[Af, Af1, Af2, Af3] = get_cross_section(input,x,h,'Af');
[P, P1, P2, P3] = get_cross_section(input,x,h,'P');

% Contribution to parameters for each of the subparts
C1 = sqrt(input.mdv.g/input.frc.Cf(1,1));
C2 = sqrt(input.mdv.g/input.frc.Cf(2,1));
C3 = sqrt(input.mdv.g/input.frc.Cf(3,1));
C_v = repmat([C1;C2;C3],1,input.mdv.nx);
%R = Af/P;

Af_v = [Af1;Af2;Af3];
P_v = [P1;P2;P3];
R_v = Af_v./P_v;
R_v(isnan(R_v)==1) = 0;
R = sum(R_v,1);
C_rep = 1./(Af.*sqrt(R)).*sum(C_v.*Af_v.*sqrt(R_v),1);
Cf_rep = input.mdv.g./C_rep.^2;
end