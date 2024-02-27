%function delft3d_3d_visualisation_example(varargin)
%DELFT3D_3D_VISUALISATION_EXAMPLE   Example to make 3D graphics from delft3d trim file
%
% For large grids with time variation, the resulting kml
% files are way too bi, try instead: vs_trim_to_kml_tiled_png.
%
%See also: VS_MESHGRID3DCORCEN, VS_TIME, VS_LET_SCALAR, VS_LET_VECTOR_CEN, vs_trim_to_kml_tiled_png

%% settings

   OPT.directory = 'H:\delft\DELFT3D\tide_neap_wind\';
   OPT.RUNIDs    = {'d17','w17','e17','p17',  'd77','w77','e77','p77',  'd27','w27','e27','p27',  'd37','w37','e37','p37',  'u17'}; % {}; % 
   OPT.export    = 1;
   OPT.pause     = 0;
   OPT.uvscale   = 1e4; % 1 m/s becomes x m
   OPT.wscale    = 2e3; % 1 m/s becomes x m
   OPT.axis      = [-50e3 0 0 100e3 -20 2];
   
   OPT.clim      = [25 35];
   OPT.scalar    = 'salinity'
   OPT.title     = 'salinity [psu]';

   OPT.clim      = [11.5 12.5];
   OPT.scalar    = 'temperature';
   OPT.title     = 'temperature [\circ C]';

%% spatial subset settings
%  plot not all point as matlab is too slow for that,
%  and the human mind too limited

   OPT.dm   =  5; % cross shore stride
   OPT.dn   = 25; % along shore stride
   OPT.dk   = 3;  % sigma layer stride

   OPT.mmin = 52;
   OPT.mmax = 151;
   OPT.nmin = 1;
   OPT.nmax = 210;
   
for iRUNID=1:length(OPT.RUNIDs)

   OPT.RUNID = OPT.RUNIDs{iRUNID};
 
