function varargout = arrow2(varargin)
%ARROW2 Quiver plot with option to adapt arrows to aspect ratio.
%
%   ARROW2(X,Y,U,V) plots velocity vectors as arrows with components (u,v)
%   at the points (x,y).  The matrices X,Y,U,V must all be the same size
%   and contain corresponding position and velocity components (X and Y
%   can also be vectors to specify a uniform grid).  ARROW2 does not
%   automatically scale the arrows to fit within the grid. If U and or V
%   are scalars, they are replicated to a matrix of the size of X.
%                                                                           
%   handles = ARROW2(...) returns the handles of both the head and shaft 
%   patches out of which the arrows are constructed. The arrays handles.head and 
%   handles.shaft have the same size as X.
%                                                                           
%   The primary reason for existance of arrow2 is that arrow2 
%   can make the arrows look <undistorted> when the dataaspectratio
%   settings of the axes are not [1 1 whatever] (as set by axis equal).  
%   arrow2 by default fixes the data aspect ratio by setting  
%   DataAspectRatioMode to manual and uses that aspect for plotting arrows. 
%   So make sure that the DataAspectRatio is satisfactory before calling arrow2.
%   Consequently a velocity vector of e.g. (1,3) will also 
%   appear with a slope 1:3. Do realize that this arrow does NOT point 
%   in the same direction as a distored arrow (created by quiver) would.
%
%   Also a 2 or 3 element vector ArrowAspectRatio specifying the
%   DataAspectRatio for which the arrows look undistored can be supplied
%   (see STRUCT below). When this vector is [], ArrowAspectRatio is set
%   to the axes' DataAspectRatio (default). Specifying [1 1] or [1 1 whatever]
%   results in quiver like appearance.
%
%   The second reason for existance of arrow2 (compared to arrow) is that 
%   in arrow2 no arrows are created if at least one of X,Y,U,V is NaN (unlike
%   arrow from the matlab central). Note that in that case the
%   corresponding handle is set also to NaN. To be
%   able to set the  properties of all arrows at once
%   nevertheless use for instance:
%   set(handles.shaft(~isnan(handles.shaft)),'edgecolor','g')
%
%   ARROW2(U,V,S) or ARROW2(X,Y,U,V,S) stretches the arrow's
%   dimensions with scalar S.
%                                                                           
%   ARROW2(U,V,S,color) or ARROW2(X,Y,U,V,S,color) can be used
%   to set the color of the arrow in a simple way (only string colors as 'r')
%                                                                           
%   ARROW2(U,V,STRUCT) or ARROW2(X,Y,U,V,STRUCT) draws arrows with the
%   dimensions, scale and coloring as specified in the fields of the struct "STRUCT". 
%   STRUCT has the following fields and with the following default 
%   values. The STRUCT fields that are not specified in the input struct STRUCT           
%   are kept at the given default values. If STRUCT contains a field called
%   'returninput' with value 1, and an output argument is specified, the
%   input values are added to the output struct containing the patch handles.
%   The defaults can be obtained by calling without input: S = arrow2();
%
%   Appearance:
%      STRUCT.scale           = 1;
%
%      STRUCT.color           = 'k'; 
%         overwrites
%      STRUCT.edgecolor       = 'k'
%      STRUCT.facecolor       = 'k'
%         overwrites
%      STRUCT.shaft.edgecolor = 'k'; 
%      STRUCT.shaft.facecolor = 'k'; 
%      STRUCT.head.edgecolor  = 'k'; % but cdata is filled to allow facecolor to be flat
%      STRUCT.head.facecolor  = 'k'; % but cdata is filled to allow facecolor to be flat
%
%      STRUCT.shaft.linestyle = '-' 
%      STRUCT.shaft.linestyle = '-' 
%
%   Distortion:
%      STRUCT.ArrowAspectRatio    = []; 
%      STRUCT.DataAspectRatioMode = 'manual'
%         By default the axes' data are
%         locked in arrow2. For subplots this might lead to unwanted behaviour.
%         Set STRUCT.DataAspectRatioMode to 'auto' to make sure that the plotbox of subplot
%         is not resized.
%   
%   Shape:				          
%                              STRUCT.L1    =  1.0;
%      STRUCT.W2    = 0.0;     STRUCT.L2    =  1.0;
%      STRUCT.W3    = 0.0;     STRUCT.L3    =  1.0;
%      STRUCT.W4    = 0.3;     STRUCT.L4    =  0.7;
%      STRUCT.W5    = 0.3;     STRUCT.L5    =  0.7;
%      STRUCT.W6    = 0.0;     STRUCT.L6    =  0.0;
%      STRUCT.elevation = 1e3; STRUCT.AspectRatioNormalisation = 'min',.mean','max',1,2
%      STRUCT.clipping  = 'on'
%
%      where elevation is the vertical position as passed to fill3 
%      to make sure the arrows appear on top of other objects.
%
%      where AspectRatioNormalisation is used to determine for which axes   
%      the arrow length matches exactly the velocity. min uses normalises
%      with the smallest aspect ratio of x an y, 1=x etc.
%                                                                           
%      where the W's and L's are defined as follows:
%      (Note the (W3,L3) (W4,L4), (W5,L5) and (W6,L6) pairs.)
%                                                                           
%                                   W4       W4                            
%                 positive  +------------+------------+- negative          
%                           .       W5   |   W5       .                    
%                           .--+---------+---------+- .                    
%                           .  .         |         .  .                    
%                           .  .    -+---+---+-    .  .                    
%                           .  .     . W3 W3 .     .  .                    
%                           .  .     .       .     .  .                    
%                           .  .     .   H   .     .  .                    
%            + ..........................o   .     .  .                    
%            |              .  .     .  /5\  .     .  .                    
%            |              .  .     . /   \ .     .  .                    
%            | W1 not used  .  .     ./     \.     .  .                    
%         L1 | W2 not used  .  .     / head  \     .  .                    
%            |              .  .    /.       .\    .  .                
%            | L2           .  .   / .  H1   . \   .  .         
%            |  +................ /..... o......\  .  .                    
%            |  |  L3       .  . /  H2 /   \ H8  \ .  .                    
%            |  |  +............/... o...... o    \.  .                    
%            |  |  |        .  /    /|S2   S6|\    \  .                    
%            |  |  |        . /.   / |       | \   .\ .                    
%            |  |  | L4     ./ .  /  |       |  \  . \.                    
%            |  |  |  +.....o  . /   |       |   \ .  o                    
%            |  |  |  |    H4\ ./   |         |   \. /H6                   
%            |  |  |  |  +... \o    |  shaft  |    o/                      
%            |  |  |  |  |     H3   |         |   H7                       
%            |  |  |  |  |L5        |         |                            
%            |  |  |  |  |         |     S4    |                           
%            +--+--+--+--+.........|.... o.....|............. point S4 is the origin       
%            |                     |    / \    |                           
%         L6 |                     |  /     \  |                           
%            + ................... o/.........\o                           
%                                  S3          S5                           
%                                                                           
%                                   +-----+-----+                           
%                                     W6     W6                             
%                                                                           
% See also: quiver, quiverlegend, quiver3, feather, arrow2, (downloadcentral): arrow, arrow3

