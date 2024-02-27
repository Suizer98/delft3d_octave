function ITHK_add_revetment(ii,phase,NREV,sens)
%function ITHK_add_revetment(ii,phase,NREV,sens)
%
% Adds revetments to the REV file
%
% INPUT:
%      ii     number of beach extension
%      phase  phase number (of CL-model)
%      NREV   number of revetments
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .EPSG
%              .settings.outputdir
%              .userinput.revetment(ii).lat
%              .userinput.revetment(ii).lon
%              .userinput.revetment(ii).length
%              .userinput.revetment(ii).filename
%              .userinput.phase(phase-1).REVfile
%              .userinput.revetment(ii).fill
%      MDAfile  'BASIC.MDA'
%      REVfile  file with already defined revetments
%
% OUTPUT:
%      REVfile  file with new and old revetments
%      S      structure with ITHK data (global variable that is automatically used)
%              .UB.input(sens).revetment(ii).REVdata
%              .userinput.revetment(ii).idRANGE
%

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 <COMPANY>
%       ir. Bas Huisman
%
%       <EMAIL>	
%
%       <ADDRESS>
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 18 Jun 2012
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: ITHK_add_revetment.m 11018 2014-07-31 15:20:51Z boer_we $
% $Date: 2014-07-31 23:20:51 +0800 (Thu, 31 Jul 2014) $
% $Author: boer_we $
% $Revision: 11018 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/measures/ITHK_add_revetment.m $
% $Keywords: $

%% code

global S

%% get relevant info from struct
lat = S.userinput.revetment(ii).lat;
lon = S.userinput.revetment(ii).lon;

%% convert coordinates
[x,y]               = convertCoordinates(lon,lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',str2double(S.settings.EPSGcode));

%% read files
[MDAdata]=ITHK_io_readMDA([S.settings.outputdir S.settings.CLRdata.mdaname '.MDA']);
if phase==1 || NREV>1
    [REVdata]=ITHK_io_readREV([S.settings.outputdir S.userinput.revetment(ii).filename]);
else
    [REVdata]=ITHK_io_readREV([S.settings.outputdir S.userinput.phase(phase-1).REVfile]);
end

%% process input and add to file
S.UB.input(sens).revetment(ii).length = S.userinput.revetment(ii).length;
[idNEAREST,idRANGE]=findGRIDinrange(MDAdata.Xcoast,MDAdata.Ycoast,x,y,0.5*S.userinput.revetment(ii).length);

Nrev = length(REVdata);
REVdata(Nrev+1).filename = [S.settings.outputdir S.userinput.revetment(ii).filename];
REVdata(Nrev+1).Xw = MDAdata.Xcoast(idRANGE)';
REVdata(Nrev+1).Yw = MDAdata.Ycoast(idRANGE)';
REVdata(Nrev+1).Top = [];
if  S.userinput.revetment(ii).fill==0
    REVdata(Nrev+1).Option = 0;
else
    REVdata(Nrev+1).Option = 2;
end
ITHK_io_writeREV(REVdata,MDAdata,0.1)
S.UB.input(sens).revetment(ii).REVdata = REVdata;
S.userinput.revetment(ii).idRANGE = idRANGE;

% Keep track of user defined revetments
if ~isfield(S.userinput.userdefined,'REV')
    len = 0;
else
    len = length(S.userinput.userdefined.REV);
end
S.userinput.userdefined.REV(len+1) = REVdata(end);


%% Function find grid in range
function [idNEAREST,idRANGE]=findGRIDinrange(Xcoast,Ycoast,x,y,radius)
    dist2 = ((Xcoast-x).^2 + (Ycoast-y).^2).^0.5;
    idNEAREST  = find(dist2==min(dist2));
    dist3 = ((Xcoast-Xcoast(idNEAREST)).^2 + (Ycoast-Ycoast(idNEAREST)).^2).^0.5;
    idRANGE  = find(dist3<radius);
end
end