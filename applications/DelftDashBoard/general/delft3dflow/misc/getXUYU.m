function [xu,yu] = getXUYU(x,y,uv)
%GETXUYU Computes X and Y coordinates of U or V points.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: getxuyu.m 5573 2011-12-05 14:56:01Z boer_we $
% $Date: 2011-12-05 15:56:01 +0100 (Mon, 05 Dec 2011) $
% $Author: boer_we $
% $Revision: 5573 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/misc/getxuyu.m $
% $Keywords: $

%% Return matrix of cell centre coordinates

xu=zeros(size(x));
yu=zeros(size(y));
xu(xu==0)=NaN;
yu(yu==0)=NaN;

switch lower(uv)
    case{'u'}
        x1=x(:,1:end-1);
        x2=x(:,2:end);
        y1=y(:,1:end-1);
        y2=y(:,2:end);        
        xu1=0.5*(x1+x2);
        yu1=0.5*(y1+y2);
        xu(:,2:end)=xu1;
        yu(:,2:end)=yu1;
    case{'v'}
        x1=x(1:end-1,:);
        x2=x(2:end,:);
        y1=y(1:end-1,:);
        y2=y(2:end,:);        
        xu1=0.5*(x1+x2);
        yu1=0.5*(y1+y2);
        xu(2:end,:)=xu1;
        yu(2:end,:)=yu1;
end
