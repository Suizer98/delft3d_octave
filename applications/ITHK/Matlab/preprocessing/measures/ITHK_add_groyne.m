function ITHK_add_groyne(ii,phase,NGRO,sens)
%function ITHK_add_groyne(ii,phase,NGRO,sens)
%
% Adds groynes to the GRO file
%
% INPUT:
%      ii     number of beach extension
%      phase  phase number (of CL-model)
%      NGRO   number of groynes
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .EPSG
%              .settings.outputdir
%              .userinput.groyne(ii).lat
%              .userinput.groyne(ii).lon
%              .userinput.groyne(ii).filename
%              .userinput.groyne(ii).length
%              .userinput.phase(phase-1).GROfile
%              .settings.measures.groyne.coastlineupdate
%              .settings.measures.groyne.updatewidth
%              .settings.measures.groyne.angleshiftclimateA
%              .settings.measures.groyne.angleshiftclimateB
%      MDAfile  'BASIS.MDA' & 'BASIS_ORIG.MDA'
%      GKLfile  'BASIS.GKL'
%
% OUTPUT:
%      GROfile  file with additional groyne and links to local climate rays
%      RAYfiles name of nearest ray with A,B,C as additional string (for sheltered climates)
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

% $Id: ITHK_add_groyne.m 11018 2014-07-31 15:20:51Z boer_we $
% $Date: 2014-07-31 23:20:51 +0800 (Thu, 31 Jul 2014) $
% $Author: boer_we $
% $Revision: 11018 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/measures/ITHK_add_groyne.m $
% $Keywords: $

%% code

global S

%% get info from struct
lat = S.userinput.groyne(ii).lat;
lon = S.userinput.groyne(ii).lon;

% GRO settings
localclimates = str2double(S.settings.measures.groyne.localclimates);
cstupdate = str2double(S.settings.measures.groyne.coastlineupdate);
updatewidth = str2double(S.settings.measures.groyne.updatewidth);
angleA = str2double(S.settings.measures.groyne.angleshiftclimateA);
angleB = str2double(S.settings.measures.groyne.angleshiftclimateB);

