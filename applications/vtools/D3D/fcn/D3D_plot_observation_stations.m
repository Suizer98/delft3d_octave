%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17855 $
%$Date: 2022-03-25 14:31:33 +0800 (Fri, 25 Mar 2022) $
%$Author: chavarri $
%$Id: D3D_plot_observation_stations.m 17855 2022-03-25 06:31:33Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_plot_observation_stations.m $
%
%Plot observation stations

function D3D_plot_observation_stations(fpath_his,varargin)

%% PARSE

parin=inputParser; 

addOptional(parin,'map',true);
addOptional(parin,'OPT',struct());

parse(parin,varargin{:})

in_p.map=parin.Results.map;
in_p.OPT=parin.Results.OPT;

%% CALC

obs_sta=D3D_observation_stations(fpath_his);

in_p.obs_sta=obs_sta;

D3D_fig_observation_stations(in_p);

end