function ZI = griddata_plus(X, Y, Z, XI, YI, varargin)
%GRIDDATA_PLUS  Like griddata, but with more options.
%
%   Two main improvements over griddata are:
%   1. Inclusion of natural naighbour interpolation, which gives musch
%      better results for most interpolaion situations.
%   2. Inclusion of a triangulation quality criterion (max lenght of a
%      side). This enables clearing of (usually unwanted) results within the
%      convex hull of the data, but outside of the region where good
%      results can be expected;
%
%   Syntax:
%   ZI = griddata_plus(X, Y, Z, XI, YI, varargin)
%
%   Input:
%   X        =
%   Y        =
%   Z        =
%   XI       =
%   YI       =
%   varargin =
%
%   Output:
%   ZI       =
%
%   Example
%   griddata_plus
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
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

% This tool is part of OpenEarthTools.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 04 Nov 2010
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: griddata_plus.m 10249 2014-02-19 15:59:44Z bartjan.spek.x $
% $Date: 2014-02-19 23:59:44 +0800 (Wed, 19 Feb 2014) $
% $Author: bartjan.spek.x $
% $Revision: 10249 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/griddata_plus.m $
% $Keywords: $

%% process varargin

OPT.method         = 'natural';   % interpolation method, supported are 'nearest', 'linear' and 'natural'
OPT.max_length     = 'auto';      % can be 'none', a scalar, or auto.
                                  % auto calculates a value with the max_length_fcn.
OPT.max_length_fcn = @(edgeLength) 2 * percentile(edgeLength,75);

OPT = setproperty(OPT,varargin{:});

%% vectorize input
x = X(:);
y = Y(:);
z = Z(:);

%% make coordinates unique

[dummy,ind,pos] = unique([x,y],'rows');

z2 = z(ind);
if ~isequal(z2(pos),z)
    error('duplicate coordinates with different z values found')
else
    x = x(ind);
    y = y(ind);
    z = z2;
end
clear z2 dummy ind;
%%
if strcmpi(OPT.max_length,'none')
    % make an unconstrained delaunay triangulation;
    DT              = DelaunayTri([x,y]);
else
    tri         = delaunay(x,y);
    
    edge.x      = [x(tri(:,[1 2 3]),1) x(tri(:,[2 3 1]),1)];
    edge.y      = [y(tri(:,[1 2 3]),1) y(tri(:,[2 3 1]),1)];
    edge.l      = ((edge.x(:,2)-edge.x(:,1)).^2 + (edge.y(:,2)-edge.y(:,1)).^2).^.5;
    
    if isscalar(OPT.max_length)
        % do nothing
    elseif strcmpi(OPT.max_length,'auto')
      OPT.max_length = OPT.max_length_fcn(edge.l);
    else
        error('unsupported value for max_length')
    end
    
    bad_tri         = any(reshape((edge.l>OPT.max_length),[],3),2);
    tri(bad_tri,:)  = [];
    trep            = TriRep(tri, x,y);
    constrainment   = freeBoundary(trep);
    % make a constrained delaunay triangulation;
    DT              = DelaunayTri([x,y],constrainment);
end


F               = TriScatteredInterp(DT,z,OPT.method); 
ZI              = F(XI,YI);

if ~strcmpi(OPT.max_length,'none')
    % find the points that are in the delaunay triangulation, outside the
    % constrainment. Set these values to NaN
    mask            = DT.pointLocation(XI(:),YI(:));
    mask            = ismember(mask,find(DT.inOutStatus));
    ZI(~mask)       = NaN;
end
