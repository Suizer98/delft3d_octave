function varargout = quiver2(varargin)
%QUIVER2   Wrapper for QUIVER.
%
% quiver2(x,y,u,v)  = quiver(x,y,u,v)
%    Plots arrows (u,v) at position (x,y).
%
% quiver2(x,y,u,v,scaling)
%    The the arrows are multiplied with scaling (default 1).
%    Scaling can have 1 or 2 elements.
%    If 2 elements are  passed, the first element
%       is applied to the first dimension,
%       the second one to the second dimension of u and v.
%    If either X and or Y is a scalar, it is replicated to a matrix of
%       the the other full variable. Usefull for a FEATHER plot, e.g.:
%       quiver2(time,0,u,v) for temporal evolution as wind
%       quiver2(0   ,z,u,v) for vertical evolution as atmosphere profile
%    If U and or V are scalers, they are replicated to a matrix of the size of X.
%       Works same as: quiver2(x,y,scaling(1).*u,scaling(1).*v)
%
% quiver2(x,y,u,v,scaling,fieldthinning)
%    The matrix is thinned with factor fieldthinning (default 1).
%    Fieldthinning can have  either 1 or 2 elements.
%    If 2 elements are passed, the first element is applied
%    to the first dimension, the second one to the second
%    dimension of x,y,u and v. Works as:
%    x(1:scaling(1):end,1:scaling(2):end);
%
% quiver2(x,y,u,v,scaling,fieldthinning,zposition)
%    Positions the arrows at vertical position zposition
%    to be sure the arrows are for example not hidden
%    below a surface.
%
% quiver2(x,y,u,v,<...>,linespec)
%    Passes linespec to quiver. See documentation for quiver
%    to see what is allowed. R12 allows only colors like 'k'.
%    (R14 allows more but is not used in quiver2 as it
%    plots erronous arrows.)
%
% scaling,fieldthinning,zposition can be set to [] or nan
%    to allow for defaults and linespec.
%
% quiver2('method',...)
%    Chooses a specific method to plot the arrows. Supported are:
%    - 'arrow2'
%    - 'quiver' (default). Due to bugs in the Matlab R14 quiver,
%       in matlab 13 quiver('v6',...) is used.
%
% See also: quiver, quiver3, feather, arrow2,
% from download central: arrow, arrow3

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: quiver2.m 9030 2013-08-12 08:08:20Z boer_g $
% $Date: 2013-08-12 16:08:20 +0800 (Mon, 12 Aug 2013) $
% $Author: boer_g $
% $Revision: 9030 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/quiver2.m $
% $Keywords: $

%% Defaults

  scaling   = [1 1];
  thinning  = [1 1];
  zpos      = nan;
  OPT.MaxHeadSize = 10; % reported bug: two sets of arrows doesn't work after v6

%% Input

   if isstr(varargin{1})
       quiverfun = varargin{1};
       nextarg   = 2;
   else
       quiverfun = 'quiver';
       nextarg   = 1;
   end
   
   x         = varargin{nextarg+0};
   y         = varargin{nextarg+1};
   u         = varargin{nextarg+2};
   v         = varargin{nextarg+3};
   
   if prod(size(x))==1
       x = repmat(x,size(y));
   end
   if prod(size(y))==1
       y = repmat(y,size(x));
   end
   
   if prod(size(u))==1
       u = repmat(u,size(x));
   end
   if prod(size(v))==1
       v = repmat(v,size(x));
   end

%% args

   linespecargs = [];

   while 1
       
       if nargin>nextarg+3
           if ischar(varargin{nextarg+4})
               linespecargs = nextarg+4:nargin;
               break
           else
               scaling   = varargin{nextarg+4};
           end
       end
       
       if nargin>nextarg+4
           if ischar(varargin{nextarg+5})
               linespecargs = nextarg+5:nargin;
               break
           else
               thinning  = round(varargin{nextarg+5});
           end
       end
       
       if nargin>nextarg+5
           if ischar(varargin{nextarg+6})
               linespecargs = nextarg+6:nargin;
               break
           else
               zpos  = round(varargin{nextarg+6});
           end
       end
       
       if nargin>nextarg+6
           if ischar(varargin{nextarg+7})
               linespecargs = nextarg+7:nargin;
           else
               linespecargs = [];
           end
       end
       
       %       linespecargs = [];
       break
       
   end

%% Set defaults when requested

   if isnan(scaling) | isempty(scaling)
       scaling   = [1 1];
   end
   
   if isnan(thinning) | isempty(thinning)
       thinning  = [1 1];
   end
   
   if     length(scaling)==1
       uscale =   scaling;
       vscale =   scaling;
   elseif length(scaling)==2
       uscale =   scaling(1);
       vscale =   scaling(2);
   end
   
   if     length(thinning)==1
       d1 =       thinning;
       d2 =       thinning;
   elseif length(thinning)==2
       d1 =       thinning(1);
       d2 =       thinning(2);
   end

%% Prepare arrays

   x = squeeze(x);
   y = squeeze(y);
   u = squeeze(u);
   v = squeeze(v);

%% Draw arrows

   if strcmp(lower(quiverfun),'quiver')
       release = version('-release');
           out = quiver(x(1:d1:end,1:d2:end),...
                        y(1:d1:end,1:d2:end),...
                        u(1:d1:end,1:d2:end).*uscale,...
                        v(1:d1:end,1:d2:end).*vscale,0,varargin{linespecargs});
   elseif strcmp(lower(quiverfun),'arrow2')
       out = arrow2(x(1:d1:end,1:d2:end),...
                    y(1:d1:end,1:d2:end),...
                    u(1:d1:end,1:d2:end).*uscale,...
                    v(1:d1:end,1:d2:end).*vscale,1);
   elseif strcmp(lower(quiverfun),'arrow')
       error('arrow not implemented yet')
   end

%% vertical positioning

   if ~isnan(zpos)
       for i=1:length(out)
           set(out(i),'ZData',zpos + zeros(size(get(out(i),'XData'))));
       end
   end

%% Output

   if nargout > 0
       varargout = {out};
   end
   
%% EOF
