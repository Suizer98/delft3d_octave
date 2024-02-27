function [xgrid, ygrid, zgrid, negrid, alpha, xori, yori] = xb_grid_optimize(varargin)
%XB_GRID_OPTIMIZE  Creates a model grid based on a given bathymetry
%
%   Creates a model grid in either one or two dimensions based on a given
%   bathymetry. The result is three matrices of equal size containing a
%   rectilinear grid in x, y and z coordinates.
%
%   Syntax:
%   xb = xb_grid_optimize(varargin)
%
%   Input:
%   varargin  = x:          x-coordinates of bathymetry
%               y:          y-coordinates of bathymetry
%               z:          z-coordinates of bathymetry
%               ne:         vector or matrix of the size of z containing
%                           either booleans indicating if a cell is
%                           non-erodable or a numeric value indicating the
%                           thickness of the erodable layer on top of a
%                           non-erodable layer
%               xgrid:      options for xb_grid_xgrid
%               ygrid:      options for xb_grid_ygrid
%               rotate:     boolean flag that determines whether the
%                           coastline is located in line with y-axis
%               crop:       either a boolean indicating if grid should be
%                           cropped to obtain a rectangle or a [x y w h]
%                           array indicating how the grid should be cropped
%               finalise:   either a boolean indicating if grid should be
%                           finalised using default settings or a cell
%                           array indicating the finalisation actions to
%                           perform
%               posdwn:     boolean flag that determines whether positive
%                           z-direction is down
%               world_coordinates:  
%                           boolean to enable a grid defined in
%                           world coordinates rather than XBeach model 
%                           coordinates
%               zdepth:     extent of model below mean sea level, which is
%                           used if non-erodable layers are defined
%
%   Output:
%   xb        = XBeach structure array
%
%   Example
%   xb = xb_grid_optimize('x', x, 'y', y, 'z', z)
%
%   See also xb_grid_xgrid, xb_grid_ygrid, xb_generate_bathy, xb_generate_model

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 09 Sep 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_grid_optimize.m 16129 2019-12-13 22:34:47Z l.w.m.roest.x $
% $Date: 2019-12-14 06:34:47 +0800 (Sat, 14 Dec 2019) $
% $Author: l.w.m.roest.x $
% $Revision: 16129 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_optimize.m $
% $Keywords: $

%% read options

xb_verbose(0,'Optimize bathymetry');

OPT = struct( ...
    'x', [0 2550 2724.9 2775 2805 3030.6], ...
    'y', [], ...
    'z', [-20 -3 0 3 15 15], ...
    'ne', [], ...
    'xgrid', {{}}, ...
    'ygrid', {{}}, ...
    'rotate', true, ...
    'crop', true, ...
    'finalise', true, ...
    'posdwn', false, ...
    'world_coordinates', true, ...
    'zdepth', 100 ...
);

OPT = setproperty(OPT, varargin{:});

if isempty(OPT.y); OPT.y = 0; end;

%% prepare grid

x_w = OPT.x;
y_w = OPT.y;
z_w = OPT.z;
ne_w = OPT.ne;

% empty memory
OPT = rmfield(OPT, {'x' 'y' 'z'});

% make sure coordinates are matrices
if isvector(x_w) && isvector(y_w)
    [x_w, y_w] = meshgrid(x_w, y_w);
    
    xb_verbose(1,'Create grid from vectors');
end

% set vertical positive direction
if OPT.posdwn
    z_w = -z_w;
    
    xb_verbose(1,'Invert vertical dimension');
end

%% convert from world to xbeach coordinates

[x_r, y_r] = deal(x_w, y_w);

% determine origin
xori = min(min(x_w));
yori = min(min(y_w));

xb_verbose(1,'Determine origin');
xb_verbose(2,'X',xori);
xb_verbose(2,'Y',yori);

alpha = 0;

