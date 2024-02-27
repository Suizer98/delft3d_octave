function D = vs_dpeads(vsfile,it,varargin)
%VS_DPEADS  get spatial gradients of PEA from NEFIS file
%
%   D = vs_dpeads(vsfile,it)
%
% calculates the 10 spatial gradients Sx/y, Ax/y, Nx/y, Cx/y, W/Mz of
% the RHS of d_phi/d_t = ... at one time step (it) 
% where phi is the potential energy anomaly
%
%                    z=surface
%                   /
%    phi = (g/H) * | (rho_depth_mean - rho) * z * dz    [J/m3]
%                 /
%               z=bottom
%
% as defined in:
%
% * Simpson, Brown, Matthews & Allen, 1990. Tidal straining, density currents & stirring 
%   in the control of estuarine  stratification, Estuaries, 13(2), 125-132. <a href="dx.doi.org/10.2307/1351581">DOI:10.2307/1351581</a>
% * F.C. Groenendijk, 1992. Distribution in time and space of fresh water & suspended matter 
%   in the Dutch coastal zone. Rijkswaterstaat, Dienst Getijdewateren, 1992. <a href="http://books.google.com/books?id=SGAhGwAACAAJ">Google books</a>.
%
% with the spatial gradient expressions described in:
%
% * de Boer, Pietrzak, & Winterwerp, 2008. Using the potential energy anomaly 
%   equation to investigate tidal straining and advection of stratification in 
%   a region of freshwater influence, Ocean Modeling, 22(1-2) <a href="http://dx.doi.org/10.1016/j.ocemod.2007.12.003">doi:10.1016/j.ocemod.2007.12.003</a>.
%
% Uses a central difference scheme with gradients defined at centers (water level 
% points). Dummy rows and columns are not returned, as in VS_LET_SCALAR. 
%
% For the temporal (LHS) gradient, see VS_TRIM2NC, that allows to  extract 
% both the spatial RHS and temporal LHS gradients at once to one netCDF file.
%
% See also: VS_TRIM2NC, DELFT3D, PEA_SIMPSON_ET_AL_1990, VS_USE, VS_LET_SCALAR

%%  --------------------------------------------------------------------
%   Copyright (C) 2012 Technische Universiteit Delft;Deltares
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl;gerben.deboer@deltares.nl
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

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id: vs_dpeads.m 7814 2012-12-10 16:59:37Z boer_g $
%  $Date: 2012-12-11 00:59:37 +0800 (Tue, 11 Dec 2012) $
%  $Author: boer_g $
%  $Revision: 7814 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_dpeads.m $
%  $Keywords: $

%% Debug

   if ischar(vsfile)
     F  = vs_use(vsfile);
   else
     F  = vsfile;
     vsfile = F.DatExt;
   end

%% Settings

   OPT.debug          = 0;
   OPT.prandtlschmidt = 0.7; %1.0;% for use see Delft3D manual 3.14.7864 Eq. 9.101 / 3.15.18392 Eq. 9.102
   OPT.mixing         = 'zero';
   
   OPT  =setproperty(OPT,varargin);

%% Read static grid

   G.mmax        =  vs_let       (F,'map-const' ,'MMAX'  ,'quiet');
   G.nmax        =  vs_let       (F,'map-const' ,'NMAX'  ,'quiet');
   G.kmax        =  vs_let       (F,'map-const' ,'KMAX'  ,'quiet');
   G.cen.mask    =  vs_let_scalar(F,'map-const' ,'KCS'   ,'quiet'); G.cen.mask(G.cen.mask~=1) = NaN; % -1/0/1/2 Non-active/Non-active/Active/Boundary water level point (fixed)
   G.cen.x       =  vs_let_scalar(F,'map-const' ,'XZ'    ,'quiet').*G.cen.mask;
   G.cen.y       =  vs_let_scalar(F,'map-const' ,'YZ'    ,'quiet').*G.cen.mask;
   G.cen.alfa    =  vs_let_scalar(F,'map-const' ,'ALFAS' ,'quiet').*G.cen.mask;
   if vs_get_elm_size(F,'DPS0') > 0
   G.cen.dep     =  vs_let_scalar(F,'map-const' ,'DPS0'  ,'quiet').*G.cen.mask; % depth is positive down
   else % legacy
   G.cen.dep     =  vs_let_scalar(F,'map-const' ,'DP0'   ,'quiet').*G.cen.mask; % depth is positive down
   end
   G.sigma_dz    =  vs_let       (F,'map-const' ,'THICK' ,'quiet');   

