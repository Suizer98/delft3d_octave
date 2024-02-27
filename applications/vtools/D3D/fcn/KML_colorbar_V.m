%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: KML_colorbar_V.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/KML_colorbar_V.m $
%
function varargout = KML_colorbar_V(OPT)
%KML_COLORBAR   make KML colorbar png
%
%   kmlstring = kml_colorbar(<keyword,value>)
%
%See also: GOOGLEPLOT, KMLcolorbar

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben de Boer
%
%       g.j.deboer@deltares.nl	
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

% $Id: K$
% $Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
% $Author: chavarri $
% $Revision: 16571 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/KML_colorbar_V.m $
% $Keywords: $

   OPT.template  = ~isempty(OPT.CBtemplateHor) | ~isempty(OPT.CBtemplateVer);
   OPT.halo      = 1; % when OPT.template
   
   if ~OPT.template & OPT.halo
   OPT.CBbgcolor  = [255 255 255]; % halo should be white
   OPT.CBframergb = [1 1 1]; %[255 253 2]/255;% white
   print('set CBframergb=[1 1 1] CBbgcolor  = [255 255 255]')
   end

   h.fig = figure('Visible','off');
   if isnumeric(OPT.CBcolorMap)
       colormap(OPT.CBcolorMap);
   else
       colormap(  OPT.CBcolorMap(OPT.CBcolorSteps));
   end

   
   set(h.fig,'color',OPT.CBbgcolor./255,'InvertHardcopy','off')
   
   
   %% !!!!! temporary set all locations to right
   OPT.CBhorizonalalignment = 'left';
   OPT.CBverticalalignment  = 'top';
   
   %% locations
   %
   %  +###+
   %  |   |
   %  +---+
   if              strcmpi(OPT.CBorientation      ,'horizontal') & ...
                   strcmpi(OPT.CBverticalalignment,'top')
      axes('position',[    OPT.CBtipmargin
                       1-  OPT.CBthickness-OPT.CBalignmargin
                       1-2*OPT.CBtipmargin    % width
                           OPT.CBthickness]); % height
                           OPT.CBXAxisLocation = 'bottom';
                           OPT.CBYAxisLocation = 'left'; % dummy
   %  +---+
   %  |   | % ERROR WITHOUT OPT.template
   %  +###+
   elseif          strcmpi(OPT.CBorientation      ,'horizontal') & ...
                   strcmpi(OPT.CBverticalalignment,'bottom')
      axes('position',[    OPT.CBtipmargin
                           OPT.CBalignmargin
                       1-2*OPT.CBtipmargin    % width
                           OPT.CBthickness]); % height
                           OPT.CBXAxisLocation = 'top';
                           OPT.CBYAxisLocation = 'left'; % dummy
   %  +---+
   %  |   # % ERROR WITHOUT OPT.template
   %  +---+
   elseif          strcmpi(OPT.CBorientation       ,'vertical') & ...
                   strcmpi(OPT.CBhorizonalalignment,'right')
      axes('position',[1-  OPT.CBthickness-OPT.CBalignmargin
                           OPT.CBtipmargin
                           OPT.CBthickness    % width
                       1-2*OPT.CBtipmargin]); % height
                           OPT.CBXAxisLocation = 'bottom'; % dummy
                           OPT.CBYAxisLocation = 'left';
   %  +---+
   %  #   | default
   %  +---+
   elseif          strcmpi(OPT.CBorientation       ,'vertical') & ...
                   strcmpi(OPT.CBhorizonalalignment,'left')
      axes('position',[    OPT.CBalignmargin
                           OPT.CBtipmargin
                           OPT.CBthickness    % width
                       1-2*OPT.CBtipmargin]); % height
                           OPT.CBXAxisLocation = 'bottom'; % dummy
                           OPT.CBYAxisLocation = 'right';
   else
      error('KMLcolorbar')
   end
   h.ax = gca;
   % if only one color is available, expand color limits:
   % add a relative amount: 0.01%, so it always works, also for very for big/small numbers
   if OPT.CBcLim(1)==OPT.CBcLim(2)
      OPT.CBcLim = OPT.CBcLim + 1e-4.*[-1 1].*OPT.CBcLim;
   end
