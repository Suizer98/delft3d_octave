function xb_write_params(filename, xb, varargin)
%XB_WRITE_PARAMS  Write XBeach settings to params.txt file
%
%   Routine to create a XBeach settings file. The settings in the XBeach
%   structure are written to "filename". Optionally an alternative header
%   line or directory containing params.f90 can be defined.
%
%   Syntax:
%   varargout = xb_write_params(filename, xb, varargin)
%
%   Input:
%   filename   = file name of params file
%   xb         = XBeach structure array
%   varargin   = header:    option to parse an alternative header string
%                xbdir :    option to parse an alternative xbeach code directory
%
%   Output:
%   none
%
%   Example
%   xb_write_params(filename, xb)
%
%   See also xb_write_input, xb_read_params

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: xb_write_params.m 13260 2017-04-13 12:37:27Z nederhof $
% $Date: 2017-04-13 20:37:27 +0800 (Thu, 13 Apr 2017) $
% $Author: nederhof $
% $Revision: 13260 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_write_params.m $
% $Keywords: $

%% read options

if ~xs_check(xb); error('Invalid XBeach structure'); end;

OPT = struct(...
    'header', {{'XBeach parameter settings input file' '' ['date:     ' datestr(now)] ['function: ' mfilename]}}, ...
    'xbdir', '', ...
    'skip_headers', false);

if nargin > 2
    OPT = setproperty(OPT, varargin{:});
end

if ~iscell(OPT.header); OPT.header = {OPT.header}; end;

if isdir(filename)
    filename = fullfile(filename, 'params.txt');
end

%% write parameter file
matfile = fullfile(fileparts(which('xb_get_params')), 'params.mat');

[params params_array] = xb_get_params(OPT.xbdir);

if OPT.skip_headers
    warning('OET:xbeach:headers', 'No XBeach parameter category definition found, skipping headers');
    parname = {xb.data.name};
    upartype = {'General'};
    partype = cell(size(parname));
    partype(:) = deal(upartype);
else
    if isempty(params_array) && exist(matfile, 'file')
        load(matfile);
    end
    parname = {params_array.name};
    partype = {params_array.partype};
    % add 'General' category for remaining variables (if present)
    parname = [parname setdiff({xb.data.name}, parname)];
    partype(end+1:length(parname)) = deal({'General'});
    upartype = unique(partype);
end

% derive maximum stringsize of all variable names
maxStringLength = max(cellfun(@length, {xb.data.name}));

% open file
fid = fopen(filename, 'w');

% write header
fprintf(fid, '%s\n', repmat('%', 1, 80));
for i = 1:length(OPT.header)
    fprintf(fid, '%s %-72s %s\n', '%%%', OPT.header{i}, '%%%');
end
fprintf(fid, '%s\n', repmat('%', 1, 80));

outputvars = '';
for i = 1:length(upartype)
    pars = parname(strcmpi(upartype{i}, partype));
    
    % create type header
    if any(ismember(pars, {xb.data.name})) && ...
            ~strcmp(upartype{i}, 'Output variables') % collect output variables for printing at the end of the file
        fprintf(fid, '\n%s %s %s\n\n', '%%%', upartype{i}, repmat('%',1,75-length(upartype{i})));
    end
    
    for j = 1:length(pars)
        ivar = strcmpi(pars{j}, {xb.data.name});
        
        if any(ivar)
            xb.data(ivar).name;
            try
            if iscell(xb.data(ivar).value)
                varname = ['n' xb.data(ivar).name];
                varname = regexprep(varname, '^n+', 'n');
                varname = regexprep(varname, 'vars$', 'var');
                
                outputvars = [outputvars sprintf('\n')];
                
                % create line indicating the number items in the cell
                outputvars = [outputvars sprintf('%s\n', var2params(varname, length(xb.data(ivar).value), maxStringLength))];

                % write output variables on separate lines
                for ioutvar = 1:length(xb.data(ivar).value)
                    outputvars = [outputvars sprintf('%s\n', xb.data(ivar).value{ioutvar})];
                end
            elseif strcmp(upartype{i}, 'Output variables')
                % collect output variables for printing at the end of the
                % file
                outputvars = [sprintf('%s\n', var2params(xb.data(ivar).name, xb.data(ivar).value, maxStringLength)) outputvars];
            else
                % create ordinary parameter line
                fprintf(fid, '%s\n', var2params(xb.data(ivar).name, xb.data(ivar).value, maxStringLength));
            end
            catch
            end
        end
    end
end

% write output variables separately
header = 'Output variables';
fprintf(fid, '\n%s %s %s\n\n', '%%%', header, repmat('%',1,75-length(header)));
fprintf(fid, '%s', outputvars);

fclose(fid);

%%
function str = var2params(varname, value, maxStringLength)
%VAR2PARAMS  create string from name and value

% derive number of blanks to line out the '=' signs
nrBlanks = maxStringLength - length(varname);
% create last part of line, taking the type into account
s=whos('value');
switch s.class
    case 'char'
        str = sprintf(' %s', value);
    case {'logical' 'int' 'double'}
        str = '';
        value = num2cell(value);
        for i = 1:length(value)
            if ~strcmpi(s.class,'double') || value{i} == round(value{i})
                str = sprintf('%s %d', str, value{i});
            else
                str = sprintf('%s %f', str, value{i});
            end
        end
    otherwise
        str = sprintf( '%s', value);
end
str = sprintf('%s%s =%s', varname, blanks(nrBlanks), str);