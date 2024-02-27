function fnames = xb_swan_write(fname, sp2, varargin)
%XB_SWAN_WRITE  Write SWAN file from struct
%
%   Write one or more SWAN files from struct. In case of multiple files,
%   the filename is extended with an indexing number.
%
%   Syntax:
%   fnames = xb_swan_write(fname, sp2, varargin)
%
%   Input:
%   fname     = Path to output file
%   sp2       = SWAN struct to write
%   varargin  = none
%
%   Output:
%   fnames    = Path(s) to output file(s)
%
%   Example
%   fnames = xb_swan_write('waves.sp2', sp2)
%
%   See also xb_swan_read, xb_swan_struct

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

% $Id: xb_swan_write.m 15437 2019-05-21 01:52:35Z cjoh296.x $
% $Date: 2019-05-21 09:52:35 +0800 (Tue, 21 May 2019) $
% $Author: cjoh296.x $
% $Revision: 15437 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_nesting/xb_swan/xb_swan_write.m $
% $Keywords: $

%% read options

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% write sp2 file

fnames = '';

for n = 1:length(sp2)
    
    % create spectrum file
    if length(sp2) > 1
        [fd fn fe] = fileparts(fname);
        fnames{n} = sprintf('%s%03d%s.sp2', fullfile(fd, fn), n, fe);
        fid = fopen(fnames{n}, 'wt');
    else
        fnames = fname;
        fid = fopen(fnames,'wt');
    end

    if ~isfield(sp2(n),'run'); sp2(n).run = 1; end;

    % write swan header
    fprintf(fid,'SWAN%4.0d\n',sp2(n).run);

    fprintf(fid,'$   Generated by matlab function WRITE_SP2\n');
    fprintf(fid,'$   Project:                 ;  run number:     \n');

    % write time header, if necessary
    if sp2(n).has_time
        fprintf(fid,'TIME\n');
        fprintf(fid,'%6.0d\n',1);
    end

    % write location header
    switch lower(sp2(n).location.type)
        case 'xy'
            fprintf(fid,'LOCATIONS\n');
        case 'lonlat'
            fprintf(fid,'LONLAT\n');
    end

    fprintf(fid,'%6.0d\n',sp2(n).location.nr);

    for i = 1:size(sp2(n).location.data,1)
        fprintf(fid,'%16.6f%16.6f\n',sp2(n).location.data(i,1),sp2(n).location.data(i,2));
    end

    % write frequency header
    switch lower(sp2(n).frequency.type)
        case 'absolute'
            fprintf(fid,'AFREQ\n');
        case 'relative'
            fprintf(fid,'RFREQ\n');
    end

    fprintf(fid,'%6.0d\n',sp2(n).frequency.nr);

    for i = 1:size(sp2(n).frequency.data,1)
        fprintf(fid,'%10.4f\n',sp2(n).frequency.data(i));
    end

    % write direction header
    switch lower(sp2(n).direction.type)
        case 'nautical'
            fprintf(fid,'NDIR\n');
        case 'cartesian'
            fprintf(fid,'CDIR\n');
    end

    fprintf(fid,'%6.0d\n',sp2(n).direction.nr);

    for i = 1:size(sp2(n).direction.data,1)
        fprintf(fid,'%10.4f\n',sp2(n).direction.data(i));
    end

    % write spectrum header
    fprintf(fid,'QUANT\n');
    fprintf(fid,'%6.0d\n',sp2(n).spectrum.nr);
    fprintf(fid,'%s\n',sp2(n).spectrum.type);
    fprintf(fid,'%s\n',sp2(n).spectrum.unit);
    fprintf(fid,'%14e\n',sp2(n).spectrum.exception);

    % write spectra for each timestep and point
    if ~isempty(sp2(n).spectrum.data)
        for i = 1:size(sp2(n).spectrum.data,1)

            % write timestep
            if sp2(n).has_time
                fprintf(fid,'%s\n',datestr(sp2(n).time.data(i),'yyyymmdd.HHMMSS'));
            end

            for j = 1:size(sp2(n).spectrum.data,2)
                % crop data to relevant part
                data = reshape(sp2(n).spectrum.data(i,j,:,:),size(sp2(n).spectrum.data,3),size(sp2(n).spectrum.data,4));

                % write NODATA, if no data is available
                if all(all(isnan(data))) || isempty(data)
                    fprintf(fid,'NODATA\n');
                    continue;
                end

                % determine multiplication factor
                if ~isfield(sp2(n).spectrum,'factor') || isempty(sp2(n).spectrum.factor) || ...
                        sp2(n).spectrum.factor(i,j) == 1 || sp2(n).spectrum.factor(i,j) == 0
                    factor = max(max(data))/990099;
                else
                    factor = sp2(n).spectrum.factor(i,j);
                end

                data = data./factor;

                % write multiplication factor
                fprintf(fid,'FACTOR\n');
                fprintf(fid,'%20.8e\n',factor);

				% format field width based on order of magnitude
				maximum_quantity = max(max(data));
				ord = floor( log10(maximum_quantity));
				field_fmt = ['%' num2str(ord+2) 'u'];
                
				% write data
                for k = 1:size(data,1)
                    fprintf(fid,[repmat(field_fmt, 1, size(data,2)) '\n'], round(data(k,:)));
                end
            end
        end
    else
        fprintf(fid,'NODATA\n');
    end

    fclose(fid);
end