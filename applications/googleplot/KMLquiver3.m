function [OPT, Set, Default] = KMLquiver3(lat,lon,z,u,v,varargin)
% KMLQUIVER3 Just like quiver3 (except no w yet)
%
%    KMLquiver3(LAT,lon,Z,V,u,<keyword,value>) % ! NOTE THE ORDER OF LAT/LON vs. V/U !
%
% Keywords:
%
% 'arrowScale': Arrows lengths are plotted in meters (for easy measuring of
%               speeds in GE with Ruler). If speeds are low compared to
%               grid size, use a high value for 'arrowScale'.
% 'arrowStyle': can be either
%               'blackTip', 'block', 'line'.
%               If you make a
%               nicer arrow yourself, it can easily be added to the
%               presets.
%
% For the additional <keyword,value> pairs call
%
%    OPT = KMLquiver3()
%
% Example:
%{
    [Lat Lon Z] = meshgrid(-80:10:80,-170:10:180,[3 6 9 12].*1e4);
    v = (rand(size(Lat))-.5);
    u = (rand(size(Lat))-.5);
    cmap = colormap_cpt('temperature');
    fillColors = cmap(ceil((u.^2+v.^2)*2*size(cmap,1)),:);
    KMLquiver3(Lat,Lon,Z,v,u,'arrowScale',5e5,'lineWidth',2,...
        'fillColor',fillColors,'fillAlpha',1);
%}
% Adjust 'W1'..'W4' and 'L1'..'L4' for user defined arrow shapes
% All lengths are a fraction of the base length.
%
%                                   W2       W2
%                 positive  +------------+------------+- negative
%                           .       W3   |   W3       .
%                           .--+---------+---------+- .
%                           .  .         |         .  .
%                           .  .    -+---+---+-    .  .
%                           .  .     . W1 W1 .     .  .
%                           .  .     .       .     .  .
%                           .  .     .   A   .     .  .
%            + ..........................o   .     .  .
%            |              .  .     .  /6\  .     .  .
%            |              .  .     . /   \ .     .  .
%            |              .  .     ./     \.     .  .
%          b |              .  .     / head  \     .  .
%          a |              .  .    /.       .\    .  .
%          s |              .  .   / .       . \   .  .
%          e |              .  .  /  .       .  \  .  .
%            |     L1       .  . /  A9       A3  \ .  .
%          l |     +............/... o...... o    \.  .
%          e |     |        .  /    /|S2   S6|\    \  .
%          n |     |        . /.   / |       | \   .\ .
%          g |     | L2     ./ .  /  |       |  \  . \.
%          t |     |  +.....o  . /   |       |   \ .  o
%          h |     |  |    A7\ ./   |         |   \. /A5
%            |     |  |  +... \o    |         |    o/
%            |     |  |  |     A8   |         |   A4
%            |     |  |  |L3        |         |
%            |     |  |  |         |     A1    |
%            +-----+--+--+.........|.... o.....|............. point S4 is the origin
%            |                     |    / \    |
%         L4 |                     |  /     \  |
%            + ................... o/.........\o
%                                  A10         A2
%
%                                  +-----+-----+
%                                    W4     W4
%
%
% Note: Notice the difference in how polygons and line are rendered by GE.
%   Especially take care when plotting large figures near pole's
%
% See also: googlePlot, quiver, arrow2, KMLquiver

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl
%
%       Deltares
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

% $Id: KMLquiver3.m 5256 2011-09-20 08:59:27Z boer_g $
% $Date: 2011-09-20 16:59:27 +0800 (Tue, 20 Sep 2011) $
% $Author: boer_g $
% $Revision: 5256 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLquiver3.m $
% $Keywords: $

%% default settings
OPT = struct(...
    'arrowStyle' ,'default',...
    'arrowScale' ,1,...
    'fileName'   ,[],...
    'openInGE'   ,false,...
    'arrowFill'  ,[],'lineWidth',[],'lineColor',[],...
    'lineAlpha'  ,[],'fillColor',[],'fillAlpha',[],...
    'W1'         ,[],'W2'       ,[],'W3'       ,[],'W4'       ,[],...
    'L1'         ,[],'L2'       ,[],'L3'       ,[],'L4'       ,[]);
OPT = mergestructs(OPT,KML_header());

   OPT.zScaleFun = @(z) (z+20).*5;

[OPT, Set, Default] = setproperty(OPT, varargin);

if length(OPT.timeIn ) ==1;OPT.timeIn  = repmat(OPT.timeIn ,[1 length(lat(1,:))]);end
if length(OPT.timeOut) ==1;OPT.timeOut = repmat(OPT.timeOut,[1 length(lat(1,:))]);end

%% pre defined arrow types
% additional user settings override presets

