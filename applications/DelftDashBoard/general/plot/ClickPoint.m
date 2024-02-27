function ClickPoint(opt, varargin)
%CLICKPOINT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ClickPoint(opt, varargin)
%
%   Input:
%   opt      =
%   varargin =
%
%
%
%
%   Example
%   ClickPoint
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
xg=[];
yg=[];
callback=[];
multi=0;

if ~isempty(varargin)
    for i=1:length(varargin)
        if ischar(varargin{i})
            switch varargin{i}
                case{'Grid','grid'}
                    xg=varargin{i+1};
                    yg=varargin{i+2};
                case{'Callback','callback'}
                    callback=varargin{i+1};
                case{'Multiple','multiple'}
                    multi=1;
                case{'Single','single'}
                    multi=0;
            end
        end
    end
end

ddb_setWindowButtonMotionFcn;
set(gcf,'windowbuttondownfcn',{@Click,opt,xg,yg,callback,multi});
set(gcf,'windowbuttonupfcn',[]);

%%
function Click(src,eventdata,opt,xg,yg,callback,multi)

mouseclick=get(gcf,'SelectionType');

x=NaN;
y=NaN;

if strcmpi(mouseclick,'normal')
    pos = get(gca, 'CurrentPoint');
    x0=pos(1,1);
    y0=pos(1,2);
    xlim=get(gca,'xlim');
    ylim=get(gca,'ylim');
    if x0<=xlim(1) || x0>=xlim(2) || y0<=ylim(1) || y0>=ylim(2)
        x0=NaN;
        y0=NaN;
    end
    if ~isnan(x0)
        switch opt,
            case{'xy'}
                x=x0;
                y=y0;
            case{'cell'}
                [x,y]=findgridcell(x0,y0,xg,yg);
                if x==0 || y==0
                    x=NaN;
                    y=NaN;
                end
            case{'cornerpoint'}
                [x,y]=findcornerpoint(x0,y0,xg,yg);
                if x==0 || y==0
                    x=NaN;
                    y=NaN;
                end
        end
        if ~multi
            ddb_setWindowButtonUpDownFcn;
            ddb_setWindowButtonMotionFcn;
        end
        feval(callback,x,y);
    end
else
    ddb_setWindowButtonUpDownFcn;
    ddb_setWindowButtonMotionFcn;
end



