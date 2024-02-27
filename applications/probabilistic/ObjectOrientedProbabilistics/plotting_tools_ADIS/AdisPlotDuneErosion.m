function AdisPlotDuneErosion(adisObject, varargin)
%ADISPLOTDUNEEROSION  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = AdisPlotDuneErosion(varargin)
%
%   Input: For <keyword,value> pairs call AdisPlotDuneErosion() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   AdisPlotDuneErosion
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
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
% Created: 11 Mar 2014
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id: AdisPlotDuneErosion.m 10382 2014-03-11 15:49:29Z bieman $
% $Date: 2014-03-11 23:49:29 +0800 (Tue, 11 Mar 2014) $
% $Author: bieman $
% $Revision: 10382 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/plotting_tools_ADIS/AdisPlotDuneErosion.m $
% $Keywords: $

%% Settings
OPT = struct(...
    'ColorLimits',      0.2,            ...
    'hLimits',          [0 10],         ...
    'HsLimits',         [6.5 18],       ...
    'TpLimits',         [12 26],        ...
    'MarkerSize',       20,             ...
    'MarkerEdgeColor',  'k',            ...
    'FilterType',       'zero',         ...
    'FigName',          'AdisPlot',     ...
    'PlotARS',          true,           ...
    'PlotBetaSphere',   true,           ...
    'PrintDir',         '',             ...
    'Print',            false);

OPT = setproperty(OPT, varargin{:});

%% Plotting & filtering

