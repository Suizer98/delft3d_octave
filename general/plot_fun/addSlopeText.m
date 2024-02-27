function varargout = addSlopeText(varargin)
%ADDSLOPETEXT   routine to show slope text in figures
%
% Routine to display the slope of lines in a figure in a way that the
% angle of the text is equal to the angle of the corresponding line
%
% Syntax:
% addSlopeText(plothandle)
% addSlopeText(plothandle, 'PropertyName', PropertyValue....)
% addSlopeText(x, y)
% addSlopeText(x, y, 'PropertyName', PropertyValue....)
% h = addSlopeText(...)
%
% Input:
% plothandle = handle of plot object to display the slopes
% x          = x values
% y          = y values
% keyword value-pairs ('PropertyName', PropertyValue; text properties)
%
% Output:
% h = handle(s) of slope text object(s)
%
% See also: text

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 18 Jun 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: addSlopeText.m 5816 2012-02-29 09:03:08Z heijer $
% $Date: 2012-02-29 17:03:08 +0800 (Wed, 29 Feb 2012) $
% $Author: heijer $
% $Revision: 5816 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/addSlopeText.m $
% $Keywords: $

%% check input
Resize = false;
if ~all(ishandle(varargin{1}))
    % x and y are specified as the first 2 input arguments
    [x y] = deal(varargin{1}, varargin{2});
    varargin(1:2) = [];
elseif strcmp(get(varargin{1}, 'Type'), 'line')
    % first argument is a handle, and its Type is 'line'
    % x and y can be obtained from the XData and YData respectively
    [x y] = deal(get(varargin{1}, 'XData'), get(varargin{1}, 'YData'));
    varargin(1) = [];
elseif strcmp(get(varargin{1}, 'Type'), 'figure') && isempty(varargin{2})
    % resize function call
    % meant keep original text but only change the Rotation
    Resize = true;
    % assign the handles
    h = varargin{3};
    % x and y are specified in the next 2 arguments
    [x y] = deal(varargin{4}, varargin{5});
    varargin(1:5) = [];
else
    error('ADDSLOPETEXT:typenoline', 'Type of plot handle should be ''line''.')
end

if any(strcmpi(varargin, 'Parent'))
    idParent = [false strcmpi(varargin(1:end-1), 'Parent')];
    % Parent manually specified
    Parent = varargin{idParent};
    varargin([idParent(2:end) false] | idParent) = [];
else
    % use current axes handle
    Parent = gca;
end

if ~isempty(varargin) && ~ischar(varargin{1})
    % give error message if old syntax "addSlopeText(x, y, FontSize, ah)"
    % is used
    error('ADDSLOPETEXT:keywordvaluepairs', 'Use keyword value pairs to specify properties');
end

xIsVector = isvector(x);
yIsVector = isvector(y);

if xIsVector && yIsVector
    xySameSize = length(x) == length(y);
    if ~xySameSize
        error('ADDSLOPETEXT:sizeXY', 'x and y should be the same size')
    elseif isscalar(x)
        error('ADDSLOPETEXT:sizeXY', 'length(x) and length(y) should be at least 2')
    end
else
    error('ADDSLOPETEXT:XYnovector', 'x and y should be vectors')
end

if size(x,1) > size(x,2)
    % make sure x is a row vector
    x = x';
end
if size(y,1) > size(y,2)
    % make sure y is a row vector
    y = y';
end

% keep current warning state and turn of all warnings
state.warning = warning;
warning off %#ok<WNOFF>

% obtain current property settings
state.axes = get(Parent);

% reset original warning state
warning(state.warning); %#ok<WNTAG>

XScaleLinear = strcmp(state.axes.XScale, 'linear'); % check whether x-axis is linear
YScaleLinear = strcmp(state.axes.YScale, 'linear'); % check whether y-axis is linear
if ~XScaleLinear || ~YScaleLinear
    warning('ADDSLOPETEXT:Nonlinearaxis', 'addSlopeText is only applicable for linear axis')
    return
end

%%
defaults = {
    'FontSize', get(Parent, 'FontSize'),...
    'FontName', get(Parent, 'FontName'),...
    'HorizontalAlignment', 'center',...
    'VerticalAlignment', 'bottom',...
    'Color', [0 0 0]};

% create structure "OPT" based on default text properties
OPT = getdefaultProperties('Text');
OPT.Parent = Parent;

% call setproperty to set the defaults and (re)set properties possibly
% passed through by varargin
OPT = setproperty(OPT, defaults{:}, varargin{:});

%%
set(OPT.Parent,...
    'Units', 'centimeters'); % set Units to centimeters
Position = get(OPT.Parent, 'Position');
set(OPT.Parent,...
    'Units', state.axes.Units) % restore Units setting
hor = Position(3) / diff(state.axes.XLim); % figure width devided by difference in axis limits
ver = Position(4) / diff(state.axes.YLim); % figure height devided by difference in axis limits

x = [x(1:end-1); x(2:end)]; % separate begins and ends of each line part
y = [y(1:end-1); y(2:end)]; % separate begins and ends of each line part
IsVertical = diff(x) == 0; % no horizontal difference
IsHorizontal = diff(y) == 0; % no vertical difference
x = x(:, ~IsHorizontal & ~IsVertical); % only keep sloping parts
y = y(:, ~IsHorizontal & ~IsVertical); % only keep sloping parts
slope =  diff(x) ./ diff(y); % horizontal difference devided by vertical difference

if ~isempty(slope)
    Reverse = ~strcmp(state.axes.XDir, state.axes.YDir); % angle will be changed if axis directions are different
    if Reverse
        slope = -slope; % text angle will be changed in case that axis directions are different
    end
    
    xcorner = [x(1,1) x(2,:)];
    ycorner = [y(1,1) y(2,:)];

    x = mean(x); % mean x for each line part
    y = mean(y); % mean y for each line part
    format = repmat({'%4.1f'}, size(x)); % display slope as rounded to 1 decimal digit
    slopeIsInteger = roundoff(slope,1) == round(slope); % slope rounded to 1 decimal digit is integer
    format(slopeIsInteger) = repmat({'%4.0f'}, 1, sum(slopeIsInteger)); % display as integer
    
    if ~Resize
        h = NaN(length(x),1); % preallocate text handles
    end
    
    OPT = repmat(OPT, length(x), 1); % expand OPT to get length equal to number of slope texts
    for id = 1:length(x)
        % determine rotation in figure, based on figure size and axis
        % information
        OPT(id).Rotation = atan(ver/slope(id)/hor)*180/pi;
        if ~Resize
            % create slope text string (overwrite field in OPT structure)
            OPT(id).String = ['1:' num2str(abs(slope(id)), format{id})];
            % define position of text
            OPT(id).Position = [x(id) y(id) 0];
            % place text in figure by setting all available properties
            h(id) = text(fieldnames(OPT(id))', struct2cell(OPT(id))');
        else
            set(h(id),...
                'Rotation', OPT(id).Rotation)
        end
    end

    if ~Resize
        % set resize function
        if ~isempty(get(gcf, 'ResizeFcn')) && strcmp(state.warning(strcmp({state.warning.identifier},'all')).state,'on')
            warning('ADDSLOPETEXT:ResizeFcnAlreadyExists', 'Existing resize function has been overwritten')
        end
        set(get(OPT(1).Parent, 'Parent'),...
            'ResizeFcn', {@addSlopeText, h(~isnan(h)), xcorner, ycorner,...
            'Parent', OPT(1).Parent,...
            varargin{:}})
    end
else
    h = [];
end

if nargout == 1
    % create output argument if requested
    varargout = {h};
end