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
%$Id: dv_bouss_coef.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/dv_bouss_coef.m $
%
%dv_bouss_coef does this and that
%
%[a1, a2] = dv_bouss_coef(input,x,h)
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

function [a1, a2] = dv_bouss_coef(input,x,h)
% Compute the coefficient resulting from the derivative of the cross
% section;
% dAf/dx = a1*(dh/dx) + a2(h)

% The computation is performed in different parts for the main channel and
% flood planes seperately.
%
%
% x should be a node identifier, and h a vector with h(1,x) the location at x!

%% Replace by default values somehow
if nargin <2 %|| isnan(x)==1
    x = 1;
elseif isnan(x)==1
    x = 1:numel(hh);
end

%% Check whether h is a vector or a coefficient
%{
if numel(hh)==1
    h = hh;
else
    h = hh(1,x);
end
%}

%% Get derivative of cross_sectional_area
[~, ~, AI_a1, AI_a2, AII_a1, AII_a2, AIII_a1, AIII_a2] = dv_cross_section(input,x,h,'Af');
[~, ~, PI_a1, PI_a2, PII_a1, PII_a2, PIII_a1, PIII_a2] = dv_cross_section(input,x,h,'P');
[Af, Af1, Af2, Af3] = get_cross_section(input,x,h,'Af');
[~, P1, P2, P3] = get_cross_section(input,x,h,'P');


%% Contribution to parameters for each of the subparts
C1 = sqrt(input.mdv.g/input.frc.Cf(1,1));
C2 = sqrt(input.mdv.g/input.frc.Cf(2,1));
C3 = sqrt(input.mdv.g/input.frc.Cf(3,1));
C_v = [C1,C2,C3]; %Chezy values
Af_v = [Af1,Af2,Af3];
P_v = [P1,P2,P3];
R_v = Af_v./P_v;
R_v(isnan(R_v)) = 0;

Aa1_v = [AI_a1, AII_a1, AIII_a1];
Aa2_v = [AI_a2, AII_a2, AIII_a2];
Pa1_v = [PI_a1, PII_a1, PIII_a1];
Pa2_v = [PI_a2, PII_a2, PIII_a2];


a1_line1 = (Af/sum(C_v.*Af_v.*sqrt(R_v))^2)*sum(C_v.^2.*(2.*R_v.*Aa1_v - R_v.^2.*Pa1_v));
a2_line1 = (Af/sum(C_v.*Af_v.*sqrt(R_v))^2)*sum(C_v.^2.*(2.*R_v.*Aa2_v - R_v.^2.*Pa2_v));
a1_miss1 = sum(C_v.^2.*Af_v.*R_v)/sum(C_v.*Af_v.*sqrt(R_v))^2*sum(Aa1_v);
a2_miss1 = sum(C_v.^2.*Af_v.*R_v)/sum(C_v.*Af_v.*sqrt(R_v))^2*sum(Aa2_v);
a1_line2 = 2*(sum(C_v.^2.*Af_v.*R_v)*Af/sum(C_v.*Af_v.*sqrt(R_v))^3)*sum(C_v.*(1.5*sqrt(R_v).*Aa1_v-0.5*R_v.^(3/2).*Pa1_v));
a2_line2 = 2*(sum(C_v.^2.*Af_v.*R_v)*Af/sum(C_v.*Af_v.*sqrt(R_v))^3)*sum(C_v.*(1.5*sqrt(R_v).*Aa2_v-0.5*R_v.^(3/2).*Pa2_v));
a1 = a1_line1 + a1_miss1 - a1_line2;
a2 = a2_line1 +a2_miss1- a2_line2;

end