function varargout=vs_meshgrid2d0(varargin),
%VS_MESHGRID2D0   deprecated, use VS_MESHGRID2DCORCEN instead

%VS_MESHGRID2D0   Read all time-independent grid info from trim/com file
%
% vs_meshgrid2d0(NEFISstruct) reads all the relevant griddata
% 2D time-invariant form NEFIS struct as returned by vs_use()
% 
% Option, value pairs are:
% * 'geometry' to read grid distances as well (default off)
% * 'face'     to grid face positions as well (default off)
%
% Implemented are:
% - comfile 
% - trimfile
%
% The depth is the initial depth.
%
% See also: vs_use, vs_let, vs_disp

warning('deprecated, use VS_MESHGRID2DCORCEN instead')

%   --------------------------------------------------------------------
%   Copyright (C) 2004-2007 Technische Universiteit Delft, 
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
%   --------------------------------------------------------------------

NFSstruct      = [];
P.logicalmask  = 1;

% READ POSITION OF THESE GRID POINTS;
% ----------------------------------

P.face         = 0; % calculate xu yu, xv, yv
P.geometry     = 0; % calculate guu, guv, gvu, gvv

% Arguments
% -----------------------------------
   i=1;
   
   while i<=nargin,
     if isstruct(varargin{i}),
       NFSstruct=varargin{i};
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
   
   switch vs_type(NFSstruct),

% comfile
% -----------------------------------

   case {'Delft3D-com','Delft3D-tram','Delft3D-botm'},

     % read
     % -----------------------------------

     G.mmax      = vs_let(NFSstruct, 'GRID'     ,'MMAX', 'quiet');
     G.nmax      = vs_let(NFSstruct, 'GRID'     ,'NMAX', 'quiet');
     G.kmax      = vs_let(NFSstruct, 'GRID'     ,'KMAX', 'quiet');
     G.sigma_dz  = vs_let(NFSstruct, 'GRID'     ,'THICK','quiet');                

     G.KCU       = vs_get(NFSstruct, 'KENMCNST' ,'KCU', {2:G.nmax-1,1:G.mmax-1}, 'quiet');%'
     G.KCV       = vs_get(NFSstruct, 'KENMCNST' ,'KCV', {1:G.nmax-1,2:G.mmax-1}, 'quiet');%'

     G.KCS       = vs_get(NFSstruct, 'KENMCNST' ,'KCS', {2:G.nmax-1,2:G.mmax-1}, 'quiet');%'
     G.CODW      = vs_get(NFSstruct, 'TEMPOUT'  ,'CODW',{2:G.nmax-1,2:G.mmax-1}, 'quiet');%'

     G.CODB      = vs_get(NFSstruct, 'TEMPOUT'  ,'CODB',{1:G.nmax-1,1:G.mmax-1}, 'quiet');%'
     G.depcor    = vs_get(NFSstruct, 'INITBOT'  ,'DP0' ,{1:G.nmax-1,1:G.mmax-1}, 'quiet');%'
     try
     % added Nov 8th 2006
     G.depcen    = vs_get(NFSstruct, 'INITBOT'  ,'DPS' ,{2:G.nmax-1,2:G.mmax-1}, 'quiet');%' 
     catch
     G.depcen    = corner2center(G.depcor);
     end

     % criterion drying and flooding
    [nfltp0,Chk]  = vs_get(NFSstruct, 'PARAMS'    ,'NFLTYP','quiet');

     if     nfltp0 == 2
     nfltp         =  'max';
     elseif nfltp0 == 3
     nfltp         =  'min';
     else
     nfltp         =  'mean'; % default
     end

     G.xcor      = vs_get(NFSstruct,'GRID',     'XCOR' ,{1:G.nmax-1,1:G.mmax-1},'quiet');%'
     G.ycor      = vs_get(NFSstruct,'GRID',     'YCOR' ,{1:G.nmax-1,1:G.mmax-1},'quiet');%'
     G.xcen      = vs_get(NFSstruct,'TEMPOUT',  'XWAT' ,{2:G.nmax-1,2:G.mmax-1},'quiet');%'
     G.ycen      = vs_get(NFSstruct,'TEMPOUT',  'YWAT' ,{2:G.nmax-1,2:G.mmax-1},'quiet');%'
     
     G.alfa      = vs_get(NFSstruct,'GRID',     'ALFAS',{2:G.nmax-1,2:G.mmax-1},'quiet');%'

