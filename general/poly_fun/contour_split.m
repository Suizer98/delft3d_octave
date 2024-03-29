function varargout = contour_split(c,varargin);
%poly_split  split contour object into it NaN-less segments
%
%   struc          = contour_split(c)
%   [x,y]          = contour_split(c)
%   [x,y,levels]   = contour_split(c)
%   [x,y,levels,n] = contour_split(c)
%
% splits c generated by c = contour(x,y,z) which looks like
%
%  c = [level1 x1 x2 x3 ... level2 x2 x2 x3 ...;
%       pairs1 y1 y2 y3 ... pairs2 y2 y2 y3 ...]
%
% contour() sometimes leaves NaNs inside single polygons,
% these are split into seperate (extra) segments, use
% [..] = contour_split(c,'nansplit',0) to prevent this.
%
%See also: contour, contour2poly, poly_split, poly_join, poly_fun
%          http://www.mathworks.nl/help/matlab/creating_plots/the-contouring-algorithm.html

% TODO make nan_join

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares, Gerben.deBoer@deltares.nl
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: contour_split.m 17793 2022-02-25 12:52:07Z l.w.m.roest.x $
% $Date: 2022-02-25 20:52:07 +0800 (Fri, 25 Feb 2022) $
% $Author: l.w.m.roest.x $
% $Revision: 17793 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/poly_fun/contour_split.m $
% $Keywords: $

  
OPT.nansplit = 1;

OPT = setproperty(OPT,varargin);

%% split polygons
                
      eof = size(c,2);

      nc          = 1;
      S.index(nc) = 1;

      S.levels    (nc) = c(1,S.index(nc));
      S.n         (nc) = c(2,S.index(nc));
      i0 = S.index(nc)  + 1;
      i1 = i0 + S.n(nc) - 1; %S.index(nc) + S.n(nc) + 1
      S.x{nc} = c(1,i0:i1);
      S.y{nc} = c(2,i0:i1);
      [nc S.index(nc) i0 i1 S.n(nc)];

      while i1 < eof
          
      nc          = nc + 1;
      S.index(nc) = i1 + 1;
         
      S.levels    (nc) = c(1,S.index(nc));
      S.n         (nc) = c(2,S.index(nc));
      i0 = S.index(nc)  + 1;
      i1 = i0 + S.n(nc) -1; %S.index(nc) + S.n(nc) + 1
      [nc S.index(nc) i0 i1 S.n(nc)];
      S.x{nc} = c(1,i0:i1);
      S.y{nc} = c(2,i0:i1);
      
      end
      
%% split contours with nan inside

      if OPT.nansplit
      for nc=1:length(S.n)
          nanmask = isnan(S.x{nc}) | isnan(S.y{nc});
          S.nan(nc) = sum(nanmask);
          if any(nanmask)
            ind = find(nanmask);
            [x,y] = poly_split(S.x{nc},S.y{nc});
            S.n(nc) = length(x{1});
            S.x{nc} = x{1};
            S.y{nc} = y{1};
            dindex  = length(x{1}) + 1; % points + NaN
            for jj=2:length(x)
                if length(x{jj}) > 0 % skip consecutive nans
                    S.index(end+1) = dindex; % duplicate
                    S.level(end+1) = S.level(nc); % duplicate
                    S.n    (end+1) = length(x{jj});
                    S.x    {end+1} = x{jj};
                    S.y    {end+1} = y{jj};                
                end
                dindex  = length(x{jj}) + 1; % points + NaN
            end
          end
%           i0 = [1 find(nan)];
%           i1 = [find(nan) end);
      end
      end

      if     nargout==1;varargout = {S};
      elseif nargout==2;varargout = {S.x,S.y};
      elseif nargout==3;varargout = {S.x,S.y,S.levels};
      elseif nargout==4;varargout = {S.x,S.y,S.levels,S.n};
      end
      
