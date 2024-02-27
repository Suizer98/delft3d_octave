function varargout = nc_cf_standard_names_generate(varargin)
%NC_CF_STANDARD_NAMES_GENERATE  generates nc_CF_standards based nc_cf_standard_names_catalogue.xls
%
%   Syntax:
%       varargout = nc_cf_standard_names_generate(varargin)
%
%   Example
%       nc_cf_standard_names_generate
%
%   See also nc_oe_standard_names

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Van Oord
%       Mark van Koningsveld
%
%       mrv@vanoord.com
%
%       Watermanweg 64
%       POBox 8574
%       3009 AN Rotterdam
%       Netherlands
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

% This tools is part of VOTools which is the internal clone of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 14 Nov 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: nc_cf_standard_names_generate.m 4583 2011-05-19 08:50:31Z thijs@damsma.net $
% $Date: 2011-05-19 16:50:31 +0800 (Thu, 19 May 2011) $
% $Author: thijs@damsma.net $
% $Revision: 4583 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_cf_standard_names_generate.m $
% $Keywords: $

%% settings
% defaults
OPT = struct(...
    'filename', [fileparts(mfilename('fullpath')) filesep 'nc_cf_standard_names.m'], ...       % description of input argument 1
    'varname', {'time'} ...        % description of input argument 2
    );

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

clc

%% get standard names info from xls file
[num, txt, raw] = xlsread('nc_cf_standard_names_catalogue.xls','Sheet1');

ids = cellfun(@isnan, raw(6:end,1), 'UniformOutput', false);ids = ~vertcat(ids{:});
raw = raw([false; false; false; false; false; ids],:);

nc_cf_standard_names_create_header_1(OPT.filename);

fid = fopen(OPT.filename,'a');
for i = 1:size(raw,1)
    fprintf(fid,'%s\n',['%        (' raw{i,2} ') ''' raw{i,3} '''']);
end
fclose(fid);

nc_cf_standard_names_create_header_2(OPT.filename);

fid = fopen(OPT.filename,'a');
for i = 1:size(raw,1)
    fprintf(fid,'%s\n',['        case ' '''' raw{i,3} '''']);
    fprintf(fid,'%s\n',['            % add variable: ' raw{i,3}]);
    fprintf(fid,'%s\n',['            Variable = struct(...']); %#ok<*NBRAK>
    fprintf(fid,'%s\n',['               ''Name'',       OPT.varname{i} , ...']);
    fprintf(fid,'%s\n',['               ''Nctype'',    ''' raw{i,6} ''', ... ']);
    fprintf(fid,'%s\n',['               ''Dimension'', {OPT.dimension(i,:)}, ... ']);
    fprintf(fid,'%s\n',['               ''Attribute'', struct( ... ']);
    fprintf(fid,'%s\n',['                   ''Name'', ... ']);
    fprintf(fid,'%s\n',['                   {''standard_name'', ''long_name'', ''units'', ''_FillValue''}, ...']);
    fprintf(fid,'%s\n',['                   ''Value'', ... ']);
    if strncmp(raw{i,3}, 'time',4)
        fprintf(fid,'%s\n',['                   {''' raw{i,3} ''', ''' raw{i,4} ''', [''' raw{i,5} ''' ''' ' '' OPT.timezone' '], OPT.fillValues.' raw{i,6} '} ...']);
    else
        fprintf(fid,'%s\n',['                   {''' raw{i,3} ''', ''' raw{i,4} ''', ''' raw{i,5} ''', OPT.fillValues.' raw{i,6} '} ...']);
    end
    fprintf(fid,'%s\n',['                   ) ...']);
    fprintf(fid,'%s\n',['                );']);
    fprintf(fid,'%s\n',[' ']);
end
fclose(fid);

nc_cf_standard_names_create_footer(OPT.filename)

disp('New nc_cf_standard_names.m created automatically!')

function nc_cf_standard_names_create_header_1(filename)
% get template text
fid = fopen('nc_cf_standard_names_header_1.txt');
str = fread(fid, '*char')';
fclose(fid);

% write it to filename
fid = fopen(filename,'w');
fprintf(fid,'%s\n',str);
fclose(fid);

function nc_cf_standard_names_create_header_2(filename)
% get template text
fid = fopen('nc_cf_standard_names_header_2.txt');
str = fread(fid, '*char')';
fclose(fid);

% write it to filename
fid = fopen(filename,'a');
fprintf(fid,'%s\n',str);
fclose(fid);

function nc_cf_standard_names_create_footer(filename)
% get template text
fid = fopen('nc_cf_standard_names_footer.txt');
str = fread(fid, '*char')';
fclose(fid);

% write it to filename
fid = fopen(filename,'a');
fprintf(fid,'%s\n',str);
fclose(fid);