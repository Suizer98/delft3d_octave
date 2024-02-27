%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18271 $
%$Date: 2022-08-01 22:24:23 +0800 (Mon, 01 Aug 2022) $
%$Author: chavarri $
%$Id: D3D_observation_stations.m 18271 2022-08-01 14:24:23Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_observation_stations.m $
%
%Read observation stations name and location

function obs_sta=D3D_observation_stations(path_his,varargin)

% parin=inputParser;
% 
% addOptional(parin,'varName','station');
% 
% parse(parin,varargin{:});
% 
% varName=parin.Results.varName;

%%

nci=ncinfo(path_his);
is_sta=ismember('station_id',{nci.Variables.Name});
if is_sta
    obs_sta.name=cellstr(ncread(path_his,'station_id')')';
    obs_sta.x=ncread(path_his,'station_x_coordinate')';
    obs_sta.y=ncread(path_his,'station_y_coordinate')';
else
    obs_sta.name={''};
    obs_sta.x=[];
    obs_sta.y=[];
end

end %function