filter          = FilterPoints(adisObject, OPT);
[~, ids]        = find(filter' == true);

XValues         = NaN(sum(filter),3);


JarkusID    = 4000760;                  % Change this according to location!
Station1    = 'Steunpunt Waddenzee';    % Change this according to location!
Station2    = 'Eierlandse Gat';         % Change this according to location!

[Lambda, ~] = getLambda_2Stations(Station1, Station2, 'JarkusId', JarkusID);     % Change this according to location!

for iPoint = 1:sum(filter)
    [h, h1, h2, s1, s2]     = getWl_2Stations(norm_cdf(adisObject.LimitState.UValues(ids(iPoint),1), 0, 1), Lambda, Station1, Station2);
    [Hs, Hs1, Hs2, s1, s2]  = getHs_2Stations(norm_cdf(adisObject.LimitState.UValues(ids(iPoint),1), 0, 1), Lambda, h1, h2, s1, s2);
    [Tp, Tp1, Tp2, s1, s2]  = getTp_2Stations(norm_cdf(adisObject.LimitState.UValues(ids(iPoint),1), 0, 1), Lambda, Hs1, Hs2, s1, s2);

    XValues(iPoint, 1)  = h;
    XValues(iPoint, 2)  = Hs;
    XValues(iPoint, 3)  = Tp;
end

aH1 = subplot(2,2,1);
scatter3(aH1, XValues(:, 1), ...
    XValues(:, 2), ...
    XValues(:, 3), ...
    OPT.MarkerSize*ones(size(XValues(:,1))), ...
    adisObject.LimitState.ZValues(filter,1), 'filled', 'MarkerEdgeColor', OPT.MarkerEdgeColor)

xlabel('h [m]')
ylabel('Hs [m]')
zlabel('Tp [s]')
title(['P_{f} = ' num2str(adisObject.Pf)])

axis equal
colormap([cbrewer('seq','Reds',200); flipud(cbrewer('seq','YlOrRd',200))])
caxis([-OPT.ColorLimits OPT.ColorLimits])
axis(aH1,[min(OPT.hLimits) max(OPT.hLimits) min(OPT.HsLimits) max(OPT.HsLimits) min(OPT.TpLimits) max(OPT.TpLimits)])
colorbar


aH2 = subplot(2,2,2);
AddARS(aH2,1,2, adisObject, OPT)
hold(aH2,'on')
scatter(aH2, XValues(:, 1), ...
    XValues(:, 2), ...
    OPT.MarkerSize*ones(size(XValues(:,1))), ...
    adisObject.LimitState.ZValues(filter, 1), 'filled', 'MarkerEdgeColor', OPT.MarkerEdgeColor)

scatter(0,0,10,'k','+')

xlabel(aH2, 'h [m]')
ylabel(aH2, 'Hs [m]')

axis equal
colormap(aH2, [cbrewer('seq','Reds',200); flipud(cbrewer('seq','YlOrRd',200))])
caxis(aH2, [-OPT.ColorLimits OPT.ColorLimits])
axis(aH2, [min(OPT.hLimits) max(OPT.hLimits) min(OPT.HsLimits) max(OPT.HsLimits)])
colorbar
hold(aH2,'off')

aH3 = subplot(2,2,3);
AddARS(aH3, 2, 3, adisObject, OPT)
hold(aH3,'on')
scatter(aH3, XValues(:, 2), ...
    XValues(:, 3), ...
    OPT.MarkerSize*ones(size(XValues(:,1))), ...
    adisObject.LimitState.ZValues(filter, 1), 'filled', 'MarkerEdgeColor', OPT.MarkerEdgeColor)

scatter(0,0,10,'k','+')

xlabel(aH3, 'Hs [m]')
ylabel(aH3, 'Tp [s]')

axis equal
colormap(aH3, [cbrewer('seq','Reds',200); flipud(cbrewer('seq','YlOrRd',200))])
caxis(aH3, [-OPT.ColorLimits OPT.ColorLimits])
axis(aH3, [min(OPT.HsLimits) max(OPT.HsLimits) min(OPT.TpLimits) max(OPT.TpLimits)])
colorbar
hold(aH3,'off')

aH4 = subplot(2,2,4);
AddARS(aH4, 1, 3, adisObject, OPT)
hold(aH4,'on')
scatter(aH4, XValues(:, 1), ...
    XValues(:, 3), ...
    OPT.MarkerSize*ones(size(XValues(:,1))), ...
    adisObject.LimitState.ZValues(filter, 1), 'filled', 'MarkerEdgeColor', OPT.MarkerEdgeColor)

scatter(0,0,10,'k','+')

xlabel(aH4, 'h [m]')
ylabel(aH4, 'Tp [s]')

axis equal
colormap(aH4, [cbrewer('seq','Reds',200); flipud(cbrewer('seq','YlOrRd',200))])
caxis(aH4, [-OPT.ColorLimits OPT.ColorLimits])
axis(aH4, [min(OPT.hLimits) max(OPT.hLimits) min(OPT.TpLimits) max(OPT.TpLimits)])
colorbar
hold(aH4,'off')

if OPT.Print
    print('-r600', '-dpng', fullfile(OPT.PrintDir,[OPT.FigName '_' OPT.FilterType '_XValues']))
end

end

function AdisPlot2DCrossSection(axisHandle, Dim1, Dim2, filter, adisObject, OPT)
scatter(axisHandle, adisObject.LimitState.UValues(filter, Dim1), ...
    adisObject.LimitState.UValues(filter, Dim2), ...
    10*ones(size(adisObject.LimitState.UValues(filter,1))), ...
    adisObject.LimitState.ZValues(filter, 1), 'filled', 'MarkerEdgeColor','k')

scatter(0,0,10,'k','+')

xlabel(axisHandle, adisObject.LimitState.RandomVariables(Dim1).Name)
ylabel(axisHandle, adisObject.LimitState.RandomVariables(Dim2).Name)

axis equal
colormap(axisHandle, [cbrewer('seq','Reds',200); flipud(cbrewer('seq','YlOrRd',200))])
caxis(axisHandle, [-OPT.ColorLimits OPT.ColorLimits])
axis(axisHandle, [-OPT.ULimits OPT.ULimits -OPT.ULimits OPT.ULimits])
colorbar
end

function AddARS(axisHandle, Dim1, Dim2, adisObject, OPT)
if OPT.PlotARS
    if adisObject.LimitState.ResponseSurface.GoodFit
    lim             = linspace(min([OPT.hLimits OPT.HsLimits OPT.TpLimits]),max([OPT.hLimits OPT.HsLimits OPT.TpLimits]),1000);
    [xGrid, yGrid]  = meshgrid(lim,lim);
    
    dims            = 1:3;
    grid            = NaN(length(xGrid(:)),3);
    grid(:,Dim1)    = xGrid(:);
    grid(:,Dim2)    = yGrid(:);
    Dim3            = dims(dims ~= Dim1 & dims ~= Dim2);
    grid(:,Dim3)    = zeros(length(xGrid(:)),1);
    zGrid           = reshape(polyvaln(adisObject.LimitState.ResponseSurface.Fit, grid), size(xGrid));
    
    pcolor(axisHandle, xGrid, yGrid, zGrid);
    shading flat
    else
        warning('This response surface does not have a good fit to the data!');
    end
end
end

function AddBetaSphere(axisHandle, adisObject, OPT)
if OPT.PlotBetaSphere
    [xMin, yMin]    = cylinder(adisObject.LimitState.BetaSphere.MinBeta, 100);
    [xMax, yMax]    = cylinder(adisObject.LimitState.BetaSphere.BetaSphereUpperLimit, 100);
    
    plot(axisHandle,xMin(1,:),yMin(1,:),':g');
    plot(axisHandle,xMax(1,:),yMax(1,:),'-g');
end
end

function filter = FilterPoints(adisObject, OPT)
switch OPT.FilterType
    case 'all'
        filter = adisObject.LimitState.EvaluationIsEnabled;
    case 'exact'
        filter = adisObject.LimitState.EvaluationIsExact & adisObject.LimitState.EvaluationIsEnabled;
    case 'approx'
        filter = ~adisObject.LimitState.EvaluationIsExact & adisObject.LimitState.EvaluationIsEnabled;
    case 'zero'
        filter = adisObject.EvaluationApproachesZero & adisObject.LimitState.EvaluationIsEnabled;
    case 'exactzero'
        filter = adisObject.LimitState.EvaluationIsExact & adisObject.EvaluationApproachesZero & adisObject.LimitState.EvaluationIsEnabled;
    otherwise
        error([OPT.FilterType ' is not a valid filter type!'])
end
end