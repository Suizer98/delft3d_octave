function varargout = quiverarrow(x,y,u,v,scaling,varargin)
%QUIVERARROW   Wrapper around ARROW to allow for syntax like QUIVER. 
%
%    <handles> = quiverarrow(x,y,u,v,scaling,...)
%
% QUIVERARROW is an interface to ARROW from the matlab file exchange
% <http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=1430>
% to make it behave like Matlab's QUIVER.
%
% The usage is the same as ARROW, except for the arrow definition:
%
% The x,y and u,v pairs need to be specified for  making it similar 
% in use to quiver3. Either the set (x,u) or the set (y,v) can be 
% a single elements, while the other set are two array.
%
% The u and v velocities are multiplied with scaling before 
% they are plotted, there is no automatic scaling like in 
% quiver. Scaling can either have 1 or 2 elements.
% 
% An extra argument 'distort' can be supplied
% so that (i) the arrows have the right angle/direction
% on screen/paper rather than in data space. and (ii)
% the arrow head is not deformed. In this
% case an additional scaling vector equal to the
% current axes' dataaspectratio is applied. So make
% sure the axis' settings are fixed before calling
% quiverarrow.
%
%    quiverarrow(x,y,u,v,scaling,'distort',...)
%
% For description of the options see the arrow3 help file.
%
% See also: quiver, quiver3, feather, arrow2, (downloadcentral): arrow, arrow3

%% Copyright notice:
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
% $Id: quiverarrow.m 6841 2012-07-10 10:23:54Z boer_g $
% $Date: 2012-07-10 18:23:54 +0800 (Tue, 10 Jul 2012) $
% $Author: boer_g $
% $Revision: 6841 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/quiverarrow.m $

   %% make arrays for when one position is
   %  only given with a single number for
   %  all arrows
   % ------------------------------
   if length(x)==1 & ...
      length(u)==1 & ...
      length(y)~=1 & ...
      length(v)~=1
      x = repmat(x,size(y));
      u = repmat(u,size(y));
   end

   if length(x)~=1 & ...
      length(u)~=1 & ...
      length(y)==1 & ...
      length(v)==1
      y = repmat(y,size(x));
      v = repmat(v,size(x));
   end

   %% Scaling
   if length(scaling)==1
      scaling = [scaling scaling];
   elseif ~(length(scaling)==2)
      error('syntax: quiverarrow(x,y,u,v,scaling) where scaling should either have 1 or 2 elements')
   end
   
   %% Optional distortion
   startvararg2pass = 1;
   if nargin > 5
   if isstr(varargin{1})
      if strcmp(lower(varargin{1}),'distort')
         dataaspectratio = get(gca,'dataaspectratio');
         dataaspectratio = dataaspectratio(1:2);
         scaling         = scaling.*dataaspectratio./rms(dataaspectratio);
         startvararg2pass = 2;
      end
   end
   end

   %% Call arrow
   z = 0;
   z = zeros(size(x)) + z;
   w = zeros(size(u));
   
   xy0 =                    [x(:)...
                             y(:)...
                             z(:)];
   
   xy1 =  xy0 + [scaling(1).*u(:)...
                 scaling(2).*v(:)...
                             w(:)];
                             
   out = arrow(xy0,xy1,varargin{startvararg2pass:end});
   
   if nargout>0
      varargout = {out};
   end

%% ------------------------------------------

   function y = rms(x)
   %RMS	Root mean square.
   %	For vectors, RMS(x) returns the root mean square.
   %	For matrices, RMS(X) is a row vector containing the
   %	root mean square of each column.
   %

   y = sqrt(sum(x.^2)/length(x));

%% ------------------------------------------

%% EOF

