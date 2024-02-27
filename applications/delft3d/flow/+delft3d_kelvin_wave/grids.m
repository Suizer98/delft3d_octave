function [OPT,G] = grids(varargin)
%delft3d_kelvin_wave.grids   collection of orthogonal kelvin wave grids
%
%  [OPT,G] = delft3d_kelvin_wave.grids(<keyword,value>)
%
% where <keyword,value> specify a grid, the output OPT
% has extra fields x,y,x0,y0 and d with respect to the inpout OPT
% that span a rectangular non-equidistant grid for calculation
% of a Kelvin wave: x is alongshore North, y is crossshore west.
%
% This function contains the grid definition used in de Boer et a. 2008:
% Ocean Dynamics (2006) 56: 198-216, DOI 10.1007/s10236-005-0042-1.
%
% Required fields in output struct G are 'x' and 'y' for 
% calculation in delft3d_kelvin_wave.calculation. The coordinate
% (0,0) is where the kelvin wave amplitude is prescribed and fixed.
% 
% Required fields in output struct OPT are 'bch' and in G 'mdf'
% for  saving the Kelvin wave results to Delft3D boundary tables.
%
%See also: delft3d_kelvin_wave

   OPT0.x           = [];
   OPT0.y           = [];
   OPT0.x0          = []; % where amplitude from delft3d_kelvin_wave.input is assigned
   OPT0.y0          = []; % where amplitude from delft3d_kelvin_wave.input is assigned
   OPT0.d_sea       = 20;
   OPT0.grdlayout   = 33;
   OPT0.kmax        = 16;
   OPT0.mdf         = 'F:\DELFT3D\kelvinwave01\n00.mdf';
   OPT0.grd         = 'F:\DELFT3D\kelvinwave01\155x235.grd';
   OPT0.dep         = 'F:\DELFT3D\kelvinwave01\155x235.dep';
   OPT0.dry         = 'F:\DELFT3D\kelvinwave01\155x235.dry';
   OPT0.bnd         = 'F:\DELFT3D\kelvinwave01\155x235.bnd';
   OPT0.bch         = 'F:\DELFT3D\kelvinwave01\155x235.bch';
   OPT0.obs         = 'F:\DELFT3D\kelvinwave01\155x235.obs';

   OPT = setproperty(OPT0,varargin,'onExtraField','silentAppend');
   
   switch OPT.grdlayout
   
   case 33 % barotropic version of model set-up of PECS 2008
          
       % plume basin stretched a little at west and north
       % at the south the model is padded, but not stretched
       % origin in lower right at coast, x has negative values
       %
       %  ::::::::::::
       %  ::::::::::::
       %  ::::::::::::
       %  ::::::::::::
       %  ::::::::####
       %  ::::::::####
       %  ::::::::####
       %  ::::::::###+ Origin (0,0)
      
      G.dx            = 500;
      G.dy            = 500;
      G.n_stretch     = 25;
      G.dm_west       = 130; % incl 3 cell wide land
      G.dn_north      = 211;
      G.dn_south      =  -2;
      G.d_river       =   5;
      G.d_sea         =  20;
   
      G.ix0           = [          1:G.dm_west ]-1; % account for one delft3d dummy row
      G.iy0           = [-G.dn_south:G.dn_north]-1; % account for one delft3d dummy row
   
      G.ix            = 0 - [G.ix0 max(G.ix0) + cumsum(1.25.^[1:G.n_stretch])].*G.dx;
      G.ix            = fliplr(G.ix) - G.dx; % offset to accomodate 3-cell land to include estuary

      % make sure (0,0) is at coastal wall in thalweg of river
      G.iy            = [G.iy0 max(G.iy0) + cumsum(1.25.^[1:G.n_stretch])].*G.dy;  % make sure (0,0) is at cenl centre
      
      disp(['Increase # cells: ',num2str((size(G.ix).*size(G.iy))/(size(G.ix0).*size(G.iy0)))])
   
     [G.cor.x,G.cor.y]  = meshgrid(G.ix, G.iy);

      G.base.x           = 0;
      G.base.y           = 1.5e3; % account 3 cell wide land
      G.base.angle       = 0;
      
      G.mmax             = length(G.ix) + 1; % FLOW expects 1 dummy row and column
      G.nmax             = length(G.iy) + 1; % FLOW expects 1 dummy row and column

      m0{1} = G.mmax-[1 2 3];
      n0{1} = [2      2      2];
      n1{1} = [G.nmax G.nmax G.nmax]-1;

      G.dry.m0 = cell2mat(m0);
      G.dry.n0 = cell2mat(n0);
      G.dry.m1 = G.dry.m0;
      G.dry.n1 = cell2mat(n1);

      G.cor.dep = repmat(G.d_sea,[G.nmax,G.mmax]-1);
      G.cen.dep = repmat(G.d_sea,[G.nmax,G.mmax]-2);

   otherwise
      
      error([num2str(OPT.grdlayout),' is no valid layout'])
      
   end
   
   %% Make sure 1st index is mmax
   
   G.cor.x            = G.cor.x';
   G.cor.y            = G.cor.y';
   G.cen.x = corner2center(G.cor.x);
   G.cen.y = corner2center(G.cor.y);
   
