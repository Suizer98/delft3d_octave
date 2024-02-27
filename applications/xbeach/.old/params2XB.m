function varargout = params2XB(varargin)
%PARAMS2XB  create XBeach communication structure out of params-file
%
%   This function reads a Xbeach input file (params.txt) and its related
%   files to create a "XBeach input structure".
%
%   Syntax:
%   varargout = params2XB(varargin)
%
%   Input:
%   varargin  = filename (fullpath) of params file
%
%   Output:
%   varargout = XBeach communication structure
%
%   Example
%   XB = params2XB('params.txt')
%
%   See also CreateEmptyXBeachVar

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% Created: 17 Feb 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: params2XB.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/params2XB.m $
% $Keywords:

%% default filename
OPT = struct(...
    'filename', fullfile(cd, 'params.txt'));

if isvector(varargin)
    OPT = setproperty(OPT, 'filename', varargin{end});
end

pathstr = fileparts(OPT.filename);

%%
if ~exist(OPT.filename, 'file')
    warning('PARAMS2XB:FileNotFound', ['File ' OPT.filename ' not found.'])
end

%%
% read file
fid = fopen(OPT.filename);
str = fread(fid, '*char')';
fclose(fid);

% obtain all keywords and values using regular expressions
[exprNames endIndex] = regexp(str, '(?<keyword>.*?)\s*=\s*(?<value>.*)', 'names', 'end', 'dotexceptnewline');

% derive output variables
nglobalvar_index = ismember({exprNames.keyword}, 'nglobalvar');
exprNames(nglobalvar_index).keyword = 'OutVars';
exprNames(nglobalvar_index).value = strread(str(endIndex(nglobalvar_index)+2:end), '%s',...
    'delimiter', '\n')';

% transform regexp output to cell arrays with keywords and values
keywords = {exprNames.keyword};
values = {exprNames.value};

% distinguish between doubles and strings
for ival = 1:length(values)
    if ~isnan(str2double(values{ival}))
        values{ival} = str2double(values{ival});
    else
        values{ival} = strtrim(values{ival});
    end
end

% create input cell array for CreateEmptyXBeachVar
Inputargs = reshape([keywords; values], 1, 2*length(keywords));

% create XB-structure using PropertyName-propertyValue pairs as
% specified in file
XB = CreateEmptyXBeachVar(Inputargs{:}, 'empty');

% read depfile if available
XB.Input.zInitial  = read_secundairy_file(pathstr, XB.settings.Grid.depfile);

if XB.settings.Grid.vardx
    % read depfile if available
    XB.Input.xInitial  = read_secundairy_file(pathstr, XB.settings.Grid.xfile);
    % read depfile if available
    XB.Input.yInitial  = read_secundairy_file(pathstr, XB.settings.Grid.yfile);
end
% read bcfile if available
bcfile = fullfile(pathstr, XB.settings.Waves.bcfile);
bcfileExists = exist(bcfile, 'file') == 2;
if bcfileExists
    XB = XB_read_bcfile(XB,...
        'path', pathstr);
end
% read zs0file if available
XB.settings.Flow.zs0 = read_secundairy_file(pathstr, XB.settings.Flow.zs0file);

varargout = {XB Inputargs};

%%
function outvar = read_secundairy_file(pathstr, file)

outvar = [];

% read file if available
file = fullfile(pathstr, file);
fileExists = exist(file, 'file') == 2;
if fileExists
    outvar = load(file);
end