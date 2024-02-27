function varargout=vs_meshgrid3d(varargin),
%VS_MESHGRID3D Read all the relevant griddata
%         G = vs_meshgrid3d(NFSstruct,TimeStep,G);
%
% where G is the time independent G as obtained with
% vs_meshgrid2d, or an empty [] so that vs_meshgrid3d
% is called.
%
%         ...,'optionname',optionval,...
%         supported options:
% 'keepwaterlevels',0/1 uses the waterlevels in input struct G
% 'centres',struct with fields 1 or more of the fields
%    - cor (default 0)
%    - cen (default 1)
%    - u   (default 0)
%    - v   (default 0)
%  with value 0 indicating to not calulcate them, and 1 to calculate them
% 'intface',same as for keyword 'centres' 

warning('deprecated, use VS_MESHGRID3DCORCEN instead')

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Technische Universiteit Delft, 
%       Gerben J. de Boer
%
%       g.j.deboer@citg.tudelft.nl	
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
%   --------------------------------------------------------------------

NFSstruct      = [];
TimeStep       = 1;

% Defaults
% -----------------------------------

P.keepwaterlevels = 0;

% calculate G.elevationcor SOMEHOW

   P.centres.cor  = 0; % = corner points
   P.centres.cen  = 1; % = centre points
   P.centres.u    = 0; % = u velocity points
   P.centres.v    = 0; % = v velocity points
   
   P.intface.cor  = 0; % = corner points
   P.intface.cen  = 1; % = centre points
   P.intface.u    = 0; % = u velocity points
   P.intface.v    = 0; % = v velocity points

% Read position of these grid points;
% ----------------------------------

   P.depth0cen    = 1; % calculated
   P.depth0cor    = 1; % stored in trim/comfile
   
   P.elevationcen = 1; % stored in trim/comfile
   P.elevationcor = 1; % CAN BE CALCULATED WITH PRELIMINARY VERSION OF CENTER2CORNER
   
   P.face         = 1; % calculate xu yu, xv, yv
   P.geometry     = 0; % calculate grid distances
     P.depth0u    = 0; % provided P.face
     P.depth0v    = 0; % provided P.face
     P.elevationu = 0; % provided P.face
     P.elevationv = 0; % provided P.face
   
   P.xy3d         = 1; % same into for every layers, so no need THERE IS NEED WHEN MAKING CROSS SLICES

% Arguments
% -----------------------------------
   
   NFSstruct = varargin{1};

   i = 2;

   while i<=nargin,


     if isnumeric(varargin{i}),
        TimeStep  = varargin{i};
        Gin       = varargin{i+1};
        i = i+2;
     elseif ischar(varargin{i}),
       switch lower(varargin{i})
       case 'keepwaterlevels'
         i=i+1;
         P.keepwaterlevels  = varargin{i};
       case 'centres'
         i=i+1;
         P.centres = mergestructs(P.centres,varargin{i});
       case 'intface'
         i=i+1;
         P.intface = mergestructs(P.intface,varargin{i});
       otherwise
         error(sprintf('Invalid string argument: %s.',varargin{i}));
       end
     end;
     i=i+1;
   end;

   if isempty(NFSstruct),
      NFSstruct=vs_use('lastread');
   end;
   
% Read time (in)dependent grid geometry
% -----------------------------------

   G = vs_meshgrid2d(NFSstruct,TimeStep,Gin,...
                    'face'      ,P.face,...
                    'geometry'  ,P.geometry);
   
% When reading the time grid suitable for plotting
% the time averaged data, also the time averaged elevation
% should be used in calculating the 3D coordinates.
% The elevation at 1 particular time as read by 
% vs_meshgrid2d must therefore be overwritten 
% by a supplied elevation.
% -----------------------------------
   if isfield(Gin,'elevationcen') & P.keepwaterlevels
      G.elevationcen = Gin.elevationcen;
   end

%% Calculate bottom levels to other positions
%% ------------------------

   if P.elevationcor
      % G.elevationcor = center2corner(G.elevationcen,'extrapolation',0);G.maskcen;
      G.elevationcor = center2cornernan(G.elevationcen).*G.maskcor;
      % do set to nan otherwise average is baised with zeros
      disp('Warning: use of preliminary center2corner.m to put elevation in dep points.')
   end

   %% if P.elevationcor = 0; % CANNOT YET BE CALCULATED
   %%  G.elevationcor               = center2corner(G.elevationcen);
   %%                               = corner2center(              ,'same',nfltp);
   %%
   %%  % not yet implemented
   %%  % merge
   %%  % - corner2centre.m
   %%  % - interp2cen.m
   %%  % - pieces about DP in comfil.m, trimfil.m
   %%
   %% end
   
   if P.depth0cen
      G.depth0cen              = corner2center(G.depth0cor);
   end

   if P.depth0u  & P.face
      error('not implemented yet')
   end
   if P.depth0v  & P.face
      error('not implemented yet')
   end
    
   if P.elevationu  & P.face
      error('not implemented yet')
   end
   if P.elevationv  & P.face
      error('not implemented yet')
   end