% Called functions: - cart2pol     (matlab\specfun)
%                   - mergestructs (included below)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
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

%% SVN keywords
% $Id: arrow2.m 7108 2012-08-02 11:37:11Z boer_g $
% $Date: 2012-08-02 19:37:11 +0800 (Thu, 02 Aug 2012) $
% $Author: boer_g $
% $Revision: 7108 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/arrow2.m $
% $Keywords: $

%% Default initialisation

warnings = 0;
      I.scale                    = 1;
      I.ArrowAspectRatio         = [];
      I.shaft.edgecolor          = 'k';
      I.shaft.facecolor          = 'k';
      I.shaft.linestyle          = '-';
      I.head.edgecolor           = 'k';
      I.head.facecolor           = 'k';
      I.head.linestyle           = '-';
      I.DataAspectRatioMode      = 'manual';
      I.AspectRatioNormalisation = 'min';
      I.clipping                 = 'on';
      
      I.W0        =  0.0;
      I.W1        =  0.0;
      I.W2        =  0.0;
      I.W3        =  0.0;
      I.W4        =  0.3;
      I.W5        =  0.3;
      I.W6        =  0.0;
      	            
      I.L0        =  0.0;
      I.L1        =  1.0;
      I.L2        =  1.0;
      I.L3        =  1.0;
      I.L4        =  0.7;
      I.L5        =  0.7;
      I.L6        = -0.0;
      I.elevation = 1e3;
      
      if nargin==0
          varargout = {I};
          return
      end