%% Read primary time-dependent data

    G.cen.zwl     = vs_let_scalar    (F,'map-series',{it},'S1'       ,{0,0}  ,'quiet').*G.cen.mask;
      cen.density = apply_mask(vs_let_scalar    (F,'map-series',{it},'RHO'      ,{0,0,0},'quiet'),G.cen.mask);
      int.dicww   = apply_mask(vs_let_scalar    (F,'map-series',{it},'DICWW'    ,{0,0,2:G.kmax},'quiet'),G.cen.mask); % internal interfaces only
      cen.w       = apply_mask(vs_let_scalar    (F,'map-series',{it},'WPHY'     ,{0,0,0},'quiet'),G.cen.mask);
     [cen.u,cen.v]= vs_let_vector_cen(F,'map-series',{it},{'U1','V1'},{0,0,0},'quiet');% apply_mask
      cen.u       = apply_mask(permute(cen.u,[2 3 4 1]),G.cen.mask); % y x z
      cen.v       = apply_mask(permute(cen.v,[2 3 4 1]),G.cen.mask); % y x z
      
      try % legacy
         mdffilename   = [filepathstr(F.DatExt),filesep,strtok(filename(F.DatExt),'trim-'),'.mdf'];
         mdf           = delft3d_io_mdf('read',mdffilename,'case','lower');
         
         try;cen.dicww    = max(mdf.keywords.dicoww,cen.dicww);end
         try;cen.vicww    = max(mdf.keywords.vicoww,cen.vicww);end
         
         disp(['Read dicoww/vicoww ',num2str([mdf.keywords.dicoww mdf.keywords.vicoww]),' from file: ',mdffilename])
      catch
         disp('warning: Not able to read background viscosities from mdf file , might reduce to below 1e-6 in some FLOW versions!!')
      end  

%% Calculate horizontal spatial gradients
      
     [cen.ddensitydx,cen.ddensitydy]=vs_gradient(G.cen.x,G.cen.y,G.cen.alfa,cen.density);
       
      if OPT.debug
         close all
         subplot(1,3,1)
         pcolorcorcen(G.cen.x,G.cen.y,cen.density   (:,:,1));axis equal;colorbarwithhtext('\rho','horiz')
         subplot(1,3,2)
         pcolorcorcen(G.cen.x,G.cen.y,cen.ddensitydx(:,:,1));axis equal;clim([-1 1].*5e-3);colorbarwithhtext('d \rho / d x','horiz')
         subplot(1,3,3)
         pcolorcorcen(G.cen.x,G.cen.y,cen.ddensitydy(:,:,1));axis equal;clim([-1 1].*5e-3);colorbarwithhtext('d \rho / d y','horiz')
      end

%% Obtain vertical grid spacing required for integrals

      g             = 9.81;
      cen.H         = G.cen.zwl(:,:) + G.cen.dep; % depth is positive down

     [G.sigma_cent,...
      G.sigma_intf] = d3d_sigma(G.sigma_dz);
      G.cen.cent.z  = nan([size(G.cen.x) G.kmax]);
      for k = 1:G.kmax
         G.cen.cent.z (:,:,k) = G.sigma_cent(k).*cen.H - G.cen.dep; % depth is positive down
         G.cen.cent.dz(:,:,k) = G.sigma_dz  (k).*cen.H;
      end
      
%% Calculate vertical spatial gradients for Wx and Mz terms

      cen.ddensitydz = repmat(nan,size(cen.ddensitydx));
      int.ddensitydz(:,:,:) = diff(cen.density(:,:,:),[],3)./diff(G.cen.cent.z(:,:,:),[],3); % internal interfaces only
      cen.ddensitydz(:,:,2:end-1) = (int.ddensitydz(:,:,1:end-1) + ...
                                     int.ddensitydz(:,:,2:end  ))./2; % add value above (make sure last = 0)
      cen.ddensitydz(:,:,1      ) =  int.ddensitydz(:,:,1      )   ; % duplicate value from half cell below
      cen.ddensitydz(:,:,end    ) =  int.ddensitydz(:,:,end    )   ; % duplicate value from half cell above
   
