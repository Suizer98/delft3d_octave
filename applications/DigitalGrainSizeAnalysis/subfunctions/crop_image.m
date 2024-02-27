
function varargout = crop_image(varargin)
%crop_image Crop image.
%   crop_image crops an image to a specified rectangle. In the
%   syntaxes below, crop_image displays the input image and waits for
%   you to specify the crop rectangle with the mouse:
%
%        I2 = crop_image(I)
%        X2 = crop_image(X,MAP)
%        RGB2 = crop_image(RGB)
% Written by Daniel Buscombe, various times in 2012 and 2013
% while at
% School of Marine Science and Engineering, University of Plymouth, UK
% then
% Grand Canyon Monitoring and Research Center, U.G. Geological Survey, Flagstaff, AZ 
% please contact:
% dbuscombe@usgs.gov
% for lastest code version please visit:
% https://github.com/dbuscombe-usgs
% see also (project blog):
% http://dbuscombe-usgs.github.com/
%====================================
%   This function is part of 'dgs-gui' software
%   This software is in the public domain because it contains materials that originally came 
%   from the United States Geological Survey, an agency of the United States Department of Interior. 
%   For more information, see the official USGS copyright policy at 
%   http://www.usgs.gov/visual-id/credit_usgs.html#copyright
%====================================


[x,y,a,cm,rect] = ParseInputs(varargin{:});

[m,n,o] = size(a);
xmin = min(x(:)); ymin = min(y(:));
xmax = max(x(:)); ymax = max(y(:));
% Transform rectangle into row and column indices.
if (m == 1)
    pixelsPerVerticalUnit = 1;
else
    pixelsPerVerticalUnit = (m - 1) / (ymax - ymin);
end
if (n == 1)
    pixelsPerHorizUnit = 1;
else
    pixelsPerHorizUnit = (n - 1) / (xmax - xmin);
end
pixelHeight = rect(4) * pixelsPerVerticalUnit;
pixelWidth = rect(3) * pixelsPerHorizUnit;
r1 = (rect(2) - ymin) * pixelsPerVerticalUnit + 1;
c1 = (rect(1) - xmin) * pixelsPerHorizUnit + 1;
r2 = round(r1 + pixelHeight);
c2 = round(c1 + pixelWidth);
r1 = round(r1);
c1 = round(c1);
% Check for selected rectangle completely outside the image
if ((r1 > m) | (r2 < 1) | (c1 > n) | (c2 < 1))
    b = [];
else
    r1 = max(r1, 1);
    r2 = min(r2, m);
    c1 = max(c1, 1);
    c2 = min(c2, n);
    b = a(r1:r2, c1:c2, :);
end

switch nargout
    case 0
        if (isempty(b))
            msg = 'The crop rectangle does not intersect the image';
            wid = sprintf('Images:%s:cropRectDoesNotIntersectImage',mfilename);
            warning(wid,msg);
        end
        figure;
        if (~isempty(cm))
            imagesc(b,cm), colormap gray, axis image
            
        else
            imagesc(b), colormap gray, axis image
            
        end
        
    case 1
        varargout{1} = b;
        
    case 2
        varargout{1} = b;
        varargout{2} = rect;
        
    case 4
        varargout{1} = x;
        varargout{2} = y;
        varargout{3} = b;
        varargout{4} = rect;
        
    otherwise
        msg = 'Too many output arguments';
        eid = sprintf('Images:%s:tooManyOutputArguments',mfilename);
        error(eid,msg);
end

%%%
%%% Subfunction ParseInputs
%%%
function [x,y,a,cm,rect] = ParseInputs(varargin)

x = [];
y = [];
a = [];
flag = 0;
cm = [];
rect = [];

checknargin(0,5,nargin,mfilename);