% TRIMFILE
% -----------------------------------

   case 'Delft3D-trim',

     % read
     % -----------------------------------

     G.mmax      = vs_let(NFSstruct,'map-const','MMAX',  'quiet');
     G.nmax      = vs_let(NFSstruct,'map-const','NMAX',  'quiet');
     G.kmax      = vs_let(NFSstruct,'map-const','KMAX',  'quiet');
     G.sigma_dz  = vs_let(NFSstruct,'map-const','THICK', 'quiet');                

     G.KCU       = vs_get(NFSstruct,'map-const','KCU', {2:G.nmax-1,1:G.mmax-1},'quiet');%'
     G.KCV       = vs_get(NFSstruct,'map-const','KCV', {1:G.nmax-1,2:G.mmax-1},'quiet');%'

     G.KCS       = vs_get(NFSstruct,'map-const','KCS', {2:G.nmax-1,2:G.mmax-1},'quiet');%'
     G.CODW      = vs_get(NFSstruct,'TEMPOUT'  ,'CODW',{2:G.nmax-1,2:G.mmax-1},'quiet');%'
     
     G.CODB      = vs_get(NFSstruct,'TEMPOUT'  ,'CODB',{1:G.nmax-1,1:G.mmax-1},'quiet');%'
     G.depcor    = vs_get(NFSstruct,'map-const','DP0' ,{1:G.nmax-1,1:G.mmax-1},'quiet');%'
     G.depcen    = corner2center(G.depcor);

     % criterion drying and flooding
    [nfltp,Chk]  = vs_get(NFSstruct,'map-const',  'DRYFLP','quiet');
    
     G.xcor      = vs_get(NFSstruct,'map-const','XCOR' ,{1:G.nmax-1,1:G.mmax-1},  'quiet');%'
     G.ycor      = vs_get(NFSstruct,'map-const','YCOR' ,{1:G.nmax-1,1:G.mmax-1},  'quiet');%'
     G.xcen      = vs_get(NFSstruct,'map-const','XZ'   ,{2:G.nmax-1,2:G.mmax-1},  'quiet');%'
     G.ycen      = vs_get(NFSstruct,'map-const','YZ'   ,{2:G.nmax-1,2:G.mmax-1},  'quiet');%'
     
     G.alfa      = vs_get(NFSstruct,'map-const','ALFAS',{2:G.nmax-1,2:G.mmax-1},  'quiet');%'
      
  otherwise,
    error('Invalid NEFIS file for this action.');
  end;


% Calculate masks
% -----------------------------------

   %% 0/1 Non-active/Active velocity point (fixed)
   G.KCU (G.KCU  ==0 ) = nan;
   G.KCV (G.KCV  ==0 ) = nan;

   %% 0/1/2 Non-active/Active/Boundary water level point (fixed)
   G.KCS (G.KCS  ==0 ) = nan;
   G.KCS (G.KCS  ==2 ) = nan;

   %% -1/1 Non-active/Active bottom point (fixed)
   G.CODB(G.CODB ==-1) = nan;
 
   %% -1/1 Non-active/Active water level point (fixed)
   G.CODW(G.CODW ==-1) = nan; % = now G.KCS

   if P.logicalmask
      % turn into logical array to save memory
      G.KCU  = ~isnan(G.KCU );
      G.KCV  = ~isnan(G.KCV );
      G.KCS  = ~isnan(G.KCS );
      G.CODB = ~isnan(G.CODB);
      G.CODW = ~isnan(G.CODW);
   end
   
%% Calculate grid properties
%% velocity points are correct.
%% They are nan when a point is dry.
%% tested with thindam scripts of Bert Jagers
%% AND
%% Apply masks
%% -----------------------------------

   %% Set inactive corner points to nan before calculating
   %% the velocity points
   %% -----------------------------------
     G.xcor(~G.CODB) = nan;
     G.ycor(~G.CODB) = nan;

   %% Calculate velocity points
   %% -----------------------------------

   if P.face
      [G.xu, G.yu, G.xv, G.yv ] = grid_corner2face     (G.xcor,G.ycor,1);
      
      % DO NOT SET TEMPORARY DRY VELOCITY POINTS TO NAN 
      G.xu (~(G.KCU)) = nan; % G.KFU & 
      G.yu (~(G.KCU)) = nan; % G.KFU & 
      
      G.xv (~(G.KCV)) = nan; % G.KFV & 
      G.yv (~(G.KCV)) = nan; % G.KFV & 
      
   end
   
   if P.geometry
      [G.guv,G.gvu,G.guu,G.gvv] = grid_corner2perimeter(G.xcor,G.ycor,1);
      
      % DO NOT SET TEMPORARY DRY VELOCITY POINTS TO NAN 
      G.gvu(~(G.KCU)) = nan; % G.KFU & 
      G.guu(~(G.KCU)) = nan; % G.KFU & 
      
      G.guv(~(G.KCV)) = nan; % G.KFV & 
      G.gvv(~(G.KCV)) = nan; % G.KFV & 
   end
   
    G.xcen(~G.CODW) = nan;
    G.ycen(~G.CODW) = nan;
   
   % save overall masks as ones to allow ALSO for muliplication
   G.maskcen           = ones(size(G.KCS));
   G.maskcen(~G.KCS)   = nan;
   G.maskcor           = ones(size(G.CODB));
   G.maskcor(~G.CODB)  = nan;

%% rembember input file as meta info
%% for later version checking
%% ------------------------

   %G.NFSstruct = NFSstruct;
    G.FileName = NFSstruct.FileName;

%% Return variables
%% ------------------------
   
   if nargout == 1
      varargout = {G};
   end
