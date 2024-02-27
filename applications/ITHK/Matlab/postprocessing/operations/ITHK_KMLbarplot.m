function [KMLdata]=ITHK_KMLbarplot(x,y,z,offset,sens,colour,fillalpha,vectorscale,popuptxt,outlineVAL)
% function ITHK_KMLbarplot(x,y,z,offset,sens)
%
% Creates a datafield for barplots that is later on used to generate the KML file
% 
% INPUT:
%      x            x-coordinate
%      y            y-coordinate
%      z            cross-shore position of the shoreline w.r.t. the initial shoreline (at t0)
%      offset       location of the bar plot in the viewer w.r.t. shoreline (in meters from current shoreline)
%      sens         sensitivity run number
%      colour       cell with two colours (for negative and postive values respectively) (default = {[1 0 0],[0 1 0]})
%      fillalpha    transparency setting (default = 0.7)
%      vectorscale  scaling factor for length of vector (default = S.settings.plotting.barplot.barscalevector)
%      popuptxt     cell string with name of indicator and text for pop-up 
%                   at start of line (e.g. popuptxt = {'inidcator name', 'Description of indicator ...'})
%      outlineVAL   Value at which outline is plotted (outline not used if not specified)
%      S            structure with ITHK data (global variable that is automatically used)
%                    .PP(sens).settings.tvec
%                    .PP(sens).settings.t0
%                    .PP(sens).settings.sgridRough
%                    .PP(sens).settings.sVectorLength
%                    .PP(sens).settings.widthRough
%                    .PP(sens).output.kml
%                    .EPSG
%
% OUTPUT:
%      S            structure with ITHK data (global variable that is automatically used)
%                    .PP(sens).output.kml
%

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 <COMPANY>
%       ir. Bas Huisman
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 18 Jun 2012
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: ITHK_KMLbarplot.m 10805 2014-06-04 08:10:15Z boer_we $
% $Date: 2014-06-04 16:10:15 +0800 (Wed, 04 Jun 2014) $
% $Author: boer_we $
% $Revision: 10805 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/operations/ITHK_KMLbarplot.m $
% $Keywords: $

%% code

fprintf('ITHK postprocessing : Generating KMLbarplots [');

global S

if nargin<6
colour={[0 1 0],[1 0 0]};
end
if nargin<7
fillalpha=0.7;
end
if nargin<8
vectorscale = S.settings.plotting.barplot.barscalevector;
end
if nargin<9
popuptxt = {'Coastline','Coastline development in time.'};
end
if nargin<10
outlineVAL=[];
end
if nargin<11
plotLABELS=[];
end

% initial values, constants and standard KML-textblocks
KMLdata              = [];
if ischar(offset);offset = str2double(offset);end
if ischar(vectorscale);vectorscale=str2double(vectorscale);end
barstyle1            = KML_stylePoly('name','default','fillColor',colour{1},'lineColor',[0 0 0],'lineWidth',0.5,'fillAlpha',fillalpha); % red bar style
barstyle2            = KML_stylePoly('name','default','fillColor',colour{2},'lineColor',[0 0 0],'lineWidth',0.5,'fillAlpha',fillalpha); % green bar style
barstyle3            = KML_stylePoly('name','default','lineColor',[0.8 0.8 0.8],'lineWidth',0.5,'polyFill',0); % outline of area of bar

%% time related parameters
tvec                 = S.PP(sens).settings.tvec;
tvec(length(tvec)+1) =round(2*tvec(end)-tvec(end-1));
t0                   = S.PP(sens).settings.t0;
time1a               = datenum(tvec(1)+t0,1,1);
time2a               = datenum(tvec(end)+t0-1/365/24/60/60,1,1);

%% get smoothed orientation of the coast + smoothed offset of coastline
dx                   = x(2:end)-x(1:end-1);
dy                   = y(2:end)-y(1:end-1);
alpha                = atan2(dy,dx)'; %*180/pi()
alpha                = mod(alpha+2*pi,2*pi);
alpha                = [alpha(1);(alpha(1:end-1)+alpha(2:end))/2;alpha(end)];
[alpha]              = ITHK_smoothvariable(alpha,100);
x1                   = x'-offset*sin(alpha);
y1                   = y'+offset*cos(alpha);

%% add reference line at 'offset' value
dist                 = distXY(x1,y1);
distref              = [dist(1):min(diff(dist))/5:dist(end)];
x1ref                = interp1(dist,x1,distref,'pchip','extrap');
y1ref                = interp1(dist,y1,distref,'pchip','extrap');
[lonref,latref]      = convertCoordinates(x1ref,y1ref,S.EPSG,'CS1.code',str2double(S.settings.EPSGcode),'CS2.name','WGS 84','CS2.type','geo');
KMLdata              = [KMLdata ITHK_KMLline(latref,lonref,'timeIn',time1a,'timeOut',time2a,'lineColor',[0.3 0.3 0.3],'lineWidth',3,'lineAlpha',.8,'writefile',0)];

