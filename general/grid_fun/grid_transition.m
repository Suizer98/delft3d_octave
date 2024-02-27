function [ff nf gridf error] = grid_transition(cell1, cell2, distance, varargin)
%GRID_TRANSITION Calculates the optimal transition from one grid size to another over a certain distance
%
%   Determines the minimum and maximum number of grid cells that fits in
%   the given distance based on the given grid sizes. Then it calculates
%   for each number of grid cells within this range the factor that
%   increases or decreases the grid size for each succeeding grid cell such
%   that the total length of the transition exactly matches the given
%   distance (within a certain accuracy). From all combinations of number
%   of grid cells and calculated factors, the combination with the smallest
%   error with respect to the bordering grid cell is chosen. With this
%   chosen combination the relative error and the corresponding grid
%   transition is calculated and retured together with the number of cells
%   and corresponding factor.
%
%   Syntax:
%   [ff nf gridf error] = grid_transition(cell1, cell2, distance, varargin)
%
%   Input:
%   cell1       = grid size at first border (no fitting error)
%   cell2       = grid size at second border (possible fitting error)
%   distance    = distance available for transition
%   varargin    = key/value pairs of optional parameters
%                 precision     = precision of fitting (default: 1e-10)
%                 maxLoop       = maximum number of fitting attempts
%                                 (default: 1e5)
%                 maxfac        = maximum grid transition factor to use
%                                 (default: .15)
%                 plot          = flag to plot the calculated grid size
%                                 development along the transition
%                                 (default: false)
%
%   Output:
%   ff          = optimal transition factor
%   nf          = optimal number of grid cells in transition corresponding
%                 to transition factor
%   gridf       = calculated transition grid, without bordering cells
%   error       = relative error at second border with respect to bordering
%                 grid size
%
%   Example
%   grid_transition(cell1, cell2, distance)
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Bas Hoonhout
%
%       bas@hoonhout.com
%
%       Stevinweg 1
%       2628CN Delft
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 2 Dec 2009
% Created with Matlab version: 7.5.0.338 (R2007b)

% $Id: grid_transition.m 5660 2012-01-09 13:56:31Z hoonhout $
% $Date: 2012-01-09 21:56:31 +0800 (Mon, 09 Jan 2012) $
% $Author: hoonhout $
% $Revision: 5660 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/grid_transition.m $
% $Keywords: $

%% settings

OPT = struct( ...
    'precision', 1e-10, ...
    'maxLoop', 1e2, ...
    'maxfac', 1.15, ...
    'plot', false ...
);

OPT = setproperty(OPT, varargin{:});

%% determine cell ranges

% define output variables
nf = 0;
ff = 1;
gridf = [];
error = 0;

% check if transition distance is given
if isempty(distance); return; end;
if diff([cell1 cell2]) == 0; return; end;

% calculate range of number of cells
cells = [cell1 cell2];

nmin = max(1,floor(distance/max(cells)));
nmax = max(1,ceil(distance/min(cells)));

n = nmin:nmax;

%% calculate factors

% calculate factors corresponding to number of cells to exactly fit the
% given transition distance for different number of cells
i = 1;
f = [];
for ni = n
    
    % start with equidistant grid
    fj = [1 1];
    Lj = ones(1,3)*cell1*ni;
    stage = 1;
    
    % fit unil precision in distance is reached
    j = 1;
    while abs(Lj(3) - distance) > OPT.precision
        switch stage
            case 1
                % expand factor ranges to contain given transition distance
                if cell1 > cell2
                    fj(1) = 0.9*fj(1);
                else
                    fj(2) = 1.1*fj(2);
                end
            case 2
                % decrease factor ranges by the bisectional method
                if Lj(3) > distance
                    fj(2) = mean(fj);
                elseif Lj(3) < distance
                    fj(1) = mean(fj);
                end
        end
        
        % calculate upper and lower limit and average length of transition
        Lj(1) = cell1*sum(fj(1).^[1:ni]);
        Lj(2) = cell1*sum(fj(2).^[1:ni]);
        Lj(3) = cell1*sum(mean(fj).^[1:ni]);
        
        % check whether length of transition contains the given transition
        % distance, if so start stage two of fitting
        if (Lj(1) > distance && Lj(2) < distance) || (Lj(1) < distance && Lj(2) > distance)
            stage = 2;
        end
        
        % check whether lower limit has reached almost zero or infinity and
        % the risk of an infinite loop is high
        if fj(1) < OPT.precision || any(isinf(fj)) || any(isnan(fj)) || ...
                (diff(fj) < OPT.precision && j > OPT.maxLoop)
            fj = [Inf Inf];
            break;
        end
        
        j = j + 1;
    end
    
    % store fitted factor for current number of cells for later use
    f(i) = mean(fj);
    
    if f(i) > OPT.maxfac
        % factor too large, discard
        f(i) = nan;
    end
    
    i = i + 1;
    
end

% calculate deviation from ideal gradual transition for all number of cells
% and factor combinations
errors = abs(cell1*f.^(n+1)-cell2);

% find the combination with the minimal error and prepare output variables
i = find(errors == min(errors));

if ~isempty(i)
    nf = n(i);
    ff = f(i);
    error = errors(i)/cell2;
    gridf = cumsum(cell1*ff.^[1:nf]);

    % plot transition, if requested
    if OPT.plot
        figure;
        subplot(1,2,1);plot([0 cell1 cell1+gridf cell1+gridf(end)+cell2],'-xb');
        title({'Grid transition' ...
            ['from ' num2str(cell1) ' to ' num2str(cell2) ' over distance ' num2str(distance)] ...
            ['using ' num2str(nf) ' cells and factor ' num2str(ff) ' with relative error ' num2str(error)]});
        xlabel('cell number'); ylabel('location');
        subplot(1,2,2);plot(diff([0 cell1 cell1+gridf cell1+gridf(end)+cell2]),'-xr');
        xlabel('cell number'); ylabel('grid size');
    end
else
    error('No transition found');
end
