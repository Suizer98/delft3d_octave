function verbose = xb_verbose(level, varargin)
%XB_VERBOSE  Writes verbose messages from XBeach toolbox
%
%   Writes verbose messages from XBeach toolbox. Excepts any fprintf like
%   input.
%
%   Syntax:
%   xb_verbose(varargin)
%
%   Input:
%   varargin  = fprintf like input
%
%   Output:
%   none
%
%   Example
%   xb_verbose('File not found [%s]', filename)
%
%   See also fprintf

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
% Created: 24 Jul 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: xb_verbose.m 16129 2019-12-13 22:34:47Z l.w.m.roest.x $
% $Date: 2019-12-14 06:34:47 +0800 (Sat, 14 Dec 2019) $
% $Author: l.w.m.roest.x $
% $Revision: 16129 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_lib/xb_verbose.m $
% $Keywords: $

%% write verbose message

strLogical = {'FALSE' 'TRUE'};

verbose = xb_getpref('verbose');

if ~isempty(verbose) && ~isempty(varargin)
    
    if verbose
    
        ind = repmat('    ',1,level);
        str = varargin{1};

        if ~iscell(str); str = {str}; end;

        for i = 1:length(str)

            switch str{i}
                case '---'
                    fprintf(['\n' repmat('-',1,60) '\n']);
                otherwise
                    if length(varargin) > 1
                        fprintf('%-25s : ', [ind str{i}]);
                    else
                        fprintf('%-25s   ', [ind str{i}]);
                    end
            end

            for j = 2:length(varargin)

                data = varargin{j};

                if ~iscell(data); data = {data}; end;

                if length(data) >= i
                    switch class(data{i})
                        case 'logical'
                            fprintf('%-15s', strLogical{data{i}+1});
                        case 'double'
                            if data{i} == round(data{i})
                                fprintf('%10d', data{i});
                            else
                                fprintf('%10.4f', data{i});
                            end
                        case 'char'
                            fprintf('%-15s', data{i});
                        otherwise
                            fprintf('%-15s', '<structure>');
                    end
                end
            end

            fprintf('\n');

        end
        
    end
    
end