% CALCULATE Z LEVELS
% -----------------------------------

%% Calculate sigma vertical positions
%% ------------------------

   [G.sigma_centres    ,...
    G.sigma_intface ]   = d3d_sigma(G.sigma_dz);
   
%   [G.sigma_centres    ,...
%    G.sigma_intface ]   = d3d_z    (G.sigma_dz);

%% Calculate also 3D x-y-grids if P.xy3d==1
%% These contain the same, i.e. redundant, information
%% for every layer)
%% ------------------------

   %% CENTRES IN VERTICAL
   
   if P.centres.cor
%                G.zcor_centres= zeros(G.mmax-1, G.nmax-1,G.kmax);
%      if P.xy3d;G.xcor_centres= zeros(G.mmax-1, G.nmax-1,G.kmax);;end
%      if P.xy3d;G.ycor_centres= zeros(G.mmax-1, G.nmax-1,G.kmax);;end
                G.zcor_centres= zeros(size(G.xcor,1),size(G.xcor,2),G.kmax);
      if P.xy3d;G.xcor_centres= zeros(size(G.xcor,1),size(G.xcor,2),G.kmax);end
      if P.xy3d;G.ycor_centres= zeros(size(G.xcor,1),size(G.xcor,2),G.kmax);end
      for k = 1:G.kmax
                   G.zcor_centres(:,:,k) = G.sigma_centres(k).*(G.elevationcor - G.depth0cor) + G.depth0cor; % <<<<<
         if P.xy3d;G.xcor_centres(:,:,k) = G.xcor;end
         if P.xy3d;G.xcor_centres(:,:,k) = G.ycor;end
      end
   end
   if P.centres.cen
%                G.zcen_centres= zeros(G.mmax-2, G.nmax-2,G.kmax);
%      if P.xy3d;G.xcen_centres= zeros(G.mmax-2, G.nmax-2,G.kmax);;end
%      if P.xy3d;G.ycen_centres= zeros(G.mmax-2, G.nmax-2,G.kmax);;end
                G.zcen_centres= zeros(size(G.xcen,1),size(G.xcen,2),G.kmax);
      if P.xy3d;G.xcen_centres= zeros(size(G.xcen,1),size(G.xcen,2),G.kmax);;end
      if P.xy3d;G.ycen_centres= zeros(size(G.xcen,1),size(G.xcen,2),G.kmax);;end
      for k = 1:G.kmax
                   G.zcen_centres(:,:,k) = G.sigma_centres(k).*(G.elevationcen - G.depth0cen) + G.depth0cen;
         if P.xy3d;G.xcen_centres(:,:,k) = G.xcen;end
         if P.xy3d;G.ycen_centres(:,:,k) = G.ycen;end
      end
   end
   if P.centres.u
      error('Not properly implemented yet')
%                G.zu_centres= zeros(G.mmax-1, G.nmax-2,G.kmax);
%      if P.xy3d;G.xu_centres= zeros(G.mmax-1, G.nmax-2,G.kmax);;end
%      if P.xy3d;G.yu_centres= zeros(G.mmax-1, G.nmax-2,G.kmax);;end
                G.zu_centres= zeros(size(G.xu,1),size(G.xu,2),G.kmax);
      if P.xy3d;G.xu_centres= zeros(size(G.xu,1),size(G.xu,2),G.kmax);end
      if P.xy3d;G.yu_centres= zeros(size(G.xu,1),size(G.xu,2),G.kmax);end
      for k = 1:G.kmax
                   G.zu_centres(:,:,k) = G.sigma_centres(k).*(G.elevationu - G.depth0u) + G.depth0u;
         if P.xy3d;G.xu_centres(:,:,k) = G.xu;end
         if P.xy3d;G.yu_centres(:,:,k) = G.yu;end
      end
   end
   if P.centres.v
      error('Not properly implemented yet')
%                G.zv_centres= zeros(G.mmax-2, G.nmax-1,G.kmax);
%      if P.xy3d;G.xv_centres= zeros(G.mmax-2, G.nmax-1,G.kmax);;end
%      if P.xy3d;G.yv_centres= zeros(G.mmax-2, G.nmax-1,G.kmax);;end
                G.zv_centres= zeros(size(G.xv,1),size(G.xv,2),G.kmax);
      if P.xy3d;G.xv_centres= zeros(size(G.xv,1),size(G.xv,2),G.kmax);end
      if P.xy3d;G.yv_centres= zeros(size(G.xv,1),size(G.xv,2),G.kmax);end
      for k = 1:G.kmax
                   G.zv_centres(:,:,k) = G.sigma_centres(k).*(G.elevationv - G.depth0v) + G.depth0v;
         if P.xy3d;G.xv_centres(:,:,k) = G.xv;end
         if P.xy3d;G.yv_centres(:,:,k) = G.yv;end
      end
   end

   %% INTERFACES IN VERTICAL

   if P.intface.cor
