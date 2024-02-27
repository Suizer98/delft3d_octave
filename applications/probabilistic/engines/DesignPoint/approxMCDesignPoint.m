function result = approxMCDesignPoint(result, varargin)
% approxMCDesignPoint: Approximates Design Point based on result structure from MC routine
%
%   Approximates the Design Point based on the centre of gravity of the
%   failure points of the Monte Carlo results. The routine searches for the
%   crossing of the line between the origin in u-space and the centre of
%   gravity of the failure points and the limit state line by bifurcation.
%   The crossing found is the first approximation of the Design Point.
%   Optionally the result is optimized using an optimization routine. Both
%   the original and the optimized results are added to the original result
%   structure and returned.
%
%   Syntax:
%   [result] = approxMCDesignPoint(result, varargin)
%
%   Input:
%   result      = result structure from MC routine
%   varargin    = 'PropertyName' PropertyValue pairs (optional)
%
%                 'precision'   = precision of Desing Point approximation,
%                                   which is the maximum Z value of
%                                   approximation. The square of this value
%                                   is used as epsZ value for FORM routine
%                                   (default: 0.05)
%                 'method'      = determines the method for approximation
%                                   of the Design Point. By default this is
%                                   the Centre Of Gravity (COG) method, but
%                                   other options are the Average Direction
%                                   (AD) method and the Minimal Distance
%                                   (MD) method (COG/AD/MD, default: COG)
%                 'threshold'   = determines the threshold of the failure
%                                   points used for the approximation of
%                                   the Design Point. Values larger than
%                                   zero and smaller than one are assumed
%                                   to be a percentage of the total number
%                                   of failure points to be taken into
%                                   account. Values larger than one are
%                                   assumed to be an actual number of
%                                   failure points to be used (default: 0)
%                                   WARNING: THIS FEATURE IS FOR DIAGNOSTIC
%                                   PURPOSES ONLY, SINCE THE RESULTS USING
%                                   ALL FAILURE POINTS ARE MUCH BETTER!
%                 'optimize'    = identifier of optimization routine to be
%                                   used (default: none)
%
%   Output:
%   result      = original result structure with Design Point
%                   description(s) added
%
%   Example
%   result = approxMCDesignPoint(result)
%
%   See also MC FORM printDesignPoint plotMCResult

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       B.M. (Bas) Hoonhout
%
%       Bas.Hoonhout@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 13 Mei 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: approxMCDesignPoint.m 7788 2012-12-05 12:46:43Z dierman $
% $Date: 2012-12-05 20:46:43 +0800 (Wed, 05 Dec 2012) $
% $Author: dierman $
% $Revision: 7788 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/DesignPoint/approxMCDesignPoint.m $

%% settings

OPT = struct( ...
    'precision', 0.05, ...
    'method', 'COG', ...
    'threshold', 0, ...
    'optimize', '' ...
);

OPT = setproperty(OPT, varargin{:});

%% approximate design point

% determine stochast names
varNames = {result.Input.Name};

% determine failure indexes
idxFail = find(result.Output.idFail);

% filter failure indexes below threshold out of selection
if OPT.threshold > 0
    % determine failure index ranking based on probability of occurance
    [p idxRank] = sort(prod(result.Output.P(idxFail, :), 2), 'descend');

    % if threshold is larger than one, take that number of indexes from
    % ranking, otherwise assume a percentage is provided
    if OPT.threshold >= 1
        idxFail = idxRank(1:round(OPT.threshold));
    else
        idxFail = idxRank(1:round(OPT.threshold * length(idxFail)));
    end
end

