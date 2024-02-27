function varargout = dgst_run(varargin)
%DGST_RUN  Run a D-Geo Stability model.
%
%   Run a D-Geo Stability model by either providing the model input as .sti
%   file or as Xstructure. The first input argument can be one of these two
%   inputs, while the remaining input arguments as <'keyword',value> pairs.
%
%   Syntax:
%   varargout = dgst_run(varargin)
%
%   Input: For <keyword,value> pairs call dgst_run() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   dgst_run
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Kees den Heijer
%
%       kees.denheijer@deltares.nl
%
%       P.O. Box 177
%       2600 MH  DELFT
%       The Netherlands
%       Rotterdamseweg 185
%       2629 HD  DELFT
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
% Created: 18 Sep 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: dgst_run.m 10185 2014-02-11 08:46:43Z heijer $
% $Date: 2014-02-11 16:46:43 +0800 (Tue, 11 Feb 2014) $
% $Author: heijer $
% $Revision: 10185 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DGeoStability/dgst_run/dgst_run.m $
% $Keywords: $

%%
OPT = struct(...
    'binary', 'c:\Program Files (x86)\Deltares\DGeoStability\DGeoStability.exe',...
    'path', pwd,...
    'run', true,...
    'verbose', false);

if nargin == 0
    varargout = {OPT};
    return
end

%%
if ~ispc
    warning('D-Geo Stability is not available for the current system "%s"', computer)
end

%%
if ischar(varargin{1})
    % assume the first input argument to be a path or filename
    fpath = varargin{1};
    if exist(fpath, 'file') || exist(fpath, 'dir')
        varargin = [{'path'} varargin];
    end
    OPT = setproperty(OPT, varargin);
elseif isstruct(varargin{1})
    % assume the first input argument to be a D-Geo Stability Xstructure
    GSs = varargin{1};
    % check the validity of the structure
    xs_check(GSs)
    % update OPT with the remaining input arguments
    OPT = setproperty(OPT, varargin(2:end));
    if exist(OPT.path, 'dir')
        % make sure that OPT.path is a file name with .sti extention
        OPT.path = fullfile(OPT.path, ['dgst_' datestr(now, 'YYYYmmddHHMMSS') '.sti']);
    end
    % write model to file
    dgst_stiwrite(OPT.path, GSs)
end

% construct the command-line call
cmd = {sprintf('"%s" /b "%s"', OPT.binary, OPT.path)};

if ~OPT.run
    % provide contents of a .bat file as output
    varargout = {sprintf('%s', cmd{:})};
    return
end

if OPT.verbose
    % add the -echo argument if the verbose option is true
    cmd{2} = '-echo';
end

% run the model by a system call
[status, cmdout] = system(cmd{:});

% output
varargout = {status, cmdout};