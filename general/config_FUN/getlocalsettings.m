function varargout = getlocalsettings
%GETLOCALSETTINGS  Get local config information or write template
%
%   Routine to read local config file or, if it does not exist, saves a
%   template of such a file.
%
%   Syntax:
%   varargout = getlocalsettings(varargin)
%
%   Output:
%   varargout = structure containing local config information
%
%   Example
%   getlocalsettings
%
%   See also: oetnewfun, userpath

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 21 Nov 2008
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: getlocalsettings.m 15372 2019-04-30 12:37:42Z l.w.m.roest.x $
% $Date: 2019-04-30 20:37:42 +0800 (Tue, 30 Apr 2019) $
% $Author: l.w.m.roest.x $
% $Revision: 15372 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/config_FUN/getlocalsettings.m $

%%
% define config path
if ispc
    configpath = fullfile(getenv('APPDATA'), 'OET');
else
    configpath = fullfile(getenv('HOME'), '.OET');
end

% make path if necessary
if ~exist(configpath,'dir')
    mkdir(configpath)
end

% define config file
configfile = fullfile(configpath, 'config');

configpathEXIST = exist(configfile, 'file');

if ~configpathEXIST
    % create config template
    configstr = createconfig;
    % write config file
    fid = fopen(configfile, 'w');
    fprintf(fid, '%s', configstr);
    fclose(fid);
    % display link to config file
    fprintf('Local settings stored in: <a href="matlab:opentoline(''%s'',1)">%s</a>\n', configfile, configfile);
else
    % read config file
    fid = fopen(configfile);
    configstr = fread(fid, '*char')';
    fclose(fid);
end


% apply config
eval(configstr)
varargout = {config};