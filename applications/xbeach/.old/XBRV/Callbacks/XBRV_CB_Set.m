function XBRV_CB_Set(varargin)
%XBRV_CB_SET  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   XBRV_CB_Set(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   XBRV_CB_Set
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       Pieter.vanGeer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 27 Nov 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: XBRV_CB_Set.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/XBRV/Callbacks/XBRV_CB_Set.m $
% $Keywords: $

%%
h = guidata(varargin{1});

call = varargin{end};

switch call
    case 'ddd'
        if get(h.plothan.plotspec.ddd,'Value')==2
            h.plotspec.ddd = true;
            view(h.plotax,3);
            set([h.plothan.plotspec.hrmson,...
                h.plothan.plotspec.nthin,...
                h.plothan.plotspec.HrmsMarker,...
                h.plothan.plotspec.nyid],'Enable','off');
        else
            h.plotspec.ddd = false;
            view(h.plotax,2);
            set([h.plothan.plotspec.hrmson,...
                h.plothan.plotspec.nthin,...
                h.plothan.plotspec.HrmsMarker,...
                h.plothan.plotspec.nyid],'Enable','on');
        end
    case 'hrmsmarker'
        str = {'o','+','*','d','h','s','<','>','^','v','p','.'};
        h.plotspec.HrmsMarker = str{get(h.plothan.plotspec.HrmsMarker,'Value')};
    case 'hrmson'
        h.plotspec.hrmson = logical(get(h.plothan.plotspec.hrmson,'Value'));
    case 'nyid'
        temp = str2double(get(h.plothan.plotspec.nyid,'String'));
        if ~isnumeric(temp)
            set(h.plothan.plotspec.nyid,'String',num2str(h.plotspec.nyid));
            return
        end
        h.plotspec.nyid = temp;
    case 'dt'
        temp = str2double(get(h.plothan.plotspec.dt,'String'));
        if ~isnumeric(temp)
            set(h.plothan.plotspec.dt,'String',num2str(h.plotspec.dt));
            return
        end
        h.plotspec.dt = temp;
    case 'dframes'
        temp = str2double(get(h.plothan.plotspec.dframes,'String'));
        if ~isnumeric(temp)
            set(h.plothan.plotspec.dframes,'String',num2str(h.plotspec.dframes));
            return
        end
        h.plotspec.dframes = temp;
    case 'XBselect'
        notfin;
    case 'nthin'
        temp = str2double(get(h.plothan.plotspec.nthin,'String'));
        if ~isnumeric(temp)
            set(h.plothan.plotspec.nthin,'String',num2str(h.plotspec.nthin));
            return
        end
        h.plotspec.nthin = temp;
end

guidata(h.fig,h);

state = get(h.control.startpause,'Value');

set(h.control.startpause,'Value',0);
frnr = round(get(h.control.slider,'Value'));

XBRV_StartVideo(varargin{:},frnr);

h = guidata(h.fig);

if state
    set(h.control.startpause,'Value',1);
    XB = get(h.fig,'UserData');
    XBRV_play(varargin{:},frnr,XB.Output.nt);
else
    set(h.control.startpause,'String','Play');
end