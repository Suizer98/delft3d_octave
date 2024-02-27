function [varargout] = bin2(fx,fy,fz,varargin)
%BIN2  Bins high resolution random data to lower resolution curvilinear bins.
%
%   Grids random fine resolution (x,y,z) data to coarse resolution 
%   curvilinear grid.
%
%      cstat = bin2(fx,fy,fz,       ,cx,cy)
%      cstat = bin2(fx,fy,fz,fweight,cx,cy)
%
%   where fx,fy and fz are the fine data set (unstructured sample points)
%   where cx,cy describe the CORNER points of a coarse (curvilinear)
%   grid. The statistical data are returned in the centres of this 
%   curvilinear grid and are thereofore stored in arrays that are 
%   one column and one row smaller than cx and cy.
%
%   cx and cy can also be 1D vectors, in which case a full (curvi-lienar)
%   grid is constructed inside BIN2.
%
%   [cstat,fi] = bin2(fx,fy,fz,cx,cy)
%   also returns the index of every fine sample point into
%   the coarse curvi-linear matrix. See also: IND2SUB, SUB2IND.
%
%   [..] = bin2(fx,fy,fz,cx,cy,<keyword,value>)
%   where implemented <keyword,value> pairs are:
%   * exact:        check that any data point is only binned once, by 
%                   handling data points at bin edges seperately. Data 
%                   points at edges are attributed to the bin with the 
%                   highest indices. (default 1)
%   * reducefines:  before applying inpolygon throw away data 
%                   outside min and max 'parallels' en 'meridians'
%   * no_nan_fines: fine date are considered random points 
%                   so NaN should be removed.  (default 1)
%   * dispprogress: display to command lien after processing every 
%                   row in coarse grid (default 1)
%   * tictoc        show duration (default 0)
%
%   Note that you cannot add ±Inf as the outermost coarse bin edges 
%   (to encompass all fines).
%
%   See also: scatter, HISTC2, GRIDDATA_AVERAGE, GRIDDATA, for use as in hist3([fx(:) fy(:)])

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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: bin2.m 11618 2015-01-09 09:53:00Z gerben.deboer.x $
% $Date: 2015-01-09 17:53:00 +0800 (Fri, 09 Jan 2015) $
% $Author: gerben.deboer.x $
% $Revision: 11618 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/bin2.m $
% $Keywords: $

% Meinte Blaas suggested option for fweight, November 2005, WL | Delft Hydraulics
% 2008 Jan 30: stop when no fines inside coarse grid
% 2008 Jan 30: changed isnan(fi) to isnan(fi(:)) to prevent issues in dimensions
% 2008 Jun 10: allow for 1D vertices
% 2008 Jul 13: return struct with empty fields rather than empty single arguments.

%% Options defaults

   OPTIONS.sortfirst     = 0; % no need
   OPTIONS.tictoc        = 0;
   OPTIONS.stenciltype   = 2; % only 1 implemendted at present, which is not the one used in D3D rgdgrid !!
   OPTIONS.datapercell   = 0;
   OPTIONS.samesize      = 0;
   OPTIONS.reducefines   = 1; % before allpying inpolygon throw away data outside min and max 'parallels' en 'meridians'
   OPTIONS.no_nan_fines  = 1; % fine date are considered random points so NaN should be removed.
   OPTIONS.exact         = 1; % mnake sure data points at edges are not used twice in neighbouring bins
                              % NOTE: exactly at corner points not taken into account yet
                              % NOTE: exactly at edge of last bins is now erronously discarded still
   OPTIONS.dispprogress  = 1;
   
   
   if nargin==0
      varargout = {OPTIONS};
      return
   end

%% Input

   % f = fine grid
   % c = course grid
   
   % x = x-vertices
   % y = y-vertices
   % z = z-vertices or any other data
   
   if ~odd(nargin)
      fweight  = varargin{1};
      cx       = varargin{2};
      cy       = varargin{3};
      iargin   = 4;
   elseif odd(nargin)
      fweight  = [];
      cx       = varargin{1};
      cy       = varargin{2};
      iargin   = 3;
   end
   
