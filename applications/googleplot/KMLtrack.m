function varargout = KMLtrack(lat,lon,z,time,varargin)
% KMLTRACK Usefull for plotting time/position logs
%
%    KMLtrack(lat,lon,z,time,<keyword,value>)
%
% creates a kml file of a lat/lon/time track
%
% z is either the same size as lat and lon, or a char string like
% 'clampToGround'
%
% coordinates (lat,lon) are in decimal degrees.
%   LON is converted to a value in the range -180..180)
%   LAT must be in the range -90..90
%
% be aware that GE draws the shortest possible connection between two
% points, when crossing the nul meridian
%
% The kml code (without header/footer) that is written to file
% 'fileName' can optionally be returned.
%
%    kmlcode = kmlline(lat,lon,<keyword,value>)
%
% The following see <keyword,value> pairs have been implemented:
%  'fileName'       name of output file, Can be either a *.kml or *.kmz
%                   or *.kmz (zipped *.kml) file. If not defined a gui pops up.
%                   (When 0 or fid = fopen(...) writing to file is skipped
%                   and optional <kmlcode> is returned without KML_header/KML_footer.)
%  'kmlName'        name of kml that shows in GE
%
%  The following line properties can each be defined as either a single
%  entry or an array with the same lenght as the number of (unique) styles
%  'style'      = ones(size(lat,2)); % must be of length of input lines
%  'lineWidth'  = 1;           % line width, can be a fraction
%  'lineColor'  = [0 0 0];     % color of the lines in RGB (0..1)
%  'lineAlpha'  = 1;           % transparency of the line
%
%  'openInGE'   = false;       % opens output directly in google earth
%  'description'= '';          %
%
%
% See also: googlePlot, plot, line

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

% $Id: KMLtrack.m 10841 2014-06-12 12:50:43Z scheel $
% $Date: 2014-06-12 20:50:43 +0800 (Thu, 12 Jun 2014) $
% $Author: scheel $
% $Revision: 10841 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLtrack.m $
% $Keywords: $

%% process <keyword,value>

OPT.fileName       = ''; % header/footer are skipped when is a fid = fopen(OPT.fileName,'w')
OPT.data           = [];
OPT.description    = '';
OPT.balloonStyle   = '';
OPT.extendedData   = '';
OPT.heading        = [];
OPT.kmlName        = [];
OPT.trackName      = [];
OPT.lineWidth      = 1;
OPT.lineColor      = [0 0 0];
OPT.lineAlpha      = 1;
OPT.icon           = 'http://maps.google.com/mapfiles/kml/shapes/track.png';
OPT.iconColor      = [];
OPT.iconScale      = 1;
OPT.hliconScale    = 1.2;
OPT.fill           = true;
OPT.fillColor      = [0 .5 0];
OPT.fillAlpha      = .4;
OPT.openInGE       = false;
OPT.timeIn         = [];
OPT.timeOut        = [];
OPT.LookAtLon      = [];
OPT.LookAtLat      = [];
OPT.LookAtAltitude = [];
OPT.LookAtrange    = [];
OPT.LookAttile     = [];
OPT.LookAtheading  = [];
OPT.dateStrStyle   = 'yyyy-mm-ddTHH:MM:SS';
OPT.visible        = true;
OPT.extrude        = true;
OPT.model          = '';
OPT.tessellate     = true;
OPT.zScaleFun      = @(z) (z+0)*1;
OPT.fid            = -1;
OPT.extrude        = 1;

if nargin==0
    varargout = {OPT};
    return
end

OPT = setproperty(OPT, varargin{:});

%% input check

% elevation (z)
is3D = ~ischar(z);

% check data field
addData = ~isempty(OPT.data);
if addData
    assert(isstruct(OPT.data),'Data must be a structure with fields ''value'' and ''name''')
    assert(isfield(OPT.data,'value'),'Data must be a structure with field ''value''')
    assert(isfield(OPT.data,'name') ,'Data must be a structure with field ''name''')
    % determine fields id and type
    [OPT.data.id]   = deal([]);
    [OPT.data.type] = deal('');
    for ii = 1:numel(OPT.data)
        OPT.data(ii)    = determineDataType(OPT.data(ii));
        OPT.data(ii).id = num2str(ii);
    end
end

if ~isempty(OPT.model)
    [model_path,model_name,model_ext] = fileparts(OPT.model);
