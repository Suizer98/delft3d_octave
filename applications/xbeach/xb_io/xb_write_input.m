function xb_write_input(filename, xb, varargin)
%XB_WRITE_INPUT  Write XBeach params.txt file and all files referred in it
%
%   Writes the XBeach settings from a XBeach structure in a parameter file.
%   Also the files that are referred to in the parameter file are written,
%   like grid and wave definition files.
%
%   Syntax:
%   xb_write_input(filename, xb, varargin)
%
%   Input:
%   filename  = filename of parameter file
%   xb        = XBeach structure array
%   varargin  = write_paths:  flag to determine whether definition files
%                             should be written or just referred
%               xbdir:  option to parse xbeach code directory (to read
%                       parameter info)
%
%   Output:
%   none
%
%   Example
%   xb_write_input(filename, xb)
%
%   See also xb_read_input, xb_write_params

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

% $Id: xb_write_input.m 13437 2017-07-03 11:34:21Z nederhof $
% $Date: 2017-07-03 19:34:21 +0800 (Mon, 03 Jul 2017) $
% $Author: nederhof $
% $Revision: 13437 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_write_input.m $
% $Keywords: $

%% read options

if ~xs_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'write_files', true, ...
    'xbdir','', ...
    'maxduration_waves',3600 ...
);

OPT = setproperty(OPT, varargin{:});

%% write referred files

if isdir(filename)
    fdir = filename;
else
    fdir = fileparts(filename);
end

if OPT.write_files
    
    for i = 1:length(xb.data)
        xb.data(i);
        if isstruct(xb.data(i).value)
            sub = xb.data(i).value;
            
            switch xb.data(i).name
                case {'bcfile' 'ezsfile'}
                    % write waves
                    xb.data(i).value = xb_write_waves(sub, 'path', fdir,'maxduration',OPT.maxduration_waves);
                case {'zs0file'}
                    % write tide
                    xb.data(i).value = xb_write_tide(sub, 'path', fdir);
                case {'xfile' 'yfile' 'depfile' 'ne_layer'}
                    % write bathymetry file by file
                    xb.data(i).value = xb_write_bathy(sub, 'path', fdir);
                case {'shipfile'}
                    % read shipfile
                    xb.data(i).value = xb_write_ship(sub, 'path', fdir);
                otherwise
                    % assume file to be a grid and try writing it
                    try
                        xb.data(i).value = unknown_filename(xb, i);
                        fname = fullfile(fdir, xb.data(i).value);
                        data = xs_get(sub, 'data');
                        if isnumeric(data)
                            save(fname, '-ascii', 'data');
                        elseif iscell(data)
                            fid = fopen(fname, 'w');
                            for j = 1:length(data)
                                if isnumeric(data{j})
                                    fprintf(fid, '%f\n', data{j});
                                else
                                    fprintf(fid, '%s\n', data{j});
                                end
                            end
                            fclose(fid);
                        elseif ischar(data)
                            fid = fopen(fname, 'w');
                            fprintf(fid, '%s', data);
                            fclose(fid);
                        end
                    catch
                        % cannot write file, ignore
                    end
            end
        end
    end
end

%% write params.txt file

xb_write_params(filename, xb, 'xbdir',OPT.xbdir);

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fname = unknown_filename(xb, i)

    prefix = '';
    
    if isfield(xb, 'file') && ~isempty(xb.file)
        [fdir, fname, fext] = fileparts(xb.file);
        
        if ~strcmpi([fname fext], 'params.txt')
            prefix = [fname '_'];
        end
    end
    
    fname = [prefix xb.data(i).name '.txt'];

end