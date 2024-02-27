function txt = netica_write_case_file(fname, varargin)
%NETICA_WRITE_CASE_FILE  write data to netica case file
%
%   Function to write data to a Netica case file.
%
%   Syntax:
%   txt = netica_write_case_file(fname, varargin)
%
%   Input:
%   fname     = filename of file to generate (put false to omit file
%                   writing)
%   varargin  = propertyname-propertyvalue pairs including defaults:
%       'IDnum', false
%       'NaN', '*'
%       'NumCases', false
%       'date', datestr(now)
%       'comments', false
%       variables are parsed as propertyname-propertyvalue pairs as well;
%       propertyname is the variablename and the propertyvalue are the
%       variable values.
%
%   Output:
%   txt = string of case file contents
%
%   Example
%   netica_write_case_file('testfile.cas', 'node1', rand(1,100), 'node2', rand(1,100
%   Example if doubles as well as cells are used as input:
%   netica_write_case_file('testfile.cas', 'node1', {{'a', 'b', 'c'}}, 'node2', {rand(1,3)})
%   See also netica

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Delft University of Technology
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
% Created: 31 Mar 2011
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: netica_write_case_file.m 12144 2015-07-30 08:09:56Z laurens.poelhekke.x $
% $Date: 2015-07-30 16:09:56 +0800 (Thu, 30 Jul 2015) $
% $Author: laurens.poelhekke.x $
% $Revision: 12144 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/netica/netica_write_case_file.m $
% $Keywords: $

%%
OPT = struct(...
    'IDnum', false,...
    'NaN', '*',...
    'NumCases', false,...
    'date', datestr(now),...
    'comments', false);

OPTn = mergestructs(OPT, struct(varargin{:}));

%%
vars = rmfield(OPTn, fieldnames(OPT));
nsamples = max(structfun(@length, vars));
if OPTn.IDnum
    vars = mergestructs(...
        struct('IDnum', {cellstr(num2str((1:nsamples)'))}),...
        vars);
end
varnames = fieldnames(vars);
nvars = length(varnames);

%% convert variables to cell arrays
strlength = ones(size(varnames));
for ivar = 1:nvars
    switch class(vars.(varnames{ivar}))
        case 'double'
            vars.(varnames{ivar}) = cellstr(num2str(vars.(varnames{ivar})(:)));
        case 'cell'
            vars.(varnames{ivar}) = vars.(varnames{ivar})(:);
        otherwise
            error('Variables of class "%s" are not yet supported', class(vars.(varnames{ivar})))
    end
    if ischar(OPTn.NaN)
        nanid = strcmp('NaN', cellfun(@strtrim, vars.(varnames{ivar}), 'UniformOutput', false));
        vars.(varnames{ivar})(nanid) = {OPTn.NaN};
    end
    strlength(ivar) = max([max(cellfun(@length, vars.(varnames{ivar}))) length(varnames{ivar})]);
end
% convert vars-structure to cell array containing the data
data = reshape(cells2cell(struct2cell(vars)), nsamples, nvars)';

%% create header
txt = '';
if OPT.comments
    txt = sprintf('%s//%s\n', OPT.comments);
end

creator = sprintf('%s @ %s (%s)', getenv('USERNAME'), getenv('COMPUTERNAME'), getenv('USERDOMAIN'));

txt = sprintf('%s// Created at: %s\n// Created by: %s\n\n', txt, OPT.date, creator);

% create cell matrix containing the formats
formats = [repmat({'%'}, size(varnames'));...
    cellfun(@strtrim, cellstr(num2str(strlength))', 'UniformOutput', false);...
    repmat({'s'}, size(varnames'));
    repmat({'\t'}, size(varnames(1:end-1)')) {'\n'}];

%% add column headers and variable values
txt = sprintf(['%s'  repmat(sprintf('%s', formats{:}), 1, nsamples+1)], txt, varnames{:}, data{:});

%% write to file
if fname
    fid = fopen(fname, 'w');
    fprintf(fid, '%s', txt);
    fclose(fid);
end