% rotate grid and determine alpha
if OPT.rotate && ~isvector(z_w)
    if ~islogical(OPT.rotate) && ~ismember(OPT.rotate,[0 1])
        alpha = OPT.rotate;
        [x_r, y_r] = xb_grid_rotate(x_r, y_r, alpha, 'origin', [xori yori]);
        
        xb_verbose(1,'Rotate grid around origin');
        xb_verbose(2,'alpha',alpha);
    else
        alpha = xb_grid_rotation(x_r, y_r, z_w);
        
        xb_verbose(1,'Determine grid rotation');
        xb_verbose(2,'alpha',alpha);
        
        if abs(alpha) > 5
            [x_r, y_r] = xb_grid_rotate(x_r, y_r, alpha, 'origin', [xori yori]);
            
            xb_verbose(1,'Rotate grid around origin');
            xb_verbose(2,'alpha',alpha);
        else
            alpha = 0;
            
            xb_verbose(1,'Rotation is small, do not rotate');
        end
    end
end

%% determine representative cross-section

if isvector(z_w)
    % create dummy grid
    x_d = x_r;
    y_d = [];
    z_d_cs = z_w;

    % empty memory
    clear x_r y_r
else
    % determine resolution and extent
    [cellsize, xmin, xmax, ymin, ymax] = xb_grid_resolution(x_r, y_r);
    
    xb_verbose(1,'Determine grid resolution and extent');
    xb_verbose(2,{'cellsize' 'xmin' 'xmax' 'ymin' 'ymax'},{cellsize xmin xmax ymin ymax});

    xcorners_r = [];
    ycorners_r = [];
    
    % crop grid
    if ischar(OPT.crop) && strcmpi(OPT.crop, 'select')
        xb_verbose(1,'Enable user to crop grid visually');
        
        disp('Please select opposing cornerpoints of your grid by clicking.');
        
        fh = figure;
        pcolor(x_r, y_r, z_w);
        axis equal;
        shading flat; colorbar;

        [xcorners_r, ycorners_r] = ginput(2);
        
        xmin = min(xcorners_r);
        xmax = max(xcorners_r);
        ymin = min(ycorners_r);
        ymax = max(ycorners_r);
        
        OPT.crop = [xmin ymin xmax-xmin ymax-ymin];

        close(fh);
    end

    if ~islogical(OPT.crop) && isvector(OPT.crop) && ~isa(OPT.crop,'char')
        % rotate crop vector if needed
        if abs(alpha) > 5
            
            if isempty(xcorners_r) || isempty(ycorners_r)
                xcorners = [OPT.crop(1) OPT.crop(1)+OPT.crop(3)];
                ycorners = [OPT.crop(2) OPT.crop(2)+OPT.crop(4)];
                
                xcorners_r = xori+cosd(alpha)*(xcorners-xori)+sind(alpha)*(ycorners-yori);
                ycorners_r = yori-sind(alpha)*(xcorners-xori)+cosd(alpha)*(ycorners-yori);
            end
             
            xmin = min(xcorners_r);
            xmax = max(xcorners_r);
            ymin = min(ycorners_r);
            ymax = max(ycorners_r);
        else
            [xmin, xmax, ymin, ymax] = xb_grid_crop(x_r, y_r, z_w, 'crop', OPT.crop);
        end
        
        xb_verbose(1,'Cropping grid as requested');
        xb_verbose(2,{'xmin' 'xmax' 'ymin' 'ymax'},{xmin xmax ymin ymax});
    elseif OPT.crop
        [xmin, xmax, ymin, ymax] = xb_grid_crop(x_r, y_r, z_w);
        
        xb_verbose(1,'Cropping grid automatically');
        xb_verbose(2,{'xmin' 'xmax' 'ymin' 'ymax'},{xmin xmax ymin ymax});
    end

    % create dummy grid
    x_d = linspace(xmin, xmax, max(2,ceil((xmax-xmin)/cellsize)));
    y_d = linspace(ymin, ymax, max(2,ceil((xmax-xmin)/cellsize)));
    
    xb_verbose(1,'Determine maximum interpolation grid in XBeach coordinates');
    xb_verbose(2,'Cells X',length(x_d));
    xb_verbose(2,'Cells Y',length(y_d));

    % interpolate elevation data to dummy grid
    [x_d, y_d] = meshgrid(x_d,y_d);
    
    % rotate dummy grid to world coordinates to allow for use of interp2
    [x_d_w, y_d_w] = xb_grid_rotate(x_d, y_d, -alpha, 'origin', [xori yori]);
    
    if max(max(diff(x_d_w,1,2))) == 0 && max(max(diff(y_d_w,1,1))) == 0
        x_d_w   = x_d_w';
        y_d_w   = y_d_w';
    end
    
    try
        z_d = interp2(x_w', y_w', z_w', x_d_w, y_d_w);
        % use other interpolation method if necessary
    catch error_message
        warning(['INTERP2 cannot be used, interpolation can take a little longer: ' error_message.message]);
        interpolant = scatteredInterpolant(x_r(:), y_r(:), z_w(:));
        z_d = interpolant(x_d, y_d);
        clear interpolant
    end
    
    xb_verbose(1,'Interpolate bathymetry to interpolation grid');

    % determine representative cross-section
    z_d_cs = max(z_d, [], 1);
    
    xb_verbose(1,'Determine representative cross-shore profile');
end

% remove nan's
notnan = ~isnan(z_d_cs);
x_d_1d = x_d(1,notnan);
if ~isempty(y_d)
    y_d_1d = y_d(:,1);
else
    y_d_1d = y_d;
end
z_d_cs = z_d_cs(notnan);

xb_verbose(1,'Remove NaN''s from representative cross shore profile');
xb_verbose(2,'Grid cells',length(notnan));
xb_verbose(2,'NaN''s',sum(~notnan));

% clear memory
clear x_d_w y_d_w

%% create xbeach grid
[x_xb, z_xb] = xb_grid_xgrid(x_d_1d, z_d_cs, OPT.xgrid{:});
[y_xb] = xb_grid_ygrid(y_d_1d, OPT.ygrid{:});

% clear memory
clear y_d z_d z_d_cs

[xgrid, ygrid] = meshgrid(x_xb, y_xb);

xb_verbose(1,'Combine alongshore and cross-shore grid');

% interpolate bathymetry on grid, if necessary
if isvector(z_w)
    % 1D grid
    zgrid = repmat(z_xb, length(y_xb), 1);
    
    xb_verbose(1,'Multiply cross-shore bathymetry in longsore direction');
    xb_verbose(2,'Times',length(y_xb));

    % interpolate non-erodable layers
    if ~isempty(OPT.ne)
        
        xb_verbose(1,'Add non-erodible layer');
        
        negrid = interp1(x_d, ne_w, x_xb);
        if islogical(OPT.ne)
            negrid(isnan(negrid)) = 0;
            idx = ~logical(round(negrid));
            negrid(idx) = OPT.zdepth+zgrid(idx);
            negrid(~idx) = 0;
            
            xb_verbose(2,'Depth',OPT.zdepth);
        else
            xb_verbose(2,'Depth','<variable>');
        end
        negrid = repmat(negrid, length(y_xb), 1);
    end
else
    % 2D grid

    % rotate xbeach grid to world coordinates
    [x_xb_w, y_xb_w] = xb_grid_rotate(x_xb, y_xb, -alpha, 'origin', [xori yori]);
    
    if max(max(diff(x_xb_w,1,2))) == 0 && max(max(diff(x_xb_w,1,1))) == 0
        x_xb_w  = x_xb_w';
        y_xb_w  = y_xb_w';
    end
    
    xb_verbose(1,'Rotate combined grid to world coordinates');

    % interpolate elevation data to xbeach grid
    try
        zgrid = interp2(x_w', y_w', z_w', x_xb_w, y_xb_w);
        % use other interpolation method if necessary
    catch error_message
        warning(['INTERP2 cannot be used, interpolation can take a little longer: ' error_message.message]);
        interpolant = scatteredInterpolant(x_w(:), y_w(:), z_w(:));
        zgrid = interpolant(x_xb_w, y_xb_w);
        clear interpolant
    end
    
    xb_verbose(1,'Interpolate bathymetry to combined grid');

    % interpolate non-erodable layers
    if ~isempty(OPT.ne)
        
        xb_verbose(1,'Add non-erodible layer');
        
        negrid = interp2(x_w, y_w, ne_w, x_xb_w, y_xb_w);
        if islogical(OPT.ne)
            negrid(isnan(negrid)) = 0;
            idx = ~logical(round(negrid));
            negrid(idx) = OPT.zdepth+zgrid(idx);
            negrid(~idx) = 0;
            
            xb_verbose(2,'Depth',OPT.zdepth);
        else
            xb_verbose(2,'Depth','<variable>');
        end
    end
end

% clear memory
clear x_d x_w y_w z_w ne_w x_xb y_xb z_xb x_xb_w y_xb_w

%% finalise grid

% remove all-nan columns and rows
idx1 = ~all(isnan(zgrid),2);
idx2 = ~all(isnan(zgrid),1);

xb_verbose(1,'Remove rows and columns with only NaN''s');
xb_verbose(2,'Rows',size(zgrid,1));
xb_verbose(2,'Nan''s',sum(~idx1));
xb_verbose(2,'Columns',size(zgrid,2));
xb_verbose(2,'Nan''s',sum(~idx2));

xgrid = xgrid(idx1, idx2);
ygrid = ygrid(idx1, idx2);
zgrid = zgrid(idx1, idx2);

if ~isempty(OPT.ne)
    negrid = negrid(idx1, idx2);
end

% interpolate nan's
if (~islogical(OPT.finalise) && iscell(OPT.finalise)) || (islogical(OPT.finalise) && OPT.finalise)
    
    xb_verbose(1,'Interpolate grid cells with NaN''s');
    xb_verbose(2,'Grid cells',numel(zgrid));
    xb_verbose(2,'Nan''s',sum(isnan(zgrid(:))));

    for i = 1:size(zgrid, 1)
        notnan = ~isnan(zgrid(i,:));
        if any(~notnan) && sum(notnan) > 1
            zgrid(i,~notnan) = interp1(xgrid(i,notnan), zgrid(i,notnan), xgrid(i,~notnan));
        end

        j = find(~isnan(zgrid(i,:)), 1, 'first');
        if ~isempty(j) && j > 1
            zgrid(i,1:j-1) = zgrid(i,j);
        end

        j = find(~isnan(zgrid(i,:)), 1, 'last');
        if ~isempty(j) && j < size(zgrid, 2)
            zgrid(i,j+1:end) = zgrid(i,j);
        end
    end

    if ~isempty(OPT.ne)
        notnan          = ~isnan(negrid);
        negrid(~notnan) = OPT.zdepth+zgrid(~notnan);
    end
end

% perform finalise actions
if ~islogical(OPT.finalise) && iscell(OPT.finalise)
    xgrid_old = xgrid;
    ygrid_old = ygrid;
    
    [xgrid, ygrid, zgrid] = xb_grid_finalise(xgrid, ygrid, zgrid, OPT.finalise);
elseif OPT.finalise
    xgrid_old = xgrid;
    ygrid_old = ygrid;
    
    [xgrid, ygrid, zgrid] = xb_grid_finalise(xgrid, ygrid, zgrid);
end

% adapt nelayer to finalised grid
if (~islogical(OPT.finalise) && iscell(OPT.finalise)) || (islogical(OPT.finalise) && OPT.finalise)
    if ~isempty(OPT.ne)
        negrid = interp2(xgrid_old,ygrid_old,negrid,xgrid,ygrid);
        if any(any(isnan(negrid)))
            distance = pointdistance_pairs([xgrid(isnan(negrid)) ygrid(isnan(negrid))], [xgrid(~isnan(negrid)) ygrid(~isnan(negrid))]);
            [~, nn_idx] = min(distance,[],2);
            negrid_notnan = negrid(~isnan(negrid));
            negrid(isnan(negrid)) = negrid_notnan(nn_idx);
            
            clear xgrid_old ygrid_old negrid_notnan
        end
        
        xb_verbose(1,'Extend non-erodible layers to finalized grids');
    end
end

% convert to world coordinates if needed
if OPT.world_coordinates
    [xgrid, ygrid] = xb_grid_rotate(xgrid, ygrid, -alpha, 'origin', [xori yori]);
    alpha = 0;
    xori = 0;
    yori = 0;
end

if max(max(diff(xgrid,1,2))) == 0 && max(max(diff(ygrid,1,1))) == 0
    xgrid   = xgrid';
    ygrid   = ygrid';
    zgrid   = zgrid';
end

%% output

if isempty(OPT.ne)
    negrid = nan(size(zgrid));
    
    xb_verbose(1,'Add dummy for non-erodible layers');
end