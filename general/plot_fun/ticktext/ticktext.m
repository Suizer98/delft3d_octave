function ticktext(ax, varargin)
%TICKTEXT  Brings text formatting power to tick labels
%
%   Replaces the original ticklabels with normal text objects. The text
%   objects can be formatted using a custom or existing formatting
%   function. This formatting function accepts as a first argument the
%   vector with tick values and returns a cell array with tick labels. The
%   tick labels may be cell arrays itself. In that case it will be a
%   multiline tick label.
%
%   A listener is attached to the axis object in order to keep the tick
%   labels updated. Any arguments passed to this function that are not
%   recognized are passed further to the text object function, enclosing
%   all formatting options of the text objects itself.
%
%   Several formatting functions are available named ticktext_*. The
%   ticktext_multiline_scalable function facilitates an easy implementation
%   of ticklabels that scale with the zoom factor and run over multiple
%   lines.
%
%   Syntax:
%   ticktext(ax, varargin)
%
%   Input:
%   ax        = Axis for which ticklabels should be set
%   varargin  = name/value pairs:
%               FormatFcn:          function handle to formatting function
%               FormatFcnVariables: optional cell array with parameters for
%                                   formatting function
%               Dimension:          dimension of axis to be formatted (x/y)
%
%               Any other parameters are pased through to the text object
%               function and therefore are typical text formatting
%               properties.
%
%   Output:
%   none
%
%   Example
%   figure; axes;
%   ticktext(gca)
%
%   figure; axes;
%   ticktext(gca, 'FormatFcn', @custom_format)
%
%   figure; axes;
%   ticktext(gca, 'FormatFcn', @(x) arrayfun(@(y) sprintf('%05.1f', y), x, 'UniformOutput', false))
%
%   figure; axes;
%   ticktext(gca, 'FormatFcn', @(x) arrayfun(@(y) datestr(y), x, 'UniformOutput', false))
%
%   See also ticktext_default, ticktext_datetime, ticktext_multiline_scalable

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
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
% Created: 09 Oct 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: ticktext.m 7687 2012-11-14 15:16:12Z hoonhout $
% $Date: 2012-11-14 23:16:12 +0800 (Wed, 14 Nov 2012) $
% $Author: hoonhout $
% $Revision: 7687 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/ticktext/ticktext.m $
% $Keywords: $

%% define options
OPT = struct(                   ...
    'FormatFcn', @ticktext_default, ...
    'FormatFcnVariables', {{}}, ...
    'Dimension', 'x'                );

%% define shortcuts

shortcuts = find(cellfun(@ischar, varargin));
shortcuts = shortcuts(~cellfun(@isempty, regexp(varargin(shortcuts), '^-.+')));

if ~isempty(shortcuts)
    for i = 1:length(shortcuts)
        if ischar(varargin{shortcuts(i)})
            switch varargin{shortcuts(i)}
                case '-default'
                    OPT.FormatFcn = @ticktext_default;
                    OPT.FormatFcnVariables = {};
                case '-datetime'
                    OPT.FormatFcn = @ticktext_datetime;
                    OPT.FormatFcnVariables = {};
                case '-datetime2'
                    OPT.FormatFcn = @ticktext_datetime2;
                    OPT.FormatFcnVariables = {};
                case '-categories'
                    OPT.FormatFcn = @ticktext_categories;
            end
        end
    end
    varargin(shortcuts) = [];
end

%% read options

% seperate extra options from default text options
i = 1;
while i < length(varargin)
    f = varargin{i};
    if any(strcmpi(f, fieldnames(OPT)))
        OPT.(f) = varargin{i+1};
        varargin(i:i+1) = [];
        i = i - 2;
    end
    i = i + 2;
end

%% set callback functions

% store object
OPT.Object = ax;

% define callback function call
fcn = {@update_axes, OPT, varargin};

% attach listener
attach_listener(ax, OPT, fcn);

% set axes
feval(fcn{1}, ax, '', fcn{2:end});

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function to attach listener
function attach_listener(ax, OPT, fcn)
    
    p = { ...
        sprintf('%sTick', upper(OPT.Dimension)), ...
    	sprintf('%sLim', upper(OPT.Dimension))      };

    hax = handle(ax);
    
    for i = 1:length(p)
        prp = findprop(hax, p{i});
        lis = handle.listener(hax, prp, 'PropertyPostSet', fcn);
        setappdata(ax, [p{i} 'Listener'], lis);
    end

end

% function to update tick labels
function update_axes(obj, event, OPT, args)
    
    stack = dbstack;
    
    % check if we are not dealing with recurrent calls
    if ~(length(stack)>1 && strcmpi(stack(1:2).name) && strcmpi(stack(1:2).file))
        
        % get axes and figure objects
        ax   = OPT.Object;
        fig  = get_figure(OPT.Object);

        % get current units
        uax  = get(ax, 'Units');
        ufig = get(fig, 'Units');

        % set units to normalized
        set(fig, 'Units', 'normalized');
        set(ax,  'Units', 'normalized');

        % determine parameter names based on dimension
        p1 = sprintf('%sTick', upper(OPT.Dimension));
        p2 = sprintf('%sTickLabel', upper(OPT.Dimension));
        p3 = sprintf('%sLim', upper(OPT.Dimension));

        % get current ticks, limits and remove ticklabels
        tck = get(ax, p1);
        lim = get(ax, p3);
        set(ax, p2, ' ');

        % evaluate tick labels
        lbl = feval(OPT.FormatFcn, tck, OPT.FormatFcnVariables{:});

        % remove old tick labels
        delete(findobj(ax, 'Tag', p2));

        % add all tick labels
        axes(ax);
        for i = 1:length(tck)

            % determine location of current tick label
            x0 = (tck(i)-lim(1))/diff(lim);
            y0 = -.01;

            switch OPT.Dimension
                case 'y'
                    y = x0;
                    x = y0;
                otherwise
                    x = x0;
                    y = y0;
            end

            % set current tick label
            text(x, y, lbl{i}, ...
                'Units', 'normalized', ...
                'Tag', p2, ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'top', ...
                args{:});
        end

        % restore units
        set(ax,  'Units', uax );
        set(fig, 'Units', ufig);
        
    end
end

% function that returns the figure object
function fig = get_figure(obj)
    if strcmpi(get(obj, 'Type'), 'figure')
        fig = obj;
    else
        fig = get_figure(get(obj, 'Parent'));
    end
end
