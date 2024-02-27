function xb = xb_read_bathy(varargin)
%XB_READ_BATHY  Read xbeach bathymetry files
%
%   Routine to read xbeach bathymetry files.
%
%   Syntax:
%   xb = xb_read_bathy('xfile', <filename>, yfile, <filename>, depfile, <filename>, nefile, <filename>)
%
%   Input:
%   varargin    = xfile:    file name of x-coordinates file (cross-shore)
%                 yfile:    file name of y-coordinates file (alongshore)
%                 depfile:  file name of bathymetry file
%                 ne_layer: file name of non erodible layer file
%
%   Output:
%   xb          = XBeach structure array
%
%   Example
%   xb = xb_read_bathy('xfile', xfile, 'yfile', yfile)
%
%   See also xb_write_bathy, xb_read_input

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

% $Id: xb_read_bathy.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_read_bathy.m $
% $Keywords: $

%% create xbeach struct

xb = xs_empty();

% odd elements should be variable names
vars = varargin(1:2:end);
% even elements should be filenames
files = varargin(2:2:end);

for ivar = 1:length(vars)
    if exist(files{ivar}, 'file')
        xb = xs_set(xb, vars{ivar}, []);
        try
            A = load(files{ivar});
        catch
            try
                fid = fopen(files{ivar}, 'r');
                A = fread(fid, '*char')';
                fclose(fid);
            catch
                error(['Bathymetry definition file incorrectly formatted [' files{ivar} ']']);
            end
        end
        
        xb = xs_set(xb, '-units', vars{ivar}, {A 'm'});
    else
        error(['Bathymetry definition file does not exist [' files{ivar} ']'])
    end
end

% set meta data
xb = xs_meta(xb, mfilename, 'bathymetry', files);