function ITHK_add_nourishment(index,phase,sens)
%function ITHK_add_nourishment(index,phase,sens)
%
% Adds nourishments to the SOS file
%
% INPUT:
%      index  number of nourishment ID
%      phase  phase number (of CL-model)
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .EPSG
%              .settings.outputdir
%              .userinput.nourishment(ss).lat
%              .userinput.nourishment(ss).lon
%              .userinput.nourishment(ss).volume
%              .userinput.nourishment(ss).width
%              .userinput.nourishment(ss).category
%              .userinput.phase(phase).SOSfile
%              .userinput.phase(phase).supids
%              .userinput.phase(phase).supcat
%      MDAfile  'BASIC.MDA'
%      SOSfile  'hotspots1locIT.SOS' file with already defined nourishments
%
% OUTPUT:
%      SOSfile  'hotspots1locIT_cont.SOS' file with already defined and new nourishments
%      S      structure with ITHK data (global variable that is automatically used)
%              .UB.input(sens).nourishment(ss).SOSdata
%              .userinput.nourishment(ss).idRANGE
%              .userinput.nourishment(ss).idNEAREST
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

% $Id: ITHK_add_nourishment.m 11018 2014-07-31 15:20:51Z boer_we $
% $Date: 2014-07-31 23:20:51 +0800 (Thu, 31 Jul 2014) $
% $Author: boer_we $
% $Revision: 11018 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/measures/ITHK_add_nourishment.m $
% $Keywords: $

%% code

global S

%% Get info from struct
ss = S.userinput.phase(phase).supids(index);
lat = S.userinput.nourishment(ss).lat;
lon = S.userinput.nourishment(ss).lon;

%% convert coordinates
[x,y]               = convertCoordinates(lon,lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',str2double(S.settings.EPSGcode));

%% read files
[MDAdata]=ITHK_io_readMDA([S.settings.outputdir S.settings.CLRdata.mdaname '.MDA']);
[SOSdata0]=ITHK_io_readSOS([S.settings.outputdir S.userinput.phase(phase).SOSfile]);
if strcmp(S.userinput.phase(phase).supcat{index},'cont') || strcmp(S.userinput.phase(phase).supcat{index},'distr')
    if exist([S.settings.outputdir 'nourshment_cont.sos'],'file')
        SOSdata_cont=ITHK_io_readSOS([S.settings.outputdir 'nourshment_cont.sos']);
    else
        SOSdata_cont=ITHK_io_readSOS([S.settings.outputdir S.settings.CLRdata.SOS{1} '.SOS']);
        ITHK_io_writeSOS([S.settings.outputdir 'nourshment_cont.sos'],SOSdata_cont);
    end
end

%% calculate nourishment information
nourishment          = struct;
nourishment.name     = 'nourishment';
nourishment.x        = x;
nourishment.y        = y;
nourishment.volume   = S.userinput.nourishment(ss).volume;
nourishment.width    = 0.5*S.userinput.nourishment(ss).width;

%% write a SOS file (sources and sinks)
SOSfilename = [S.settings.outputdir S.userinput.phase(phase).SOSfile];
ITHK_io_writeSOS(SOSfilename,SOSdata0);
%nourishment.volume = volumes;
%nourishment.width  = 0.5*width;%must be radius
if strcmp(S.userinput.nourishment(ss).category,'distr')||strcmp(S.userinput.nourishment(ss).category,'distrsupp_single')
    [SOSdata2,idNEAREST,idRANGE] = ITHK_addUNIFORMLYDISTRIBUTEDnourishment(MDAdata,nourishment,SOSfilename);
else
    [SOSdata2,idNEAREST,idRANGE] = ITHK_addTRIANGULARnourishment(MDAdata,nourishment,SOSfilename);
end

S.UB.input(sens).nourishment(ss).SOSdata = nourishment;
S.userinput.nourishment(ss).idRANGE = idRANGE;
S.userinput.nourishment(ss).idNEAREST = idNEAREST;

% Update cont nourishment file
if strcmp(S.userinput.phase(phase).supcat{index},'cont') 
    [SOSdata_cont2,idNEAREST,idRANGE] = ITHK_addTRIANGULARnourishment(MDAdata,nourishment,[S.settings.outputdir 'nourshment_cont.sos']);
elseif strcmp(S.userinput.phase(phase).supcat{index},'distr')
    [SOSdata_cont2,idNEAREST,idRANGE] = ITHK_addUNIFORMLYDISTRIBUTEDnourishment(MDAdata,nourishment,[S.settings.outputdir 'nourshment_cont.sos']);
end

% Keep track of user defined cont nourishments
if ~isfield(S.userinput.userdefined,'SOS')
    len = 0;
else
    len = length(S.userinput.userdefined.SOS);
end
if strcmp(S.userinput.phase(phase).supcat{index},'cont')
    SOSfilename = [S.settings.outputdir 'cont_phase' num2str(phase) '.SOS'];
    [SOSdata2,idNEAREST,idRANGE] = ITHK_addTRIANGULARnourishment(MDAdata,nourishment,SOSfilename);
    S.userinput.userdefined.SOS(len+1) = SOSdata2;
    delete(SOSfilename)
end

%if strcmp(S.userinput.phase(phase).supcat{index},'cont') || strcmp(S.userinput.phase(phase).supcat{index},'distr')
%    ITHK_io_writeSOS([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],SOSdata2);
%end