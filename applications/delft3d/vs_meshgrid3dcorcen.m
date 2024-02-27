function varargout=vs_meshgrid3dcorcen(varargin),
%VS_MESHGRID3DCORCEN   Read 3D time-dependent grid info from NEFIS file.
%
%  G = VS_MESHGRID3DCORCEN(NFSstruct,TimeStep,G,<'keyword',value>);
%
% where G is the time independent G as obtained with
% VS_MESHGRID2DCORCEN, or an empty [], so that it will be 
% called by this function.
%
% Works for fully for sigma and partially (cell centers only) for z planes.
%
% Implemented optional <'keyword',value> pairs are:
%  * 'centres',struct with fields 1 or more of the fields
%      - cor (default 1)
%      - cen (default 1)
%      - u   (default 0)
%      - v   (default 0)
%     with value 0 indicating to not calulcate them, and 1 to calculate them
%  * 'intface'  same as for keyword 'centres' 
%  * 'latlon'   labels x to lon, and y to lat if coordinate system is spherical (default 1)
%  * 'quiet'    1 (default 0)
%
% See also: VS_USE, VS_LET, VS_DISP, VS_MESHGRID2DCORCEN, VS_LET_SCALAR

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Technische Universiteit Delft, 
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
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: vs_meshgrid3dcorcen.m 11859 2015-04-08 10:00:55Z bartgrasmeijer.x $
% $Date: 2015-04-08 18:00:55 +0800 (Wed, 08 Apr 2015) $
% $Author: bartgrasmeijer.x $
% $Revision: 11859 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_meshgrid3dcorcen.m $

NFSstruct      = [];
TimeStep       = 1;

%% Defaults
% calculate G.elevationcor SOMEHOW

   P.cor.cent      = 1; % = corner points
   P.cen.cent      = 1; % = centre points
   P.u.cent        = 0; % = u velocity points
   P.v.cent        = 0; % = v velocity points
   
   P.cor.intf      = 1; % = corner points
   P.cen.intf      = 1; % = centre points
   P.u.intf        = 0; % = u velocity points
   P.v.intf        = 0; % = v velocity points

%% Read position of these grid points;

   P.cor.zwl       = 1; % CAN BE CALCULATED WITH PRELIMINARY VERSION OF CENTER2CORNER
   P.xy3d          = 1; % same for every layers, so no need THERE IS NEED WHEN MAKING CROSS SLICES
   
   P.face          = 1; % calculate xu yu, xv, yv
   P.geometry      = 0; % calculate grid distances
     P.u.depth0    = 0; % provided P.face
     P.v.depth0    = 0; % provided P.face
     P.u.elevation = 0; % provided P.face
     P.v.elevation = 0; % provided P.face
   P.latlon        = 1; % labels x to lon, and y to lat if spherical
   P.quiet         = 1;
   
%% Arguments
   
   NFSstruct = varargin{1};
   iargin    = 2;
   G         = [];

   while iargin<nargin,

     if isnumeric(varargin{iargin}),
        TimeStep  = varargin{iargin  };
        G         = varargin{iargin+1};
        iiargin   = iargin+2;
     elseif ischar(varargin{iargin}),
       switch lower(varargin{iargin})
       case 'centres'        ;iargin=iargin+1;P.cen   = mergestructs(P.cen    ,varargin{iargin});
       case 'intface'        ;iargin=iargin+1;P.int   = mergestructs(P.int    ,varargin{iargin});
       case 'latlon'         ;iargin=iargin+1;P.int   = mergestructs(P.latlon ,varargin{iargin});
       case 'quiet'          ;iargin=iargin+1;P.quiet = varargin{iargin};
       otherwise
         error(sprintf('Invalid string argument: %s.',varargin{i}));
       end
     end;
     iargin=iargin+1;
   end;

   if isempty(NFSstruct),
      NFSstruct=vs_use('lastread');
   end;
   