%                G.zcor_intface= zeros(G.mmax-1, G.nmax-1,G.kmax+1);
%      if P.xy3d;G.xcor_intface= zeros(G.mmax-1, G.nmax-1,G.kmax+1);;end
%      if P.xy3d;G.ycor_intface= zeros(G.mmax-1, G.nmax-1,G.kmax+1);;end
                G.zcor_intface= zeros(size(G.xcor,1),size(G.xcor,2),G.kmax+1);
      if P.xy3d;G.xcor_intface= zeros(size(G.xcor,1),size(G.xcor,2),G.kmax+1);end
      if P.xy3d;G.ycor_intface= zeros(size(G.xcor,1),size(G.xcor,2),G.kmax+1);end
      for k = 1:G.kmax+1
                   G.zcor_intface(:,:,k) = G.sigma_intface(k).*(G.elevationcor - G.depth0cor) + G.depth0cor; % <<<<<
         if P.xy3d;G.xcor_intface(:,:,k) = G.xcor;end
         if P.xy3d;G.ycor_intface(:,:,k) = G.ycor;end
      end
   end
   if P.intface.cen
%                G.zcen_intface= zeros(G.mmax-2, G.nmax-2,G.kmax+1);
%      if P.xy3d;G.xcen_intface= zeros(G.mmax-2, G.nmax-2,G.kmax+1);;end
%      if P.xy3d;G.ycen_intface= zeros(G.mmax-2, G.nmax-2,G.kmax+1);;end
                G.zcen_intface= zeros(size(G.xcen,1),size(G.xcen,2),G.kmax+1);
      if P.xy3d;G.xcen_intface= zeros(size(G.xcen,1),size(G.xcen,2),G.kmax+1);end
      if P.xy3d;G.ycen_intface= zeros(size(G.xcen,1),size(G.xcen,2),G.kmax+1);end
      for k = 1:G.kmax+1
                   G.zcen_intface(:,:,k) = G.sigma_intface(k).*(G.elevationcen - G.depth0cen) + G.depth0cen;
         if P.xy3d;G.xcen_intface(:,:,k) = G.xcen;end
         if P.xy3d;G.ycen_intface(:,:,k) = G.ycen;end
      end
   end
   if P.intface.u
      error('Not properly implemented yet')
%                G.zu_intface= zeros(G.mmax-1, G.nmax-2,G.kmax+1);
%      if P.xy3d;G.xu_intface= zeros(G.mmax-1, G.nmax-2,G.kmax+1);;end
%      if P.xy3d;G.yu_intface= zeros(G.mmax-1, G.nmax-2,G.kmax+1);;end
                G.zu_intface= zeros(size(G.xu,1),size(G.xu,2),G.kmax+1); 
      if P.xy3d;G.xu_intface= zeros(size(G.xu,1),size(G.xu,2),G.kmax+1);end
      if P.xy3d;G.yu_intface= zeros(size(G.xu,1),size(G.xu,2),G.kmax+1);end
      for k = 1:G.kmax+1
                   G.zu_intface(:,:,k) = G.sigma_intface(k).*(G.elevationu - G.depth0u) + G.depth0u;
         if P.xy3d;G.xu_intface(:,:,k) = G.xu;end
         if P.xy3d;G.yu_intface(:,:,k) = G.yu;end
      end
   end
   if P.intface.v
      error('Not properly implemented yet')
%                G.zv_intface= zeros(G.mmax-2, G.nmax-1,G.kmax+1);
%      if P.xy3d;G.xv_intface= zeros(G.mmax-2, G.nmax-1,G.kmax+1);;end
%      if P.xy3d;G.yv_intface= zeros(G.mmax-2, G.nmax-1,G.kmax+1);;end
                G.zv_intface= zeros(size(G.xv,1),size(G.xv,2),G.kmax+1);
      if P.xy3d;G.xv_intface= zeros(size(G.xv,1),size(G.xv,2),G.kmax+1);end
      if P.xy3d;G.yv_intface= zeros(size(G.xv,1),size(G.xv,2),G.kmax+1);end
      for k = 1:G.kmax+1
                   G.zv_intface(:,:,k) = G.sigma_intface(k).*(G.elevationv - G.depth0v) + G.depth0v;
         if P.xy3d;G.xv_intface(:,:,k) = G.xv;end
         if P.xy3d;G.yv_intface(:,:,k) = G.yv;end
      end
   end

%% Return variables
%% ------------------------

   if nargout == 1
      varargout = {G};
   end
