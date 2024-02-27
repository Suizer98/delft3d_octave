function varargout = dgst_stiwrite(fname, D, varargin)
%DGST_STIWRITE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = dgst_stiwrite(varargin)
%
%   Input: For <keyword,value> pairs call dgst_stiwrite() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   dgst_stiwrite
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

% $Id: dgst_stiwrite.m 10185 2014-02-11 08:46:43Z heijer $
% $Date: 2014-02-11 16:46:43 +0800 (Tue, 11 Feb 2014) $
% $Author: heijer $
% $Revision: 10185 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DGeoStability/io/dgst_stiwrite.m $
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

txt = sprintf('%s', D.header);

for i = 1:length(D.data)
    txt = sprintf('%s%s', txt, writeblock(D.data(i)));
    if any(strcmp(D.data(i).name, {'VERSION', 'SOIL_COLLECTION', 'GEOMETRY_DATA'}))
        txt = sprintf('%s\r\n', txt);
    end
end
txt = sprintf('%s[END OF INPUT FILE]\r\n', txt);

% txt = regexprep(txt, '\r\r', '\r');

%% write file
fid = fopen(fname, 'w');
fprintf(fid, '%s', txt);
fclose(fid);

%%%%%%%%%%% private functions
%%%% general helper functions
function hd = type2header(str)
hd = regexprep(str, '_', ' ');
hd = regexprep(hd, '(?<= CO) (?=ORDINATES$)', '-');
hd = regexprep(hd, '(?<=^SIGMA) (?=TAU CURVES$)', '-');
hd = regexprep(hd, 'degree Free water', 'degree Free water(Cu)');
hd = regexprep(hd, 'UNIFORM LOADS$', 'UNIFORM LOADS ');

function txt = nameisvalue(Ds, varargin)
OPT = struct(...
    'header', '',...
    'namecol', 1,...
    'valcol', 2,...
    'delimiter', '=',...
    'format', '%g',...
    'trailingnewline', false,...
    'regexprep', {{}});

OPT = setproperty(OPT, varargin);
data = repmat({''}, 2, length(Ds.data));
data(OPT.namecol,:) = {Ds.data.name};
data(OPT.valcol,:) = {Ds.data.value};
for i = 1:2:length(OPT.regexprep)
    data(OPT.namecol,:) = regexprep(data(OPT.namecol,:), OPT.regexprep{i:i+1});
end
data(OPT.namecol,:) = regexprep(data(OPT.namecol,:), '_', ' ');
if ischar(OPT.format)
    fmt = {'%s', '%s'};
    fmt{OPT.valcol} = OPT.format;
    format = repmat(sprintf(['%s' OPT.delimiter '%s\r\n'], fmt{:}), 1, length(Ds.data));
elseif iscell(OPT.format)
    fmt = repmat({'%s'}, 3, length(Ds.data));
    fmt(2,:) = {OPT.delimiter};
    if OPT.valcol == 2
        fmt(3,:) = OPT.format;
    else
        fmt(OPT.valcol,:) = OPT.format;
    end
    format = sprintf(['%s%s%s\r\n'], fmt{:});
elseif isstruct(OPT.format)
    if isfield(OPT.format, 'default_')
        defformat = OPT.format.default_;
    else
        defformat = '';
    end
    formatcell = repmat({defformat}, 1, length(Ds.data));
    fnames = fieldnames(OPT.format);
    for i = 1:length(fnames)
        idx = ~cellfun(@isempty, regexp(fnames{i}, data(OPT.namecol,:), 'once'));
        if any(idx)
            formatcell{idx} = OPT.format.(fnames{i});
        end
    end
    if isfield(OPT.format, 'regexp_')
        for i = 1:2:length(OPT.format.regexp_)
            idx = ~cellfun(@isempty, regexp(data(OPT.namecol,:), OPT.format.regexp_{i}, 'once'));
            if any(idx)
                formatcell(idx) = OPT.format.regexp_(i+1);
            end
        end
    end
    OPT.format = formatcell;
    txt = nameisvalue(Ds, OPT);
    return
    %format = sprintf(['%%s' OPT.delimiter '%s\r\n'], formatcell{:});