%% Input
   if nargin==2
      I.u     = squeeze(varargin{1});
      I.v     = squeeze(varargin{2});
   elseif nargin==3
      I.u     = squeeze(varargin{1});
      I.v     = squeeze(varargin{2});
      I.scale =         varargin{3};
   elseif nargin==4
      if     isstruct(varargin{4})
         I.u     = squeeze(varargin{1});
         I.v     = squeeze(varargin{2});
         I.scale =         varargin{3};
         I = mergestructs(I,varargin{4});
      elseif ischar(varargin{4})
         I.u     = squeeze(varargin{1});
         I.v     = squeeze(varargin{2});
         I.scale =         varargin{3};
         I.color =         varargin{4};
     else
         I.x     = squeeze(varargin{1});
         I.y     = squeeze(varargin{2});
         I.u     = squeeze(varargin{3});
         I.v     = squeeze(varargin{4});
     end
   elseif nargin==5
      I.x     = squeeze(varargin{1});
      I.y     = squeeze(varargin{2});
      I.u     = squeeze(varargin{3});
      I.v     = squeeze(varargin{4});
      if ischar(varargin{5})
        I.color = varargin{5};
     elseif isstruct(varargin{5})
        I = mergestructs(I,varargin{5});
     else
        I.scale = varargin{5};
     end
   elseif nargin==6
      I.x     = squeeze(varargin{1});
      I.y     = squeeze(varargin{2});
      I.u     = squeeze(varargin{3});
      I.v     = squeeze(varargin{4});
      I.scale = varargin{5};
      if     isstruct(varargin{6})
          I = mergestructs(I,varargin{6});
          % NOTE: this lead to overwriting of 'scale_a' by default scale again:
          % I = arrow2();I.W1 = x;arrow2(x,y,u,v,scale_a,S)
          disp([mfilename,' scaled arrows with = ',num2str(I.scale)])
      elseif ischar(varargin{6})
          I.color = varargin{6};
      else
          error('');
      end
   end
   
   if numel(I.u)==1
       I.u = repmat(I.u,size(I.x));
   end
   if numel(I.v)==1
       I.v = repmat(I.v,size(I.x));
   end
       
   if isfield(I,'color')
       I.edgecolor           = I.color;
       I.facecolor           = I.color;
       I.shaft.edgecolor     = I.color;
       I.shaft.facecolor     = I.color;
       I.head.edgecolor      = I.color;
       I.head.facecolor      = I.color;
   end   
   
   if isfield(I.head,'color')
       I.head.edgecolor      = I.head.color;
       I.head.facecolor      = I.head.color;
   end    
   if isfield(I.head,'color')
       I.shaft.edgecolor     = I.shaft.color;
       I.shaft.facecolor     = I.shaft.color;
   end
   
   clear varargin
   
   I.ABS    = sqrt (I.u.^2+ I.v.^2);
   I.ANG    = atan2(I.v,I.u); % [-pi ,pi]

   I.DataAspectRatio  = get(gca,'DataAspectRatio');
   %([mfilename,' adapted arrows to DataAspectRatio = ',num2str(I.DataAspectRatio)])
   
   if isempty(I.ArrowAspectRatio)
      
      % copy axes' DataAspectRatio and make them the arrow's aspectratio
      % ------------------------------

      I.ArrowAspectRatio = get(gca,'DataAspectRatio');

   end
   
   %% BELOW is very wrong because for a dataaspecratio of [1 1 1] this yields
   %% arrowaspectratio of [0.70711 0.70711 0.70711]
   
   %   % normalize with the diagonal of the x and y aspectratio's, so there
   %   % is no effect on the overall scaling.
   %   % ------------------------------
   %   I.ArrowAspectRatio = I.ArrowAspectRatio./(sqrt(sum(I.ArrowAspectRatio(1:2).^2)))

   if isnumeric(I.AspectRatioNormalisation)
   
      I.ArrowAspectRatio = I.ArrowAspectRatio./(I.ArrowAspectRatio(I.AspectRatioNormalisation));

   elseif ischar(I.AspectRatioNormalisation)
   
      if     strcmpi(I.AspectRatioNormalisation,'min')
             I.ArrowAspectRatio = I.ArrowAspectRatio./(min (I.ArrowAspectRatio(1:2)));
      elseif strcmpi(I.AspectRatioNormalisation,'mean')
             I.ArrowAspectRatio = I.ArrowAspectRatio./(mean(I.ArrowAspectRatio(1:2)));
      elseif strcmpi(I.AspectRatioNormalisation,'max')
             I.ArrowAspectRatio = I.ArrowAspectRatio./(max (I.ArrowAspectRatio(1:2)));
      end
   end
      
   set (gca,'DataAspectRatioMode',I.DataAspectRatioMode);
   if warnings
   if strcmpi(I.DataAspectRatioMode,'manual')
   disp(['warning from arrow2: DataAspectRatioMode locked to: ',num2str(I.DataAspectRatio)])
   end
   end

   holdstate = get (gca,'nextplot');
               set (gca,'nextplot','add');

