%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17337 $
%$Date: 2021-06-10 19:14:13 +0800 (Thu, 10 Jun 2021) $
%$Author: chavarri $
%$Id: D3D_bct.m 17337 2021-06-10 11:14:13Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_bct.m $
%
%bct file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_bct(simdef)
%% RENAME

D3D_structure=simdef.D3D.structure;

if isfield(simdef.bct,'version_V')==0
    if isfield(simdef.bct,'sec')
        simdef.bct.version_V=1;
        warning('call bct_io')
    elseif isfield(simdef.bct,'Table')
        simdef.bct.version_V=2;
    else
        simdef.bct.version_V=0;
    end
end

%% FILE

if D3D_structure==1
    switch simdef.bct.version_V
        case 0
            D3D_bct_s(simdef)
        case 1
            simdef.bct.fname=simdef.file.bct;
            D3D_bct_2(simdef)
        case 2
            bct_io('write',simdef.file.bct,simdef.bct);
    end
else
    D3D_bc_wL(simdef);
    D3D_bc_q0(simdef);
end