switch nargin
    case 0
        % crop_image
        % Get information from current figure
        [x,y,a,flag] = getimage;
        if (flag == 0)
            msg = 'No image found in the current axes';
            eid = sprintf('Images:%s:noImageFoundInCurrentAxes',mfilename);
            error(eid,msg);
        end
        if (flag == 1)
            % input image is indexed; get its colormap;
            cm = colormap;
        end
        rect = getrect(gcf);
        
    case 1
        % crop_image(I) or crop_image(RGB)
        a = varargin{1};
        x = [1 size(a,2)];
        y = [1 size(a,1)];
        CheckCData(a);
        imagesc(a); colormap gray, axis image
        
        rect = getrect(gcf);
        
    case 2
        % crop_image(X,MAP) or crop_image(I,RECT) or crop_image(RGB,RECT)
        a = varargin{1};
        x = [1 size(a,2)];
        y = [1 size(a,1)];
        if (size(varargin{2},2) == 3)
            % crop_image(X,MAP)
            cm = varargin{2};
            CheckCData(a);
            imagesc(a,cm); colormap gray, axis image
            
            rect = getrect(gcf);
        else
            rect = varargin{2};
        end
        
    case 3
        % crop_image(x,y,RGB) or crop_image(X,MAP,RECT)
        if (size(varargin{3},3) == 3)
            % crop_image(x,y,RGB)
            x = varargin{1};
            y = varargin{2};
            a = varargin{3};
            CheckCData(a);
            imagesc(x,y,a); colormap gray, axis image
            
            rect = getrect(gcf);
        else
            % crop_image(X,MAP,RECT)
            a = varargin{1};
            cm = varargin{2};
            rect = varargin{3};
            x = [1 size(a,2)];
            y = [1 size(a,1)];
        end
        
    case 4
        % crop_image(x,y,I,RECT) or crop_image(x,y,RGB,RECT)
        x = varargin{1};
        y = varargin{2};
        a = varargin{3};
        rect = varargin{4};
        
    case 5
        % crop_image(x,y,X,MAP,RECT)
        x = varargin{1};
        y = varargin{2};
        a = varargin{3};
        cm = varargin{4};
        rect = varargin{5};
        
end

% In some cases CheckCData gets called twice.  This could be avoided with
% more complex logic, but the check is quick and the code is simpler this
% way.  -sle
CheckCData(a);


%%%
%%% Subfunction CheckCData
%%%
function CheckCData(cdata)

right_type = (isnumeric(cdata) | islogical(cdata)) & isreal(cdata) & ...
    ~issparse(cdata);

is_2d = ndims(cdata) == 2;
is_rgb = (ndims(cdata) == 3) & (size(cdata,3) == 3);

if ~right_type | ~(is_2d | is_rgb)
    msg = 'Invalid input image.';
    eid = sprintf('Images:%s:invalidInputImage',mfilename);
    error(eid, msg);
end



function rect = getrect(varargin)
%GETRECT Select rectangle with mouse.
%   RECT = GETRECT(FIG) lets you select a rectangle in the
%   current axes of figure FIG using the mouse.  Use the mouse to
%   click and drag the desired rectangle.  RECT is a four-element
%   vector with the form [xmin ymin width height].  To constrain
%   the rectangle to be a square, use a shift- or right-click to
%   begin the drag.
%
%   RECT = GETRECT(AX) lets you select a rectangle in the axes
%   specified by the handle AX.
%
%   See also GETLINE, GETPTS.

%   Callback syntaxes:
%        getrect('ButtonDown')
%        getrect('ButtonMotion')
%        getrect('ButtonUp')

global GETRECT_FIG GETRECT_AX GETRECT_H1 GETRECT_H2
global GETRECT_PT1 GETRECT_TYPE

xlimorigmode = xlim('mode');
ylimorigmode = ylim('mode');
zlimorigmode = zlim('mode');
xlim('manual');
ylim('manual');
zlim('manual');

if ((nargin >= 1) & (isstr(varargin{1})))
    % Callback invocation: 'ButtonDown', 'ButtonMotion', or 'ButtonUp'
    feval(varargin{:});
    return;
end

if (nargin < 1)
    GETRECT_AX = gca;
    GETRECT_FIG = get(GETRECT_AX, 'Parent');
else
    if (~ishandle(varargin{1}))
        CleanUp(xlimorigmode,ylimorigmode,zlimorigmode);
        error('First argument is not a valid handle');
    end
    
    switch get(varargin{1}, 'Type')
        case 'figure'
            GETRECT_FIG = varargin{1};
            GETRECT_AX = get(GETRECT_FIG, 'CurrentAxes');
            if (isempty(GETRECT_AX))
                GETRECT_AX = axes('Parent', GETRECT_FIG);
            end
            
        case 'axes'
            GETRECT_AX = varargin{1};
            GETRECT_FIG = get(GETRECT_AX, 'Parent');
            
        otherwise
            CleanUp(xlimorigmode,ylimorigmode,zlimorigmode);
            error('First argument should be a figure or axes handle');
    end