%% ARROW HEAD

   %% Calculate relative length of template patch sides 

   [H.ang(1),H.abs(1)] = cart2pol(+I.L2 - I.L0,     0 - I.W0);
   
   [H.ang(2),H.abs(2)] = cart2pol(+I.L3 - I.L0,  I.W3 - I.W0);
   [H.ang(3),H.abs(3)] = cart2pol(+I.L5 - I.L0,  I.W5 - I.W0);
   [H.ang(4),H.abs(4)] = cart2pol(+I.L4 - I.L0,  I.W4 - I.W0);
   [H.ang(5),H.abs(5)] = cart2pol(+I.L1 - I.L0,     0 - I.W0); % symmetry point
   [H.ang(6),H.abs(6)] = cart2pol(+I.L4 - I.L0, -I.W4 - I.W0);
   [H.ang(7),H.abs(7)] = cart2pol(+I.L5 - I.L0, -I.W5 - I.W0);
   [H.ang(8),H.abs(8)] = cart2pol(+I.L3 - I.L0, -I.W3 - I.W0);
   
   %% Calculate absolute length of all arrow2 patch sides 

   for i=1:length(H.abs)
      H.ABS(:,:,i) = (I.scale*H.abs(i)).*I.ABS;
      H.ANG(:,:,i) =          H.ang(i) + I.ANG;
   end

   H.x0 = H.ABS.*cos(H.ANG).*I.ArrowAspectRatio(1);
   H.y0 = H.ABS.*sin(H.ANG).*I.ArrowAspectRatio(2);
   
   H.x  = H.x0 + repmat(I.x,[1,1,length(H.abs)]);
   H.y  = H.y0 + repmat(I.y,[1,1,length(H.abs)]);
   
   %% Draw all patches

   OUT.head = nan.*ones(size(I.x));
   for i=1:(size(I.x,1))
      for j=1:(size(I.x,2))
         OUT.head(i,j) = fill3(squeeze(H.x(i,j,:)),...
                               squeeze(H.y(i,j,:)),...
                               repmat(I.elevation,size(squeeze(H.x(i,j,:)))),I.ABS(i,j)); % this allows for shading flat afterwards
         %if ~strcmp(I.facecolor_head,'flat')                      
         %set(OUT.head(i,j),'facecolor',I.facecolor_head);
         %end
         %set(OUT.head(i,j),'edgecolor',I.edgecolor_head);
      end
   end

   if isfield(I.head,'facecolor');set(OUT.head,'facecolor',I.head.facecolor);end
   if isfield(I.head,'edgecolor');set(OUT.head,'edgecolor',I.head.edgecolor);end
   if isfield(I.head,'linestyle');set(OUT.head,'linestyle',I.head.linestyle);end
   if isfield(I     ,'clipping' );set(OUT.head,'clipping' ,I.clipping      );end

