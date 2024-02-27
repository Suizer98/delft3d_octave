function d3dTransData=detran_d3dTrans_single(type,filename,timeStep,save);
%DETRAN_D3DTRANS_SINGLE Read u,v-transport data from a single Delft3D simulation
%
% Calculate averaged or instantaneous sediment transport (u-comp & v-comp) of a single 
% Delf3D simulation.
%
%   Syntax:
%   d3dTransData=detran_d3dTrans_single(type,filename,timeStep,save);
%
%   Input:
%   type:       'mean' for mean transport or 'instant' for instantaneous transport.
%   filename:   full name (including path) of one of the trim-files, set to []
%               for interactive selection.
%   timeStep:   specify time step, set to 0 for last time step, set to []
%               for interactive selection
%   save        set to 1 for saving output to a mat-file (optional).
%
%   NB: only for simulations with constant morfac!
%
%   Ouput:
%   d3dTransData: structure with the followin fields:
%                 xcor    = x-coordinates of model grid
%                 ycor    = y-coordinates of model grid
%                 alfa    = orientation m-axis w.r.t x-axis (degrees)
%                 tsu     = avg. suspended sediment transport in u-direction
%                 tsv     = avg. suspended sediment transport in v-direction
%                 tbu     = avg. bedload sediment transport in u-direction
%                 tbv     = avg. bedload sediment transport in v-direction
%                 tsuPlus = gross positive avg. suspended sediment transport in u-direction
%                 tsuMin  = gross negative avg. suspended sediment transport in u-direction
%                 tsvPlus = gross positive avg. suspended sediment transport in v-direction
%                 tsvMin  = gross negative avg. suspended sediment transport in v-direction
%                 tbuPlus = gross positive avg. bedload sediment transport in u-direction
%                 tbuMin  = gross negative avg. bedload sediment transport in u-direction
%                 tbvPlus = gross positive avg. bedload sediment transport in v-direction
%                 tbvMin  = gross negative avg. bedload sediment transport in v-direction
%
%                 All output transports are in m3/s!
%
%   See also detran, detran_d3dTrans_mm, detran_d3dTrans_multi, detran_d3dTransFromHis_single

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

if nargin<4
    save=0;
end

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

switch type
    case 'mean'
        series='map-avg-series';
        postfix='A';
    case 'instant'
        series='map-sed-series';
        postfix='';
end

curDir = pwd;

if isempty(filename)
    if ~isdeployed
        if str2double(datestr(datenum(version('-date')),10)) > 2011
            disp(['A bug in Matlab 2013 ignores the getfile through ui function in Detran']);
            disp(['This is avoided automatically by using internal debugging']);
            disp(['Though this requires the user to press F5 (or click ''Continue'' in the Matlab ''Run'' tab)']);
            % Contact Freek Scheel for issues with this, or use any Matlab version from 2009-2011
            this_file_in_struct = textscan(fopen(which(mfilename)),'%s','Delimiter','\n'); % get the entire file
            for ii=1:size(this_file_in_struct{:},1) % Make it a char variable
                this_file_in_text(ii,1) = this_file_in_struct{1}(ii,1);
            end
            function_line = find(cellfun(@isempty,strfind(this_file_in_text,['[names, pat] = uigetfile(''trim-*.dat'',''Please select trim-file(s)'',''MultiSelect'',''on'');']))==0); % these are the line where the function is called (can be multiple, is also including this line)
            eval(['dbstop in detran_d3dTrans_single at ' num2str(function_line(1))]);
            warning_state = warning; warning on; warning('Press F5 to continue (this is implemented as you''re using a new version of matlab'); eval(['warning ' warning_state(1,1).state]);
        end
    end
    [names, pat] = uigetfile('trim-*.dat','Please select trim-file(s)','MultiSelect','on'); % Press F5 when debug mode is applied
    if ~isdeployed
        if str2double(datestr(datenum(version('-date')),10)) > 2011
            eval(['dbclear in detran_d3dTrans_single at ' num2str(function_line(1))]);
        end
    end
    if names == 0
        disp('No file was supplied');
        d3dTransData = [];
        return
    end
    if ~iscell(names)
        names = {names};
    end
