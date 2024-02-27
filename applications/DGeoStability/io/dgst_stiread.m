function varargout = dgst_stiread(fname, varargin)
%DGST_STIREAD  Read input file of D-Geo Stability.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = dgst_stiread(varargin)
%
%   Input: For <keyword,value> pairs call dgst_stiread() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   dgst_stiread
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 05 Sep 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: dgst_stiread.m 10185 2014-02-11 08:46:43Z heijer $
% $Date: 2014-02-11 16:46:43 +0800 (Tue, 11 Feb 2014) $
% $Author: heijer $
% $Revision: 10185 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DGeoStability/io/dgst_stiread.m $
% $Keywords: $

%%
OPT = struct();
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code

%% read file

fid = fopen(fname,'r');
contents = fread(fid,'*char')';
fclose(fid);

[datastr, keys] = regexpi(strtrim(contents), '\[[a-z0-9\-\(\) ]{4,100}\]',...
    'split', 'match');

% datastr = datastr(~cellfun(@(s) isempty(strtrim(s)), datastr));

D = xs_empty();
D.header = datastr{1};
D.type = 'input';
D.file = getfilename(fname);

% endid = ~cellfun(@isempty, regexpi(keys, '[end of '));

for i = 1:length(keys)
    if regexpi(keys{i}, '[end of')
        if isempty(strtrim(datastr{i+1}))
            continue
        else
            Tp = header2type(keys{i+1});
        end
    else
        Tp = header2type(keys{i});
    end
    funcname = sprintf('%s_read', upper(Tp));
    if exist(funcname)
        func = str2func(funcname);
    else
        func = @fallback_read;
    end
    D = feval(func, datastr{i+1}, Tp, D);
end

varargout = {D};

%%%%%%%%%%% private functions
%%%% general helper functions
function Tp = header2type(str)
str = regexprep(str, '[\[\]\.]', '');
str = regexprep(str, '\(.*\)', '');
Tp = strtrim(regexprep(str, '[- ]', '_'));

function Tp = funname2type()
S = dbstack();
Tp = regexprep(S(2).name, '_read$', '');

function varargout = getfilename(varargin)
persistent fname
if nargin == 1
    fname = abspath(varargin{1});
end
varargout = {fname};

function fun = getfunname(varargin)
S = dbstack();
fun = S(2).name;

function D = nameisvalue(str, varargin)
OPT = struct(...
    'skiplines', 0,...
    'namecol', 1,...
    'valcol', 2,...
    'delimiter', '=',...
    'format', '%g',...
    'regexprep', {{}});

OPT = setproperty(OPT, varargin);

D = xs_empty();
D = xs_meta(D, getfunname(), funname2type(), getfilename());

cellstr = regexp(strtrim(str), '\r\n', 'split');
cellstr = cellstr(1+OPT.skiplines:end);
cellstr = regexp(cellstr, OPT.delimiter, 'split');

for i = 1:length(cellstr)
%     if ~isempty(OPT.format)
%         val = sscanf(cellstr{i}{OPT.valcol}, OPT.format);
%     else
%         val = strtrim(cellstr{i}{OPT.valcol});
%     end
    valstr = strtrim(cellstr{i}{OPT.valcol});
    if isempty(regexpi(valstr, '[^e\.+-\d ]', 'once'))
        val = sscanf(cellstr{i}{OPT.valcol}, '%g');
    else
        val = valstr;
    end
    key = cellstr{i}{OPT.namecol};
    for j = 1:2:length(OPT.regexprep)
        key = regexprep(key, OPT.regexprep{j:j+1});
    end
    D = xs_set(D, header2type(key), val);
end

function D = list_read(str, varargin)
OPT = struct(...
    'feature', '');
OPT = setproperty(OPT, varargin);

D = xs_empty();
D = xs_meta(D, getfunname(), funname2type(), getfilename());
[datastr, hstr] = regexp(str, '\d+\s+-\s+(Curve|Boundary|PlLine|Layer) number.*?\r\n', 'split', 'match');
format = ['%0' num2str(ceil(log10(length(hstr)))) 'i'];
for i = 2:length(datastr)
    tmp = regexprep(datastr{i}, '^.*?numbers', '');
    if strcmpi(OPT.feature, 'layers')
        Ds = nameisvalue(tmp, 'skiplines', 1, 'delimiter', ' - ', 'valcol', 1, 'namecol', 2);
        tmpsoil = regexp(tmp, '(?<=^\s+).*?(?=\r\n)', 'match'); % first line of text block
        Ds.type = header2type(strtrim(tmpsoil{1})); % soil type
        D = xs_set(D, sprintf(['%s_' format], OPT.feature, sscanf(hstr{i-1}, '%i')), Ds);
    else
        D = xs_set(D, sprintf(['%s_' format], OPT.feature, sscanf(hstr{i-1}, '%i')), sscanf(tmp, '%i'));
    end
