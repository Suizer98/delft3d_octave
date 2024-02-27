%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18020 $
%$Date: 2022-05-05 14:45:01 +0800 (Thu, 05 May 2022) $
%$Author: chavarri $
%$Id: datenum_tzone.m 18020 2022-05-05 06:45:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/datenum_tzone.m $
%
%datenum considering time zone

function tim_dnum=datenum_tzone(tim_dtime)

tzone=tim_dtime.TimeZone;
if isempty(tzone)
    op='+';
    hs=0;
    ms=0;
else
    tok=regexp(tzone,'([+-])(\d{2}):(\d{2})','tokens');
    if isempty(tok)
        error('improve the string')
    end
    op=tok{1,1}{1,1};
    hs=str2double(tok{1,1}{1,2});
    ms=str2double(tok{1,1}{1,3});
end

switch op
    case '+'
        tim_dnum=datenum(tim_dtime)+(hs/24+ms/(24/60));
    case '-'
        tim_dnum=datenum(tim_dtime)-(hs/24+ms/(24/60));
end

end %function