%% Make curvi-linear grid of 1D vertices

   if min([size(cx,1) size(cx,2)])==1
   
      [cx,cy] = meshgrid(cx,cy);
      
   end

   
   %% Options user options

   while iargin<=nargin-3,
     if      ischar(varargin{iargin}),
       switch lower(varargin{iargin})
       case 'sortfirst'     ;iargin=iargin+1;OPTIONS.sortfirst    = varargin{iargin};
       case 'tictoc'        ;iargin=iargin+1;OPTIONS.tictoc       = varargin{iargin};
       case 'stenciltype'   ;iargin=iargin+1;OPTIONS.stenciltype  = varargin{iargin};
       case 'datapercell'   ;iargin=iargin+1;OPTIONS.datapercell  = varargin{iargin};
       case 'samesize'      ;iargin=iargin+1;OPTIONS.samesize     = varargin{iargin};
       case 'reducefines'   ;iargin=iargin+1;OPTIONS.reducefines  = varargin{iargin};
       case 'no_nan_fines'  ;iargin=iargin+1;OPTIONS.no_nan_fines = varargin{iargin};
       case 'exact'         ;iargin=iargin+1;OPTIONS.exact        = varargin{iargin};
       case 'dispprogress'  ;iargin=iargin+1;OPTIONS.dispprogress = varargin{iargin};
       otherwise
          error(sprintf('Invalid string argument: %s.',varargin{iargin}));
       end
     end;
     iargin=iargin+1;
   end;   

%% Pre processing

  %if OPTIONS.sortfirst
  %   fines = [fx(:) fy(:) fz(:)];
  %   tic
  %   fines = sortrows(fines,[1 2]);
  %   toc
  %
  %   fx       = fines(:,1);
  %   fy       = fines(:,2);
  %   fz       = fines(:,3);
  %   clear fines
  %end
      
   if OPTIONS.no_nan_fines
      nonanmask = ~isnan(fz);
      fx        = fx     (nonanmask);
      fy        = fy     (nonanmask);
      fz        = fz     (nonanmask);
      
      if ~isempty(fweight)
      fweight   = fweight(nonanmask);
      end
      clear nonanmask
   end
   
   if OPTIONS.reducefines
      cxmin = min(cx(:));
      cxmax = max(cx(:));
      cymin = min(cy(:));
      cymax = max(cy(:));
      
      %% GJdB Jan 5th 2007: the eps offset to a larger outer domain is not sufficient refrain form using >= and <=
      fmask1 = find(fx(:                        ) >=  cxmin-eps);
      fmask2 = find(fx(fmask1(:                )) <=  cxmax+eps);
      fmask3 = find(fy(fmask1(fmask2(:        ))) >=  cymin-eps);
      fmask4 = find(fy(fmask1(fmask2(fmask3(:)))) <=  cymax+eps);
      
      fmask     = fmask1(fmask2(fmask3(fmask4)));
      fx        = fx      (fmask);       
      fy        = fy      (fmask);       
      fz        = fz      (fmask);       

      if ~isempty(fweight)
      fweight   = fweight(fmask);       
      end
      clear fmask fmask1 fmask2 fmask3 fmask4
   end
   
   if OPTIONS.tictoc
      tic
   end

% TO BE IMPLEMENTED
%  - closest point besides
%   - max
%   - min
%   - avg
%  - define region around coarse points to use for averaging
%  add smoothing for points outside

% For each data point from f find out in which gridcell from
% c is resides. Store the position number of that grid cell
% in array fi. Stop if fi empty.
%----------------------------------------------------------------

fi = repmat(nan,size(fx)); % preallocation of array is much faster

if length(fi)==0

   disp('bin2: Not a single fine point inside coarse grid, function skipped.')

   c.sum  = [];
   c.sum2 = [];
   c.n    = [];
   c.avg  = [];
   c.min  = [];
   c.max  = [];
   c.std  = [];

   if nargout==1 | nargout==0
      varargout={c};
   elseif nargout==2
      varargout={c,fi};
   end
   return
end

