%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17488 $
%$Date: 2021-09-17 23:01:18 +0800 (Fri, 17 Sep 2021) $
%$Author: chavarri $
%$Id: read_str_time.m 17488 2021-09-17 15:01:18Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/read_str_time.m $
%
%read string with time

function [t0_dtime,units,tzone,tzone_num]=read_str_time(str_time)

if iscell(str_time)
    error('input must be char')
end

tok=regexp(str_time,' ','split');
if numel(tok)>4
    tzone=tok{1,5};
else
    tzone='+00:00';
    messageOut(NaN,'There is no time zone. I assume +00:00');
end
t0_dtime=datetime(sprintf('%s %s',tok{1,3},tok{1,4}),'InputFormat','yyyy-MM-dd HH:mm:ss','TimeZone',tzone);
units=tok{1,1};
tok=regexp(tzone,'([+-]?)(\d{2}):(\d{2})','tokens');
s=tok{1,1}{1,1};
h=str2double(tok{1,1}{1,2});
m=str2double(tok{1,1}{1,3});
tzone_num=h+m/60;
if strcmp(s,'-')
    tzone_num=-tzone_num;
end