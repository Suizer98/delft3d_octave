function varargout = nccreateVarstruct_standardnames_cf_generate(varargin)
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

% $Id: nccreateVarstruct_standardnames_cf_generate.m 8086 2013-02-15 15:20:35Z tda.x $
% $Date: 2013-02-15 23:20:35 +0800 (Fri, 15 Feb 2013) $
% $Author: tda.x $
% $Revision: 8086 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nccreate/nccreateVarstruct_standardnames_cf_generate.m $
% $Keywords: $

%% settings
% defaults
OPT = struct(...
    'filename', [fileparts(mfilename('fullpath')) filesep 'nccreateVarstruct_standardnames_cf.m'], ...       % description of input argument 1
    'varname', {'time'} ...        % description of input argument 2
    );

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

%% get standard names info from xls file
[num, txt, raw] = xlsread('nc_cf_standard_names_catalogue.xls','Sheet1');

ids = cellfun(@isnan, raw(6:end,1), 'UniformOutput', false);ids = ~vertcat(ids{:});
txt = txt([false; false; false; false; false; ids],:);

% replace all white space characters as tabs and linebreaks etc by spaces
txt = regexprep(txt,'\s',' ');

% replace all qutes by double qoutes
txt = regexprep(txt,'''','''''');

%%
fid = fopen('nccreateVarstruct_standardnames_cf_generate_template.m');
template = fread(fid,'*char')';
fclose(fid);

template = strrep(template,'''$standard_names''',[char(10) sprintf('    ''%s''\n',txt{:,3})]);
template = strrep(template,'''$long_names'''    ,[char(10) sprintf('    ''%s''\n',txt{:,4})]);
template = strrep(template,'''$units'''         ,[char(10) sprintf('    ''%s''\n',txt{:,5})]);
template = strrep(template,'''$definitions'''   ,[char(10) sprintf('    ''%s''\n',txt{:,7})]);

fid = fopen(OPT.filename,'w');
fwrite(fid,template);
fclose(fid);

disp(['New ' OPT.filename ' created automatically!'])
