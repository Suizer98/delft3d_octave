function [dist]=distXY(X,Y, varargin)
%distXY : Computes the distance along a landboundary (first point set at offset value)
%
%   Syntax:
%     function  [dist]=distXY(X,Y, varargin)
% 
%   Input:
%     X            [1xN] vector 
%     Y            [1xN] vector
%     offset       distance at first point (optional)
% 
%   Output:
%     dist    [1xN] vector
%   
%   Example:
%     [dist]=distXY(X,Y)
%     
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: distXY.m 3259 2012-01-24 15:04:23Z huism_b $
% $Date: 2012-01-24 16:04:23 +0100 (Tue, 24 Jan 2012) $
% $Author: huism_b $
% $Revision: 3259 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/engines/distXY.m $
% $Keywords: $


if nargin==3
    offset = varargin{1};
else
    offset = 0;
end

if size(X,2)>size(X,1)
    X=X';
end
if size(Y,2)>size(Y,1)
    Y=Y';
end

dist=[];
if isnumeric(X) & isnumeric(Y)
    if size(X,2)==1 & size(X,1)>1 & size(Y,2)==1 & size(Y,1)>1
        diffX = X(2:end)-X(1:end-1);
        diffY = Y(2:end)-Y(1:end-1);
        diffdist = sqrt(diffX.^2+diffY.^2);
        for iii=1:length(diffdist)
            dist(iii) = sum(diffdist(1:iii))+offset;
        end
        dist = [offset,dist]';
    else
        dist=[0];
    end
else
    dist=[];
end