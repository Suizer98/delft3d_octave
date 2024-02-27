function varargout = t_tide_compare(ncmodel,ncdata,varargin)
%NC_T_TIDE_COMPARE   visualize comparison of nc_t_tide results
%
%   nc_t_tide_compare(ncmodel,ncdata,<keyword,value>)
%
% plots the results from a tidal analysis performed by
% NC_T_TIDE. ncmodel and ncdata are pairwise linked lists 
% of netCDF files (obtained with e.g. OPENDAP_CATALOG and sorted).
%
% See also: T_TIDE, NC_T_TIDE, OPENDAP_CATALOG

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2007-2012 Gerben J. de Boer, Delft, The Netherlands
%       (i)   Delft University of Technology, Fluid Mechanics Section & Deltares (Borsje et al, 2008)
%       (ii)  Deltares for Rijkswaterstaat (VOP-slib 2010)
%       (iii) Deltares for NWO (GeoRisk-PACE)
%
%       g.j.deboer@tudelft.nl / gerben.deboer@deltares.nl	
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

   OPT.export              = 0;
   OPT.directory           = pwd;
   OPT.axis                = [];
   OPT.vc                  = 'http://opendap.deltares.nl/thredds/dodsC/opendap/noaa/gshhs/gshhs_l.nc';

   OPT.plot.spectrum       = 1;
   OPT.plot.scatter        = 1;
   OPT.plot.planview       = 1;
   
   OPT.color.data          = [0 0 0];
   OPT.color.model         = [.4 .4 .4];
   OPT.color.difference    = [1 0 0];
   OPT.fontsize            = 8;

   OPT.title.fontsize      = 15;
   OPT.axes.fontsize       = 8;
   OPT.verticalalignment   = 'top' ; %[ top | cap | {middle} | baseline | bottom ]
   OPT.horizontalalignment = 'left'; %[ {left} | center | right ]
   
   OPT.pause               = 0; % after each station/netCDF fil
   OPT.names2label         = {'M2','S2','N2','M4','K1','O1','MN4','MS4','2MS6','2MN6','M6','Q1','2MK5','2SM6','MO3'};
   OPT.names2planview      = {'M2','S2','N2','M4','K1','O1','MN4','MS4','2MS6','2MN6','M6','Q1','2MK5','2SM6','MO3'};
   % scale arrows to be of same size: scale with inverse of amplitude
   OPT.names2planviewscale = [0.16 0.68 0.74 0.79 0.90 1.04 1.06  1.07  1.57   1.78   1.82 2.15 3.90    5.49  8.40 ]; % 1 over Petten harmonics
   OPT.amp_min             = 0.01; %[0.005];
   OPT.ddatenumeps         = 1e-8;
  %OPT.verticaloffset      = []; %[1 1 1 2 1 1 1 1 1 1 1 1]; % plots the text for the specified station at the #th line (1 = normal 1st line)
   OPT.eps                 = 10*eps;
   
   OPT = setproperty(OPT,varargin{:});
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
%% Initialize

   FIG.spectrum = figure('name','spectrum');
   FIG.scatter  = figure('name','scatter');

   if OPT.plot.planview
      for icomp=1:length(OPT.names2planview)
      FIGS(icomp) = figure('name',['planview_',OPT.names2planview{icomp}]);
      end
   end
   
