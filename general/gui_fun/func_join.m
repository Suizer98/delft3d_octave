function func_join(varargin)
%FUNC_JOIN  Executes a series of function calls
%
%   Accepts a series of funcion handles or cell arrays with full function
%   calls and executes them one after eachother. If this function is called
%   as callback function, the first two parameters are an object handle to
%   the calling object and a event structure. These are detected and
%   subsequently all function calls are rearranged as if it were individual
%   callback calls.
%
%   Syntax:
%   func_join(varargin)
%
%   Input:
%   varargin  = Function handles or cell arrays with full function calls
%
%   Output:
%   none
%
%   Example
%   func_join(@figure, @axes, {@title, 'This is just a test'})
%
%   event1 = {@(o,e,x) disp(x), 'This is my first event!'};
%   event2 = {@(o,e,x) disp(x), 'This is my second event!'};
%   figure('ResizeFcn', event1);
%   set(gcf, 'ResizeFcn', {@func_join, get(gcf, 'ResizeFcn'), event2})
% 
%   See also func_callback_add

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

% $Id: func_join.m 7421 2012-10-09 16:43:01Z hoonhout $
% $Date: 2012-10-10 00:43:01 +0800 (Wed, 10 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7421 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/gui_fun/func_join.m $
% $Keywords: $

%% join function handles

if ~isempty(varargin)
    
    % flag to determine if we are called by a callback function
    callback_mode = true;
    
    % check if first argument is a function handle or a cell array of
    % which the first argument is a function handle, if yes, we are not
    % dealing with a callback function
    if iscell(varargin{1})
        if ~isempty(varargin{1})
            if isa(varargin{1}{1}, 'function_handle')
                callback_mode = false;
            end
        end
    else
        if isa(varargin{1}, 'function_handle')
            callback_mode = false;
        end
    end
    
    % seperate calling object and event structure from other parameters in
    % case we are dealing with a callback function
    if callback_mode
        if length(varargin) > 1
            obj = varargin{1};
            event = varargin{2};
        else
            error('Invalid input');
        end
        
        if length(varargin) > 2
            varargin = varargin(3:end);
        else
            varargin = {};
        end
    end
    
    % call all functions one by one
    for i = 1:length(varargin)
        if ~isempty(varargin{i})
            if ~iscell(varargin{i})
                varargin{i} = varargin(i);
            end
            
            % skip in case of an invalid function handle
            if isa(varargin{i}{1},'function_handle')
                
                % differentiate between callback function calls and normal
                % calls
                if callback_mode
                    if length(varargin{i})>1
                        feval(varargin{i}{1}, obj, event, varargin{i}{2:end});
                    else
                        feval(varargin{i}{1}, obj, event);
                    end
                else
                    feval(varargin{i}{:});
                end
            end
        end
    end
end
