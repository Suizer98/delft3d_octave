%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17780 $
%$Date: 2022-02-19 00:08:45 +0800 (Sat, 19 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_grd2shp.m 17780 2022-02-18 16:08:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_grd2shp.m $
%
%Converts a grid with bed elevation into shp format

function [map,polygons]=D3D_grd2shp(fpath_grd,varargin)

%% PARSE

[~,fname_grd]=fileparts(fpath_grd);

parin=inputParser;

addOptional(parin,'fdir_work',fullfile(pwd,'tmp_grd2map'));
addOptional(parin,'fpath_exe','c:\Program Files (x86)\Deltares\Delft3D Flexible Mesh Suite HMWQ (2021.03)\plugins\DeltaShell.Dimr\kernels\x64\dimr\scripts\run_dimr.bat');
addOptional(parin,'fpath_map',fullfile(pwd,sprintf('%s_map.nc',fname_grd)));
addOptional(parin,'fpath_shp',fullfile(pwd,sprintf('%s_etab.shp',fname_grd)));
addOptional(parin,'fid_log',NaN);

parse(parin,varargin{:});

fdir_work=parin.Results.fdir_work;
fpath_exe=parin.Results.fpath_exe;
fpath_map=parin.Results.fpath_map;
fpath_shp=parin.Results.fpath_shp;
fid_log=parin.Results.fid_log;

%% CALC

D3D_grd2map(fpath_grd,'fpath_exe',fpath_exe,'fpath_map',fpath_map)
polygons=D3D_grid_polygons(fpath_map);
map=EHY_getMapModelData(fpath_map,'varName','mesh2d_flowelem_bl');
messageOut(fid_log,'start writing shp-fle')
shapewrite(fpath_shp,'polygon',polygons,map.val)
messageOut(fid_log,sprintf('file created: %s',fpath_shp))

end %function
