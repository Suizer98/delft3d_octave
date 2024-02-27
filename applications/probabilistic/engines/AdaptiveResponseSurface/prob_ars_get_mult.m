function [z ARS] = prob_ars_get_mult(u, varargin)
%PROB_ARS_GET_MULT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_ars_total(varargin)
%
%   Input: For <keyword,value> pairs call prob_ars_total() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_ars_total
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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
% Created: 27 Sep 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: prob_ars_get_mult.m 7527 2012-10-18 15:21:25Z bieman $
% $Date: 2012-10-18 23:21:25 +0800 (Thu, 18 Oct 2012) $
% $Author: bieman $
% $Revision: 7527 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/AdaptiveResponseSurface/prob_ars_get_mult.m $
% $Keywords: $

%% Settings

OPT = struct(...
    'ARS',      prob_ars_struct_mult,   ...
    'DesignPointDetection', false       ...
);

OPT = setproperty(OPT, varargin{:});

%% read fit

ARS = OPT.ARS;
if length(ARS) > 1 && OPT.DesignPointDetection
    
    z_tot     = nan(size(ARS));
    distances = nan(size(ARS));
    
    for i=1:length(ARS)
        un  = u/(sqrt(sum(u.^2)));
        distances(i)    = pointdistance_pairs(ARS(i).u_DP,un*min([ARS.betamin]));              % Calculate distance between approximated point and ARS design point
        
        if ARS(i).hasfit                                                        % Check if the ARS has a good fit
            z_tot(i)   = polyvaln(ARS(i).fit, u(:,ARS(i).active));
        else
            z_tot(i)   = nan;
        end
    end
    
    [d ii]  = nanmin(distances);
    z       = z_tot(ii);                                                              % The approximation is the value from the ARS of the closest design point
elseif length(ARS) > 1 && ~OPT.DesignPointDetection
    for i=1:length(ARS)
        if ARS(i).hasfit
            z(i) = polyvaln(ARS(i).fit, u(:,ARS(i).active));
        else
            z(i) = nan;
        end
        z   = z(~isnan(z));
    end
    z   = feval(@prob_aggregate_z, z,'aggregateFunction', ARS(1).aggregateFunction);
else
    z       = polyvaln(ARS.fit, u(:,ARS.active));
end