end


function D = fallback_read(str, key, D)
D = xs_set(D, header2type(key), str);

function Ds = requested_read(str)
Ds = nameisvalue(str,...
    'namecol', 2,...
    'valcol', 1);

%%%% header specific functions
function D = VERSION_read(str, key, D)
Ds = nameisvalue(str);
D = xs_set(D, key, Ds);

function D = SOIL_COLLECTION_read(str, key, D)
Ds = xs_empty();
Ds = xs_meta(Ds, getfunname(), funname2type(), getfilename());
D = xs_set(D, key, Ds);

function D = SOIL_read(str, key, D)
Dss = nameisvalue(str, 'skiplines', 1);
tmp = regexp(str, '(?<=^\s*).*?(?=\r\n)', 'match'); % first line of text block
Dss.type = header2type(strtrim(tmp{1})); % soil type
Ds = xs_get(D, 'SOIL_COLLECTION');
Ds = xs_set(Ds, sprintf('%s_%02i', key, length(Ds.data)+1), Dss);
D = xs_set(D, 'SOIL_COLLECTION', Ds);

function D = GEOMETRY_DATA_read(str, key, D)
Ds = xs_empty();
Ds = xs_meta(Ds, getfunname(), key, getfilename());
D = xs_set(D, key, Ds);

function D = ACCURACY_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str2double(str));
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = POINTS_read(str, key, D)
tmp = regexp(str, '\r\n', 'split');
data = cell2mat(cellfun(@(s) sscanf(s, '%f'), tmp(3:end-1),...
    'uniformoutput', false))';
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, data);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = CURVES_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Dss = list_read(str,...
    'feature', 'CURVE');
Ds = xs_set(Ds, key, Dss);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = BOUNDARIES_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Dss = list_read(str,...
    'feature', 'BOUNDARY');
Ds = xs_set(Ds, key, Dss);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = USE_PROBABILISTIC_DEFAULTS_BOUNDARIES_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
val = sscanf(regexprep(str, '^.*?boundaries.*?\r\n', ''), '%i');
Ds = xs_set(Ds, key, logical(val));
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = STDV_BOUNDARIES_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = DISTRIBUTION_BOUNDARIES_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = PIEZO_LINES_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Dss = list_read(str,...
    'feature', 'PlLine');
Ds = xs_set(Ds, key, Dss);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

% Ds = xs_get(D, 'GEOMETRY_DATA');
% Ds = xs_set(Ds, key, str);
% D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = PHREATIC_LINE_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = WORLD_CO_ORDINATES_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = LAYERS_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Dss = list_read(str, 'feature', 'layers');
Ds = xs_set(Ds, key, Dss);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = LAYERLOADS_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = RUN_IDENTIFICATION_TITLES_read(str, key, D)
D = xs_set(D, key, str);

function D = MODEL_read(str, key, D)
Ds = nameisvalue(str,...
    'namecol', 2,...
    'valcol', 1,...
    'delimiter', ' : ',...
    'regexprep', {'\s+(on|off)$', ''});
Ds.data(1).name = 'Model';
Ds.data(2).name = 'default_shear_strength';
D = xs_set(D, key, Ds);

function D = MSEEPNET_read(str, key, D)
D = xs_set(D, key, str);

function D = UNIT_WEIGHT_WATER_read(str, key, D)
D = xs_set(D, key, sscanf(str, '%g'));

function D = DEGREE_OF_CONSOLIDATION_read(str, key, D)
Ds = xs_empty();
Ds = xs_meta(Ds, getfunname(), funname2type(), getfilename());

cellstr = regexp(strtrim(str), '\r\n', 'split');