tDP = tic;

    % calculate mode and centre of gravity
    a = zeros(1, length(varNames));

    switch OPT.method
        case 'AD'
            % average direction method

            c = [];
            phi_M1 = [];
            length_M1 = 0;

            % define first non-zero axis as reference axis
            refAxis = find(result.Output.u(idxFail(1), :), 1, 'first');

            % walk through failure points to calculate directions
            for j = 1:length(idxFail)

                % determine failure point in u-space
                x = result.Output.u(idxFail(j), :);

                % determine length reference axis
                refLength = x(refAxis) - a(refAxis);

                % calculate directions of all axes with respect to
                % reference axis
                for i = 1:length(x)

                    % calculate axis length
                    curLength = x(i) - a(i);

                    % determine quarter where axis is located and calculate
                    % direction accordingly
                    if refLength == 0 || curLength == 0
                        phi = 0;
                    else
                        if refLength > 0
                            if curLength > 0
                                phi = atan(curLength / refLength);
                            else
                                phi = 2 * pi + atan(curLength / refLength);
                            end
                        else
                            phi = pi + atan(curLength / refLength);
                        end
                    end

                    % incorporate current direction in the overall average
                    % trying to prevent directions to be defined both
                    % around 0PI and 2PI (average would be 1PI)
                    if j == 1
                        % first direction calculated, define it as average
                        phi_M1(i) = phi;
                    else
                        % correct direction definitions
                        if phi - phi_M1(i) > pi
                            % current point is more than 1PI away from
                            % average, substract 2PI
                            dPhi = phi - phi_M1(i) - 2 * pi;
                        elseif phi - phi_M1(i) < -1 * pi
                            % current point is more than 1PI away from
                            % average, add 2PI
                            dPhi = phi - phi_M1(i) + 2 * pi;
                        else
                            % current point is reasonably close to average
                            dPhi = phi - phi_M1(i);
                        end

                        % update average with current point
                        phi_M1(i) = phi_M1(i) + dPhi / j;
                    end
                end
            end

            % calculate b-vector from average direction
            b = tan(phi_M1);

            length_M1 = sqrt(sum(b.^2)) * refLength;

            % calculate c-vector from b-vector
            c = a + length_M1 .* b;
        case 'MD'
            % minimal disctance method

            c = [];

            % define first non-zero axis as reference axis
            refAxis = find(result.Output.u(idxFail(1), :), 1, 'first');

            % walk through failure points to calculate directions
            minX = [];
            minDistance = Inf;
            for j = 1:length(idxFail)

                % determine failure point in u-space
                x = result.Output.u(idxFail(j), :);

                % determine length reference axis
                refLength = x(refAxis) - a(refAxis);

                % calculate distances of point from mode
                distance = sqrt(sum((x - a).^2));

                if distance < minDistance
                    minDistance = distance;
                    minX = x;
                end
            end

            % define c-vector
            c = minX;
        otherwise
            % centre of gravity method
            weights = repmat(result.Output.P_corr(idxFail, :), 1, size(result.Output.u, 2));
            c       = wmean(result.Output.u(idxFail, :), weights);
    end

    % calculate limit crossing along line between mode and centre of gravity
    designPoint = getLimitCrossing(result, a, c, 'precision', OPT.precision);

    % calculate probability of failure
    designPoint.P = 1 - norm_cdf(sqrt(sum((designPoint.u).^2)), 0, 1);
    designPoint.beta = sqrt(sum(designPoint.u.^2));
    designPoint.alpha = designPoint.u./designPoint.beta;

designPoint.time = toc(tDP);

%% optimize result

designPointOptimized = struct('u', [], 'x', [], 'z', Inf, 'P', 0);

% if first estimation of design point is available, try to optimize
if ~isempty(designPoint.u) && ~any(isnan(designPoint.u)) && ~isempty(OPT.optimize)

    tDPO = tic;
        switch OPT.optimize
            case 'FORM'
                try
                    resultOptimized = FORM(result.Input, ...
                        'startU', designPoint.u, ...
                        'epsZ', OPT.precision^2, ...
                        'x2zFunction', result.settings.x2zFunction, ...
                        'x2zVariables', result.settings.x2zVariables ...
                    );

                    designPointOptimized.z = resultOptimized.Output.z(end);
                    designPointOptimized.u = resultOptimized.Output.u(end, :);
                    designPointOptimized.x = resultOptimized.Output.x(end, :);
                    designPointOptimized.iterations = resultOptimized.Output.Iter;
                    designPointOptimized.calculations = resultOptimized.Output.Calc;
                    designPointOptimized.converged = resultOptimized.Output.Converged;

                    % calculate probability of failure
                    designPointOptimized.P = resultOptimized.Output.P_f;
                catch
                    % throw error
                    error = lasterror;
                    disp(['ERROR: ' error.message]);
                end
        end
    designPointOptimized.time = toc(tDPO) + designPoint.time;

end

%% return variable

% construct return variable
result.Output.designPoint = designPoint;
result.Output.designPointOptimized = designPointOptimized;



