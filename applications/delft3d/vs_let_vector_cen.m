function varargout=VS_LET_VECTOR_CEN(NFStruct,GroupName,GroupIndex,ElementNames,ElementIndex,varargin);
%VS_LET_VECTOR_CEN Read U,V vector data to centers from a trim- or com-file.
%
%   [U,V]=vs_let_vector_cen(NFStruct,'GroupName',GroupIndex,{'ElementName','ElementName'},ElementIndex,<'quiet'>)
%
%   Reads the vector field in GLOBAL co-ordinates at the 
%   specified timesteps from the specified NEFIS file 
%   (GroupIndex=TimeStep) by
%   (i  ) reading the curvi-linear data UKSI,UETA,
%   (ii ) applying drying masks at interfaces,
%   (iii) interpolating to center (water level, zeta) points
%   (iv ) applying drying masks at centers,
%   (v  ) reorienting using the local grid angle.
%
%   [U,V,UKSI,UETA]=vs_let_vector_cen(..);
%   Returns also the original velocities at the velocity points
%   NOTE that those have different dimesions than each other 
%   and than the zeta array.
%
%   [U,V,UKSI,UETA,u,v]=vs_let_vector_cen(..);
%   Returns also the velocities at the corner points in LOCAL 
%   orientation (skipping step v above). Note when only these are needed
%   [~,~,~,~,u,v] = vs_let_vector_cen(..) can be used.
%
%   Dummy rows are not returned, so only 
%   n: [2 nmax-1]
%   m: [2 mmax-1] can be requested
%
%   E.g.: to get velocities at one grid point (m,n) for all layers and all times:
%   [u,v] = vs_let_vector_cen(trimfile,'map-series',{0},{'U1','V1'},{n,m,1:kmax});
%   gives u and v as: [number_of_times x nmax x mmax x kmax]
%   Use m=0 for m=2:mmax-1, n=0 for n=2:nmax-1, k=0 for n=1:kmax
%
%
%
%         n+1          |       |          
%                  x   +   x   +   x      
%        - - -         |       |          
%               ---+---o---+---o---+      
%         n            |:::::::|          
%                  x   +:::X:::+   x      
%        - - -         |:::::::|          
%               ---+---o---+---o---+      
%         n-1          |       |          
%                  x   +   x   +   x      
%        - - -         |       |          
%                .       .       .      
%                .  m-1  .  m    .  m+1  
%                .       .       .      
%                                                                        
%         LEGEND:                                                      
%                                                                      
%         0 o         corner point (goal, others)       
%         X x         center point (goal, others)                                    
%         +           u or v velocity point                            
%         ::::        stencil used to get velocities
%                                                                      
%         o---+---o                                                    
%         |       |                                                    
%         +       +   control volume                                   
%         |       |                                                    
%         o---+---o                                                    
%                                                                      
%             +---o   center /corner/ velocity                          
%                 |   points with same matrix indices                  
%             x   +                                                    
%       
%       
%   The center velocity array is at point (n    ,m    ) is has size 1x1,
%   the u      velocity array is at point (n    ,m-1:m) is has size 1x2,
%   the v      velocity array is at point (n-1:n,m    ) is has size 2x1,
%
% Examle:
%
%         [D.cen.U D.cen.V] = vs_let_vector_cen(handle,...
%                           'map-series'              ,...
%                           {timestep}                ,...
%                           {'U1','V1'}               ,...
%                           {0,0,0}                   ,...
%                           'quiet'                   );
%
%   See also: VS_USE, VS_GET, VS_LET, VS_LET_SCALAR, VS_MASK, VS_...

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: vs_let_vector_cen.m 7520 2012-10-17 16:08:59Z dthompson.x $
% $Date: 2012-10-18 00:08:59 +0800 (Thu, 18 Oct 2012) $
% $Author: dthompson.x $
% $Revision: 7520 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_let_vector_cen.m $

% © G.J. de Boer, 2006, TU Delft, based on ideas in xyveloc.m by H.R.A. Jagers.
% 2008, May 15, made it work also for 2D arrays (tau)
% 2008, May 15, catch error when loading outermost dummy row/col
% 2008, Aug 06, added quiets to vs_*

% local works structs are:
%    u   = u face data
%    v   = c face data
%    cor = corner data
%    cen = center data