end

% correct coordinates
if any((abs(lat)/90)>1)
    error('latitude out of range, must be within -90..90')
end
lon = mod(lon+180, 360)-180;

% make sure input is columnvector
if size(lat,1)==1
    lat = lat(:);
    lon = lon(:);
    time = time(:);
    OPT.data    = OPT.data(:);
    OPT.heading = OPT.heading(:);
    if is3D
        z = z(:);
    end
end

%% fix styles
%  first check is multiple line/fill styles are defined. If not, then it's
%  easy: there is only one style.
%  if so, then repeat each style for size(lat,2) (that's the number of lines
%  to draw), put them all in one matrix, and then define the unique
%  linestyles.

if numel(OPT.lineWidth) + numel(OPT.lineColor)+numel(OPT.lineAlpha) == 5
    % one linestyle; do nothing
    styles   = 1;
    style_nr = ones(size(lat,2),1);
else
    % multiple styles; expand input options to # of lines
    OPT.lineWidth = OPT.lineWidth(:);
    OPT.lineWidth = [repmat(OPT.lineWidth,floor(size(lat,2)/length(OPT.lineWidth)),1);...
        OPT.lineWidth(1:rem(size(lat,2),length(OPT.lineWidth)))];
    
    OPT.lineColor = [repmat(OPT.lineColor,floor(size(lat,2)/size(OPT.lineColor,1)),1);...
        OPT.lineColor(1:rem(size(lat,2),size(OPT.lineColor,1)),:)];
    
    OPT.lineAlpha = OPT.lineAlpha(:);
    OPT.lineAlpha = [repmat(OPT.lineAlpha,floor(size(lat,2)/length(OPT.lineAlpha)),1);...
        OPT.lineAlpha(1:rem(size(lat,2),length(OPT.lineAlpha)))];
    
    % find unique linestyles
    [~,styles,style_nr] = unique([OPT.lineWidth,OPT.lineColor,OPT.lineAlpha],'rows','stable');
end


%% get filename, gui for filename, if not set yet

if ischar(OPT.fileName) && isempty(OPT.fileName); % can be char ('', default) or fid
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
    OPT.fileName = fullfile(filePath,fileName);
    
    %% set kmlName if it is not set yet
    
    if isempty(OPT.kmlName)
        [~, OPT.kmlName] = fileparts(OPT.fileName);
    end
end

%% start KML

if ischar(OPT.fileName)
    OPT.fid = fopen(OPT.fileName,'w');
    
    %% HEADER
    
    OPT_header = struct(...
        'name'          ,OPT.kmlName,...
        'open'          ,0,...
        'description'   ,OPT.description,...
        'timeIn'        ,OPT.timeIn,...
        'timeOut'       ,OPT.timeOut,...
        'dateStrStyle'  ,OPT.dateStrStyle,...
        'LookAtLon'		,OPT.LookAtLon,...
        'LookAtLat'		,OPT.LookAtLat,...
        'LookAtAltitude',OPT.LookAtAltitude,...
        'LookAtrange'	,OPT.LookAtrange,...
        'LookAttile'	,OPT.LookAttile,...
        'LookAtheading'	,OPT.LookAtheading...
        );
    output = KML_header(OPT_header);
    
    fprintf(OPT.fid,output);
    
else
    OPT.fid = OPT.fileName;
end

output = '';
   
%% define line style
for ii = 1:length(styles);
    OPT_styleTrack = struct(...
        'name'        ,['trackstyle' num2str(ii)] ,...
        'balloonStyle',OPT.balloonStyle           ,...
        'lineColor'   ,OPT.lineColor(styles(ii),:),...
        'lineAlpha'   ,OPT.lineAlpha(styles(ii))  ,...
        'lineWidth'   ,OPT.lineWidth(styles(ii))  ,...
        'icon'        ,OPT.icon                   ,...
        'iconColor'   ,OPT.iconColor              ,...
        'iconScale'   ,OPT.iconScale              ,...
        'hlIconScale' ,OPT.hliconScale            ,...
        'hlLineColor' ,OPT.lineColor(styles(ii),:),...
        'hlLineAlpha' ,OPT.lineAlpha(styles(ii))  ,...
        'hlLineWidth' ,OPT.lineWidth(styles(ii))  ,...
        'hlIcon'      ,OPT.icon                   ,...
        'hlIconColor' ,OPT.iconColor              );
    output = [output KML_styleTrack(OPT_styleTrack)]; %#ok<AGROW>
