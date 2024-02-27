% function varargout = prob_DUROS_example(varargin)
%PROB_DUROS_EXAMPLE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_DUROS_example(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_DUROS_example
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 25 Aug 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: prob_DUROS_example.m 7266 2012-09-21 13:44:20Z heijer $
% $Date: 2012-09-21 21:44:20 +0800 (Fri, 21 Sep 2012) $
% $Author: heijer $
% $Revision: 7266 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/probabilistic/Z/prob_DUROS_example.m $
% $Keywords: $

%% carry out a series of FORM calculations
% the resistance is in this z-function implemented as retreat distance of
% the dune face (in fact the point where the after storm dune face
% intersects the initial profile, the erosion point) with respect to the
% NAP + 5m contour of the initial dune profile. By choosing a series of
% retreat distances, we get insight in the probabilities of 'failure' at
% different locations in the cross-shore.
resultFORM = cellfun(@(Res) FORM(...
    'x2zFunction', @x2z_DUROS,...
    'stochast', exampleStochastVar,...
    'x2zVariables', {'Resistance', Res}),...
    num2cell(40:10:140));

%% create a plot of the probability of failure (=exceedance) as function of
%% the retreat distance
[Res P_f] = deal(NaN(size(resultFORM)));
for ires = 1:length(resultFORM)
    P_f(ires) = resultFORM(ires).Output.P_f;
    Res(ires) = resultFORM(ires).settings.Resistance;
end
semilogy(Res, P_f);
xlabel('Retreat distance [m]')
ylabel('Probability of exceedance [y^{-1}]')

%% carry out another FORM calculation
% in the FORM calculation above, the resulting P_f values are usually not
% round values. By interpolation (see figure) we can find e.g. retreat
% distances for 1e-4, 1e-5 etc. However, if we also would like to have
% design point information in those points, we have to perform another FORM
% calculation for those specific points.
P_fround = ceil(min(log10(P_f))):floor(max(log10(P_f)));

Res_round = sort(round(interp1(log10(P_f), Res, P_fround)));

resultFORMr = cellfun(@(Res) FORM(...
    'x2zFunction', @x2z_DUROS,...
    'stochast', exampleStochastVar,...
    'x2zVariables', {'Resistance', Res}),...
    num2cell(Res_round));

[Resr P_fr] = deal(NaN(size(resultFORMr)));
for ires = 1:length(resultFORMr)
    P_fr(ires) = resultFORMr(ires).Output.P_f;
    Resr(ires) = resultFORMr(ires).settings.Resistance;
end

%% plot DUROS result in specific design points
% carry out one more DUROS calculation for each of the design point
% conditions to visualise the actual cross-shore profile under design point
% conditions
for ires = 1:length(resultFORMr)
    samples = resultFORMr(ires).Output.designpoint;
    samples = rmfield(samples, {'finalP' 'finalU'});
    [z ErosionVolume result] = x2z(samples, 0);
    plotduneerosion(result, figure)
    title(['design point for P_f = 1e' num2str(round(log10(resultFORMr(ires).Output.P_f)))])
    min(result(1).zActive)
end