function [gx gy rsz] = plotARS(ARS)
%PLOTARS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = plotARS(varargin)
%
%   Input: For <keyword,value> pairs call plotARS() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   plotARS
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
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
% Created: 11 Oct 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: plotARS.m 7527 2012-10-18 15:21:25Z bieman $
% $Date: 2012-10-18 23:21:25 +0800 (Thu, 18 Oct 2012) $
% $Author: bieman $
% $Revision: 7527 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/AdaptiveResponseSurface/plotARS.m $
% $Keywords: $

%%

d = find(ARS(1).active, 2);

% create plot grid
lim         = linspace(-10,10,100);
[gx gy]     = meshgrid(lim,lim);

rsz = nan(size(gx));

if any([ARS.hasfit])
    
    dat         = zeros(numel(gx),sum(ARS(1).active));
    dat(:,d)    = [gx(:) gy(:)];
    
    if length(ARS) == 1
        rsz     = reshape(polyvaln(ARS.fit, dat), size(gx));
    else
        rsz     = nan(size(gx));
        
        u_DP = cat(1,ARS.u_DP);
        if ~isempty(u_DP)
            distances   = pointdistance_pairs(u_DP,dat);
            [dm filter] = min(distances,[],1);
            filter      = reshape(filter, size(gx));
            
            for ii = 1:length(ARS)
                if ARS(ii).hasfit
                    rsz_temp(:,:)     = reshape(polyvaln(ARS(ii).fit,dat), size(gx));
                    rsz(filter == ii) = rsz_temp(filter == ii);
                end
            end
        else
            for ii = 1:length(ARS)
                if ARS(ii).hasfit
                    rsz_temp(ii,:,:)     = reshape(polyvaln(ARS(ii).fit,dat), size(gx));
                end
            end
            rsz = feval(@prob_aggregate_z, rsz_temp,'aggregateFunction', ARS(1).aggregateFunction);
            rsz = squeeze(rsz);
        end
    end
end