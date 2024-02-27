function xb = xb_read_ship(filename)
%XB_READ_SHIP  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_read_ship(varargin)
%
%   Input: For <keyword,value> pairs call xb_read_ship() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_read_ship
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
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
% Created: 18 Jan 2013
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: xb_read_ship.m 10444 2014-03-25 15:16:24Z rooijen $
% $Date: 2014-03-25 23:16:24 +0800 (Tue, 25 Mar 2014) $
% $Author: rooijen $
% $Revision: 10444 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_read_ship.m $
% $Keywords: $

%% read ship file structure
if ~exist(filename, 'file')
    error('File not found: %s', filename);
end

fdir = fileparts(filename);
xb   = xs_empty();
fid  = fopen(filename, 'r');
n    = 1;
while ~feof(fid)
    fullfile(fdir, fgetl(fid))
    n     = n + 1;
end

[names, values, filenames] = read_shipfile(filename);
for i = 1:length(names)
    if strcmp(names{i},'shipgeom')
        for j = 1:length(filenames)
            files(j,:) = char(values{i,j});
%             xb_sg = read_shipgeom(values{i,j});
            xb = xs_set(xb, names{i}, files);
        end
    elseif strcmp(names{i},'shiptrack')
        for j = 1:length(filenames)
            files(j,:) = char(values{i,j});
            xb_st = read_shiptrack(values{i,j});
            xb = xs_set(xb, names{i}, xb_st);
        end
    else
        for j = 1:length(filenames)
            val(j) = str2double(values{i,j});
        end
        xb = xs_set(xb, names{i}, val);
    end
    clearvars files 
end

% set meta data
xb = xs_meta(xb, mfilename, 'ship', filename);

function [names values filenames] = read_shipfile(filename) % read overall ship file
names      = {};
values    = {};
filenames = {};

fdir = fileparts(filename);

nship = 0;
fid = fopen(filename);
while ~feof(fid)
    fline = fgetl(fid);
    if isempty(fline); continue; end;
    nship = nship + 1;
    fname = fullfile(fdir, fline);
    filenames{nship} = fname;
    if exist(fname, 'file')
        
        [n,v] = read_shipfile2(fname);
        
        for i = 1:length(n)
            names = n;
            values{i,nship} = v{i};
        end
    end
end
fclose(fid);

function [names,values] = read_shipfile2(fname) % read ship settings file
fid = fopen(fname);
txt = fread(fid, '*char')';
fclose(fid);

[exprNames endIndex] = regexp([txt char(10)], ...
    '\s*(?<name>.*?)\s*=\s*(?<value>.*?)\s*\n', 'names', 'end', 'dotexceptnewline');

names  = {exprNames.name};
values = {exprNames.value};

function xb_st = read_shiptrack(filename) % read ship track file
try
    A = load(filename);
    
    xb_st = xs_empty;
    xb_st = xs_meta(xb_st, mfilename, 'ship', filename);
    
    % check if txy or txyz
    if size(A,2) == 3
        xb_st = xs_set(xb_st, 'time', [], 'x', [], 'y', []);
        xb_st = xs_set(xb_st, '-units', 'time', {A(:,1) 's'}, 'x', {A(:,2) 'm'}, 'y', {A(:,3) 'm'});
    elseif size(A,2) == 4
        xb_st = xs_set(xb_st, 'time', [], 'x', [], 'y', [], 'z', []);
        xb_st = xs_set(xb_st, '-units', 'time', {A(:,1) 's'}, 'x', {A(:,2) 'm'}, 'y', {A(:,3) 'm'}, 'z', {A(:,4) 'm'});
    else
        error(['Error Reading Ship Track File [' filename ']'])
    end
catch
   error(['Error Reading Ship Track File [' filename ']'])
end

% function xb_sg = read_shipgeom(filename)
% To do, read in depfile for ship geometry