%    h.c  = colorbarlegend(gca,[0 1],[0 1],OPT.CBcLim,...
%             'ontop',1,... % 1 needed for CBcolorTitle
%         'reference','gca',...
%       'orientation',OPT.CBorientation);
   h.c  = colorbarlegend_V(gca,[0 1],[0 1],OPT.CBcLim,...
            'ontop',1,... % 1 needed for CBcolorTitle
        'reference','gca',...
      'orientation',OPT.CBorientation,...
      'CBlegendFontSize',OPT.CBlegendFontSize);

   if OPT.template
        if     strcmpi(OPT.CBorientation      ,'vertical') 
           text(-2.1,0.1,[' ',OPT.CBcolorTitle],'color',OPT.CBtitlergb,'units','normalized','rotation',90,'verticalalignment','middle','interpreter',OPT.CBinterpreter,'fontsize',OPT.CBfontsize);
        elseif strcmpi(OPT.CBorientation      ,'horizontal')
           text( 0.0,2.0,[' ',OPT.CBcolorTitle],'color',OPT.CBtitlergb,'units','normalized','rotation', 0,'verticalalignment','bottom','interpreter',OPT.CBinterpreter,'fontsize',OPT.CBfontsize);
        end        
   else
      if     strcmpi(OPT.CBorientation      ,'vertical') 
         text(0.5,0.0,[' ',OPT.CBcolorTitle],'color',OPT.CBtitlergb,'units','normalized','rotation',90,'verticalalignment','middle','interpreter',OPT.CBinterpreter,'fontsize',OPT.CBfontsize);
      elseif strcmpi(OPT.CBorientation      ,'horizontal')
         text(0.0,0.5,[' ',OPT.CBcolorTitle],'color',OPT.CBtitlergb,'units','normalized','rotation', 0,'verticalalignment','middle','interpreter',OPT.CBinterpreter,'fontsize',OPT.CBfontsize);
      end
      set   (h.c,'FontWeight'   ,'bold'); % we need bold for both halo and normal irregular background
   end

   set   (h.c,'xcolor'       ,OPT.CBfontrgb)
   set   (h.c,'ycolor'       ,OPT.CBfontrgb)
   set   (h.c,'XAxisLocation',OPT.CBXAxisLocation);
   set   (h.c,'YAxisLocation',OPT.CBYAxisLocation);
   
   % set the tick marks if they have been provided
   if isfield(OPT,'CBcolorTick')
     if ~isempty(OPT.CBcolorTick)
        if  strcmpi(OPT.CBorientation   ,'vertical');
         set(h.c,'YTick',OPT.CBcolorTick);
        elseif strcmpi(OPT.CBorientation,'horizontal')
         set(h.c,'XTick',OPT.CBcolorTick);
        end
     end
   end
   
   % set the ticklabels if they have been provided
   if isfield(OPT,'CBcolorTickLabel')
     if ~isempty(OPT.CBcolorTickLabel)
        if     strcmpi(OPT.CBorientation,'vertical');
         set(h.c,'YTickLabel',OPT.CBcolorTickLabel);
        elseif strcmpi(OPT.CBorientation,'horizontal')
         set(h.c,'XTickLabel',OPT.CBcolorTickLabel);
        end
     end
   end
   delete(h.ax)
   box on
   
   % copy axes and set box color seperately
   c_axes = copyobj(gca,h.fig);
   set(c_axes, 'color', 'none', 'xcolor', OPT.CBframergb, 'xgrid', 'off', 'ycolor',OPT.CBframergb, 'ygrid','off','xtick',[],'ytick',[]);
 
   set  (h.fig,'paperUnits','inch')
   set  (h.fig,'PaperSize',[4.6 5.8])
   set  (h.fig,'PaperPosition',[0 0 4.6 5.8])
   if OPT.template
       res = '-r100';
   else
       res = '-r150';
   end
   print(h.fig,[OPT.CBfileName,'.png'],res,'-dpng'); % explicitly refer to h.fig, otherwise another figure (e.g. UCIT GUI) is printed.
   im = imread([OPT.CBfileName,'.png']);
   
   if OPT.template
      switch OPT.CBorientation
          case 'horizontal'
              % crop image to 100 by 440
              im   = im((1:100),(1:440)+10,:);
              mask = bsxfun(@eq,im,reshape(OPT.CBbgcolor,1,1,3));
              % load template
              [template, map, alpha] = imread(OPT.CBtemplateHor);
              % place all non invisible pixels in the template)
              templateColobarArea = template((1:100)+14,(1:440)+140,:);
              templateColobarArea(repmat(any(~mask,3),1,3)) = im(repmat(any(~mask,3),1,3));
              template((1:100)+14,(1:440)+140,:) = templateColobarArea;
          case 'vertical'
              % crop image to 440 by 100
              im   = im((1:440)+70,1:100,:);
              mask = bsxfun(@eq,im,reshape(OPT.CBbgcolor,1,1,3));
              % load template
              [template, map, alpha] = imread(OPT.CBtemplateVer);
              % place all non invisible pixels in the template)
              templateColobarArea = template((1:440)+90,(1:100)+18,:);
              templateColobarArea(repmat(any(~mask,3),1,3)) = im(repmat(any(~mask,3),1,3));
              template((1:440)+90,(1:100)+18,:) = templateColobarArea;
      end
      imwrite(template,[OPT.CBfileName,'.png'],'Alpha',alpha*OPT.CBalpha);
   else
      % do not use any default
      mask  = bsxfun(@eq,im,reshape(OPT.CBbgcolor,1,1,3));

      %% now let alpha gradually decrease from 0 inside to 1 outside

      if OPT.halo
      s1 = all(mask,3);
      s2 = ~ceil((~s1([1 1:end-1],[1 1:end-1]) + ...
                  ~s1([2:end end],[1 1:end-1]) + ...
                  ~s1([1 1:end-1],[2:end end]) + ...
                  ~s1([2:end end],[2:end end]))/4); % move letters 1 pixel around
      s3 = ~ceil((~s2([1 1:end-1],[1 1:end-1]) + ...
                  ~s2([2:end end],[1 1:end-1]) + ...
                  ~s2([1 1:end-1],[2:end end]) + ...
                  ~s2([2:end end],[2:end end]))/4); % move letters 1other pixel around

      blend = zeros(size(s1)); % alpha value to add ONLY to pixels adjacent to letters and colorbar
      blend(logical(s1-s3))= 0.5;
      blend(logical(s1-s2))= 1.0;
      imwrite(im,[OPT.CBfileName,'.png'],'Alpha',ones(size(mask(:,:,1))).*(1-double(all(mask,3)) + blend)*OPT.CBalpha);
      else
      imwrite(im,[OPT.CBfileName,'.png'],'Alpha',ones(size(mask(:,:,1))).*(1-double(all(mask,3)))*OPT.CBalpha);
      end

   end
   
   try close(h.fig);end
   
   if nargout==1
      varargout = {[OPT.CBfileName,'.png']};
   end

%% EOF