end

% Remember initial figure state
old_db = get(GETRECT_FIG, 'DoubleBuffer');
state = uisuspend(GETRECT_FIG);

% Set up initial callbacks for initial stage
set(GETRECT_FIG, ...
    'Pointer', 'crosshair', ...
    'WindowButtonDownFcn', 'getrect(''ButtonDown'');', ...
    'DoubleBuffer', 'on');

% Bring target figure forward
figure(GETRECT_FIG);

% Initialize the lines to be used for the drag
GETRECT_H1 = line('Parent', GETRECT_AX, ...
    'XData', [0 0 0 0 0], ...
    'YData', [0 0 0 0 0], ...
    'Visible', 'off', ...
    'Clipping', 'off', ...
    'Color', 'k', ...
    'LineStyle', '-');

GETRECT_H2 = line('Parent', GETRECT_AX, ...
    'XData', [0 0 0 0 0], ...
    'YData', [0 0 0 0 0], ...
    'Visible', 'off', ...
    'Clipping', 'off', ...
    'Color', 'w', ...
    'LineStyle', ':');


% We're ready; wait for the user to do the drag
% Wrap the waitfor call in try-catch so
% that if the user Ctrl-C's we get a chance to
% clean up the figure.
errCatch = 0;
try
    waitfor(GETRECT_H1, 'UserData', 'Completed');
catch
    errCatch = 1;
end

% After the waitfor, if GETRECT_H1 is still valid
% and its UserData is 'Completed', then the user
% completed the drag.  If not, the user interrupted
% the action somehow, perhaps by a Ctrl-C in the
% command window or by closing the figure.

if (errCatch == 1)
    errStatus = 'trap';
    
elseif (~ishandle(GETRECT_H1) | ...
        ~strcmp(get(GETRECT_H1, 'UserData'), 'Completed'))
    errStatus = 'unknown';
    
else
    errStatus = 'ok';
    x = get(GETRECT_H1, 'XData');
    y = get(GETRECT_H1, 'YData');
end

% Delete the animation objects
if (ishandle(GETRECT_H1))
    delete(GETRECT_H1);
end
if (ishandle(GETRECT_H2))
    delete(GETRECT_H2);
end

% Restore the figure state
if (ishandle(GETRECT_FIG))
    uirestore(state);
    set(GETRECT_FIG, 'DoubleBuffer', old_db);
end

CleanUp(xlimorigmode,ylimorigmode,zlimorigmode);

% Depending on the error status, return the answer or generate
% an error message.
switch errStatus
    case 'ok'
        % Return the answer
        xmin = min(x);
        ymin = min(y);
        rect = [xmin ymin max(x)-xmin max(y)-ymin];
        
    case 'trap'
        % An error was trapped during the waitfor
        error('Interruption during mouse selection.');
        
    case 'unknown'
        % User did something to cause the rectangle drag to
        % terminate abnormally.  For example, we would get here
        % if the user closed the figure in the drag.
        error('Interruption during mouse selection.');
end

%--------------------------------------------------
% Subfunction ButtonDown
%--------------------------------------------------
function ButtonDown

global GETRECT_FIG GETRECT_AX GETRECT_H1 GETRECT_H2
global GETRECT_PT1 GETRECT_TYPE

set(GETRECT_FIG, 'Interruptible', 'off', ...
    'BusyAction', 'cancel');

[x1, y1] = getcurpt(GETRECT_AX);
GETRECT_PT1 = [x1 y1];
GETRECT_TYPE = get(GETRECT_FIG, 'SelectionType');
x2 = x1;
y2 = y1;
xdata = [x1 x2 x2 x1 x1];
ydata = [y1 y1 y2 y2 y1];

set(GETRECT_H1, 'XData', xdata, ...
    'YData', ydata, ...
    'Visible', 'on');
set(GETRECT_H2, 'XData', xdata, ...
    'YData', ydata, ...
    'Visible', 'on');

