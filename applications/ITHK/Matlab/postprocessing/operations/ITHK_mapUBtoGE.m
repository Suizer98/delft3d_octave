function ITHK_mapUBtoGE(sens)
% function ITHK_mapUBtoGE(sens)
%
% MAPS the id's of the measures that are applied on the coast
% 
% INPUT:
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .userinput.phases
%              .userinput.phase(jj).SOSfile
%              .userinput.phase(jj).REVfile
%              .userinput.phase(jj).GROfile
%              .userinput.phase(jj).supids
%              .userinput.phase(jj).revids
%              .userinput.phase(jj).groids
%              .userinput.nourishment(ss).lat
%              .userinput.nourishment(ss).lon
%              .userinput.nourishment(ss).start
%              .userinput.nourishment(ss).stop
%              .userinput.nourishment(ss).idRANGE
%              .userinput.nourishment(ss).volperm
%              .userinput.nourishment(ss).width
%              .userinput.revetment(ss).length
%              .userinput.groyne(ss).length
%              .UB(sens).results.PRNdata
%              .PP(sens).settings.tvec 
%              .PP(sens).coast.x0gridRough
%              .PP(sens).coast.y0gridRough
%              .settings.measures.groyne.updatewidth
%              .EPSG
%
% OUTPUT:
%      S      structure with ITHK data (global variable that is automatically used)
%              .PP(sens).UBmapping.supp_beach
%              .PP(sens).UBmapping.supp_foreshore
%              .PP(sens).UBmapping.supp_mega
%              .PP(sens).UBmapping.rev
%              .PP(sens).UBmapping.gro
%              .PP(sens).GEmapping.supp_beach
%              .PP(sens).GEmapping.supp_foreshore
%              .PP(sens).GEmapping.supp_mega
%              .PP(sens).GEmapping.rev
%              .PP(sens).GEmapping.gro
%
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

% $Id: ITHK_mapUBtoGE.m 11018 2014-07-31 15:20:51Z boer_we $
% $Date: 2014-07-31 23:20:51 +0800 (Thu, 31 Jul 2014) $
% $Author: boer_we $
% $Revision: 11018 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/operations/ITHK_mapUBtoGE.m $
% $Keywords: $

%% code

fprintf('ITHK postprocessing : Remapping data to output grids\n');

global S

NRgridcells   = length(S.UB(sens).results.PRNdata.xSLR(:,1));
NRtimesteps   = length(S.PP(sens).settings.tvec);
NRmappedcells = length(S.PP(sens).coast.x0gridRough);

%% Initialize measures for UB mapping
% Total coastline
S.PP(sens).UBmapping.supp_beach = zeros(NRtimesteps,NRgridcells);
S.PP(sens).UBmapping.supp_foreshore = zeros(NRtimesteps,NRgridcells);
S.PP(sens).UBmapping.supp_mega = zeros(NRtimesteps,NRgridcells);
S.PP(sens).UBmapping.rev = zeros(NRtimesteps,NRgridcells);
S.PP(sens).UBmapping.gro = zeros(NRtimesteps,NRgridcells);

for jj = 1:length(S.userinput.phases)
    %if ~strcmp(lower(strtok(S.userinput.phase(jj).SOSfile,'.')),'basis')
    if isfield(S.userinput.phase(jj).SOSfile,'supids')    
        for ii = 1:length(S.userinput.phase(jj).supids)
            ss = S.userinput.phase(jj).supids(ii); 
            startid      = S.userinput.nourishment(ss).start;
            stopid       = S.userinput.nourishment(ss).stop;
            idrange      = S.userinput.nourishment(ss).idRANGE;
            volperm      = S.userinput.nourishment(ss).volume/S.userinput.nourishment(ss).width;
            THRforeshore = str2num(S.settings.measures.nourishment.THRforeshore);
            THRmega      = str2num(S.settings.measures.nourishment.THRmega);
            if volperm <= THRforeshore
                S.PP(sens).UBmapping.supp_beach(startid+1:stopid,idrange) = 1;
            elseif  volperm >= THRmega
                S.PP(sens).UBmapping.supp_mega(startid+1:stopid,idrange) = 1;
            else
                S.PP(sens).UBmapping.supp_foreshore(startid+1:stopid,idrange) = 1;
            end
        end
    end
    %if ~strcmp(lower(strtok(S.userinput.phase(jj).REVfile,'.')),'basis')
    if isfield(S.userinput.phase(jj).SOSfile,'revids')
        for ii = 1:length(S.userinput.phase(jj).revids)
            ss = S.userinput.phase(jj).revids(ii); 
            S.PP(sens).UBmapping.rev(S.userinput.revetment(ss).start+1:S.userinput.revetment(ss).stop,S.userinput.revetment(ss).idRANGE) = 1;
        end
    end
    %if ~strcmp(lower(strtok(S.userinput.phase(jj).GROfile,'.')),'basis')
    if isfield(S.userinput.phase(jj).SOSfile,'groids')
        for ii = 1:length(S.userinput.phase(jj).groids)
            ss = S.userinput.phase(jj).groids(ii); 
            S.PP(sens).UBmapping.gro(S.userinput.groyne(ss).start+1:S.userinput.groyne(ss).stop,S.userinput.groyne(ss).idNEAREST) = 1;
        end
    end
