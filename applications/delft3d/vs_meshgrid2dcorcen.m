function varargout=vs_meshgrid2dcorcen(varargin),
%VS_MESHGRID2DCORCEN   Read 2D time-independent grid info from NEFIS file.
%
%  G = VS_MESHGRID2DCORCEN(NFSstruct);
%
% where NEFISstruct is a NEFIS struct as returned by VS_USE(...)
% 
% reads all the relevant 2D time-invariant griddata 
% from NEFIS struct as returned by vs_use()
% 
% VS_MESHGRID2DCORCEN(NEFISstruct,ElementIndex) reads only the 
% data at elements in cell array ElementIndex {n,m} defining the
% CENTER points. The corner array is larger in two dimensions,
% the face arrays are larger in one dimension.
%
%        ^ eta(~y)
%               ---+---o---+---o---+---o      
%         n+1          |       |       |      
%                  x   +   x   +   x   +      
%        - - -         |       |       |      
%               ---+---Q%%%#%%%Q---+---o . . . . . Q  GVV  Q  
%         n            %:::::::%    :::|           G:::::::G  
%                  x   #:::@:::#   x:::+           U:::@:::U  
%        - - -         %:::::::%    :::|           U:::::::U  
%               ---+---Q%%%#%%%Q---+---o . . . . . Q  GVV  Q  
%         n-1          |       |       |      
%                  x   +   x   +   x   +      
%        - - -         |       |       |      
%                .       .       .      
%                .  m-1  .  m    .  m+1  > ksi (~x)
%                .       .       .      
%                                                                        
%         LEGEND:                                                      
%                                                                      
%         o  Q      corner point (all, returned)       
%         x  @      center point (all, returned)                                    
%         +  #      u or v velocity point                            
%         ::::      grid area returned
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
%   The center array is at point (n    ,m    ) with size 1x1,
%   the u      array is at point (n    ,m-1:m) with size 1x2,
%   the v      array is at point (n-1:n,m    ) with size 2x1,
%   the corner array is at point (n-1:n,m-1:m) with size 2x1,
%
% Option, value pairs are:
%
%  * 'geometry' to read grid distances as well (default off)
%               guu and gvv calculated from trim file data are NaN at boundaries
%               while the comfile contains 'mirrored' values here.
%  * 'face'     to grid face positions as well (default off)
%  * 'area'     grid cell areas (where cen.area is area between corners)
%  * 'mdf'      reads dpsopt and dpuopt from *.mdf file (default []).
%  * 'dpsopt'   method to calculate depths at center points  (only valid when 'mdf' isempty)
%  * 'dpuopt'   method to calculate depths at velocity faces (only valid when 'mdf' isempty)
%  * 'timestep' timestep for time dependent wave grid (default 1)
%  * 'latlon'   labels x to lon, and y to lat if coordinate system is spherical (default 1)
%
%  Implemented are:
%  - comfile 
%  - trimfile
%  - wavmfile (hwgxy), all co-ordinates are read, not subset, and only cor, u and v
%
% Remarks:
%  * The depth is the initial depth.
%  * The depth is positive up, like the water level, unlike the depth input file.
%  * the depth at center/face points depends on the settings of the 
%    keywords dpsopt and dpuopt in the *.mdf file.
%  * The masks are NaN at inactive points, and 1 at active points.
%  * The dimension of the arrays are [n,m]
%
% Note
% G.u.guu should be G.u.gu as 2nd letter is direction and first letter is location.
% G.v.gvv should be G.v.gv as 2nd letter is direction and first letter is location.
%
% See also: VS_USE, VS_LET, VS_DISP, VS_MESHGRID3DCORCEN, VS_LET_SCALAR,
% locations history file: VS_TRIH_STATION

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

% $Id: vs_meshgrid2dcorcen.m 17817 2022-03-14 10:41:21Z chavarri $
% $Date: 2022-03-14 18:41:21 +0800 (Mon, 14 Mar 2022) $
% $Author: chavarri $
% $Revision: 17817 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_meshgrid2dcorcen.m $

