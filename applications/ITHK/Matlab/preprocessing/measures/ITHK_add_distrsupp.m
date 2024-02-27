function ITHK_add_distrsupp(ii,sens)
%function ITHK_add_distrsupp(ii,sens)
%
% Adds distributed nourishments to the SOS file
%
% INPUT:
%      ii     number of beach extension
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .EPSG
%              .distrsupp(ii).lat
%              .distrsupp(ii).lon
%              .distrsupp(ii).volume
%      MDAfile  'BASIC.MDA'
%      SOSfile  '1HOTSPOTS1IT.SOS'
%
% OUTPUT:
%      SOSfile  '1HOTSPOTS1IT.SOS' updated
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

% $Id: ITHK_add_distrsupp.m 10731 2014-05-22 14:41:23Z boer_we $
% $Date: 2014-05-22 22:41:23 +0800 (Thu, 22 May 2014) $
% $Author: boer_we $
% $Revision: 10731 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/measures/ITHK_add_distrsupp.m $
% $Keywords: $

%% code

global S

%% Get info from struct
lat = S.distrsupp(ii).lat;
lon = S.distrsupp(ii).lon;
%mag = S.distrsupp(ii).magnitude;

%% convert coordinates
[x,y]               = convertCoordinates(lon,lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',str2double(S.settings.EPSGcode));

%% read files
[MDAdata]=ITHK_io_readMDA('BASIS.MDA');
[SOSdata0]=ITHK_io_readSOS('1HOTSPOTS1IT.SOS');

%% calculate nourishment information
volumes             = S.distrsupp(ii).volume;

    SOSdata=struct;
    SOSdata.headerline='';
    SOSdata.nrsourcesandsinks=0;
    SOSdata.XW=[];
    SOSdata.YW=[];
    SOSdata.CODE=0;
    SOSdata.Qs=[];
    SOSdata.COLUMN=1;
    SOSdata2=SOSdata;
    
    SOSdata(1)= SOSdata0;
    SOSfilename = '1HOTSPOTS1IT.sos';
    
    %% find gridcells inside range of nourishment
    distance        = distXY(MDAdata.Xi(1:307),MDAdata.Yi(1:307));
    gridcellwidth   = diff(distance);
    gridcellwidth   = [gridcellwidth(1:3:end-2)+gridcellwidth(2:3:end-1)+gridcellwidth(3:3:end)];
    idRANGE         = [2:3:length(MDAdata.QpointsX(1:307))-1];
    SOSdata(2).XW   = MDAdata.QpointsX(idRANGE);
    SOSdata(2).YW   = MDAdata.QpointsY(idRANGE);
    
    
    %% determine magnitude for each grid cell (based on length of grid cells)
    distrfactor        = gridcellwidth/sum(gridcellwidth);
    volumepercell      = distrfactor*volumes; %/length(idRANGE);
    SOSdata(2).CODE    = zeros(length(idRANGE),1);
    SOSdata(2).Qs      = volumepercell;
    SOSdata(2).COLUMN  = zeros(length(idRANGE),1);
    
    %% combine different nourishment and initial data in file
    ids=[];
    for ii=1:length(SOSdata)
        for jj=1:length(SOSdata(ii).XW)
%             dist3           = ((MDAdata.Xcoast-nourishment.x(jj)).^2 + (MDAdata.Ycoast-nourishment.y(jj)).^2).^0.5;  % distance to coast line
%             idNEAREST       = find(dist3==min(dist3));
            
            dist2 = ((MDAdata.QpointsX-SOSdata(ii).XW(jj)).^2 + (MDAdata.QpointsY-SOSdata(ii).YW(jj)).^2).^0.5;
            idNEAREST  = find(dist2==min(dist2));
            
            idVOL = find(ids==idNEAREST(1), 1);
            if isempty(idVOL)
                ids=[ids;idNEAREST(1)];
                SOSdata2.Qs = [SOSdata2.Qs ; SOSdata(ii).Qs(jj)];
                SOSdata2.XW = [SOSdata2.XW ; MDAdata.QpointsX(idNEAREST(1))];
                SOSdata2.YW = [SOSdata2.YW ; MDAdata.QpointsY(idNEAREST(1))];
            else
                SOSdata2.Qs(idVOL)=SOSdata2.Qs(idVOL)+SOSdata(ii).Qs(jj);
            end
        end
    end
    SOSdata2B=SOSdata2;
    SOSdata2=SOSdata2B;
    SOSdata2.CODE=SOSdata2.Qs*0;
    SOSdata2.COLUMN=SOSdata2.Qs*0+1;
    SOSdata2.nrsourcesandsinks=length(SOSdata2.XW);
    ITHK_io_writeSOS(SOSfilename,SOSdata2);
