function wkt = m_shp2wkt(shp, varargin)
%M_SHP2WTK  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = m_shp2wkt(varargin)
%
%   Input: For <keyword,value> pairs call m_shp2wkt() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   m_shp2wkt
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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
% Created: 04 Dec 2012
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: m_shp2wkt.m 8605 2013-05-10 10:35:08Z hoonhout $
% $Date: 2013-05-10 18:35:08 +0800 (Fri, 10 May 2013) $
% $Author: hoonhout $
% $Revision: 8605 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/m_map/m_shp2wkt.m $
% $Keywords: $

%% read options

%% read shapefile

if isstruct(shp)
    S = shp;
else
    if ~exist(shp, 'file')
        error('File not found: %s', shp);
    end

    [fdir, fname] = fileparts(shp);

    S = m_shaperead(fullfile(fdir, fname));
end

wkt = cell(length(S.ncst), 1);
for i = 1:length(S.ncst)
    
    type        = shp2wtk_type(S.ctype);
    
    coords      = num2cell(S.ncst{i});
    coords_WKT  = concat(concat(cellfun(@(x) sprintf('%10.4f',x), coords, 'UniformOutput', false),' '),', \n');
    
    multi_WKT   = regexp(coords_WKT, ',\s+NaN\s+NaN,\s+', 'split');
    if length(multi_WKT) > 1
        type        = sprintf('MULTI%s', type);
        coords_WKT  = sprintf('(%s)', concat(multi_WKT, '),('));
    end

	wkt{i} = sprintf('%s (%s)', type, coords_WKT);
    
end

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function wkt = shp2wtk_type(shp)

    switch shp
        case 'point'
            wkt = 'POINT';
        case 'polyline'
            wkt = 'LINESTRING';
        case 'polygon'
            wkt = 'POLYGON';
        otherwise
            error('Unsupported feature type: %s', shp);
    end
    
end