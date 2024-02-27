%DELFT3D_WAQ_GETFETCH4WAQ_ANALYTICAL   script to calculate fetch from landboundary on flow grid
%
% For every point, per sector of say 5 degree, all landboundary points are binned.
% The smallest value per bin is taken as the fetch. When the landboundary points
% are too widely spaced, the nearest shoreline
%
%                      ||  /          //               
%                      *a/          // the landboundary 
%                      ||         //                   
%                    / ||       //                      
%                  /   ||      *f the landboundary support points that are binned
%                /     *b      ||                        
%              /        \\     ||                       
%   the grid +           \\    ||                        
%   piont      \           *c  ||                       
%   center       \         ||  ||                       
%                  \       ||  *e                        
%                    \     ||  ||                       
%                      \   ||  ||                       
%                        \ ||  ||                      
%                          ||  ||                      
%                          ||\ ||                      
%                          ||  ||                      
%                          ||  ||\                     
%                          *d==*e  \ the sector limit  
%                                                      
%   piont *b is closest and is considered the fetch       
%   note that if point *b and *c were absent, point *e 
%   would be considered closest, because the sector would peer
%   through the line *a-*d. Therefore the landboundary
%   needs sufficient support points. The function FILLUPLDB
%   is called to ansure that the maximal hole between 2 support 
%   points is half the minimum grid cell size. For a narrow sector 
%   along the grid boundary this still gives erronous points.
%   This still HAS TO BE RESOLVED, although the subsequent binning
%   to 45 degree wide bins makes this invisible.
%
% Make sure that ALL center points are inside the POLYGONS.
% Make sure that you minimize the numeber of landboundary segments for best performance!!
%
% © Deltares, Q4408, Gerben J. de Boer <gerben.deboer@deltares.nl>, Jun-Jul. 2008
% ----------------------------------------------------
% Any missing m=files are in:
% * cd Y:\app\matlab\toolbox\
% * wlsettings
% * cd P:\mctools\mc_toolbox\
% * mcsettings
% ----------------------------------------------------