%% load and plot

   H = vs_use([OPT.directory,filesep,'trim-',OPT.RUNID,'.dat']);
   T = vs_time(H);
   G = vs_meshgrid2dcorcen(H);
   
   G.cen.dep =-20 + 0.*G.cen.x; % error: No sensible depth data on trim file for old delft3d versions.
   
   for it=2:T.nt_storage % NOTE: vertical velocity is ALWAYS 0 1st timestep, so we start with step 2
   
   %% load 3D data, incl time-varying grid

      % grid, incl waterlevel which determines z grid spacing
      G                = vs_meshgrid3dcorcen     (H, it, G);
   
      % dissolved substances
      I                  = vs_get_constituent_index(H,OPT.scalar);
      D.cen.(OPT.scalar) = vs_let_scalar           (H,'map-series',{it}, 'R1'      , {0,0,0,I.index});
   
      % horizontal velocities
     [D.cen.u,D.cen.v]   = vs_let_vector_cen       (H,'map-series',{it},{'U1','V1'}, {0,0,0});
      
      % vertical velocity
      D.cen.w            = vs_let_scalar           (H,'map-series',{it}, 'WPHY'    , {0,0,0,});
     
      hold off 
      
      dn = OPT.dn;
      dm = OPT.dm;
      dk = OPT.dk;
      mmin = OPT.mmin;
      mmax = OPT.mmax;
      nmin = OPT.nmin;
      nmax = OPT.nmax;

   %% 3D velocity field

      h.q = quiver3(G.cen.cent.x(  nmin:dn:nmax,mmin:dm:mmax,:),...
                    G.cen.cent.y(  nmin:dn:nmax,mmin:dm:mmax,:),...
                    G.cen.cent.z(  nmin:dn:nmax,mmin:dm:mmax,:),...
                 permute(D.cen.u(1,nmin:dn:nmax,mmin:dm:mmax,:),[2 3 4 1]).*OPT.uvscale,...
                 permute(D.cen.v(1,nmin:dn:nmax,mmin:dm:mmax,:),[2 3 4 1]).*OPT.uvscale,...
                         D.cen.w(  nmin:dn:nmax,mmin:dm:mmax,:)           .*OPT.wscale,0,'k');
      hold on
      
   %% horizontal scalar slices
   
      for k=1:dk:G.kmax
      h.s = surf(permute(G.cen.cent.x      (nmin:nmax,mmin:mmax,k),[1 2 3]),...
                 permute(G.cen.cent.y      (nmin:nmax,mmin:mmax,k),[1 2 3]),...
                 permute(G.cen.cent.z      (nmin:nmax,mmin:mmax,k),[1 2 3]),...
                 permute(D.cen.(OPT.scalar)(nmin:nmax,mmin:mmax,k),[1 2 3]));
                 
      end

   %% draw white lines at outer ribs of data

      for k=[1 G.kmax]
      h.s = plot3(squeeze(G.cen.cent.x  (nmin:nmax,mmin,k)),...
                  squeeze(G.cen.cent.y  (nmin:nmax,mmin,k)),...
                  squeeze(G.cen.cent.z  (nmin:nmax,mmin,k)),'w');
      h.s = plot3(squeeze(G.cen.cent.x  (nmin:nmax,mmax,k)),...
                  squeeze(G.cen.cent.y  (nmin:nmax,mmax,k)),...
                  squeeze(G.cen.cent.z  (nmin:nmax,mmax,k)),'w');

      h.s = plot3(squeeze(G.cen.cent.x  (nmin,mmin:mmax,k)),...
                  squeeze(G.cen.cent.y  (nmin,mmin:mmax,k)),...
                  squeeze(G.cen.cent.z  (nmin,mmin:mmax,k)),'w');
      h.s = plot3(squeeze(G.cen.cent.x  (nmax,mmin:mmax,k)),...
                  squeeze(G.cen.cent.y  (nmax,mmin:mmax,k)),...
                  squeeze(G.cen.cent.z  (nmax,mmin:mmax,k)),'w');

      end
      
      for n1=[nmin nmax]
      for m1=[mmin mmax]

      h.s = plot3(squeeze(G.cen.cent.x  (n1,m1,:)),...
                  squeeze(G.cen.cent.y  (n1,m1,:)),...
                  squeeze(G.cen.cent.z  (n1,m1,:)),'w');
                  
      end
      end
   
   %% vertical scalar slices

      for n=nmin:dn:nmax
      
      h.s = surf(permute(G.cen.cent.x      (n,mmin:mmax,:),[2 3 1]),...
                 permute(G.cen.cent.y      (n,mmin:mmax,:),[2 3 1]),...
                 permute(G.cen.cent.z      (n,mmin:mmax,:),[2 3 1]),...
                 permute(D.cen.(OPT.scalar)(n,mmin:mmax,:),[2 3 1]));
      
      end
      
   %% lay-out

      set(gca,'xtick',[-50:25:0].*1e3)
      set(gca,'ytick',[0:25:100].*1e3)
      axis   (OPT.axis)
      zlim([-20 1.5])
      tickmap('xy')
      grid    on
      title  ([OPT.title, ' ',datestr(T.datenum(it),'HH:MM')])
      set    (gca,'dataAspectRatio',[1 1 5e-4])
      view   (40,30)
      set    (h.q,'clipping','on')
      set    (h.s,'clipping','on')
      caxis  (OPT.clim)
      alpha  (0.5)
      shading interp
      h.c = colorbar;
      set(h.c,'position',[0.18 0.7 0.05 0.25])
      set(h.c,'ytick',OPT.clim)
      if strcmp(OPT.scalar,'temperature')
      set(h.c,'yticklabel',{'cold','hot'})
      else
      set(h.c,'yticklabel',{'fresher','34.5'})
      end
      
   %% export

      if OPT.export
      print2screensizeoverwrite([fileparts(H.DatExt),filesep,'movies',filesep,OPT.RUNID,'_',OPT.scalar,'_',num2str(it,'%0.2d')])
      end
   
      if OPT.pause
      pausedisp
      end
      
   end
   
end % RUNIDs   
   
%% EOF