function [x1 y1 mcut ncut] = CutNanRows(x0, y0)
%CUTNANROWS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [x1 y1 mcut ncut] = CutNanRows(x0, y0)
%
%   Input:
%   x0   =
%   y0   =
%
%   Output:
%   x1   =
%   y1   =
%   mcut =
%   ncut =
%
%   Example
%   CutNanRows
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%

% Find number of cells to cut off original grid because entire row or
% column is NaN

nx=size(x0,1);
ny=size(x0,2);

mcut=[0 0];
ncut=[0 0];

% left
for i=1:nx
    if isnan(max(x0(i,:)))
        mcut(1)=i;
    else
        break
    end
end
% right
k=0;
for i=nx:-1:1
    k=k+1;
    if isnan(max(x0(i,:)))
        mcut(2)=k;
    else
        break
    end
end
% bottom
for i=1:ny
    if isnan(max(x0(:,i)))
        ncut(1)=i;
    else
        break
    end
end
% top
k=0;
for i=ny:-1:1
    k=k+1;
    if isnan(max(x0(:,i)))
        ncut(2)=k;
    else
        break
    end
end

m1=1+mcut(1);
m2=nx-mcut(2);
n1=1+ncut(1);
n2=ny-ncut(2);
x1=x0(m1:m2,n1:n2);
y1=y0(m1:m2,n1:n2);


