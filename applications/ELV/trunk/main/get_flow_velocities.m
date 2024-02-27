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
%$Id: get_flow_velocities.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/get_flow_velocities.m $
%
%get_flow_velocities does this and that
%
%U = get_flow_velocities(input,x,Q,h,ib)
%
%INPUT:
%   -
%
%OUTPUT:
%   -

%HISTORY:
%170404
%   -V. Added the header because Liselot does not follow the protocol :D
%

function U = get_flow_velocities(input,x,Q,h,ib)
% Compute velocities; assume a normal flow discharge distribution over the
% main and side channels
[~, Af1,Af2,Af3] = get_cross_section(input,x,h,'Af');
[~,P1,P2,P3] = get_cross_section(input,x,h,'P');

dhdx = 0; %Should be non-zero???
Af_v = [Af1;Af2;Af3];
P_v = [P1;P2;P3];
C1 = sqrt(input.frc.Cf(1,1)/input.mdv.g);
C2 = sqrt(input.frc.Cf(2,1)/input.mdv.g);
C3 = sqrt(input.frc.Cf(3,1)/input.mdv.g);
C_v = [C1;C2;C3];
R_v = Af_v./P_v;
R_v(isnan(R_v)==1)= 0;

Q_vt = sqrt(Af_v.^2*(dhdx-ib).*C_v.^2.*R_v);
Q_v = Q_vt./sum(Q_vt)*Q;
U = Q_v./(Af_v); %flow velocity vector
U(isnan(U)==1) = 0;
end