function varargout = arc_shape2kml(shape_filename,varargin)
%ARC_SHAPE2KML   save ESRI shape file as Google Earth file
%
%   arc_shape2kml(shape_filename,<keyword,value>)   
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = arc_shape2kml()
%
% where the keyword 'epsg' is required (the *.prj is 
% sometimes lacking, and is not parsed yet).
%
% Example: plot datsaset in 'ED50 / UTM zone 31N' in green
%  
%    arc_shape2kml('vogel en habitat\habitat gebieden\habitat.shp','epsg',23031,'color',[0 1 0]); 
%
%See also: CONVERTCOORDINATES, ARC_SHAPE_READ

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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 06 Apr 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: arc_shape2kml.m 3560 2010-12-07 12:52:50Z santinel $
% $Date: 2010-12-07 20:52:50 +0800 (Tue, 07 Dec 2010) $
% $Author: santinel $
% $Revision: 3560 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/gis/arc_shape2kml.m $
% $Keywords: $

%% settings

   OPT.directory_out     = pwd;
   OPT.pause             = 0;
   OPT.plot              = 0;
   OPT.html              = 0;
   OPT.epsg              = 0;
   OPT.cleanup           = 0;
   OPT.color             = [1 1 0]; % yellow
   OPT.fldname           = ''; % *.dbf fieldname entry to be used for name (default sequence number)
   OPT.deleteSourceFiles = 1;
   
   if nargin==0
      varargout = {OPT};
      return
   end

   OPT.fname         = shape_filename;
   
   OPT = setproperty(OPT,varargin{:});
   
%% read shape file

  %R0    = shaperead(OPT.fname);  %% issues with reading metadata..shp.xlm (matlab mapping toolbox, )
  [R,M]  = arc_shape_read(OPT.fname); %% still issues with reading chars (OpenEarth)
      n  = length(R);

%% plot whole polygons

figure(1)
for i=1:n

   disp([num2str(i,'%0.3d'),' / ',num2str(n,'%0.3d')])

%% analyse

   x = R(i).X;
   y = R(i).Y;
      
   if isempty(x) % 'zuid holland\waterkeringen\Waterkeringen.shp' no 23
      warning(['shape with length 0: ',OPT.fname,' no ',num2str(i)])
   else
   
     [lon,lat]           = convertCoordinates(R(i).X,R(i).Y,'CS1.code',OPT.epsg,'CS2.code',4326);
      
      % for patch-holes remove the NaNs
      mask = isnan(R(i).X);
      lonp = lon;
      latp = lat;
      lonp(mask) = lonp(1);
      latp(mask) = latp(1);
   
   %% plot in matlab
   
      if OPT.plot
         h(i) = patch(lonp,latp,[0 1 0]);
         hold on
         p(i) = plot (lon,lat,'k');
         
         axislat(52)
        %axis equal
         hold on
         
         set(h(i),'edgecolor','none')
      end
      
   %% plot as google earth files
   
      if ~exist([OPT.directory_out,filesep,fileparts(OPT.fname)])
      mkpath([OPT.directory_out,filesep,fileparts(OPT.fname)])
      end
   
      fillnames{i} = [OPT.directory_out,filesep,fileparts(OPT.fname),filesep,filename(OPT.fname),num2str(i,'%0.3d'),'_fill.kml'];
      edgenames{i} = [OPT.directory_out,filesep,fileparts(OPT.fname),filesep,filename(OPT.fname),num2str(i,'%0.3d'),'_edge.kml'];
      textnames{i} = [OPT.directory_out,filesep,fileparts(OPT.fname),filesep,filename(OPT.fname),num2str(i,'%0.3d'),'_text.kml'];
      
      %% name
      if ~isempty(OPT.fldname)
         try
          namestr = R(i).(OPT.fldname);
         catch
             disp(char(fieldnames(R)))
             error(['unknown field:',OPT.fldname])
             break
         end
      else
         namestr = num2str(i);
      end

      %% thin back line
      KMLline (lat,lon,'fileName',edgenames{i},...
                        'kmlName',namestr);

      %% colored fill
      if     strcmpi(R(i).Geometry,'Point')
      elseif strcmpi(R(i).Geometry,'Line') 
      KMLline (lat,lon,'fileName',fillnames{i},...
           'kmlName',namestr,...
           'lineAlpha',0.6,...
           'lineColor',OPT.color,...
           'lineWidth',5);
      elseif strcmpi(R(i).Geometry,'Line')| ...
             strcmpi(R(i).Geometry,'Polygon')
      KMLpatch(latp'    ,lonp'    ,'fileName',fillnames{i},...
           'kmlName',namestr,...
         'lineAlpha',0,...
         'fillColor',OPT.color,...
         'fillAlpha',0.6);
      end

      fldnames = setxor(fieldnames(R),{'BoundingBox','X','Y','Geometry'});
         
      html = ['<table border="1"><tr>'];
      for j=1:length(fldnames)
         fldname = fldnames{j};
         value   = R(i).(fldname);
         if isnumeric(value)
         value = num2str(value);
         end
         html = [html '<td>' fldname '=</td><td>' value '</td><tr>'];
      end
      html = [html '</tr>'];
      
      KMLmarker(lat(1),lon(1),'fileName',textnames{i},...
                               'kmlName',namestr,...
                                  'name',namestr,...
                                  'html',html,...
                      'colornormalState',OPT.color,...
                   'colorhighlightState',OPT.color);
           
   end        
   
   if OPT.pause
   pausedisp
   end
   
