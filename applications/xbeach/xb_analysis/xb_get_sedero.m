function [sed ero dz R Q P] = xb_get_sedero(x,z,varargin)
%XB_GET_SEDERO  Compute sedimentation and erosion from profiles
%
%   Compute sedimentation and erosion from profile development in time. A
%   single x-axis and multiple z-axes are provided. Crossings with the
%   initial profile are computed and areas of erosion and sedimentation
%   distinguished. Based on a given surge level, the erosion volume and
%   retreat distance above surge level are computed.
%
%   Syntax:
%   [sed ero dz R Q P] = xb_get_sedero(x,z)
%
%   Input:
%   x         = x-axis vector
%   z         = z-axes matrix with time in first dimension
%   varargin  = level:      maximum surge level
%
%   Output:
%   sed       = total sedimentation volume
%   ero       = total erosion volume
%   dz        = profile change
%   R         = first profile crossing above surge level
%   Q         = last profile crossing below surge level
%   P         = one but last profile crossing below surge level
%
%   Example
%   [sed ero] = xb_get_sedero(x, z, 'level, 5)
%
%   See also xb_get_morpho

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
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
% Created: 24 Oct 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_get_sedero.m 11957 2015-05-29 09:25:58Z geer $
% $Date: 2015-05-29 17:25:58 +0800 (Fri, 29 May 2015) $
% $Author: geer $
% $Revision: 11957 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_analysis/xb_get_sedero.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'level',            5 ...
);

OPT = setproperty(OPT, varargin{:});

%% compute sedimentation and erosion

R   = nan(1,size(z,1));
Q   = nan(1,size(z,1));
P   = nan(1,size(z,1));

sed = zeros(1,size(z,1));
ero = zeros(1,size(z,1));

dz  = z-repmat(z(1,:),size(z,1),1);

if(length(x) == size(z,2) && size(x,2) ~= size(z,2))
    x = x';
end

for i = 2:size(dz,1)

    
    [xc zc] = findCrossings(x,z(1,:),x,z(i,:));

    xc1     = xc(zc>OPT.level);
    xc2     = xc(zc<OPT.level);
    
    if isempty(xc1); xc1 = x(end); end;
    if isempty(xc2); xc2 = x(1);   end;
    
    R(i)    = min([Inf xc1]);
    Q(i)    = max([-Inf xc2(xc2<R(i))]);
    P(i)    = max([-Inf xc(xc<Q(i))]);

    iR      = find(x<R(i),1,'last');
    iQ      = find(x<Q(i),1,'last');
    iP      = find(x<P(i),1,'last');

    % accretion area
    if ~isempty(iP) && ~isempty(iQ)
        sed(i)  =          .5 *     (x(iP+1)    - P(i)        ) .*  dz(i,iP+1)                       ;
        sed(i)  = sed(i) + .5 * sum((x(iP+2:iQ) - x(iP+1:iQ-1)) .* (dz(i,iP+2:iQ) + dz(i,iP+1:iQ-1)));
        sed(i)  = sed(i) + .5 *     (Q(i)       - x(iQ)       ) .*  dz(i,iQ)                         ;
    end

    % erosion area
    if ~isempty(iQ) && ~isempty(iR)
        ero(i)  =          .5 *     (x(iQ+1)    - Q(i)        ) .*  dz(i,iQ+1)                       ;
        ero(i)  = ero(i) + .5 * sum((x(iQ+2:iR) - x(iQ+1:iR-1)) .* (dz(i,iQ+2:iR) + dz(i,iQ+1:iR-1)));
        ero(i)  = ero(i) + .5 *     (R(i)       - x(iR)       ) .*  dz(i,iR)                         ;
    end
    
end

ero     = -ero;

xc      = findCrossings(x,z(1,:),x([1 end]),OPT.level*[1 1]);
R(1)    = min([Inf xc]);