%% Initialize

   nargchk(1,7,nargin);
   
   % NOTE vs_let matrices are [n_times nmax mmax kmax]
   
   switch vs_type(NFStruct),
   case {'Delft3D-trim'},
      layer_model = strtrim(permute(vs_let(NFStruct,'map-const','LAYER_MODEL','quiet'),[2 3 1]));
   case {'Delft3D-com'},
      layer_model = strtrim(permute(vs_let(NFStruct,'GRID'     ,'LAYER_MODEL','quiet'),[2 3 1]));
   otherwise,
     error('Invalid NEFIS file for this action.');
   end;
   
   if strcmpi(layer_model,'Z-MODEL')
      disp('vs_let_vector_cen might not yet work correctly for velocities below highest layer in Z-MODEL due to absence of masks (set values of -999 to 0).')
   end

%% Define staggered ElementIndices

   nz = ElementIndex{1}; % indices centers
   mz = ElementIndex{2}; % indices centers
   
  [mmax, nmax, kmax] = vs_mnk(NFStruct);
   
   if (mz(1)==0 | ...
       nz(1)==0)
      if (mz==0)
          mz = 2:mmax-1;
      end
      if (nz==0)
          nz = 2:nmax-1;
      end
   end
   
   if any(nz==1) | any(nz==nmax)
      error('vs_let_vector_cen can not load cells at n=1 or nmax')
   end
   if any(mz==1) | any(mz==mmax)
      error('vs_let_vector_cen can not load cells at m=1 or mmax')
   end
   
   if length(ElementIndex)>2
   kz  = ElementIndex{3};
   else
   kz  = 0;
   end
   
   mu = [mz(1)-1,mz]; % indices u faces % add one before
   nu = nz          ; % indices u faces 
   mv = mz          ; % indices v faces 
   nv = [nz(1)-1,nz]; % indices v faces % add one before

   if length(vs_get_elm_size(NFStruct,ElementNames{1})) >2
   dimension = 3;
   else
   dimension = 2;
   end

   %disp(['m z: ',num2str(mz)])
   %disp(['n z: ',num2str(nz)])
   %disp(['m u: ',num2str(mu)])
   %disp(['n u: ',num2str(nu)])
   %disp(['m v: ',num2str(mv)])
   %disp(['n v: ',num2str(nv)])

%% i. Read curvi-linear data

   if     dimension==3
   u.UKSI  = vs_let(NFStruct,GroupName,GroupIndex,char(ElementNames{1}),{nu,mu,kz},varargin{:});%
   v.VETA  = vs_let(NFStruct,GroupName,GroupIndex,char(ElementNames{2}),{nv,mv,kz},varargin{:});%
   elseif dimension==2
   u.UKSI  = vs_let(NFStruct,GroupName,GroupIndex,char(ElementNames{1}),{nu,mu   },varargin{:});%
   v.VETA  = vs_let(NFStruct,GroupName,GroupIndex,char(ElementNames{2}),{nv,mv   },varargin{:});%
   end
   
   no_times = size(v.VETA,1);

%% ii. Read and apply masks at interfaces

   switch vs_type(NFStruct),
   case 'Delft3D-com',
     u.kfu = vs_let(NFStruct,'KENMTIM'   ,GroupIndex,'KFU',{nu,mu},varargin{:});%
     v.kfv = vs_let(NFStruct,'KENMTIM'   ,GroupIndex,'KFV',{nv,mv},varargin{:});%
   case 'Delft3D-trim',
     u.kfu = vs_let(NFStruct,'map-series',GroupIndex,'KFU',{nu,mu},varargin{:});%
     v.kfv = vs_let(NFStruct,'map-series',GroupIndex,'KFV',{nv,mv},varargin{:});%
   end;
   
   for k=1:size(u.UKSI,4)
      u.UKSI(:,:,:,k)=u.UKSI(:,:,:,k).*u.kfu;
      v.VETA(:,:,:,k)=v.VETA(:,:,:,k).*v.kfv;
   end
   
   if strcmpi(layer_model,'Z-MODEL')
      u.UKSI(u.UKSI==-999) = 0;
      v.VETA(v.VETA==-999) = 0;
   end

