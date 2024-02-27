function filename = xb_write_waves(xb, varargin)
%XB_WRITE_WAVES  Writes wave definition files for XBeach input
%
%   Writes JONSWAP or variance density spectrum files for XBeach input. In
%   case of conditions changing in time, a file list file is created
%   refering to multiple wave definition files. In case of a JONSWAP
%   spectrum, the file list file can be omitted and a single matrix
%   formatted file is created. Returns the filename of the file to be
%   referred in the params.txt file.
%
%   In order to generate time varying wave conditions, simply add an extra
%   dimension to the input arguments specifying the spectrum. The
%   single-valued parameters Hm0, Tp, dir, gammajsp, s fnyq, duration and
%   timestep then become one-dimensional. The one- and two-dimensional
%   parameters freqs, dirs and vardens then become two- and
%   three-dimensional respectively. It is not necessary to provide
%   time-varying values for all parameters. In case a specific parameter is
%   constant, simply provide the constant value. The value is reused in
%   each period of time. However, it is not possible to provide for one
%   parameter more than one value and for another too, while the number of
%   values is not the same. Thus for each parameter the number of values
%   must equal eiter 1 or n.
%
%   Syntax:
%   filename = xb_write_waves(xb, varargin)
%
%   Input:
%   xb          = XBeach structure array that overwrites the
%                 default varargin options (optional)
%   varargin    = path:             path to output directory
%                 filelist_file:    name of filelist file without extension
%                 jonswap_file:     name of jonswap file without extension
%                 vardens_file:     name of vardens file without extension
%                 unknown_file:     name of unknown wave file without
%                                   extension
%                 omit_filelist:    flag to omit filelist generation in
%                                   case of jonswap spectrum
%
%   Output:
%   filename = filename to be referred in parameter file
%
%   Example
%   filename = xb_write_waves(xb)
%
%   See also xb_write_input, xb_read_waves

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: xb_write_waves.m 16128 2019-12-13 22:08:50Z l.w.m.roest.x $
% $Date: 2019-12-14 06:08:50 +0800 (Sat, 14 Dec 2019) $
% $Author: l.w.m.roest.x $
% $Revision: 16128 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_write_waves.m $
% $Keywords: $

%% read options

% if ~xs_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'path', pwd, ...
    'filelist_file', 'filelist', ...
    'jonswap_file', 'jonswap', ...
    'vardens_file', 'vardens', ...
    'unknown_file', 'wave', ...
    'omit_filelist', false, ...
    'maxduration', 3600 ...
);

OPT = setproperty(OPT, varargin{:});

%% check input

type = xs_get(xb, 'type');

% check parameter dimensions
switch type
    case {'jonswap', 'jonswap_mtx', 'jons_table'}
        vars = {'Hm0' 'Tp' 'fp' 'mainang' 'gammajsp' 's' 'fnyq' 'duration' 'timestep'};

        fname = OPT.jonswap_file;

        % determine length of time series
        tlength = get_time_length(xb, vars);
    case 'vardens'
        vars = {'duration' 'timestep'};

        fname = OPT.vardens_file;

        % determine length of time series
        tlength = get_time_length(xb, vars);

        [freqs, dirs, vardens] = xs_get(xb, 'freqs', 'dirs', 'vardens');
        if length(freqs) ~= size(vardens, 2) || ...
                length(dirs) ~= size(vardens, 1)
            error('Dimensions of variance density matrix do not match');
        end

        if tlength ~= size(vardens, 3)
            if tlength == 1
                tlength = size(vardens, 3);
            else
                error('Time dimension of variance density matrix does not match');
            end
        end
    case {'ezs'}
        vars = {'contents' 'duration' 'timestep'};

        fname = 'bc/gen.ezs';

        bcpath = abspath(fullfile(OPT.path, 'bc'));
        if ~exist(bcpath, 'dir')
            mkdir(bcpath);
        end

        tlength = 1;
        xb = xs_set(xb, 'duration', 0, 'timestep', 0);
    case {'unknown'}
        vars = {'contents' 'duration' 'timestep'};

        fname = OPT.unknown_file;

        % determine length of time series
        tlength = get_time_length(xb, vars);
