function s = scurve(x,varargin)
%SCURVE   curve with asymmetrical tanh-shape
%
% scurve(x,yinf,ymininf,x0,L)
%
% Gives the following s-curve 
%
% y = (ymininf + yinf*exp((x-dx)./L))./...
%     (1       +    1*exp((x-dx)./L));
%
% with default values (as in figure)
%
% yinf    = +1;ymininf = -1;
% x0      =  0;L       =  1;
% 
% This gives an scurve centered at (0,0)
% with y = yinf    for x/xo towards +Inf  
% with y = ymininf for x/xo towards -Inf  
%
%            y       
% yinf       ^           -------
%            |      x0 /
%        ----+-------/---------> x
%            |     /  
% ymininf --------   
%            |    <-----> ~ 2 L
%            |
%
%See also: ATANH

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

   yinf    =  1;
   ymininf = -1;
   x0      =  0;
   L       =  1;
   
   if nargin>1
      yinf     = varargin{1};
   end
   if nargin>2
      ymininf = varargin{2};
   end
   if nargin>3
      x0      = varargin{3};
   end
   if nargin>4
      L       = varargin{4};
   end
   
   s = (ymininf + yinf.*exp((x-x0)./L))./...
       (1       +       exp((x-x0)./L));

%% EOF