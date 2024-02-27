function [x1 y1] = ddb_refineD3DGrid(x0, y0, refm, refn)
%DDB_REFINED3DGRID  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [x1 y1] = ddb_refineD3DGrid(x0, y0, refm, refn)
%
%   Input:
%   x0   =
%   y0   =
%   refm =
%   refn =
%
%   Output:
%   x1   =
%   y1   =
%
%   Example
%   ddb_refineD3DGrid
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% Refine Grid

x=zeros(size(x0)+1);
x(x==0)=NaN;
y=x;

x(1:end-1,1:end-1)=x0;
y(1:end-1,1:end-1)=y0;

for i=1:size(x,1)-1
    for j=1:size(x,2)-1
        for k=0:refm
            for l=0:refn
                
                i1=(i-1)*refm+k+1;
                j1=(j-1)*refn+l+1;
                con1=( isnan(x(i  ,j  )) & (k<refm & l<refn) );
                con2=( isnan(x(i+1,j  )) & (k>0    & l<refn) );
                con3=( isnan(x(i+1,j+1)) & (k>0    & l>0   ) );
                con4=( isnan(x(i  ,j+1)) & (k<refm & l>0   ) );
                
                if con1||con2||con3||con4
                    x4(i1,j1)=NaN;
                    y4(i1,j1)=NaN;
                else
                    
                    xa=x(i  ,j  );
                    xb=x(i+1,j  );
                    xc=x(i+1,j+1);
                    xd=x(i  ,j+1);
                    dx1=xb-xa;
                    dx2=xc-xd;
                    
                    fac1x=1-k/refm;
                    fac2x=k/refm;
                    fac1y=1-l/refn;
                    fac2y=l/refn;
                    
                    x2=xa+fac2x*dx1;
                    x3=xd+fac2x*dx2;
                    
                    xtmp=fac1y*x2+fac2y*x3;
                    if isfinite(xtmp)
                        x1(i1,j1)=xtmp;
                    end
                    
                    ya=y(i  ,j  );
                    yb=y(i+1,j  );
                    yc=y(i+1,j+1);
                    yd=y(i  ,j+1);
                    dy1=yd-ya;
                    dy2=yc-yb;
                    
                    y2=ya+fac2y*dy1;
                    y3=yb+fac2y*dy2;
                    
                    ytmp=fac1x*y2+fac2x*y3;
                    if isfinite(ytmp)
                        y1(i1,j1)=ytmp;
                    end
                    
                end
            end
        end
    end
end

x1(x1==0)=NaN;
y1(isnan(x1))=NaN;