%% convert coordinates
[x,y]               = convertCoordinates(lon,lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',str2double(S.settings.EPSGcode));

%% read files
% MDAdata=ITHK_io_readMDA([S.settings.outputdir 'BASIS.MDA']);
% MDAdata_ORIG=ITHK_io_readMDA([S.settings.outputdir 'BASIS_ORIG.MDA']);
MDAdata_ORIG=ITHK_io_readMDA([S.settings.outputdir S.settings.CLRdata.mdaname '.MDA']);
%GROdata_ORIG=ITHK_io_readGRO([S.settings.outputdir S.userinput.phase(1).GROfile]);
if phase==1 || NGRO>1
    [GROdata]=ITHK_io_readGRO([S.settings.outputdir S.userinput.groyne(ii).filename]);
else
    [GROdata]=ITHK_io_readGRO([S.settings.outputdir S.userinput.phase(phase-1).GROfile]);
end

%% Find groyne location on initial coastline
[idNEAREST,idRANGE]=findGRIDinrange(MDAdata_ORIG.Xcoast,MDAdata_ORIG.Ycoast,x,y,updatewidth*S.userinput.groyne(ii).length);
if ~ismember(idRANGE,[1,2,length(MDAdata_ORIG.Xcoast)-1,length(MDAdata_ORIG.Xcoast)]) %Check whether outside or at boundary of grid
    
    S.userinput.groyne(ii).idNEAREST = idNEAREST;
    S.userinput.groyne(ii).idRANGE = idNEAREST;

    % Groyne points
    S.UB.input(sens).groyne(ii).length = S.userinput.groyne(ii).length;
    Xw = MDAdata_ORIG.Xcoast(idNEAREST);
    Yw = MDAdata_ORIG.Ycoast(idNEAREST);
    s0 = distXY(MDAdata_ORIG.Xcoast,MDAdata_ORIG.Ycoast);
    s1 = s0(idNEAREST);

    %% Update initial coastline around groyne (in MDA)
    %{
    if cstupdate == 1   
        % Beach extension south of groyne (0.5 GRO length)
        if length(idRANGE(1):idNEAREST)>1
            Y1south = interp1([MDAdata_ORIG.Xcoast(idRANGE(1)) MDAdata_ORIG.Xcoast(idNEAREST)],[0 0.5*S.userinput.groyne(ii).length],MDAdata_ORIG.Xcoast(idRANGE(1):idNEAREST));
        end
        Y1_new = MDAdata.Y1i;
        Y1_new(idRANGE(1):idNEAREST) = MDAdata.Y1i(idRANGE(1):idNEAREST)+Y1south;

        % Beach extension nord of groyne  (0.5 GRO length)
        if length(idNEAREST+1:idRANGE(end))>1
            Y1north = interp1([MDAdata_ORIG.Xcoast(idNEAREST) MDAdata_ORIG.Xcoast(idRANGE(end))],[0.5*S.userinput.groyne(ii).length 0],x0(idNEAREST+1:idRANGE(end)));
        end
        Y1_new(idNEAREST+1:idRANGE(end)) = MDAdata.Y1i(idNEAREST+1:idRANGE(end))+Y1north;

        % Refine grid cells around groyne
        MDAdata.nrgridcells=MDAdata.Xi.*0+1;MDAdata.nrgridcells(1)=0;
        MDAdata.nrgridcells(idNEAREST:idNEAREST+1)=8;
        ITHK_io_writeMDA([S.settings.outputdir 'BASIS.MDA'],[MDAdata.Xi MDAdata.Yi],Y1_new,[],MDAdata.nrgridcells);

        % For post-processing (same number of points)
        MDAdata_ORIG.nrgridcells=MDAdata_ORIG.Xi.*0+1;MDAdata_ORIG.nrgridcells(1)=0;
        MDAdata_ORIG.nrgridcells(idNEAREST:idNEAREST+1)=8;
        ITHK_io_writeMDA([S.settings.outputdir 'BASIS_ORIG.MDA'],[MDAdata_ORIG.Xi MDAdata_ORIG.Yi],MDAdata_ORIG.Y1i,[],MDAdata_ORIG.nrgridcells);    
    end
    %}
    %% Add local climates & adjust GROfile
    if localclimates == 1
        % Updated coastline
        MDAdatanew=ITHK_io_readMDA([S.settings.outputdir S.settings.CLRdata.mdaname '.MDA']);
        % Find closest ray in GKL
        [xGKL,yGKL,rayfiles]=ITHK_io_readGKL([S.settings.outputdir S.settings.CLRdata.GKL{1} '.GKL']);
        idRAY=findGRIDinrange(xGKL,yGKL,x,y,0);

        %% Info local climates
        % Ray at GRO
        RAYfilename = rayfiles(idRAY);
        RAY = ITHK_io_readRAY([S.settings.outputdir RAYfilename{1}(2:end-1) '.ray']);

        % Set local climate at GRO and 2 and 3 GRO lengths from GRO
        positions = [0 1 2].*S.userinput.groyne(ii).length;
        angles = [mod(RAY.equi-angleA,360),mod(RAY.equi-angleB,360),RAY.equi];
        names = {[RAYfilename{1}(2:end-1) 'A.RAY'],[RAYfilename{1}(2:end-1) 'B.RAY'],[RAYfilename{1}(2:end-1) 'C.RAY']};
        for jj=1:length(positions)
            distance = abs(s1+positions(jj)-distXY(MDAdatanew.Xcoast,MDAdatanew.Ycoast));
            ids(jj) = find(distance==min(distance));
        end

        %Write rays - if GRO length is small, less climates required
        ids2 = unique(ids);
        RAY.path = {S.settings.outputdir};
        for jj=1:length(ids2)
            RAY.name = names(jj);
            RAY.equi = angles(jj);
            ITHK_io_writeRAY(RAY);
            names2{jj} = names{jj}(1:end-4);
        end
        X = MDAdatanew.Xcoast(ids2);
        Y = MDAdatanew.Ycoast(ids2);
        XY = [X Y];
    end

    %{
    equiA = mod(RAY.equi-angleA,360);
    XA = MDAdatanew.Xcoast(idNEAREST);%MDAdatanew.Xcoast(idNEAREST+8);
    YA = MDAdatanew.Ycoast(idNEAREST);%MDAdatanew.Ycoast(idNEAREST+8);
    % Ray 1 GRO length from GRO
    equiB = mod(RAY.equi-angleB,360);
    distB = abs(s1+S.userinput.groyne(ii).length-distXY(MDAdatanew.Xcoast,MDAdatanew.Ycoast));
    idB = find(distB==min(distB));
    XB = MDAdatanew.Xcoast(idB);
    YB = MDAdatanew.Ycoast(idB);
    % Ray 2 GRO lengths from GRO
    distC = abs(s1+2*S.userinput.groyne(ii).length-distXY(MDAdatanew.Xcoast,MDAdatanew.Ycoast));
    idC = find(distC==min(distC));
    XC = MDAdatanew.Xcoast(idC);
    YC = MDAdatanew.Ycoast(idC);

    %% Summarize
    XY = [XA YA; XB YB; XC YC];
    nameA = [RAYfilename{1}(2:end-1) 'A.RAY'];
    nameB = [RAYfilename{1}(2:end-1) 'B.RAY'];
    nameC = [RAYfilename{1}(2:end-1) 'C.RAY'];
    names = {nameA(1:end-4),nameB(1:end-4),nameC(1:end-4)};

    %% Write RAY files
    RAY.path = {S.settings.outputdir};
    RAY.name = {nameC};
    ITHK_io_writeRAY(RAY);
    RAY.name = {nameA};
    RAY.equi = equiA;
    ITHK_io_writeRAY(RAY);
    RAY.name = {nameB};
    RAY.equi = equiB;
    ITHK_io_writeRAY(RAY);
    %}

    %% GROdata
    Ngroynes = length(GROdata);
    GROdata(Ngroynes+1).Xw = Xw;
    GROdata(Ngroynes+1).Yw = Yw;
    GROdata(Ngroynes+1).Length = S.userinput.groyne(ii).length;%0.2*Length; %Because length is not accurately represented in UNIBEST
    GROdata(Ngroynes+1).BlockPerc = 100;
    GROdata(Ngroynes+1).Yreference = 0;
    GROdata(Ngroynes+1).option = 'right';
    GROdata(Ngroynes+1).xyl = [];
    GROdata(Ngroynes+1).ray_file1 = [];
    if localclimates == 1
        GROdata(Ngroynes+1).xyr = XY;
        GROdata(Ngroynes+1).ray_file2 = names2;
        S.UB.input(sens).groyne(ii).rayfiles = names;
    else
        GROdata(Ngroynes+1).xyr = '';
        GROdata(Ngroynes+1).ray_file2 = '';
        S.UB.input(sens).groyne(ii).rayfiles = '';
    end
    ITHK_io_writeGRO([S.settings.outputdir S.userinput.groyne(ii).filename],GROdata);
    S.UB.input(sens).groyne(ii).GROdata = GROdata;
    S.UB.input(sens).groyne(ii).Ngroynes = length(GROdata);%-length(GROdata_ORIG);%to prevent double writing in PP
    
    % Keep track of user defined groynes
    if ~isfield(S.userinput.userdefined,'GRO')
        len = 0;
    else
        len = length(S.userinput.userdefined.GRO);
    end
    S.userinput.userdefined.GRO(len+1) = GROdata(end);    
end


%% Function find grid in range
function [idNEAREST,idRANGE]=findGRIDinrange(Xcoast,Ycoast,x,y,radius)
    dist2 = ((Xcoast-x).^2 + (Ycoast-y).^2).^0.5;
    idNEAREST  = find(dist2==min(dist2));
    dist3 = ((Xcoast-Xcoast(idNEAREST)).^2 + (Ycoast-Ycoast(idNEAREST)).^2).^0.5;
    idRANGE  = find(dist3<radius);
end
end