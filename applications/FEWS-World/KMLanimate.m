function KMLanimate(inFile, outFile, MapNames, begintime, timestep, timeunit)
%KMLANIMATE   adapts kml existing file
%
%   KMLanimate(inFile, outFile, MapNames, begintime, timestep, timeunit)
%
% opens a .kml (not kmz) file and inserts lines at the right spots to make 
% it an animation instead of single images.
%
% Input:    (all inputs are compulsory)
% inFile:    non-animated kml file, containing several images
% outFile:   name of resulting animated kml
% MapNames:  specify a cell array of strings, indicating the mapnames, where
%            animation should occur.
% begintime: a datevector [yyyy mm dd HH MM SS] or [yyyy mm dd], indicating the start date/time of the first image
% timestep:  it is assumed that all images are separated by the same timestep. Here a number should be given concurring with the unit given.
% timeunit:  unit of timesteps (can be 'year', 'month', 'day', 'hour', 'minute', 'second', 'millisecond')
%
%See also: googleplot

%% OpenEarth general information
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Hessel C. Winsemius
%
%       hessel.winsemius@deltares.nl
%
%		Rotterdamseweg 185
%       Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   --------------------------------------------------------------------

% $Id: KMLanimate.m 2184 2010-01-22 12:40:53Z winsemi $
% $Date: 2010-01-22 20:40:53 +0800 (Fri, 22 Jan 2010) $
% $Author: winsemi $
% $Revision: 2184 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/FEWS-World/KMLanimate.m $

%% START PROCESSING
% Open input kml-file for reading
fid_in = fopen(inFile,'r');
fid_out = fopen(outFile,'w');
if length(begintime) < 6
    begintime(4:6) = 0;
end
% Determine timespan of first image in kml
endtime = addtodate(datenum(begintime),timestep,timeunit);
MapNameCount = 1;
CurrentMapName = MapNames{MapNameCount};
while 1

	% Read until end of file
    line = fgetl(fid_in);
    if ~ischar(line)
        fclose(fid_in);
        fclose(fid_out);
        fclose('all');
        clear all
        break
    end
    stringyn = strfind(line,['<name>' CurrentMapName '</name>']);
    % If the string CurrentMapName is found in a line, do the following....
    if ~isempty(stringyn)
		% In the new kml-file, write a time span in between the original lines of the kml
        fprintf(fid_out,'%s\n','<TimeSpan>');
        fprintf(fid_out,'\t%s\n',['<begin>' datestr(datenum(begintime),'yyyy-mm-ddTHH:MM:SSZ') '</begin>']);
        fprintf(fid_out,'\t%s\n',['<end>' datestr(endtime,'yyyy-mm-ddTHH:MM:SSZ') '</end>']);
        fprintf(fid_out,'%s\n','</TimeSpan>');
        % Update the time beginning and end for the next image
        begintime = endtime;
        endtime = addtodate(endtime,timestep,timeunit);
        % Update the current map name
        MapNameCount = MapNameCount + 1;
        if MapNameCount > length(MapNames)
            CurrentMapName = '*******';
        else
            CurrentMapName = MapNames{MapNameCount};
        end
    end
    fprintf(fid_out,'%s\n',line);

end