end

%% Initialize measures for GE mapping
% Mapping on rough grid (for plotting in GE)
S.PP(sens).GEmapping.supp_beach = zeros(NRtimesteps,NRmappedcells);
S.PP(sens).GEmapping.supp_foreshore = zeros(NRtimesteps,NRmappedcells);
S.PP(sens).GEmapping.supp_mega = zeros(NRtimesteps,NRmappedcells);
S.PP(sens).GEmapping.rev = zeros(NRtimesteps,NRmappedcells);
S.PP(sens).GEmapping.gro= zeros(NRtimesteps,NRmappedcells);

for jj = 1:length(S.userinput.phases)
    %if ~strcmp(lower(strtok(S.userinput.phase(jj).SOSfile,'.')),'basis')
    if isfield(S.userinput.phase(jj).SOSfile,'supids')
        for ii = 1:length(S.userinput.phase(jj).supids)
            ss = S.userinput.phase(jj).supids(ii); 
            [x,y] = convertCoordinates(S.userinput.nourishment(ss).lon,S.userinput.nourishment(ss).lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',str2double(S.settings.EPSGcode));
            [idNEAREST,idRANGE]=findGRIDinrange(S.PP(sens).coast.x0gridRough(1,:),S.PP(sens).coast.y0gridRough(1,:),x,y,0.5*S.userinput.nourishment(ss).width);
            startid      = S.userinput.nourishment(ss).start;
            stopid       = S.userinput.nourishment(ss).stop;
            volperm      = S.userinput.nourishment(ss).volume/S.userinput.nourishment(ss).width;
            THRforeshore = str2num(S.settings.measures.nourishment.THRforeshore);
            THRmega      = str2num(S.settings.measures.nourishment.THRmega);
            if volperm < THRforeshore
                S.PP(sens).GEmapping.supp_beach(startid+1:stopid,idRANGE) = 1;
            elseif  volperm > THRmega
                S.PP(sens).GEmapping.supp_mega(startid+1:stopid,idRANGE) = 1;
            else
                S.PP(sens).GEmapping.supp_foreshore(startid+1:stopid,idRANGE) = 1;
            end
            S.userinput.nourishment(ss).idNEAREST2 = idNEAREST;
            S.userinput.nourishment(ss).idRANGE2   = idRANGE;
        end
    end
    %if ~strcmp(lower(strtok(S.userinput.phase(jj).REVfile,'.')),'basis')
    if isfield(S.userinput.phase(jj).SOSfile,'revids')
        for ii = 1:length(S.userinput.phase(jj).revids)
            ss = S.userinput.phase(jj).revids(ii); 
            [x,y] = convertCoordinates(S.userinput.revetment(ss).lon,S.userinput.revetment(ss).lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',str2double(S.settings.EPSGcode));
            [idNEAREST,idRANGE]=findGRIDinrange(S.PP(sens).coast.x0gridRough(1,:),S.PP(sens).coast.y0gridRough(1,:),x,y,0.5*S.userinput.revetment(ss).length);
            S.PP(sens).GEmapping.rev(S.userinput.revetment(ss).start+1:S.userinput.revetment(ss).stop,idRANGE) = 1;
            S.userinput.revetment(ss).idNEAREST2 = idNEAREST;
            S.userinput.revetment(ss).idRANGE2   = idRANGE;
        end
    end
    %if ~strcmp(lower(strtok(S.userinput.phase(jj).GROfile,'.')),'basis')
    if isfield(S.userinput.phase(jj).SOSfile,'groids')
        for ii = 1:length(S.userinput.phase(jj).groids)
            ss = S.userinput.phase(jj).groids(ii);
            [x,y] = convertCoordinates(S.userinput.groyne(ss).lon,S.userinput.groyne(ss).lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',str2double(S.settings.EPSGcode));
            [idNEAREST,idRANGE]=findGRIDinrange(S.PP(sens).coast.x0gridRough(1,:),S.PP(sens).coast.y0gridRough(1,:),x,y,str2double(S.settings.measures.groyne.updatewidth)*S.userinput.groyne(ss).length); 
            S.PP(sens).GEmapping.gro(S.userinput.groyne(ss).start+1:S.userinput.groyne(ss).stop,idNEAREST) = 1;
            S.userinput.groyne(ss).idNEAREST2 = idNEAREST;
            S.userinput.groyne(ss).idRANGE2   = idRANGE;
        end
    end
end

%% Function find grid in range
function [idNEAREST,idRANGE]=findGRIDinrange(Xcoast,Ycoast,x,y,radius)
    dist2 = ((Xcoast-x).^2 + (Ycoast-y).^2).^0.5;
    idNEAREST  = find(dist2==min(dist2));
    dist3 = ((Xcoast-Xcoast(idNEAREST)).^2 + (Ycoast-Ycoast(idNEAREST)).^2).^0.5;
    idRANGE  = find(dist3<radius);
end
end