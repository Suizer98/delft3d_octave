function xb_gui_dragselect(obj, varargin)
%XB_GUI_DRAGSELECT  Creates an drag and select interface
%
%   Creates an drag and select interface for maps. Can fire a function
%   after selection is complete. The function should take 5 arguments:
%   default object and event arguments, the drag-and-select object, the x
%   and y position of the selection.
%
%   Syntax:
%   xb_gui_dragselect(obj, varargin)
%
%   Input:
%   obj       = Object handle which should be drag-and-select enabled
%   varargin  = cursor:     Enables crosshair cursor
%               select:     Enables area selection
%               fcn:        Function handle to be fired after selection
%
%   Output:
%   none
%
%   Example
%   xb_gui_dragselect(axes, 'select', true, 'cursor', false, 'fcn', @drawrectangle)
%
%   See also xb_gui_normconditions, xb_gui_mergebathy

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 10 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_gui_dragselect.m 4436 2011-04-11 16:45:44Z hoonhout $
% $Date: 2011-04-12 00:45:44 +0800 (Tue, 12 Apr 2011) $
% $Author: hoonhout $
% $Revision: 4436 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_gui/xb_gui_dragselect.m $
% $Keywords: $

%% create gui

    % read options
    OPT = struct( ...
        'cursor', true, ...
        'select', true, ...
        'fcn', '' ...
    );

    OPT = setproperty(OPT, varargin{:});
    
    if OPT.select
        set(gcf, ...
            'windowbuttonmotionfcn', {@dodrag, obj}, ...
            'windowbuttonupfcn', {@stopdrag, obj, OPT.fcn} ...
        );

        set(obj, 'buttondownfcn', @startdrag);
    else
        set(gcf, ...
            'windowbuttonmotionfcn', '', ...
            'windowbuttonupfcn', '' ...
        );
    
        if OPT.cursor
            set(gcf, 'windowbuttonmotionfcn', {@setpointer, obj});
        end

        set(obj, 'buttondownfcn', '');
        
        robj = findobj(obj, 'tag', 'selection');
    
        if ~isempty(robj)
            delete(robj);
        end
    end
    
    set(get(obj, 'children'), 'hittest', 'off');
end

function setpointer(obj, event, aobj)
    if ~isempty(aobj)
        cp = get(aobj, 'currentpoint');
        x = cp(1,1);
        y = cp(1,2);

        xlim = get(aobj, 'xlim');
        ylim = get(aobj, 'ylim');
        xv = xlim([1 1 2 2]);
        yv = ylim([1 2 2 1]);

        if inpolygon(x, y, xv, yv)
            set(obj, 'pointer', 'crosshair');
        else
            set(obj, 'pointer', 'arrow');
        end
    end
end

function startdrag(obj, event)
    set(obj, 'userdata', get(obj, 'currentpoint'));
end

function stopdrag(obj, event, aobj, fcn)
    robj = findobj(aobj, 'tag', 'selection');
    
    if ~isempty(robj)
        delete(robj);
        
        p1 = get(aobj, 'userdata');
        if ~isempty(p1)
            p2 = get(aobj, 'currentpoint');

            r1 = [min(p1(1,1), p2(1,1)) min(p1(1,2), p2(1,2))];
            r2 = [max(p1(1,1), p2(1,1)) max(p1(1,2), p2(1,2))];
            
            polx = [r1(1) r1(1) r2(1) r2(1)];
            poly = [r1(2) r2(2) r2(2) r1(2)];
            
            if ~isempty(fcn)
                feval(fcn, obj, event, aobj, polx, poly);
            end
        end
    end
    
    set(aobj, 'userdata', []);
end

function dodrag(obj, event, aobj)
    setpointer(obj, event, aobj);
    
    p1 = get(aobj, 'userdata');
    if ~isempty(p1)
        p2 = get(aobj, 'currentpoint');
        
        r1 = [min(p1(1,1), p2(1,1)) min(p1(1,2), p2(1,2))];
        r2 = [max(p1(1,1), p2(1,1)) max(p1(1,2), p2(1,2))];
        
        pos = [r1 max(r2-r1, [1 1])];
        
        robj = findobj(aobj, 'tag', 'selection');
        if isempty(robj);
            rectangle('position', pos, 'linestyle', ':', 'tag', 'selection');
        else
            set(robj, 'position', pos);
        end
    end
end
