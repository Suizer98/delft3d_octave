function [X, Y, Z, T] = grid_orth_getDataFromNetCDFGrid(varargin)
%GRID_ORTH_GETDATAFROMNETCDFGRID  This routine gets data from a NetCDF grid file.
%
%   This routine gets data from a NetCDF grid file
%
%   Syntax:
%   varargout = getDataFromNetCDFGrid(varargin)
%
%   Output:
%       X                           = X values
%       Y                           = Y values
%       Z                           = Z values
%       T                           = temporal signature of the data
%
%   Example
%
%   poly = [68920.9 447892
%           69222.7 447863
%           69377.2 447909
%           69730.6 448307
%           69679.1 448608
%           69215.3 448682
%           68928.2 448631
%           68812.9 448211
%           68839.9 447961];
%
%   ncfile = 'Delflandsekust.nc'
%
%   [X, Y, Z, T] = grid_orth_getDataFromNetCDFGrid('ncfile', ncfile, 'starttime', now, 'polygon', poly)
%
%   See also: nc_dump, nc_varfind, grid_2D_orthogonal

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

% Created: 24 Mar 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: grid_orth_getDataFromNetCDFGrid.m 7557 2012-10-23 11:45:48Z boer_g $
% $Date: 2012-10-23 19:45:48 +0800 (Tue, 23 Oct 2012) $
% $Author: boer_g $
% $Revision: 7557 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_getDataFromNetCDFGrid.m $
% $Keywords: $

%% settings
% defaults
OPT = struct(...
    'ncfile', [], ...          % filename of nc file to use
    'starttime', [], ...       % this is a datenum of the starting time to search
    'searchinterval', -30, ... % this indicates the search window (nr of days, '-': backward in time, '+': forward in time)
    'polygon', [], ...         % search polygon (default: [] use entire grid)
    'stride', [1 1 1] ...      % stride vector indicating thinning factor
    );

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

[X, Y, Z, T] = deal([]);

%% find nc variables of coordinates
nc_index.x = nc_varfind(OPT.ncfile, 'attributename','standard_name','attributevalue','projection_x_coordinate');
nc_index.y = nc_varfind(OPT.ncfile, 'attributename','standard_name','attributevalue','projection_y_coordinate');
nc_index.t = nc_varfind(OPT.ncfile, 'attributename','standard_name','attributevalue','time');
nc_index.z = nc_varfind(OPT.ncfile, 'attributename','standard_name','attributevalue','altitude'); % JarKus
if isempty(nc_index.z)
    nc_index.z = nc_varfind(OPT.ncfile, 'attributename','standard_name','attributevalue','height_above_reference_ellipsoid'); % AHN
end

%% find data area of interest

X0        = nc_varget(OPT.ncfile, nc_index.x);
Y0        = nc_varget(OPT.ncfile, nc_index.y);

y_descending = unique(diff(Y0)) < 0;

% sort X and Y. NB: Y is ussumed to descend! This may not be the case for AHN - need to check!
X1 = sort(X0,'ascend');
% check whether Y is ascending, this is also relevant for the start and
% count later on
if y_descending
    Y1 = sort(Y0,'descend');
else
    Y1 = sort(Y0,'ascend');
end

if ~isempty(OPT.polygon)
    % determine the extent of the polygon
    minx = min(OPT.polygon(:,1));
    maxx = max(OPT.polygon(:,1));
    miny = min(OPT.polygon(:,2));
    maxy = max(OPT.polygon(:,2));
    
    % Find out which part of X and Y data lies within the extent of the polygon
    % NB: these are indexes, should be reduced with one for netCDF call as nc files start counting at 0
    xstart  = find(X1>minx, 1, 'first');
    xcount  = find(X1<maxx, 1, 'last');
    if y_descending
        ystart  = find(Y1<maxy, 1, 'first');
        ycount  = find(Y1>miny, 1, 'last');
    else
        ystart  = find(Y1>miny, 1, 'first');
        ycount  = find(Y1<maxy, 1, 'last');
    end
    
else
    xstart  = 1;
    xcount  = size(X0,1);
    ystart  = 1;
    ycount  = size(Y0,1);
end

