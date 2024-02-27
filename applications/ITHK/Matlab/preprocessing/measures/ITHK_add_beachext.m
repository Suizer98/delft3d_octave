function ITHK_add_beachext(ii,sens)
%function ITHK_add_beachext(ii,sens)
%
% Adds seaward beach extension to the MDA file
%
% INPUT:
%      ii     number of beach extension
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .EPSG
%              .beachextension(ii).lat
%              .beachextension(ii).lon
%      MDAfiles 'BASIC.MDA' & 'BASIS_ORIG.MDA'
%
% OUTPUT:
%      MDAfiles 'BASIC.MDA' & 'BASIS_ORIG.MDA' updated
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

% $Id: ITHK_add_beachext.m 10731 2014-05-22 14:41:23Z boer_we $
% $Date: 2014-05-22 22:41:23 +0800 (Thu, 22 May 2014) $
% $Author: boer_we $
% $Revision: 10731 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/measures/ITHK_add_beachext.m $
% $Keywords: $

%% code


global S

%% get relevant info from struct
lat = S.beachextension(ii).lat;
lon = S.beachextension(ii).lon;

%% convert coordinates
[x,y]               = convertCoordinates(lon,lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',str2double(S.settings.EPSGcode));

%% read files
[MDAdata]=ITHK_io_readMDA('BASIS.MDA');
[MDAdata_ORIG]=ITHK_io_readMDA('BASIS_ORIG.MDA');


%% calculate coastline extension & put into MDAfile
% Obtain new Y1 values and write to MDAfile (be sure that BASIS.MDA and BASIS_ORIG.MDA have same number of gridcells)
XYref = [MDAdata.Xcoast MDAdata.Ycoast];
XYcoast = [x' y'];
[Y1,idY1,Xcoast_new,Ycoast_new,Xcoast_old,Ycoast_old] = ITHK_fitCoastlineOnReferenceline(XYref,XYcoast);
Y1_new = MDAdata.Y1i;
Y1_new(idY1) = MDAdata.Y1i(idY1)+Y1;
MDAdata.nrgridcells=MDAdata.Xi.*0+1;MDAdata.nrgridcells(1)=0;
ITHK_io_writeMDA('BASIS.MDA',[MDAdata.Xi MDAdata.Yi],Y1_new,[],MDAdata.nrgridcells);
ITHK_io_writeMDA('BASIS_ORIG.MDA',[MDAdata_ORIG.Xi MDAdata_ORIG.Yi],MDAdata_ORIG.Y1i,[],MDAdata.nrgridcells);

% % Put info in struct
% S.beachextension(ii).idY1 = idY1;
% S.beachextension(ii).Xcoast_new = Xcoast_new;
% S.beachextension(ii).Ycoast_new = Ycoast_new;
% S.beachextension(ii).Xcoast_old = Xcoast_old;
% S.beachextension(ii).Ycoast_old = Ycoast_old;