end
if ~OPT.trailingnewline
    format = format(1:end-2);
end
txt = sprintf(format, data{:});

function txt = writeblock(Ds, varargin)

txt = sprintf('[%s]', type2header(Ds.name));
funcname = [upper(Ds.name) '_write'];
if exist(funcname)
    func = str2func(funcname);
    stxt = feval(func, Ds.value);
elseif ischar(Ds.value)
%     stxt = sprintf('%s\n', strtrim(Ds.value));
    cellstr = regexp(Ds.value, '\r\n', 'split');
    idx = ~cellfun(@(s) isempty(strtrim(s)), cellstr);
    stxt = sprintf('%s\r\n', cellstr{idx});
    if ~strcmp(Ds.name , {'LAYERLOADS', 'RUN_IDENTIFICATION_TITLES'})
        %stxt = regexprep(stxt, '\r\n$', '');
    elseif strcmp(Ds.name , 'LAYERLOADS')
        stxt = sprintf('%s\r\n', stxt);
    end
end
noendkeys = {'RUN_IDENTIFICATION_TITLES', 'MSEEPNET', 'UNIT_WEIGHT_WATER',...
    'DEGREE_OF_CONSOLIDATION', 'degree_Temporary_loads', 'degree_Free_water', 'degree_earth_quake',...
    'CIRCLES', 'SPENCER_SLIP_DATA', 'SPENCER_SLIP_DATA_2', 'SPENCER_SLIP_INTERVAL',...
    'LINE_LOADS', 'UNIFORM_LOADS_', 'EARTH_QUAKE', 'MINIMAL_REQUIRED_CIRCLE_DEPTH',...
    'START_VALUE_SAFETY_FACTOR', 'REFERENCE_LEVEL_CU', 'LIFT_SLIP_DATA',...
    'MULTIPLE_LIFT_TANGENTS', 'EXTERNAL_WATER_LEVELS', 'MODEL_FACTOR', 'NEWZONE_PLOT_DATA',...
    'REQUESTED_CIRCLE_SLICES', 'REQUESTED_LIFT_SLICES', 'REQUESTED_SPENCER_SLICES'};
if strcmp(Ds.name, 'Slip_Circle_Selection')
    endstr = sprintf('[End of %s]', type2header(Ds.name));
elseif ~any(strcmp(Ds.name, noendkeys))
    endstr = sprintf('[END OF %s]', type2header(Ds.name));
else
    endstr = '';
end
newlinekeys0 = {'GEOMETRY_DATA'};
newlinekeys2 = {'ACCURACY', 'POINTS', 'CURVES', 'BOUNDARIES',...
    'USE_PROBABILISTIC_DEFAULTS_BOUNDARIES', 'STDV_BOUNDARIES', 'DISTRIBUTION_BOUNDARIES',...
    'PIEZO_LINES', 'PHREATIC_LINE', 'WORLD_CO_ORDINATES', 'LAYERS', 'LAYERLOADS'};
if any(strcmp(Ds.name, newlinekeys0))
    endstr = sprintf('%s', endstr);
elseif any(strcmp(Ds.name, newlinekeys2))
    endstr = sprintf('%s\r\n\r\n', endstr);
else
    endstr = sprintf('%s\r\n', endstr);
end
txt = sprintf('%s\r\n%s%s', txt, stxt, endstr);

function txt = list_write(Ds, varargin)
OPT = struct(...
    'feature', '');
OPT = setproperty(OPT, varargin);
switch lower(OPT.feature)
    case 'curve'
        feature_plur = [OPT.feature 's'];
    case 'boundary'
        feature_plur = [OPT.feature(1:end-1) 'ies'];
    case 'plline'
        feature_plur = 'piezometric level lines';
    case 'layer'
        feature_plur = 'layers';
