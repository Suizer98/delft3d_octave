function varargout = KMLline(lat,lon,varargin)
% KMLLINE Just like line (and that's just like plot)
%
%    kmlline(lat,lon,    <keyword,value>)
%    kmlline(lat,lon,<z>,<keyword,value>)
%
% creates a kml file fname with lines at the Earth surface or optionally 
% at <z> connecting the coordinates defined in (lat,lon). As in plot, 
% an array of lines can be drawn at once. Each column in (lat,lon) 
% defines a new line (size(lat,2)).. A single line can be split into 
% segments by nan's in (lat,lon).
% 
% coordinates (lat,lon) are in decimal degrees. 
%   LON is converted to a value in the range -180..180)
%   LAT must be in the range -90..90
%
% be aware that GE draws the shortest possible connection between two 
% points, when crossing the null meridian.
%
% The kml code (without header/footer) that is written to file 
% 'fileName' can optionally be returned as argument.
%
%    kmlcode = kmlline(lat,lon,<keyword,value>)
%
% Some <keyword,value> pairs are described here:
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
% Example 1: draw a spiral around the earth
%   lat = linspace(-90,90,1000)'; lon = linspace(0,5*360,1000)';
%   KMLline(lat,lon)
%
% Example 2: draw the mean low water line of the netherlands as a function 
%            of time
%   % read data from server
%   url  = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/strandlijnen/strandlijnen.nc';
%   url  = 'd:\opendap\rijkswaterstaat\strandlijnen\/strandlijnen.nc';
%   time = ncread(url, 'time')+datenum(1970,1,1);
%   id   = ncread(url, 'id')';
%   lat  = ncread(url, 'MHW_lat')';
%   lon  = ncread(url, 'MHW_lon')';
%   % insert a NaN to split lines for a given year at a gap in trID number
%   splits = find(diff(id)>1e5)+1; length(id);
%   for ii = length(splits):-1:1
%       lat(splits(ii)+1:end+1,:) = lat(splits(ii):end,:);
%       lon(splits(ii)+1:end+1,:) = lon(splits(ii):end,:);
%       lat(splits(ii),:) = nan;
%       lon(splits(ii),:) = nan;
%   end
%   % draw the lines
%   KMLline(lat,lon,'timeIn',time,'timeOut',time+364,...
%       'lineWidth',4,'lineColor',jet(length(time)),'lineAlpha',.7);
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

% $Id: KMLline.m 12701 2016-04-22 09:47:55Z gerben.deboer.x $
% $Date: 2016-04-22 17:47:55 +0800 (Fri, 22 Apr 2016) $
% $Author: gerben.deboer.x $
% $Revision: 12701 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLline.m $
% $Keywords: $

%% process <keyword,value>

   OPT               = KML_header();

   OPT.fileName      = ''; % header/footer are skipped when is a fid = fopen(OPT.fileName,'w')
   OPT.lineWidth     = 1;
   OPT.lineColor     = [0 0 0];
   OPT.lineAlpha     = 1;
   OPT.fill          = true;
   OPT.fillColor     = [0 .5 0];
   OPT.fillAlpha     = .4;
   OPT.openInGE      = false;
   OPT.is3D          = false;
   OPT.extrude       = false; % false is google's default
   OPT.tessellate    = ~OPT.is3D;
   OPT.zScaleFun     = @(z) (z+0)*1;
   OPT.fid           = -1;
   OPT.name          = ''; % name of each line, for unique name per line make sure name is cellstr with length size(D.x,1)
   
   if nargin==0
      varargout = {OPT};
      return
   end

%% see if height is defined

   z = 'clampToGround';
   if ~isempty(varargin);
       if isnumeric(varargin{1});
           z        = varargin{1};
           varargin(1) = [];
           if ~ischar(z)
           OPT.is3D = true;
           end
       elseif ischar(varargin{1}) & odd(nargin) % when even(nargin), this is a keyword
           z        = varargin{1}; % 'clampToGround', 'relativeToGround' (ski lift),  'absolute' (airplane)
           varargin(1) = [];
       end
   end
   
   [OPT, Set, Default] = setproperty(OPT, varargin);

%% input check

   if any((abs(lat)/90)>1)
       error('latitude out of range, must be within -90..90')
   end
   lon = mod(lon+180, 360)-180;
   
   if size(lat,1)==1
       lat = lat(:);
       lon = lon(:);
       if OPT.is3D
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
       line_ind    = 1;
       OPT.line_nr = ones(size(lat,2),1);
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
       [ignore,line_ind,OPT.line_nr] = unique([OPT.lineWidth,OPT.lineColor,OPT.lineAlpha],'rows');
   end

%% do the same for the fill style if 3D

   if OPT.is3D&&OPT.fill
       if numel(OPT.fillColor)+numel(OPT.fillAlpha) == 4
           % one fillstyle, do nothing
           fill_ind    = 1;
           OPT.fill_nr = ones(size(lat,2),1);
       else
           % multiple styles; expand input options to # of lines
           OPT.fillColor = [repmat(OPT.fillColor,floor(size(lat,2)/size(OPT.fillColor,1)),1);...
               OPT.fillColor(1:rem(size(lat,2),size(OPT.fillColor,1)),:)];
   
           OPT.fillAlpha = OPT.fillAlpha(:);
           OPT.fillAlpha = [repmat(OPT.fillAlpha,floor(size(lat,2)/length(OPT.fillAlpha)),1);...
               OPT.fillAlpha(1:rem(size(lat,2),length(OPT.fillAlpha)))];
   
           % find unique fillstyles
           [ignore,fill_ind,OPT.fill_nr] = unique([OPT.fillColor,OPT.fillAlpha],'rows');
       end
   end

