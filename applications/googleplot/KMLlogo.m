function varargout = KMLlogo(varargin)
%KMLlogo   make a white logo *.png with transparent background of an image
%
%    <kmlcode> = KMLlogo(<imName>,<keyword,value>)
% 
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLlogo()
%
% The following see <keyword,value> pairs have been implemented:
%  'fileName'       name of output file, Can be either a *.kml or *.kmz
%                   or *.kmz (zipped *.kml) file. If not defined a gui pops up.
%                   (When 0 or fid = fopen(...) writing to file is skipped
%                   and optional <kmlcode> is returned without KML_header/KML_footer.)
%
% See also: googlePlot, imread

% http://code.google.com/intl/nl/apis/kml/documentation/kmlreference.html#screenoverlay

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares for Building with Nature
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

% $Id: KMLlogo.m 5853 2012-03-16 15:42:18Z boer_g $
% $Date: 2012-03-16 23:42:18 +0800 (Fri, 16 Mar 2012) $
% $Author: boer_g $
% $Revision: 5853 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLlogo.m $
% $Keywords: $

%% import
 
   OPT                  = KML_header();

   OPT.fileName         = 0;  % header/footer are skipped when is a fid = 0 or fopen(OPT.fileName,'w')
   OPT.logoName         = ''; % png file as in kml
   OPT.imName           = ''; % png file used as basis
   OPT.invertblackwhite = 0; % invert black/white
   
   OPT.overlayXY        = [0 0];       % mapping a point in the image specified by <overlayXY> ...
   OPT.screenXY         = [0.02 0.05]; % ...  to a point on the screen specified by <screenXY>
   OPT.size             = [-1 -1];     % -1  = automatic
   
   OPT.overlayXYunits   = 'fraction';
   OPT.screenXYunits    = 'fraction';
   OPT.sizeunits        = 'fraction';

   if nargin==0
      varargout = {OPT};
      return
   end
   
   if odd(nargin)
       imName             = varargin{1};
      [OPT, Set, Default] = setproperty(OPT, varargin{2:end});
   else
      [OPT, Set, Default] = setproperty(OPT, varargin{:});
       imName             = OPT.imName;
   end


%% get filename, gui for filename, if not set yet

   if ischar(OPT.fileName) & isempty(OPT.fileName); % can be char ('', default) or fid
      [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
      OPT.fileName = fullfile(filePath,fileName);
      
%% set kmlName if it is not set yet

      if isempty(OPT.kmlName)
      [ignore OPT.kmlName] = fileparts(OPT.fileName);
      end
   end

%% do image stuff: white image with transparancy ~ lack of white

  [im,map,im4alpha0] = imread([imName]);
  
   if ~isempty(map)
   im = ind2rgb(im,map).*255;
   end
   
   % make alpha sum of rgb values
   if OPT.invertblackwhite
   im4alpha =  sum(im,3)./255./3;
   else
   im4alpha = 1-sum(im,3)./255./3;
   end
   im4alpha = im4alpha./max(im4alpha(:));% scale so lightest pixel is fully white
   
   % Use exisitng alpha when present
   % otherwise calculate alpha by scaling image
   if any(im4alpha0(:) > 0)
   im4alpha = double(im4alpha0)./255.*double(im4alpha);
   end
   
   if isempty(OPT.logoName)
   OPT.logoName = fullfile(fileparts(imName),[filename(imName),'4GE.png']);
   end

   imwrite(ones(size(im)),OPT.logoName,'Alpha',im4alpha);
   
%% make kml encapsulation

% <name>logo</name>
%   <ScreenOverlay>
% 	<Icon><href>hydro4GE.png</href></Icon>
% 		<overlayXY  x="0"      y="0.00"  xunits="fraction" yunits="fraction"/>
% 		<screenXY   x="0.02"   y="0.05"  xunits="fraction" yunits="fraction"/>
% 		<size       x="-1"     y="-1"    xunits="fraction"   yunits="fraction"/>
%   </ScreenOverlay>
% </Folder>

   if ischar(OPT.fileName)
      OPT.fid = fopen(OPT.fileName,'w');
      output = KML_header(OPT);
      fprintf(OPT.fid,output);
   else
      OPT.fid = OPT.fileName;
   end

   output = '';
   
   output = [output '\n' ...
       '<Folder>\n'...
       ' <name>',OPT.kmlName,'</name>\n' ...
       ' <ScreenOverlay>\n' ...
       '  <Icon><href>' filenameext(OPT.logoName) '</href></Icon>\n' ... % only relative path
       '  <overlayXY  x="',num2str(OPT.overlayXY(1)),'" y="',num2str(OPT.overlayXY(2)),'" xunits="',OPT.overlayXYunits,'" yunits="fraction"/>\n' ...
       '  <screenXY   x="',num2str(OPT.screenXY (1)),'" y="',num2str(OPT.screenXY(2) ),'" xunits="',OPT.screenXYunits ,'" yunits="fraction"/>\n' ...
       '  <size       x="',num2str(OPT.size (1)    ),'" y="',num2str(OPT.size (2)    ),'" xunits="',OPT.sizeunits     ,'" yunits="fraction"/>\n' ...
       ' </ScreenOverlay>\n'...
       '</Folder>' ];

   if OPT.fid > 0
      fprintf(OPT.fid,output,'%s');
   end
   if nargout==1;kmlcode = output;end % collect all kml for function output

   if ischar(OPT.fileName)
      output = KML_footer;
      fprintf(OPT.fid,output);
      fclose (OPT.fid);
   end
   
if nargout ==1
  varargout = {kmlcode};
end


%% EOF