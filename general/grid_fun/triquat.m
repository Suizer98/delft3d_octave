function varargout = TRIQUAT(x,y,varargin)
%TRIQUAT   triangulate curvi-linear mesh
%
%    S = triquat(x,y) 
%    [tri, quat] = triquat(x,y) 
%    [tri, quattri_per_quat, quat_per_tri] = triquat(x,y) 
%
% triangulates and quadrangulates a curvi-linear mesh 
% into triangles and quadrangles. It also gives the mappers
% array of the traingles to the quadrangles and v.v.
% This is faster than using DELAUNAY and QUAT and 
% finding out the mapping afterwards. In TRIQUAT
% the triangulation and quadrangulation are performed
% in a structured way so the mapping is made without 
% extra comparisons.
% 
% It does the same as the following 3 actions:
%
%    tri  = delaunay(x,y)
%    quat = quat(x,y)
%    [tri_per_quat,quat_per_tri] = tri2quat(tri,quat)
%
% Do note that ALL TRIANGLES ARE ORIENTED IN THE SAME WAY,
% whereas DELAUNAY has a random distribution of orientations
% for a perfect orthogonal grid.
%
% Behaviour is similar to DELAUNAY(x,y) that
% can be used to triangulate a mesh into triangles.
% 
% It returns an array of indices into the (x,y) matrices
% where the first dimension walks the quadrangles and 
% the second dimension are the 4 1D indices into the 
% (x,y) matrices. Like the results of DELAUNAY where
% the first dimension walks the triangles and the second 
% dimension contains the 3 1D indices into the (x,y) matrices.
%
% The output is a struct with fields
% - tri
% - quat
% - tri_per_quad
% - quad_per_tri
%
% [...] = triquat(x,y,<keyword,value>) 
%
% where the following <keyword,value> pairs have been implemented.
% * active: if 1, only cells with 4 non-NaN corners are considered. Default 0:
%           also returns nan values. Meant for triangulating plaid curvi-linear 
%           grids. When using DELAUNAY with not-NaN vertices, holes are filled, 
%           whereas TRIQUAT with active=0 leaves holes open.
%
% Example:
%                                                          
%     Array of corner points measures 3 x 2.               
%     Array of center points measures 2 x 1.               
%                                                          
%     o-------o-------o.....> 1st matlab dimension         
%     |1      |2      |3                                   
%     |   A   |   B   |                                    
%     |       |       |                                    
%     o-------o-------o                                    
%     .4       5       6 indices when treating 2D array as 1D array
%     .                  walking 1st dimension first.
%     .                                                    
%     v                                                    
%                                                          
%     2nd matlab dimension                                 
%                                                          
%     Quadrangle A is spanned by corner indices [1 2 4 5]  
%     Quadrangle B is spanned by corner indices [2 3 5 6]  
%                                                          
%     Note that the number of quadrangles is equal         
%     to the number of cell centers.                       
%                
% Example: D = triquat([1 2 3;4 5 6;7 8 9],[1 4 7;2 5 8;3 6 9])
% 
% see also: QUAT, TRI2QUAT, DELAUNAY, GRADIENT2

%% Copyright
%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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

% TO DO: take triangle which has shortest diagonal, so it behaves DELAUNAYish

%% set properties

   OPT.active = 1; % only return triangles of active quadrangles

   [OPT, Set, Default] = setproperty(OPT, varargin{:});

szcor1 = size(x,1);
szcor2 = size(x,2);

szcen1 = szcor1-1;
szcen2 = szcor2-1;

nquat  = szcen1*szcen2;
ntri   = nquat*2;

quat         = repmat(0,[nquat   4]); % 4 corners    per quadrangle
tri          = repmat(0,[ntri    3]); % 3 corners    per triangle
tri_per_quat = repmat(0,[nquat   2]); % 2 triangles  per quadrangle
quat_per_tri = repmat(0,[ntri    1]); % 1 quadrangle per triangle

mncor    = -1;
mncen    = 0;
mnactive = 0;
itri     = [];