NFSstruct      = [];
P.logicalmask  = 1;
NFSstruct      = varargin{1};

   if ~odd(nargin)
      ElementIndex = varargin{2};
      iargin       = 3;
   else
      ElementIndex = {0,0,0};
      iargin       = 2;
   end
   
%% Define staggered ElementIndices

   nz = ElementIndex{1}; % indices centers
   mz = ElementIndex{2}; % indices centers
   
   if (mz(1)==0 | ...
       nz(1)==0)
      [mmax, nmax, kmax] = vs_mnk(NFSstruct);
      if (mz==0)
          mz = 2:mmax-1;
      end
      if (nz==0)
          nz = 2:nmax-1;
      end
   end
   
   if length(ElementIndex)>3
   kz  = ElementIndex{3};
   else
   kz  = 0;
   end
   
   mu   = [mz(1)-1,mz]; % indices u faces % add one before
   nu   = nz          ; % indices u faces 
   mv   = mz          ; % indices v faces 
   nv   = [nz(1)-1,nz]; % indices v faces % add one before
   
   mcor = [mz(1)-1,mz];% indices v faces % add one before 
   ncor = [nz(1)-1,nz];% indices v faces % add one before
   
   G.mcor = mcor;
   G.ncor = ncor;
   
   %disp(['m z: ',num2str(mz)])
   %disp(['n z: ',num2str(nz)])
   %disp(['m u: ',num2str(mu)])
   %disp(['n u: ',num2str(nu)])
   %disp(['m v: ',num2str(mv)])
   %disp(['n v: ',num2str(nv)])

%% READ POSITION OF THESE GRID POINTS;

P.face         = 1; % calculate      u.x, u.y, v.x, v.y
P.geometry     = 1; % calculate/load guu, guv, gvu, gvv
P.area         = 1; % calculate/load area
P.mdf          = [];
P.dpsopt       = [];% method to calculate depth at cen  from cor.
P.dpuopt       = [];% method to calculate depth at face from cor/cen.
P.timestep     = 1; % for WAVM file that has only time-dependent XP and YP
P.latlon       = 1; % labels x to lon, and y to lat if spherical

%% Arguments
   
   while iargin<=nargin,
     if    isstruct(varargin{iargin}),
          NFSstruct=varargin{iargin};
     elseif  ischar(varargin{iargin}),
       switch lower(varargin{iargin})
       
       case 'face'    ;iargin=iargin+1;P.face     = varargin{iargin};
       case 'geometry';iargin=iargin+1;P.geometry = varargin{iargin};
       case 'area'    ;iargin=iargin+1;P.area     = varargin{iargin};
       case 'mdf'     ;iargin=iargin+1;P.mdf      = varargin{iargin};
       case 'dpsopt'  ;iargin=iargin+1;P.dpsopt   = varargin{iargin};
       case 'dpuopt'  ;iargin=iargin+1;P.dpuopt   = varargin{iargin};
       case 'timestep';iargin=iargin+1;P.timestep = varargin{iargin};
       case 'latlon'  ;iargin=iargin+1;P.latlon   = varargin{iargin};
       
       otherwise
         error(sprintf('Invalid string argument: %s.',varargin{i}));
       end
     end;
     iargin=iargin+1;
   end;
   
   G.comment      = 'The array dimensions are [n x m]';
   G.cor.comment  = 'The array dimensions are (n-1) x (m-1)';
   G.cen.comment  = 'The array dimensions are (n-2) x (m-2)';
   G.u.comment    = 'The array dimensions are (n-2) x (m-1)';
   G.v.comment    = 'The array dimensions are (n-1) x (m-2)';
   
   if isempty(NFSstruct),
     NFSstruct=vs_use('lastread');
   end;
   
%% Read depth interpolation options from input file

   if ~isempty(P.mdf),
     mdf      = delft3d_io_mdf('read',P.mdf);
     if isfield(mdf.keywords,'dpsopt')
      P.dpsopt = mdf.keywords.dpsopt;
     end
     if isfield(mdf.keywords,'dpsopt')
      P.dpuopt = mdf.keywords.dpsopt;
     end
   end;

   switch vs_type(NFSstruct),

