%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: settling_velocity.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/settling_velocity.m $
%
%compute settling velocity according to Ferguson, R. & Church, M. (2004),
%A Simple Universal Equation for Grain Settling Velocity, Journal of Sedimentary Research, 
%74, 933-937

function ws=settling_velocity(dk)

%% INPUT

R=1.65;
g=9.81;
c1=20;
c2=1.1;
nu=1e-6;

%% CALC

ws=R.*g.*dk.^2/(c1.*nu+sqrt(0.75.*c2.*R.*g.*dk.^3));

end %function
