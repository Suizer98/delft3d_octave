function varargout = KMLtrimesh(tri,lat,lon,varargin)
% KMLTRIMESH    Just like trimesh
%
%   [OPT, Set, Default] = KMLtrimesh(tri,lat,lon,  <keyword,value>)
%   [OPT, Set, Default] = KMLtrimesh(tri,lat,lon,z,<keyword,value>)
%
% is implemented very fast compared to KMLtrisurf: it assembles 
% long lines that assemble all faces. Lines plot orders of  
% magnitude faster in google earth than patch edges.
%
% You can KMLtrimesh edges in combination with KMLtrisurf for faces.
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLtrimesh()
%
% Example:
% [x,y,z]=peaks(20);
% tri = delaunay(x,y);
% KMLtrimesh(tri,X,Y,Z,'fileName','KMltrimesh.kml','openInGE',1)
% hold on
% KMLtriSURF(tri,X,Y,Z,'fileName','KMltriSURF.kml','openInGE',1)
%
% See also: googlePlot, KMLtrisurf, trimesh, tri2poly, KMLmesh

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares for www.NMDC.eu
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

% $Id: KMLtrimesh.m 5495 2011-11-17 12:42:49Z boer_g $
% $Date: 2011-11-17 20:42:49 +0800 (Thu, 17 Nov 2011) $
% $Author: boer_g $
% $Revision: 5495 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLtrimesh.m $
% $Keywords: $

%% process <keyword,value>

   OPT            = KMLline();

   if nargin==0
      varargout = {OPT};
      return
   end

%% see if height is defined

   if ~isempty(varargin)
       if ~ischar(varargin{1}) | strcmpi(varargin{1},'clampToGround')
           z = varargin{1};
           varargin = varargin(2:length(varargin));
           OPT.is3D        = true;      
       end
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

%% start KML

   OPT.fid=fopen(OPT.fileName,'w');

%% HEADER

   output = KML_header(OPT);
   fprintf(OPT.fid,output);

%% make mesh
%  turn tri into lines


   fileName     = OPT.fileName;
   OPT.fileName = OPT.fid;

   kmlcode = [];
   if OPT.is3D
     [lat lon z] = tri2poly(tri,lat,lon,z);
      KMLline(lat ,lon ,z ,OPT);
      KMLline(lat',lon',z',OPT);
   else
     [lat lon] = tri2poly(tri,lat,lon);
      KMLline(lat ,lon    ,OPT);
      KMLline(lat',lon'   ,OPT);
   end

   OPT.fileName = fileName;

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
