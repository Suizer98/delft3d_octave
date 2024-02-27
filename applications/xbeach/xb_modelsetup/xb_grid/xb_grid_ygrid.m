function ygr = xb_grid_ygrid(yin, varargin)
%XB_GRID_YGRID  Creates a model grid in y-direction based on minimum and maximum cell size and area of interest
%
%   Generates a model grid in y-direction using two grid cellsizes. The
%   minimum grid cellsize is used for the area of interest. The maximum is
%   used near the lateral borders. A gradual transition between the grid
%   cellsizes over a specified distance is automatically generated. The
%   area of interest can be defined in several manners. By default, this is
%   a distance of 100m in the center of the model.
%
%   Syntax:
%   ygr = xb_grid_ygrid(yin, varargin)
%
%   Input:
%   yin       = range of y-coordinates to be included in the grid
%   varargin  = dymin:                  minimum grid cellsize
%               dymax:                  maximum grid cellsize
%               area_type:              type of definition of the area of
%                                       interest (center/range)
%               area_size:              size of the area of interest
%                                       (length or fraction in case of
%                                       area_type center, from/to range in
%                                       case of area_type range)
%               transition_distance:    distance over which the grid
%                                       cellsize is gradually changed from
%                                       mimumum to maximum, a negative
%                                       value means the distance may be
%                                       adapted to limit the error made in
%                                       the fit
%
%   Output:
%   ygr       = generated grid in y_direction
%
%   Example
%   ygr = xb_grid_ygrid(yin)
%
%   See also xb_generate_grid, xb_grid_xgrid

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
% Created: 01 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_grid_ygrid.m 7701 2012-11-19 09:51:05Z hoonhout $
% $Date: 2012-11-19 17:51:05 +0800 (Mon, 19 Nov 2012) $
% $Author: hoonhout $
% $Revision: 7701 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_ygrid.m $
% $Keywords: $

%% read options

xb_verbose(1,'Optimize alongshore grid');

OPT = struct( ...
    'dymin', 5, ...
    'dymax', 20, ...
    'area_type', 'center', ...
    'area_size', .4, ...
    'transition_distance', -.1, ...
    'maxerror', .05 ...
);

OPT = setproperty(OPT, varargin{:});

retry = false;
if OPT.transition_distance < 0
    OPT.transition_distance = abs(OPT.transition_distance);
    retry = true;
    
    xb_verbose(2,'Enable optimization of transition distance');
end

%% make grid

if length(yin) <= 1
    % one-dimensional model
    ygr = [0:2]*OPT.dymin;
    
    xb_verbose(2,'Stop optimization of one-dimensional model');
else
    if OPT.dymin == OPT.dymax
        % equidistant grid
        ygr = min(yin):OPT.dymin:max(yin);
        
        xb_verbose(2,'Create equidistant alongshore grid');
        xb_verbose(2,'Grid size',OPT.dymin);
    else
        % variable, two-dimensional grid
        
        err = Inf;
        
        xb_verbose(2,'Area type',OPT.area_type);
        
        while err>OPT.maxerror
            
            dy = max(yin)-min(yin);
            if all(OPT.transition_distance < 1)
                OPT.transition_distance = OPT.transition_distance*dy;
            end
            
            xb_verbose(2,'Transition',OPT.transition_distance);

            switch OPT.area_type
                case 'center'
                    if all(OPT.area_size < 1)
                        OPT.area_size = OPT.area_size*dy;
                    end

                    ygr = mean(yin)-OPT.area_size/2:OPT.dymin:mean(yin)+OPT.area_size/2;
                case 'range'
                    if all(OPT.area_size < 1 & OPT.area_size > 0)
                        OPT.area_size = min(yin)+OPT.area_size*dy;
                    end

                    ygr = OPT.area_size(1):OPT.dymin:OPT.area_size(2);
                otherwise
                    % default center with length one
                    ygr = mean(yin)+[-1 1]*OPT.dymin/2;
            end
        
            % grid transition
            [ff nf gridf err] = grid_transition(OPT.dymin, OPT.dymax, OPT.transition_distance);
            ygr = [ygr(1)-fliplr(gridf) ygr ygr(end)+gridf];

            if retry
                if err>OPT.maxerror && retry
                    OPT.transition_distance = 1.1*OPT.transition_distance;
                end
            else
                break
            end
            
            xb_verbose(2,'Error',err);
        end
        
        if err>OPT.maxerror
            warning(sprintf('Relative error in alongshore grid transition > %d%%',floor(err*100)));
        end
        
        % extend till borders
        ygr = [fliplr(ygr(1)-OPT.dymax:-OPT.dymax:min(yin)) ygr ygr(end)+OPT.dymax:OPT.dymax:max(yin)];
        
        xb_verbose(2,'Grid cells',length(ygr));
    end
end