i = 2;
while i<length(cellstr)
    tmp = sscanf(cellstr{i}, '%g');
    Ds = xs_set(Ds, sprintf('layer_%i', tmp(1)), tmp(2:end)');
    i = i + 1;
end

val = logical(sscanf(cellstr{end}, '%i'));
tmp = strtrim(regexprep(cellstr{end}, '[^\D]', ''));
Tp = regexprep(tmp, '\s+not\s+', ' ');
Ds = xs_set(Ds, header2type(Tp), val);
D = xs_set(D, key, Ds);

function D = DEGREE_TEMPORARY_LOADS_read(str, key, D)
Ds = xs_empty();
Ds = xs_meta(Ds, getfunname(), funname2type(), getfilename());
cellstr = regexp(strtrim(str), '\r\n', 'split');
Ds = xs_set(Ds, 'data', sscanf(cellstr{1}, '%g'));

val = logical(sscanf(cellstr{end}, '%i'));
tmp = strtrim(regexprep(cellstr{end}, '[^\D]', ''));
Tp = regexprep(tmp, '\s+not\s+', ' ');
Ds = xs_set(Ds, header2type(Tp), val);
D = xs_set(D, key, Ds);

function D = DEGREE_FREE_WATER_read(str, key, D)
D = xs_set(D, key, sscanf(str, '%g'));

function D = DEGREE_EARTH_QUAKE_read(str, key, D)
D = xs_set(D, key, sscanf(str, '%g'));

function D = CIRCLES_read(str, key, D)
Ds = xs_empty();
Ds = xs_meta(Ds, getfunname(), funname2type(), getfilename());

cellstr = regexp(strtrim(str), '\r\n', 'split');
for i = 1:length(cellstr)
    tmp = regexp(cellstr{i}, '(?<=\d)\s+(?=[\D- ]+$)', 'split');
    values = sscanf(tmp{1}, '%g');
    Tp = header2type(regexprep(tmp{end}, '\s?(no|used)\s?', ''));
    Ds = xs_set(Ds, Tp, values);
end
D = xs_set(D, key, Ds);

function D = SPENCER_SLIP_DATA_read(str, key, D)
D = xs_set(D, key, str);

function D = SPENCER_SLIP_DATA_2_read(str, key, D)
D = xs_set(D, key, str);

function D = SPENCER_SLIP_INTERVAL_read(str, key, D)
D = xs_set(D, key, str);

function D = LINE_LOADS_read(str, key, D)
D = xs_set(D, key, str);

function D = UNIFORM_LOADS__read(str, key, D)
Ds = xs_empty();
n = sscanf(str, '%i');
[m,s] = regexp(str, '\r\n[^=]*?\r\n', 'match', 'split');
for i = 1:n
    Dss = nameisvalue(s{i+1},...
        'namecol', 2, 'valcol', 1,...
        'delimiter', ' = ',...
        'regexprep', {'\s+$', ''});
    Ds = xs_set(Ds, header2type(m{i}), Dss);
end
D = xs_set(D, funname2type(), Ds);

function D = TREE_ON_SLOPE_read(str, key, D)
D = xs_set(D, key, str);

function D = EARTH_QUAKE_read(str, key, D)
val = nameisvalue(str,...
    'namecol', 2,...
    'valcol', 1,...
    'delimiter', ' = ');
D = xs_set(D, key, val);

function D = SIGMA_TAU_CURVES_read(str, key, D)
D = xs_set(D, key, xs_empty());

function D = STRESS_CURVE_read(str, key, D)
tmp = regexp(str, '(?<=^\s*).*?(?=\r\n)', 'match'); % first line of text block
Dss = xs_empty();
Dss.type = strtrim(tmp{1});%header2type(strtrim(tmp{1})); % soil type
Ds = xs_get(D, 'SIGMA_TAU_CURVES');
Ds = xs_set(Ds, sprintf('%s_%02i', key, length(Ds.data)+1), Dss);
D = xs_set(D, 'SIGMA_TAU_CURVES', Ds);
%D = xs_set(D, key, str);

function D = POINT_read(str, key, D)
Ds = xs_get(D, 'SIGMA_TAU_CURVES');
typename = sprintf('SIGMA_TAU_CURVES.%s', Ds.data(end).name);
Dss = xs_get(D, typename);
Dsss = nameisvalue(str);
Dss = xs_set(Dss, sprintf('%s_%02i', key, length(Dss.data)+1), Dsss);
D = xs_set(D, typename, Dss);

function D = END_OF_STRESS_CURVE_read(str, key, D)
Ds = xs_get(D, 'SIGMA_TAU_CURVES');
typename = sprintf('SIGMA_TAU_CURVES.%s', Ds.data(end).name);
Dss = xs_get(D, typename);
Dsss = nameisvalue(str);
for i = 1:length(Dsss.data)
    Dss = xs_set(Dss, Dsss.data(i).name, Dsss.data(i).value);
end
D = xs_set(D, typename, Dss);

function D = BOND_STRESS_DIAGRAMS_read(str, key, D)
D = xs_set(D, key, str);

function D = MINIMAL_REQUIRED_CIRCLE_DEPTH_read(str, key, D)
units = regexprep(str, '^.*\[|\].*$', '');
val = sscanf(str, '%g');
D = xs_set(D, '-units', key, {val units});

function D = SLIP_CIRCLE_SELECTION_read(str, key, D)
Ds = nameisvalue(str);
D = xs_set(D, key, Ds);

function D = START_VALUE_SAFETY_FACTOR_read(str, key, D)
D = xs_set(D, key, str);

function D = REFERENCE_LEVEL_CU_read(str, key, D)
D = xs_set(D, key, str);

function D = LIFT_SLIP_DATA_read(str, key, D)
Ds = xs_empty();
Ds = xs_meta(Ds, getfunname(), funname2type(), getfilename());

cellstr = regexp(strtrim(str), '\r\n', 'split');
for i = 1:length(cellstr)-1
    tmp = regexp(cellstr{i}, '(?<=\d)\s+(?=[\D- ]+$)', 'split');
    values = sscanf(tmp{1}, '%g');
    Tp = header2type(regexprep(tmp{end}, '\s?(no|used)\s?', ''));
    Ds = xs_set(Ds, Tp, values);
end
Tp = header2type(regexprep(cellstr{end}, '^[\d\s]+(?=\D)|[\(\)]', ''));
Ds = xs_set(Ds, Tp, sscanf(cellstr{end}, '%i'));
D = xs_set(D, key, Ds);

function D = MULTIPLE_LIFT_TANGENTS_read(str, key, D)
tmp = cellfun(@str2double, regexp(str, '\r\n', 'split'));
D = xs_set(D, funname2type(), tmp(~isnan(tmp)));

function D = EXTERNAL_WATER_LEVELS_read(str, key, D)
cellstr = regexp(str, '\r\n', 'split');
Ds = nameisvalue(sprintf('%s\r\n', cellstr{2:4}),...
    'namecol', 2,...
    'valcol', 1,...
    'delimiter', '= ',...
    'regexprep', {'^\s+|No\s|\sused|\s+$', ''});
Ds = xs_set(Ds, 'norm', eval(regexprep(cellstr{5}, '^.*=', '')));
wdcellstr = regexp(str, 'Water data \(\d+\)|Piezo lines', 'split');
format = sprintf('%%0%ii', ceil(log10(length(wdcellstr))));
for i = 2:length(wdcellstr)-1
    Dss = nameisvalue(wdcellstr{i},...
        'namecol', 2,...
        'valcol', 1,...
        'delimiter', '= ',...
        'regexprep', {'\s+$', ''});
    Ds = xs_set(Ds, sprintf(['Water_data_' format], i-1), Dss);
end
tmp = regexp(str, '^[\d ]+(?= = Pl-top and pl-bottom)','match', 'lineanchors');
val = cell2mat(cellfun(@(s) sscanf(s, '%g'), tmp, 'uniformoutput', false))';
Ds = xs_set(Ds, 'Piezo_lines', val);

D = xs_set(D, key, Ds);

function D = MODEL_FACTOR_read(str, key, D)
Ds = nameisvalue(str,...
    'namecol', 2,...
    'valcol', 1,...
    'delimiter', ' = ');
D = xs_set(D, key, Ds);

function D = CALCULATION_OPTIONS_read(str, key, D)
Ds = nameisvalue(str);
D = xs_set(D, key, Ds);

function D = PROBABILISTIC_DEFAULTS_read(str, key, D)
Ds = nameisvalue(str);
D = xs_set(D, key, Ds);

function D = NEWZONE_PLOT_DATA_read(str, key, D)
% Ds = nameisvalue(str,...
%     'namecol', 2,...
%     'valcol', 1);
D = xs_set(D, key, str);

function D = HORIZONTAL_BALANCE_read(str, key, D)
D = xs_set(D, key, nameisvalue(str));

function D = REQUESTED_CIRCLE_SLICES_read(str, key, D)
D = xs_set(D, key, requested_read(str));

function D = REQUESTED_LIFT_SLICES_read(str, key, D)
D = xs_set(D, key, requested_read(str));

function D = REQUESTED_SPENCER_SLICES_read(str, key, D)
D = xs_set(D, key, requested_read(str));

function D = SOIL_RESISTANCE_read(str, key, D)
D = xs_set(D, key, nameisvalue(str));

function D = GENETIC_ALGORITHM_OPTIONS_BISHOP_read(str, key, D)
D = xs_set(D, key, nameisvalue(str));

function D = GENETIC_ALGORITHM_OPTIONS_LIFTVAN_read(str, key, D)
D = xs_set(D, key, nameisvalue(str));

function D = GENETIC_ALGORITHM_OPTIONS_SPENCER_read(str, key, D)
D = xs_set(D, key, nameisvalue(str));

function D = NAIL_TYPE_DEFAULTS_read(str, key, D)
D = xs_set(D, key, nameisvalue(str));