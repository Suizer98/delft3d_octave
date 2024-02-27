%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16661 $
%$Date: 2020-10-21 16:32:07 +0800 (Wed, 21 Oct 2020) $
%$Author: chavarri $
%$Id: D3D_figure_domain.m 16661 2020-10-21 08:32:07Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_figure_domain.m $
%
function out=D3D_figure_domain(simdef,in)

switch simdef.D3D.structure
    case 1
        d3dplotgrid(grd);
    case 2
        is1d=0;
        if isfield(in,'network1d_geom_x')
            is1d=1;
        end
        if is1d
            D3D_figure_domain_1D(simdef,in)
        else
            D3D_figure_domain_2D(simdef,in)
            %%
%             figure
%             scatter(in.mesh2d_node_x,in.mesh2d_node_y)
%             error('implement')
        end

end %function