function varargout = KMLanimatedIcon(lat,lon,varargin)
%KMLANIMATEDICON  adds place markers with color varying in time
%
%   KMLanimatedIcon(lat,lon,c,<keyword,value>)
%
% where - amongst others - the following <keyword,value> pairs have been implemented:
%
%  * filename           = []; % file name
%  * kmlname            = []; % name that appears in Google Earth places list
%  * colorMap           = colormap (default @(m) jet(m));
%  * colorSteps         = number of colors in colormap (default 20);
%  * cLim               = cLim aka caxis (default [min(c) max(c)]);
%  * long_name          = ''; used for point description ... (default 'value=')
%  * units              = ''; 'long_name = x units'
%  * OPT.timeIn         = [];
%  * OPT.timeOut        = [];
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLanimatedIcon()
%
% See also: GOOGLEPLOT, KMLscatter, KMLtext, KMLmarker

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: KMLanimatedIcon.m 9848 2013-12-07 12:33:27Z boer_g $
% $Date: 2013-12-07 20:33:27 +0800 (Sat, 07 Dec 2013) $
% $Author: boer_g $
% $Revision: 9848 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLanimatedIcon.m $
% $Keywords: $

%% process options

   % get colorbar options first
   OPT                     = KMLcolorbar();
   OPT                     = mergestructs(OPT,KML_header());

   OPT.fileName           = [];
   OPT.kmlName            = [];
   OPT.colorMap           = @(m) jet(m);
   OPT.colorSteps         = 20;
   OPT.cLim               = [];
   OPT.openInGE           = 0;
   OPT.markerAlpha        = 1;
   OPT.description        = '';
   OPT.colorbar           = 1;
   OPT.colorbarlocation   = {'W'}; %{'N','E','S','W'}; %{'N','NNE','ENE','E','ESE','SSE','S','SSW','WSW','W','WNW','NNW'};
   OPT.colorbartitle      = '';

   OPT.icon               = 'http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png';
   OPT.iconHotspot         = ''; %<hotSpot x="0.5"  y="0.5" xunits="fraction" yunits="fraction"/>
   OPT.scale              = 1.0;
   OPT.timeIn             = [];
   OPT.timeOut            = [];
   OPT.dateStrStyle       = 29; % set to yyyy-mm-ddTHH:MM:SS for detailed times
   
   OPT.balloonStyle       = '';
   
if ~isempty(varargin)
    if ~ischar(varargin{1})
        c                  = varargin{1};
        varargin           = varargin(2:end);
        OPT.coloredIcon    = true;
    else
        OPT.coloredIcon    = false;
    end
else
    OPT.coloredIcon    = false;
end

if nargin==0
    varargout = {OPT};
    return
end

[OPT, Set, Default] = setproperty(OPT, varargin);

%% get filename, gui for filename, if not set yet