end

if addData
    for ii=1:size(lat,2)
        OPT_schema.name = ['schema' num2str(ii)] ;
        output = [output KML_schema(OPT.data(ii,:),OPT_schema)]; %#ok<AGROW>
    end
end

% print styles

fprintf(OPT.fid,'%s',output);if nargout==1;kmlcode = output;end % collect all kml for function output

%% generate contents
%  preallocate output
output = repmat(char(1),1,1e6);
kk = 1;

%% loop through number of lines
OPT_track              = KML_track;
OPT_track.dateStrStyle = OPT.dateStrStyle;
OPT_track.extrude      = OPT.extrude;
if ~isempty(OPT.model) && strcmpi  ( OPT.fileName(end-2:end),'kmz')
    OPT_track.model        = [model_name model_ext];
else
    OPT_track.model        = OPT.model;
end
        
for ii=1:size(lat,2)
    % check if there is data to write
    if ~all(isnan(lat(:,ii)+lon(:,ii)))
        
        % update linestyle
        OPT_track.styleName     = ['trackstyle' num2str(style_nr(ii))];
        
        if addData
            OPT_track.schemaName = ['schema' num2str(ii)];
        end
        
        if OPT.extrude
            OPT_track.extrude = 1;
        else
            OPT_track.extrude = 0;
        end
        
        if iscell(OPT.trackName);           OPT_track.name = OPT.trackName{ii};     else  OPT_track.name         = OPT.trackName;       end
        if iscell(OPT.extendedData);OPT_track.extendedData = OPT.extendedData{ii};  else  OPT_track.extendedData = OPT.extendedData;    end
        if addData;                                dataTmp = OPT.data(ii,:);        else                 dataTmp = [];                  end
        if ~isempty(OPT.heading);               headingTmp = OPT.heading(:,ii);     else              headingTmp = [];                  end
        if is3D;                                      zTmp = z(:,ii);               else                    zTmp = z;                   end
        
        % write the track
        newOutput = KML_track(lat(:,ii),lon(:,ii),zTmp,time(:,ii),dataTmp,headingTmp,OPT_track);
        
        % add newOutput to output
        output(kk:kk+length(newOutput)-1) = newOutput;
        kk = kk+length(newOutput);
        
        % write output to file if output is full, and reset
        if kk>1e6
            fprintf(OPT.fid,'%s',output(1:kk-1));
            if nargout==1;
                kmlcode = [kmlcode output(1:kk-1)]; %#ok<AGROW>
            end
            kk        = 1;
            output    = repmat(char(1),1,1e6);
        end
    end
end

% print output

fprintf(OPT.fid,'%s',output(1:kk-1));if nargout==1;kmlcode = [kmlcode output(1:kk-1)];end

if ischar(OPT.fileName)
    
    %% close KML
    
    output = KML_footer;
    fprintf(OPT.fid,output);
    fclose(OPT.fid);
    
    %% compress to kmz?
    
    if strcmpi  ( OPT.fileName(end-2:end),'kmz')
        movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
        if isempty(OPT.model)
            zip ( OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
        else
            zip (OPT.fileName,{OPT.model,[OPT.fileName(1:end-3) 'kml']});
        end
        movefile([OPT.fileName '.zip'],OPT.fileName)
        delete  ([OPT.fileName(1:end-3) 'kml'])
    end
    
    %% openInGoogle?
    
    if OPT.openInGE
        system([OPT.fileName ' &']);
    end
    
end

if nargout ==1
    varargout = {kmlcode};
end

%% EOF
function data = determineDataType(data)

switch class(data.value);
    case {'cell','char'}
        data.type = 'string';
    case {'int8','int16'}
        data.type = 'short';
    case {'int32','int64'}
        data.type = 'int';
    case {'uint8','uint16'}
        data.type = 'ushort';
    case {'uint32','uint64'}
        data.type = 'uint';
    case 'logical'
        data.type = 'bool';
    case 'double'
        data.type = 'double';
    case 'single'
        data.type = 'float';
end

if iscell(data.value), 
    assert(iscellstr(data.value),'Values in cell are expected to be strings');
end

if ischar(data.value)
    data.value = cellstr(data.value);
end