% Let the motion functions take over.
set(GETRECT_FIG, 'WindowButtonMotionFcn', 'getrect(''ButtonMotion'');', ...
    'WindowButtonUpFcn', 'getrect(''ButtonUp'');');


%-------------------------------------------------
% Subfunction ButtonMotion
%-------------------------------------------------
function ButtonMotion

global GETRECT_FIG GETRECT_AX GETRECT_H1 GETRECT_H2
global GETRECT_PT1 GETRECT_TYPE

[x2,y2] = getcurpt(GETRECT_AX);
x1 = GETRECT_PT1(1,1);
y1 = GETRECT_PT1(1,2);
xdata = [x1 x2 x2 x1 x1];
ydata = [y1 y1 y2 y2 y1];

if (~strcmp(GETRECT_TYPE, 'normal'))
    [xdata, ydata] = Constrain(xdata, ydata);
end

set(GETRECT_H1, 'XData', xdata, ...
    'YData', ydata);
set(GETRECT_H2, 'XData', xdata, ...
    'YData', ydata);

%--------------------------------------------------
% Subfunction ButtonUp
%--------------------------------------------------
function ButtonUp

global GETRECT_FIG GETRECT_AX GETRECT_H1 GETRECT_H2
global GETRECT_PT1 GETRECT_TYPE

% Kill the motion function and discard pending events
set(GETRECT_FIG, 'WindowButtonMotionFcn', '', ...
    'Interruptible', 'off');

% Set final line data
[x2,y2] = getcurpt(GETRECT_AX);
x1 = GETRECT_PT1(1,1);
y1 = GETRECT_PT1(1,2);
xdata = [x1 x2 x2 x1 x1];
ydata = [y1 y1 y2 y2 y1];
if (~strcmp(GETRECT_TYPE, 'normal'))
    [xdata, ydata] = Constrain(xdata, ydata);
end

set(GETRECT_H1, 'XData', xdata, ...
    'YData', ydata);
set(GETRECT_H2, 'XData', xdata, ...
    'YData', ydata);

% Unblock execution of the main routine
set(GETRECT_H1, 'UserData', 'Completed');

%-----------------------------------------------
% Subfunction Constrain
%
% constrain rectangle to be a square in
% axes coordinates
%-----------------------------------------------
function [xdata_out, ydata_out] = Constrain(xdata, ydata)

x1 = xdata(1);
x2 = xdata(2);
y1 = ydata(1);
y2 = ydata(3);
ydis = abs(y2 - y1);
xdis = abs(x2 - x1);

if (ydis > xdis)
    x2 = x1 + sign(x2 - x1) * ydis;
else
    y2 = y1 + sign(y2 - y1) * xdis;
end

xdata_out = [x1 x2 x2 x1 x1];
ydata_out = [y1 y1 y2 y2 y1];

%---------------------------------------------------
% Subfunction CleanUp
%--------------------------------------------------
function CleanUp(xlimmode,ylimmode,zlimmode)

xlim(xlimmode);
ylim(ylimmode);
zlim(zlimmode);
% Clean up the global workspace
clear global GETRECT_FIG GETRECT_AX GETRECT_H1 GETRECT_H2
clear global GETRECT_PT1 GETRECT_TYPE





function [x,y] = getcurpt(axHandle)
%GETCURPT Get current point.
%   [X,Y] = GETCURPT(AXHANDLE) gets the x- and y-coordinates of
%   the current point of AXHANDLE.  GETCURPT compensates these
%   coordinates for the fact that get(gca,'CurrentPoint') returns
%   the data-space coordinates of the idealized left edge of the
%   screen pixel that the user clicked on.  For IPT functions, we
%   want the coordinates of the idealized center of the screen
%   pixel that the user clicked on.


pt = get(axHandle, 'CurrentPoint');
x = pt(1,1);
y = pt(1,2);

% What is the extent of the idealized screen pixel in axes
% data space?

axUnits = get(axHandle, 'Units');
set(axHandle, 'Units', 'pixels');
axPos = get(axHandle, 'Position');
set(axHandle, 'Units', axUnits);

axPixelWidth = axPos(3);
axPixelHeight = axPos(4);

axXLim = get(axHandle, 'XLim');
axYLim = get(axHandle, 'YLim');