%% Station loop

   nfiles = length(ncmodel);
   if ischar(OPT.verticalalignment);val = OPT.verticalalignment;OPT.verticalalignment = {};
      for ifile=1:nfiles, OPT.verticalalignment{ifile}=val;end
   end
   
   if ischar(OPT.horizontalalignment);val = OPT.horizontalalignment;OPT.horizontalalignment = {};
      for ifile=1:nfiles, OPT.horizontalalignment{ifile}=val;end
   end   

   for ifile=1:nfiles
   
   %% LOAD data

     [M,Ma] = nc2struct(ncmodel{ifile});% Load model    data
     [D,Da] = nc2struct(ncdata{ifile}) ;% Load observed data
     D.title = '';
     if isfield(D,'platform_name')
         D.platform_name = make1D(char(D.platform_name))';
         D.title = [D.title,D.platform_name];
     elseif isfield(M,'platform_name')
         D.platform_name = make1D(char(M.platform_name))';
         D.title = [D.title,D.platform_name];
     end
     
     if isfield(D,'platform_id')
        D.platform_id   = make1D(char(D.platform_id  ))';
        D.title = [D.title,' (', D.platform_name,') '];
     elseif isfield(M,'platform_id')
        D.platform_id   = make1D(char(M.platform_id  ))';
        D.title = [D.title,' (', D.platform_name,') '];
     end
     
     if isfield(D,'longitude') & isfield(D,'latitude')
     if abs(M.longitude - D.longitude) > OPT.eps;error('lon coordinates of model and data do not match');end
     if abs(M.latitude  - D.latitude ) > OPT.eps;error('lat coordinates of model and data do not match');end
     D.title = [D.title,'[',...
                num2str(D.longitude),'\circ E, ',...
                num2str(D.latitude ),'\circ N]'];
     elseif isfield(M,'longitude') & isfield(M,'latitude')
     D.title = [D.title,'[',...
                num2str(M.longitude),'\circ E, ',...
                num2str(M.latitude ),'\circ N]'];
     end
     
   %% SCATTER plot

      if OPT.plot.scatter
      
         figure(FIG.scatter);clf
            
      %% SCATTER component loop
      
         for dcomp = 1:size  (D.fmaj,1);
             mcomp = strmatch(D.component_name(dcomp,:),...
                              M.component_name);
                             
            if ~isempty(mcomp)     
            
            if D.fmaj(dcomp) > OPT.amp_min;
         
               name = lower(deblank(D.component_name(dcomp,:)));
               tmp  = strmatch(name,OPT.names2label);
         
               subplot(1,2,1)
               loglog(D.fmaj  (dcomp),...
                      M.fmaj  (mcomp),'k+')
               hold on
               if ~isempty(tmp)
               plot(D.fmaj(dcomp),M.fmaj(mcomp),'ko')
         
               %% draw name at side where not 45 degree line is located
               loc = sign(D.fmaj(dcomp) - M.fmaj(mcomp));
               if loc < 0
               text(D.fmaj(dcomp),M.fmaj(mcomp),...
                    [name,'     '],'rotation',-45,'horizontalalignment','right')
               else
               text(D.fmaj(dcomp),M.fmaj(mcomp),...
                    ['     ',name],'rotation',-45)
               end
               end
	       
               subplot(1,2,2)
               plot(D.pha(dcomp),...
                    M.pha(mcomp),'k+')
               hold on
               if ~isempty(tmp)
               plot(D.pha(dcomp),M.pha(mcomp),'ko')
         
               %% draw name at side where not 45 degree line is located
               loc = sign(D.pha(dcomp) - M.phase(mcomp));
               if loc < 0
               text(D.phase(dcomp),M.pha(mcomp),...
                    [name,'     '],'rotation',-45,'horizontalalignment','right')
               else
               text(D.pha(dcomp),M.pha(mcomp),...
                    ['     ',name],'rotation',-45)
               end
               end
            end
            
            end
         
         end
         
      %% SCATTER lay-out

        subplot(1,2,1)
         xlims = [5e-3 1];
         ylims = [5e-3 1];
         plot(xlims,     ylims,'-k')
         plot(xlims,0.9.*ylims,'-k')
         plot(xlims,1.1.*ylims,'-k')
         
         axis equal
         grid on
         xlabel([ 'data amplitude [',mktex(Da.fmaj.units),']'],'Interpreter','none')
         ylabel(['model amplitude [',mktex(Da.fmaj.units),']'],'Interpreter','none')
         xlim(xlims)
         ylim(ylims)
         plot(xlims       ,ylims + 0.01,'-','color',[.5 .5 .5])
         plot(xlims       ,ylims       ,'-','color',[.5 .5 .5])
         plot(xlims + 0.01,ylims       ,'-','color',[.5 .5 .5])
         
         title(D.title)
         
        subplot(1,2,2)
         xlims = [0 360];
         ylims = [0 360];
         for ddeg = [0 -360 360]
         plot(xlims,ylims + 10 + ddeg,'-k')
         plot(xlims,ylims      + ddeg,'-k')
         plot(xlims,ylims - 10 + ddeg,'-k')
         plot(xlims,ylims + 20 + ddeg,'-k','color',[.5 .5 .5])
         plot(xlims,ylims      + ddeg,'-k','color',[.5 .5 .5])
         plot(xlims,ylims - 20 + ddeg,'-k','color',[.5 .5 .5])
         end
         axis equal
         grid on
         xlim(xlims)
         ylim(ylims)
         set(gca,'xtick',[0:90:360]);
         set(gca,'ytick',[0:90:360]);
         title([datestr(udunits2datenum(M.period(  1),Ma.period.units),'yyyy-mmm-dd'),' \rightarrow ',...
                datestr(udunits2datenum(M.period(end),Ma.period.units),'yyyy-mmm-dd')])
         if ~isequal(D.period,M.period)
         xlabel({'data phase [deg]',...
                [datestr(udunits2datenum(D.period(  1),Da.period.units),'yyyy-mmm-dd'),' \rightarrow ',...
                 datestr(udunits2datenum(D.period(end),Da.period.units),'yyyy-mmm-dd')]});
         else
         xlabel( 'data phase [deg]')
         end
         ylabel('model phase [deg]')
         
        if OPT.export
         text(1,0,mktex('Created with t_tide (Pawlowicz et al, 2002) & OpenEarthTools <www.OpenEarth.eu>'),'rotation',90,'units','normalized','verticalalignment','top','fontsize',6)
         basename = [OPT.directory,filesep,'scatter',filesep,filename(ncmodel{ifile})];
         print2screensizeoverwrite([basename,'_scatter.png'])
        %print2screensizeeps      ([basename,'_scatter.eps'])
        end
         
        disp(['processed station file ',num2str(ifile,'%0.4d'),' of ',num2str(nfiles,'%0.4d')])

      end % OPT.plot.scatter

   %% SPECTRUM plot

      if OPT.plot.spectrum
      
         figure(FIG.spectrum);clf
         
         ncomp_plotted{1} = 0;
         ncomp_plotted{2} = 0;
         ncomp_plotted{4} = 0;
         ncomp_plotted{6} = 0;
         
      %% SPECTRUM component loop
         
         for dcomp = 1:size  (D.fmaj,1);
             mcomp = strmatch(D.component_name(dcomp,:),...
                              M.component_name);
                             
            if ~isempty(mcomp)     
            if D.fmaj(dcomp) > OPT.amp_min & ...
               M.fmaj(mcomp) > OPT.amp_min;

            %disp([D.component_name(dcomp,:) M.component_name(mcomp,:)])
            %disp(num2str([M.fmaj(mcomp) D.fmaj(dcomp)]))
            
         
               if (D.frequency(dcomp) > 0     & ...
                   D.frequency(dcomp) < 2/24) % 1
                  ncomp_plotted{1} = ncomp_plotted{1} + 1;
                  spaces           = repmat(' ',[1 ceil(ncomp_plotted{1}./2)]);
                  leftright        = odd(ncomp_plotted{1});
           elseif (D.frequency(dcomp) > 1/24  & ...
                   D.frequency(dcomp) < 3/24) % 2
                  ncomp_plotted{2} = ncomp_plotted{2} + 1;
                  spaces           = repmat(' ',[1 ceil(ncomp_plotted{2}./2)]);
                  leftright        = odd(ncomp_plotted{2});
           elseif (D.frequency(dcomp) > 3/24  & ...
                   D.frequency(dcomp) < 5/24) % 4
                  ncomp_plotted{4} = ncomp_plotted{4} + 1;
                  spaces           = repmat(' ',[1 ceil(ncomp_plotted{4}./2)]);
                  leftright        = odd(ncomp_plotted{4});
           elseif (D.frequency(dcomp) > 5/24  & ...
                   D.frequency(dcomp) < 7/24) % 6
                  ncomp_plotted{6} = ncomp_plotted{6} + 1;
                  spaces           = repmat(' ',[1 ceil(ncomp_plotted{6}./2)]);
                  leftright        = odd(ncomp_plotted{6});
               end                  

               name  = lower(deblank(D.component_name(dcomp,:)));
               icomp = strmatch(name,lower(OPT.names2planview));
               
               if ~isempty(icomp)
               
               subplot(2,1,1)

            %% harmonic (incl. nodal)

               plot([M.frequency(mcomp)],...
                    [M.fmaj(mcomp)],'k.','markersize',8)
               hold on
               plot([M.frequency(mcomp)],...
                    [D.fmaj(dcomp)],'ko','markersize',6)
               plot([M.frequency(mcomp) M.frequency(mcomp)],...
                    [M.fmaj(mcomp) D.fmaj(dcomp)],'k-')
               if leftright
               text([M.frequency(mcomp)],...
                    [D.fmaj(dcomp)],[' ',spaces,name])
               else
               text([M.frequency(mcomp)],...
                    [D.fmaj(dcomp)],[name,spaces,' '],'horizontalalignment','right')
               end
               
               xlim([0 0.3]);
               ylim([5e-3 1]);

               subplot(2,1,2)
               plot([M.frequency(mcomp)],...
                    [M.pha(mcomp)],'k.','markersize',8)
               hold on
               plot([M.frequency(mcomp)],...
                    [D.pha(dcomp)],'ko','markersize',6)

               if leftright
               text([M.frequency(mcomp)],...
                    [D.pha(dcomp)],[' ',spaces,name])
               else
               text([M.frequency(mcomp)],...
                    [D.pha(dcomp)],[name,spaces,' '],'horizontalalignment','right')
               end
               
               difference = M.pha(mcomp)  - ...
                            D.pha(dcomp);
               
               xlim([0 0.3]);

               if (abs(difference) < 180)
               plot([ M.frequency(mcomp) M.frequency(mcomp)],[M.pha(mcomp) D.pha(dcomp)],'k-')
               else
               maximum = max([D.pha(dcomp) M.pha(mcomp)]);
               minimum = min([D.pha(dcomp) M.pha(mcomp)]);
               plot    ([ M.frequency(mcomp) M.frequency(mcomp)],[0       minimum],'k-')
               plot    ([ M.frequency(mcomp) M.frequency(mcomp)],[maximum 360    ],'k-')
               end
               
               end % icomp
               
            end
            end
         end      
         
      %% SPECTRUM lay-out

         subplot(2,1,1)
         title(D.title)

         xlim([.02 .27])
         set(gca,'xtick',[1 2 3 4 5 6]./24)
         set(gca,'xticklabel',{'1/24','1/12','1/8','1/6','5/24','1/4'})
         set(gca,'yscale','log')

         grid on
         ylabel(['Amplitude [',Da.fmaj.units,']'],'Interpreter','none')

         legend('model','data')

         subplot(2,1,2)
         ylim([0 360])

         xlim([.02 .27])
         set(gca,'xtick',[1 2 3 4 5 6]./24)
         set(gca,'xticklabel',{'1/24','1/12','1/8','1/6','5/24','1/4'})
         set(gca,'ytick',[0:45:360])

         grid on
         xlabel(['Frequency [',Da.frequency.units,']'],'Interpreter','none')
         ylabel(    ['Phase [',Da.pha.units    ,']'],'Interpreter','none')
         
         if OPT.export
         text(1,0,mktex('Created with t_tide (Pawlowicz et al, 2002) & OpenEarthTools <www.OpenEarth.eu>'),'rotation',90,'units','normalized','verticalalignment','top','fontsize',6)
         basename = [OPT.directory,filesep,'spectrum',filesep,filename(ncmodel{ifile})];
         print2screensizeoverwrite([basename,'_spectrum.png'])
        %print2screensizeeps      ([basename,'_spectrum.eps'])
         saveas         (gcf,[basename,'_spectrum.fig'],'fig')
         end
         
      
      end
      
   %% PLANVIEW plot

      if OPT.plot.planview
      
      %% PLANVIEW component loop

         for dcomp = 1:size  (D.fmaj,1);
             mcomp = strmatch(D.component_name(dcomp,:),...
                              M.component_name);
                             
            if ~isempty(mcomp)     
            if D.fmaj(dcomp) > OPT.amp_min;
         
               name  = lower(deblank(D.component_name(dcomp,:)));
               icomp = strmatch(name,lower(OPT.names2planview));
               
               if ~isempty(icomp)
               
               %disp([mfilename,' : ',char(name),' - ',num2str(icomp),' - ',num2str(OPT.names2planviewscale(icomp))])
               
               %               data | model
               % amplitude     x    |  x
               % phase         x    |  x
               
               figure(FIGS(icomp))
               plot(D.longitude(1),D.latitude(1),'k.')
               hold on

               txt.D.amp = pad(num2str(D.fmaj(dcomp),'%4.2f'),5,' ');
               txt.D.pha = pad(num2str(D.pha (dcomp),'%4.1f'),5,' ');
               
               txt.M.amp = pad(num2str(M.fmaj(mcomp),'%4.2f'),5,' ');
               txt.M.pha = pad(num2str(M.pha (mcomp),'%4.1f'),5,' ');
               
               try;txt.D = rmfield(txt.D,'both');end
               try;txt.M = rmfield(txt.M,'both');end

               %if ~isempty(OPT.verticaloffset)
               %   txt.D.both{OPT.verticaloffset(ifile)  } = [txt.D.amp  ,' ',Da.fmaj.units,' | ',txt.D.pha,' ',Da.pha.units];
               %   txt.M.both{OPT.verticaloffset(ifile)+1} = [txt.M.amp  ,' ',Ma.fmaj.units,' | ',txt.M.pha,' ',Ma.pha.units];
               %   txt.M.both{OPT.verticaloffset(ifile)+2} = [char(D.platform_id)];
               %else
                  txt.D.both{1}                           = [txt.D.amp  ,' ',Da.fmaj.units,' | ',txt.D.pha,' ',Da.pha.units];
                  txt.M.both{2}                           = [txt.M.amp  ,' ',Ma.fmaj.units,' | ',txt.M.pha,' ',Ma.pha.units];
                  txt.M.both{3}                           = [char(D.platform_id)];
               %end
               
               text(D.longitude(1),D.latitude(1),'.')
               text(D.longitude(1),D.latitude(1),txt.D.both,'verticalalignment',OPT.verticalalignment{ifile},'color',OPT.color.data ,'horizontalalignment',OPT.horizontalalignment{ifile},'fontsize',OPT.fontsize);
               text(D.longitude(1),D.latitude(1),txt.M.both,'verticalalignment',OPT.verticalalignment{ifile},'color',OPT.color.model,'horizontalalignment',OPT.horizontalalignment{ifile},'fontsize',OPT.fontsize);
