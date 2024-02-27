function varargout = readSTI(fname, varargin)
%READSTI  Read input file of D-Geo Stability.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = readSTI(fname, varargin)
%
%   Input: For <keyword,value> pairs call readSTI() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   readSTI
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
% Created: 26 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: readSTI.m 9176 2013-09-04 15:34:22Z heijer $
% $Date: 2013-09-04 23:34:22 +0800 (Wed, 04 Sep 2013) $
% $Author: heijer $
% $Revision: 9176 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DGeoStability/io/readSTI.m $
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

%% read file

fid = fopen(fname,'r');
contents = fread(fid,'*char')';
fclose(fid);

%% read sections

% read all section headers
pattern = '(?<=\[)[A-Za-z0-9\-\(\) ]{5,100}(?=\])';
ihdr = regexp(contents, pattern, 'start');
shdr = regexp(contents, pattern, 'match');
nshdr = regexprep(shdr, '\s', '_');

[ihdr,   ix] = sort(ihdr);
shdr = shdr(ix);

getfilename(fname)

D  = xs_empty();

% save header
D = HEADER_read(contents(1:ihdr(1)-2), D);
D = xs_meta(D, [mfilename '_'], 'D-Geo Stability', getfilename());

substr = false(size(ihdr));
i = 0;
j2 = 0;
while i<length(ihdr)
    i = find(ihdr>j2, 1, 'first');
    if regexp(shdr{i}, '^END OF ')
        j2 = ihdr(i);
        continue
    end
    j1 = ihdr(i)+length(shdr{i})+2;
    ie = strcmp(shdr, ['END OF ' shdr{i}]);
    if ~any(ie)
        ie = i+1;
    elseif sum(ie) > 1
        ie(1:i) = false;
        ie = find(ie, 1, 'first');
    end
%     if find(ie)>i+1
%         substr(i:find(ie)) = true;
%         shdr{i}
%         Ds = xs_empty();
%         i = i+1;
%         continue
%     end
    
    j2 = ihdr(ie)-2;


    str = contents(j1:j2);
    
    funcname = [upper(header2type(nshdr{i})) '_read'];


    if ~exist(funcname)
        Ds = str;
%         fprintf('"%s" skipped\n', shdr{i})
%         continue
    else
        
        func = str2func(['@' funcname]);
        Ds = feval(func, str);
    end
    D  = xs_set(D, header2type(nshdr{i}),Ds);
    
%     if substr(i)
%         Ds = xs_meta(Ds, [mfilename '_'], nshdr{i}, fname);
%         j = length(Ds.data)+1;
%         Ds.data(j).name = nshdr{i};
%         Ds.data(j).value = contents(j1:j2);
%     else
%         Ds = xs_empty();
%         Ds.data(1).name = nshdr{i};
%         Ds.data(1).value = contents(j1:j2);
%     end
%     if ~substr(i+1)
%         D  = xs_set(D,nshdr{i},Ds);
%     end
    
end

