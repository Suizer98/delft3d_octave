function filename = xb_write_ship(xb, varargin)
%XB_WRITE_SHIP  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_write_ship(varargin)
%
%   Input: For <keyword,value> pairs call xb_write_ship() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_write_ship
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

% $Id: xb_write_ship.m 10445 2014-03-25 15:22:38Z rooijen $
% $Date: 2014-03-25 23:22:38 +0800 (Tue, 25 Mar 2014) $
% $Author: rooijen $
% $Revision: 10445 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_write_ship.m $
% $Keywords: $

%% read options
if ~xs_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'path', pwd, ...
    'filename', 'ships.txt' ...
);

OPT = setproperty(OPT, varargin{:});

%% Write ship main file file
filename = OPT.filename;
try
    fid = fopen(fullfile(OPT.path, filename), 'w');
    for j = 1:length(xb)
        fname = sprintf('ship%03d.txt', j);
        fprintf(fid, '%s\n', fname);
    end
    fclose(fid);
catch
    error(['Could not create ship definition file [' filename ']']);
end

% Create individual files per ship
fly = [];
for i = 1:length(xb.data(1).value)
    fid = fopen(fullfile(OPT.path, sprintf('ship%03d.txt', i)), 'w');
    for j = 1:length(xb.data)
        xb.data(j).name
        if strcmp(xb.data(j).name,{'shiptrack'});
            if length(xb.data(j).value.data) == 4
                t = xs_get(xb.data(j).value,'time');
                x = xs_get(xb.data(j).value,'x');
                y = xs_get(xb.data(j).value,'y');
                z = xs_get(xb.data(j).value,'z');
                A = [t,x,y,z];
            elseif length(xb.data(j).value.data) == 3
                t = xs_get(xb.data(j).value,'time');
                x = xs_get(xb.data(j).value,'x');
                y = xs_get(xb.data(j).value,'y');
                A = [t,x,y];
            else 
                error('something wrong with ship track data...')
            end
            save(fullfile(OPT.path, sprintf('track%03d.txt', i)),'A','-ascii');
            fprintf(fid, '%s\n', [xb.data(j).name ' = ' sprintf('track%03d.txt', i)]);
        elseif strcmp(xb.data(j).name,{'shipgeom'});
            fprintf(fid, '%s\n', [xb.data(j).name ' = ' xb.data(j).value(i,:)]);
        else
            fprintf(fid, '%s\n', [xb.data(j).name ' = ' num2str(xb.data(j).value(i))]);
        end
    end
end
% function write_shiptrack(fname, tlength, xb)