%                quiver(D.longitude(1),D.latitude(1),...
%                       D.fmaj(dcomp).*cosd(D.pha(dcomp)).*scale,...
%                       D.fmaj(dcomp).*sind(D.pha(dcomp)).*scale,0,'color',OPT.color.data )
%                quiver(D.longitude(1),D.latitude(1),...
%                       M.fmaj(mcomp).*cosd(M.pha(mcomp)).*scale,...
%                       M.fmaj(mcomp).*sind(M.pha(mcomp)).*scale,0,'color',OPT.color.model)
               
               if ~isempty(OPT.axis)
                  axislat(mean(OPT.axis(3:4)))
                  axis([OPT.axis])
               else
                  axislat
                  axis tight
               end     
               
               S = arrow2;S.W4 = 0.1;S.W5 = 0.0;
               S.ArrowAspectRatio = daspect;
               S.scale = OPT.names2planviewscale(icomp);
               
               ud = D.fmaj(dcomp).*cosd(D.pha(dcomp));
               vd = D.fmaj(dcomp).*sind(D.pha(dcomp));
               um = M.fmaj(mcomp).*cosd(M.pha(mcomp));
               vm = M.fmaj(mcomp).*sind(M.pha(mcomp));
               
               S.color = OPT.color.data;
               arrow2(D.longitude(1),D.latitude(1),ud   ,vd   ,S)
               S.color = OPT.color.model;  
               arrow2(D.longitude(1),D.latitude(1),um   ,vm   ,S)
               S.color = OPT.color.difference;  
               arrow2(D.longitude(1),D.latitude(1),um-ud,vm-vd,S)
               end
               
            end
            end
         end
         
      end % if OPT.plot.planview
      
   %% Pause

      if OPT.pause
      disp('Press key to continue ...')
      pause
      end

   end % Station loop

