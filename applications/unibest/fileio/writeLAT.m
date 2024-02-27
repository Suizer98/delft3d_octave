function writeLAT(filename, xlimits, ylimits, land_polygon, polygons, text_block, point_block, color_info)
%write LAT : Writes a unibest lat file (used for visualisation in UNIBEST-CL)
%
%   Syntax:
%     function writeLAT(filename, xlimits, ylimits, land_polygon, polygons, text_block, point_block, color_info)
% 
%   Input:
%     filename             string with output filename
%     xlimits              [xmin xmax];
%     ylimits              [ymin ymax];
%     land_polygon         polygon defined at the landward side of the coast ([Nx2] matrix with xy-coordinates)
%     polygons             polygons that are drawn in the cl-run, struct with:
%                            - polygons.xy = {[Nx2],[Nx2],[Nx2]} or [Nx2] (i.e. only 1 polygon);
%                            - polygons.RGB = {[1 2 3],[3 6 8],[3 8 9]}  or [1 5 9] (i.e. same colour for all polygons) or [] (i.e. everything black)
%     text_block           block with text to be added in cl-run, struct with:
%                            - text_block.xy = [xy]
%                            - text_block.font = [fontsize]  (value or Nx1)
%                            - text_block.textcolor = [color]    (value or Nx1)
%                            - text_block.textstr = '' or {''}
%     point_block          block with text and circle to be added in cl-run, struct with:
%                            - point_block.xy = [xy]
%                            - point_block.diameter = [D]     (value or Nx1)
%                            - point_block.color = [color]    (value or Nx1)
%                            - point_block.font = [fontsize]  (value or Nx1)
%                            - point_block.textstr = '' or {''}
%                            - point_block.textcolor = [color]    (value or Nx1)
%     color_info           defines colours ([7x1] vector) of Sea, Land, Groyns, Revetment, Sources/Sinks, Offshore Breakwaters, t0-line)
%                            (default: [9, 14, 6, 2, 4, 8, 0])
%                            -  0 = black
%                            -  1 = dark blue
%                            -  2 = dark green
%                            -  3 = dark green-blue
%                            -  4 = dark red
%                            -  5 = purple
%                            -  6 = brown
%                            -  7 = light grey
%                            -  8 = dark grey
%                            -  9 = blue
%                            - 10 = green
%                            - 11 = light blue
%                            - 12 = red
%                            - 13 = pink
%                            - 14 = yellow
%                            - 15 = white
% 
%   Output:
%     .lat file
% 
%   Example:
%     writeLAT('test.lat', xlimits, ylimits, [], {[20,1;10,2],[220,95;150,72;80,20]}, [], point_block, [])
% 
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: writeLAT.m 8631 2013-05-16 14:22:14Z heijer $
% $Date: 2013-05-16 22:22:14 +0800 (Thu, 16 May 2013) $
% $Author: heijer $
% $Revision: 8631 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/writeLAT.m $
% $Keywords: $


%-----------analyse input data--------------
%-------------------------------------------

default_polygonRGB     = [0 0 0];

default_texttextsize   = [8];
default_texttextcolor  = [12];
default_texttextstr    = 'Loc.';

default_pointdiameter  = [3];
default_pointcolor     = [10];
default_pointtextstr   = 'Loc.';
default_pointtextsize  = [8];
default_pointtextcolor = [0];

default_colorinfo      = [9, 14, 6, 2, 4, 8, 0];


% Catch input land_polygon
%-------------------------------------------
if isstr(land_polygon)
    land_polygon = readldb(land_polygon);
    land_polygon = [land_polygon.x land_polygon.y];
end
if size(land_polygon,2)>size(land_polygon,1)
    land_polygon = land_polygon';
end

% Catch input polygons
%-------------------------------------------
if isempty(polygons)
    polygons=struct;
    polygons.xy=[];
else
    if ~isfield(polygons,'RGB')
        polygons.RGB=[];
    end
    if isempty(polygons.RGB)
        polygons.RGB=default_polygonRGB;
    end
    if isnumeric(polygons.RGB)
        polygons.RGB={polygons.RGB};
        for ii=1:length(polygons.xy)
            polygons.RGB{ii}=polygons.RGB{1};
        end
    end
    if isnumeric(polygons.xy)
        polygons.xy={polygons.xy};
    end
end


% Catch input text_block
%-------------------------------------------
if isempty(text_block)
    text_block=struct;
    text_block.xy=[];
else
    % .font
    if ~isfield(text_block,'font')
        text_block.font=[];
    end
    if isempty(text_block.font)
        text_block.font=default_texttextsize;
    end
    if length(text_block.font)<size(text_block.xy,1)
        for ii=1:size(text_block.xy,1)
            text_block.font(ii)=text_block.font(1);
        end
    end
    % .textcolor
    if ~isfield(text_block,'textcolor')
        text_block.textcolor=[];
    end
    if isempty(text_block.textcolor)
        text_block.textcolor=default_texttextcolor;
    end
    if length(text_block.textcolor)<size(text_block.xy,1)
        for ii=1:size(text_block.xy,1)
            text_block.textcolor(ii)=text_block.textcolor(1);
        end
    end
    % .textstr
    if ~isfield(text_block,'textstr')
        text_block.textstr={};
    end
    if isempty(text_block.textstr)
        text_block.textstr={default_texttextstr};
    end
    if length(text_block.textstr) < size(text_block.xy,1)
        for ii=1:size(text_block.xy,1)
            text_block.textstr2{ii}=[text_block.textstr{1},num2str(ii,'%02.0f')];
        end
        text_block.textstr = text_block.textstr2;
    end    
