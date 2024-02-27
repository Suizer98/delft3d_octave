%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17077 $
%$Date: 2021-02-19 13:31:11 +0800 (Fri, 19 Feb 2021) $
%$Author: chavarri $
%$Id: messageOut.m 17077 2021-02-19 05:31:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/messageOut.m $
%
%writes message to log file and screen with time stamp

function messageOut(fid,str)

str=strrep(str,'%','%%');
str_time=sprintf('%s %s',datestr(datetime('now')),str);
str_time=strrep(str_time,'\','/');

if isnan(fid)==0
str_file=strcat(str_time,'\r\n');
fprintf(fid,str_file);
end

str_window=strcat(str_time,'\n');
fprintf(str_window);