%                        _
%% calculate depth-mean ( ) and depth-anomalies (~)
%

      [cen.ddensitydxmean ,cen.ddensitydxshear] = meanweighted(cen.ddensitydx,3,G.sigma_dz(:));
      [cen.ddensitydymean ,cen.ddensitydyshear] = meanweighted(cen.ddensitydy,3,G.sigma_dz(:));
      [cen.densitymean    ,cen.densityshear   ] = meanweighted(cen.density   ,3,G.sigma_dz(:));

      if OPT.debug % reassure that linear operations GRADIENT and MEANWEIGHTED are indeed interchangeable
      [cen.ddensitydxmean2,cen.ddensitydymean2] = vs_gradient(G.cen.x,G.cen.y,G.cen.alfa,cen.densitymean);
      OK = isequalwithequalnans(cen.ddensitydxmean2,cen.ddensitydxmean)
      OK = isequalwithequalnans(cen.ddensitydymean2,cen.ddensitydymean)
      end
      
      [cen.umean     ,cen.ushear      ] = meanweighted(cen.u   ,3,G.sigma_dz(:));
      [cen.vmean     ,cen.vshear      ] = meanweighted(cen.v   ,3,G.sigma_dz(:));
      
      [cen.d_usheardensityshear_mean_H_dx_over_H,~]=vs_gradient(G.cen.x,G.cen.y,G.cen.alfa,meanweighted(cen.ushear.*cen.densityshear,3,G.sigma_dz(:)).*cen.H);
      [~,cen.d_vsheardensityshear_mean_H_dy_over_H]=vs_gradient(G.cen.x,G.cen.y,G.cen.alfa,meanweighted(cen.vshear.*cen.densityshear,3,G.sigma_dz(:)).*cen.H);
      
      cen.d_usheardensityshear_mean_H_dx_over_H = cen.d_usheardensityshear_mean_H_dx_over_H./cen.H;
      cen.d_vsheardensityshear_mean_H_dy_over_H = cen.d_vsheardensityshear_mean_H_dy_over_H./cen.H;

