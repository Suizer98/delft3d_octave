% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17617 $
%$Date: 2021-11-30 19:07:58 +0800 (Tue, 30 Nov 2021) $
%$Author: chavarri $
%$Id: D3D_main_minimal_2D_plot.m 17617 2021-11-30 11:07:58Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/source/D3D_main_minimal_2D_plot.m $
%
%Minimal example to plot 2D results with a map in the background. 

%% PREAMBLE

clear
clc
fclose all;

%% ADD OET

path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
addpath(path_add_fcn)
addOET

%% READ

path_map='c:\Users\chavarri\checkouts\riverlab\real_world\black_volta\delft3d_fm\morphodynamics_2D\dimr\dflowfm\DFM_OUTPUT_FlowFM\FlowFM_map.nc'; %path to the map file
gridInfo=EHY_getGridInfo(path_map,{'face_nodes_xy'}); %grid
map_h=EHY_getMapModelData(path_map,'varName','mesh2d_waterdepth'); %map result to plot. As such you are loading all the times available. 

%check <nci.Variables.Name> to see the possibilities
% nci=ncinfo(path_map);

%% PLOT

kt=42; %time to plot
tol=10e3; %tolerance for tiles
lims_x=[min(gridInfo.face_nodes_x(:)),max(gridInfo.face_nodes_x(:))];
lims_y=[min(gridInfo.face_nodes_y(:)),max(gridInfo.face_nodes_y(:))];

figure
hold on

%add tiles from google earth
OPT=struct();
OPT.xlim=lims_x+[-tol,tol]; %x limit for downloading tiles
OPT.ylim=lims_y+[-tol,tol]; %y limit for downloading tiles 
OPT.epsg_in=32630; %system of the limits
OPT.epsg_out=32630; %system of the plot
OPT.tzl=13; %zoom
OPT.save_tiles=false; %save a mat-file with the tiles to reuse
% OPT.path_save='tiles'; %path of the mat-file
OPT.path_tiles='C:\Users\chavarri\checkouts\riv\earth_tiles\'; %folder to store the downloaded tiles (it will first check if already downloaded).
OPT.map_type=3;%map type
OPT.han_ax=gca; %axis to add the plot
OPT.z_tiles=min(map_h.val(kt,:))-abs(min(map_h.val(kt,:))); %elevation of the tiles (should be below the minimum)
% OPT.z_tiles=0; %elevation of the tiles

plotMapTiles(OPT);

%plot map results
EHY_plotMapModelData(gridInfo,map_h.val(kt,:));

%beautify
xlim(lims_x);
ylim(lims_y);
axis equal
colorbar
caxis([min(map_h.val(kt,:)),max(map_h.val(kt,:))])
view([0,90])