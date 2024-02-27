function wavefile = xb_sp22xb_loc(files, varargin)
%XB_SP22XB_LOC Converts a set of Delft3D-WAVE SP2 files into XBeach wave boundary conditions
%
%   Converts a set of Delft3D-WAVE SP2 files into XBeach wave boundary
%   conditions by cropping the timeseries, writing the corresponding SP2
%   files, and filelist and loclist files. 
%
%   Syntax:
%   wavefile = xb_sp22xb_loc(fnames, varargin)
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
%   wavefile = xb_sp22xb_loc('*.sp2')
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

% $Id: xb_sp22xb_loc.m 10134 2014-02-05 02:25:47Z omouraenko.x $
% $Date: 2014-02-05 10:25:47 +0800 (Wed, 05 Feb 2014) $
% $Author: omouraenko.x $
% $Revision: 10134 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_nesting/xb_delft3d/xb_sp22xb_loc.m $
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

% write sp2 files
files = {};
for n = 1:length(sp2_t)
    sp2_t_p = xb_swan_split(sp2_t(n),'location');
    for l = 1:length(sp2_t_p)
        % create file name
        if sp2_t(n).location.nr > 1 % multiple locations
            if length(sp2_t) > 1
                files{n,l} = sprintf('%s_p%03d_t%03d.sp2',fullfile(fd,fn),l,n);
            else
                files{n,l} = sprintf('%s_p%03d.sp2',fullfile(fd,fn),l);
            end
        else % single location
            if length(sp2) > 1
                files{n,l} = sprintf('%s_t%03d.sp2',fullfile(fd,fn),n);
            else
                files{n,l} = sprintf('%s.sp2',fullfile(fd,fn));
            end
        end
        xb_swan_write(files{n,l},sp2_t_p(l));
    end
end

% make relative time axis
t = diff(t);
t(end+1) = t(end);

% write LOCLIST and FILELIST
[nt np] = size(files); % n - number of time steps, l - number of locations

if np==1
    % FILELIST
    fid = fopen(wavefile, 'wt');
    fprintf(fid, '%s\n', 'FILELIST');
    for n = 1:nt
        fprintf(fid, '%8.1f %8.1f %s\n', t(n)*24*60*60, 1.0, files{n,np});
    end
    fclose(fid);
else
    % LOCLIST
    fid = fopen(wavefile, 'wt');
    fprintf(fid, '%s\n', 'LOCLIST');
    for l = 1:np
        fname = sprintf('%s_p%03d%s', fullfile(fd, fn), l, fe);
        fprintf(fid, '%16.6f %16.6f %s\n', sp2(1).location.data(l,:), fname);
        
        fid2 = fopen(fname,'wt');
        fprintf(fid2, '%s\n', 'FILELIST');
        for n = 1:nt
            fprintf(fid2, '%8.1f %8.1f %s\n', t(n)*24*60*60, 1.0, files{n,l});
        end
        fclose(fid2);
    end
    fclose(fid);
end