%% Create an array which contains for each point from
%  the fine aray the indices of the course grid point
%  in which it resides, more precisly the 1D index of
%  the 1D array f(:) (which is exactly to f(:,:))
%  Each fine point resides in exactly only one,
%  and not more or not less than one, coarse grid cell.
%----------------------------------------------------------------

sz1 = size(cx,1);
sz2 = size(cx,2);

   c.sum  = repmat(0   ,size(cx));
   c.sum2 = repmat(0   ,size(cx));
   c.n    = repmat(0   ,size(cx));
   c.avg  = repmat(0   ,size(cx));
   c.min  = repmat(+Inf,size(cx));
   c.max  = repmat(-Inf,size(cx));
   c.std  = repmat(0   ,size(cx));
  %c.med = repmat(0   ,size(cx));

% Define function to use for inpolygon procedure:
% Matlab inpolygon function is much faster but assigns 
% points on the border of a polygon to the inside.
% Dano's ipon does handle border, but not correctly.

% loop over all grid cells of coarse grid and mark
% all fine ones which are inside of it with the number of the 
% coarse grid cell. A fine piont can be in one coarse cell only!
% with the mask 'in' the relevant points in fine are aded to the 
% coarse statistics.

%% Loop
%for j=1:prod(size(cx))-rowlength
%for j=1:prod(size(cx(1:end-1,1:end-1)))
for i=1:sz1-1
for j=1:sz2-1

ij = (j-1).*sz1 + i;
%disp(['i j ij :  ',num2str([i j ij])])

% do only loop over coarse cells which are inside the region enclosed by
% min and max x-y values of the fine data. This speeds up considerably 
% when the fine data cover only a small area of the coarse grid.

%[fregion.x(1) cx(j) fregion.x(2)]
%[fregion.y(1) cy(j) fregion.y(2)]

