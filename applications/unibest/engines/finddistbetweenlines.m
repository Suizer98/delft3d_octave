function [Ycross,baselineNearest]=finddistbetweenlines(coastline,baseline,dx)
%finddistbetweenlines : Function determines the nearest distance from point on coastline to the baseline (reference line of UNIBEST model)
%
%   Syntax:
%     function  [Ycross,baselineNearest]=finddistbetweenlines(coastline,baseline,dx)
% 
%   Input:
%     coastline  [Nx2] ldb of coastline
%     baseline   [Nx2] ldb of baseline
%     dx         (optional) discretisation of baseline (default=1m)
% 
%   Output:
%     Ycross           nearest distance from point on coastline to the baseline (reference line of UNIBEST model)
%     baselineNearest  find nearest point on baseline
%   
%   Example:
%     [Ycross,baselineNearest]=finddistbetweenlines(coastline,baseline)
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

% $Id: finddistbetweenlines.m 2849 2010-10-01 08:30:33Z huism_b $
% $Date: 2010-10-01 10:30:33 +0200 (Fri, 01 Oct 2010) $
% $Author: huism_b $
% $Revision: 2849 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/engines/finddistbetweenlines.m $
% $Keywords: $

if nargin<2
    fprintf('Error : not enough input parameters')
    return
elseif nargin==2
    dx=1;
end
baselineFine=add_equidist_points(dx,baseline);

% loop through points of coastline and find for each point the nearest point of the baseline
baselineNearest=[];
for ii=1:size(coastline,1)
    dist=sqrt((baselineFine(:,1)-coastline(ii,1)).^2+(baselineFine(:,2)-coastline(ii,2)).^2);
    [Ycross(ii,1),id]=min(dist);
    baselineNearest(ii,:)=baselineFine(id,:);
end