function [m n uv] = findgridline(posx, posy, x, y)
%findgridline  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [m n uv] = findgridline(posx, posy, x, y)
%
%   Input:
%   posx =
%   posy =
%   x    =
%   y    =
%
%   Output:
%   m    =
%   n    =
%   uv   =
%
%   Example
%   findgridline
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
m=0;
n=0;
uv=-1;
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
[mm,nn]=find(xmin<=posx & xmax>=posx & ymin<=posy & ymax>=posy);
if length(mm)>0
    for i=1:length(m)
        polx=[x(mm(i),nn(i)) x(mm(i)+1,nn(i)) x(mm(i)+1,nn(i)+1) x(mm(i),nn(i)+1) ];
        poly=[y(mm(i),nn(i)) y(mm(i)+1,nn(i)) y(mm(i)+1,nn(i)+1) y(mm(i),nn(i)+1) ];
        ip=inpolygon(posx,posy,polx,poly);
        if ip==1
            x0=[posx,posy];
            % top
            xx1=[x(mm(i),nn(i)+1) y(mm(i),nn(i)+1)];
            xx2=[x(mm(i)+1,nn(i)+1) y(mm(i)+1,nn(i)+1)];
            pt=sqrt((xx2(1)-xx1(1))^2  + (xx2(2)-xx1(2))^2);
            dist(1)=det([xx2-xx1 ; xx1-x0])/pt;
            % bottom
            xx1=[x(mm(i),nn(i)) y(mm(i),nn(i))];
            xx2=[x(mm(i)+1,nn(i)) y(mm(i)+1,nn(i))];
            pt=sqrt((xx2(1)-xx1(1))^2  + (xx2(2)-xx1(2))^2);
            dist(2)=det([xx2-xx1 ; xx1-x0])/pt;
            % right
            xx1=[x(mm(i)+1,nn(i))   y(mm(i)+1,nn(i))];
            xx2=[x(mm(i)+1,nn(i)+1) y(mm(i)+1,nn(i)+1)];
            pt=sqrt((xx2(1)-xx1(1))^2  + (xx2(2)-xx1(2))^2);
            dist(3)=det([xx2-xx1 ; xx1-x0])/pt;
            % left
            xx1=[x(mm(i),nn(i))   y(mm(i),nn(i))];
            xx2=[x(mm(i),nn(i)+1) y(mm(i),nn(i)+1)];
            pt=sqrt((xx2(1)-xx1(1))^2  + (xx2(2)-xx1(2))^2);
            dist(4)=det([xx2-xx1 ; xx1-x0])/pt;
            dist=abs(dist);
            mind=find(dist<=min(dist));
            if mind==1
                m=mm(i)+1;
                n=nn(i)+1;
                uv=1;
            elseif mind==2
                m=mm(i)+1;
                n=nn(i);
                uv=1;
            elseif mind==3
                m=mm(i)+1;
                n=nn(i)+1;
                uv=0;
            elseif mind==4
                m=mm(i);
                n=nn(i)+1;
                uv=0;
            end
            break
        end
    end
end