OPT2 = struct(...
    'arrowStyle' ,[],'arrowScale',[],'fileName'  ,[],...
    'openInGE'  ,[],...
    'timeIn'     ,datestr(OPT.timeIn ,OPT.dateStrStyle),...
    'timeOut'    ,datestr(OPT.timeOut,OPT.dateStrStyle),...
    'arrowFill'  ,true,...
    'lineWidth'  ,1.5,...
    'lineColor'  ,[0 0 0],...
    'lineAlpha'  ,1,...
    'fillColor'  ,[1 0 0],...
    'fillAlpha'  ,0.75,...
    'W1'         ,0.12,'W2'       ,0.25,'W3'       ,0.25,'W4'       ,0.15,...
    'L1'         ,0.80,'L2'       ,0.70,'L3'       ,0.70,'L4'       ,0.20);
OPT2 = mergestructs(OPT2,KML_header());
OPT2.zScaleFun = OPT.zScaleFun;

switch lower(OPT.arrowStyle)
    case 'default'
        % don't adjust anything
    case 'blacktip'
        OPT2.lineWidth      = 3;
        OPT2.fillColor      = [0 0 0];
        OPT2.fillAlpha      = 1;
        OPT2.W1             = 0.00;
        OPT2.W4             = 0.00;
    case 'block'
        OPT2.W1             = 0.14;
        OPT2.W4             = 0.14;
        OPT2.L1             = 0.70;
        OPT2.L4             = 0.00;
    case 'line'
        OPT2.W1             = 0.00;
        OPT2.W4             = 0.00;
        OPT2.L1             = 1.00;
        OPT2.L4             = 0.00;
        OPT2.arrowFill      = false;
        OPT2.lineWidth      = 2;
    otherwise
        error('unsupported Arrow %s', OPT.arrow)
end

if nargin==0
    return
end

%delete empty OPT fieldnames before merge
fields = fieldnames(OPT);
for ii = 1:length(fields)
    if isempty(OPT.(fields{ii}))
        OPT = rmfield(OPT, fields{ii});
    end
end

% set properties again
[OPT, Set, Default] = setproperty(OPT2, OPT);

%% Calculate coordinates, scaling and orientation of arrows

lat         = lat(:)';
lon         = lon(:)';
z           = OPT.zScaleFun(z(:)');
u           =   u(:)';
v           =   v(:)';

% remove nan values
nans = isnan(lat+lon+u+v+z);
lat(nans) = [];
lon(nans) = [];
z(nans)   = [];
u(nans)   = [];
v(nans)   = [];

[angle,scale] = cart2pol(u,v);
scale = scale/40000000*360*OPT.arrowScale;

% Calculate polar cooradinates of template arrow
[A.ang( 1),A.abs( 1)] = cart2pol(      0,       0);
[A.ang( 2),A.abs( 2)] = cart2pol(-OPT.L4,  OPT.W4);
[A.ang( 3),A.abs( 3)] = cart2pol( OPT.L1,  OPT.W1);
[A.ang( 4),A.abs( 4)] = cart2pol( OPT.L3,  OPT.W3);
[A.ang( 5),A.abs( 5)] = cart2pol( OPT.L2,  OPT.W2);
[A.ang( 6),A.abs( 6)] = cart2pol(      1,       0); % symmetry point
[A.ang( 7),A.abs( 7)] = cart2pol( OPT.L2, -OPT.W2);
[A.ang( 8),A.abs( 8)] = cart2pol( OPT.L3, -OPT.W3);
[A.ang( 9),A.abs( 9)] = cart2pol( OPT.L1, -OPT.W1);
[A.ang(10),A.abs(10)] = cart2pol(-OPT.L4, -OPT.W4);

% Filter out points which are on the same location;
dubblePoints = [false diff(A.ang) == 0 & diff(A.abs) == 0];
A.ang(dubblePoints) = [];
A.abs(dubblePoints) = [];

% Duplicate startpoint to close poly;
A.ang(end+1) = A.ang(1);
A.abs(end+1) = A.abs(1);

% Calculate polar coordinates of individual arrows
for i=1:length(A.abs)
    A.ABS(i,:) = scale*A.abs(i);
    A.ANG(i,:) = angle+A.ang(i);
end

arrowLat =   repmat(lat,length(A.abs),1)+A.ABS.*cos(A.ANG);
arrowZ   =   repmat(z  ,length(A.abs),1);
arrowLon =   repmat(lon,length(A.abs),1)+A.ABS.*sin(A.ANG)...
     ./repmat(cosd(lat),length(A.abs),1); % d_longitudes squeeze to zero as we move latitudeward (i.e. as we near the north pole)
arrowLon = mod(arrowLon+180, 360)-180;

%% get filename
if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz',...
        'Zipped KML file'},'Save as','quiver.kml');
    OPT.fileName = fullfile(filePath,fileName);
end

%% start KML
OPT.fid=fopen(OPT.fileName,'w');

%% HEADER
output = KML_header(OPT);

%% LINESTYLE
OPT_style = struct(...
    'name'      ,['arrowline' num2str(1)],...
    'lineColor' ,OPT.lineColor(1,:),...
    'lineAlpha' ,OPT.lineAlpha(1),...
    'lineWidth' ,OPT.lineWidth(1));
