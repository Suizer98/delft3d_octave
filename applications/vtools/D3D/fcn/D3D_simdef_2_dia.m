%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17942 $
%$Date: 2022-04-06 03:30:26 +0800 (Wed, 06 Apr 2022) $
%$Author: chavarri $
%$Id: D3D_simdef_2_dia.m 17942 2022-04-05 19:30:26Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_simdef_2_dia.m $
%
%OUTPUT:

function [fpath_dia,structure]=D3D_simdef_2_dia(simdef)

if isstruct(simdef)
    fpath_dia=simdef.file.dia;
    structure=simdef.D3D.structure;
elseif isfolder(simdef)
    dire_sim=simdef;
    simdef=struct();
    simdef.D3D.dire_sim=dire_sim;
    simdef=D3D_simpath(simdef);
    fpath_dia=simdef.file.dia;
    structure=simdef.D3D.structure;
elseif exist(simdef,'file')==2
    fpath_dia=simdef;
    [~,~,ext]=fileparts(fpath_dia);
    switch ext
        case '.dia'
            structure=2;
        otherwise
            structure=1;
    end
else
    error('not a dir, not a structure')
end

end %function