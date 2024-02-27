function varargout = grid_orth_getPolygon(OPT)
%GRID_ORTH_GETPOLYGON Allows user to select and save a polygon.

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

% $Id: grid_orth_getPolygon.m 9307 2013-10-01 12:32:10Z heijer $
% $Date: 2013-10-01 20:32:10 +0800 (Tue, 01 Oct 2013) $
% $Author: heijer $
% $Revision: 9307 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_getPolygon.m $
% $Keywords: $

if nargin==0
   OPT.polygon = [];
end

try ah = findobj('type','axes','tag',OPT.tag);
delete(findobj(ah,'tag','selectionpoly')); 
end %#ok<*TRYNC> delete any remaining poly

% if no polygon is available yet draw one
if isempty(OPT.polygon)

    % make sure the proper axes is current
    try axes(ah); end
    
%% question

    jjj = menu({'Zoom to your place of interest first.',...
        'Next select one of the following options.',...
        'Finish clicking of a polygon with the <right mouse> button.'},...
        '1. click a polygon',...
        '2. click a polygon and save to a file for reuse',...
        '3. load a polygon from any file type' ...
        );
        
%% load polygon

    if ismember(jjj,[1 2])
        % draw a polygon using polydraw making sure it is tagged properly
        disp('Please click a polygon from which to select data ...')
        [x,y] = polydraw('g','linewidth',2,'tag','selectionpoly');
    else
    
       if isfield(OPT, 'polygondir') % needed when this routine is called from generateVolumeDevelopment
           polygondir = OPT.polygondir;
       else
           polygondir = [];
       end
    
       % load and plot a polygon
       [fileName, filePath, filterindex] = uigetfile({'*.ldb','Delt3D landboundary file (*.ldb)';...
                                         '*.nc' ,'Two variable (x,y) netCDF file (*.nc)';...
                                         '*.mat','Two column xy array (*.mat)';...
                                         '*.shp','Shape file (*.shp)';...
                                         '*.*'  ,'All Files (*.*)'},'Pick a file',[polygondir filesep '*.ldb']);
       if filterindex==1
         [x,y]=landboundary('read',fullfile(filePath,fileName));
       elseif filterindex==2
          x = nc_varget(fullfile(filePath,fileName),'x');
          y = nc_varget(fullfile(filePath,fileName),'y');
       elseif filterindex==3
          % load and plot a polygon
          load(fullfile(filePath,fileName));
          x = polygon(:,1);
          y = polygon(:,2);
       elseif filterindex==4
          R = arc_shape_read(fullfile(filePath,fileName))   
          x = R.X;
          y = R.Y;
       end
       x = reshape(x,[1 length(x)]);
       y = reshape(y,[1 length(y)]);

    end
    
%% save polygon
    
    if jjj==2

       if isfield(OPT, 'polygondir') % needed when this routine is called from generateVolumeDevelopment
           polygondir = OPT.polygondir;
           if ~exist(polygondir)
               mkpath(polygondir)
           end
       else
           polygondir = [];
       end

       [fileName, filePath, filterindex] = uiputfile({'*.ldb','Delt3D landboundary file (*.ldb)';...
                                         '*.nc' ,'Two variable (x,y) netCDF file (*.nc)';...
                                         '*.mat','Two column xy array (*.mat)';...
                                         '*.shp','Shape file (*.shp)';...
                                         '*.*'  ,'All Files (*.*)'},'Save as:',[polygondir filesep 'polygon_',datestr(now,'yyyy-mm-dd_HH.MM.ss') '.ldb']);
                                         
       if filterindex==1
       
          landboundary('write',fullfile(filePath,fileName),x,y);
          
       elseif filterindex==2
       
          nc_create_empty(fullfile(filePath,fileName))
          
          nc_adddim(fullfile(filePath,fileName),'points',length(x));
          varstruct.Nctype    = 'double';
          varstruct.Dimension = { 'points' };

          varstruct.Name      = 'x';
          varstruct.Attribute(1) = struct('Name', 'units'        ,'Value', 'm');
          varstruct.Attribute(2) = struct('Name', 'long_name'    ,'Value', 'projection_x_coordinate');
          varstruct.Attribute(3) = struct('Name', 'standard_name','Value', 'x');
          nc_addvar(fullfile(filePath,fileName),varstruct);
          nc_varput(fullfile(filePath,fileName),'x',x);
          varstruct.Attribute(4) = struct('Name', 'coordinates'  ,'Value', 'x y');

          varstruct.Name      = 'y';
          varstruct.Attribute(1) = struct('Name', 'units'        ,'Value', 'm');
          varstruct.Attribute(2) = struct('Name', 'long_name'    ,'Value', 'projection_y_coordinate');
          varstruct.Attribute(3) = struct('Name', 'standard_name','Value', 'y');
          varstruct.Attribute(4) = struct('Name', 'coordinates'  ,'Value', 'x y');
          nc_addvar(fullfile(filePath,fileName),varstruct);
          nc_varput(fullfile(filePath,fileName),'y',y);
          
       elseif filterindex==3
       
          polygon = [x' y']; %#ok<NASGU>
          save(fullfile(filePath,fileName),'polygon');
       elseif filterindex==4
          try
          shapewrite(fullfile(filePath,fileName),{[x',y']})
          catch
          error('install oss.deltares.nl toolbox for writing *.shp files: shapewrite.m missing.')
          end
       end
    end
    
%% combine x and y in the variable polygon and close it
    
    OPT.polygon = [x' y'];
    OPT.polygon = [OPT.polygon; OPT.polygon(1,:)];
    
    clear x y
    
else
    
    x = OPT.polygon(:,1);
    y = OPT.polygon(:,2);
    
end

if nargout==1
   varargout = {OPT};
else
   varargout = {OPT.polygon(:,1),OPT.polygon(:,2)};
end