end

% Catch input point_block
%-------------------------------------------
if isempty(point_block)
    point_block=struct;
    point_block.xy=[];
else
    % .diameter
    if ~isfield(point_block,'diameter')
        point_block.diameter=[];
    end
    if isempty(point_block.diameter)
        point_block.diameter=default_pointdiameter;
    end
    if length(point_block.diameter)<size(point_block.xy,1)
        for ii=1:size(point_block.xy,1)
            point_block.diameter(ii)=point_block.diameter(1);
        end
    end
    % .color
    if ~isfield(point_block,'color')
        point_block.color=[];
    end
    if isempty(point_block.color)
        point_block.color=default_pointcolor;
    end
    if length(point_block.color)<size(point_block.xy,1)
        for ii=1:size(point_block.xy,1)
            point_block.color(ii)=point_block.color(1);
        end
    end
    % .font
    if ~isfield(point_block,'font')
        point_block.font=[];
    end
    if isempty(point_block.font)
        point_block.font=default_pointtextsize;
    end
    if length(point_block.font)<size(point_block.xy,1)
        for ii=1:size(point_block.xy,1)
            point_block.font(ii)=point_block.font(1);
        end
    end
    % .textcolor
    if ~isfield(point_block,'textcolor')
        point_block.textcolor=[];
    end
    if isempty(point_block.textcolor)
        point_block.textcolor=default_pointtextcolor;
    end
    if length(point_block.textcolor)<size(point_block.xy,1)
        for ii=1:size(point_block.xy,1)
            point_block.textcolor(ii)=point_block.textcolor(1);
        end
    end
    % .textstr
    if ~isfield(point_block,'textstr')
        point_block.textstr={};
    end
    if isempty(point_block.textstr)
        point_block.textstr={default_pointtextstr};
    end
    if length(point_block.textstr)<size(point_block.xy,1)
        for ii=1:size(point_block.xy,1)
            point_block.textstr2{ii}=[point_block.textstr{1},num2str(ii,'%02.0f')];
        end
        point_block.textstr = point_block.textstr2;
    end    
end


% Catch input color_info
%-------------------------------------------
if isempty(color_info)
    color_info = default_colorinfo;
end



%-----------Write data to file--------------
%-------------------------------------------
fid = fopen(filename,'wt');
fprintf(fid,'%s\n','Land polygon');
fprintf(fid,'%5.0f\n', size(land_polygon,1)); 
if size(land_polygon,1)>0
    fprintf(fid,' %11.3f %11.3f\n', land_polygon');
end
fprintf(fid,'%s\n',' Xmin      Xmax      Ymin      Ymax');
fprintf(fid,' %10.1f %10.1f %10.1f %10.1f\n', xlimits(1), xlimits(2), ylimits(2), ylimits(1));
fprintf(fid,'%s\n','Polygons');
num_of_polygons = length(polygons.xy);
if num_of_polygons==1 & isempty(polygons.xy{1})
    num_of_polygons=0;
end
fprintf(fid,' %4.0f\n', num_of_polygons);
for ii=1:num_of_polygons
    fprintf(fid,'%s\n','Color     R          G          B');
    fprintf(fid,'        %4.0f      %4.0f      %4.0f\n', polygons.RGB{ii}(1), polygons.RGB{ii}(2), polygons.RGB{ii}(3));
    fprintf(fid,'%s\n','Number of points');
    fprintf(fid,' %4.0f\n',size(polygons.xy{ii},1));
    fprintf(fid,'%s\n','         X [m]     Y [m]');
    for iii=1:size(polygons.xy{ii},1)
        fprintf(fid,' %12.3f %12.3f\n',polygons.xy{ii}(iii,1),polygons.xy{ii}(iii,2));
    end
end
fprintf(fid,'%s\n','Text block');
fprintf(fid,' %4.0f\n', size(text_block.xy,1));
fprintf(fid,'%s\n','         X [m]     Y [m]     FontheightColor     Text');
for ii=1:size(text_block.xy,1)
    fprintf(fid,' %12.3f %12.3f %12.0f %12.0f %s\n',text_block.xy(ii,1),text_block.xy(ii,2),text_block.font(ii),text_block.textcolor(ii),text_block.textstr{ii});
end
fprintf(fid,'%s\n','Point block');
fprintf(fid,' %4.0f\n', size(point_block.xy,1));
fprintf(fid,'%s\n','              Place               Circle                   Text');
fprintf(fid,'%s\n','         X [m]     Y [m]     Dia [m]   Color          FontheightColorText');
for ii=1:size(point_block.xy,1)
    fprintf(fid,' %12.3f %12.3f %12.0f %12.0f %s\n',point_block.xy(ii,1),point_block.xy(ii,2),...
                                                    point_block.diameter(ii),...
                                                    point_block.color(ii),...
                                                    point_block.font(ii),...
                                                    point_block.textcolor(ii),...
                                                    point_block.textstr{ii});
end
fprintf(fid,'%s\n','Color Information');
fprintf(fid,'%03.0f %s\n', color_info(1), '               (Sea)');
fprintf(fid,'%03.0f %s\n', color_info(2), '               (Land)');
fprintf(fid,'%03.0f %s\n', color_info(3), '               (Groyns)');
fprintf(fid,'%03.0f %s\n', color_info(4), '               (Revetment)');
fprintf(fid,'%03.0f %s\n', color_info(5), '               (Sources/Sinks)');
fprintf(fid,'%03.0f %s\n', color_info(6), '               (Offshore Breakwaters)');
fprintf(fid,'%03.0f %s\n', color_info(7), '               (t0 lyn)');
