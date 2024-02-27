function [NAMTRA, XYTRA, transport,namsed]=detran_d3dTransFromHis_single(type,filename,timeStep);
%DETRAN_D3DTRANSFROMHIS_SINGLE Read transport through cross-sections from history files of single Delft3D simulation
%
% Calculate averaged or instantaneous sediment transport through the cross sections in a history-file
% of a single Delft3D simulation.
%
%   Syntax:
%   [crossName, crossXY, transport, namsed]=avgTransFromHis_single(type,filename,timeStep);
%
%   Input:
%   type:       'mean' for mean transport or 'instant' for instantaneous transport.
%   filename:   full name (including path) of one of the trih-files, set to []
%               for interactive selection.
%   timeStep:   specify time step, set to 0 for last time step, set to []
%               for interactive selection
%
%   NB: only for simulations with constant morfac!
%
%   Ouput:
%   crossName:  Char. array with the names of the cross sections
%   crossXY:    X,y-coordinates of the cross sections [M x 4]
%   transport:  Structure with total, bed and suspended transport rates through the cross sections in m3/s
%               Number of transport rates is determined by number of cross sections and number of fractions
%   namsed:     Char. array with names of the available sediment fractions
%
%   See also detran, detran_d3dTransFromHis_mm, detran_d3dTransFromHis_multi, detran_d3dTrans_single

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

transport = [];
NAMTRA=[];
XYTRA=[];
namsed=[];

% check if wlsettings are available
wldir = which('vs_use');
if isempty(wldir)
    try % try wlsettings
        wlsettings;
    catch % wlsettings not found, check if Delft3D has been installed
        d3ddir = getenv('D3D_HOME');
        arch = getenv('ARCH');
        if isempty(d3ddir)
            error('Delft3D installation is required...');
            return
        else
            addpath([d3ddir filesep arch filesep 'matlab']);
        end
    end
end

curDir = pwd;

if isempty(filename)
    % [trimNam,trimPat] = uigetfiles('trih-*.dat', 'Please select trih-file(s)');
    [trimNam,trimPat] = uigetfile('trih-*.dat', 'Please select trih-file(s)','MultiSelect','on');    
    if trimNam ==0
        return
    end
    if ~iscell(trimNam)
        trimNam = {trimNam};
    end
else
    [trimPat, trimNam, filterindex]=fileparts(filename);
    trimNam={trimNam};
end

for jj = 1:length(trimNam)
    N=vs_use([trimPat filesep trimNam{jj}],'quiet');
    if jj==1
        MORFT    = vs_let(N,'his-infsed-serie','MORFT','quiet');
        if nargin<3 || isempty(timeStep)
            timeStep=str2num(char(inputdlg('Specify which time-step to use',[num2str(length(MORFT)) ' timesteps found, specify required time step:'],1,cellstr(num2str(length(MORFT))))));
            if isempty(timeStep)
                return
            end
        elseif timeStep == 0
            timeStep = length(MORFT);
        end
        MORFAC    = vs_let(N,'his-infsed-serie',{1},'MORFAC','quiet');
        simLength = MORFT(timeStep)/MORFAC * 24 * 3600;
        morfStart = min (find(MORFT > 0))-1;
        namsed    = vs_get(N,'his-const','NAMSED','quiet');
        MNTRA     = vs_get(N,'his-const','MNTRA','quiet');
        XYTRA     = vs_get(N,'his-const','XYTRA','quiet')';
        NAMTRA    = vs_get(N,'his-const','NAMTRA','quiet');
     end    
    
    switch type
        case 'mean'
            if ~isempty(deblank(NAMTRA))
                SBTRC(1:size(MNTRA,2),:)= squeeze(vs_let(N,'his-sed-series',{timeStep},'SBTRC','quiet') - vs_let(N,'his-sed-series',{morfStart},'SBTRC','quiet'));
                SSTRC(1:size(MNTRA,2),:)=  squeeze(vs_let(N,'his-sed-series',{timeStep},'SSTRC','quiet') - vs_let(N,'his-sed-series',{morfStart},'SSTRC','quiet'));
                transport{jj}.total     = (SSTRC + SBTRC) ./ simLength;
                transport{jj}.bed       = SBTRC ./ simLength;
                transport{jj}.suspended = SSTRC ./ simLength;
            end
        case 'instant'
            if ~isempty(deblank(NAMTRA))
                SBTR(1:size(MNTRA,2),:) = squeeze(vs_let(N,'his-sed-series',{timeStep},'SBTR','quiet'));
                SSTR(1:size(MNTRA,2),:) = squeeze(vs_let(N,'his-sed-series',{timeStep},'SSTR','quiet'));
                transport{jj}.total     = SSTR + SBTR;
                transport{jj}.bed       = SBTR;
                transport{jj}.suspended = SSTR;
            end
    end
end

% sign correction (make it independend of grid direction, but dependend to transect direction)
MTRA=MNTRA(1:2:end,:);
NTRA=MNTRA(2:2:end,:);
signCor=repmat([sign(diff(MTRA))-sign(diff(NTRA))]',1,size(transport{1}.total,2)); % check if m1 > m2 or n2 > n1 for certain transect, than change sign of calculated transport

for jj=1:length(transport)
    transport{jj}.total=[signCor.*transport{jj}.total];
    transport{jj}.bed=[signCor.*transport{jj}.bed];
    transport{jj}.suspended=[signCor.*transport{jj}.suspended];
end