%% get filename, gui for filename, if not set yet

   if ischar(OPT.fileName) && isempty(OPT.fileName); % can be char ('', default) or fid
      [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
      OPT.fileName = fullfile(filePath,fileName);

%% set kmlName if it is not set yet

      if isempty(OPT.kmlName)
      [ignore OPT.kmlName] = fileparts(OPT.fileName);
      end
   end

%% start KML

if ischar(OPT.fileName)
   OPT.fid = fopen(OPT.fileName,'w');

%% HEADER

   output = KML_header(OPT);
   
   fprintf(OPT.fid,output);

else
   OPT.fid = OPT.fileName;
end

output = '';

%% define line and fill  styles
%  line styles

   for ii = 1:length(line_ind);
       OPT_style = struct(...
           'name',['line_style' num2str(ii)],...
           'lineColor',OPT.lineColor(line_ind(ii),:) ,...
           'lineAlpha',OPT.lineAlpha(line_ind(ii)),...
           'lineWidth',OPT.lineWidth(line_ind(ii)));
       output = [output KML_style(OPT_style)];
   end

%% fill styles

   if OPT.is3D&&OPT.fill
       for ii = 1:length(fill_ind);
           OPT_stylePoly = struct(...
               'name',['fill_style' num2str(ii)],...
               'lineWidth'   ,0,...
               'fillColor'   ,OPT.fillColor(fill_ind(ii),:),...
               'fillAlpha'   ,OPT.fillAlpha(fill_ind(ii)),...
               'polyFill'    ,1,...
               'polyOutline' ,1);
           output = [output KML_stylePoly(OPT_stylePoly)];
       end
   end

% print styles

   fprintf(OPT.fid,output);if nargout==1;kmlcode = output;end % collect all kml for function output

%% generate contents
%  preallocate output

   output = repmat(char(1),1,1e5);
   kk = 1;

% line properties

   OPT_line = struct(...
       'name',{OPT.name},...
       'styleName',['line_style' num2str(OPT.line_nr(1))],...
       'tessellate',OPT.tessellate,...
       'visibility',OPT.visible,...
           'extrude',OPT.extrude);
   if isempty(OPT.timeIn) ,OPT_line.timeIn  = [];else  OPT_line.timeIn = datestr( OPT.timeIn(1),OPT.dateStrStyle); end
   if isempty(OPT.timeOut),OPT_line.timeOut = [];else OPT_line.timeOut = datestr(OPT.timeOut(1),OPT.dateStrStyle); end
   
   if OPT.is3D&&OPT.fill
       % fill properties
       OPT_fill = struct(...
           'name'      ,'',...
           'styleName' ,['fill_style' num2str(OPT.fill_nr(1))],...
           'visibility',OPT.visible,...
           'extrude'   ,1);
       if isempty(OPT.timeIn) , OPT_fill.timeIn = [];else  OPT_fill.timeIn = datestr( OPT.timeIn(1),OPT.dateStrStyle); end
       if isempty(OPT.timeOut),OPT_fill.timeOut = [];else OPT_fill.timeOut = datestr(OPT.timeOut(1),OPT.dateStrStyle); end
   end

%% loop through number of lines

   for ii=1:length(lat(1,:))
     % check if there is data to write
     if ~all(isnan(lat(:,ii)+lon(:,ii)))
         % update linestyle
         OPT_line.styleName = ['line_style' num2str(OPT.line_nr(ii))];
         % update timeIn and timeOut if multiple times are defined
         if length(OPT.timeIn )>1,OPT_line.timeIn  = datestrnan(OPT.timeIn (ii),OPT.dateStrStyle,'');end
         if length(OPT.timeOut)>1,OPT_line.timeOut = datestrnan(OPT.timeOut(ii),OPT.dateStrStyle,'');end
         if OPT.is3D&&OPT.fill
             OPT_fill.styleName = ['fill_style' num2str(OPT.fill_nr(ii))];
             if length(OPT.timeIn )>1, OPT_fill.timeIn = datestr(OPT.timeIn (ii),OPT.dateStrStyle);end
             if length(OPT.timeOut)>1,OPT_fill.timeOut = datestr(OPT.timeOut(ii),OPT.dateStrStyle);end
         end
         
         % set line label
         if iscell(OPT.name)
             if length(OPT.name) >= 1
                OPT_line.name = OPT.name{ii};
             else
                OPT_line.name = '';
             end
         end
         
         % write the line
         if OPT.is3D
             newOutput = KML_line(lat(:,ii),lon(:,ii),OPT.zScaleFun(z(:,ii)),OPT_line);        
         else
             newOutput = KML_line(lat(:,ii),lon(:,ii),z                     ,OPT_line);
         end

         % add a fill if needed
         if OPT.is3D&&OPT.fill
             newOutput =  [newOutput,KML_line(lat(:,ii),lon(:,ii),OPT.zScaleFun(z(:,ii)),OPT_fill)];
         end
         
         % add newOutput to output
         output(kk:kk+length(newOutput)-1) = newOutput;
         kk = kk+length(newOutput);

         % write output to file if output is full, and reset
         if kk>1e5
             fprintf(OPT.fid,       output(1:kk-1));if nargout==1;kmlcode = [kmlcode output(1:kk-1)];end
             kk        = 1;
             output    = repmat(char(1),1,1e5);
         end
     end
   end

% print output

   fprintf(OPT.fid,       output(1:kk-1));if nargout==1;kmlcode = [kmlcode output(1:kk-1)];end

if ischar(OPT.fileName)

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
       system([OPT.fileName ' &']);
   end

end

if nargout ==1
  varargout = {kmlcode};
end

%% EOF