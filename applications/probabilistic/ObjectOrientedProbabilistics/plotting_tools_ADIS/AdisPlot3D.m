function AdisPlot3D(adisObject, varargin)
%ADISPLOT3D  Plots a ADIS object with 3 stochastic variables
%
%   Creates 1 3d plot and 3 2D subplots of each pair of stochastic
%   variables
%
%   Syntax:
%   AdisPlot3D(adisObject, varargin)
%
%   Input: For <keyword,value> pairs call AdisPlot3D() without arguments.
%   adisObject =
%   varargin   =
%
%
%
%
%   Example
%   AdisPlot3D
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
% Created: 28 Feb 2014
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id: AdisPlot3D.m 10382 2014-03-11 15:49:29Z bieman $
% $Date: 2014-03-11 23:49:29 +0800 (Tue, 11 Mar 2014) $
% $Author: bieman $
% $Revision: 10382 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/plotting_tools_ADIS/AdisPlot3D.m $
% $Keywords: $

%% Settings
OPT = struct(...
    'ColorLimits',      0.2,            ...
    'ULimits',          10,             ...
    'FilterType',       'zero',         ...
    'FigName',          'AdisPlot',     ...
    'PlotARS',          true,           ...
    'PlotBetaSphere',   true,           ...
    'PrintDir',         '',             ...
    'Print',            false);

OPT = setproperty(OPT, varargin{:});

%% Plotting & filtering

filter = FilterPoints(adisObject, OPT);

aH1 = subplot(2,2,1);
scatter3(aH1, adisObject.LimitState.UValues(filter, 1), ...
    adisObject.LimitState.UValues(filter, 2), ...
    adisObject.LimitState.UValues(filter, 3), ...
    10*ones(size(adisObject.LimitState.UValues(filter,1))), ...
    adisObject.LimitState.ZValues(filter,1), 'filled', 'MarkerEdgeColor','k')

xlabel(adisObject.LimitState.RandomVariables(1).Name)
ylabel(adisObject.LimitState.RandomVariables(2).Name)
zlabel(adisObject.LimitState.RandomVariables(3).Name)
title(['P_{f} = ' num2str(adisObject.Pf)])

axis equal
colormap([cbrewer('seq','Reds',200); flipud(cbrewer('seq','YlOrRd',200))])
caxis([-OPT.ColorLimits OPT.ColorLimits])
axis([-OPT.ULimits OPT.ULimits -OPT.ULimits OPT.ULimits -OPT.ULimits OPT.ULimits])
colorbar


aH2 = subplot(2,2,2);
AddARS(aH2,1,2, adisObject, OPT)
hold(aH2,'on')
AdisPlot2DCrossSection(aH2, 1, 2, filter, adisObject, OPT)
AddBetaSphere(aH2, adisObject, OPT)
hold(aH2,'off')

aH3 = subplot(2,2,3);
AddARS(aH3, 2, 3, adisObject, OPT)
hold(aH3,'on')
AdisPlot2DCrossSection(aH3, 2, 3, filter, adisObject, OPT)
AddBetaSphere(aH3, adisObject, OPT)
hold(aH3,'off')

aH4 = subplot(2,2,4);
AddARS(aH4, 1, 3, adisObject, OPT)
hold(aH4,'on')
AdisPlot2DCrossSection(aH4, 1, 3, filter, adisObject, OPT)
AddBetaSphere(aH4, adisObject, OPT)
hold(aH4,'off')

if OPT.Print
    print('-r600', '-dpng', fullfile(OPT.PrintDir,[OPT.FigName '_' OPT.FilterType]))
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
    lim             = linspace(-OPT.ULimits,OPT.ULimits,1000);
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