function varargout = ShearStress(varargin)
%UNTITLED  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = Untitled(varargin)
%
%   Input: For <keyword,value> pairs call Untitled() without arguments.
%   varargin  = setOptions()
%
%   Output:
%   varargout =
%         raw_data = raw data from raw data file
%         xls_data = raw data from excel file
%
%   Example
%   [raw_data, xls_data] = ShearStress('fdir',rawfiledirs{i},'ffilter','raw')
%
%   dir(), get_fnames() 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 <COMPANY>
%       Kees Pruis
%
%       kees.pruis@boskalis.com	
%
%       +31 78 696 8470
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
% Created: 09 Sep 2014
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%

OPT = setOptions();

% return defaults (aka introspection)
if ~isempty(double(cellfun('isempty',varargin)))
    if strcmp(varargin{1},'show');
       varargout = {OPT};
       return
    end
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code
%% get raw data file
raw_data = [];
if OPT.usef
    fdir = strcat(OPT.fdir,filesep,'*.',OPT.fext);
    fnames = get_fnames('fdir',fdir,'filter',OPT.ffilter);
    
    for i = 1:length(fnames)
        %create a varname for every file
        v = genvarname(strcat('read_',fnames{i}(1:end-(length(OPT.fext)+1))));
        raw_data.(v) = load(strcat(OPT.fdir,filesep,fnames{i}));
        %eval([raw_data.v '= num;']);
    end
end
xls_data = [];
if OPT.usexls
    xlsdir = strcat(OPT.xlsdir,filesep,'*.',OPT.xlsext);
    xlsnames = get_fnames('fdir',xlsdir,'filter',OPT.xlsfilter);
    for i = 1:length(xlsnames)
        %create a varname for every xls file
        v = genvarname(strcat('read_',xlsnames{i}(1:end-(length(OPT.xlsext)+1))));
        xls_data.(v) = xlsread(strcat(OPT.xlsdir,filesep,xlsnames{i}), OPT.xlssheet, OPT.xlsrange);
    %     eval([xls_data.v '= num;']);
    end
end
varargout = {raw_data, xls_data};
end

