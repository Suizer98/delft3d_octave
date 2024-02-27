function ZI = griddata_remap(X, Y, Z, XI, YI, varargin)
%GRIDDATA_REMAP places regularly spaced xyz column data onto an X,Y grid returning Z
%   
%   Only remaps data from a 1D column to a regularly spaced 2D array, does
%   not interpolate anything.
%
%   Syntax:
%   ZI = griddata_remap(X, Y, Z, XI, YI,<keyword,value>)
%
%   Input:
%   X  = 1D vectore with coordinates
%   Y  = 1D vectore with coordinates
%   Z  = 1D vectore with coordinates
%   XI = XI must be either a 1D vector, or a 2D array made with meshgrid
%   YI = YI must be either a 1D vector, or a 2D array made with meshgrid
%   for floats set keyword 'tolerance'
%
%   Output:
%   ZI = 2D array
%
%   Example
%   griddata_remap
%
%   See also: GRIDDATA, GRIDDATA_NEAREST, GRIDDATA_AVERAGE, INTERP2, BIN2 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       tda
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 21 Apr 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: griddata_remap.m 5973 2012-04-13 18:20:38Z tda.x $
% $Date: 2012-04-14 02:20:38 +0800 (Sat, 14 Apr 2012) $
% $Author: tda.x $
% $Revision: 5973 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/griddata_remap.m $
% $Keywords: $
%% set properties

OPT.errorCheck = true;

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

%% vectorize data
x=X(:);
y=Y(:);
z=Z(:);



nans = isnan(x)|isnan(y)|isnan(z);

x(nans) = [];
y(nans) = [];
z(nans) = [];

%% input check
dimx = size(XI);
dimy = size(YI);

if OPT.errorCheck
    if length(dimx) ~= 2 
        error('XI must be a 1D or 2D array')
    end
    if length(dimy) ~= 2 
        error('YI must be a 1D or 2D array')
    end
end    

dimx(dimx == 1) = [];
dimy(dimy == 1) = [];

if length(dimx) == 2;
    XI = XI(1,:);
else
    XI = XI(:);
end
if length(dimy) == 2;
    YI = YI(:,1);
else
    YI = YI(:);
end

if OPT.errorCheck
     if length(unique(XI)) ~= length(XI);
                 error(['XI and YI must be either 1D vectors, or 2D vectors made with'...
               'meshgrid. Also, no duplicate values are allowed in XI or YI'])
     end
     if length(unique(YI)) ~= length(YI);
        error(['XI and YI must be either 1D vectors, or 2D vectors made with'...
               'meshgrid. Also, no duplicate values are allowed in XI or YI'])
     end
end


[tfx,n] = ismember (x,XI);
[tfy,m] = ismember (y,YI);   
tf = tfx & tfy;
if OPT.errorCheck    
    if all(dimx ~= length(XI))||all(dimy ~= length(YI))
        error(['XI and YI must be either 1D vectors, or 2D vectors made with'...
               'meshgrid. Also, no duplicate values are allowed in XI or YI'])
    end
    if ~(all(tf))
        error('some points could not be mapped to the XI,YI grid, maybe use griddata_average instead');
    end
end


%% remap x and y to rounded gridpoints

ZI = nan(length(YI),length(XI));
ZI(sub2ind(size(ZI),m(tf),n(tf))) = z(tf);
