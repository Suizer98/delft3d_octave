function [NAMTRA, XYTRA, transport, namsed]=detran_d3dTransFromHis_multi(type,filename,weights,timeStep);
%DETRAN_D3DTRANSFROMHIS_MULTI Read transport through cross-sections from history files of Delft3D simulation with multiple conditions
%
% Calculate averaged or instantaneous sediment transport through the cross sections in a history-file
% of a Delft3D simulation consisting of multiple conditions (no mormerge!). The contribution of each condition
% to the resulting transport is according to the weights in the specified tekal-file.
%
%   Syntax:
%   [crossName, crossXY, transport, namsed]=avgTransFromHis_multi(type,filename,weigths,timeStep);
%
%   Input:
%   type:       'mean' for mean transport or 'instant' for instantaneous transport.
%   filename:   full name (including path) of one of the trih-files, set to []
%               for interactive selection.
%   weights:    full name (including path) of tekal-file with weights, set
%               to [] for interacive selection.
%   timeStep:   specify time step, set to 0 for last time step, set to []
%               for interactive selection
%
%   The various conditions should be stored in seperate sub-dirs, with a counter in the naming.
%   The weight factors will be loaded from a tekal file.
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
%   See also detran, detran_d3dTransFromHis_single, detran_d3dTransFromHis_mm, detran_d3dTrans_multi

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
    [trimNam,trimPat, filterindex] = uigetfile( {'*.dat;*.def','trih-files (*.dat,*.def)'},'Select (one of the) trih file(s)');
    if trimNam==0
        return
    end
    fname = fullfile(trimPat,trimNam); 
else
    fname=filename;
end

N1=vs_use(fname,'quiet');

[p1,p2]=fileparts(fname);
[p3,p4]=fileparts(p1);

if isempty(filename) % in interactive mode
    dataDirPrefix=char(inputdlg('Specify prefix of subdirs with data files','Opti - Datagroup Input Processor',1,{strtok(p4,'0')}));
    if isempty(dataDirPrefix)
        return
    end
else % in scripting mode
    dataDirPrefix=strtok(p4,'0');
end
pat=dir([p3 filesep dataDirPrefix '*']);
pat={pat([pat.isdir]==1).name}';

if isempty(weights)
    [namW,patW]=uigetfile('*.tek','Select tekal-file with weights');
    if namW==0
        return
    end
else
    [patW, namW, extW]=fileparts(weights);
    namW = [namW extW];
end

tek=tekal('read',[patW filesep namW]);
weightFac=tek.Field.Data(:,2)';
weightFac = weightFac / sum (weightFac);

cd(p3);
hW = waitbar(0,'Please wait...');

for ii = 1 : length(pat)
    cd(char(pat{ii}));
    trihFile = dir('trih*.dat');
    
    for jj = 1 : length(trihFile)
        N = vs_use (trihFile(jj).name,'quiet');
        if ii==1
            if jj==1
                MORFT    = vs_let(N,'his-infsed-serie','MORFT','quiet');
                if nargin<4 | isempty(timeStep)
                    timeStep=str2num(char(inputdlg('Specify which time-step to use',[num2str(length(MORFT)) ' timesteps found, specify required time step:'],1,cellstr(num2str(length(MORFT))))));
                    if isempty(timeStep)
                        close(hW);
                        cd(curDir);
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
                MNTRA     = vs_get(N,'his-const','MNTRA','quiet');
            end
            transport{jj}.total= 0;
            transport{jj}.bed= 0;
            transport{jj}.suspended= 0;
            
        end
        if ~isempty(deblank(NAMTRA))
            switch type
                case 'mean'
                    SBTRC     = squeeze(vs_let(N,'his-sed-series',{timeStep},'SBTRC','quiet') - vs_let(N,'his-sed-series',{morfStart},'SBTRC','quiet'));
                    SSTRC     = squeeze(vs_let(N,'his-sed-series',{timeStep},'SSTRC','quiet') - vs_let(N,'his-sed-series',{morfStart},'SSTRC','quiet'));
                    transport{jj}.total     = transport{jj}.total  + weightFac(ii) .* (SSTRC + SBTRC) ./ simLength;
                    transport{jj}.bed       = transport{jj}.bed  + weightFac(ii) .* (SBTRC) ./ simLength;
                    transport{jj}.suspended = transport{jj}.suspended + weightFac(ii) .* (SSTRC) ./ simLength;
                case 'instant'
                    SBTR     = squeeze(vs_let(N,'his-sed-series',{timeStep},'SBTR','quiet'));
                    SSTR     = squeeze(vs_let(N,'his-sed-series',{timeStep},'SSTR','quiet'));
                    transport{jj}.total      = transport{jj}.total + weightFac(ii) .* (SSTR + SBTR);
                    transport{jj}.bed        = transport{jj}.bed + weightFac(ii) .* (SBTR);
                    transport{jj}.suspended  = transport{jj}.suspended + weightFac(ii) .* (SSTR);
            end
        end
    end
    waitbar(ii/length(pat),hW);
    cd ..
end

close(hW);
cd(curDir);

% sign correction (make it independend of grid direction, but dependend to transect direction)
MTRA=MNTRA(1:2:end,:);
NTRA=MNTRA(2:2:end,:);
signCor=repmat([sign(diff(MTRA))-sign(diff(NTRA))]',1,size(transport{1}.total,2)); % check if m1 > m2 or n2 > n1 for certain transect, than change sign of calculated transport

for jj=1:length(transport)
    transport{jj}.total=[signCor.*transport{jj}.total];
    transport{jj}.bed=[signCor.*transport{jj}.bed];
    transport{jj}.suspended=[signCor.*transport{jj}.suspended];
end
