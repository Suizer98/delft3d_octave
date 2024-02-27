 function varargout=d3d2dflowfm_viscosity_xyz(varargin)

% d3d2dflowfm_viscosity_xyz generate and write write D-Flow FM viscosity (and diffusivity) file
%                           from d3d files
%
%
%                          Iput arguments 1) Delft3D-Flow grid file (*.grd)
%                                         2) Delft3D-Flow viscosity/fiffusivity file (*.edy)
%                                         3) Name of the Dflowfm viscosity file (*.xyz)
%                              (Optional) 4) Name of the Dflowfm diffusivity file (*.xyz)
%
% See also: dflowfm_io_mdu dflowfm_io_xydata
%

   filgrd = varargin{1};
   filedy = varargin{2};
   filvico= varargin{3};

   no_edy = 1;
   if length(varargin) == 4
       fildico = varargin{4};
       no_edy  = 2;
   end

   %
   % Read the grid information
   %

   grid                     = delft3d_io_grd('read',filgrd);
   mmax                     = grid.mmax;
   nmax                     = grid.nmax;
   xcoor_u                  = grid.u_full.x';
   ycoor_u                  = grid.u_full.y';
   xcoor_v                  = grid.v_full.x';
   ycoor_v                  = grid.v_full.y';

   % read the viscosity/diffusivity values
   edy        = wldep('read',filedy,[mmax nmax],'multiple');

   % Fill LINE struct with viscosity and diffusivity values
   for i_edy = 1: no_edy
       tmp(i_edy,1:mmax*nmax,1)             = reshape(xcoor_u',mmax*nmax,1);
       tmp(i_edy,1:mmax*nmax,2)             = reshape(ycoor_u',mmax*nmax,1);
       tmp(i_edy,1:mmax*nmax,3)             = reshape(edy(i_edy).Data',mmax*nmax,1);

       tmp(i_edy,mmax*nmax+1:2*mmax*nmax,1) = reshape(xcoor_v',mmax*nmax,1);
       tmp(i_edy,mmax*nmax+1:2*mmax*nmax,2) = reshape(ycoor_v',mmax*nmax,1);
       tmp(i_edy,mmax*nmax+1:2*mmax*nmax,3) = reshape(edy(i_edy).Data',mmax*nmax,1);

   end

   nonan = ~isnan(tmp(1,:,1));

   for i_edy = 1: no_edy
       tmp2             = d3d2dflowfm_addsquare(squeeze(tmp(i_edy,nonan,:)));
       LINE(i_edy).DATA = num2cell(tmp2);
   end

   % write viscosity to file
   dflowfm_io_xydata('write',filvico,LINE(1));

   % write diffusivity to file
   if no_edy == 2 dflowfm_io_xydata('write',fildico,LINE(2));end