end

   if OPT.plot
      tickmap('ll')
   end
   
%% merge files

   edgename = [OPT.directory_out,filesep,fileparts(OPT.fname),filesep,filename(OPT.fname),'_edge.kml'];
   KMLmerge_files('fileName',edgename,'sourceFiles',edgenames,...
                   'kmlName','edge',...
         'deleteSourceFiles',OPT.deleteSourceFiles);

   fillname = [OPT.directory_out,filesep,fileparts(OPT.fname),filesep,filename(OPT.fname),'_fill.kml'];
   KMLmerge_files('fileName',fillname,'sourceFiles',fillnames,...
                   'kmlName','fill',...
         'deleteSourceFiles',OPT.deleteSourceFiles);
   
   textname = [OPT.directory_out,filesep,fileparts(OPT.fname),filesep,filename(OPT.fname),'_text.kml'];
   KMLmerge_files('fileName',textname,'sourceFiles',textnames,...
                   'kmlName','text',...
         'deleteSourceFiles',OPT.deleteSourceFiles);
       
   try % the XML meta-data files are generally mess: they change per arcGIS version and per user.
   if ~isfield(M.dataset_description.identification,'dataset_title')
   M.dataset_description.identification.dataset_title = M.dataset_description.identification.alternative_title;
   end

   if ~isfield(M.dataset_description,'overview')
   M.dataset_description.overview.summary = '';
   else
      if ~isfield(M.dataset_description.overview,'summary')
      M.dataset_description.overview.summary = '';
      end
   end
   catch
      M.dataset_description                              = struct();
      M.dataset_description.identification.dataset_title = '';
      M.dataset_description.overview.summary             = '';
   end

   %if ~isempty(OPT.html)
   %  %M.dataset_description.overview.summary = ['<![CDATA[',str2line(textread(OPT.html,'%s')),']]>'];
   %   M.dataset_description.overview.summary = ['<A href="',filenameext(OPT.html),'" >metadata</A>'];
   %end

   fullname = [OPT.directory_out,filesep,fileparts(OPT.fname),filesep,filename(OPT.fname),'.kml'];
   KMLmerge_files('fileName',fullname,...
                  'sourceFiles',{fillname edgename textname},...
                  'foldernames',{'areas','edges','texts'},...
       'kmlName',M.dataset_description.identification.dataset_title,...
   'description',M.dataset_description.overview.summary,...
   'deleteSourceFiles',OPT.deleteSourceFiles);
   
%% clean-up   
   
   if OPT.cleanup
    for i=1:n
     delete(edgenames{i})   
     delete(fillnames{i})   
     delete(textnames{i})   
    end
    delete(edgename)   
    delete(fillname)   
    delete(textname)   
   end
                  
%% EOF