%% Calculate terms spatial gradient PEA

      for k = 1:G.kmax

   %  Sx/y: Handle per layer combination depth averaged and varying term (different sizes)

      cen.dphidx_strain(:,:,k) =  cen.ddensitydxmean (:,:)  .*cen.ushear(:,:,k); % [rho/m]*[m/s] = [rho/s]
      cen.dphidy_strain(:,:,k) =  cen.ddensitydymean (:,:)  .*cen.vshear(:,:,k); % [rho/m]*[m/s] = [rho/s]

   %  Ax/y: Handle per layer combination depth averaged and varying term (different sizes)
      
      cen.dphidx_frozen(:,:,k) =  cen.ddensitydxshear(:,:,k).*cen.umean (:,:)  ; % [rho/m]*[m/s] = [rho/s]
      cen.dphidy_frozen(:,:,k) =  cen.ddensitydyshear(:,:,k).*cen.vmean (:,:)  ; % [rho/m]*[m/s] = [rho/s]
      
   %  Cx/y (replicate per layer for uniform integration of terms down below

      cen.dphidx_crossc(:,:,k) = -cen.d_usheardensityshear_mean_H_dx_over_H(:,:); % [(m/s*rho)*m]*[1/m]/[m] = [rho/s]
      cen.dphidy_crossc(:,:,k) = -cen.d_vsheardensityshear_mean_H_dy_over_H(:,:); % [(m/s*rho)*m]*[1/m]/[m] = [rho/s]

      end

   %  Nx/y

      cen.dphidx_nonlin(:,:,:) =  (cen.ddensitydxshear(:,:,:)).*(cen.ushear(:,:,:)); % [rho/m]*[m/s] = [rho/s]
      cen.dphidy_nonlin(:,:,:) =  (cen.ddensitydyshear(:,:,:)).*(cen.vshear(:,:,:)); % [rho/m]*[m/s] = [rho/s]

   %  W/Mz: Vertical exchange
   %  for use see Delft3D manual 3.14.7864 Eq. 9.101 / 3.15.18392 Eq. 9.102      
   
      cen.dphidt_updown(:,:,:) =  cen.ddensitydz     (:,:,:).*cen.w     (:,:,:); % [rho/m]*[m/s] = [rho/s]

      cen.dphidt_mixing = 0.*cen.dphidt_updown;
      cen.dphidt_mixing(:,:,2:end-1) = + (1./OPT.prandtlschmidt).*... 
                                         (int.dicww(:,:,2:end  ).*int.ddensitydz(:,:,2:end  ) - ...
                                          int.dicww(:,:,1:end-1).*int.ddensitydz(:,:,1:end-1))./G.cen.cent.dz(:,:,2:end-1);

      if strcmp(OPT.mixing(1:4),'zero')
      % Top and bottom layer values were initialized zero, just keep them like that.
      elseif strcmp(OPT.mixing(1:3),'lin')
      % Assume linear profile of nu*drhodz in top and bottom layer,
      % with end-values zero at free surface interface and bed interface.
      % For bottom we should use f(bed_shear_stress) and 
      % for surface we should use f(wind_speed) mixing, so this is
      % an underestimation of nu*drhodz, but necesarrily of dphidt_mixing
      % as that depends on the density distribution too.
      cen.dphidt_mixing(:,:,1      ) = + (1./OPT.prandtlschmidt).*...
                                         (int.dicww(:,:,2      ).*int.ddensitydz(:,:,2) -   0)./G.cen.cent.dz(:,:,1      );
      cen.dphidt_mixing(:,:,end    ) = + (1./OPT.prandtlschmidt).*...
                                       (0 - int.dicww(:,:,  end-1).*int.ddensitydz(:,:,end-1))./G.cen.cent.dz(:,:,  end  );
      end

%% Integrate terms spatial gradient PEA

      D.Sx = (g./cen.H).*sum(cen.dphidx_strain(:,:,:).*G.cen.cent.z(:,:,:).*G.cen.cent.dz(:,:,:),3);
      D.Ax = (g./cen.H).*sum(cen.dphidx_frozen(:,:,:).*G.cen.cent.z(:,:,:).*G.cen.cent.dz(:,:,:),3);
      			 						       
      D.Sy = (g./cen.H).*sum(cen.dphidy_strain(:,:,:).*G.cen.cent.z(:,:,:).*G.cen.cent.dz(:,:,:),3);
      D.Ay = (g./cen.H).*sum(cen.dphidy_frozen(:,:,:).*G.cen.cent.z(:,:,:).*G.cen.cent.dz(:,:,:),3);
      
      D.Nx = (g./cen.H).*sum(cen.dphidx_nonlin(:,:,:).*G.cen.cent.z(:,:,:).*G.cen.cent.dz(:,:,:),3);
      D.Ny = (g./cen.H).*sum(cen.dphidy_nonlin(:,:,:).*G.cen.cent.z(:,:,:).*G.cen.cent.dz(:,:,:),3);

      D.Cx = (g./cen.H).*sum(cen.dphidx_crossc(:,:,:).*G.cen.cent.z(:,:,:).*G.cen.cent.dz(:,:,:),3);
      D.Cy = (g./cen.H).*sum(cen.dphidy_crossc(:,:,:).*G.cen.cent.z(:,:,:).*G.cen.cent.dz(:,:,:),3);

      D.Mz = (g./cen.H).*sum(cen.dphidt_mixing(:,:,:).*G.cen.cent.z(:,:,:).*G.cen.cent.dz(:,:,:),3);
      D.Wz = (g./cen.H).*sum(cen.dphidt_updown(:,:,:).*G.cen.cent.z(:,:,:).*G.cen.cent.dz(:,:,:),3);

function matrix = apply_mask(matrix,mask)

   for k=1:size(matrix,3)
      matrix(:,:,k) = matrix(:,:,k).*mask;
   end