%% comfile

   case {'Delft3D-com','Delft3D-tram','Delft3D-botm'},

     G.mmax        =  vs_let(NFSstruct,'GRID'     ,'MMAX'             ,'quiet');
     G.nmax        =  vs_let(NFSstruct,'GRID'     ,'NMAX'             ,'quiet');
     G.kmax        =  vs_let(NFSstruct,'GRID'     ,'KMAX'             ,'quiet');
     G.sigma_dz    =  vs_let(NFSstruct,'GRID'     ,'THICK'            ,'quiet');   
     G.coordinates =  vs_let(NFSstruct,'GRID'     ,'COORDINATES'      ,'quiet');
     G.layer_model =  vs_let(NFSstruct,'GRID'     ,'LAYER_MODEL'      ,'quiet');
     G.coordinates =  strtrim(permute(G.coordinates,[1 3 2]));
     G.layer_model =  strtrim(permute(G.layer_model,[1 3 2]));
     
     if strmatch('Z-MODEL', G.layer_model)
     G.ZK          =  vs_let(NFSstruct,'GRID'     ,'ZK'               ,'quiet');
     end
     
     
       u.KCU       =  vs_get(NFSstruct,'KENMCNST' ,'KCU'  ,{nu  ,mu  },'quiet');%'
       v.KCV       =  vs_get(NFSstruct,'KENMCNST' ,'KCV'  ,{nv  ,mv  },'quiet');%'

       cen.KCS     =  vs_get(NFSstruct,'KENMCNST' ,'KCS'  ,{nz  ,mz  },'quiet');%'
%        cen.CODW    =  vs_get(NFSstruct,'TEMPOUT'  ,'CODW' ,{nz  ,mz  },'quiet');%'

%        cor.CODB    =  vs_get(NFSstruct,'TEMPOUT'  ,'CODB' ,{ncor,mcor},'quiet');%'
       
     G.cor.dep     = -vs_get(NFSstruct,'INITBOT'  ,'DP0'  ,{ncor,mcor},'quiet');%'
     G.cen.dep     = -vs_get(NFSstruct,'INITBOT'  ,'DPS'  ,{nz  ,mz  },'quiet');%' 

%    DP0             REAL    *  4                  [   M   ]        ( 7 6 )
%        Initial bottom depth in bottom points (positive down) [extrapolated in case of dpsopt=DP ??]
%    DPS             REAL    *  4                  [   M   ]        ( 7 6 )
%        Initial bottom depth in zeta points (positive down)

     G.cen.dep_comment = 'positive up';
     if isempty(P.dpsopt)
     G.cor.dep_comment = 'positive up; (possibly) extrapolated from centers by Delft3d-FLOW to com*';
     disp('com-file: Depth at corners; (possibly extrapolated from centers by Delft3D-FLOW to com*)')
     else
        if     strcmpi(deblank(P.dpsopt),'dp')
        G.cor.dep_comment = 'positive up; extrapolated from centers by Delft3d-FLOW to com*';
        disp('com-file: Depth at corners; extrapolated from centers by Delft3d-FLOW to com*')
        elseif strcmpi(deblank(P.dpsopt),'dp')
        G.cor.dep_comment = 'positive up; as speficied in *.dep input file.';
        disp('com-file: Depth at corners; as speficied in *.dep input file.')
        end
     end
     
     G.cor.(x)     =  vs_get(NFSstruct,'GRID',     'XCOR' ,{ncor,mcor},'quiet');%'
     G.cor.(y)     =  vs_get(NFSstruct,'GRID',     'YCOR' ,{ncor,mcor},'quiet');%'
     G.cen.(x)     =  vs_get(NFSstruct,'TEMPOUT',  'XWAT' ,{nz  ,mz  },'quiet');%'
     G.cen.(y)     =  vs_get(NFSstruct,'TEMPOUT',  'YWAT' ,{nz  ,mz  },'quiet');%'
     
     G.cen.alfa    =  vs_get(NFSstruct,'GRID',     'ALFAS',{nz  ,mz  },'quiet');%'