%% save as Delft3D input
   
   G.mdf = delft3d_io_mdf('new');
   
   if ~isempty(OPT.grd)
      delft3d_io_grd('write',OPT.grd,G.cor.x,G.cor.y);
      G.mdf.keywords.filcco = filenameext(OPT.grd);
      G.mdf.keywords.filgrd = strrep(G.mdf.keywords.filcco,'.grd','.enc');
      G.mdf.keywords.mnkmax = [G.mmax G.nmax OPT.kmax];
      G.mdf.keywords.thick  = repmat(100/OPT.kmax,[OPT.kmax 1]);
   end
   
   if ~isempty(OPT.dry)
      delft3d_io_dry('write',OPT.dry,G.dry.m0,G.dry.n0,G.dry.m1,G.dry.n1);
      G.mdf.keywords.fildry = filenameext(OPT.dry);
   end

   if ~isempty(OPT.dep)
      delft3d_io_dep('write',           strrep(OPT.dep,'.dep','_cen.dep'),G.cen.dep,'location','cen');
      delft3d_io_dep('write',           strrep(OPT.dep,'.dep','_cor.dep'),G.cor.dep,'location','cor');
      G.mdf.keywords.fildep = filenameext(strrep(OPT.dep,'.dep','_cor.dep'));
      G.mdf.keywords.depuni = [];
   end
   
   if ~isempty(OPT.bnd)
         G.bnd.DATA(1).name     = 'north1';
         G.bnd.DATA(1).bndtype  = 'R'; % riemann
         G.bnd.DATA(1).datatype = 'H';
         G.bnd.DATA(1).mn       = [2 G.nmax (G.mmax-4) G.nmax];
         G.bnd.DATA(1).alfa     = 0;

         G.bnd.DATA(2).name     = 'west1';
         G.bnd.DATA(2).bndtype  = 'R'; % riemann
         G.bnd.DATA(2).datatype = 'H';
         G.bnd.DATA(2).mn       = [1 2 1 (G.nmax-1)];
         G.bnd.DATA(2).alfa     = 0;

      for m=2:G.mmax-4
         name = ['south',num2str(m-1),'(',num2str(m),'..',num2str(1),')'];
         G.bnd.DATA(end+1).name     = [name,'..',name]; % '(152,1)..(152,1)'
         G.bnd.DATA(end  ).bndtype  = 'Z';
         G.bnd.DATA(end  ).datatype = 'H';
         G.bnd.DATA(end  ).mn       = [m 1 m 1];
         G.bnd.DATA(end  ).alfa     = 0;
      end
      G.bnd.NTables = length(G.bnd.DATA);
      delft3d_io_bnd('write',OPT.bnd,G.bnd);
      G.mdf.keywords.filbnd = filenameext(OPT.bnd);
   end
   
   if ~isempty(OPT.obs)
      y = [G.base.y:10e3:max(G.cen.y(:))];
      x = 0.*y-2e3;
     [m,n]     = xy2mn(G.cen.x,G.cen.y,x,y);
      namst = [num2str(x','(%d'),num2str(y',',%d)')];
      delft3d_io_obs('write',OPT.obs,m+1,n+1,namst);
      G.mdf.keywords.filsta = filenameext(OPT.obs);
   end

   G.mdf.keywords.anglat = 52.5;
   G.mdf.keywords.itdate = '2012-01-01';
   G.mdf.keywords.tstart = 0;
   G.mdf.keywords.tstop  = 3600;
   G.mdf.keywords.flmap  = [0 20 3600];
   G.mdf.keywords.flhis  = [0 10 3600];
   G.mdf.keywords.flrst =  720;
   G.mdf.keywords.dt     = 2;
   G.mdf.keywords.zeta0  = 0; % large geostrophic basins take long to empty to MSL
   G.mdf.keywords.roumet = 'W';
   G.mdf.keywords.ccofu  = 1.2500000e-001;
   G.mdf.keywords.ccofv  = 1.2500000e-001;
   G.mdf.keywords.vicouv = 1;
   G.mdf.keywords.dicouv = 1;
   G.mdf.keywords.vicoww = 1e-4;
   G.mdf.keywords.dicoww = 1e-6;
   G.mdf.keywords.forfww = 'Y';
   G.mdf.keywords.sigcor = 'Y';
   G.mdf.keywords.BarocP = 'N';
   G.mdf.keywords.Cstbnd = 'Y';
   G.mdf.keywords.filfou = '';
   delft3d_io_mdf('write',OPT.mdf,G.mdf.keywords);

%% return the transformed co-ordinates that describe 
%  a coastally trapped wave with x crossshore and y alongshore.
%  the origin (0,0) is where the kelvin wave amplitude will be specified.

      OPT.d_sea = G.d_sea;
     [OPT.x] = center2corner(G.cor.x)-G.base.x;
     [OPT.y] = center2corner(G.cor.y)-G.base.y;
    %[OPT.x, OPT.y] = rotatevector((OPT.x-G.base.x),...
    %                              (OPT.y-G.base.y),G.base.angle);

%% EOF