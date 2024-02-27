%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_checkInput.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_checkInput.m $
%
%check the input parameters

%INPUT:
%   -simdef.mdf.Dpsopt = bed level interpolation at water level points [string]: DP=position of depth points shifted to water level points; MIN=minimum of the surrounding points; MEAN=mean of the surrounding points; MAX=max of the surrouding points; 
%   -simdef.mdf.Dpuopt = bed level interpolation at velocity    points [string]: MIN=minimum of the surrounding point; MEAN=mean of the surrounding points; UPW=upwind 

function D3D_checkInput(simdef)
%% RENAME

Dpsopt=simdef.mdf.Dpsopt;
Dpuopt=simdef.mdf.Dpuopt;

%% CHECKS
%interpolation
if strcmp(Dpsopt,'DP') && strcmp(Dpuopt,'MEAN')
    warning('DPSOPT=DP and DPUOPT=MEAN should not be used together (10.8.2 D3D manual)')
end