%% Read time in-dependent grid geometry

   if isempty(G)
      G = vs_meshgrid2dcorcen(NFSstruct);
   end

   if P.latlon & strmatch(G.coordinates,'SPHERICAL')
      x = 'lon';
      y = 'lat';
   else
      x = 'x';
      y = 'y';
   end

%% Read time dependent grid geometry (waterlevel)

   switch vs_type(NFSstruct),

%% Comfile

   case {'Delft3D-com','Delft3D-tram','Delft3D-botm'},

     d3dcen.zwl = vs_get(NFSstruct,'CURTIM'    ,{TimeStep},'S1' ,{1:G.nmax-0,1:G.mmax-0},'quiet');%'{2:G.nmax-1,2:G.mmax-1}
       d3du.kfu = vs_get(NFSstruct,'KENMTIM'   ,{TimeStep},'KFU',{1:G.nmax-0,1:G.mmax-0},'quiet');%'{2:G.nmax-1,1:G.mmax-1}
       d3dv.kfv = vs_get(NFSstruct,'KENMTIM'   ,{TimeStep},'KFV',{1:G.nmax-0,1:G.mmax-0},'quiet');%'{1:G.nmax-1,2:G.mmax-1}
       d3du.kcu = vs_get(NFSstruct,'KENMCNST'  ,{TimeStep},'KCU',{1:G.nmax-0,1:G.mmax-0},'quiet');%'{2:G.nmax-1,1:G.mmax-1}
       d3dv.kcv = vs_get(NFSstruct,'KENMCNST'  ,{TimeStep},'KCV',{1:G.nmax-0,1:G.mmax-0},'quiet');%'{1:G.nmax-1,2:G.mmax-1}


%% Trimfile

   case 'Delft3D-trim',

     d3dcen.zwl  = vs_get(NFSstruct,'map-series',{TimeStep},'S1' ,{1:G.nmax-0,1:G.mmax-0},'quiet');%'
       d3du.kfu  = vs_get(NFSstruct,'map-series',{TimeStep},'KFU',{1:G.nmax-0,1:G.mmax-0},'quiet');%'
       d3dv.kfv  = vs_get(NFSstruct,'map-series',{TimeStep},'KFV',{1:G.nmax-0,1:G.mmax-0},'quiet');%'
       d3du.kcu  = vs_get(NFSstruct,'map-const' ,{       1},'KCU',{1:G.nmax-0,1:G.mmax-0},'quiet');%'
       d3dv.kcv  = vs_get(NFSstruct,'map-const' ,{       1},'KCV',{1:G.nmax-0,1:G.mmax-0},'quiet');%'
       output = char(vs_find(NFSstruct,'DPS'));
       if strcmp(output, 'map-sed-series');
           G.cor.dps = -vs_get(NFSstruct,'map-sed-series' ,{TimeStep},'DPS'  ,{G.ncor,G.mcor},'quiet');%' % depth is positive up here (in contrast to NEFIS files) !!!
       end
       output = char(vs_find(NFSstruct,'DPSED'));
       if strcmp(output, 'map-sed-series');
           d3dcen.dpsed = vs_get(NFSstruct,'map-sed-series' ,{TimeStep},'DPSED',{1:G.nmax-0,1:G.mmax-0},'quiet');% Sediment thickness at bed (zeta point)
       end
       output = char(vs_find(NFSstruct,'BODSED'));
       if strcmp(output, 'map-sed-series');
           d3dcen.bodsed = vs_get(NFSstruct,'map-sed-series' ,{TimeStep},'BODSED',{1:G.nmax-0,1:G.mmax-0,1},'quiet');% Available sediment at bed (zeta point)
       end

  otherwise,
    error('Invalid NEFIS file for this action.');
  end; % switch vs_type(NFSstruct),
  