%% TRIMFILE

   case 'Delft3D-trim',

     G.mmax        =  vs_let(NFSstruct,'map-const','MMAX'             ,'quiet');
     G.nmax        =  vs_let(NFSstruct,'map-const','NMAX'             ,'quiet');
     G.kmax        =  vs_let(NFSstruct,'map-const','KMAX'             ,'quiet');
     G.sigma_dz    =  vs_let(NFSstruct,'map-const','THICK'            ,'quiet');     
     G.dryflp      =  vs_get(NFSstruct,'map-const','DRYFLP'           ,'quiet');

     %% Checks for Z model legacy
     if ~isempty(vs_get_elm_size(NFSstruct,'LAYER_MODEL'))
      G.layer_model =  vs_let(NFSstruct,'map-const','LAYER_MODEL'      ,'quiet');
      G.layer_model =  permute(G.layer_model,[1 3 2]);
      if strmatch('Z-MODEL', G.layer_model)
      G.ZK          =  vs_let(NFSstruct,'map-const','ZK'               ,'quiet');
      end
     end
     if ~isempty(vs_get_elm_size(NFSstruct,'COORDINATES')) % Z model legacy check
      G.coordinates =  vs_let(NFSstruct,'map-const','COORDINATES'      ,'quiet');
      G.coordinates =  permute(G.coordinates,[1 3 2]);     
     end

       u.KCU       =  vs_get(NFSstruct,'map-const','KCU'  ,{nu  ,mu  },'quiet');%'
       v.KCV       =  vs_get(NFSstruct,'map-const','KCV'  ,{nv  ,mv  },'quiet');%'

       cen.KCS     =  vs_get(NFSstruct,'map-const','KCS'  ,{nz  ,mz  },'quiet');%'
%        cen.CODW    =  vs_get(NFSstruct,'TEMPOUT'  ,'CODW' ,{nz  ,mz  },'quiet');%'
     
%        cor.CODB    =  vs_get(NFSstruct,'TEMPOUT'  ,'CODB' ,{ncor,mcor},'quiet');%'

     % depfile contains a raw copy of the dep fuile, so can be either corner or center
     % depfile       = -vs_get(NFSstruct,'map-const','DP0'  ,{ncor,mcor},'quiet')

     %% Read center data (if any)
     DPS0 = 0;
     for ielm =1:length(NFSstruct.ElmDef)
        if strcmpi(NFSstruct.ElmDef(ielm).Name,'DPS0')
           DPS0 = 1;
        end
     end
     
  if DPS0
     G.cen.dep     = -vs_get(NFSstruct,'map-const','DPS0' ,{nz  ,mz  },'quiet');%'
  if strcmpi(strtrim(G.dryflp),'DP')
      if any(G.mmax==[1,3]) || any(G.nmax==[1,3])
        G.cor.dep     = center2corner1(G.cen.dep,'nearest');
      else
        G.cor.dep     = center2corner(G.cen.dep,'nearest');
      end
     disp('trim-file: Depth at corners; extrapolated from centers by VS_MESHGRID2DCORCEN from trim*')
     G.cen.dep_comment = 'positive up';
     G.cor.dep_comment = 'positive up; extrapolated from centers by VS_MESHGRID2DCORCEN from trim*';
  else
     G.cor.dep     = -vs_get(NFSstruct,'map-const','DP0'  ,{ncor,mcor},'quiet');
     disp('trim-file: Depth at corners; as speficied in *.dep input file.')
     G.cen.dep_comment = 'positive up';
     G.cor.dep_comment = 'positive up; speficied in *.dep input file.';
  end
  else
    %G.cor.dep     = nan.*cor.CODB;
    %G.cen.dep     = nan.*cen.CODW;
     G.cor.dep     = -vs_get(NFSstruct,'map-const','DP0'  ,{ncor,mcor},'quiet');
     G.cen.dep     = corner2center(G.cor.dep);
     warning('error: No sensible depth data on trim file.')
  end
     
