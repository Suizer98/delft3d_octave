function CLRdata = ITHK_io_readCLR(filename)
%UNTITLED  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = Untitled(varargin)
%
%   Input: For <keyword,value> pairs call Untitled() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   Untitled
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 <COMPANY>
%       boer_we
%
%       <EMAIL>
%
%       <ADDRESS>
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
% Created: 23 May 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: ITHK_io_readCLR.m 11589 2014-12-18 16:27:34Z boer_we $
% $Date: 2014-12-19 00:27:34 +0800 (Fri, 19 Dec 2014) $
% $Author: boer_we $
% $Revision: 11589 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/ITHK_io_readCLR.m $
% $Keywords: $

%%
if ~exist(filename,'file')
    fprintf('Error : Filename for CLR not found!\n');
    return
end
    
CLRdata=struct;
fid = fopen(filename,'rt');
fgetl(fid);
CLRdata.phase_unit = str2double(fgetl(fid));
fgetl(fid);
CLRdata.dt = str2double(fgetl(fid));
fgetl(fid);
CLRdata.n_phases = str2double(fgetl(fid));
fgetl(fid);
CLRdata.n_cycli = str2double(fgetl(fid));
fgetl(fid);
CLRdata.t0 = str2double(fgetl(fid));
str = strsplit(fgetl(fid),' ');
% Check for apostrophe in name
if strcmp(str{1}(1),'''')
    CLRdata.mdaname = str{1}(2:end-1);
else
    CLRdata.mdaname = str{1};
end
str = strsplit(fgetl(fid),' ');
% Check for LAT-file
if sum(strcmpi(str,'(LAT-file)'))>0
    % Check for apostrophe in name
    if strcmp(str{1}(1),'''')
        CLRdata.latname = str{1}(2:end-1);
    else
        CLRdata.latname = str{1};
    end
    fgetl(fid);
end
for ii=1:CLRdata.n_phases
    str = strsplit(fgetl(fid),' ');
    if isempty(str{1})
        CLRdata.fase(ii)=str2double(str{2});
        CLRdata.from(ii)=str2double(str{3});
        CLRdata.to(ii)=str2double(str{4});
        CLRdata.GKL{ii}=str{5}(2:end-1);
        CLRdata.BCO{ii}=str{6}(2:end-1);
        CLRdata.GRO{ii}=str{7}(2:end-1);
        CLRdata.SOS{ii}=str{8}(2:end-1);
        CLRdata.REV{ii}=str{9}(2:end-1);
        CLRdata.OBW{ii}=str{10}(2:end-1);
        CLRdata.BCI{ii}=str{11}(2:end-1);
    else
        CLRdata.fase(ii)=str2double(str{1});
        CLRdata.from(ii)=str2double(str{2});
        CLRdata.to(ii)=str2double(str{3});
        CLRdata.GKL{ii}=str{4}(2:end-1);
        CLRdata.BCO{ii}=str{5}(2:end-1);
        CLRdata.GRO{ii}=str{6}(2:end-1);
        CLRdata.SOS{ii}=str{7}(2:end-1);
        CLRdata.REV{ii}=str{8}(2:end-1);
        CLRdata.OBW{ii}=str{9}(2:end-1);
        CLRdata.BCI{ii}=str{10}(2:end-1);
    end
end
fgetl(fid);
str=strsplit(fgetl(fid),' ');
CLRdata.iaant =str2double(str{1});
CLRdata.ifirst =str2double(str{2});
CLRdata.ival =str2double(str{3});
fclose(fid);