output = [output KML_style(OPT_style)];

% if multiple styles are define, generate them
if length(OPT.lineColor(:,1))+length(OPT.lineWidth)+length(OPT.lineAlpha)>3
    for ii = 2:length(lat(1,:))
        OPT_style.name = ['arrowline' num2str(ii)];
        if length(OPT.lineColor(:,1))>1
            OPT_style.lineColor = OPT.lineColor(ii,:);
        end
        if length(OPT.lineWidth(:,1))>1
            OPT_style.lineWidth = OPT.lineWidth(ii);
        end
        if length(OPT.lineAlpha(:,1))>1
            OPT_style.lineAlpha = OPT.lineAlpha(ii);
        end
        output = [output KML_style(OPT_style)];
    end
end

%% POLYSTYLE

if OPT.arrowFill
    OPT_stylePoly = struct(...
        'name'       ,['arrowfill' num2str(1)],...
        'fillColor'  ,OPT.fillColor(1,:),...
        'fillAlpha'  ,OPT.fillAlpha(1,:),...
        'lineColor'  ,[0 0 0],...
        'lineAlpha'  ,0,...
        'lineWidth'  ,0,...
        'polyFill'   ,1,...
        'polyOutline',0);
    output = [output KML_stylePoly(OPT_stylePoly)];
end

% if multiple styles are define, generate them
if length(OPT.fillColor(:,1))+length(OPT.fillAlpha)>2
    for ii = 2:length(lat(1,:))
        OPT_stylePoly.name = ['arrowfill' num2str(ii)];
        if length(OPT.fillColor(:,1))>1
            OPT_stylePoly.fillColor = OPT.fillColor(ii,:);
        end
        if length(OPT.fillAlpha(:,1))>1
            OPT_stylePoly.fillAlpha = OPT.fillAlpha(ii);
        end
        output = [output KML_stylePoly(OPT_stylePoly)];
    end
end

%% print output
fprintf(OPT.fid,output);

%% ARROWS
OPT_line = struct(...
          'name','',...
     'styleName',['arrowline' num2str(1)],...
        'timeIn',[],...
       'timeOut',[],...
    'visibility',OPT.visible,...
       'extrude',0);

if OPT.arrowFill
    OPT_poly = struct(...
          'name','',...
     'styleName',['arrowfill' num2str(1)],...
        'timeIn',[],...
       'timeOut',[],...
    'visibility',OPT.visible,...
       'extrude',0);
end

% preallocate output
output = repmat(char(1),1,1e5);
kk = 1;
for ii=1:length(lat(1,:))
    
    % assign different styles if needed
    if length(OPT.lineColor(:,1))+length(OPT.lineWidth)+length(OPT.lineAlpha)>3
        OPT_line.styleName = ['arrowline' num2str(ii)];
    end
    if isempty(OPT.timeIn) ,OPT_line.timeIn  = [];else OPT_line.timeIn  = datestr(OPT.timeIn(ii) ,OPT.dateStrStyle); end
    if isempty(OPT.timeOut),OPT_line.timeOut = [];else OPT_line.timeOut = datestr(OPT.timeOut(ii),OPT.dateStrStyle); end
    
    newOutput = KML_line(arrowLat(:,ii),arrowLon(:,ii),arrowZ(:,ii),OPT_line);
    
    if OPT.arrowFill
        % assign different styles if needed
        if length(OPT.fillColor(:,1))+length(OPT.fillAlpha)>2
            OPT_poly.styleName = ['arrowfill' num2str(ii)];
        end
        
        if isempty(OPT.timeIn) ,OPT_poly.timeIn  = [];else OPT_poly.timeIn  = datestr(OPT.timeIn(ii) ,OPT.dateStrStyle); end
        if isempty(OPT.timeOut),OPT_poly.timeOut = [];else OPT_poly.timeOut = datestr(OPT.timeOut(ii),OPT.dateStrStyle); end
        
        newOutput = [newOutput...
            KML_poly(arrowLat(:,ii),arrowLon(:,ii),arrowZ(:,ii),OPT_poly)];
    end
    output(kk:kk+length(newOutput)-1) = newOutput;
    kk = kk+length(newOutput);
    if kk>1e5
        %then print and reset
        fprintf(OPT.fid,output(1:kk-1));
        kk = 1;
        output = repmat(char(1),1,1e5);
    end
end
fprintf(OPT.fid,output(1:kk-1)); % print output
%% FOOTER
output = KML_footer;
fprintf(OPT.fid,output);
%% close KML
fclose(OPT.fid);
%% compress to kmz?
if strcmpi(OPT.fileName(end),'z')
    movefile(OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
    zip(OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
    movefile([OPT.fileName '.zip'],OPT.fileName)
    delete([OPT.fileName(1:end-3) 'kml'])
end
%% openInGoogle?
if OPT.openInGE
    system(OPT.fileName);
end