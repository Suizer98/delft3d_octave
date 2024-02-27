function wavefile = xb_sp22xb(files, varargin)
%XB_SP22XB  Converts a set of Delft3D-WAVE SP2 files into XBeach wave boundary conditions
%
%   Converts a set of Delft3D-WAVE SP2 files into XBeach wave boundary
%   conditions by cropping the timeseries, writing the corresponding SP2
%   files and a filelist file.
%
%   Syntax:
%   wavefile = xb_sp22xb(fnames, varargin)
%
%   Input:
%   fnames    = Path to Delft3D-WAVE SP2 files
%   varargin  = wavefile:       Path to output file
%               tstart:         Datenum indicating simulation start time
%               tlength:        Datenum indicating simulation length
%               location:       Indeces of locations to include as numeric
%                               array or 'all'
%
%   Output:
%   wavefile  = Path to output file
%
%   Example
%   wavefile = xb_sp22xb('*.sp2')
%
%   See also xb_delft3d_wave, xb_bct2xb

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 14 Feb 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_sp22xb.m 10135 2014-02-05 02:43:30Z omouraenko.x $
% $Date: 2014-02-05 10:43:30 +0800 (Wed, 05 Feb 2014) $
% $Author: omouraenko.x $
% $Revision: 10135 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_nesting/xb_delft3d/xb_sp22xb.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'wavefile', 'waves.txt', ...
    'tstart', 0, ...
    'tlength', Inf, ...
    'location','all' ...
);

OPT = setproperty(OPT, varargin{:});

wavefile = OPT.wavefile;
[fd fn fe] = fileparts(wavefile);

%% convert sp2 files

% read sp2 files
sp2 = xb_swan_read(files);

if isnumeric(OPT.location)
    ip = true(sp2(1).location.nr,1);
    ip(OPT.location) = false;
else
    ip = false(sp2(1).location.nr,1);
end

t = [];
sp2_t = xb_swan_struct(); % one time step per file

% select sp2 files in time window
n = 1;
for i = 1:length(sp2)
    for j = 1:sp2(i).time.nr
        ti = sp2(i).time.data(j);
        if  ti >= OPT.tstart && ti < OPT.tstart+OPT.tlength
            sp2_t(n) = sp2(i);
            t(n) = ti;
            % reduce fields
            it = true(sp2(i).time.nr,1); it(j) = false;
            sp2_t(n).time.nr = 1;
            sp2_t(n).time.data(it) = [];
            sp2_t(n).location.nr = sum(~ip);
            sp2_t(n).location.data(ip,:) = [];
            sp2_t(n).spectrum.data(:,ip,:,:) = [];
            sp2_t(n).spectrum.data(it,:,:,:) = [];
            sp2_t(n).spectrum.factor(:,ip) = [];
            sp2_t(n).spectrum.factor(it,:) = [];

            n = n + 1;
        end
    end
end

% write selected spectrum files
files = xb_swan_write(fullfile(fd, [fn '.sp2']), sp2_t);
files = cellstr(files);

% make relative time axis
t = diff(t);
t(end+1) = t(end);

% write FILELIST
nt = numel(files);

fid = fopen(wavefile, 'wt');
fprintf(fid, '%s\n', 'FILELIST');
for n = 1:nt
    fprintf(fid, '%8.1f %8.1f %s\n', t(n)*24*60*60, 1.0, files{n});
end
fclose(fid);