%    DP0             REAL    *  4                  [   M   ]        ( 7 6 )
%        Initial bottom depth (positive down) [NOT extrapolated to corner points as in comfile, but simple copy of *.dep file??]
%    DPS0            REAL    *  4                  [   M   ]        ( 7 6 )
%        Initial bottom depth at zeta points (positive down)     
     if P.latlon & strmatch(G.coordinates,'SPHERICAL')
        x = 'lon';
        y = 'lat';
     else
        x = 'x';
        y = 'y';
     end

     G.cor.(x)     =  vs_get(NFSstruct,'map-const','XCOR' ,{ncor,mcor},'quiet');%'
     G.cor.(y)     =  vs_get(NFSstruct,'map-const','YCOR' ,{ncor,mcor},'quiet');%'
     G.cen.(x)     =  vs_get(NFSstruct,'map-const','XZ'   ,{nz  ,mz  },'quiet');%'
     G.cen.(y)     =  vs_get(NFSstruct,'map-const','YZ'   ,{nz  ,mz  },'quiet');%'
     
     G.cen.alfa    =  vs_get(NFSstruct,'map-const','ALFAS',{nz  ,mz  },'quiet');%'
      
%% wavm file
% -------------------------------------

   case {'Delft3D-hwgxy'},
       
     %if P.latlon & ~any(strfind(G.coordinates,'CARTESIAN'))
     %   x = 'lon';
     %   y = 'lat';
     %else
        x = 'x';
        y = 'y';
     %end       

     disp('For hwgxy all co-ordimnates are read, not subset.')
     % NOTE THAT M AND N ARE SWAPPED HRE TO GET SAME M and N AS FLOW GRID !!!
     G.cor.(x)     =  vs_get(NFSstruct,'map-series',{1},'XP'  ,{0,0},'quiet')';
     G.cor.(y)     =  vs_get(NFSstruct,'map-series',{1},'YP'  ,{0,0},'quiet')';
     G.cor.mask    =  vs_get(NFSstruct,'map-series',{1},'CODE',{0,0},'quiet')';
     
     G.cor.(x)(~G.cor.mask) = NaN;
     G.cor.(y)(~G.cor.mask) = NaN;
     
  otherwise,
    error('Invalid NEFIS file for this action.');
  end;

%% Calculate masks

   switch vs_type(NFSstruct),
   case {'Delft3D-com','Delft3D-tram','Delft3D-botm',...
         'Delft3D-trim'}, % not wave

      %% 0/1 Non-active/Active velocity point (fixed)
         u.KCU (  u.KCU  ==0 ) = nan;
         v.KCV (  v.KCV  ==0 ) = nan;

      %% 0/1/2 Non-active/Active/Boundary water level point (fixed)
         cen.KCS (  cen.KCS  ==0 ) = nan;
         cen.KCS (  cen.KCS  ==2 ) = nan;

      %% -1/1 Non-active/Active bottom point (fixed)
%          cor.CODB(  cor.CODB ==-1) = nan;
 
      %% -1/1 Non-active/Active water level point (fixed)
         cen.KCS(  cen.KCS ==-1) = nan; % = now G.KCS

         if P.logicalmask
            % turn into logical array to save memory
            u.KCU    = ~isnan(u.KCU   );
            v.KCV    = ~isnan(v.KCV   );
            cen.KCS  = ~isnan(cen.KCS );
%             cor.CODB = ~isnan(cor.CODB);
%             cen.CODW = ~isnan(cen.CODW);
         end
         
      %% Calculate grid properties
      %  velocity points are correct.
      %  They are nan when a point is dry.
      %  tested with thindam scripts of Bert Jagers
      %  AND
         
      %  Apply masks
      %  Do not set the inactive corner points to nan before calculating
      %  the velocity points, otherwise coordinates at your boundayr get lost.

         G.cen.(x)(~(cen.KCS)) = nan;
         G.cen.(y)(~(cen.KCS)) = nan;
         
