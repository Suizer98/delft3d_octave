function gui_dragLine(varargin)
%DDB_DRAGLINE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_dragLine(fcn, varargin)
%
%   Input:
%   fcn      =
%   varargin =
%
%
%
%
%   Example
%   ddb_dragLine
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: gui_dragLine.m 6807 2012-07-06 17:02:23Z ormondt $
% $Date: 2012-07-07 01:02:23 +0800 (Sat, 07 Jul 2012) $
% $Author: ormondt $
% $Revision: 6807 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/gui/experimental/gui_dragLine.m $
% $Keywords: $

%%

xg=[];
yg=[];
method='free';
callback=[];
input=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'method'}
                method=lower(varargin{i+1});
            case{'gridx'}
                xg=varargin{i+1};
            case{'gridy'}
                yg=varargin{i+1};
            case{'callback'}
                callback=varargin{i+1};
            case{'input'}
                input=varargin{i+1};
        end
    end
end

set(gcf, 'windowbuttondownfcn',{@dragLine,callback,input,method,xg,yg});
set(gcf, 'windowbuttonmotionfcn',[]);

%%
function dragLine(src,eventdata,callback,input,method,xg,yg)

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

xax=get(gca,'XLim');
yax=get(gca,'YLim');

if posx>xax(1) && posx<xax(2) && posy>yax(1) && posy<yax(2)
    
    m1=[];
    n1=[];
    
    if strcmpi(method,'alonggridline')
        [m1,n1]=findcornerpoint(posx,posy,xg,yg);
        posx=xg(m1,n1);
        posy=yg(m1,n1);
    end
    
    h=plot([posx posx],[posy posy]);
    set(h,'Color','g');
    set(h,'LineWidth',2);
    set(h,'LineStyle','-');
    
    setappdata(h,'callback',callback);
    setappdata(h,'input',input);
    setappdata(h,'method',method);
    setappdata(h,'xg',xg);
    setappdata(h,'yg',yg);
    setappdata(h,'x',[posx posx]);
    setappdata(h,'y',[posy posy]);
    setappdata(h,'m1',m1);
    setappdata(h,'n1',n1);
    
    set(gcf, 'windowbuttonmotionfcn', {@followTrack,h});
    set(gcf, 'windowbuttonupfcn',     {@stopTrack,h});
    
else
    set(gcf, 'windowbuttondownfcn',[]);
    set(gcf, 'windowbuttonmotionfcn',[]);
    set(gcf, 'windowbuttonupfcn',[]);
end

%%
function followTrack(imagefig, varargins, h)
pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
x=getappdata(h,'x');
y=getappdata(h,'y');
x(2)=posx;
y(2)=posy;
setappdata(h,'x',x);
setappdata(h,'y',y);
set(h,'XData',x);
set(h,'YData',y);

%ddb_updateCoordinateText('arrow');

%%
function stopTrack(imagefig, varargins, h)

x=getappdata(h,'x');
y=getappdata(h,'y');
xg=getappdata(h,'xg');
yg=getappdata(h,'yg');
m1=getappdata(h,'m1');
n1=getappdata(h,'n1');
callback=getappdata(h,'callback');
input=getappdata(h,'input');
method=getappdata(h,'method');

ddb_setWindowButtonMotionFcn;
ddb_setWindowButtonUpDownFcn;

delete(h);

% Make sure line is inside axis
xax=get(gca,'XLim');
yax=get(gca,'YLim');
if x(1)>xax(1) && x(1)<xax(2) && x(2)>xax(1) && x(2)<xax(2) && y(1)>yax(1) && y(1)<yax(2) && y(2)>yax(1) && y(2)<yax(2)
    
    if strcmpi(method,'alonggridline')
        % Make sure second point is on same grid line
        [m2,n2]=findcornerpoint(x(2),y(2),xg,yg);
        if m2==m1 || n2==n1
            % Second point on same grid line
            xx(1)=xg(m1,n1);
            yy(1)=yg(m1,n1);
            xx(2)=xg(m2,n2);
            yy(2)=yg(m2,n2);
            if isempty(input)
                feval(callback,xx,yy,[m1 m2],[n1 n2]);
            else
                feval(callback,input,xx,yy,[m1 m2],[n1 n2]);
            end
        end
    else
        if isempty(input)
            feval(callback,x,y);
        else
            feval(callback,input,x,y);
        end
    end
    
end

