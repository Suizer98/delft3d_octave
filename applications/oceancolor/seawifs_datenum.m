function out = seawifsdatenum(in)
%SEAWIFS_DATENUM   map between SeaWiFS yyyydoyHHMMSS and datenum
%
%   out = seawifs_datenum(char   ) makes datenum from SeaWiFS date string
%   out = seawifs_datenum(numeric) makes SeaWiFS date string from datenum
%
% Note: in      == seawifs_datenum(seawifs_datenum(in))
% Note: datenum == seawifs_datenum(seawifs_datenum(datenum)) % when datenum rounded to minutes
%
% 
% Example:
%
%    seawifs_datenum(seawifs_datenum('1998128121603'))
%
%see also: DATENUM, SEAWIFS_L2_READ

if ischar(in)

   T.year = str2num(in( 1: 4));
   T.doy  = str2num(in( 5: 7));
   T.HH   = str2num(in( 8: 9));
   T.MM   = str2num(in(10:11));
   T.SS   = str2num(in(12:13));
   
   out = datenum(T.year,0,T.doy,T.HH,T.MM ,T.SS);
   
elseif isnumeric(in)
   
   out( 1: 4) = datestr(       (in),'yyyy');
   out( 5: 7) = num2str(yearday(in),'%0.3d');
   out( 8: 9) = datestr(       (in),'HH');
   out(10:11) = datestr(       (in),'MM');
   out(12:13) = datestr(       (in),'SS');
   
end

%% EOF