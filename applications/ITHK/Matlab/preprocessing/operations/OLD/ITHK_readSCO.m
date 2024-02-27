function varargout=ITHK_readSCO(SCOfilename)
%read SCO : Reads an sco-file
%
%   Syntax:
%     function [h0,hs,tp,xdir,dur,x,y,numOfDays]=ITHK_readSCO(SCOfilename)
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
%     [SCOdata]=ITHK_readSCO('test.sco');
%
%        OR
%
%     [h0,hs,tp,xdir,dur,x,y,numOfDays]=ITHK_readSCO('test.sco');
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

% $Id: ITHK_readSCO.m 6382 2012-06-12 16:00:17Z boer_we $
% $Date: 2012-06-13 00:00:17 +0800 (Wed, 13 Jun 2012) $
% $Author: boer_we $
% $Revision: 6382 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/OLD/ITHK_readSCO.m $
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
fgetl(fid);

%Read data
data=fscanf(fid,'%f',[5 numOfWaves])';
fclose(fid);

%Output arguments
SCOdata.h0   = data(:,1);
SCOdata.hs   = data(:,2);
SCOdata.tp   = data(:,3);
SCOdata.xdir = data(:,4);
SCOdata.dur  = data(:,5);

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