end
txt = sprintf('%4i - Number of %s -\r\n', length(Ds.data), lower(feature_plur));
for i = 1:length(Ds.data)
    ifeature = str2double(regexprep(Ds.data(i).name, '^\D+_', ''));
    if ~strcmpi('layer', OPT.feature)
        txt = sprintf('%s%6i - %s number\r\n', txt, ifeature, OPT.feature);
    else
        txt = sprintf('%s%6i - Layer number, next line is material of layer\r\n', txt, ifeature);
    end
    if strcmpi('curve', OPT.feature)
        txt = sprintf('%s%8i - number of points on %s, next line(s) are pointnumbers\r\n', txt, length(Ds.data(i).value), lower(OPT.feature));
    elseif strcmpi('boundary', OPT.feature)
        txt = sprintf('%s%8i - number of curves on %s, next line(s) are curvenumbers\r\n', txt, length(Ds.data(i).value), lower(OPT.feature));
    elseif strcmpi('PlLine', OPT.feature)
        txt = sprintf('%s%8i - number of curves on %s, next line(s) are curvenumbers\r\n', txt, length(Ds.data(i).value), OPT.feature);
    elseif strcmpi('layer', OPT.feature)
        txt = sprintf('%s%s%s\r\n', txt, blanks(8), type2header(Ds.data(i).value.type));
        stxt = nameisvalue(xs_get(Ds, Ds.data(i).name),...
            'delimiter', ' - ',...
            'valcol', 1,...
            'namecol', 2,...
            'trailingnewline', true);
        stxt = regexprep(stxt, '\r\n(?!$)', sprintf('%s\r\n', blanks(7)));
        stxt = sprintf('%s%s', blanks(7), stxt);
    end
    if ~strcmpi('layer', OPT.feature)    
        stxt = sprintf(['%10i' repmat('%6i', 1, min(10, length(Ds.data(i).value))-1) '\r\n'], Ds.data(i).value);
    end
    txt = sprintf('%s%s', txt, stxt);
end

function txt = probabilistic_boundary_list_write(Ds, varargin)

OPT = struct(...
    'format', '%g');
OPT = setproperty(OPT, varargin);
txth = sprintf('%4i - Number of boundaries -\r\n', length(Ds));
txtv = sprintf([OPT.format '\r\n'], Ds);
txt = sprintf('%s%s', txth, txtv);

function txt = requested_write(Ds)
txt = nameisvalue(Ds,...
    'namecol', 2,...
    'valcol', 1,...
    'format', '%3i',...
    'delimiter', '     =');

function txt = genetic_write(Ds)
txt = nameisvalue(Ds,...
    'trailingnewline', true,...
    'format', struct('default_', '%.3f', 'regexp_', {{'Count$', '%i'}}));

%%%% header specific functions
function txt = VERSION_write(Ds)
txt = nameisvalue(Ds,...
    'regexprep', {'D_Geo', 'D-Geo'});
txt = sprintf('%s\r\n', txt);

function txt = SOIL_COLLECTION_write(Ds)
n = length(Ds.data);
txt = sprintf('%5i = number of items\r\n', n);
for i = 1:n
    Dss = Ds.data(i);
    Dss.name = regexprep(Dss.name, '[_\d]', '');
    txt = sprintf('%s%s', txt, writeblock(Dss));
end

function txt = SOIL_write(Ds)
txt = sprintf('%s\r\n%s', regexprep(Ds.type, '_', ' '), nameisvalue(Ds,...
    'format', struct('default_', '%g',...
    'SoilColor', '%i',...
    'SoilPc', '%.2E',...
    'SoilExcessPorePressure', '%.2f',...
    'SoilPorePressureFactor', '%.2f',...
    'SoilCohesion', '%.2f',...
    'SoilPhi', '%.2f',...
    'SoilDilatancy', '%.2f',...
    'StrengthIncreaseExponent', '%.2f',...
    'SoilPOP', '%.2f',...
    'SoilRheologicalCoefficient', '%.2f',...
    'SoilCorrelationCPhi', '%.2f',...
    'SoilRRatio', '%.7f',...
    'SoilStressTableName', '%s',...
    'regexp_', {{...
    '^SoilStd.*', '%.2f',...
    '^SoilCu.*', '%.2f',...
    '[xy]CoorSoilPc$', '%.3f',...
    '^SoilGam.*', '%.2f',...
    '^SoilRatioCuPc.*', '%.2f',...
    '^SoilDesign.*', '%.2f',...
    '^SoilHorFluct.*', '%.2f'}}...
    )));
