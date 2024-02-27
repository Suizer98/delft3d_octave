function varargout = display(data, time, mask, dataf, S,varargin)
%display  display DINEOF results for inspection via plot
%
%   dineof.display(data, time, mask, dataf, eofs)
%
% plot the results of DINEOF analysis [dataf,eofs] = dineof.run(...)
%
%See also: DINEOF

%   --------------------------------------------------------------------
%   Copyright (C) 2011-2012 Deltares 4 Rijkswaterstaat: Resmon project
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

% $Id: display.m 12593 2016-03-17 08:37:37Z gerben.deboer.x $
% $Date: 2016-03-17 16:37:37 +0800 (Thu, 17 Mar 2016) $
% $Author: gerben.deboer.x $
% $Revision: 12593 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/+dineof/display.m $
% $Keywords: $

   sz = size(data);

   if sz(2)==1
     dim = 1;
   else
     dim = 2;
   end

   nt = size(S.rghvec,1);
   r  = [min(data(:)) max(data(:))];

%% space-time field for 1D spaces
if dim==1

   AX = subplot_meshgrid(3,3,[.08 .02 .02 .05],[.08 .02 .05 .05],[nan nan nan],[nan nan .05]);

   %% raw data
   axes(AX(4))
   pcolor(time,1:sz(1),permute(data,[1 3 2]))
   shading interp
   xlabel('time')
   ylabel('space')
   datetick('x');xlim(time([1 end]))
   ylim([0 sz(1)])
   clim(r)
   set(AX(4),'xAxisLocation','bot')
   [ax1,h1,txt1]=colorbarwithhtext('\uparrow residual        \downarrow raw data','horiz','position',get(AX(7),'position'));
   
   %% filled data
   axes(AX(5))
   pcolor(time,1:sz(1),permute(dataf,[1 3 2]))
   shading interp
   xlabel('time')
   datetick('x');xlim(time([1 end]))
   ylim([0 sz(1)])
   clim(r)
   set(AX(5),'xAxisLocation','bot')
   set(AX(5),'yticklabel',{})
   [ax2,h2,txt2]=colorbarwithhtext('data filled','horiz','position',get(AX(8),'position'));
   
   %% spatial modes
   axes(AX(6))
   for im=1:S.P
   plot(S.lftvec(:,1,im),1:sz(1),'.-','Color',repmat(interp1([S.P 0],[0.9 0],im),[1 3]),...
                                  'linewidth',       interp1([S.P 0],[1 4],im),'DisplayName',S.varLab{im});
   hold on
   end   
   xlabel('EOF lftvec')
   ylim([0 sz(1)])
   grid on
   set(AX(6),'yAxisLocation','right')   
   h = legend('Location',get(AX(3),'position'));set(h,'box','off')
   vline(S.mean,'k--',['mean = ',num2str(S.mean)])
   ylabel('space')   

   %% temporal modes
   axes(AX(2))
   for im=S.P:-1:1
   plot(time,S.rghvec(:,im),'.-','Color',repmat(interp1([S.P 0],[0.9 0],im),[1 3]),...
                             'linewidth',       interp1([S.P 0],[1 4],im),'DisplayName',S.varLab{im});
   hold on
   end   
   xlabel('time')
   ylabel('EOF rghvec')
   datetick('x');xlim(time([1 end]))
   grid on

   set(AX(2),'xAxisLocation','top')
   set(AX(2),'yAxisLocation','right')   

   %% diff
   axes(AX(1))
   pcolor(time,1:sz(1),permute(data - dataf,[1 3 2]))
   shading interp
   xlabel('time')
   datetick('x');xlim(time([1 end]))
   ylim([0 sz(1)])
   clim(r)
   set(AX(1),'xAxisLocation','top')
   ylabel('space')
   %[ax2,h2,txt2]=colorbarwithhtext('data filled','horiz','position',get(AX(8),'position'));
   
   delete(AX([3 7:9]))

%% 3D movie for 2D spaces
elseif dim==2

   AX = subplot_meshgrid(4,2,[.08 .02 .02 .02 .08],.05,nan,[nan .05]);

   %% spatial modes
   axes(AX(4))
   for im=1:S.P
   surf(0.*S.lftvec(:,:,im)+time(im),S.lftvec(:,:,im))
   hold on
   end
   zlim([1 max(2,S.P)])
   grid on
   colorbarwithhtext('EOF leftvec','horiz','position',get(AX(8),'position'));
   shading interp
   zlabel('modes')  
   set(AX(4),'zdir','reverse')
   view(-20,10)
   set(AX(4),'ztick',1:S.P)    
  %set(AX(4),'zAxisLocation','right')  
   
   %% 1st temporal modes
   axes(AX(3))
   for im=1:S.P
   plot3(S.rghvec(:,im),time.*0,time,'.-','Color',repmat(interp1([S.P 0],[0.9 0],im),[1 3]),'DisplayName',S.varLab{im});
   hold on
   end
   ylim([-1 0])
   zlim(time([1 end]))
   grid on
   title('EOF rghvec')
   ylabel('time')
   h = legend('Location',get(AX(7),'position'));set(h,'box','off')
   view(-20,10)
   set(AX(3),'ytick',[]) 
   set(AX(3),'zticklabel',{}) 
   lim = xlim;
   plot3([lim([1 2 2 1 1])],[0 0 0 0 0],[time([1 1 end end 1])],'k')
   
   %% data
   axes(AX(1))
   caxis([min(data(:)) max(data(:))])
   d = surf(data(:,:,1).*0+time(1),data(:,:,1));
   hold on
   zlim(time([1 end]))
   grid on
   zlabel('time')
   shading interp
   clim(r)
   colorbarwithhtext('raw data','horiz','position',get(AX(5),'position'));
   view(-20,10)
   set(AX(1),'xticklabel',{})
   
   %% data filled
   axes(AX(2))
   caxis([min(data(:)) max(data(:))])
   df = surf(dataf(:,:,1).*0+time(1),dataf(:,:,1));
   hold on
   zlim(time([1 end]))
   grid on
   shading interp
   clim(r)
   colorbarwithhtext('filled data','horiz','position',get(AX(6),'position'));
   view(-20,10)
   set(AX(2),'yticklabel',{})
   set(AX(2),'zticklabel',{})   
   for it=1:nt
   
      if nt > 20
      
         set(d,'zdata',data(:,:,1 ).*0+time(im))
         set(d,'cdata',data(:,:,it))

         set(df,'zdata',dataf(:,:,1 ).*0+time(im))
         set(df,'cdata',dataf(:,:,it))
         pause(0.01)
         
      else
      
         axes(AX(1))
         surf(dataf(:,:,1).*0+it,data(:,:,it));
         shading interp
      
         axes(AX(2))
         surf(dataf(:,:,1).*0+it,dataf(:,:,it));
         shading interp

      end

   end
   
   delete(AX([5:8]))
   
end