xExtentPerPixel = abs(diff(axXLim)) / axPixelWidth;
yExtentPerPixel = abs(diff(axYLim)) / axPixelHeight;

x = x + xExtentPerPixel/2;
y = y + yExtentPerPixel/2;



function checkinput(A, classes, attributes, function_name, ...
    variable_name, argument_position)
%CHECKINPUT Check validity of array.
%   CHECKINPUT(A,CLASSES,ATTRIBUTES,FUNCTION_NAME,VARIABLE_NAME, ...
%   ARGUMENT_POSITION) checks the validity of the array A and issues a
%   formatted error message if it is invalid.
%   CLASSES is either a space separated string or a cell array of strings
%   containing the set of classes that A is expected to belong to.  For
%   example, CLASSES could be 'uint8 double' if A can be either uint8 or
%   double.  CLASSES could be {'logical' 'cell'} if A can be either logical
%   or cell.  The string 'numeric' is interpreted as an abbreviation for all
%   the numeric classes.
%   ATTRIBUTES is either a space separated string or a cell array of strings
%   containing the set of attributes that A must satisfy.  To see the list of
%   valid attributes, see the subfunction init_table below.  For example, if
%   ATTRIBUTES is {'real' 'nonempty' 'finite'}, then A must be real and
%   nonempty, and it must contain only finite values.
%   FUNCTION_NAME is a string containing the function name to be used in the
%   formatted error message.
%   VARIABLE_NAME is a string containing the documented variable name to be
%   used in the formatted error message.
%   ARGUMENT_POSITION is a positive integer indicating which input argument
%   is being checked; it is also used in the formatted error message.


check_classes(A, classes, function_name, variable_name, argument_position);

check_attributes(A, attributes, function_name, variable_name, ...
    argument_position);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = is_numeric(A)

numeric_classes = {'double' 'uint8' 'uint16' 'uint32' 'int8' ...
    'int16' 'int32' 'single'};

tf = false;
for p = 1:length(numeric_classes)
    if isa(A, numeric_classes{p})
        tf = true;
        break;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = expand_numeric(in)
% Converts the string 'numeric' to the equivalent cell array containing the
% names of the numeric classes.

out = in(:);

idx = strmatch('numeric', out, 'exact');
if (length(idx) == 1)
    out(idx) = [];
    numeric_classes = {'uint8', 'int8', 'uint16', 'int16', ...
        'uint32', 'int32', 'single', 'double'}';
    out = [out; numeric_classes];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function check_classes(A, classes, function_name, ...
    variable_name, argument_position)

if isempty(classes)
    return
end

if ischar(classes)
    if isempty(classes)
        % Work around bug in strread.
        classes = {};
    else
        classes = strread(classes, '%s');
    end
end

is_valid_type = false;
for k = 1:length(classes)
    if strcmp(classes{k}, 'numeric') && is_numeric(A)
        is_valid_type = true;
        break;
        
    else
        if isa(A, classes{k})
            is_valid_type = true;
            break;
        end
    end
end

if ~is_valid_type
    messageId = sprintf('Images:%s:%s', function_name, 'invalidType');
    classes = expand_numeric(classes);
    validTypes = '';
    for k = 1:length(classes)
        validTypes = [validTypes, classes{k}, ', '];
    end
    validTypes(end-1:end) = [];
    message1 = sprintf('Function %s expected its %s input argument, %s,', ...
        function_name, ...
        num2ordinal(argument_position), ...
        variable_name);
    message2 = 'to be one of these types:';
    message3 = sprintf('Instead its type was %s.', class(A));
    error(messageId, '%s\n%s\n\n  %s\n\n%s', message1, message2, validTypes, ...
        message3);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function check_attributes(A, attributes, function_name, ...
    variable_name, argument_position)

if ischar(attributes)
    if isempty(attributes)
        % Work around bug in strread.
        attributes = {};
    else
        attributes = strread(attributes, '%s');
    end
end

table = init_table;

