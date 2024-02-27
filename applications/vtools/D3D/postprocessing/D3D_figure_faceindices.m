%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_figure_faceindices.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_figure_faceindices.m $
%
function D3D_figure_faceindices(han,in)

han.fig_fi=figure;
hold on
scatter3(in.x_face,in.y_face,[1:1:numel(in.x_face)],10,[1:1:numel(in.x_face)],'filled')
view([0,90])
axis equal
han.ta=gca;
linkaxes([han.sfig,han.ta],'xy')