else
    [pat, names, filterindex]=fileparts(filename);
    names={names};
end

hW = waitbar(0,'Please wait...');

for jj = 1 : length(names)
    N = vs_use ([pat filesep names{jj}],'quiet');
    grpDatNr=find(strcmp({N.GrpDat.Name},series));
    if isempty(grpDatNr)
        error(['Required group type: ''' series ''' is not found in file ' names{jj}]);
    end
    if timeStep == 0;
        lastTimeStep = N.GrpDat(grpDatNr).SizeDim;
    elseif isempty(timeStep)
        lastTimeStep=str2num(char(inputdlg('Specify which time-step to use',[num2str(N.GrpDat(grpDatNr).SizeDim) ' timesteps found, specify required time step:'],1,cellstr(num2str(N.GrpDat(grpDatNr).SizeDim)))));
        if isempty(lastTimeStep)
            d3dTransData = [];
            close(hW);
            return
        end
    else
        lastTimeStep = timeStep;
    end
    d3dTransData.namSed {jj} = vs_get(N,'map-const','NAMSED','quiet');
    sbuua = vs_get(N,series,{lastTimeStep},['SBUU' postfix],'quiet');
    sbvva = vs_get(N,series,{lastTimeStep},['SBVV' postfix],'quiet');
    ssuua = vs_get(N,series,{lastTimeStep},['SSUU' postfix],'quiet');
    ssvva = vs_get(N,series,{lastTimeStep},['SSVV' postfix],'quiet');
    d3dTransData.tbu {jj} = sbuua;
    d3dTransData.tbv {jj} = sbvva;
    d3dTransData.tsu {jj} = ssuua;
    d3dTransData.tsv {jj} = ssvva;
    d3dTransData.xcor   {jj} = vs_get(N,'map-const','XCOR','quiet');
    d3dTransData.ycor   {jj} = vs_get(N,'map-const','YCOR','quiet');
    d3dTransData.alfa   {jj} = vs_get(N,'map-const','ALFAS','quiet');
    d3dTransData.tsuPlus{jj} = zeros(size(sbuua));
    d3dTransData.tsuMin {jj} = zeros(size(sbuua));
    d3dTransData.tsvPlus{jj} = zeros(size(sbuua));
    d3dTransData.tsvMin {jj} = zeros(size(sbuua));
    d3dTransData.tbuPlus{jj} = zeros(size(sbuua));
    d3dTransData.tbuMin {jj} = zeros(size(sbuua));
    d3dTransData.tbvPlus{jj} = zeros(size(sbuua));
    d3dTransData.tbvMin {jj} = zeros(size(sbuua));
    d3dTransData.tbuPlus{jj}(sbuua > 0) = sbuua(sbuua > 0);
    d3dTransData.tbuMin {jj}(sbuua < 0) = sbuua(sbuua < 0);
    d3dTransData.tsuPlus{jj}(ssuua > 0) = ssuua(ssuua > 0);
    d3dTransData.tsuMin {jj}(ssuua < 0) = ssuua(ssuua < 0);
    d3dTransData.tbvPlus{jj}(sbvva > 0) = sbvva(sbvva > 0);
    d3dTransData.tbvMin {jj}(sbvva < 0) = sbvva(sbvva < 0);
    d3dTransData.tsvPlus{jj}(ssvva > 0) = ssvva(ssvva > 0);
    d3dTransData.tsvMin {jj}(ssvva < 0) = ssvva(ssvva < 0);
    waitbar(jj/length(names),hW);
end

close(hW);

if isempty(filename)
    d3dTransData.runID = [pat filesep names{1}];
else
    d3dTransData.runID = filename;
end

cd(curDir);

if save==1
    [nam pat]=uiputfile('d3dTrans.mat','Save file as');
    save([pat nam],'d3dTransData');
end