%% Apply masks

  d3dcen.kfu =        max(1,conv2([double(d3du.kfu(:,1))>0 double(d3du.kfu>0)],[1 1],'valid'));
  d3dcen.kfv =        max(1,conv2([double(d3dv.kfv(1,:))>0;double(d3dv.kfv>0)],[1;1],'valid'));

  d3dcen.kcu =        max(1,conv2([double(d3du.kcu(:,1))>0 double(d3du.kcu>0)],[1 1],'valid'));
  d3dcen.kcv =        max(1,conv2([double(d3dv.kcv(1,:))>0;double(d3dv.kcv>0)],[1;1],'valid'));
  
  d3dcen.zwl(d3dcen.kfu==1 & d3dcen.kfv==1)=NaN;
  d3dcen.mask = ~(d3dcen.kfu==1 & d3dcen.kfv==1);
  
%% Subset center data and extrapolate to corner data
  
     G.cen.zwl = d3dcen.zwl(2:end-1,2:end-1);
     G.cen.zwl_comment = 'Waterlevel at centers with application of time dependent velocity point masks';
     G.cen.dpsed = d3dcen.dpsed(2:end-1,2:end-1);
     G.cen.dpsed_comment = 'Sediment thickness at bed (zeta point)';
     G.cen.bodsed = d3dcen.bodsed(2:end-1,2:end-1);
     G.cen.bodsed_comment = 'Available sediment at bed (zeta point)';
     G.cen.mask = d3dcen.mask(2:end-1,2:end-1);
     G.cen.mask_comment = 'wet = true; dry = false';

  if P.cor.zwl 
    sz = size(G.cen.zwl);
    if all(sz>1) % not for 1d slices
      G.cor.zwl = center2corner(G.cen.zwl,'nearest');
      G.cor.zwl_comment = 'Waterlevel at corners extrapolated from centers by VS_MESHGRID3DCORCEN';
    else
      warning('1D slices not yet tested !')
      if   sz(1)==1
      G.cor.zwl = center2corner([G.cen.zwl;G.cen.zwl],'nearest');
      G.cor.zwl = G.cor.zwl(1:2,:);
      else sz(1)==2
      G.cor.zwl = center2corner([G.cen.zwl G.cen.zwl],'nearest');
      G.cor.zwl = G.cor.zwl(:,1);
      end
      G.cor.zwl_comment = 'Waterlevel at corners extrapolated from duplicated centers by VS_MESHGRID3DCORCEN';
    end
    if ~P.quiet
    disp('Waterlevel at corners extrapolated from centers by VS_MESHGRID3DCORCEN')
    end
  end
  
%% Start 3D coordinates
%  CALCULATE Z LEVELS
%  Calculate also 3D x-y-grids if P.xy3d==1
%  These contain the same, i.e. redundant, information
%  for every layer)
   
if strmatch('SIGMA-MODEL', G.layer_model)
   
%% SIGMA-MODEL

%% Calculate sigma vertical positions

   [G.sigma_cent,...
    G.sigma_intf]   = d3d_sigma(G.sigma_dz);

%% CENTRES IN VERTICAL

   
   if P.cor.cent
                G.cor.cent.z   = zeros(size(G.cor.(x),1),size(G.cor.(x),2),G.kmax);
      if P.xy3d;G.cor.cent.(x) = zeros(size(G.cor.(x),1),size(G.cor.(x),2),G.kmax);end
      if P.xy3d;G.cor.cent.(y) = zeros(size(G.cor.(x),1),size(G.cor.(x),2),G.kmax);end
      for k = 1:G.kmax
                   G.cor.cent.z(:,:,k) = G.sigma_cent(k).*(G.cor.zwl - G.cor.dep) + G.cor.dep; % <<<<<
         if P.xy3d;G.cor.cent.(x)(:,:,k) = G.cor.(x);end
         if P.xy3d;G.cor.cent.(y)(:,:,k) = G.cor.(y);end
      end
   end
   if P.cen.cent
                G.cen.cent.z  = zeros(size(G.cen.(x),1),size(G.cen.(x),2),G.kmax);
      if P.xy3d;G.cen.cent.(x)= zeros(size(G.cen.(x),1),size(G.cen.(x),2),G.kmax);;end
      if P.xy3d;G.cen.cent.(y)= zeros(size(G.cen.(x),1),size(G.cen.(x),2),G.kmax);;end
      for k = 1:G.kmax
                   G.cen.cent.z(:,:,k) = G.sigma_cent(k).*(G.cen.zwl - G.cen.dep) + G.cen.dep;
         if P.xy3d;G.cen.cent.(x)(:,:,k) = G.cen.(x);end
         if P.xy3d;G.cen.cent.(y)(:,:,k) = G.cen.(y);end
      end
   end

