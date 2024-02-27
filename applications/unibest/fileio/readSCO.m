function varargout=readSCO(SCOfilename)
%read SCO : Reads an sco-file
%
%   Syntax:
%     function [h0,hs,tp,xdir,dur,x,y,numOfDays]=readSCO(SCOfilename)
% 
%   Input:
%     SCOfilename          string with .sco filename
%  
%   Output:
%     SCOdata              structure with the following fields:
%     .h0                   water level per condition [m] (array [Nx1])
%     .hs                   wave height per condition [m] (array [Nx1])
%     .tp                   wave period per condition [s] (array [Nx1])
%     .xdir                 wave direction per condition [°N] (array [Nx1]) 
%     .dur                  duration per condition [days] (array [Nx1]) 
%     .x                    x-coordinate of sco-file [m]
%     .y                    y-coordinate of sco-file [m]
%     .numOfDays            total duration of year in sco-file [days] (default=365)
%      
%     Note that it is also still possible to get output for all fields 
%     seperately if you provide sufficient output arguments (see example).
%
%   Example:
%     [SCOdata]=readSCO('test.sco');
%
%        OR
%
%     [h0,hs,tp,xdir,dur,x,y,numOfDays]=readSCO('test.sco');
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Robin Morelissen, Cilia Swinkels.,2006
%       robin.morelissen@deltares.nl
% 
%       updated improved version by BJA Huisman 2010
%       bas.huisman@deltares.nl
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: readSCO.m 17266 2021-05-07 08:01:51Z huism_b $
% $Date: 2021-05-07 16:01:51 +0800 (Fri, 07 May 2021) $
% $Author: huism_b $
% $Revision: 17266 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/readSCO.m $
% $Keywords: $

SCOdata=struct;

fid=fopen(SCOfilename);
if fid==-1
    fprintf('Error : Unable to find specified .sco file! Check input.')
    return
end

%Read number of days
lin=fgetl(fid);
SCOdata.numOfDays=str2num(strtok(lin));
if isempty(SCOdata.numOfDays)
    error('Error reading first line of SCO, number of days. Make sure line is not empty or filled with non-numeric values!');
    return
    varargout{1}=[];
end

%Read number of waves 
lin=fgetl(fid);
numOfWaves=str2num(strtok(lin));
if isempty(numOfWaves)
    error('Error reading second line of SCO, number of waves. Make sure line is not empty or filled with non-numeric values!');
    return
    varargout{1}=[];
end

%Determine location from this line else ask
try
    [dum,rest]=strtok(lower(lin),'=');
    rest=rest(2:end);
    [x,y]=strtok(lower(rest),'=');
    SCOdata.x=str2num(x(1:end-1));
    SCOdata.y=str2num(y(2:end-1));
catch
    SCOdata.x=0;
    SCOdata.y=0;
end

%read dummy
SCOdata.isWavecurrent = 0;
SCOdata.isDynamicBND = 0;
SCOdata.prctDynamicBND = 50;
SCOdata.isWind = 0;
SCOdata.isTideoffset = 0;
SCOdata.isTimeseries = 0;
numFields = 5;
readheader = true;
ff=1;
while readheader
   lin=fgetl(fid);
   if ff==8 || ~isempty(findstr(lower(lin),'hsig')) || ~isempty(findstr(lower(lin),'tper')) || ~isempty(findstr(lower(lin),'alf')) || ~isempty(findstr(lower(lin),'duration'))
       readheader = false;
   elseif ~isempty(findstr(lower(lin),'wave-current'))
       SCOdata.isWavecurrent=str2num(strtok(lin));ff=ff+1;
   elseif ~isempty(findstr(lower(lin),'dynamic boundary'))
       %id=findstr(lin,'(');id=[id-1,length(lin)];
       [a,id2]=setdiff(lin,char([48:57,32]));id=[min(id2)-1,length(lin)];
       [SCOdata.isDynamicBND,SCOdata.prctDynamicBND]=strread(lin(1:id(1)),'%f%f');ff=ff+1;
   elseif ~isempty(findstr(lower(lin),'wind'))
       SCOdata.isWind=str2num(strtok(lin));ff=ff+1;
       if SCOdata.isWind==1;numFields = numFields+3;end
   elseif ~isempty(findstr(lower(lin),'tide offset'))
       SCOdata.isTideoffset=str2num(strtok(lin));ff=ff+1;
   elseif ~isempty(findstr(lower(lin),'timeseries'))
       SCOdata.isTimeseries=str2num(strtok(lin));ff=ff+1;
       if SCOdata.isTimeseries==1;numFields = numFields+3;end
   end
end
   
%Read data
data=fscanf(fid,'%f',[numFields numOfWaves])';
fclose(fid);

%Output arguments
if numFields==5
    SCOdata.h0     = data(:,1);
    SCOdata.hs     = data(:,2);
    SCOdata.tp     = data(:,3);
    SCOdata.xdir   = data(:,4);
    SCOdata.dur    = data(:,5);
elseif numFields==8 && SCOdata.isWind
    SCOdata.h0     = data(:,1);
    SCOdata.hs     = data(:,2);
    SCOdata.tp     = data(:,3);
    SCOdata.xdir   = data(:,4);
    SCOdata.dur    = data(:,5);
    SCOdata.WS     = data(:,6);
    SCOdata.Wdir   = data(:,7);
    SCOdata.Wdrag  = data(:,8);
elseif numFields==8 && SCOdata.isTimeseries
    SCOdata.time   = data(:,1);
    SCOdata.h0     = data(:,2);
    SCOdata.hs     = data(:,3);
    SCOdata.tp     = data(:,4);
    SCOdata.xdir   = data(:,5);
    SCOdata.Htide  = data(:,6);
    SCOdata.Vtide  = data(:,7);
    SCOdata.RefDep = data(:,8);
    if length(SCOdata.time)>1
      Dur0         = (SCOdata.time(2:end)-SCOdata.time(1:end-1));Dur0=Dur0(:);
      SCOdata.Dur  = [Dur0(1);(Dur0(2:end)+Dur0(1:end-1))/2;Dur0(end)];
    end
end


% read tide table (not yet implemented)
%if ~SCOdata.isTimeseries
%    for mm=1:length()
%        SCOdata.Ptide 
%    end
%end


if nargout==1
    varargout{1}=SCOdata;
else
    varargout{1}=SCOdata.h0;
    varargout{2}=SCOdata.hs;
    varargout{3}=SCOdata.tp;
    varargout{4}=SCOdata.xdir;
    varargout{5}=SCOdata.dur;
    varargout{6}=SCOdata.x;
    varargout{7}=SCOdata.y;
    varargout{8}=SCOdata.numOfDays;
end
