%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17759 $
%$Date: 2022-02-14 17:50:54 +0800 (Mon, 14 Feb 2022) $
%$Author: chavarri $
%$Id: NC_read_time.m 17759 2022-02-14 09:50:54Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_time.m $
%
%read time from NC file

function [time_dtime,units,time_r]=NC_read_time(nc_map,kt,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'type','hydro')

parse(parin,varargin{:});

tim_type=parin.Results.type;

%% CALC

[t0_dtime,units]=NC_read_time_0(nc_map);

switch tim_type
    case 'hydro'
        tim_str='time';
    case 'morpho'
        tim_str='morft';
end
        
time_r=ncread(nc_map,tim_str,kt(1),kt(2)); %results time vector [seconds/minutes/hours since start date]

switch units
    case 'seconds'
        time_dtime=t0_dtime+seconds(time_r);
    case 'minutes'
        time_dtime=t0_dtime+minutes(time_r);
    case 'hours'
        time_dtime=t0_dtime+hours(time_r);
    case 'days'
        time_dtime=t0_dtime+days(time_r);
    otherwise
        error('add')
end

end %function