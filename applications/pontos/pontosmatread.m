function data = pontosmatread(matfilename)
%PONTOSMATREAD reads the output data from a PonTos mat file and puts them
% in a struct (ALPHA RELEASE, UNDER CONSTRUCTION)
%
%   PonTos is an integrated conceptual model for Shore Line Management,
%   developed to assess the long-term and large-scale development
%   of coastal stretches. It is originally based on the multi-layer model
%   that was used to predict the development of the Dutch Wadden coast
%   [Steetzel, 1995].
%
%   The output of the PonTos-model for a specific case is gathered in a
%   file Case.MAT. This is a TEGAGX formatted ASCII file that has no
%   relation with Matlab mat files.
%
%   Syntax:
%   data = pontosmatread(matfilename)
%
%   Input:
%   matfilename  = filename of the PonTos mat files (PonTos output)
%
%   Output:
%   data = struct containing PonTos output blocks
%
%   Example
%   matfilename =
%   'l:\A1367_Planstudie-Delflandse-kust\PonTos\Results\Run_t_Sch_PBU1n_50.mat';
%   data = pontosmatread(matfilename);
%
%   See also tekal.m from the Delft3D matlab toolbox
%
% Alphabetic  summary of output blocks
% CLnn    MCL-layer positions
% CPnn    Coastal Profile location
% CSyy    Coastal Sectoral relative change per layer
% CXyy    longshore relative change per layer
% DXyy    total yearly longshore disharge and flow velocity distribution
% FX      Layer levels and sedimentsize
% GL      Groyne locations
% HCND    Hydraulic conditions (waves, waterlevels and currents)
% NLSyy   Distribution of Layer Auto-Nourished Volumes per section
% NLXyy   Longshore distribution of Layer Auto-Nourished Volumes
% NTSyy   Distribution of total Nourished Volumes per section
% NTXyy   Longshore distribution of total Nourished Volumes
% PLnn    Location of local Profile no. nn
% QPnn    Compound Q-Phi curve for wave climate table no. nn
% QTyy    total yearly Tide-induced longshore transport rate
% QWyy    total yearly Wave-induced longshore transport rate
% QXyy    total yearly longshore transport rate
% QYyy    total yearly cross-shore transport rate
% SBnn    Boundary position coastal Section no. nn
% SB-I    Inner boundary positions
% SB-O    Outer boundary positions
% SGnn    Structure - Groyne no. nn
% SGA     Structure - All groynes
% SVyy    Summary of Section Volumes changes at output yy
% TCnn    Time evolution of Cross-shore transport in local Profile no. nn
% TCS     Overview of Tidal Climate Stations
% TGV     Time evolution of Global Volumes
% THC     Time evolution of Hydraulic Conditions
% TNLS    Auto-layer nourished volumes per section
% TNV     Time evolution of Nourishment Volumes
% TPnn    Time evolution of Coastal Profile no. nn
% TQnn    Time evolution of Longshore transport at section boundary no. nn
% TSnn    Time evolution of coastal Section no. nn
% TSA     Time evolution of All coastal Sections
% TTS     Time evolution of Time Stepping data
% WCS     Overview of Wave Climate Stations
% WXyy    Relative layer distances at output yy
% XCyy    Layer contour position using cell Centres
% XYyy    Layer contour position using cell boundaries
% YCLy    Position of MCL at output yy
% YZnnyy  cross-shore profile no. nn at output yy
%
% With nn for specific number
%      yy at a specific time interval


%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Alkyon Hydraulic Consultancy & Research
%       Bart Grasmeijer
%
%       bart.grasmeijer@alkyon.nl
%
%       P.O. Box 248
%       8300 AE Emmeloord
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Aug 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: pontosmatread.m 2983 2010-08-24 06:46:33Z b.t.grasmeijer@arcadis.nl $
% $Date: 2010-08-24 14:46:33 +0800 (Tue, 24 Aug 2010) $
% $Author: b.t.grasmeijer@arcadis.nl $
% $Revision: 2983 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/pontos/pontosmatread.m $
% $Keywords: $

%%