for k = 1:length(attributes)
    if strcmp(attributes{k}, '2d')
        tableEntry = table.twod;
    else
        tableEntry = table.(attributes{k});
    end
    
    if ~feval(tableEntry.checkFunction, A)
        messageId = sprintf('Images:%s:%s', function_name, ...
            tableEntry.mnemonic);
        message1 = sprintf('Function %s expected its %s input argument, %s,', ...
            function_name, num2ordinal(argument_position), ...
            variable_name);
        message2 = sprintf('to be %s.', tableEntry.endOfMessage);
        error(messageId, '%s\n%s', message1, message2);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_real(A)

try
    tf = isreal(A);
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_even(A)

try
    tf = ~any(rem(double(A(:)),2));
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_vector(A)

try
    tf = (ndims(A) == 2) & (any(size(A) == 1) | all(size(A) == 0));
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_row(A)

try
    tf = (ndims(A) == 2) & ((size(A,1) == 1) | isequal(size(A), [0 0]));
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_column(A)

try
    tf = (ndims(A) == 2) & ((size(A,2) == 1) | isequal(size(A), [0 0]));
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_scalar(A)

try
    tf = all(size(A) == 1);
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_2d(A)

try
    tf = ndims(A) == 2;
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_nonsparse(A)

try
    tf = ~issparse(A);
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_nonempty(A)

try
    tf = ~isempty(A);
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_integer(A)

try
    A = A(:);
    switch class(A)
        
        case {'double','single'}
            tf = all(floor(A) == A) & all(isfinite(A));
            
        case {'uint8','int8','uint16','int16','uint32','int32','logical'}
            tf = true;
            
        otherwise
            tf = false;
    end
    
catch
    tf = false;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_nonnegative(A)

try
    tf = all(A(:) >= 0);
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_positive(A)

try
    tf = all(A(:) > 0);
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_nonnan(A)

try
    tf = ~any(isnan(A(:)));
catch
    % if isnan isn't defined for the class of A,
    % then we'll end up here.  If isnan isn't
    % defined then we'll assume that A can't
    % contain NaNs.
    tf = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_finite(A)

try
    tf = all(isfinite(A(:)));
catch
    % if isfinite isn't defined for the class of A,
    % then we'll end up here.  If isfinite isn't
    % defined then we'll assume that A is finite.
    tf = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_nonzero(A)

try
    tf = ~all(A(:) == 0);
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = init_table

persistent table

if isempty(table)
    table.real.checkFunction        = @check_real;
    table.real.mnemonic             = 'expectedReal';
    table.real.endOfMessage         = 'real';
    
    table.vector.checkFunction      = @check_vector;
    table.vector.mnemonic           = 'expectedVector';
    table.vector.endOfMessage       = 'a vector';
    
    table.row.checkFunction         = @check_row;
    table.row.mnemonic              = 'expectedRow';
    table.row.endOfMessage          = 'a row vector';
    
    table.column.checkFunction      = @check_column;
    table.column.mnemonic           = 'expectedColumn';
    table.column.endOfMessage       = 'a column vector';
    
    table.scalar.checkFunction      = @check_scalar;
    table.scalar.mnemonic           = 'expectedScalar';
    table.scalar.endOfMessage       = 'a scalar';
    
    table.twod.checkFunction        = @check_2d;
    table.twod.mnemonic             = 'expected2D';
    table.twod.endOfMessage         = 'two-dimensional';
    
    table.nonsparse.checkFunction   = @check_nonsparse;
    table.nonsparse.mnemonic        = 'expectedNonsparse';
    table.nonsparse.endOfMessage    = 'nonsparse';
    
    table.nonempty.checkFunction    = @check_nonempty;
    table.nonempty.mnemonic         = 'expectedNonempty';
    table.nonempty.endOfMessage     = 'nonempty';
    
    table.integer.checkFunction     = @check_integer;
    table.integer.mnemonic          = 'expectedInteger';
    table.integer.endOfMessage      = 'integer-valued';
    
    table.nonnegative.checkFunction = @check_nonnegative;
    table.nonnegative.mnemonic      = 'expectedNonnegative';
    table.nonnegative.endOfMessage  = 'nonnegative';
    
    table.positive.checkFunction    = @check_positive;
    table.positive.mnemonic         = 'expectedPositive';
    table.positive.endOfMessage     = 'positive';
    
    table.nonnan.checkFunction      = @check_nonnan;
    table.nonnan.mnemonic           = 'expectedNonNaN';
    table.nonnan.endOfMessage       = 'non-NaN';
    
    table.finite.checkFunction      = @check_finite;
    table.finite.mnemonic           = 'expectedFinite';
    table.finite.endOfMessage       = 'finite';
    
    table.nonzero.checkFunction     = @check_nonzero;
    table.nonzero.mnemonic          = 'expectedNonZero';
    table.nonzero.endOfMessage      = 'non-zero';
    
    table.even.checkFunction        = @check_even;
    table.even.mnemonic             = 'expectedEven';
    table.even.endOfMessage         = 'even';
    
