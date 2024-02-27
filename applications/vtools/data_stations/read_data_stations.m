%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18286 $
%$Date: 2022-08-09 19:35:55 +0800 (Tue, 09 Aug 2022) $
%$Author: chavarri $
%$Id: read_data_stations.m 18286 2022-08-09 11:35:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/read_data_stations.m $
%
%INPUT:
%   paths.main_folder = path to the main folder of the stations; e.g. paths.main_folder='d:\temporal\data_stations';
%   OPTION 1
%   varargin = pair-input with token-name and token; e.g.:
%           -'location_clear','Rood-9'
%           -'grootheid','CONCTTE'
%
%   OPTION 2
%   varargin = 'loadall'; for loading all data
%
%   OPTION 3
%   varargin = boolean with <true> at the indices to load
%
%   OPTION 4
%   varargin = double indices to load
%
%E.g.
%[data_stations,idx]=read_data_stations('c:\Users\chavarri\checkouts\riv\data_stations','location','HOEKVHLRTOVR','grootheid','CONCTTE','bemonsteringshoogte',-9);
%figure
%plot(data_stations.time,data_stations.waarde);
%ylabel(data_stations.grootheid)

function [data_stations,idx]=read_data_stations(paths_main_folder,varargin)

%% PARSE

if isempty(paths_main_folder)
    paths_main_folder='C:\Users\chavarri\checkouts\riv\data_stations\';
    
end
if ~isfolder(paths_main_folder)
    error('Input folder does not exist: %s',paths_main_folder)
end

%% CALC

%do not ask for meaningless variables
varargin_clean=varargin;
nv=numel(varargin)/2;
for kv=1:nv
    par=varargin{kv*2-1};
    val=varargin{kv*2};
    switch par
        case 'bemonsteringshoogte'
            if abs(val)<-1e-7
                varargin_clean(kv*2-1:kv*2)='';
                messageOut(NaN,sprintf('Parameter without meaning removed: %s',par))
            end
            
    end
    
end

%% 
%get indices of stations to read
idx=data_stations_stations_to_load(paths_main_folder,varargin_clean{:});

%% load data

nget=numel(idx);
if nget~=0
    for kget=1:nget
        fname=data_stations_get_file_name(paths_main_folder,idx(kget));
        load(fname,'data_one_station')
        data_stations(kget)=data_one_station;
    end
else
    data_stations=[];
    fprintf('No station found \n')
end

end %function
