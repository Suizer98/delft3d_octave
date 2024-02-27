%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18082 $
%$Date: 2022-05-27 22:38:11 +0800 (Fri, 27 May 2022) $
%$Author: chavarri $
%$Id: D3D_plot_grid.m 18082 2022-05-27 14:38:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_plot_grid.m $
%

function D3D_plot_grid(fdir_sim)

simdef.D3D.dire_sim=fdir_sim;
simdef.flg.which_p='grid';
simdef.flg.print=NaN;
simdef=D3D_simpath(simdef,'break',1);
out_read=D3D_read(simdef,NaN);
D3D_figure_domain(simdef,out_read);