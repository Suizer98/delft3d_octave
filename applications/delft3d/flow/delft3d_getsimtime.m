function [time] = delft3d_getsimtime(dirname)
%DELFT3D_GETSIMTIME retrieves the simulation time from the tri-diag.* file.
%
% input:
% dirname    - String containing directory.
%              '' = current directory
%
% output:
% time.num:      - In datenum format
% time.hours:    - Number of hours
% time.minutes:  - Number of minutes
% time.seconds:  - Number of seconds
% time.str:      - Length of simulation as a string format 'HH:MM:SS'.
%
% example:
% [time] = delft3d_getsimtime('d:\simulations\sim01\')
%
% See also: datenum

% -------------------------------------------------------------------------
%  Copyright (C) 2008 Delft University of Technology
%    Faculty of Civil Engineering and Geosciences
%    Willem Ottevanger  (email: w.ottevanger@tudelft.nl)
%    Version 0.2 (05-09-08)
% -------------------------------------------------------------------------


if (nargin < 1)
    dirname = '';
end
%TO DO: Should check on tailing '\' in dirname.
tridiagfile = dir([dirname,'tri-diag.*']);

if size(tridiagfile,1) == 1
    fid = fopen([dirname,tridiagfile.name],'r');
    count = 0;
    while 1
        count = count +1;
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        linesfromfile{count} = tline;
    end
    fclose(fid);

    %Last Line contains end-time
    endstr = linesfromfile{count-1};
    %disp(endstr(11:29))  

    %Find line containing start-time
    count2 = count-1;
    while count2 > 1
        count2 = count2-1;
        stastr = linesfromfile{count2};
        if length(stastr)>48
            if sum(stastr(1:29) == '***         Simulation date: ') == 29
                %disp(stastr(30:48))
                break
            end
        end
    end

    VStart=datevec(stastr(30:48),'yyyy-mm-dd HH:MM:SS');   %Start of simulation date and time;
    VEnd = datevec(endstr(11:29),'yyyy-mm-dd HH:MM:SS');   %End   of simulation date and time;

    time.num     = datenum(VEnd)-datenum(VStart);
    time.hours   = floor(time.num*24);
    time.minutes = floor((time.num*24-time.hours)*60);
    time.seconds = floor((((time.num*24-time.hours)*60)-time.minutes)*60);
    time.str     = [num2str(time.hours,'%0.2i'),':',num2str(time.minutes,'%0.2i'),':',num2str(time.seconds,'%0.2i')];
else
    time = 'NaN'
    if (size(tridiagfile,1) == 0)
        warning('No tri-diag files available')
    elseif (size(tridiagfile,1) > 1)
        warning('Multiple tri-diag files available')
    end
end
