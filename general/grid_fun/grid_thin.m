function gridOut = grid_thin(gridIn,step)
%GRID_THIN  performs grid thinning with step sizes given in step.
%
%   grid_thin(gridIn,step) is the same as
%   gridIn(1:step(1):end,1:step(2):end,...)
%
%   Syntax:
%   gridOut = grid_thin(grindIn,step)
%
%   Input:
%   gridIn  = [m(1)xm(2)xm(3)...xm(n) double] n-dimensional input matrix
%   step    = [1xn double/1x1 integer] step(k) is step size in dimension k.
%             if length(step)==1 then step size is step in all dimensions.
%
%   Output:
%   gridOut = [m1/step(1)xm2/stepx...xm(n)/step(n) double] Thinned output
%             matrix
%
%   Example
%   x=ones(4,3); y=grid_thin(x,[2,1]) gives a 2x3 matrix y.
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Arcadis
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl	
%
%       Arcadis Zwolle
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
% Created: $date(dd mmm yyyy)
% Created with Matlab version: $version

% $Id: grid_thin.m 7833 2012-12-14 10:19:46Z ivo.pasmans.x $
% $Date: 2012-12-14 18:19:46 +0800 (Fri, 14 Dec 2012) $
% $Author: ivo.pasmans.x $
% $Revision: 7833 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/grid_thin.m $
% $Keywords: $

%% Preprocessing

%size matrix
sizeIn=size(gridIn); 

%check consistency size
if length(step)~=1 && length(step)~=length(sizeIn)
    error('Number of entries in step must be equal to the number of dimensions of gridIn'); 
end

%match dimension step
if length(step)==1
    step=step*ones(1,length(sizeIn));
end 

%check if steps are integers
if sum(mod(step,1)~=0)>0
    error('step must be a row of integers'); 
end %end if

%create output
gridOut=gridIn;
%% Thinning

for k=1:length(sizeIn)
    
  sizeOut1=size(gridOut); 
  gridOut=gridOut(1:step(k):end,:);
  sizeOut2=size(gridOut);
  gridOut=reshape(gridOut,[sizeOut2(1),sizeOut1(2:end)]); 
  gridOut=shiftdim(gridOut,1); 
  
end %end for k

end %end function 