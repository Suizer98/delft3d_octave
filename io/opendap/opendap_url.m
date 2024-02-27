function url = opendap_url(file, varargin)
%OPENDAP_URL  returns link to opendap file
%
%   Routine returns to a OPeNDAP file. The function can check for a local
%   copy of a file, provided that the local directory structure is
%   identical to the OPeNDAP server.
%
%   Syntax:
%   url = opendap_url(varargin)
%
%   Input:
%   file     = path to file relative to the main opendap folder
%   varargin = propertyname-propertyvalue-pairs:
%       localpath : path to local main data directory (e.g. for Deltares:
%       p:\mcdata)
%       opendapurl: main OPeNDAP url, identical for both THREDDS and HYRAX 
%                       (default: 'http://opendap.deltares.nl:8080/')
%       infix     : part of suburl which is identical for local as well as
%                   both OPeNDAP protocols (default: and opendap)
%       protocol  : OPeNDAP protocol being either 'THREDDS' (default) or 'HYRAX'
%       verbose   : boolean to indicate verbosity
%
%   Output:
%   url      = url or local file (including path) to specified file
%
%   Example
%   opendap_url
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
%       Kees den Heijer
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 01 Dec 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: opendap_url.m 11134 2014-09-24 07:44:42Z bieman $
% $Date: 2014-09-24 15:44:42 +0800 (Wed, 24 Sep 2014) $
% $Author: bieman $
% $Revision: 11134 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/opendap/opendap_url.m $
% $Keywords: $

%%
OPT = struct(...
    'localpath', 'p:\mcdata',...
    'opendapurl', 'http://opendap.deltares.nl/',...
    'infix', 'opendap',...
    'protocol', 'THREDDS',...
    'verbose', true);

if nargin > 1
    % update OPT structure with input from varargin
    OPT  = setproperty(OPT, varargin{:});
end

%%
if exist(OPT.localpath, 'dir')
    local = fullfile(OPT.localpath, OPT.infix, file);
    if exist(local, 'file')
        % url is local file
        url = local;
        
        if OPT.verbose
            % warn user that local file is used if it is not specifically
            % specified in the function call
            disp(['Warning: local file from "' OPT.localpath '" is used.'])
        end
        
        return
    end
end

%% construct OPeNDAP url
switch upper(OPT.protocol)
    % case-insensitive switch to OPeNDAP protocol
    case 'HYRAX'
        % OPeNDAP HYRAX
        infix = OPT.infix;
    case 'THREDDS'
        % OPeNDAP THREDDS
        infix = fullurl('thredds/dodsC', OPT.infix);
    otherwise
        error(['Protocol is not valid [' OPT.protocol ']'])
end

url = fullurl(OPT.opendapurl, infix, file);