%% iii. Interpolate
%  iv.  Read and apply center masks

   cen.U    = nan.*zeros(no_times,length(nz),length(mz),length(kz)); % U at centers, first (local), then global (global) after reorientation
   cen.V    = nan.*zeros(no_times,length(nz),length(mz),length(kz)); % V at centers, first (local), then global (global) after reorientation
   cen.u    = nan.*zeros(         length(nz),length(mz));            % local work array per layer to get from local to global velocities
   cen.v    = nan.*zeros(         length(nz),length(mz));            % local work array per layer to get from local to global velocities
   cen.actu = nan.*zeros(no_times,length(nz),length(mz));
   cen.actv = nan.*zeros(no_times,length(nz),length(mz));
   
   for it=1:no_times
   
      % do not use squeeze because that causes squeeze([1 1 2]) to get size [2 1],
      % and thus requires another (flipped) conv bipeds 
      
      cen.actu(it,:,:)    = ...
      max(1,conv2(double([shiftdim(u.kfu(it,:,:),1)>0]),[1 1],'valid')); % <<<
      cen.actv(it,:,:)    = ...
      max(1,conv2(double([shiftdim(v.kfv(it,:,:),1)>0]),[1;1],'valid'));
   
   end
   
   %% Average local (U,V) at faces to local (U,V) at centers
   %  using weights actu/v that are (1/2) when both faces are active
   
   for ik=1:size(u.UKSI,4) % all layers
   
      cen.U(:,:,:,ik) = u.UKSI(:,:        ,[2:end  ],ik)+...
                        u.UKSI(:,:        ,[1:end-1],ik);
      cen.V(:,:,:,ik) = v.VETA(:,[2:end  ],:        ,ik)+...
                        v.VETA(:,[1:end-1],:        ,ik);
   
      cen.U(:,:,:,ik) = squeeze(cen.U  (:,:,:,ik)./cen.actu);
      cen.V(:,:,:,ik) = squeeze(cen.V  (:,:,:,ik)./cen.actv);
   
   end

%% v. Reorient

   switch vs_type(NFStruct),
   case 'Delft3D-com',
      cen.alfa = vs_let(NFStruct,'GRID'     ,'ALFAS' ,{nz,mz},'quiet');
     %cen.alfa0= vs_let(NFStruct,'GRID'     ,'ALFORI',        'quiet');
     %cen.alfa = cen.alfa+cen.alfa0; 
   case 'Delft3D-trim',
      cen.alfa = vs_let(NFStruct,'map-const','ALFAS' ,{nz,mz},'quiet');
     %cen.alfa0= vs_let(NFStruct,'map-const','ALFORI',        'quiet');
     %cen.alfa = cen.alfa+cen.alfa0;
   end;
   
   cen.alfa = permute(cen.alfa,[2 3 1])*pi/180;

%% Reorient local (U,V) to global (U,V), using work arrays (u,v)

   for it=1:size(u.UKSI,1)
   %-%if dimension==3
     for ik=1:size(u.UKSI,4)
   
      cen.u = permute(cen.U(it,:,:,ik),[2 3 1 4]); % copy (local) U to 2D array (per layer) , and then transform to (global) U
      cen.v = permute(cen.V(it,:,:,ik),[2 3 1 4]); % Note that (global) U and V calculatation both requires (local) U and V, so make a temporary copy of the local U and V.
      
      cen.U(it,:,:,ik) = cen.u.*cos(cen.alfa(:,:)) - ...
                         cen.v.*sin(cen.alfa(:,:));
      cen.V(it,:,:,ik) = cen.u.*sin(cen.alfa(:,:)) + ...
                         cen.v.*cos(cen.alfa(:,:));
                     
     end
   %-%else
   %-%
   %-%   cen.u = permute(cen.U(it,:,:,ik),[2 3 1]); % copy (local) U to 2D array (per layer) , and then transform to (global) U
   %-%   cen.v = permute(cen.V(it,:,:,ik),[2 3 1]); % Note that (global) U and V calculatation both requires (local) U and V, so make a temporary copy of the local U and V.
   %-%   
   %-%   cen.U(it,:,:) = cen.u.*cos(cen.alfa(:,:)) - ...
   %-%                   cen.v.*sin(cen.alfa(:,:));
   %-%   cen.V(it,:,:) = cen.u.*sin(cen.alfa(:,:)) + ...
   %-%                   cen.v.*cos(cen.alfa(:,:));
   %-%
   %-%end
  end
   
%% Output
   
   if nargout==2, % U,V
     varargout={cen.U cen.V};
     return;
   elseif nargout==4, % U,V,UKSI,VETA
     varargout={cen.U cen.V u.UKSI v.VETA};
     return;
   elseif nargout==6, % U,V,UKSI,VETA
     varargout={cen.U cen.V u.UKSI v.VETA cen.u cen.v};
     return;
   end;

%% EOF