end

out = table;


function checknargin(low, high, numInputs, function_name)
%CHECKNARGIN Check number of input arguments.
%   CHECKNARGIN(LOW,HIGH,NUM_INPUTS,FUNCTION_NAME) checks whether NUM_INPUTS
%   is in the range indicated by LOW and HIGH.  If not, CHECKNARGIN issues a
%   formatted error message using the string in FUNCTION_NAME.
%   LOW should be a scalar nonnegative integer.
%   HIGH should be a scalar nonnegative integer or Inf.
%   FUNCTION_NAME should be a string.

if numInputs < low
    msgId = sprintf('Images:%s:tooFewInputs', function_name);
    if low == 1
        msg1 = sprintf('Function %s expected at least 1 input argument', ...
            function_name);
    else
        msg1 = sprintf('Function %s expected at least %d input arguments', ...
            function_name, low);
    end
    
    if numInputs == 1
        msg2 = 'but was called instead with 1 input argument.';
    else
        msg2 = sprintf('but was called instead with %d input arguments.', ...
            numInputs);
    end
    
    error(msgId, '%s\n%s', msg1, msg2);
    
elseif numInputs > high
    msgId = sprintf('Images:%s:tooManyInputs', function_name);
    
    if high == 1
        msg1 = sprintf('Function %s expected at most 1 input argument', ...
            function_name);
    else
        msg1 = sprintf('Function %s expected at most %d input arguments', ...
            function_name, high);
    end
    
    if numInputs == 1
        msg2 = 'but was called instead with 1 input argument.';
    else
        msg2 = sprintf('but was called instead with %d input arguments.', ...
            numInputs);
    end
    
    error(msgId, '%s\n%s', msg1, msg2);
end




function out = checkstrs(in, valid_strings, function_name, ...
    variable_name, argument_position)
%CHECKSTRS Check validity of option string.
%   OUT = CHECKSTRS(IN,VALID_STRINGS,FUNCTION_NAME,VARIABLE_NAME, ...
%   ARGUMENT_POSITION) checks the validity of the option string IN.  It
%   returns the matching string in VALID_STRINGS in OUT.  CHECKSTRS looks
%   for a case-insensitive nonambiguous match between IN and the strings
%   in VALID_STRINGS.
%   VALID_STRINGS is a cell array containing strings.
%   FUNCTION_NAME is a string containing the function name to be used in the
%   formatted error message.
%   VARIABLE_NAME is a string containing the documented variable name to be
%   used in the formatted error message.
%   ARGUMENT_POSITION is a positive integer indicating which input argument
%   is being checked; it is also used in the formatted error message.

checkinput(in, 'char', 'row', function_name, variable_name, argument_position);

idx = strmatch(lower(in), valid_strings);

num_matches = prod(size(idx));

if num_matches == 1
    out = valid_strings{idx};
    
else
    % Convert valid_strings to a single string containing a space-separated list
    % of valid strings.
    list = '';
    for k = 1:length(valid_strings)
        list = [list ', ' valid_strings{k}];
    end
    list(1:2) = [];
    
    msg1 = sprintf('Function %s expected its %s input argument, %s,', ...
        function_name, num2ordinal(argument_position), ...
        variable_name);
    msg2 = 'to match one of these strings:';
    
    if num_matches == 0
        msg3 = sprintf('The input, ''%s'', did not match any of the valid strings.', in);
        id = sprintf('Images:%s:unrecognizedStringChoice', function_name);
        
    else
        msg3 = sprintf('The input, ''%s'', matched more than one valid string.', in);
        id = sprintf('Images:%s:ambiguousStringChoice', function_name);
    end
    
    error(id,'%s\n%s\n\n  %s\n\n%s', msg1, msg2, list, msg3);
end

     