%% first walk alomng 1st dimension, 
%  while keeping the 2nd dimension constant

for ncen=1:szcen2

   for mcen=1:szcen1
   
      mncen = mncen + 1;
      mncor = mncor + 1 + (mcen==1); % at the transition from end of row to begining of row skip 1 corner cell.
      
%% Define a polygon for quadrangle
%  Note: do not by incident define a Z or N shape
%  always define a C or V or U shape.
      
      quat1         = [mncor              ,...
                       mncor + 1          ,...
                       mncor + szcor1 + 1 ,...
                       mncor + szcor1    ];
      realcoordinates = ~any(isnan(x(quat1)));
      
      if ~OPT.active
      
         %% Define mapping indices triangles <> quadrangle

         itri                     = [2*mncen-1 2*mncen];
         tri_per_quat(mncen,:)    = itri;  % 2 traingles per quadrangle
         quat_per_tri(itri)       = mncen; % 1 quadrangle for both traingles
         
         %% Define 2 non-overlapping polygons for 2 triangles
         %  - For perfect orthogonal grid the trainagle definition should 
         %    be more or less random
         %  - For curvilinear grids the trainagle definition should 
         %    be such that the diagonal is short as possible

         
         tri(itri(1),:)      = [mncor             , ...
                                mncor + 1         , ...
                                mncor + szcor1    ];
         tri(itri(2),:)      = [mncor + 1         , ...
                                mncor + szcor1 + 1, ...
                                mncor + szcor1    ];

         quat(mncen,:)       = [mncor              ,...
                                mncor + 1          ,...
                                mncor + szcor1 + 1 ,...
                                mncor + szcor1    ];
         
      else
      
         if realcoordinates

         mnactive = mnactive + 1;

         itri                     = [2*mnactive-1 2*mnactive];
         tri_per_quat(mnactive,:) = itri;  % 2 traingles per quadrangle
         quat_per_tri(itri)       = mnactive; % 1 quadrangle for both traingles
         
         %% Define 2 non-overlapping polygons for 2 triangles
         %  - For perfect orthogonal grid the trainagle definition should 
         %    be more or less random
         %  - For curvilinear grids the trainagle definition should 
         %    be such that the diagonal is short as possible
         
         tri(itri(1),:)      = [mncor             , ...
                                mncor + 1         , ...
                                mncor + szcor1    ];
         tri(itri(2),:)      = [mncor + 1         , ...
                                mncor + szcor1 + 1, ...
                                mncor + szcor1    ];

         quat(mnactive,:)    = [mncor              ,...
                                mncor + 1          ,...
                                mncor + szcor1 + 1 ,...
                                mncor + szcor1    ];

         else
         
            % skip inactive quadrangle
         
         end

      end
      
   end

end

if ~isempty(itri)
   tri          = tri (1:itri(2) ,:); % remove triangles   not needed for inactive cells
   quat         = quat(1:mnactive,:); % remove quadrangles not needed for inactive cells
else
   tri          = [];
   quat         = [];
   tri_per_quat = [];
   quat_per_tri = []
end

if nargout < 2
   
   OUT.tri          = tri;
   OUT.quat         = quat;
   OUT.tri_per_quat = tri_per_quat;
   OUT.quat_per_tri = quat_per_tri;
   varargout = {OUT};

elseif nargout == 2
   
   varargout = {tri         ,...
                quat};

elseif nargout ==4

   varargout = {tri         ,...
                quat        ,...
                tri_per_quat,...
                quat_per_tri};

end

%% function polygon_around_square(mncor, szcor1,geometry)
%  
%  
%  if strcmp(geometry,'open')
%  
%  pol = [mncor             , ...
%         mncor + 1         , ...
%         mncor + szcor1 + 1, ...
%         mncor + szcor1    ];
%  
%  elseif strcmp(geometry,'open')
%  
%  pol = [mncor             , ...
%         mncor + 1         , ...
%         mncor + szcor1 + 1, ...
%         mncor + szcor1    , ...
%         mncor             ];
%  
%  end       

%% EOF