% This implementation does not work when one or more variables are scalar.
% In fact jons_table was already implemented via keyword jonswap_mtx.
%     case{'jons_table'}
% 
%         fid = fopen(fullfile(OPT.path, 'jonswap.txt'),'wt');
%         nconditions = length(xb.data(2).value);
%         for ii = 1:nconditions
%         fprintf(fid, '%.4f ',   [xb.data(2).value(ii)]); % Hm0
%         fprintf(fid, '%.4f ',   [xb.data(3).value(ii)]); % Tp
%         fprintf(fid, '%.4f ',   [xb.data(4).value(ii)]); % main angle
%         fprintf(fid, '%.4f ',   [xb.data(5).value]);     % gamma
%         fprintf(fid, '%.4f ',   [xb.data(6).value(ii)]); % s
%         fprintf(fid, '%.4f ',   [xb.data(8).value(ii)]); % duration
%         fprintf(fid, '%.4f\n',  [xb.data(9).value(ii)]); % dtbc
%         end
%         fclose('all');
        
    otherwise
        error(['Unknown wave definition type [' type ']']);
end

% set variable alternatives
% switch type
%     case{'jons_table'}
%         filename = 'jonswap.txt';
%     otherwise
    if xs_exist(xb, 'Tp') && ~xs_exist(xb, 'fp')
        xb = xs_set(xb, 'fp', 1./xs_get(xb, 'Tp'));
    end

    if xs_exist(xb, 'fp') && ~xs_exist(xb, 'Tp')
        xb = xs_set(xb, 'Tp', 1./xs_get(xb, 'fp'));
    end

    if xs_exist(xb, 'mainang') && ~xs_exist(xb, 'dir')
        xb = xs_set(xb, 'dir', xs_get(xb, 'mainang'));
    end

    if xs_exist(xb, 'dir') && ~xs_exist(xb, 'mainang')
        xb = xs_set(xb, 'mainang', xs_get(xb, 'dir'));
    end

    % extend constant parameters to length of time series
    for i = 1:length(vars)
        if strcmpi(vars{i}, 'contents'); continue; end;

        var = xs_get(xb, vars{i});
        switch length(var)
            case 0
                xb = xs_set(xb, vars{i}, nan*ones(1,tlength));
            case 1
                xb = xs_set(xb, vars{i}, var*ones(1,tlength));
        end
    end

    %% set maximum duration

    [duration, timestep] = xs_get(xb, 'duration', 'timestep');

    if isnan(duration); duration = OPT.maxduration; end;
    if size(duration,1) == max(size(duration)); duration = duration'; end;

    duration = roundoff(duration, 4);

    while any(duration>OPT.maxduration)
        i           = find(duration>OPT.maxduration,1,'first');
        n           = floor(duration(i)/OPT.maxduration);
        d           = [repmat(OPT.maxduration,1,n) mod(duration(i), OPT.maxduration)];
        n           = n-sum(d==0);
        d(d==0)     = [];
        idx         = [1:i-1 repmat(i,1,length(d)) i+1:length(duration)];
        duration    = [duration(1:i-1) d duration(i+1:end)];
        for j = 1:length(vars)
            if strcmpi(vars{j}, 'duration'); continue; end;

            data    = xs_get(xb, vars{j});
            xb      = xs_set(xb, vars{j}, data(idx));
        end
        tlength     = tlength+n;
    end

    xb = xs_set(xb, 'duration', ceil(duration));

    %% create file list

    % create file list file, if necessary
    [duration, timestep] = xs_get(xb, 'duration', 'timestep');
    if length(duration) > 1 && ~(strcmpi(type, 'jonswap') && OPT.omit_filelist) && ~any(strcmpi(type, {'jonswap_mtx','jons_table'}));
        filename = [OPT.filelist_file '.txt'];
        fid = fopen(fullfile(OPT.path, filename), 'w');
        fprintf(fid, 'FILELIST\n');
        for i = 1:length(duration)
            fprintf(fid, '%10i%10.4f%50s\n', duration(i), timestep(i), [fname '_' num2str(i) '.txt']);
        end
        fclose(fid);
    end

    %% create wave files

    % determine whether single matrix formatted jonswap file should be
    % created, otherwise write single or multiple wave files
    if any(strcmpi(type, {'jonswap_mtx','jons_table'})) || (length(duration) > 1 && strcmpi(type, 'jonswap') && OPT.omit_filelist)
        filename = [fname '.txt'];
        write_jonswap_mtx_file(fullfile(OPT.path, filename), tlength, xb)
    else
        % loop through time series and write wave files
        for i = 1:length(duration)
            if length(duration) == 1
                if isempty(regexp(fname, '\.\w+$', 'once'))
                    filename = [fname '.txt'];
                else
                    filename = fname;
                end

                fname_i = filename;
            else
                fname_i = [fname '_' num2str(i) '.txt'];
            end

            fname_i = fullfile(OPT.path, fname_i);

            switch type
                case 'jonswap'
                    write_jonswap_file(fname_i, i, xb)
                case 'vardens'
                    write_vardens_file(fname_i, i, xb)
                case 'ezs'
                    write_unknown_file(fname_i, i, xb)
                case 'unknown'
                    write_unknown_file(fname_i, i, xb)
            end
        end
    end
