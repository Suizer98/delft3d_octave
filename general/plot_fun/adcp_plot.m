function varargout = adcp_plot(edge_time, edge_z, face_time, face_z, degn, uabs, wind_time, wind_degn, wind_uabs,varargin)
%ADCP_PLOT  plot 3 panel plot (u,direction, wind) of ADCP recording
%
% <ax_handles>= adcp_plot(edge_time, edge_z, face_time, face_z, degn, uabs, ...
%                         wind_time, wind_degn, wind_uabs, <keyword,value>)
%
%           z
%           ^
%  egde_1   +---+---+---+---+---+
%  face_1   |   |   |   |   |   | bin1 (binn)
%  egde_2   +---+---+---+---+---+
%           :   :   :   :   :   :
%  egde_n   +---+---+---+---+---+
%  face_n   |   |   |   |   |   | binn (bin1) 
%  egde_n+1 +---+---+---+---+---+ --> t
%
%           |   |   |   |  face_times ...
%             |   |   |    edge_times ...
%
% Example:
% adcp_plot(now+[0 2 4 6],[-10  -6  -2],...                % z & time (center2corner)
%           now+[ 1 3 5 ],[   -8  -4  ],...                % z & time (corner2center)
%           [90 45 10; 60 30 5],...                        % sample data
%           [4 8 6;5 9 7],[0:.1:10],[0:3.6:360],[0:.2:20]) % rotating high-frequency wind
%
% Note: make sure z is positive upward, so it works for both bottom mounted
%       ADCPs (bin 1 near bed) and for model resuls (Delft3D layer k=1 is near surface)
%
%See also: KMLcurtain, vs_trih2nc, wind_rose, wind_plot, meshgrid_time_z,
%          load (for WinADCP mat file export, http://www.rdinstruments.com)

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
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

% $Id: adcp_plot.m 5069 2011-08-17 06:05:23Z boer_g $
% $Date: 2011-08-17 14:05:23 +0800 (Wed, 17 Aug 2011) $
% $Author: boer_g $
% $Revision: 5069 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/adcp_plot.m $
% $Keywords: $
%% keywords

%% options
   
   OPT.title     = '';
   OPT.ylabel    = 'z [m]'; % mab, mbs
   OPT.pause     = 1;
   OPT.print_base_name = 0;
   OPT.export    = 0;
   OPT.close     = 0;
   OPT.watermark = '';
   OPT.clim      = [];
   OPT.windlim   = [0 10];
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
   OPT = setproperty(OPT,varargin);

%% define axis

   FIG = figure;
   AX = subplot_meshgrid(2,3,.08,[.08 .01 .01 .08],[nan .05],nan);
   
%% uabs panel

   axes(AX(1,1))
   pcolorcorcen(edge_time, edge_z, uabs)
   hold on
  %contour(face_time, face_z,uabs,[0:10:60])
   yy = ylim;
   uchar = mean(uabs,1);
   plot(face_time,yy(1) + (uchar - min(uchar)).*(yy(2)-yy(1))./max(uchar),'k','linewidth',2)
   text([1 1],[0 1],{[' ',num2str(min(uchar),'%0.3f')], [' ',num2str(max(uchar),'%0.3f')]},'units','normalized')
   text(1,.5,'mean(U) [m/s]','units','normalized','rotation',90,'horizontalalignment','center','verticalalignment','top')
   %set(gca,'ydir','reverse')
   if ~isempty(OPT.clim);caxis(OPT.clim);end
   [ax, h]=colorbarwithvtext('|U| [m/s]',[0:20:100],'position',get(AX(2,1),'position'));delete(AX(2,1))
   ylabel(OPT.ylabel)
   title(OPT.title)
   freezeColors(AX(1)); % screws up colorbar legend
   cbFreeze(ax);
   text(1.08,0,'|U| m/s','units','normalized','rotation',90)
   
%% degn panel

   axes(AX(1,2))
   pcolorcorcen(edge_time, edge_z, degn)
   hold on
   contour(face_time, face_z,degn,[-1 90 270 361],'k')   %set(gca,'ydir','reverse')
   hsvmap = hsv; hsvmap=colormap([hsvmap(52:-1:1,:);hsvmap(end:-1:53,:)]); % same colormap as WINADCP, green at 180
   colormap(hsvmap)
   %set(gca,'ydir','reverse')
   caxis([0 360])
   [ax, h]=colorbarwithvtext('',[0:90:360],'position',get(AX(2,2),'position'));delete(AX(2,2));
   axes(ax);hline([90 270],'k-');axes(AX(1,2))
   set(ax,'YTickLabel',{'N','E','S','W','N'}); % tex arrows do not work here
   ylabel(OPT.ylabel)
   text(1.08,0,'current to direction [\circ]','units','normalized','rotation',90)
   text(1.0 ,0,OPT.watermark,'units','normalized','rotation',90,'fontsize',6,'verticalalignment','top')
   xx = xlim;
   
%% meteo panel

   axes(AX(1,3))
  [wind_ux,wind_uy] = pol2cart(deg2rad(degn2deguc(wind_degn)),wind_uabs);
   
   wind_plot(wind_time,wind_degn,wind_uabs,'Ulim',[0 10],'dtype','meteo','Uleg',['wind |U|'],'thleg',['wind \theta'])
   grid     on
  %legend('location',get(AX(2,3),'position'))
   delete(AX(2,3))
   ylim(OPT.windlim)
   %% loop over time to export set of plots of manageable chunks
   da = daspect;fac = da(2)./da(1); fac=10;
   quiver(wind_time,0.*wind_time+5,wind_ux.*.03,wind_uy.*fac.*.03,0,'.k')
   timeaxis(xx,'fmt','yyyy-mm-dd')

   if OPT.export
   print2screensizeoverwrite([OPT.print_base_name,'_overview.png'])
   end
   
%% printing in time chunks

   if OPT.pause
   pausedisp
   end

   day0 = floor(face_time(  1));
   day1 = floor(face_time(end));
   
   dday = 2;
   for day = day0:1:day1
   
      multiWaitbar( 'plotting ADCP file chunkwise', (day-day0-1)/(day1-day0));
      
      %%
      for iax=1:3
         axes(AX(1,iax))
         timeaxis(day + [0:3:24.*dday]/24,'fmt','')
         grid on
      end
         timeaxis(day + [0:3:24.*dday]/24,'fmt','HH')
        %xlabel([datestr(day,'yyyy-mmm-dd'), ' - ', datestr(day+1,'yyyy-mmm-dd')])
         h.tt = text([.25 .75],[-.1 -0.1],datestr(day+[0 1],'yyyy-mmm-dd'),'units','normalized','vert','top');
         
      if OPT.pause
      pausedisp
      end
   
      if OPT.export
      print2screensizeoverwrite([OPT.print_base_name,'_',datestr(day,'yyyy_mm_dd'),'_',datestr(day+dday-1,'yyyy_mm_dd'),'.png']) % name should be up to and including, while xlim it up to, so move 1 day back
      end
      
      delete(h.tt);
      
      %pausedisp
   end
   
   if OPT.close
      close(FIG)
   end
   
   if nargout & ~OPT.close
      varargout  = {AX};
   end