%% INTERFACES IN VERTICAL

   if P.cor.intf
                G.cor.intf.z  = zeros(size(G.cor.(x),1),size(G.cor.(x),2),G.kmax+1);
      if P.xy3d;G.cor.intf.(x)= zeros(size(G.cor.(x),1),size(G.cor.(x),2),G.kmax+1);end
      if P.xy3d;G.cor.intf.(y)= zeros(size(G.cor.(x),1),size(G.cor.(x),2),G.kmax+1);end
      for k = 1:G.kmax+1
                   G.cor.intf.z(:,:,k) = G.sigma_intf(k).*(G.cor.zwl - G.cor.dep) + G.cor.dep; % <<<<<
         if P.xy3d;G.cor.intf.(x)(:,:,k) = G.cor.(x);end
         if P.xy3d;G.cor.intf.(y)(:,:,k) = G.cor.(y);end
      end
   end
   if P.cen.intf
                G.cen.intf.z  = zeros(size(G.cen.(x),1),size(G.cen.(x),2),G.kmax+1);
      if P.xy3d;G.cen.intf.(x)= zeros(size(G.cen.(x),1),size(G.cen.(x),2),G.kmax+1);end
      if P.xy3d;G.cen.intf.(y)= zeros(size(G.cen.(x),1),size(G.cen.(x),2),G.kmax+1);end
      for k = 1:G.kmax+1
                   G.cen.intf.z(:,:,k)   = G.sigma_intf(k).*(G.cen.zwl - G.cen.dep) + G.cen.dep;
         if P.xy3d;G.cen.intf.(x)(:,:,k) = G.cen.(x);end
         if P.xy3d;G.cen.intf.(y)(:,:,k) = G.cen.(y);end
      end
   end
   
elseif strmatch('Z-MODEL', G.layer_model)

%% Calculate z vertical positions
   G.z_intf    = G.ZK;
   G.z_cent    = corner2center1(G.ZK);
   
%% Calculate layer number of bottom

   for n=1:size(G.cen.dep,1)
   for m=1:size(G.cen.dep,2)
      G.cen.kbotreal(n,m) = interp1(  G.z_intf,...
                                    1:G.kmax+1,...
                                      G.cen.dep(n,m)); % depth is positive up here (in contrast to NEFIS files) !!!
   end
   end

   G.cen.kbotreal_comments = 'Decimal vertical position of bottom in k-index space with k=1 at ZBOT andf k=kmax+1 at ZTOP';
   G.cen.kbot              = floor(G.cen.kbotreal);
   G.cen.kbot_comments     = 'Vertical layer number in which the bottom resides with with k=1 just above ZBOT and k=kmax+1 just below ZTOP';
      
%% Calculate layer number of waterlevel
      
   for n=1:size(G.cen.zwl,1)
   for m=1:size(G.cen.zwl,2)
      
      %% from trisim 3.55 onwards
      %  ZTOP is fixed at the *.mdf file value, and floats upward with any higher waterlevels
      %  rather then being mirrored internaly to get twice the water depth.
      
      ztop_local   = max(G.z_intf(end),G.cen.zwl(n,m)); 
      z_intf_local = [G.z_intf(1:end-1) ztop_local];
      
      G.cen.ktopreal(n,m) = interp1(z_intf_local,...
                                    1:G.kmax+1,...
                                      G.cen.zwl(n,m)); % depth is positive up here (in contrast to NEFIS files) !!!

   end
   end
   
   G.cen.ktopreal_comments = 'Decimal vertical position of waterlevel in k-index space with k=1 at ZBOT andf k=kmax+1 at ZTOP';
   G.cen.ktop              = floor(G.cen.ktopreal);      
   G.cen.ktop_comments     = 'Vertical layer number in which the waterlevel resides with with k=1 just above ZBOT and k=kmax+1 just below ZTOP';

   G.cen.ktop(G.cen.ktop > G.kmax) = G.kmax;
       

