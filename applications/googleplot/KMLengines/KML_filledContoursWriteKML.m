function KML_filledContoursWriteKML(OPT,lat,lon,z,latC,lonC,zC,contour)
%KML_FILLEDCONTOURSWRITEKML  subsidiary of KMLcontourf
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = KML_filledContoursWriteKML(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   KML_filledContoursWriteKML
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Thijs
%
%       <EMAIL>
%
%       <ADDRESS>
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
% Created: 21 Apr 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: KML_filledContoursWriteKML.m 4894 2011-07-21 20:47:45Z boer_g $
% $Date: 2011-07-22 04:47:45 +0800 (Fri, 22 Jul 2011) $
% $Author: boer_g $
% $Revision: 4894 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLengines/KML_filledContoursWriteKML.m $
% $Keywords: $

%% get filename, gui for filename, if not set yet

if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
    OPT.fileName = fullfile(filePath,fileName);
end

%% set kmlName if it is not set yet

if isempty(OPT.kmlName)
    [dummy, OPT.kmlName] = fileparts(OPT.fileName); %#ok<ASGLU>
end

%% make all contour lines counterclockwise
for ii=1:size(latC,2)
    if poly_isclockwise(lonC(~isnan(lonC(:,ii)),ii),latC(~isnan(lonC(:,ii)),ii))
        endOfContour = find(~isnan(latC(:,ii)),1,'last');
        latC(1:endOfContour,ii) = latC(endOfContour:-1:1,ii);
        lonC(1:endOfContour,ii) = lonC(endOfContour:-1:1,ii);
        zC  (1:endOfContour,ii) = zC  (endOfContour:-1:1,ii);
    end
end

%% pre-process color data

if isempty(OPT.cLim)
    OPT.cLim         = [min(zC(:)) max(zC(:))];
end

colorRGB = OPT.colorMap(OPT.colorSteps);

% determine the area's of the different polygons
contour.area = nan(1,contour.n);
for ii=1:contour.n
    contour.area(ii) = polyarea(lonC(~isnan(latC(:,ii)),ii),latC(~isnan(latC(:,ii)),ii));
end

% [dummy,outerPoly] = max(contour.area);
mm = 0;
for outerPoly = 1:contour.n
    % OuterPoly is the outer boundary.
    
    % find the largest loop that is contained by that loop
    % polygons that form the inner boundaries
    innerPoly = [];
    % only check inpolygon for the first point of a polygon
    [inOuterPoly, onOuterPoly] = inpolygon(latC(1,:),lonC(1,:),...
        latC(~isnan(latC(:,outerPoly)),outerPoly),...
        lonC(~isnan(latC(:,outerPoly)),outerPoly));
    % if a line point is *on* the outerPoly, it is not *in* it.
    inOuterPoly(onOuterPoly) = false; % OuterPoly is not in OuterPoly
    
    % check if there are polygons inside the outer poly, but not in one of the
    % inner polygons
    inOuterPoly = find(inOuterPoly);
    
    while ~isempty(inOuterPoly)
        for ii = innerPoly
            % remove self
            inOuterPoly(inOuterPoly==ii)=[];
            
            % find polygons inside the outer poly and in this innerPoly
            inInnerPoly  = inpolygon(latC(1,inOuterPoly),lonC(1,inOuterPoly),...
                latC(~isnan(latC(:,ii)),ii),...
                lonC(~isnan(latC(:,ii)),ii));
            
            % remove those the polygons from inOuterPoly
            inOuterPoly(inInnerPoly)=[];
        end
        
        if ~isempty(inOuterPoly)
            [dummy,ii] = max(contour.area(inOuterPoly)); %#ok<ASGLU>
            innerPoly(end+1) = inOuterPoly(ii); %#ok<AGROW>
        end
    end
    mm = mm+1;
    D(mm).outerPoly = outerPoly; %#ok<AGROW>
    D(mm).innerPoly = innerPoly; %#ok<AGROW>
end

contour.colorLevel = nan(size(contour.level));

% set level to the minimum level of inner and outer polygon
contour.min = nan(size(1,contour.n));
contour.max = nan(size(1,contour.n));
z1          = nan(size(1,contour.n));
for ii = 1:contour.n
    contour.min(ii) = min(min(zC(:,[D(ii).outerPoly D(ii).innerPoly])));
    contour.max(ii) = max(max(zC(:,[D(ii).outerPoly D(ii).innerPoly])));
end

OPT.levels = [(2*OPT.levels(1) - OPT.levels(2)) OPT.levels];

for ii = 1:contour.n
    if contour.min(ii)~=contour.max(ii)
        z1(ii) = find(OPT.levels<contour.max(ii),1,'last');
    else
        kk = 0;
        
        % Find the 5 points nearest to the first point of the polygon
        [dummy,ind] = sort((lat - latC(1,D(ii).outerPoly)).^2+(lon - lonC(1,D(ii).outerPoly)).^2);
        in = inpolygon(lat(ind(1:5)),lon(ind(1:5)),latC(:,D(ii).outerPoly),lonC(:,D(ii).outerPoly));
        if ~any(in)
            in = inpolygon(lat(ind(:)),lon(ind(:)),latC(:,D(ii).outerPoly),lonC(:,D(ii).outerPoly));
        end
        if  max(z(ind(in)))>contour.max(ii)
            kk = 0;
        else
            kk = -1;
        end
        z1(ii) = find(OPT.levels>=contour.max(ii),1,'first')+kk;
    end
end
if ~isfield(OPT,'colorLevels')|isempty(OPT.colorLevels)
    OPT.colorLevels = linspace(OPT.cLim(1),OPT.cLim(2),OPT.colorSteps);
end
[dummy,ind] = min(abs(repmat(OPT.colorLevels,length(OPT.levels),1) - repmat(OPT.levels',1,length(OPT.colorLevels))),[],2); %#ok<ASGLU>

c = ind(z1);


%% start KML

OPT.fid=fopen(OPT.fileName,'w');

OPT_header = struct(...
    'name',OPT.kmlName,...
    'open',0);
output = KML_header(OPT_header);

if OPT.colorbar
    clrbarstring = KMLcolorbar(OPT);
    output = [output clrbarstring];
end

%% STYLE

OPT_stylePoly = struct(...
    'name'       ,['style' num2str(1)],...
    'fillColor'  ,colorRGB(1,:),...
    'lineColor'  ,OPT.lineColor,...
    'lineAlpha'  ,OPT.lineAlpha,...
    'lineWidth'  ,OPT.lineWidth,...
    'fillAlpha'  ,OPT.fillAlpha,...
    'polyFill'   ,OPT.polyFill,...
    'polyOutline',OPT.polyOutline);
for ii = unique(c)'
    OPT_stylePoly.name = ['style' num2str(ii)];
    OPT_stylePoly.fillColor = colorRGB(ii,:);
    output = [output KML_stylePoly(OPT_stylePoly)]; %#ok<AGROW>
end

% print and clear output

output = [output '<!--############################-->' fprinteol];
fprintf(OPT.fid,output);

%% POLYGON

OPT_poly = struct(...
    'name','',...
    'styleName',['style' num2str(1)],...
    'timeIn' ,[datestr(OPT.timeIn ,'yyyy-mm-ddTHH:MM:SSZ')],...
    'timeOut',[datestr(OPT.timeOut,'yyyy-mm-ddTHH:MM:SSZ')],...
    'visibility',1,...
    'extrude',OPT.extrude);

% preallocate output

output = repmat(char(1),1,1e5);
kk = 1;

for ii=1:mm
    OPT_poly.styleName = sprintf('style%d',c(ii));
    
    x1 =  latC(:,[D(ii).outerPoly D(ii).innerPoly]);
    y1 =  lonC(:,[D(ii).outerPoly D(ii).innerPoly]);
    if OPT.is3D
        if OPT.staggered
            z2 = repmat(OPT.levels(z1(ii)),size(x1,1),size(x1,2));
            z2 = OPT.zScaleFun(z2);
        else
            z2 = zC(:,[D(ii).outerPoly D(ii).innerPoly]);
            z2 = OPT.zScaleFun(z2);
        end
    else
        z2 = 'clampToGround';
    end
    newOutput = KML_poly(x1,y1,z2,OPT_poly);
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

%% close KML

output = KML_footer;
fprintf(OPT.fid,output);
fclose(OPT.fid);

%% compress to kmz?

if strcmpi  ( OPT.fileName(end-2:end),'kmz')
    movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
    zip     ( OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
    movefile([OPT.fileName '.zip'],OPT.fileName)
    delete  ([OPT.fileName(1:end-3) 'kml'])
end

%% openInGoogle?
if OPT.openInGE
    system(OPT.fileName);
end

%% EOF