%% loop over time
IDjj = round([1:(length(tvec)-2)/9:length(tvec)-1]);
for jj = 1:length(S.PP(sens).settings.tvec)
    time1            = datenum(tvec(jj)+t0,1,1);
    time2            = datenum(tvec(jj+1)+t0-1/365/24/60/60,1,1);

    % get x,y coordinates of base point of bars (x1,y1) and z-value in xy coordinates (xtip,ytip)
    % construct x,y coordinates of bars on the basis of x1, xtip and barwidth (five coordinates specifying a rectangle for each bar)
    % convert coordinates to lat-lon
    [latpoly,lonpoly]=getLatLon(x1,y1,z(:,jj),vectorscale,alpha,S.PP(sens).settings.widthRough,S.EPSG);
    
    %% add pop-up window
    KMLdata2         = [];
    if ~isempty(popuptxt) && jj==1
        if isstr(popuptxt{2});popuptxt{2}={popuptxt{2}};end
        KMLdata2     = [KMLdata2,ITHK_KMLtextballoon(lonpoly(1),latpoly(1),'name',popuptxt{1},'text_array',popuptxt{2},'logo','','timeIn',time1a,'timeOut',time2a)];
    end
    
    %% construct KMLdata
    IDneg            = find(z(:,jj)<0); % red
    IDpos            = find(z(:,jj)>=0);
    for ii=1:length(IDpos) %length(S.PP(sens).settings.sgridRough)
        KMLdata2     = [KMLdata2,barstyle1];
        KMLdata2     = [KMLdata2 KMLpolytext(time1,time2,latpoly(:,IDpos(ii)),lonpoly(:,IDpos(ii)))];
    end
    for ii=1:length(IDneg) %length(S.PP(sens).settings.sgridRough)
        KMLdata2     = [KMLdata2,barstyle2];
        KMLdata2     = [KMLdata2 KMLpolytext(time1,time2,latpoly(:,IDneg(ii)),lonpoly(:,IDneg(ii)))];
    end
    KMLdata = [KMLdata KMLdata2];

    if max(IDjj==jj)==1
    fprintf('#');
    end
end

%% add empty outline of bar as a reference (if wanted)
if ~isempty(outlineVAL)
    [latpoly,lonpoly]=getLatLon(x1,y1,repmat(outlineVAL,size(x1)),vectorscale,alpha,S.PP(sens).settings.widthRough,S.EPSG);
    time1            = datenum(tvec(1)+t0,1,1);
    for ii=1:length(x1) 
        KMLdata      = [KMLdata,barstyle3];
        KMLdata      = [KMLdata KMLpolytext(time1,time2,latpoly(:,ii),lonpoly(:,ii))];
    end
end
fprintf(']\n');

end
%% END OF MAIN FUNCTION



%% sub-function
function [latpoly,lonpoly]=getLatLon(x1,y1,zval,vectorscale,alpha,widthRough,EPSG)
    global S

% get x,y coordinates of base point of bars (x1,y1) and z-value in xy coordinates (xtip,ytip)
    xtip         = x1-zval.*vectorscale.*sin(alpha);
    ytip         = y1+zval.*vectorscale.*cos(alpha);
       
    %% construct x,y coordinates of bars on the basis of x1, xtip and barwidth (five coordinates specifying a rectangle for each bar)
    dxbar        = 0.5*widthRough*cos(alpha);
    dybar        = 0.5*widthRough*sin(alpha);
    xpoly        = [x1+dxbar, xtip+dxbar, xtip-dxbar, x1-dxbar, x1+dxbar];
    ypoly        = [y1+dybar, ytip+dybar, ytip-dybar, y1-dybar, y1+dybar];
    
    %% convert coordinates to lat-lon
    [lonpoly,latpoly] = convertCoordinates(xpoly,ypoly,EPSG,'CS1.code',str2double(S.settings.EPSGcode),'CS2.name','WGS 84','CS2.type','geo');
    lonpoly      = lonpoly';
    latpoly      = latpoly';
end


%% sub-function which generates KML code for each polygon
function [kmltxt]=KMLpolytext(time1,time2,lat,lon)
% <Placemark>
% <TimeSpan><begin>2005-01-01T00:00:00</begin><end>2005-12-31T00:00:00</end></TimeSpan><name>poly</name>
% <styleUrl>#default</styleUrl>
% <Polygon>
% <altitudeMode>clampToGround</altitudeMode>
% <outerBoundaryIs>
% <LinearRing>
% <coordinates>
% 4.58978161,52.50718724,0.000
% 4.58978161,52.50718724,0.000
% 4.58571435,52.49854962,0.000
% 4.58571435,52.49854962,0.000
% 4.58978161,52.50718724,0.000
% </coordinates>
% </LinearRing>
% </outerBoundaryIs>
% </Polygon>
% </Placemark>
    timetxt1 = [datestr(time1,'yyyy-mm-dd'),'T',datestr(time1,'HH:MM:SS')];  %2005-01-01T00:00:00
    timetxt2 = [datestr(time2,'yyyy-mm-dd'),'T',datestr(time2,'HH:MM:SS')];  %2005-12-31T00:00:00
    kmltxt   = ['<Placemark>' char(13) '<TimeSpan><begin>',timetxt1,'</begin><end>',timetxt2,'</end></TimeSpan><name>poly</name>' char(13) ...
               '<styleUrl>#default</styleUrl>' char(13) '<Polygon>' char(13) '<altitudeMode>clampToGround</altitudeMode>' char(13) ...
               '<outerBoundaryIs>' char(13) '<LinearRing>' char(13) '<coordinates>' char(13)];
    latlon   = [num2str(lon,'%10.8f') repmat(',',[5 1]) num2str(lat,'%11.8f') repmat([',0.000' char(13)],[5 1]) ]';
    S        = size(latlon);
    kmltxt   = [kmltxt reshape(latlon,[1 S(1)*S(2)])];  % this sentence replace the loop over the points ii below (which is much slower)
%     for ii=1:length(lon)
%         kmltxt = [kmltxt num2str(lon(ii),'%10.8f') ',' num2str(lat(ii),'%11.8f') ',0.000' char(13)];
%     end
    kmltxt   = [kmltxt,'</coordinates>' char(13) '</LinearRing>' char(13) '</outerBoundaryIs>' char(13) '</Polygon>' char(13) '</Placemark>' char(13)];
end
