function varargout=vs_meshgrid2d(varargin),
%VS_MESHGRID2D   deprecated, use VS_MESHGRID2DCORCEN instead

%VS_MESHGRID2D   Read time-independent grid info from trim/com file
%
%         G = vs_meshgrid2d(NFSstruct,timestep)
%         G = vs_meshgrid2d(NFSstruct,timestep,G)
%
% reads all the relevant griddata of 
% time-independent grid properties.
%
% Arrays have m as first and n as second index.
%
% To save time, G can be passed as 3rd argument, where
% G is the struct with time independent info as returned 
% by vs_meshgrid2d0 or a previous call to vs_meshgrid2d.
%
% depth0cor is positive up just like the water level
% (and not positive down like in the Delft3D convenction)
%
%         ...,'optionname',optionval,...
%         supported options:
%         * 'face'
%            1: calculates position u,v velocity points
%         * 'geometry'
%            1: calculates grid distances guu,gvv, guv, gvu

warning('deprecated, use VS_MESHGRID2DCORCEN instead')

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
P.logicalmask  = 1;

% READ POSITION OF THESE GRID POINTS;
% ----------------------------------

P.face         = 1; % calculate xu yu, xv, yv
P.geometry     = 0; % calculate guu, guv, gvu, gvv

% Arguments
% -----------------------------------
   NFSstruct = varargin{1};
   TimeStep  = varargin{2};
   
   if odd(nargin)
      G         = varargin{3};
      i=3;
   else
      G         = vs_meshgrid2d0(NFSstruct);
      i=2;
   end
   
   while i<=nargin,
     if isstruct(varargin{i}),
     elseif ischar(varargin{i}),
       switch lower(varargin{i})
       case 'geometry'
         i=i+1;
         P.geometry     = varargin{i};
       case 'face'
         i=i+1;
         P.face         = varargin{i};
       otherwise
         error(sprintf('Invalid string argument: %s.',varargin{i}));
       end
     end;
     i=i+1;
   end;

if isempty(NFSstruct),
  NFSstruct=vs_use('lastread');
end;

   if isempty(G)
      G = vs_meshgrid2d0(NFSstruct,...
                         'face',P.face,...
                         'geometry',P.geometry);
   end
   
   switch vs_type(NFSstruct),

% comfile
% -----------------------------------

   case {'Delft3D-com','Delft3D-tram','Delft3D-botm'},


     % water level elevation in centre(zeta) points
     G.elevationcen = vs_get(NFSstruct         ,...
                         'CURTIM'              ,...
                         {TimeStep}            ,...
                         'S1'                  ,...
                         {2:G.nmax-1,2:G.mmax-1}   ,...
                         'quiet'               );%'   
     %G.elevationcen = actwl(NFSstruct, TimeStep);
     % depth bathymetry in bottom (corner) points
     G.depth0cor    = -vs_get(NFSstruct, ...
                              'BOTTIM',...
                              'DP',...
                              {1:G.nmax-1,1:G.mmax-1}   ,...
                              'quiet');%'
     G.depth0cor(G.depth0cor==999)=nan;
     

     G.KFU           = vs_get(NFSstruct,...
                              'KENMTIM'  ,...
                              {TimeStep},...
                              'KFU',...
                              {2:G.nmax-1,1:G.mmax-1},...
                              'quiet');%'
     G.KFV           = vs_get(NFSstruct,...
                              'KENMTIM'  ,...
                              {TimeStep},...
                              'KFV',...
                              {1:G.nmax-1,2:G.mmax-1},...
                              'quiet');%'
                              


% TRIMFILE
% -----------------------------------

   case 'Delft3D-trim',


     G.KFU       = vs_get(NFSstruct     ,...
                              'map-series'  ,...
                              {TimeStep}    ,...
                              'KFU'         ,...
                              {2:G.nmax-1,1:G.mmax-1},...
                              'quiet'       );%'
     G.KFV       = vs_get(NFSstruct     ,...
                              'map-series'  ,...
                              {TimeStep}    ,...
                              'KFV'         ,...
                              {1:G.nmax-1,2:G.mmax-1},...
                              'quiet'       );%'

     % water level elevation in centre(zeta) points
     G.elevationcen = vs_get(NFSstruct         ,...
                         'map-series'          ,...
                         {TimeStep}            ,...
                         'S1'                  ,...
                         {2:G.nmax-1,2:G.mmax-1}   ,...
                         'quiet'               );%'
     %G.elevationcen = actwl(NFSstruct, TimeStep);
      % depth bathymetry in bottom ??? points
     G.depth0cor    = -vs_get(NFSstruct,...
                              'map-const',...
                              'DP0',...
                              {1:G.nmax-1,1:G.mmax-1}   ,...
                              'quiet');%'
     G.depth0cor(G.depth0cor==999)=nan;

      
  otherwise,
    error('Invalid NEFIS file for this action.');
  end;
  
% Calculate masks
% -----------------------------------

   %% 0/1 Non-active/Active veleocity point (time dependent)
   G.KFU (G.KFU  ==0 ) = nan;
   G.KFV (G.KFV  ==0 ) = nan;
  
   if P.logicalmask
      G.KFU  = ~isnan(G.KFU );
      G.KFV  = ~isnan(G.KFV );
   end

%% Return variables
%% ------------------------

   if nargout == 1
      varargout = {G};
   end