% end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% determine length of time series
function t = get_time_length(xb, vars)
t = 1;
for i = 1:length(vars)
    var = xs_get(xb, vars{i});
    if t > 1 && length(var) > 1 && t ~= length(var)
        error('Time dimensions do not match');
    end

    t = max(t, length(var));
end

% write single jonswap wave file
function write_jonswap_file(fname, idx, xb)
vars = {'Hm0' 'fp' 'mainang' 'gammajsp' 's' 'fnyq'};

fid = fopen(fname, 'w');
for i = 1:length(vars)
    var = xs_get(xb, vars{i});
    if ~isnan(var(idx))
        fprintf(fid, '%-10s = %10.4f\n', vars{i}, var(idx));
    end
end
fclose(fid);

% write matrix formatted jonswap wave file
function write_jonswap_mtx_file(fname, tlength, xb)
vars = {'Hm0' 'Tp' 'mainang' 'gammajsp' 's' 'duration' 'timestep'};

fid = fopen(fname, 'w');
for i = 1:tlength
    for j = 1:length(vars)
        var = xs_get(xb, vars{j});
        fprintf(fid, '%10.4f', var(i));
    end
    fprintf(fid, '\n');
end
fclose(fid);

% write single variance density spectrum file
function write_vardens_file(fname, idx, xb)
[freqs, dirs, vardens] = xs_get(xb, 'freqs', 'dirs', 'vardens');

fid = fopen(fname, 'w');
fprintf(fid, '%10.4f\n', length(freqs));
for i = 1:length(freqs)
    fprintf(fid, '%10.4f\n', freqs(i));
end
fprintf(fid, '%10.4f\n', length(dirs));
for i = 1:length(dirs)
    fprintf(fid, '%10.4f\n', dirs(i));
end
for i = 1:length(dirs)
    for j = 1:length(freqs)
        fprintf(fid, '%10.4f', vardens(i,j,idx));
    end
    fprintf(fid, '\n');
end
fclose(fid);

% write unknown formatted wave file
function write_unknown_file(fname, tlength, xb)
contents = xs_get(xb, 'contents');

fid = fopen(fname, 'w');
if iscell(contents)
    fprintf(fid, '%s', contents{tlength});
else
    fprintf(fid, '%s', contents);
end
fclose(fid);