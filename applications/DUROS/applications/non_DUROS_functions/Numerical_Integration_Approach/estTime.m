function [endTime] = estTime(startTime, progress)
%ESTTIME    routine to estimate the end time for processes linear in time
%
% This routine estimates the end time of a process by linear
% extrapolation using the start time and the elapsed time so far
% and prints relevant information on the screen
% 
% input:      startTime   =   reference time at the beginning of the process; Can
%                             either be a date vector or a serial date number
%             progress    =   indicates the progress so far; Can either be expressed as a number < 1 (e.g. 0.1 for 10%),
%                             1 if process is completed, or as a number > 1 (e.g. 25 for 1/25)
% 
% output      endTime     =   gives the (estimated) end time of the process in the same format as startTime (date vector or serial date number)
%
%   See also
% 
% --------------------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2008 FOR INTERNAL USE ONLY 
% Version:      Version 1.0, January 2008 (Version 1.0, January 2008)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>                                                            
% --------------------------------------------------------------------------
%%
t2 = clock; % current time
num = 0; 
if length(startTime) == 1 % startTime expressed as a serial date number
    startTime = datevec(startTime);  % express startTime as date vector
    num = 1; % indicator that original startTime is in serial date number form set to 1
end
fprintf(1,'\nThe process started on %s\n\n',datestr(startTime))

if nargin==1 % only startTime has been used as input
    progress = 1; % assumes the process has been finished
end
if progress > 1
    progress = 1/progress; % progress should be between 0 and 1
elseif progress <= 0 % progress should positive
    fprintf(1,'  Warning: variable ''progress'' cannot be zero or negative\n');
    endTime=[];
    return;
end
e = etime(t2,startTime); % time in seconds between vectors startTime and t2
endTime = datevec(datenum(startTime)+(datenum(t2)-datenum(startTime))/progress); % estimate endTime based linear extrapolation of progress and time so far

if progress~=1
    fprintf(1,'Progress is %2.0f %%, elapsed time is ',progress*100);
else
    fprintf(1,'Elapsed time is ');
end
if e < 60
    fprintf(1,'%5.2f seconds.\n',e);
elseif e < 3600
    fprintf(1,'%5.2f minutes.\n',e/60);
else
    fprintf(1,'%5.2f hours.\n',e/3600);
end 

if progress~=1
    fprintf(1,'\nEstimated end time is %s\n\n',datestr(endTime));
else
    fprintf(1,'\nEnd time is %s\n\n',datestr(endTime));
end

if num == 1 % startTime expressed as a serial date number
    endTime = datenum(endTime);  % express endTime as date vector
end