% $Id: delft3d_waq_getFetch4waq_analytical.m 2391 2010-03-30 16:52:40Z boer_g $
% $Date: 2010-03-31 00:52:40 +0800 (Wed, 31 Mar 2010) $
% $Author: boer_g $
% $Revision: 2391 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/delft3d_waq_getFetch4waq_analytical.m $

   %% Ini
   %% ------------------

  %OPT.ldbs            ={'D:\PROJECTS\q4408-mkm\flow\matlab\ldb\confined008_polygon4fetch2.ldb_sc02_ks005_damsonly.ldb',...

   OPT.ldbs            ={'D:\PROJECTS\q4408-mkm\flow\matlab\ldb\confined008_polygon4fetch2.ldb_sc04_ks005_damsonly.ldb',...
                         'D:\PROJECTS\q4408-mkm\flow\matlab\ldb\confined008_polygon4fetch2.ldb_sc05_ks005_damsonly.ldb',...
                         'D:\PROJECTS\q4408-mkm\flow\matlab\ldb\confined008_polygon4fetch2.ldb_sc06_ks005_damsonly.ldb',...
                         'D:\PROJECTS\q4408-mkm\flow\matlab\ldb\confined008_polygon4fetch2.ldb_sc07_ks005_damsonly.ldb',...
                         'D:\PROJECTS\q4408-mkm\flow\matlab\ldb\confined008_polygon4fetch2.ldb_sc10_ks005_damsonly.ldb',...
                         'D:\PROJECTS\q4408-mkm\flow\matlab\ldb\confined008_polygon4fetch2.ldb',...
                         }

   OPT.ldbs            ={'D:\PROJECTS\q4408-mkm\flow\matlab\ldb\confined008_polygon4fetch2.ldb_sc04_ks005_damsonly.ldb',...
                         'D:\PROJECTS\q4408-mkm\flow\matlab\ldb\confined008_polygon4fetch2.ldb_sc10_ks005_damsonly.ldb',...
                         }

      OPT.grd          = 'P:\q4408-mkm\flow\cb005\confined008.grd'; %flow grid

     %OPT.imagedir     = 'D:\PROJECTS\q4408-mkm\flow\matlab\png_fetch\';
      OPT.imagedir     = 'P:\q4408-mkm\flow\matlab\png_fetch\';

      OPT.debug        = [1 0]; % for all sectors, for one sectors
      OPT.pause        = 0; % during debug, 0 prints output for OPT.debug(1)
      OPT.export       = 1;
      OPT.dth          = 5; % WAQ can handle only 8 bins (45 deg), so get info for narrow bins and aggregate afterwards
                            % this takes order 12 hours, note that the ldb should be as coarse as possible
                            
      OPT.save2map     = 0;
      OPT.save2dep     = 1;
      OPT.plot.sectors = 1;
      OPT.plot.waq     = 1;      
      OPT.sector       = 1;  % 1= calculate, 2 = load, because calculating TAKES LONG
      OPT.minfetch     = 50; % with a fetch of 0 m WAQ crashes
      OPT.ds           = [] ;% max distance to fill up ldb, set [] for min grid size
      
   %% Specify sectors
   %% ------------------

      climate.cor.th = deg2rad([(-180):OPT.dth:(180)]);
      climate.cor.r  = [0 100e3];

      climate.nth    = length(climate.cor.th)-1; % defined per bin, so @ bin center
         
     [climate.cor.th,...
      climate.cor.r] = meshgrid     (climate.cor.th,...
                                     climate.cor.r);
      climate.cen.th = corner2center(climate.cor.th);
      climate.cen.r  = corner2center(climate.cor.r );


   %% Read grid
   %% ------------------

      G              = delft3d_io_grd('read',OPT.grd);
      
   for ildb=1:length(OPT.ldbs)   
   
      %% Determine results per narrow sector
      %% ------------------
   
         OPT.ldb = OPT.ldbs{ildb};
         basedir = [OPT.imagedir,filesep,filename(OPT.ldb),filesep];
   
      %% Read and refine landboundary
      %% ------------------
      
         [L.x,L.y]      = landboundary('read',OPT.ldb);
         
      %% Grid points loop
      %% ------------------
      
      if     OPT.sector==2
      
         B = load([basedir,'fetch_',filename(OPT.grd),'_',filename(OPT.ldb),'_dth',num2str(OPT.dth),'deg_analytical.mat']);
         
      elseif OPT.sector==1
      
         B.cen.fetch = repmat(nan,[G.nmax-2 G.mmax-2 climate.nth]);
      
         for m= 2:G.mmax-2 % no dummy row/col
         for n= 2:G.nmax-2 % no dummy row/col
         disp(['processing  (m,n) = (',num2str(m),',',num2str(n),') of (',num2str(G.mmax),',',num2str(G.nmax),')'])
         
         PNT.x = G.cen.x(n,m);
         PNT.y = G.cen.y(n,m);
            
         if ~isnan(PNT.x) | ~isnan(PNT.y)
         
            for ith=1:length(climate.cen.th)
            
           %disp(['   processing  th = ',num2str(ith,length(climate.cen.th)),' of ',num2str(length(climate.cen.th))])
   
            dr       = 1000e3;
            dx       = cos(climate.cen.th(ith)).*dr;
            dy       = sin(climate.cen.th(ith)).*dr;
            
            PNT.x(2) = PNT.x(1) + dx;
            PNT.y(2) = PNT.y(1) + dy;      
         
           % SLOW
           %[CR.x, CR.y] = findCrossingsOfPolygonAndPolygon(PNT.x,PNT.y,L.x,L.y);
           % SLOW
           %[CR.x, CR.y] = findCrossingsOfPolygonAndPolygon(PNT.x,PNT.y,L.x,L.y);
           % SLOW
            [CR.x, CR.y] = polyintersect(PNT.x,PNT.y,L.x,L.y); %,'debug',1
            
            %% Debug
            %% ------------------
            
               if OPT.debug(2)
                  TMP1 = figure;
                  setfig2screensize
                  grid_plot(G.cor.x,G.cor.y,'color',[.5 .5 .5])
                  axis equal
                  hold on
                  plot(L.x,L.y,'b')
                  
                  axis tight
   
                  plot(PNT.x,PNT.y,'k-o','MarkerFaceColor','k')
                  
                  plot(CR.x, CR.y,'ro')
                  plot(CR.x, CR.y,'r.')
                  title(['(m,n) = (',num2str(m),',',num2str(n),')'])
   
                  if OPT.pause==1
                     disp('Press key to continue ...')
                     pause
                  end
                  try
                     close(TMP1)
                  end
               end
               
               %% for multiple crosssings, find closest, with shortest fetch
               
               CR.r     = sqrt((CR.x  - PNT.x(1)).^2 + ...
                               (CR.y  - PNT.y(1)).^2);
                                     
               CR.th    = atan2(CR.y  - PNT.y(1),...
                                CR.x  - PNT.x(1));  
               
               %% Store fetch length, and associated coordinate on landboudnary
               %% if there is no intersection (flow center point is on land, or direction point towards open sea)
               %% store NaN (or Inf/0 ?) for Fetch, and NaN for intersection.
   
               if ~isempty(CR.r)
              [B.cen.fetch(n,m,ith),index] = nanmin(CR.r);
               B.cen.x    (n,m,ith)        = CR.x(index);
               B.cen.y    (n,m,ith)        = CR.y(index);
              else
               B.cen.fetch(n,m,ith)        = nan;
               B.cen.x    (n,m,ith)        = nan;
               B.cen.y    (n,m,ith)        = nan;
               end
   
            end
   
           if OPT.debug(1)
              TMP1 = figure;
              setfig2screensize
              grid_plot(G.cor.x,G.cor.y,'color',[.5 .5 .5])
              axis equal
              hold on
              plot(L.x,L.y,'b')
              
              axis tight
           
              for ith=1:size(B.cen.x,3)
              plot([PNT.x(1) B.cen.x(n,m,ith)],...
                   [PNT.y(1) B.cen.y(n,m,ith)],'r-o');
           
              end
              title(['(m,n) = (',num2str(m),',',num2str(n),')'])
              
              if OPT.pause==1
                 disp('Press key to continue ...')
                 pause
              else
                 if OPT.export
                 print2screensize([basedir,'per_cell',filesep,'fetch_',filename(OPT.grd),'_',filename(OPT.ldb),'_dth',num2str(OPT.dth),'deg_th',num2str(round(angle2domain(rad2deg(climate.cen.th(ith)),0,360)),' %0.3d'),'_m_',...
                 num2str(m,'%0.3d'),'_n_',num2str(n,'%0.3d'),'_analytical.png'])
                 end              
              end
              try
                 close(TMP1)
              end
           end
         
         end % isnan
         end % for m=1:G.mmax
         end % for n=1:G.nmax
         
         %% Save
         %% ------------------
      
         mkpath(basedir)
         save([basedir,'fetch_',filename(OPT.grd),'_',filename(OPT.ldb),'_dth',num2str(OPT.dth),'deg_analytical.mat'],'-struct','B');
      
      end % OPT.sector
      
      %% Check result per narrow sector
      %% ------------------
     
      if OPT.plot.sectors
         OPT.scale = 5e3;
         for ith=1:length(climate.cen.th)
        
            hold off
            plot(L.x,L.y,'k.-')
            hold on
            Z = B.cen.fetch(:,:,ith)./1e3;
            Z(isnan(Z))=0;
            pcolorcorcen(G.cor.x,G.cor.y,Z);
            title(['Wind from : ',num2str(rad2deg(climate.cen.th(ith))),'\circ'])
            axis equal
            colorbarwithtitle('fetch [km]')
         
            quiver2(150e3,487.5e3,cos(climate.cen.th(  ith  )),...
                                  sin(climate.cen.th(  ith  )),OPT.scale,'r')
            
            quiver2(150e3,487.5e3,cos(climate.cor.th(1,ith  )),...
                                  sin(climate.cor.th(1,ith  )),OPT.scale,'k')
            quiver2(150e3,487.5e3,cos(climate.cor.th(1,ith+1)),...
                                  sin(climate.cor.th(1,ith+1)),OPT.scale,'k')
                                  
            axis tight
            tickmap('xy','texttype','text','dellast',1)                              
            grid on
            text(1,0,'© Deltares, GJdB, 2008 ','rotation',90,'fontsize',8,'units','normalized','verticalalignment','top','fontsize',6)
                                  
            if OPT.export
            print2screensize([basedir,'fetch_',filename(OPT.grd),'_',filename(OPT.ldb),'_dth',num2str(OPT.dth),'deg_th',num2str(round(angle2domain(rad2deg(climate.cen.th(ith)),0,360)),' %0.3d'),'_analytical.png'])
            end
            
         end
      end
     
     %% Aggregate to fewer bins (8)
     %% ------------------
     
        %% we always use the max number of bins allowed in WAQ< i.e. 8
        %% Note that WAQ is in deg N, while we used cartesian here
        %% also take dummy rows now into into account
        
        waq.th.edge   = deg2rad(-180:45:180);
        waq.cen.fetch = repmat(nan,[G.nmax G.mmax 8]); % incl dummy rows
        
        for ibin=1:length(waq.th.edge)-1
        
           indices = find(climate.cen.th > waq.th.edge(ibin  ) & ...
                          climate.cen.th < waq.th.edge(ibin+1));
                
          %waq.cen.fetch(2:end-1,2:end-1,ibin) =  median(B.cen.fetch(:,:,indices),3);    % does not work
           waq.cen.fetch(2:end-1,2:end-1,ibin) =  mean  (B.cen.fetch(:,:,indices),3);
          %waq.cen.fetch(2:end-1,2:end-1,ibin) =  max   (B.cen.fetch(:,:,indices),[],3); % does not work
          %waq.cen.fetch(2:end-1,2:end-1,ibin) =  min   (B.cen.fetch(:,:,indices),[],3); % does not work
        
              if OPT.plot.waq
                  OPT.scale = 5e3;
                  hold off
                  plot(L.x,L.y,'k.-')
                  hold on
                  pcolorcorcen(G.cor.x,G.cor.y,waq.cen.fetch(2:end-1,2:end-1,ibin)./1e3);
                  title({['Wind from ',...
                          num2str(   rad2deg(waq.th.edge(ibin  ))),' to ',...
                          num2str(   rad2deg(waq.th.edge(ibin+1))),'\circ cartesian = '],...
                         [num2str(90-rad2deg(waq.th.edge(ibin+1))),' to ',...
                          num2str(90-rad2deg(waq.th.edge(ibin  ))),'\circ waq']})
                  axis equal
                  colorbarwithtitle('fetch [km]')
           	    
                  quiver2(150e3,487.5e3,cos(waq.th.edge(1,ibin  )),...
                                        sin(waq.th.edge(1,ibin  )),OPT.scale,'k')
                  quiver2(150e3,487.5e3,cos(waq.th.edge(1,ibin+1)),...
                                        sin(waq.th.edge(1,ibin+1)),OPT.scale,'k')
                                    
                  axis tight
                  tickmap('xy','texttype','text','dellast',1)                              
                  grid on
                  text(1,0,'© Deltares, GJdB, 2008 ','rotation',90,'fontsize',8,'units','normalized','verticalalignment','top','fontsize',6)
   
                  if OPT.export
                  print2screensize([basedir,'fetch_',filename(OPT.grd),'_',filename(OPT.ldb),'_dth',num2str(OPT.dth),'deg_',...
                                    num2str(round(angle2domain(90-rad2deg(waq.th.edge(ibin+1)),-1,359)),' %0.3d'),'_',...
                                    num2str(round(angle2domain(90-rad2deg(waq.th.edge(ibin  )),-1,359)),' %0.3d'),'_degN_analytical.png'])
                  end
                                   
              end
           
        end;
        
        mask                = isnan(waq.cen.fetch);
        waq.cen.fetch(mask) = OPT.minfetch;
        waq.cen.fetch(mask) = min(waq.cen.fetch(mask),OPT.minfetch);
     
     %% Write to *.dep files, one per sector
     %% ------------------
     
     %    WAQ bins          cartesian bins of waq. and climte. structs
     %                 
     %       8 | 1            7 | 6   
     %     7       2        8       5 
     %     --     --        --     -- 
     %     6       3        1       4 
     %       5 | 4            2 | 3   
     %                 
     %                 
     
     if OPT.save2dep % waq cannot read this as *.map
     
        sector = 1;
     
        for ibin=1:length(waq.th.edge)-1
        
           basefname = [basedir,'fetch_',filename(OPT.grd),'_',filename(OPT.ldb),'_dth',num2str(OPT.dth),'deg_',...
                        num2str(round(angle2domain(90-rad2deg(waq.th.edge(ibin+1)),-1,359)),' %0.3d'),'_',...
                        num2str(round(angle2domain(90-rad2deg(waq.th.edge(ibin  )),-1,359)),' %0.3d'),'_degN_analytical.qin'];
           
           OK    = delft3d_io_dep('write',basefname,waq.cen.fetch(:,:,ibin),'location','cen','nodatavalue',-999);
     
           sector = sector + 1;
     
        end;
     
     end % if OPT.save2map
     
   end % for ildb=1:length(OPT.ldbs)   
   
%% EOF
