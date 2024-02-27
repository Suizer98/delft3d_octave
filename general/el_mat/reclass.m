function mtrxr = reclass(mtrx,cls,varargin)
%RECLASS reclasses matrix to plot pcolor or surf with non-equidistant colors
%
%   Syntax:
%   mtrxr = reclass(mtrx,cls,varargin)
%
%   Input:
%   mtrx  = matrix of Z values
%
%   Output:
%   mtrxr = matrix with reclassed Z values
%
%   Example
%       figure;
%       mylevels = [-10 -5 0 .6 .8 1.0 1.25 1.5 1.75 2.0 2.5 3.0 3.5 10.0];
%       mybed = reclass(Z,mylevels);
%       pcolor(X,Y,mybed);
%       shading flat;
%       mymap = colormap(jet(length(mylevels)-1));
%       clim([1:length(mylevels)]);
%       axis equal; axis tight;
%       hold on;
%       colorbardiscrete('test',[1:length(mylevels)-1],'fixed',true,'reallevels',mylevels);
%
%   See also colorbardiscrete

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 ARCADIS
%       ademaj
%
%       jeroen.adema@arcadis.nl
%
%       <ADDRESS>
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
% Created: 12 Aug 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: reclass.m 5172 2011-09-05 07:12:39Z jeroen.adema@arcadis.nl $
% $Date: 2011-09-05 15:12:39 +0800 (Mon, 05 Sep 2011) $
% $Author: jeroen.adema@arcadis.nl $
% $Revision: 5172 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/reclass.m $
% $Keywords: $

%%
OPT.interp=true;
OPT = setproperty(OPT,varargin{:});

if nargin==0;
    varargout = OPT;
    return;
end
%% code
[mmax nmax] = size(mtrx);
mtrxr = NaN(mmax,nmax);

if cls(1) == -Inf
	cls(1) = min(  2*cls(2)-cls(3),  min(min(mtrx))  );
end

if cls(end) == Inf
	cls(end) = max(  2*cls(end-1)-cls(end-2),  max(max(mtrx))  );
end

for k = 2:length(cls)
    i = find(mtrx >= cls(k-1) & mtrx <= cls(k));
    if OPT.interp
    mtrxr(i) = k-1 + (mtrx(i)-cls(k-1))/(cls(k)-cls(k-1));
    else
        mtrxr(i) = k-1+0.5;
    end
end