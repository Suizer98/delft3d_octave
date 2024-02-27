function sp2 = xb_swan_read(fname, varargin)
%XB_SWAN_READ  Read a SWAN file into a struct
%
%   Read one or more SWAN files into a struct
%
%   Syntax:
%   sp2 = xb_swan_read(fname, varargin)
%
%   Input:
%   fname     = Path to SWAN file
%   varargin  = none
%
%   Output:
%   sp2       = SWAN struct
%
%   Example
%   sp2 = xb_swan_read('waves.sp2')
%   sp2 = xb_swan_read('*.sp2')
%
%   See also xb_swan_write, xb_swan_struct

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

% $Id: xb_swan_read.m 10134 2014-02-05 02:25:47Z omouraenko.x $
% $Date: 2014-02-05 10:25:47 +0800 (Wed, 05 Feb 2014) $
% $Author: omouraenko.x $
% $Revision: 10134 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_nesting/xb_swan/xb_swan_read.m $
% $Keywords: $

%% read options

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% read sp2 file

fdir = fileparts(fname);
files = dir(fname);
for n = 1:length(files)
    fname = fullfile(fdir, files(n).name);
    
    % create empty sp2 spectrum struct
    sp2(n) = xb_swan_struct();
    
    c = 1; l = 0;

    if exist(fname, 'file')

        % open spectrum file
        fid = fopen(fname);

        % loop throught spectrum file
        while ~feof(fid)
            fline = fgetl(fid); l = l + 1;

            % skip comments
            if strcmp(strtok(fline),'$') || ~isempty(regexp(fline,'^\s*$')) || isempty(fline); continue; end;

            % determine current part
            key = upper(strtok(fline));
            switch key
                case 'SWAN'
                    % read swan header
                    tok = regexp(fline,'^\s*SWAN\s+(?<version>\d)\s*.*?\s*$','names');

                    sp2(n).run = str2double(tok.version);
                case 'TIME'
                    % read time header
                    d = read_double(fid);

                    sp2(n).has_time = logical(d);

                    if sp2(n).has_time % stationary (0) or non-stationary (1)
                        t = 0;
                    else
                        t = 1;
                    end
                    sp2(n).time.nr = 0;
                    sp2(n).time.data = [];
                case {'LOCATIONS','LOCATION','LONLAT'}
                    % read location header
                    sp2(n).location = read_block(fid,2);

                    switch key
                        case {'LOCATIONS','LOCATION'}
                            sp2(n).location.type = 'xy';
                        case 'LONLAT'
                            sp2(n).location.type = 'lonlat';
                    end
                case {'AFREQ','RFREQ'}
                    % read frequency header
                    sp2(n).frequency = read_block(fid,1);

                    switch key
                        case 'AFREQ'
                            sp2(n).frequency.type = 'absolute';
                        case 'RFREQ'
                            sp2(n).frequency.type = 'relative';
                    end
                case {'NDIR','CDIR'}
                    % read direction header
                    sp2(n).direction = read_block(fid,1);

                    switch key
                        case 'NDIR'
                            sp2(n).direction.type = 'nautical';
                        case 'CDIR'
                            sp2(n).direction.type = 'cartesian';
                    end
                case 'QUANT'
                    % read spectrum header
                    sp2(n).spectrum.nr = read_double(fid); % always 1 in sp2
                    sp2(n).spectrum.type = read_char(fid);
                    sp2(n).spectrum.unit = read_char(fid);
                    sp2(n).spectrum.exception = read_double(fid);
                case 'FACTOR'
                    % read spectrum definition for current time and point
                    factor = read_double(fid);
                    data = read_matrix(fid,sp2(n).frequency.nr,sp2(n).direction.nr);
                    
                    sp2(n).spectrum.factor(t,c) = factor;
                    sp2(n).spectrum.data(t,c,:,:) = factor.*data;

                    c = c + 1;
                case 'NODATA'
                    % skip line, since no data
                    sp2(n).spectrum.factor(t,c) = nan;
                    sp2(n).spectrum.data(t,c,:,:) = nan(sp2(n).frequency.nr,sp2(n).direction.nr);
                    
                    c = c + 1;
                case 'ZERO'
                    % skip line, spectrum is zero
                    sp2(n).spectrum.factor(t,c) = 0;
                    sp2(n).spectrum.data(t,c,:,:) = zeros(sp2(n).frequency.nr,sp2(n).direction.nr);
                    
                    c = c + 1;
                otherwise
                    % check whether current unknown line is start of new
                    % timestep
                    if sp2(n).has_time && regexp(key,'^\d+.\d+$')
                        % update time step
                        t = t+1;
                        sp2(n).time.data(t) = datenum(key,'yyyymmdd.HHMMSS');
                        sp2(n).time.nr = t;

                        % restart data index
                        c = 1;
                    else
                        error(['Invalid SP2 spectrum file [line ' num2str(l) ']']);
                    end
            end
        end

        fclose(fid);
    end
end

% FUNCTION: read next line as matrix, starting with matrix size definition
function block = read_block(fid, cols)
    nline = read_double(fid);
    
    block = struct( ...
        'nr',nline, ...
        'data',read_matrix(fid,nline,cols) ...
    );

% FUNCTION: read next lines as matrix
function matrix = read_matrix(fid,rows,cols)

    matrix = nan(rows,cols);
    
    for i = 1:rows
        fline = fgetl(fid);
        mline = strread(fline);
        
        matrix(i,1:length(mline)) = mline;
    end
    
% FUNCTION: read next line as double
function d = read_double(fid)

    fline = fgetl(fid);
    d = str2double(strtok(fline));

% FUNCTION: read next line as char
function c = read_char(fid)

    fline = fgetl(fid);
    c = strtok(fline);