%EXAMPLE_MAKE_INI   example how to use DELFT3D_IO_INI
%
%See also: DELFT3D_IO_INI

   U.directory = 'P:\z3672-cassino\runs\run030_3D\';
   G           = wlgrid('read',[U.directory,filesep,'lake_and_sea_5.grd']);
   G.mmax      = size(G.X,1) + 1; % dummy corner points are not in grid file
   G.nmax      = size(G.X,2) + 1; % dummy corner points are not in grid file
   G.kmax      = 16;
   
   INI.zwl     = zeros(G.mmax,G.nmax) + 0.3;
   INI.u       = zeros(G.mmax,G.nmax,G.kmax) + 0;
   INI.v       = zeros(G.mmax,G.nmax,G.kmax) + 0;
   INI.sal     = zeros(G.mmax,G.nmax,G.kmax) + 0;
   
   INI.sal (1:42,:) = 35;
   
   pcolorcorcen  (G.X,G.Y,INI.sal(2:end-1,2:end-1,1),[.5 .5 .5])
   axis equal
   colorbar
   
   delft3d_io_ini('write',[U.directory,filesep,'cas_kmax=',num2str(G.kmax,'%0.3d'),'.ini'] ,INI);
   %delft3d_io_ini('write',[U.directory,'cas_kmax=',num2str(G.kmax,'%0.3d'),'2.ini'],INI.zwl,...
   %                                                                                 INI.u,...
   %                                                                                 INI.v,...
   %                                                                                 INI.sal);
