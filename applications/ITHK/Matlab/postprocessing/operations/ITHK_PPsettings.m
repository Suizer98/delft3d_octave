function ITHK_PPsettings(sens)
% function ITHK_PPsettings(sens)
% 
% Prepare grid settings for ITHK postprocessing
% 
% INPUT:
%      sens   sensitivity run number
%      S      structure with ITHK data (global variable that is automatically used)
%              .UB(sens).results.PRNdata.year
%              .UB(sens).results.PRNdata.xdist
%              .settings.plotting.barplot.dsrough
%              .settings.plotting.barplot.dsfine
%              .settings.plotting.barplot.widthfine
%              .settings.plotting.barplot.barscalevector
%              .PP(sens).settings.MDAdata_ORIG.Xcoast
%              .PP(sens).settings.MDAdata_ORIG.Ycoast
%
% OUTPUT:
%      S      structure with ITHK data (global variable that is automatically used)
%              .PP(sens).settings.MDAdata_ORIG_OLD
%              .PP(sens).settings.MDAdata_ORIG
%              .PP(sens).settings.MDAdata_NEW
%              .PP(sens).settings.tvec
%              .PP(sens).settings.t0
%              .PP(sens).settings.dsRough
%              .PP(sens).settings.dsFine
%              .PP(sens).settings.dxFine
%              .PP(sens).settings.sVectorLength
%              .PP(sens).settings.x0
%              .PP(sens).settings.y0
%              .PP(sens).settings.s0
%              .PP(sens).settings.sgridRough
%              .PP(sens).settings.sgridFine
%              .PP(sens).settings.idplotrough
%              .PP(sens).settings.widthRough
%              .PP(sens).settings.widthFine
%              .PP(sens).settings.idFR

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

% $Id: ITHK_PPsettings.m 11018 2014-07-31 15:20:51Z boer_we $
% $Date: 2014-07-31 23:20:51 +0800 (Thu, 31 Jul 2014) $
% $Author: boer_we $
% $Revision: 11018 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/operations/ITHK_PPsettings.m $
% $Keywords: $

%% code

fprintf('ITHK postprocessing : Initialising settings\n');

global S

%% Basic ITHK directories and settings
% warning off
% S.settings                     = xml_load('ITHK_settings.xml');
% S.settings.inputdir            = [S.settings.basedir 'Matlab\preprocessing\input\'];
% S.settings.outputdir           = [S.settings.basedir 'UB model\'];
% warning on

%% Load EPSG if necessary
if ~isfield(S,'EPSG')
   S.EPSG=load('EPSG.mat'); 
end

%% General PP settings
% Extract MDAdata for original and updated coastline
%[S.PP(sens).settings.MDAdata_ORIG_OLD]=ITHK_io_readMDA([S.settings.outputdir filesep 'BASIS_ORIG_OLD.MDA']);
%[S.PP(sens).settings.MDAdata_ORIG]=ITHK_io_readMDA([S.settings.outputdir filesep 'BASIS_ORIG.MDA']);
[S.PP(sens).settings.MDAdata_ORIG]=ITHK_io_readMDA([S.settings.outputdir filesep S.settings.CLRdata.mdaname '.MDA']);
[S.PP(sens).settings.MDAdata_NEW]=ITHK_io_readMDA([S.settings.outputdir filesep S.settings.CLRdata.mdaname '.MDA']);

% time settings
S.PP(sens).settings.tvec = S.UB(sens).results.PRNdata.year;
S.PP(sens).settings.t0 = S.settings.CLRdata.from(1);

if ~isfield(S.settings,'plotting')
    S.settings.plotting.barplot = S.settings.barplot;
end

% settings
S.PP(sens).settings.dsRough         = str2double(S.settings.plotting.barplot.dsrough); % grid size rough grid
S.PP(sens).settings.dsFine          = str2double(S.settings.plotting.barplot.dsfine);  % grid size fine grid
S.PP(sens).settings.dxFine          = str2double(S.settings.plotting.barplot.widthfine); % distance from nourishment location where fine grid is used
S.PP(sens).settings.sVectorLength   = str2double(S.settings.plotting.barplot.barscalevector);   % scaling factor for vector length

% initial coast line
S.PP(sens).settings.x0              = S.PP(sens).settings.MDAdata_ORIG.Xcoast; 
S.PP(sens).settings.y0              = S.PP(sens).settings.MDAdata_ORIG.Ycoast; 
S.PP(sens).settings.s0              = distXY(S.PP(sens).settings.MDAdata_ORIG.Xcoast,S.PP(sens).settings.MDAdata_ORIG.Ycoast);

% Rough & fine grids
S.PP(sens).settings.sgridRough      = S.PP(sens).settings.s0(1):S.PP(sens).settings.dsRough:S.PP(sens).settings.s0(end);
S.PP(sens).settings.sgridFine       = S.PP(sens).settings.s0(1):S.PP(sens).settings.dsFine:S.PP(sens).settings.s0(end);
S.PP(sens).settings.idplotrough     = ones(length(S.PP(sens).settings.sgridRough),1);
S.PP(sens).settings.widthRough      = max(mean(diff(S.UB(sens).results.PRNdata.xdist)),S.PP(sens).settings.dsRough/2);
S.PP(sens).settings.widthFine       = max(mean(diff(S.UB(sens).results.PRNdata.xdist)),S.PP(sens).settings.dsFine/2);

% Find ids of fine grid corresponding to rough grid
for ii=1:length(S.PP(sens).settings.sgridRough)
    distFR{ii} = abs(S.PP(sens).settings.sgridFine-S.PP(sens).settings.sgridRough(ii));
    S.PP(sens).settings.idFR(ii) = find(distFR{ii} == min(distFR{ii}),1,'first');
end
% Find ids of UNIBEST grid corresponding to rough grid
for ii=1:length(S.PP(sens).settings.sgridRough)
    distUR{ii} = abs(S.PP(sens).settings.s0-S.PP(sens).settings.sgridRough(ii));
    S.PP(sens).settings.idUR(ii) = find(distUR{ii} == min(distUR{ii}),1,'first');
end

% settings for 'postprocessDUNEGROWTH'
S.settings.dunes.CSTorient   = 'BASIS_ORIG.MDA'; 
S.settings.dunes.yposinitial = str2double(S.settings.indicators.dunes.yposinitial)+S.PP(sens).settings.MDAdata_ORIG.Y1i-S.PP(sens).settings.MDAdata_ORIG.Y1i;

