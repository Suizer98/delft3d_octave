function XBRV_CB_Contr(varargin)
%XBRV_CB_CONTR  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   XBRV_CB_Contr(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   XBRV_CB_Contr
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

% $Id: XBRV_CB_Contr.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/XBRV/Callbacks/XBRV_CB_Contr.m $
% $Keywords: $

%%
h = guidata(varargin{1});
XB = get(h.fig,'UserData');

if isempty(XB)
    set(h.control.startpause,'Value',0);
    set(h.control.slider,'Value',get(h.control.slider,'min'));
    return
end

tagg = get(varargin{1},'Tag');

switch tagg
    case 'rew'
        playstate = get(h.control.startpause,'Value');
        set(h.control.slider,'Value',1);
        XBRV_play(varargin{:},1,'set');
        if playstate
            set(h.control.startpause,'Value',1,'String','Pause');
            XBRV_play(varargin{:},1,XB.Output.nt);
        else
            set(h.control.startpause,'Value',0,'String','Play');
        end
    case 'stop'
        set(h.control.startpause,'Value',0,'String','Play');
        set(h.control.slider,'Value',1);
        XBRV_play(varargin{:},1,'set');
    case 'start'
        if get(h.control.startpause,'Value')
            set(h.control.startpause,'String','Pause');
            frnr = get(h.control.slider,'Value');
            set(varargin{1},'Selected','off','SelectionHighlight','off');
            XBRV_play(varargin{:},frnr,XB.Output.nt);
            % uiwait
        else
            set(h.control.startpause,'String','Resume');
        end
    case 'slider'
        frnr = round(get(h.control.slider,'Value'));
        set(h.control.slider,'Value',frnr);
        if get(h.control.startpause,'Value')
            set(h.control.startpause,'Value',0,'String','Resume');
        else
            set(h.control.startpause,'Value',1);
            XBRV_play(varargin{:},frnr,'set');
            set(h.control.startpause,'Value',0);
        end
    case 'forw'
        set(h.control.startpause,'Value',0,'String','Play');
        set(h.control.slider,'Value',XB.Output.nt);
        XBRV_play(varargin{:},XB.Output.nt,'set');
end

set(h.fig,'Currentobj',h.plotax);
set(varargin{1},'Selected','off','SelectionHighlight','off');