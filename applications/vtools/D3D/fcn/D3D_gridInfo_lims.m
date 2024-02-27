%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18390 $
%$Date: 2022-09-27 18:07:53 +0800 (Tue, 27 Sep 2022) $
%$Author: chavarri $
%$Id: D3D_gridInfo_lims.m 18390 2022-09-27 10:07:53Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_gridInfo_lims.m $
%

function [xlims,ylims]=D3D_gridInfo_lims(gridInfo)

if isfield(gridInfo,'face_nodes_x')
    xlims=[min(gridInfo.face_nodes_x(:)),max(gridInfo.face_nodes_x(:))];
    ylims=[min(gridInfo.face_nodes_y(:)),max(gridInfo.face_nodes_y(:))];
elseif isfield(gridInfo,'Xcor')
    xlims=[min(gridInfo.Xcor(:)),max(gridInfo.Ycor(:))];
    ylims=[min(gridInfo.Xcor(:)),max(gridInfo.Ycor(:))];
elseif isfield(gridInfo,'offset')
%     error('what to do with rkm')
    xlims=[min(gridInfo.x_node(:)),max(gridInfo.x_node)];
    ylims=[min(gridInfo.y_node(:)),max(gridInfo.y_node)];
end

tol=0.05;
xlims=xlims+diff(xlims).*[-tol,tol]+10*[-eps,eps];
ylims=ylims+diff(ylims).*[-tol,tol]+10*[-eps,eps];

end %function
