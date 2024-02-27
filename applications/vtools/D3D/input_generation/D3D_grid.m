%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17699 $
%$Date: 2022-02-01 16:11:11 +0800 (Tue, 01 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_grid.m 17699 2022-02-01 08:11:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_grid.m $
%
%grid creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_grid(simdef)
%% RENAME

D3D_structure=simdef.D3D.structure;

%% FILE

%% before conversion function
% if D3D_structure==1
%     D3D_grd(simdef)
%     D3D_enc(simdef)
% else
%     D3D_grd_copy(simdef);
% end

%% with conversion function

% D3D_grd(simdef)
% D3D_enc(simdef)
%     
% if D3D_structure==2
%     if simdef.grd.cell_type==1
%         D3D_grd_convert(simdef)
%     else
%         D3D_grd_copy(simdef);
%     end
% end

%% direct write in FM

switch D3D_structure
    case 1
        D3D_grd(simdef)
        D3D_enc(simdef)
    case 2
        switch simdef.grd.type
            case 1
                D3D_grd_rect_u(simdef)
        end %simdef.grd.type
end