fid = fopen(matfilename);
tline = fgetl(fid);
while ischar(tline)
    tline = fgetl(fid);
    if findstr(tline,'active layers');                                      % find number of active layers
        tmpline = tline;
        tmpline(findstr(tline,'active layers'):end) = [];
        tmpline(1) = [];
        data.nroflayers = str2double(tmpline);
    end
    
    if findstr(tline,'specific sections active');                           % find number of active sections
        tmpline = tline;
        tmpline(findstr(tline,'specific sections active'):end) = [];
        tmpline(1) = [];
        data.nrofsections = str2double(tmpline);
    end
    
    if findstr(tline,'specific profiles active');                           % find number of active profile
        tmpline = tline;
        tmpline(findstr(tline,'specific profiles active'):end) = [];
        tmpline(1) = [];
        data.nrofprofiles = str2double(tmpline);
    end
    
    if findstr(tline,'groyne(s) active');                                   % find number of active groynes
        tmpline = tline;
        tmpline(findstr(tline,'groyne(s) active'):end) = [];
        tmpline(1) = [];
        data.nrofgroynes = str2double(tmpline);
    end
    
    if findstr(tline,'-Time')
        tline = fgetl(fid);
        if findstr(tline,'output intervals');                                   % find outputintervals
            tmpline = tline;
            tmpline(findstr(tline,'output intervals'):end) = [];
            tmpline(1) = [];
            outputintervals = str2double(tmpline);
            tline = fgetl(fid);
            tmpline = tline;
            tmpline(1:12) = [];
            tmpline(findstr(tmpline,'-'):end) = [];
            tbegin = str2double(tmpline);
            tmpline = tline;
            tmpline(1:findstr(tmpline,'-')) = [];
            tmpline(findstr(tmpline,'yr'):end) = [];
            tend = str2double(tmpline);
            data.years = tbegin:(tend-tbegin)/(outputintervals-1):tend;
        else
           tbegin = 0;
           tend = 0;
           outputintervals = 0;
           data.years = 0;
        end
    end
end
fclose(fid);

FileInfo = tekal('open',matfilename);
for i = 1:length(FileInfo.Field)
    if ~isempty(strfind(FileInfo.Field(i).Name,'@'))
        FileInfo.Field(i).Name(strfind(FileInfo.Field(i).Name,'@'))='_';
    end
    
    if ~isempty(strfind(FileInfo.Field(i).Name,'SB-I'))
        FileInfo.Field(i).Name='SB_I';
    end
    
    if ~isempty(strfind(FileInfo.Field(i).Name,'SB-O'))
        FileInfo.Field(i).Name='SB_O';
    end
    
    if sum((strfind(FileInfo.Field(i).Name,'_'))==1)>0
        FileInfo.Field(i).Name(1)='x';
    end
    if isempty(strfind(FileInfo.Field(i).Name,'CMT'));
        data.(FileInfo.Field(i).Name) = tekal('read',FileInfo,i);
    end
end

data.dt = diff(data.years);

cumsumdt = cumsum(data.dt);

NLXi = [];

j = 1;
data_fieldnames = fieldnames(data);
for i = 1:length(data_fieldnames)
    if ~isempty(findstr(char(data_fieldnames(i)),'NLX')) && isempty(findstr(char(data_fieldnames(i)),'xNLX'))  % find NLX indexes
        NLXi(j) = i;
        j = j+1;
    end
end

%% add Longshore distribution of Layer Auto-Nourished Volumes averaged per
%% time block (in output only available as averaged over total time from 
%% start of run)
for i = 1:length(NLXi)
    NLXstep = char(data_fieldnames(NLXi(i)));
    if i==1
        data.(NLXstep)(:,4) = data.(NLXstep)(:,3).*cumsumdt(i);        
    else
        NLXprevstep = char(data_fieldnames(NLXi(i-1)));
        data.(NLXstep)(:,4) = data.(NLXstep)(:,3).*cumsumdt(i)-data.(NLXprevstep)(:,3).*cumsumdt(i-1);
    end
    data.(NLXstep)(:,4) = data.(NLXstep)(:,4)./data.dt(i);
end