if ~(isempty(xstart) || isempty(ystart) || isempty(xcount) || isempty(ycount))
    
    %% get relevant data (possibly using stride)
    X        = nc_varget(OPT.ncfile, nc_index.x, xstart - 1, floor((xcount-(xstart-1))/OPT.stride(3)), OPT.stride(3));
    Y        = nc_varget(OPT.ncfile, nc_index.y, ystart - 1, floor((ycount-(ystart-1))/OPT.stride(2)), OPT.stride(2));
    Z        = nan(size(Y,1), size(X,1));
    T        = nan(size(Y,1), size(X,1));
    
    %% find the data files that lie within the temporal search window
    if ~isempty(nc_index.t)
        t        = nc_cf_time(OPT.ncfile, nc_index.t);
        [t,idt]  = sort(t,'descend');
        
        idt_in   = find(t <= OPT.starttime & ...
            t >= OPT.starttime + OPT.searchinterval);
        
        % TO DO: add nearest in time
        % TO DO: add linear interpolation in time
        if ~isempty(OPT.polygon)
            XX   = repmat(X',size(Y,1),          1);
            YY   = repmat(Y ,        1, size(X',2));
            mask = isnan(Z(inpolygon(XX, YY, OPT.polygon(:,1), OPT.polygon(:,2))));
        else
            mask = ':';
        end
        
        %% one by one place separate grids on overall grid
        for id_t = [idt(idt_in)-1]'
            % So long as not all Z values inpolygon are nan try to add data
            if sum(mask)~=0 % trick: sum(':')=58
                if getpref('SNCTOOLS','PRESERVE_FVD')==0
                    Z_next    = nc_varget(OPT.ncfile, nc_index.z, [id_t                ystart-1                                  xstart-1], ...
                                                                  [1   floor((ycount-(ystart-1))/OPT.stride(2)) floor((xcount-(xstart-1))/OPT.stride(3))], ...
                        OPT.stride);
                    if xor(floor((xcount-(xstart-1))/OPT.stride(3)) == 1,  floor((ycount-(ystart-1))/OPT.stride(2)) ==1)
                        Z_next = transpose(Z_next); % wonder if this is needed or only occurs when n cols == 1
                    end
                elseif getpref('SNCTOOLS','PRESERVE_FVD')==1
                    Z_next    = nc_varget(OPT.ncfile, nc_index.z, [                xstart-1                                  ystart-1                  id_t], ...
                                                                  [floor((xcount-(xstart-1))/OPT.stride(3)) floor((ycount-(ystart-1))/OPT.stride(2)) 1], ...
                        OPT.stride);
                    Z_next = transpose(Z_next);
                end
                
                if sum(sum(~isnan(Z_next))) ~=0
                    disp(['... adding data from: ' datestr(t(idt(id_t+1)))])
                    try
                        ids2add = ~isnan(Z_next) & isnan(Z);    % helpul to be in a variable as the nature of Z changes in the next two lines
                    catch
                        xx=0;
                        ids2add = [];
                    end
                    
                    
                    Z(ids2add) = Z_next(ids2add);           % add Z values from Z_next grid to Z grid at places where there is data in Z_next and no data in Z yet
                    T(ids2add) = t(idt(id_t+1));            % add time information to T at those places where Z data was added
                end
            end
        end
    else % do this if there is no time variable in the nc file (e.g. AHN)
        
        OPT.stride  = OPT.stride(2:3);
        
        % find right indices
        xstart_inv  = find(X0 == X1(xstart));
        xcount     = length(xstart:xcount);
        ystart_inv  = find(Y0 == Y1(ystart));
        ycount     = length(ystart:ycount);
        
        % get data without time variable
        X        = nc_varget(OPT.ncfile, nc_index.x,  xstart_inv - 1,       xcount/OPT.stride(2), OPT.stride(2));
        Y        = nc_varget(OPT.ncfile, nc_index.y,  ystart_inv - ycount, ycount/OPT.stride(1), OPT.stride(1));
        Z_next   = nc_varget(OPT.ncfile, nc_index.z, [xstart_inv - 1       ystart_inv - ycount], [xcount/OPT.stride(1) ycount/OPT.stride(2)], OPT.stride);
        Z        = Z_next';
        
    end
    
    %% set values outside polygon to nan if a polygon is available
    if ~isempty(OPT.polygon)
        disp('Setting values not in polygon to nan ...')
        idout = ~inpolygon(repmat(X',size(Y,1),1), repmat(Y, 1, size(X',2)), OPT.polygon(:,1), OPT.polygon(:,2));
        Z(idout) = nan;
        T(idout) = nan;
    end
end
