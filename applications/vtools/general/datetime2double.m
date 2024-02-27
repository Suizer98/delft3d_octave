%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: datetime2double.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/datetime2double.m $
%

function [tim_double,tim_str]=datetime2double(dtime,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'ref_time',dtime(1));
addOptional(parin,'unit','seconds');

parse(parin,varargin{:});

ref_time=parin.Results.ref_time;
unit=parin.Results.unit;

%% CALC

switch unit
    case 'seconds'
        tim_double=seconds(dtime-ref_time);
    case 'minutes'
        tim_double=minutes(dtime-ref_time);
    otherwise
        error('add')
end

tim_str=sprintf('%s since %s %s',unit,datestr(ref_time,'yyyy-mm-dd HH:MM:SS'),ref_time.TimeZone);

end %function