% the following keywords appear twice in the SOIL definition
repkeys = {'SoilDistCu', 'SoilDistCuTop', 'SoilDistCuGradient'};
for i = 1:length(repkeys)
    txt = sprintf('%s\r\n%s=%g', txt, repkeys{i},  xs_get(Ds, repkeys{i}));
end
txt = sprintf('%s\r\n', txt);

function txt = GEOMETRY_DATA_write(Ds)
txt = '';
for i = 1:length(Ds.data)
    Dss = Ds.data(i);
    txt = sprintf('%s%s', txt, writeblock(Dss));
end

function txt = ACCURACY_write(Ds)
txt = sprintf('%14.4f\r\n', Ds);

function txt = POINTS_write(Ds)
txth = sprintf('%7i  - Number of geometry points -\r\n', size(Ds,1));
txtd = sprintf('%8i%15.3f%15.3f%15.3f\r\n', Ds');
txt = sprintf('%s', txth, txtd);

function txt = CURVES_write(Ds)
txt = list_write(Ds,...
    'feature', 'Curve');

function txt = BOUNDARIES_write(Ds)
txt = list_write(Ds,...
    'feature', 'Boundary');

function txt = USE_PROBABILISTIC_DEFAULTS_BOUNDARIES_write(Ds)
txt = probabilistic_boundary_list_write(Ds,...
    'format', '%3i');

function txt = PIEZO_LINES_write(Ds)
txt = list_write(Ds,...
    'feature', 'PlLine');

function txt = LAYERS_write(Ds)
txt = list_write(Ds,...
    'feature', 'layer');

function txt = MODEL_write(Ds)
regexprepoff = {Ds.data(~[Ds.data.value]).name};
regexprepon = {Ds.data([Ds.data.value]==1).name};
regexprep = [regexprepoff(:)' regexprepon(:)';
    cellfun(@(s) [s ' off'], regexprepoff(:)', 'uniformoutput', false)...
    cellfun(@(s) [s ' on'], regexprepon(:)', 'uniformoutput', false)...
    ];
tmp = cellfun(@(s) ~strcmpi(regexprep(1,:)', s),...
    {'local_measurements' 'default_shear_strength' 'Mean' 'model'},...
    'UniformOutput', false);
idx = any(~cell2mat(tmp), 2);
regexprep = regexprep(:,~idx);
Ds.data(1).name = dgst_get_model(xs_get(Ds, 'model'));
Ds.data(2).name = dgst_get_defaultshearstrength(xs_get(Ds, 'default_shear_strength'));
txt = nameisvalue(Ds,...
    'namecol', 2,...
    'valcol', 1,...
    'delimiter', ' : ',...
    'format', '%3i',...
    'regexprep', regexprep(:));
txt = sprintf('%s\r\n', txt);

function txt = UNIT_WEIGHT_WATER_write(Ds)
txt = sprintf('%9.2f : Unit weight water', Ds);

function txt = DEGREE_OF_CONSOLIDATION_write(Ds)
layeridx = ~cellfun(@isempty, regexp({Ds.data.name}, 'layer'));
nlayers = sum(layeridx);
txt = sprintf('%4i Number of layers ', nlayers);
for i = find(layeridx)
    stxt = sprintf('%4i', xs_get(Ds, Ds.data(i).name));
    txt = sprintf('%s\r\n%6i     %s', txt, sscanf(regexprep(Ds.data(i).name, '[\D_]+', ''), '%i'), stxt);
end
for i = find(~layeridx)
    expl = type2header(Ds.data(i).name);
    if ~Ds.data(i).value
        expl = regexprep(expl, '(?<=water) (?=included)', ' not ');
    end
    stxt = sprintf('%3i    %s', Ds.data(i).value, expl);
    txt = sprintf('%s\r\n%s', txt, stxt);
end

function txt = DEGREE_TEMPORARY_LOADS_write(Ds)
stxt = sprintf('%4g', Ds.data(1).value);
txt = sprintf('%s%s ', blanks(10), stxt);
for i = 2:length(Ds.data)
    expl = type2header(Ds.data(i).name);
    if ~Ds.data(i).value
        expl = regexprep(expl, '(?<=water) (?=included)', ' not ');
    end
    stxt = sprintf('%3i    %s', Ds.data(i).value, expl);
    txt = sprintf('%s\r\n%s', txt, stxt);
end

function txt = DEGREE_FREE_WATER_write(Ds)
stxt = sprintf('%4g', Ds);
txt = sprintf('%s%s ', blanks(10), stxt);

function txt = DEGREE_EARTH_QUAKE_write(Ds)
stxt = sprintf('%4g', Ds);
txt = sprintf('%s%s ', blanks(10), stxt);

function txt = CIRCLES_write(Ds)
for i = 1:length(Ds.data)
    key = type2header(Ds.data(i).name);
    key = regexprep(key, '(?<=^[XY]) (?=dir)', '-');
    if Ds.data(i).value(end) == 0
        key = sprintf('no %s used ', key);
    end
    stxt = sprintf('%13.3f%17.3f%8i    %s', Ds.data(i).value, key);
    if i == 1
        txt = stxt;
    else
        txt = sprintf('%s\r\n%s', txt, stxt);
    end
end

function txt = UNIFORM_LOADS__write(Ds)
n = length(Ds.data);
txt = sprintf('%3i     = number of items', n);
for i = 1:n
    typename = Ds.data(i).name;
    stxt = nameisvalue(xs_get(Ds, typename),...
        'namecol', 2,...
        'valcol', 1,...
        'delimiter', ' = ',...
        'format', struct('default_', '%7.2f', 'regexp_', {{'^xstart', '%7.2f %10.2f', '^temporary', '%7g'}}));
    txt = sprintf('%s\r\n%s\r\n%s', txt, typename, stxt);
end

function txt = EARTH_QUAKE_write(Ds)
txt = nameisvalue(Ds,...
    'namecol', 2,...
    'valcol', 1,...
    'delimiter', ' = ',...
    'format', '%10.3f');

function txt = SIGMA_TAU_CURVES_write(Ds)
n = length(Ds.data);
txt = sprintf('%5i = number of items\r\n', n);
for i = 1:n
    Dss = Ds.data(i);
    Dss.name = regexprep(Dss.name, '(?<=CURVE)[_\d]+', '');
    txt = sprintf('%s%s', txt, writeblock(Dss));
end

function txt = STRESS_CURVE_write(Ds)
pointidx = ~cellfun(@isempty, regexp({Ds.data.name}, '^POINT', 'once'));
n = length(pointidx);
txt = sprintf('%s\r\n%i', Ds.type, sum(pointidx));
for i = 1:n
    if pointidx(i)
        Dss = xs_get(Ds, Ds.data(i).name);
        stxt = nameisvalue(Dss,...
            'trailingnewline', true,...
            'format', '%.2f');
        txt = sprintf('%s\r\n[POINT]\r\n%s[END OF POINT]', txt, stxt);
    else
        Dss = Ds;
        idx = false(size(pointidx));
        idx(i) = true;
        Dss.data(~idx) = [];
        txt = sprintf('%s\r\n%s', txt, nameisvalue(Dss));
    end
end
txt = sprintf('%s\r\n', txt);

function txt = MINIMAL_REQUIRED_CIRCLE_DEPTH_write(Ds)
txt = sprintf('%10.2f     [m]', Ds);

function txt = SLIP_CIRCLE_SELECTION_write(Ds)
txt = nameisvalue(Ds,...
    'trailingnewline', true,...
    'format', struct('regexp_', {{'Used$', '%i', '^XEntry', '%.2f'}}));

function txt = LIFT_SLIP_DATA_write(Ds)
for i = 1:length(Ds.data)-1
    key = type2header(Ds.data(i).name);
    key = regexprep(key, '(?<=^[XY]) (?=dir)', '-');
    if Ds.data(i).value(end) == 0
        key = sprintf('no %s used ', key);
    end
    stxt = sprintf('%13.3f%17.3f%8i    %s', Ds.data(i).value, key);
    if i == 1
        txt = stxt;
    else
        txt = sprintf('%s\r\n%s', txt, stxt);
    end
end
key = regexprep(type2header(Ds.data(end).name), ' (?=\d+)', ' (');
key = [key ')'];
txt = sprintf('%s\r\n%13i%s%s', txt, Ds.data(end).value, blanks(29), key);

function txt = MULTIPLE_LIFT_TANGENTS_write(Ds)
txt = sprintf('%14i    Number of tangentlines%s', length(Ds), sprintf('\r\n%14.3f', Ds));

function txt = EXTERNAL_WATER_LEVELS_write(Ds)
tmp = Ds;
tmp.data(4:end) = [];
if ~tmp.data(1).value
    tmp.data(1).name = sprintf('No %s used', type2header(tmp.data(1).name));
end
txt = nameisvalue(tmp,...
    'namecol', 2,...
    'valcol', 1,...
    'delimiter', '      = ',...
    'format', {'%6g' '%6.2f' '%6.2f'});
txt = sprintf('%s\r\n%5i     norm = 1/%i\r\n', txt, 1, 1/Ds.data(4).value);
idx = ~cellfun(@isempty, regexp({Ds.data.name}, 'Water_data_\d+', 'once'));
txt = sprintf('%s%5i = number of items', txt, sum(idx));
for i = 1:sum(idx)
    Dss = xs_get(Ds, sprintf('Water_data_%i', i));
    stxt = sprintf('Water data (%i)\r\n%s', i, nameisvalue(Dss, 'namecol', 2, 'valcol', 1, 'delimiter', ' = ', 'format', struct('default_', '%6g', 'Level', '%6.2f')));
    txt = sprintf('%s\r\n%s', txt, stxt);
end
Dss = xs_get(Ds, 'Piezo_lines');
n = size(Dss,1);
txt = sprintf('%s\r\n Piezo lines\r\n%4i - Number of layers', txt, n);
for i = 1:n
    stxt = sprintf('%8g%10g = Pl-top and pl-bottom', Dss(i,:));
    txt = sprintf('%s\r\n%s', txt, stxt);
end

function txt = MODEL_FACTOR_write(Ds)
txt = nameisvalue(Ds,...
    'namecol', 2,...
    'valcol', 1,...
    'delimiter', ' = ',...
    'format', struct('default_', '%16.2f', 'regexp_', {{'^Use', '%5i'}}));

function txt = CALCULATION_OPTIONS_write(Ds)
txt = nameisvalue(Ds,...
    'trailingnewline', true);

function txt = PROBABILISTIC_DEFAULTS_write(Ds)
txt = nameisvalue(Ds,...
    'trailingnewline', true,...
    'format', struct('default_', '%.2f', 'regexp_', {{'Distribution$', '%.0f'}}));

% function txt = NEWZONE_PLOT_DATA_write(Ds)
% txt = nameisvalue(Ds,...
%     'trailingnewline', true,...
%     'namecol', 2,...
%     'valcol', 1,...
%     'format', struct('default_', '%.2f', 'regexp_', {{}}));

function txt = HORIZONTAL_BALANCE_write(Ds)
txt = nameisvalue(Ds,...
    'trailingnewline', true,...
    'format', struct('default_', '%.2f', 'regexp_', {{'X(Left|Right)$', '%.3f', 'Interval$', '%.0f'}}));

function txt = REQUESTED_CIRCLE_SLICES_write(Ds)
txt = requested_write(Ds);

function txt = REQUESTED_LIFT_SLICES_write(Ds)
txt = requested_write(Ds);

function txt = REQUESTED_SPENCER_SLICES_write(Ds)
txt = requested_write(Ds);

function txt = SOIL_RESISTANCE_write(Ds)
txt = nameisvalue(Ds,...
    'trailingnewline', true);

function txt = GENETIC_ALGORITHM_OPTIONS_BISHOP_write(Ds)
txt = genetic_write(Ds);

function txt = GENETIC_ALGORITHM_OPTIONS_LIFTVAN_write(Ds)
txt = genetic_write(Ds);

function txt = GENETIC_ALGORITHM_OPTIONS_SPENCER_write(Ds)
txt = genetic_write(Ds);

function txt = NAIL_TYPE_DEFAULTS_write(Ds)
txt = nameisvalue(Ds,...
    'trailingnewline', true,...
    'format', struct('default_', '%.2f', 'regexp_', {{'BendingStiffness', '%.2E', 'Use', '%i'}}));