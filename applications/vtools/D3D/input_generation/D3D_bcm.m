%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17316 $
%$Date: 2021-06-03 18:01:47 +0800 (Thu, 03 Jun 2021) $
%$Author: chavarri $
%$Id: D3D_bcm.m 17316 2021-06-03 10:01:47Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_bcm.m $
%
%bcm file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_bcm(simdef,varargin)
%% RENAME

D3D_structure=simdef.D3D.structure;
IBedCond=simdef.mor.IBedCond;

%% FILE

if any(IBedCond==[3,5])
    if D3D_structure==1
        D3D_bcm_s(simdef,varargin{:});
    else
        D3D_bcm_u(simdef,varargin{:});
    end
end