%(cx(j) >= fregion.x(1))
%(cx(j) <= fregion.x(2))
%(cy(j) >= fregion.y(1))
%(cy(j) <= fregion.y(2))
%pause
%   if (cx(j) >= fregion.x(1)) & ...
%      (cx(j) <= fregion.x(2)) & ...
%      (cy(j) >= fregion.y(1)) & ...
%      (cy(j) <= fregion.y(2))
 
      % last elements of each row represent only the endface of a polygon,
      % and not the start of the next polygon. Instead display that a row has 
      % been processed.
      
      %if ~(mod(j,size(cx,1))==0)
      
         switch OPTIONS.stenciltype
         
         case 2
         
               %       ij + 1 + sz1
               % +----/ \----+ The double line should not be taken into account when a data point is on an edge
               % |  / / \ \  | except for the last bin        
               % |/ /     \ \|                                
               % |/ij +     \|ij + 1                          
               % |\sz1      /|                                
               % | \      /  |        j          i            
               % |  \   /    |         \        /             
               % |   \/ ij   |           \    /               
               % +-----------+             \/                 
               %

            Xstencil        = [cx(ij) cx(ij+1) cx(ij + 1 + sz1) cx(ij + sz1) cx(ij)];
            Ystencil        = [cy(ij) cy(ij+1) cy(ij + 1 + sz1) cy(ij + sz1) cy(ij)];
            
	    % ij = (j-1).*sz1 + i;
            
            if     ~(i==sz1-1) & ~(j==sz2-1)
            %disp('ij')
            Xstencilexclude = [cx(ij+1) cx(ij + 1 + sz1) cx(ij + sz1) cx(ij + 1 + sz1) cx(ij+1)];
            Ystencilexclude = [cy(ij+1) cy(ij + 1 + sz1) cy(ij + sz1) cy(ij + 1 + sz1) cy(ij+1)];
            elseif ~(j==sz2-1)
            %disp('i')
            Xstencilexclude = [cx(ij+1) cx(ij + 1 + sz1) cx(ij+1)];
            Ystencilexclude = [cy(ij+1) cy(ij + 1 + sz1) cy(ij+1)];
            elseif ~(i==sz1-1)
            %disp('j')
            Xstencilexclude = [cx(ij + 1 + sz1) cx(ij + sz1) cx(ij + 1 + sz1)];
            Ystencilexclude = [cy(ij + 1 + sz1) cy(ij + sz1) cy(ij + 1 + sz1)];
            else
            %disp('j')
            Xstencilexclude = [];
            Ystencilexclude = [];
            end

         otherwise
         end

         if ~isnan(prod(Xstencil.*Ystencil));
         
            %% Construct a subset to search for points in stencil:
            %  part of samples where previous search was positive
            %            
            %  I. Pre select all points (a and b) that are within the orthogonal
            %  rectangle enclosed by the minimum and maximum X and Y coordinates
            %----------------------------------
            
               % +-----------+ 
               % |aaa /b\aaaa|                                                         
               % |aa/bbbbb\aa|                                                        
               % |/bbbbbbbbb\|                                                     
               % |\bbbbbbbb /|                                                       
               % |a\bbbbbb/aa|                                                            
               % |aa\bbb/aaaa|                                                          
               % |aaa\/aaaaaa|                                                        
               % +-----------+                                                      
               
               %% GJdB Jan 5th 2007: the eps offset to a larger outer domain is 
               %  not sufficient refrain from using >= and <=
               if OPTIONS.exact
               % only consider points that do not have an index yet
               indpre1   = find(fx(:                           ) >=  min(Xstencil)-eps  & ...%size(in1)
                           isnan(fi(:))); 
               else
               % points at adged are counted twice !
               indpre1   = find(fx(:                           ) >=  min(Xstencil)-eps);     %size(in1)
               end
               indpre2   = find(fx(indpre1(:                  )) <=  max(Xstencil)+eps);     %size(in2)
               indpre3   = find(fy(indpre1(indpre2(:         ))) >=  min(Ystencil)-eps);     %size(in3)
               indpre4   = find(fy(indpre1(indpre2(indpre3(:)))) <=  max(Ystencil)+eps);     %size(in4)
	       
               indpre    = 1:length(fx(:));       
               indpre    = indpre(indpre1(indpre2(indpre3(indpre4))));       
               
               % 'indpre' contains only ones when the coarse grid polygon 
               % covers at least a part of the fine grid ????

            %% II. Now select from the points in the orthogonal
            %  rectangle only those (namely b, not a) that are within the 
            %  curvilinear quadrangle. Using inpolygon for all fine points
            %  is way to slow.
            %----------------------------------

               [ininpre] = inpolygon(fx(indpre),...
                                     fy(indpre),Xstencil,...
                                                Ystencil);
               %% To prevent elements on edges to be counted twice
               %  we have to remove then
               %--------------------------------------------------
               %-%if OPTIONS.exact==1
               %-%   if ~isempty(Xstencilexclude)
               %-%   [exclude] = inpolygon(fx(indpre),...
               %-%                         fy(indpre),Xstencilexclude,...
               %-%                                    Ystencilexclude);
               %-%   ininpre(exclude) = false;
               %-%   end
               %-%end
               
               in        = indpre(ininpre);
            
               fi(in) = ij;
            
            %% Add points found to statistics
            %----------------------------------
            
               if sum(   in(:)) >0
               % perhaps better is to get rid of all
               % nans at start of fucntion before 
               % gridding
               
                  if ~isempty(fweight)
                  c.sum (ij) = c.sum (ij) + nansum(       fz(in(:))   .*fweight(in(:)));
                  c.sum2(ij) = c.sum2(ij) + nansum(       fz(in(:)).^2.*fweight(in(:)));
                  c.n   (ij) = c.n   (ij) + length(~isnan(fz(in(:)))  .*fweight(in(:)));
                  else
                  c.sum (ij) = c.sum (ij) + nansum(       fz(in(:))   );
                  c.sum2(ij) = c.sum2(ij) + nansum(       fz(in(:)).^2);
                  c.n   (ij) = c.n   (ij) + length(~isnan(fz(in(:)))  );
                  end
                  
	          % NOTE nanmin(nan) = empty therefore difficult contruction
	          
                  nmin = nanmin(fz(in(:)));
                  nmax = nanmax(fz(in(:)));
                  if ~isempty(nmin)
                  c.min (ij) = nanmin([c.min(ij);nmin]);
                  end
                  if ~isempty(nmax)
                  c.max (ij) = nanmax([c.max(ij);nmax]);
                  end
               end
        end
      
      %else
      
      if j==(sz2-1)
      if OPTIONS.dispprogress
      disp(['    Processed row ',num2str(i),' of ',num2str(sz1-1)]); 
      end
      end
      
      %end
      
