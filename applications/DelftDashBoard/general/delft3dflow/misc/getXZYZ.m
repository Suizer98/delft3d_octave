function [xz,yz] = getXZYZ(x,y)
%GETXZYZ  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = getXZYZ(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getXZYZ
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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

% $Id: getXZYZ.m 5573 2011-12-05 14:56:01Z boer_we $
% $Date: 2011-12-05 22:56:01 +0800 (Mon, 05 Dec 2011) $
% $Author: boer_we $
% $Revision: 5573 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/misc/getXZYZ.m $
% $Keywords: $

%% Return matrix of cell centre coordinates

xz=zeros(size(x));
yz=zeros(size(y));
xz(xz==0)=NaN;
yz(yz==0)=NaN;

x1=x(1:end-1,1:end-1);
x2=x(2:end  ,1:end-1);
x3=x(2:end  ,2:end  );
x4=x(1:end-1,2:end  );

y1=y(1:end-1,1:end-1);
y2=y(2:end  ,1:end-1);
y3=y(2:end  ,2:end  );
y4=y(1:end-1,2:end  );

xz1=0.25*(x1+x2+x3+x4);
yz1=0.25*(y1+y2+y3+y4);

xz(2:end,2:end)=xz1;
yz(2:end,2:end)=yz1;