%          G.cor.(x)(~(cor.CODB)) = nan;
%          G.cor.(y)(~(cor.CODB)) = nan;
         

      %% Redefine masks
      %  Set overall masks as [ones and NaNs] to allow for muliplication
         
         G.cen.mask            = ones(size(cen.KCS));
         G.cen.mask(~cen.KCS)  = nan;
         
         G.cor.mask            = nan*ones(size(G.cor.x));
         for n = 1:G.nmax-2;
            for m = 1:G.mmax-2;
                if G.cen.mask(n,m) == 1;
                   G.cor.mask(n:n+1,m:m+1) = 1;
                end
            end
         end         
      
         G.u.mask              = ones(size(u.KCU));
         G.u.mask(~u.KCU)      = nan;
      
         G.v.mask              = ones(size(v.KCV));
         G.v.mask(~v.KCV)      = nan;
         
         G.cen.dep = G.cen.dep.*G.cen.mask;
%          G.cor.dep = G.cor.dep.*G.cor.mask;          
         

%% Calculate depths at velocity points

     G.u.dep = nan.*ones(size(G.u.mask));
     G.v.dep = nan.*ones(size(G.v.mask));
     
     if strcmpi(P.dpuopt,'mean') % mean of depth points at both end of face !!
        if strcmpi(P.dpsopt,'dp')
        error('however moronically: dpuopt ''mean'' and dpsopt ''dp'' cannot be used together')
        error('dpsopt ''mean'' not implemented in this function VS_MESHGRID2DCORCEN as it requires dummy cen depths.')
        G.u.dep(:      ,2:end-1) =    (G.cen.dep(:      ,1:end-1) + ...
                                       G.cen.dep(:      ,2:end  ))./2;% n by m
        G.v.dep(2:end-1,:      ) =    (G.cen.dep(1:end-1,:      ) + ...
                                       G.cen.dep(2:end  ,:      ))./2;% n by m
        else
        G.u.dep(:      ,:      ) =    (G.cor.dep(1:end-1,:      ) + ...
                                       G.cor.dep(2:end  ,:      ))./2;% n by m
        G.v.dep(:      ,:      ) =    (G.cor.dep(:      ,1:end-1) + ...
                                       G.cor.dep(:      ,2:end  ))./2;% n by m
        end
     elseif strcmpi(P.dpuopt,'min') % parallel to face !!!
        error('dpsopt ''max'' not implemented in this function VS_MESHGRID2DCORCEN as it requires dummy cen depths.')
        G.u.dep(:      ,2:end-1) = min(G.cen.dep(:      ,1:end-1),...
                                       G.cen.dep(:      ,2:end  ))   ;% n by m
        G.v.dep(2:end-1,:      ) = min(G.cen.dep(1:end-1,:      ),...
                                       G.cen.dep(2:end  ,:      ))   ;% n by m
     elseif strcmpi(P.dpuopt,'max') % parallel to face !!!
        error('dpsopt ''max'' not implemented in FLOW.')
        G.u.dep(:      ,2:end-1) = max(G.cen.dep(:      ,1:end-1),...
                                       G.cen.dep(:      ,2:end  ))   ;% n by m
        G.v.dep(2:end-1,:      ) = max(G.cen.dep(1:end-1,:      ),...
                                       G.cen.dep(2:end  ,:      ))   ;% n by m
     elseif strcmpi(P.dpuopt,'upw' )
        disp('No depths at faces because they depend on flow condition')
     end         
   
   end;

%% Calculate velocity points

   if P.face

      [G.u.(x), G.u.(y), G.v.(x), G.v.(y)] = grid_corner2face(G.cor.(x),G.cor.(y),2);
      
      % DO NOT SET TEMPORARY DRY VELOCITY POINTS TO NAN 
      % NOR BOUNDARY POINTS
      
      %G.u.x (~(u.KCU)) = nan; % u.KFU & 
      %G.u.y (~(u.KCU)) = nan; % u.KFU & 
      
      %G.v.x (~(v.KCV)) = nan; % v.KFV & 
      %G.v.y (~(v.KCV)) = nan; % v.KFV & 
      
   end
   
