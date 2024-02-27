function [m,n]=findgridcell(posx0,posy0,x,y)
%findgridcell  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = findgridcell(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   findgridcell
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
m=zeros(size(posx0));
n=zeros(size(posx0));
x1=x(1:end-1,1:end-1);
y1=y(1:end-1,1:end-1);
x2=x(2:end  ,1:end-1);
y2=y(2:end  ,1:end-1);
x3=x(2:end  ,2:end  );
y3=y(2:end  ,2:end  );
x4=x(1:end-1,2:end  );
y4=y(1:end-1,2:end  );
xmin=min(min(min(x1,x2),x3),x4);
xmax=max(max(max(x1,x2),x3),x4);
ymin=min(min(min(y1,y2),y3),y4);
ymax=max(max(max(y1,y2),y3),y4);
xmin(isnan(x1))=NaN;
xmin(isnan(x2))=NaN;
xmin(isnan(x3))=NaN;
xmin(isnan(x4))=NaN;
ymin(isnan(y1))=NaN;
ymin(isnan(y2))=NaN;
ymin(isnan(y3))=NaN;
ymin(isnan(y4))=NaN;

for j=1:length(posx0)
    posx=posx0(j);
    posy=posy0(j);
    [mm,nn]=find(xmin<=posx & xmax>=posx & ymin<=posy & ymax>=posy);
    if ~isempty(mm)
        for i=1:length(mm)
            polx=[x(mm(i),nn(i)) x(mm(i)+1,nn(i)) x(mm(i)+1,nn(i)+1) x(mm(i),nn(i)+1) ];
            poly=[y(mm(i),nn(i)) y(mm(i)+1,nn(i)) y(mm(i)+1,nn(i)+1) y(mm(i),nn(i)+1) ];
            ip=inpolygon(posx,posy,polx,poly);
            if ip==1
                m(j)=mm(i)+1;
                n(j)=nn(i)+1;
                break
            end
        end
    end
end

