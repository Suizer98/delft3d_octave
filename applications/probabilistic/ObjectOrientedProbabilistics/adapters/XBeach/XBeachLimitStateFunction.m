function z = XBeachLimitStateFunction(varargin)
%XBeachLimitStateFunction  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   z = XBeachLimitStateFunction(varargin)
%
%   Input: For <keyword,value> pairs call XBeachLimitStateFunction() without arguments.
%   varargin  =
%
%   Output:
%   z =
%
%   Example
%   Untitled
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 16 Oct 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: XBeachLimitStateFunction.m 16860 2020-11-30 16:20:33Z bieman $
% $Date: 2020-12-01 00:20:33 +0800 (Tue, 01 Dec 2020) $
% $Author: bieman $
% $Revision: 16860 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/adapters/XBeach/XBeachLimitStateFunction.m $
% $Keywords: $

%% Settings
OPT = struct(...
    'Ph',               [],         ...
    'PHm0',             [],         ...
    'PTp',              [],         ...
    'D50',              225e-6,     ...
    'JarkusID',         [],         ...
    'MaxErosionPoint',  [],         ...
    'ModelSetupDir',    '',         ...
    'ModelRunDir',      '',         ...
    'ExecutablePath',   '',         ...
    'tstop',            5*3600,     ...
    'RunRemote',        false,      ...
    'NrNodes',          1,          ...
    'QueueType',        'normal-e3',   ...
    'sshUser',          [],         ...
    'sshPassword',      [],         ...
    'LSFChecker',       []);

OPT = setproperty(OPT, varargin{:});
    

%% Check whether run already exists

FolderName          = ['h' num2str(OPT.Ph) '_H' num2str(OPT.PHm0) '_Tp' num2str(OPT.PTp)]; % '_D50' num2str(OPT.D50)];
ModelOutputDir      = fullfile(OPT.ModelRunDir, FolderName);
ModelOutputDir      = strrep(ModelOutputDir, '\', '/');
MaxErosionPoint     = OPT.MaxErosionPoint;
OPT                 = rmfield(OPT, {'ModelRunDir', 'MaxErosionPoint'});

if ~isdir(ModelOutputDir)
    %% Setup & run model
    XBeachProbabilisticRun(ModelOutputDir, OPT(:));
    OPT.LSFChecker.CheckProgress(ModelOutputDir);
else
    OPT.LSFChecker.CheckProgress(ModelOutputDir);
end

%% Limit State Function
zsize       = nc_varsize(fullfile(ModelOutputDir,'xboutput.nc'),'zb');
xi          = nc_varget(fullfile(ModelOutputDir,'xboutput.nc'), 'globalx');
zi          = nc_varget(fullfile(ModelOutputDir,'xboutput.nc'), 'zb',[0 0 0], [1 -1 -1]);
xe          = xi;
ze          = nc_varget(fullfile(ModelOutputDir,'xboutput.nc'), 'zb',[zsize(1)-1 0 0], [1 -1 -1]);
tide        = load(fullfile(ModelOutputDir,'tide.txt'));

if tide(1,2) > max(zi)
    % Waterlevel higher than dune crest, use intersection of 1/100 slope
    % with dune crest level from water height as ErosionPoint
    zReference      = 0;
    xReference      = max(findCrossings(xi,zi,[min(xi),max(xi)],zReference*ones(1,2)));
    if isempty(xReference) || xReference < max(findCrossings(xi,zi,[min(xi),max(xi)],max(zi)*ones(1,2)))
        xReference  = max(xi);
    end
    Slope           = 1/100;
    ErosionPoint    = xReference + (tide(1,2)-max(zi))/Slope;
else
    [TargetVolume, ~, ~] = getVolume('x',xi,'z',zi,'x2',xe,'z2',ze,'LowerBoundary',tide(1,2));
    ErosionResult = getAdditionalErosion(xi, zi, ...
        'TargetVolume', TargetVolume, ...
        'poslndwrd', true, ...
        'x0min', min(xi), ...
        'x0max', max(findCrossings(xi,zi,[min(xi),max(xi)],ones(1,2)*tide(1,2))), ...
        'zmin',tide(1,2));
    
    if ~isempty(ErosionResult.VTVinfo.Xr)
        if ErosionResult.info.precision > 1
            % Eroded volume can't be fit completely in the available volume
            % above waterlevel, add remainder as the distance it takes to
            % erode the mean volume above waterlevel
            ErosionPoint    = ErosionResult.VTVinfo.Xr + ErosionResult.info.precision/(mean(zi(zi>tide(1,2)))-tide(1,2));
        else
            ErosionPoint    = ErosionResult.VTVinfo.Xr;
        end
        % DEBUG: make dune erosion plots to check results
%         hFig    = figure;
%         hAx     = gca;
%         plotDuneErosion(ErosionResult,'xdir','normal')
%         hold on
%         plot(hAx,xe,ze,'b.-')
%         hold off
%         xlim(hAx,[min(xe) max(xe)])
%         ylim(hAx,[min(zi) max(zi)+5])
%         print('-dpng','-r600',[ModelOutputDir '.png'])
%         close(hFig)
    else
        % Erosion volume can't be fitted, take most seaward crossing with
        % waterlevel as ErosionPoint
        ErosionPoint    = min(findCrossings(xi,zi,[min(xi),max(xi)],ones(1,2)*tide(1,2)));
    end
end

z           = MaxErosionPoint - ErosionPoint;

display(['The current exact Z-value is ' num2str(z) '(h = ' num2str(OPT.Ph), ...
    ', Hm0 = ' num2str(OPT.PHm0) ', Tp = ' num2str(OPT.PTp) ')']) %DEBUG