%   end
   
end
end

   c.min(isinf(c.min)) = nan;
   c.max(isinf(c.max)) = nan;
   
%% Calculate statistics of fine data in coarse grid cells
%----------------------------------------------------------------

   c.avg(c.n >0) = c.sum(c.n >0)./c.n(c.n >0); % Do not divide by zero if no points are found
   c.avg(c.n==0) = nan; % Do not divide by zero if no points are found
   c.sum(c.n==0) = nan; % Do not divide by zero if no points are found
   %c.std(c.n>0 ) = sqrt((c.sum2(c.n>0) - 2.*c.avg(c.n>0).*c.sum(c.n>0) + c.n(c.n>0).*c.avg(c.n>0).^2)./c.n(c.n>0));
   c.std(c.n>0 ) = sums2std(c.n(c.n>0),c.sum(c.n>0),c.sum2(c.n>0));
   c.std(c.n==0) = nan;

%% Create array with size of c in 1st and 2nd dimension,
% and with >>>variable length<< in 3rd dimension. Store each
% data point from f in the right position of c.dat. Calculate c.n
% again to be able to store each data point from f in the correct,
% still empty, position in c.dat. In this way also all nans, Inf 
% from f are present in c.dat.
% ---------------------------------------------------------------

if OPTIONS.datapercell

   c.dat  = repmat({1},size(c.n));
   for i=1:prod(size(c.n))
      c.dat{i} = 1:c.n(i);
   end   
   
   %c.n   = repmat(0   ,size(cx));
   for i=1:prod(size(fx))
      if fi(i) > 0
         %c.n  (fi(i))               = c.n  (fi(i)) + 1;
         c.dat{fi(i)}(c.n  (fi(i))) = fz(i);
      end
   end

   c.dat = c.dat(1:end-1,1:end-1,:);

end

%% Crop arrays to correct size (I.e. the coarse grid cell centers.)
% cx contains the grid centers
% while the data should be atributed to 
% the cell centers
%----------------------------------------------------------------

if ~OPTIONS.samesize

   c.sum  = c.sum (1:end-1,1:end-1);
   c.sum2 = c.sum2(1:end-1,1:end-1);
   c.n    = c.n   (1:end-1,1:end-1);
   c.avg  = c.avg (1:end-1,1:end-1);
   c.min  = c.min (1:end-1,1:end-1);
   c.max  = c.max (1:end-1,1:end-1);
   c.std  = c.std (1:end-1,1:end-1);

end   

%% Output
%----------------------------------------------------------------
   if nargout==1 | nargout==0
      varargout={c};
   elseif nargout==2
      varargout={c,fi};
   end
if OPTIONS.tictoc
   toc
end   

%%
%  __                                               
%  |  --__                                                          
%  |      --__                                                      
%   |         --__                                                  
%   |             --__                                                                      
%    |                -|__                                                  
%    |                 |  --__                                              
%     |\              |       --__                                        
%     | \             |           --__                                    
%      |  \           |               --__                                
%      |    \        |                    --__                                                  
%       |     \      |                    /   --__                                              
%       |       \    |                   /        --__                                          
%        |        \ |                   /             --__                                      
%        |          |                  /                  --__                                  
%         |         | \               /                       --                                
%         |        |    \            /                                    
%          \       |      \         /                                     
%           \      |        \      /                                        
%            \    |           \   /                                         
%             \   |             \/                                          
%              \  |             / \                                                     
%               \|             /    \                                                  
%                |            /       \                                                
%                 \          /          \                                              
%                  \        /             \                                            
%                   \      /                \                                          
%                    \    /                                                 
%                     \  /                                                  
%                      \/                                                            
%                                                                           
%                                                                                         
%                                                                 
