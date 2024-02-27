function yi = interp1_block(x, y, xi, varargin)
% interp1_block: Block interpolation between the x-values. 
%
%   Block interpolation (similar to Delft3d) between the the given x-values. Extrapolation
%   based on the second most outer values is done in case a value outside the
%   supplied range is requested.
%
%   Syntax:
%   yi = interp1_(x, y, xi, method, extrap)
%
%   Input:
%   x          = array with x-values
%   y          = array with y-values
%   xi         = requested x-value
%   method     = optional. Indicates whether by taking the first value in y after point xi(n) ('upper')
%                or before point xi(n) ('lower'=default)
%   extrap     = value used for extrapolation. If no value is specified
%                y(1) is used for points before x(1) and y(end) for points after x(end).  
%
%   Output:
%   yi           = interpolated y-value
%
%   Example
%   yi = interp1_log(x, y, xi,'lower',NaN)
%
%   See also interp1, interp1_log

%   --------------------------------------------------------------------
%   Copyright (C) 2013 Arcadis
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl
%
%       Arcadis
%       Zwolle
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

% Created: 17 jan 2013
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: interp1_block.m 7918 2013-01-17 09:07:21Z ivo.pasmans.x $
% $Date: 2013-01-17 17:07:21 +0800 (Thu, 17 Jan 2013) $
% $Author: ivo.pasmans.x $
% $Revision: 7918 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/general/interp1_block.m $

%% Preprocessing

%Check input is 1 dimensional
sizex=size(x); sizey=size(y); sizexi=size(xi); 
if sum(sizex==1)==0 || sum(sizey==1)==0
    errror('Input must be a 1-dimensional vector'); 
end

%Convert input to column vectors
if sizex(2)>1
    x=x';
end
if sizey(2)>1
    y=y';
end
if sizexi(2)>1
    xi=xi';
end


%Remove NaN-values and infinity values
inan=isnan(x) | isnan(y) | abs(x)==Inf | abs(y)==Inf; 
if sum(inan)>0
    warning('NaN-values and Inf-values are removed.'); 
end
x=x(~inan); y=y(~inan); 


%Check if Vx is in ascending order
dx=diff(x);
if sum(dx<=0)>0
   error('x-values must be in strictly ascending order.');  
end

%Append values for extrapolation 
if length(varargin)<2
    extrap=[y(1),y(end)]; 
else
    extrap=varargin{2}*[1 1]; 
end



%initialize output
yi=nan(size(xi)); 

%% Extrapolation

yi(xi<x(1))=extrap(1); 
yi(xi>x(end))=extrap(2); 

%% Interpolation

%x-values within range 
inter=xi>=x(1) & xi<=x(end); 
xi=xi(inter); 

%Find index
index_x=[1:length(x)]; 
index_xi=interp1(x,index_x,xi); 
if isempty(varargin) || strcmpi(varargin{1},'lower')
    index_xi=floor(index_xi);
elseif strcmpi(varargin{1},'upper')
    index_xi=ceil(index_xi); 
else
    error('Interpolation method must be either upper or lower.'); 
end %end if varargin
yi(inter)=y(index_xi); 

%% Postprocessing

yi=reshape(yi,sizexi); 

end %end function interp1_block