%% ARROW SHAFT

   %% Calculate relative length of template patch sides 

   [S.ang(1),S.abs(1)] = cart2pol(+I.L2      - I.L0,     0 - I.W0);
   
   [S.ang(2),S.abs(2)] = cart2pol(+I.L3      - I.L0,  I.W3 - I.W0);
   [S.ang(3),S.abs(3)] = cart2pol(+I.L6      - I.L0,  I.W6 - I.W0);
   [S.ang(4),S.abs(4)] = cart2pol(           - I.L0,     0 - I.W0);
   [S.ang(5),S.abs(5)] = cart2pol(+I.L6      - I.L0, -I.W6 - I.W0);
   [S.ang(6),S.abs(6)] = cart2pol(+I.L3      - I.L0, -I.W3 - I.W0);   
   
   %% Calculate absolute length of all arrow2 patch sides 
   
   for i=1:length(S.abs)
      S.ABS(:,:,i) = (I.scale*S.abs(i)).*I.ABS;
      S.ANG(:,:,i) =          S.ang(i) + I.ANG;
   end
   
   S.x0 = S.ABS.*cos(S.ANG).*I.ArrowAspectRatio(1);
   S.y0 = S.ABS.*sin(S.ANG).*I.ArrowAspectRatio(2);
   
   S.x  = S.x0 + repmat(I.x,[1,1,length(S.abs)]);
   S.y  = S.y0 + repmat(I.y,[1,1,length(S.abs)]);
   
   %% Draw all patches
   
   OUT.shaft = nan.*ones(size(I.x));
   for i=1:(size(I.x,1))
      for j=1:(size(I.x,2))
         OUT.shaft(i,j) = fill3(squeeze(S.x(i,j,:)),...
                                squeeze(S.y(i,j,:)),...
                                repmat(I.elevation,size(squeeze(S.x(i,j,:)))),I.ABS(i,j));  % this allows for shading flat afterwards
         %set(OUT.shaft(i,j),'facecolor',I.facecolor_shaft);
         %set(OUT.shaft(i,j),'edgecolor',I.edgecolor_shaft);
      end
   end

   if isfield(I.shaft,'facecolor');set(OUT.shaft,'facecolor',I.shaft.facecolor);end
   if isfield(I.shaft,'edgecolor');set(OUT.shaft,'edgecolor',I.shaft.edgecolor);end
   if isfield(I.shaft,'linestyle');set(OUT.shaft,'linestyle',I.shaft.linestyle);end
   if isfield(I      ,'clipping' );set(OUT.shaft,'clipping' ,I.clipping       );end

   %% Hold state

   set (gca,'nextplot',holdstate);


   %% Output

   if     nargout==1
      if isfield(I,'returninput')
         if I.returninput==1
         varargout = {mergestructs(OUT,I)};
         else
         varargout = {OUT};
         end
      else
         varargout = {OUT};
      end
   end


function result = mergestructs(varargin)
% MERGESTRUCTS
% mergestructs merges 2 or any more number of structs 
% into a new struct.
%
% result = mergestructs(a,b,c,..,) 
% creates a struct 'result' containing all field names
% and values of structs a, b, and c.
%
% - The sizes of all input struct should be equal.
% - By default an error is generated if
%   a field name is present in 2 or more structs. An
%   optioanl argument can be specified to allow merging
%   of structs with similar fieldnames:
%   result = mergestructs('overwrite',a,b,c,..,) 
%   overwrites fields with the same name with the field
%   value of the struct appearing <last> among the
%   input arguments.

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
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

U.overwrite   = 0;
U.firststruct = 1;
if ~isstruct(varargin{1})
    if strcmp(varargin{1},'overwrite')
        U.overwrite   = 1;
        U.firststruct = 2;
    end
end    


% Perform check on struct sizes
% ----------------------------------
for i=U.firststruct:nargin-1
   if ~isstruct(varargin{i})
      error(['Argument ',num2str(i),' is not a struct.']);
   end
   for j=1:length(size(varargin{i}))
      if ~(size(varargin{i},(j))==size(varargin{i+1},(j)))
         error(['Structures ',num2str(i),' and ',num2str(i+1),' do not have the same size']);
      end
   end
end

% Get field names
% ----------------------------------
for i=U.firststruct:nargin
   FLDNAMES(i) = {fieldnames(varargin{i})};
end

% Perform check on double fieldnames
% ----------------------------------

% for all input structs
for i=U.firststruct:nargin-1
   % for all field names
   for k = 1:length(FLDNAMES{i})
      if strcmp(char(FLDNAMES{i}),char(FLDNAMES{i+1}));
         if ~(U.overwrite)
            error(['Same field name is present in structs ',num2str(i),' and ',num2str(i+1)]);
         end
      end
   end
end

% Merge structs
% ----------------------------------

% for all input structs
for i=U.firststruct:nargin

   % for all elements of input structs
   for j=1:numel(varargin{i})

      % for all field names
      for k = 1:length(FLDNAMES{i})
         result(j).(char(FLDNAMES{i}(k))) = varargin{i}(j).(char(FLDNAMES{i}(k)));
      end

   end

end


% Output
% ----------------------------------

result = reshape(result,size(varargin{U.firststruct}));