if isempty(OPT.fileName)
      [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
    OPT.fileName = fullfile(filePath,fileName);
end

%% set kmlName if it is not set yet
if isempty(OPT.kmlName)
    [ignore OPT.kmlName] = fileparts(OPT.fileName);
end

if ~isempty(OPT.balloonStyle)
    OPT.balloonStyle = ['<BalloonStyle>' OPT.balloonStyle '</BalloonStyle>'];
end

%% if colordata is defined, color the icon
if OPT.coloredIcon
    % set cLim
    
    if isempty(OPT.cLim)
        OPT.cLim         = [min(c(:)) max(c(:))];
    end
    
    if isnumeric(OPT.colorMap)
        OPT.colorSteps = size(OPT.colorMap,1);
    end
    
    %% pre-process data
    %  make 1D and remove NaNs
    
    if length(c)==1
        c = repmat( c,size(lon));
    elseif ~length(c)==length(lon)
        error('c should have length 1 or have same size as lon')
    end
    
    lon    = lon(~isnan(c(:)));
    lat    = lat(~isnan(c(:)));
    c      =   c(~isnan(c(:)));
    
    if isnumeric(OPT.colorMap)
        OPT.colorSteps = size(OPT.colorMap,1);
    end
    
    if isa(OPT.colorMap,'function_handle')
        colorRGB           = OPT.colorMap(OPT.colorSteps);
    elseif isnumeric(OPT.colorMap)
        if size(OPT.colorMap,1)==1
            colorRGB         = repmat(OPT.colorMap,[OPT.colorSteps 1]);
        elseif size(OPT.colorMap,1)==OPT.colorSteps
            colorRGB         = OPT.colorMap;
        else
            error(['size ''colorMap'' (=',num2str(size(OPT.colorMap,1)),') does not match ''colorSteps''  (=',num2str(OPT.colorSteps),')'])
        end
    end
    
end
%% start KML

OPT.fid=fopen(OPT.fileName,'w');

%% HEADER

output = KML_header(OPT);

output = [output '<!--############################-->\n'];

%% STYLE
if OPT.coloredIcon

    if OPT.colorbar
      clrbarstring = KMLcolorbar('CBcLim',OPT.cLim,'CBfileName',OPT.fileName,'CBcolorMap',colorRGB,'CBcolorTitle',OPT.colorbartitle);
      output = [output clrbarstring];
    end

    for ii = 1:OPT.colorSteps

    temp                = dec2hex(round([OPT.markerAlpha, colorRGB(ii,:)].*255),2);
    markerColor         = [temp(1,:) temp(4,:) temp(3,:) temp(2,:)];

    output = [output ...
        '<Style id="Marker_',num2str(ii,'%0.3d'),'">\n'...
        OPT.balloonStyle...
        ' <IconStyle>\n'...
        ' <color>' markerColor '</color>\n'...
        ' <scale>' num2str(OPT.scale) '</scale>\n'...
        ' <Icon><href>' OPT.icon '</href></Icon>\n'...
        OPT.iconHotspot...
        ' </IconStyle>\n'...
        ' </Style>\n'];
    end
else
     output = [output ...
        '<Style id="Marker">\n'...
        OPT.balloonStyle...
        ' <IconStyle>\n'...
        ' <scale>' num2str(OPT.scale) '</scale>\n'...
        ' <Icon><href>' OPT.icon '</href></Icon>\n'...
        ' </IconStyle>\n'...
        ' </Style>\n'];
end

%% print and clear output

output = [output '<!--############################-->\n'];
fprintf(OPT.fid,output);
output = repmat(char(1),1,1e5);
kk = 1;

%% Plot the points

for ii=1:length(lon)
    if OPT.coloredIcon
        % convert color values into colorRGB index values
        cindex = round(((c(ii)-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1);
        cindex = min(cindex,OPT.colorSteps);
        cindex = max(cindex,1); % style numbering is 1-based

        styleName = ['Marker_',num2str(cindex,'%0.3d')];
    else
        styleName = 'Marker';
    end
    % define time
    
    %% preproces timespan
    if  ~isempty(OPT.timeIn)
        if length(OPT.timeIn)>1
            tt = ii;
        else
            tt = 1;
        end
        if ~isempty(OPT.timeOut)
            timeSpan = sprintf([...
                '<TimeSpan>\n'...
                '<begin>%s</begin>\n'...OPT.timeIn
                '<end>%s</end>\n'...OPT.timeOut
                '</TimeSpan>\n'],...
                datestr(OPT.timeIn (tt),OPT.dateStrStyle),...
                datestr(OPT.timeOut(tt),OPT.dateStrStyle));
        else
            timeSpan = sprintf([...
                '<TimeStamp>\n'...
                '<when>%s</when>\n'...OPT.timeIn
                '</TimeStamp>\n'],...
                datestr(OPT.timeIn (tt),OPT.dateStrStyle));
        end
    else
        timeSpan ='';
    end
    
      
    newOutput= sprintf([...
        '<Placemark>\n'...     
        ' <styleUrl>#%s</styleUrl>\n'...               % styleName
        ' %s'...                                       % timeSpan
        ' <Point><coordinates>% 2.8f,% 2.8f, 0</coordinates></Point>\n'... % coordinates
        ' </Placemark>\n'],...
        styleName,timeSpan,...
        lon(ii),lat(ii));

    % add newOutput to output
    output(kk:kk+length(newOutput)-1) = newOutput;
    kk = kk+length(newOutput);

    % write output to file if output is full, and reset
    if kk>1e5
        fprintf(OPT.fid,'%s',output(1:kk-1));
        kk = 1;
        output = repmat(char(1),1,1e5);
    end

end

%% print and clear output

% print output
fprintf(OPT.fid,'%s',output(1:kk-1));

%% FOOTER

output = KML_footer;
fprintf(OPT.fid,output);

%% close KML

fclose(OPT.fid);

%% compress to kmz and include image files

   if strcmpi  ( OPT.fileName(end-2:end),'kmz')
      movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
      if OPT.colorbar
          files = [{[OPT.fileName(1:end-3) 'kml']},pngNames];
      else
          files =  {[OPT.fileName(1:end-3) 'kml']};
      end
      zip     ( OPT.fileName,files);
      for ii = 1:length(files)
          delete  (files{ii})
      end
      movefile([OPT.fileName '.zip'],OPT.fileName)
   end

%% openInGoogle?

if OPT.openInGE
    system(OPT.fileName);
end

%% Output

if nargout==1
    varargout = {handles};
end

%% EOF

