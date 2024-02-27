function returnmessage(log_id, format, varargin)
%RETURNMESSAGE  Returns message to user in commandline, logfile or textbox 
%
%   Syntax is identical to fprintf, except that a negative returns a
%   message to a textbox
%
%   Syntax:
%   returnmessage(log_id, format, varargin)
%
%   Input:
%   log_id   
%       0       = do nothing
%       1       = print message to commandwindow (black)
%       2       = print message to commandwindow (red)
%       3-inf   = print message to file id
%       -1      = print mesage  to message dialogue
%       -2      = print mesage  to warning dialogue
%       -3      = print mesage  to error   dialogue
%
%   format   = same as second argument of fprintf
%   varargin = same as varargin of fprintf
%
%
%
%
%   Example
%   log_id = 2;
%   returnmessage(log_id,'%s is the message\n','This')
%
%   See also: fprintf

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
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
% Created: 25 May 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: returnmessage.m 6243 2012-05-25 07:56:25Z tda.x $
% $Date: 2012-05-25 15:56:25 +0800 (Fri, 25 May 2012) $
% $Author: tda.x $
% $Revision: 6243 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/returnmessage.m $
% $Keywords: $


if log_id > 0
    fprintf(log_id,format,varargin{:});
end
if log_id < 0
    switch log_id
        case -1
            msgbox(sprintf(format,varargin{:}));
        case -2
            warndlg(sprintf(format,varargin{:}));
        case -3
            errordlg(sprintf(format,varargin{:}));
    end
end