%% Load grid cell areas
   
   if P.area
   
      switch vs_type(NFSstruct),
      
      %% comfile
      case {'Delft3D-com','Delft3D-tram','Delft3D-botm'},
      
         G.cen.area = vs_let(NFSstruct,'GRID','GSQS',{nz,mz},'quiet');
         G.cen.area = permute(G.cen.area,[2 3 1]); % do not use squeeze as that cna be wrong for 1D grids
         G.cen.area_comment = 'This area is incorrectly calculated by Delft3D-FLOW,and is not equal to the area of the two constituting triangles.';
      
      %% trimfile, wavm file
      case {'Delft3D-trim','Delft3D-hwgxy'}
      
         G.cen.area = grid_area(G.cor.(x),G.cor.(y));
         G.cen.area_comment = 'This area is calculated exactly as the area of the two constituting triangles, whereas Delft3D-FLOW uses an approximation.';
      
      otherwise,
         error('Invalid NEFIS file for this action.');
      end;

   end

%% Load grid cell sizes
   
   if P.geometry
   
      switch vs_type(NFSstruct),
      
      %% comfile
      case {'Delft3D-com','Delft3D-tram','Delft3D-botm'},
      
         G.u.gvu = vs_let(NFSstruct,'GRID','GVU',{nu,mu},'quiet');
         G.u.guu = vs_let(NFSstruct,'GRID','GUU',{nu,mu},'quiet');
         
         G.v.guv = vs_let(NFSstruct,'GRID','GUV',{nv,mv},'quiet');
         G.v.gvv = vs_let(NFSstruct,'GRID','GVV',{nv,mv},'quiet');
      
         G.u.gvu = permute(G.u.gvu,[2 3 1]);
         G.u.guu = permute(G.u.guu,[2 3 1]);
         
         G.v.guv = permute(G.v.guv,[2 3 1]);
         G.v.gvv = permute(G.v.gvv,[2 3 1]);

      %% trimfile, wavm file
      case {'Delft3D-trim','Delft3D-hwgxy'}
      
         [dummy1,dummy2,G.v.guv,G.u.gvu,G.u.guu,G.v.gvv] = grid_corner2perimeter(G.cor.x,G.cor.y);
         clear dummy1; clear dummy2;

         %% At the boundary the comfile gives realistic boundary-perpendicular distances
         %  while with this method they are undefined (NaN).
      	  
      otherwise,
         error('Invalid NEFIS file for this action.');
      end;
      
      %% Calculate grid distance at center points
      %  (needed for du_dksi at center points)

      G.cen.guu = (G.u.guu(:      ,1:end-1) + G.u.guu(:    ,2:end))./2; % average in m-direction, is 2nd dim
      G.cen.gvv = (G.v.gvv(1:end-1,:      ) + G.v.gvv(2:end,:    ))./2; % average in n-direction, is 1st dim
   
      % G.cen.guu should be G.cen.gu as 2nd letter is direction
      % G.cen.gvv should be G.cen.gv as 2nd letter is direction

      %% Apply masks

      % DO NOT SET TEMPORARY DRY VELOCITY POINTS TO NAN 
      % NOR BOUNDARY POINTS
      %G.u.gvu(~(u.KCU)) = nan; % u.KFU & 
      %G.u.guu(~(u.KCU)) = nan; % u.KFU & 
      
      %G.v.guv(~(v.KCV)) = nan; % v.KFV & 
      %G.v.gvv(~(v.KCV)) = nan; % v.KFV & 

   end


%% rembember input file as meta info
%  for later version checking

   %G.NFSstruct = NFSstruct;
    G.FileName = NFSstruct.FileName;

%% Return variables
   
   if nargout == 1
      varargout = {G};
   end

%% EOF