%% CENTRES IN VERTICAL
   
%   if P.cor.cent
%   
%                G.cor.cent.z = zeros(size(G.cor.x,1),size(G.cor.x,2),G.kmax);
%      if P.xy3d;G.cor.cent.x = zeros(size(G.cor.x,1),size(G.cor.x,2),G.kmax);end
%      if P.xy3d;G.cor.cent.y = zeros(size(G.cor.x,1),size(G.cor.x,2),G.kmax);end
%      for k = 1:G.kmax
%         if P.xy3d;G.cor.cent.x(:,:,k) = G.cor.x;end
%         if P.xy3d;G.cor.cent.x(:,:,k) = G.cor.y;end
%      end
%   end
%   if P.cen.cent
%                G.cen.cent.z= zeros(size(G.cen.x,1),size(G.cen.x,2),G.kmax);
%      if P.xy3d;G.cen.cent.x= zeros(size(G.cen.x,1),size(G.cen.x,2),G.kmax);;end
%      if P.xy3d;G.cen.cent.y= zeros(size(G.cen.x,1),size(G.cen.x,2),G.kmax);;end
%      for k = 1:G.kmax
%         if P.xy3d;G.cen.cent.x(:,:,k) = G.cen.x;end
%         if P.xy3d;G.cen.cent.y(:,:,k) = G.cen.y;end
%      end
%   end
 
%% INTERFACES IN VERTICAL
 