%% PLANVIEW lay-out (NB after Station loop)

   if OPT.plot.planview
   
      if ~isempty(OPT.vc);
         try % if http and you're not connected
         L.lon = nc_varget(OPT.vc,'lon');
         L.lat = nc_varget(OPT.vc,'lat');
         catch
         L.lon = [];
         L.lat = [];
         end
      end

      for icomp=1:length(OPT.names2planview)
   
         figure(FIGS(icomp))
         
         if ~isempty(OPT.axis)
            axislat(mean(OPT.axis(3:4)))
            axis([OPT.axis])
         else
            axislat
            axis tight
         end
         
         tickmap('ll','format','%0.1f')
         h = title({[upper(OPT.names2planview{icomp}),'    \color[rgb]{',num2str(OPT.color.data ),'}^{data}',...
                                                          '\color[rgb]{',num2str(OPT.color.model),'}_{model}']});
         set(h  ,'fontSize',OPT.title.fontsize)
         set(gca,'fontSize',OPT.axes.fontsize );
         if ~isempty(OPT.vc)
            plot(L.lon,L.lat,'color',[.7 .7 .7]);
         end
         hold on
         
         if OPT.export
         text(1,0,mktex('Created with t_tide (Pawlowicz et al, 2002) & OpenEarthTools <www.OpenEarth.eu>'),'rotation',90,'units','normalized','verticalalignment','top','fontsize',6)
         annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);
         
         % extract unique basename
         ind = find(~all(diff(filename(ncmodel),[],1)==0,1));
         if isempty(ind) | (ind==1)
            basename = mfilename;
         else
            basename = filename(ncmodel{1});
            basename = basename(1:ind(1)-1);
         end
         basename = [OPT.directory,filesep,'planview',filesep,basename];
         
         print2screensizeoverwrite([basename,'_plan_',OPT.names2planview{icomp},'.png'])
         end
         
      end
   
   end