% %% code
% fid = fopen(fname);
% 
% % read the entire file as characters
% % transpose so that F is a row vector
% F = fread(fid, '*char')';
% 
% fclose(fid);
% 
% splittext = cellfun(@strtrim, regexp(F, '\n', 'split'),...
%     'UniformOutput', false);
% 
% D  = xs_empty();
% 
% categories = regexp(F, '(?<=\[)[A-Z ]*?(?=\])', 'match');
% level = zeros(size(splittext));
% tmp = regexp(categories, '(?<=^END OF ).*', 'match');
% level_cats = tmp(~cellfun(@isempty, tmp));
% level_cats = unique(cellfun(@(s) s{1}, level_cats, 'UniformOutput', false));
% % fprintf('%i\t%s\n', 
% 
% for i = 1:length(level_cats)
%     catbeg = strcmp(splittext, ['[' level_cats{i} ']']);
%     catend = strcmp(splittext, ['[END OF ' level_cats{i} ']']);
%     tmp = [find(catbeg') find(catend')];
%     if ~isscalar(tmp)
%         for j = 1:size(tmp,1)
%             level(tmp(j,1)+1:tmp(j,2)-1) = level(tmp(j,1)+1:tmp(j,2)-1) + 1;
%         end
%     end
% end
varargout = {D};
% for i = 1:length(splittext)
%     fprintf('%s%s\n', blanks(level(i)*5), splittext{i})
% end

function Tp = header2type(str)
str = regexprep(str, '[\[\]\.]', '');
str = regexprep(str, '\(.*\)', '');
Tp = strtrim(regexprep(strtrim(str), '[- ]', '_'));

function Tp = funname2type()
S = dbstack();
Tp = regexprep(S(2).name, '_+read$', '');

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

cellstr = regexp(strtrim(str), '\n', 'split');
cellstr = cellstr(1+OPT.skiplines:end);
cellstr = regexp(cellstr, OPT.delimiter, 'split');

for i = 1:length(cellstr)
    if ~isempty(OPT.format)
        val = sscanf(cellstr{i}{OPT.valcol}, OPT.format);
    else
        val = strtrim(cellstr{i}{OPT.valcol});
    end
    D = xs_set(D, header2type(cellstr{i}{OPT.namecol}), val);
end

function D = HEADER_read(str, D)
cellstr = regexp(str, '=+', 'split');
Ds = nameisvalue(cellstr{2},...
    'delimiter', ' : ',...
    'format', '');
D = xs_set(D, funname2type(), Ds);
D.header = cellstr{1};

function D = VERSION_read(str)
cellstr = regexp(strtrim(str), '\n+', 'split');

D = xs_empty();
D = xs_meta(D, getfunname(), 'VERSION', getfilename());

data = splitcellstr(cellstr, '=');
data(:,2) = num2cell(cellfun(@str2double, data(:,2)));
for i = 1:size(data,1)
    D.data(i).name = regexprep(data{i,1}, '\s', '_'); % probably hyphen will also cause problems in fieldname
    D.data(i).value = data{i,2};
end

function D = SOIL__read(str)
S = dbstack();

cellstr = regexp(strtrim(str), '\s+', 'split');
nameidx = cellfun(@isempty, strfind(cellstr, '='));
soiltype = strtrim(sprintf('%s ', cellstr{nameidx}));

D = xs_empty();
D = xs_meta(D, S(1).name, soiltype, getfilename());

data = splitcellstr(cellstr(~nameidx), '=');
data(:,2) = num2cell(cellfun(@str2double, data(:,2)));
for i = 1:size(data,1)
    D.data(i).name = data{i,1};
    D.data(i).value = data{i,2};
end

function D = SOIL_COLLECTION_read(str)
S = dbstack();

D = xs_empty();
D = xs_meta(D, S(1).name, 'SOIL COLLECTION', getfilename());

soilstrs = regexp(strtrim(str), '\[[A-Z ]+\]', 'split');
for i = 2:2:length(soilstrs)
    Ds = SOIL__read(soilstrs{i});
    D  = xs_set(D, Ds.type,Ds);
end

function D = ACCURACY_read(str)
D = str2double(str);

function D = POINTS_read(str)
tmp = regexp(str, '\n', 'split');
D = cell2mat(cellfun(@(s) sscanf(s, '%f'), tmp(3:end-1),...
    'uniformoutput', false))';

function D = CURVES_read(str)
S = dbstack();

D = xs_empty();
D = xs_meta(D, S(1).name, 'CURVES', getfilename());
curvestrs = regexp(strtrim(str), '\d+\s+-\s+Curve number\s+', 'split');
for i = 2:length(curvestrs)
    Ds = CURVE__read(curvestrs{i}, i-1);
    D  = xs_set(D, Ds.type,Ds);
end

function D = CURVE__read(str, icurve)
S = dbstack();

cellstr = regexp(strtrim(str), '\s+-.*pointnumbers\s+', 'split');

D = xs_empty();
D = xs_meta(D, S(1).name, sprintf('CURVE_%i', icurve), getfilename());

D.data(1).name = sprintf('pointnumbers');
D.data(1).value = sscanf(cellstr{2}, '%f')';

function D = GEOMETRY_DATA_read(str)
S = dbstack();

D = xs_empty();

[geomstrs, keys] = regexp(strtrim(str), '\[[A-Za-z\- ]{5,100}\]', 'split', 'match');

geomstrs = geomstrs(cellfun(@length, geomstrs) > 5);
keys = keys(1:2:end);

for i = 1:length(keys)
    funcname = [upper(header2type(keys{i})) '_read'];


    if ~exist(funcname)
        fprintf('"%s" skipped\n', keys{i})
        continue
    end
    func = str2func(['@' funcname]);
    Ds = func(geomstrs{i});
    if xs_check(Ds)
        Tp = Ds.type;
    else
        Tp = keys{i}(2:end-1);
    end
    D  = xs_set(D, Tp, Ds);
                
end

function D = BOUNDARIES_read(str)
[boundarystrs, boundarynmbrs] = regexp(str, '\d+(?=\s+-\s+Boundary number)', 'split', 'match');
formatstr = sprintf('%%%ii', length(boundarynmbrs(end)));
boundarynmbrs = str2double(boundarynmbrs);
S = dbstack();

D = xs_empty();
D = xs_meta(D, S(1).name, 'BOUNDARIES', getfilename());

for i = 1:length(boundarynmbrs)
    tmp = regexp(boundarystrs{i+1}, '(?<=curvenumbers\s+).*', 'match');
    curvenumbers = str2double(regexp(tmp{1}, ' ', 'split'));
    
    D = xs_set(D, sprintf(['BOUNDARY_' formatstr], boundarynmbrs(i)), curvenumbers);
end

function D = USE_PROBABILISTIC_DEFAULTS_BOUNDARIES_read(str)
tmp = regexp(str, '(?<=Number of boundaries\s+-\s+).*', 'match');
D = boolean(str2double(strsplit(tmp{1}, ' ')));

function D = STDV_BOUNDARIES_read(str)
tmp = regexp(str, '(?<=Number of boundaries\s+-\s+).*', 'match');
D = str2double(strsplit(tmp{1}, ' '));

function D = DISTRIBUTION_BOUNDARIES_read(str)
tmp = regexp(str, '(?<=Number of boundaries\s+-\s+).*', 'match');
D = str2double(strsplit(tmp{1}, ' '));

function D = PIEZO_LINES_read(str)
[linestrs, linenmbrs] = regexp(str, '\d+(?=\s+-\s+PlLine number)', 'split', 'match');
formatstr = sprintf('%%%ii', length(linenmbrs(end)));
linenmbrs = str2double(linenmbrs);

D = xs_empty();
D = xs_meta(D, getfunname(), funname2type(), getfilename());

for i = 1:length(linenmbrs)
    tmp = regexp(linestrs{i+1}, '(?<=curvenumbers\s+).*', 'match');
    curvenumbers = str2double(strsplit(tmp{1}, ' '));
    
    D = xs_set(D, sprintf(['PlLine_' formatstr], linenmbrs(i)), curvenumbers);
end

function D = PHREATIC_LINE_read(str)
D = sscanf(str, '%i');

function D = WORLD_CO_ORDINATES_read(str)
D = xs_empty();
D = xs_meta(D, getfunname(), 'WORLD_CO_ORDINATES', getfilename());

x = str2double(regexp(str, '[\d\.]+(?=\s+-\s+X\s+world)', 'match'));
y = str2double(regexp(str, '[\d\.]+(?=\s+-\s+Y\s+world)', 'match'));

D = xs_set(D, 'X_world', x);
D = xs_set(D, 'Y_world', y);

function D = LAYERS_read(str)
D = xs_empty();
D = xs_meta(D, getfunname(), 'LAYERS', getfilename());

[linestrs, linenmbrs] = regexp(str, '\d+(?=\s+-\s+Layer number, next line is material of layer)', 'split', 'match');
formatstr = sprintf('%%%ii', length(linenmbrs(end)));
linenmbrs = str2double(linenmbrs);

for ilayer = 1:length(linenmbrs)
    str = linestrs{ilayer+1};
    
    tmp = regexp(str, '(?<=material of layer\s+).*?(?=\s+\d)', 'match');
    material = header2type(strtrim(tmp{1}));
    
    Tp = sprintf(['LAYER_' formatstr '_' material], linenmbrs(ilayer));
    
    Ds = xs_empty();
    Ds = xs_meta(Ds, getfunname(), Tp, getfilename());
    
    [s,m] = regexp(str, '\d+', 'split', 'match');
    for i = 1:length(m)
        Ds = xs_set(Ds, header2type(strtrim(s{i+1}(4:end))), str2double(m{i}));
    end
    
    D = xs_set(D, Tp, Ds);
end

function D = LAYERLOADS_read(str)
%TODO('implement support LAYERLOADS')
D = str;

function D = RUN_IDENTIFICATION_TITLES(str)
D = regexp(strtrim(str), '\n', 'split');

function D = MODEL_read(str)

D = xs_empty();
D = xs_meta(D, getfunname(), funname2type(), getfilename());

cellstr = regexp(strtrim(str), '\n', 'split');
data = splitcellstr(cellstr, ':');

Bl = cellfun(@(s) strtrim(s) == '1', data(:,1));
txt = cellfun(@strtrim, regexprep(data(:,2), '\s+off\s*$', ''),...
    'UniformOutput', false);
for i = 1:length(Bl)
    D = xs_set(D, header2type(txt{i}), Bl(i));
end

function D = MSEEPNET_read(str)
D = xs_empty();
D = xs_meta(D, getfunname(), funname2type(), getfilename());
cellstr = regexp(strtrim(str), '\n', 'split');
nameidx = cellfun(@isempty, regexp(cellstr, '\d'));
data = splitcellstr(cellstr(~nameidx), ':');

Bl = cellfun(@(s) strtrim(s) == '1', data(:,1));
txt = cellfun(@strtrim, regexprep(data(:,2), '^\s+do not\s+', '', 'ignorecase'),...
    'UniformOutput', false);
for i = 1:length(Bl)
    D = xs_set(D, header2type(txt{i}), Bl(i));
end

function D = UNIT_WEIGHT_WATER_read(str)
D = sscanf(str, '%g');

function D = DEGREE_OF_CONSOLIDATION_read(str)
D = xs_empty();
D = xs_meta(D, getfunname(), funname2type(), getfilename());

cellstr = regexp(strtrim(str), '\n', 'split');

i = 2;
while i<length(cellstr)
    tmp = sscanf(cellstr{i}, '%g');
    D = xs_set(D, sprintf('layer_%i', tmp(1)), tmp(2:end)');
    i = i + 1;
end

tmp = regexp(cellstr{end}, '(?<=\d)\s+(?=\w)', 'split');
Tp = regexprep(tmp{end}, '\s+not\s+', ' ');
D = xs_set(D, header2type(Tp), strtrim(tmp{1}) == '1');

function D = DEGREE_TEMPORARY_LOADS_read(str)
D = xs_empty();
D = xs_meta(D, getfunname(), funname2type(), getfilename());

cellstr = regexp(strtrim(str), '\n', 'split');

D = xs_set(D, funname2type(), sscanf(cellstr{1}, '%g')');

tmp = regexp(cellstr{end}, '(?<=\d)\s+(?=\w)', 'split');
Tp = regexprep(tmp{end}, '\s+not\s+', ' ');
D = xs_set(D, header2type(Tp), strtrim(tmp{1}) == '1');

function D = DEGREE_FREE_WATER_read(str)
D = sscanf(str, '%g')';

function D = DEGREE_EARTH_QUAKE_read(str)
D = sscanf(str, '%g')';

function D = CIRCLES_read(str)
D = xs_empty();
D = xs_meta(D, getfunname(), funname2type(), getfilename());

cellstr = regexp(strtrim(str), '\n', 'split');
for i = 1:length(cellstr)
    tmp = regexp(cellstr{i}, '(?<=\d)\s+(?=[\D- ]+$)', 'split');
    values = sscanf(tmp{1}, '%g');
    Tp = header2type(regexprep(tmp{end}, '\s?(no|used)\s?', ''));
    D = xs_set(D, Tp, values);
end

function D = SPENCER_SLIP_DATA_read(str)
D = str;

function D = SPENCER_SLIP_DATA_2_read(str)
D = str;

function D = SPENCER_SLIP_INTERVAL_read(str)
D = sscanf(str, '%g');

function D = LINE_LOADS_read(str)
D = str;

function D = UNIFORM_LOADS_read(str)
D = str;

function D = TREE_ON_SLOPE_read(str)
D = xs_empty();
D = xs_meta(D, getfunname(), funname2type(), getfilename());

cellstr = regexp(strtrim(str), '\n', 'split');

data = splitcellstr(cellstr, '=');
val = cellfun(@str2double, data(:,1));
name = cellfun(@header2type, data(:,2), 'UniformOutput', false);
for i = 1:length(val)
    D = xs_set(D, name{i}, val(i));
end

function D = EARTH_QUAKE_read(str)
D = xs_empty();
D = xs_meta(D, getfunname(), funname2type(), getfilename());

cellstr = regexp(strtrim(str), '\n', 'split');

data = splitcellstr(cellstr, '=');
val = cellfun(@str2double, data(:,1));
name = cellfun(@header2type, data(:,2), 'UniformOutput', false);
for i = 1:length(val)
    D = xs_set(D, name{i}, val(i));
end

function D = SIGMA_TAU_CURVES_read(str)
D = str;

function D = BOND_STRESS_DIAGRAMS_read(str)
D = str;

function D = MINIMAL_REQUIRED_CIRCLE_DEPTH_read(str)
D = sscanf(str, '%g');

function D = SLIP_CIRCLE_SELECTION_read(str)
D = xs_empty();
D = xs_meta(D, getfunname(), funname2type(), getfilename());

cellstr = regexp(strtrim(str), '\n', 'split');

data = splitcellstr(cellstr, '=');
val = cellfun(@str2double, data(:,2));
name = cellfun(@header2type, data(:,1), 'UniformOutput', false);
for i = 1:length(val)
    D = xs_set(D, name{i}, val(i));
end

function D = START_VALUE_SAFETY_FACTOR_read(str)
D = sscanf(str, '%g');

function D = REFERENCE_LEVEL_CU_FACTOR_read(str)
D = sscanf(str, '%g');

function D = LIFT_SLIP_DATA_read(str)
D = xs_empty();
D = xs_meta(D, getfunname(), funname2type(), getfilename());

cellstr = regexp(strtrim(str), '\n', 'split');
for i = 1:length(cellstr)-1
    tmp = regexp(cellstr{i}, '(?<=\d)\s+(?=[\D- ]+$)', 'split');
    values = sscanf(tmp{1}, '%g');
    Tp = header2type(tmp{end});
    D = xs_set(D, Tp, values);
end

tmp = regexpi(cellstr{end}, '[a-z ]+', 'match');
Tp = header2type(tmp{end});
D = xs_set(D, Tp, sscanf(cellstr{end}, '%g'));

function D = EXTERNAL_WATER_LEVELS_read(str)
D = str;
TODO('ask Raymond')
% D = xs_empty();
% D = xs_meta(D, getfunname(), funname2type(), getfilename());
% 
% cellstr = regexp(strtrim(str), '\n', 'split');
% data = splitcellstr(cellstr, '=');
% Tp = header2type(regexprep(data{1,end}, '^\s+no', '', 'ignorecase'));
% D = xs_set(D, Tp, logical(str2double(data{1,1})));
% val = cellfun(@str2double, data(2:3,1));
% name = cellfun(@header2type, data(2:3,2), 'UniformOutput', false);
% for i = 1:length(val)
%     D = xs_set(D, name{i}, val(i));
% end

function D = MODEL_FACTOR_read(str)
D = nameisvalue(str, 'valcol', 1, 'namecol', 2);

function D = CALCULATION_OPTIONS_read(str)
D = nameisvalue(str);

function D = PROBABILISTIC_DEFAULTS_read(str)
D = nameisvalue(str);

function D = NEWZONE_PLOT_DATA_read(str)
D = str;
TODO('ask Raymond')

function D = HORIZONTAL_BALANCE_read(str)
D = nameisvalue(str);

function D = REQUESTED_CIRCLE_SLICES_read(str)
D = nameisvalue(str, 'valcol', 1, 'namecol', 2);

function D = REQUESTED_LIFT_SLICES_read(str)
D = nameisvalue(str, 'valcol', 1, 'namecol', 2);

function D = REQUESTED_SPENCER_SLICES_read(str)
D = nameisvalue(str, 'valcol', 1, 'namecol', 2);

function D = SOIL_RESISTANCE_read(str)
D = nameisvalue(str);

function D = GENETIC_ALGORITHM_OPTIONS_BISHOP_read(str)
D = nameisvalue(str);

function D = GENETIC_ALGORITHM_OPTIONS_LIFTVAN_read(str)
D = nameisvalue(str);

function D = GENETIC_ALGORITHM_OPTIONS_SPENCER_read(str)
D = nameisvalue(str);

function D = NAIL_TYPE_DEFAULTS_read(str)
D = nameisvalue(str);