%   if P.cor.intf
%
%      G.cor.intf_comment = 'The coordinates of the layer interfaces at the cell centers.'
%   
%                G.cor.intf.z= zeros(size(G.cor.x,1),size(G.cor.x,2),G.kmax+1);
%
%      for n=1:size(G.cor.zwl,1)
%      for m=1:size(G.cor.zwl,2)
%      
%         %-% disp(num2str([n m G.cor.mask(n,m) G.cor.dep(n,m) G.z_intf(end) G.cor.dep(n,m) < G.z_intf(end)]))
%      
%         if  ~(G.cor.mask(n,m)) | ...
%             ~(G.cor.dep (n,m) < G.z_intf(end)) % depth below highest zlayer
%
%            G.zcen_intface(n,m,:)              = NaN;
%         
%         else
%         
%            %% the local ZTOP is equal to the hightes input ZTOP
%            %% or the waterlevel if that is higher 
%            %% (so that the highest interface floats upward)
%            %% --------------------------------
%            
%            G.cor.intf.z(n,m,:)                = G.z_intf;
%
%            %% The waterlevel is always by definition the uppermost active layer
%            %% either above ZTOP (because it floats upward), 
%            %% or below ZTOP because the waterlevel is below ZTOP. Therefore
%            %% >> ztop_local = max( G.z_intf(end) , G.cor.zwl(n,m) );
%            %% irrelevant
%            %% --------------------------------
%
%            G.cor.intf.z(n,m,G.cor.ktop(n,m)+1    ) =  G.cor.zwl(n,m);
%            
%            %% except when the waterlevel is not in the upper layer, but below that,
%            %% so we have to remove all layers above that
%            %% and put the upper active interface at the waterlevel
%            %% --------------------------------
%
%            if               G.cor.ktop(n,m) < G.kmax
%            G.cor.intf.z(n,m,G.cor.ktop(n,m)+2:end)  = NaN;
%            end
%
%            %% the local ZBOT is equal to the actual depth,
%            %% while below rthat is inactive
%            %% --------------------------------
%
%            G.cor.intf.z(n,m,  G.cor.kbot(n,m)  )  = G.cor.dep(n,m);
%            
%            if                 G.cor.kbot(n,m) > 1
%            G.cor.intf.z(n,m,1:G.cor.kbot(n,m)-1)  = NaN;
%            end
%                  
%         end 
%      
%      end % n
%      end % m   
%
%      if P.xy3d;G.cor.intf.x= zeros(size(G.cor.x,1),size(G.cor.x,2),G.kmax+1);end
%      if P.xy3d;G.cor.intf.y= zeros(size(G.cor.x,1),size(G.cor.x,2),G.kmax+1);end
%      for k = 1:G.kmax+1
%         if P.xy3d;G.cor.intf.x(:,:,k) = G.cor.x;end
%         if P.xy3d;G.cor.intf.y(:,:,k) = G.cor.y;end
%      end
%   end

   if P.cen.intf
   
      G.cen.intf_comment = 'The coordinates of the layer interfaces at the cell centers.';
   
                G.cen.intf.z= zeros(size(G.cen.(x),1),size(G.cen.(x),2),G.kmax+1);

      for n=1:size(G.cen.zwl,1)
      for m=1:size(G.cen.zwl,2)
      
         %-% disp(num2str([n m G.cen.mask(n,m) G.cen.dep(n,m) G.z_intf(end) G.cen.dep(n,m) < G.z_intf(end)]))
      
         if   (isnan(G.cen.mask(n,m))) | ...
             ~(      G.cen.dep (n,m) < G.z_intf(end)) % depth below highest zlayer

            G.zcen_intface(n,m,:)              = NaN;
         
         else
         
            %% the local ZTOP is equal to the hightes input ZTOP
            %  or the waterlevel if that is higher 
            %  (so that the highest interface floats upward)
            %----------------------------------
            
            G.cen.intf.z(n,m,:)                = G.z_intf;

            %% The waterlevel is always by definition the uppermost active layer
            %  either above ZTOP (because it floats upward), 
            %  or below ZTOP because the waterlevel is below ZTOP. Therefore
            %  >> ztop_local = max( G.z_intf(end) , G.cen.zwl(n,m) );
            %  irrelevant
            %----------------------------------

            G.cen.intf.z(n,m,G.cen.ktop(n,m)+1    ) =  G.cen.zwl(n,m);
            
            %% except when the waterlevel is not in the upper layer, but below that,
            %  so we have to remove all layers above that
            %  and put the upper active interface at the waterlevel
            %----------------------------------

            if               G.cen.ktop(n,m) < G.kmax
            G.cen.intf.z(n,m,G.cen.ktop(n,m)+2:end)  = NaN;
            end

            %% the local ZBOT is equal to the actual depth,
            %  while below rthat is inactive
            %----------------------------------

            G.cen.intf.z(n,m,  G.cen.kbot(n,m)  )  = G.cen.dep(n,m);
            
            if                 G.cen.kbot(n,m) > 1
            G.cen.intf.z(n,m,1:G.cen.kbot(n,m)-1)  = NaN;
            end
                  
         end 
      
      end % n
      end % m   
   %
   %   if P.xy3d;G.cen.intf.(x)= zeros(size(G.cen.(x),1),size(G.cen.(x),2),G.kmax+1);end
   %   if P.xy3d;G.cen.intf.(y)= zeros(size(G.cen.(x),1),size(G.cen.(x),2),G.kmax+1);end
   %   for k = 1:G.kmax+1
   %      if P.xy3d;G.cen.intf.(x)(:,:,k) = G.cen.(x);end
   %      if P.xy3d;G.cen.intf.(y)(:,:,k) = G.cen.(y);end
   %   end

   end % if P.cen.intf

end

%% Return variables

   if nargout == 1
      varargout = {G};
   end

%% EOF