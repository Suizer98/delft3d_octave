function [KMLdata]=ITHK_KMLicons(x,y,class,icons,offset,sens,popuptxt)
% ITHK_KMLicons(x,y,class,icons,offset,sens)
%
% creates kml-txt for a pop-up at the specified x,y location.
% 
% coordinates (lat,lon) are in decimal degrees. 
%   LON is converted to a value in the range -180..180)
%   LAT must be in the range -90..90
%
% be aware that GE draws the shortest possible connection between two 
% points, when crossing the null meridian.
%
% The kml code (without header/footer) is written to the S structure 

%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares for Building with Nature
%       Bas Huisman
%
%       Bas.Huisman@deltares.nl	
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

% $Id: ITHK_KMLicons.m 11018 2014-07-31 15:20:51Z boer_we $
% $Date: 2014-07-31 23:20:51 +0800 (Thu, 31 Jul 2014) $
% $Author: boer_we $
% $Revision: 11018 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/operations/ITHK_KMLicons.m $
% $Keywords: $

fprintf('ITHK postprocessing : Generating KMLicons [');

global S

if nargin<6
sens=1;
end
if nargin<7
popuptxt = [];
end

%% Find the full path of the icons specified in the xml-file
iconfiles = struct;
for kk=1:length(icons.class)
    iconclass(kk)      = str2double(icons.class{kk});
    if isfield(S,'weburl')
        iconfiles(kk).url  = strtrim(icons.url{kk});
    else
        iconfiles(kk).url  = which(strtrim(icons.url{kk}));
    end
end

%% time related parameters
tvec            = S.PP(sens).settings.tvec;
tvec(length(tvec)+1)=round(2*tvec(end)-tvec(end-1));
t0              = S.PP(sens).settings.t0;

%% get smoothed orientation of the coast + smoothed offset of coastline
dx         = x(2:end)-x(1:end-1);
dy         = y(2:end)-y(1:end-1);
alpha      = atan2(dy,dx)'; %*180/pi()
alpha      = [alpha(1);(alpha(1:end-1)+alpha(2:end))/2;alpha(end)];
[alpha]    = ITHK_smoothvariable(alpha,100);
x1         = x'-offset*sin(alpha);           %*cos(alpha-pi()/2);  
y1         = y'+offset*cos(alpha);           %+offset*sin(alpha-pi()/2);

%% get KML text string
IDii = round([1:(length(x1)-1)/9:length(x1)]);
KMLdata=[];lookAt=1;
for ii=1:length(x1)
    [lon,lat] = convertCoordinates(x1(ii),y1(ii),S.EPSG,'CS1.code',str2double(S.settings.EPSGcode),'CS2.name','WGS 84','CS2.type','geo');
    KMLdata2=[];
    
    %% add pop-up text with name of indicator
    if ~isempty(popuptxt) && ii==1
        time1         = datenum(tvec(1)+t0,1,1);
        time2         = datenum(tvec(end)+t0-1/365/24/60/60,1,1);
        if isstr(popuptxt{2});popuptxt{2}={popuptxt{2}};end
        KMLdata2     = [KMLdata2,ITHK_KMLtextballoon(lon,lat,'name',popuptxt{1},'text_array',popuptxt{2},'logo','','timeIn',time1,'timeOut',time2,'lookAt',lookAt)];
        lookAt=0;
    end
    
    %% add indicator icons in time and space
    for jj = 1:length(S.PP(sens).settings.tvec)
        time1         = datenum(tvec(jj)+t0,1,1);
        time2         = datenum(tvec(jj+1)+t0-1/365/24/60/60,1,1);
        % dunes to KML  
        OPT.icon = iconfiles(iconclass==class(ii,jj)).url; %id = find(iconclass==class(ii,jj));OPT.icon = icons(id).url; fprintf('%s  =  %s\n',icons(id).url(end-20:end),OPT.icon(end-20:end))
        if isempty(strfind('OPT.icon','_no.png'))
        KMLdata2 = [KMLdata2 ITHK_KMLtextballoon(lon,lat,'icon',OPT.icon,'timeIn',time1,'timeOut',time2,'lookAt',lookAt)];
        end
    end
    KMLdata = [KMLdata KMLdata2];

    if max(IDii==ii)==1
    fprintf('#');
    end
end
fprintf(']\n');