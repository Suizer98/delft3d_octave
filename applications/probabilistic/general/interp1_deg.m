function [yi_norm yi_deg]=interp1_deg(x,y_norm,y_deg,xi,varargin)
%INTERP1_DEG Interpolates vectors given as norm and angle. 
%
%   interp1_deg can be used to interpolate a time series
%   of e.g. wind series of which the vectors are given as a norm (wind speed)
%   and direction in degrees (wind direction). 
%
%   Syntax:
%   [yi_norm yi_deg]=interp1_angle(x,y_norm,y_deg,xi)
%
%   Input:
%	x		= [mx1 double] x-coordinates on which y_norm and y_deg are defined. 
%	y_norm	= [mxn double/1x1 double] norm of vectors. 
%   y_deg	= [mxn double/1x1 double] angle in degrees. 
%   xi 		= [kx1 double] x-coordinates on which yi_norm and yi_deg are defined
%
%   Output:
%	yi_norm	= [kxn double] norm of interpolated vectors.
%   yi_deg  = [kxn double] angle of interpolated vectors in deg. 
%
%   Example
%   [yi_norm yi_angle]=interp1_angle([0,1,2]',1,[0 90 180]',2.5);
%
%   See also interp1

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 ARCADIS
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl
%
%		Arcadis Zwolle, The Netherlands
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 18 Jun 2013
% Created with Matlab version: 7.5.0 (2007b)

% $Id: interp1_deg.m 8830 2013-06-18 15:31:39Z ivo.pasmans.x $
% $Date: 2013-06-18 23:31:39 +0800 (Tue, 18 Jun 2013) $
% $Author: ivo.pasmans.x $
% $Revision: 8830 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/general/interp1_deg.m $
% $Keywords: $

%% PREPROCESSING

%
if length(varargin)>=1
	OPT.method=varargin{1};
else
	OPT.method='linear';
end
if length(varargin)>=2
	OPT.extraval=varargin{2};
else
	OPT.extraval=NaN; 
end

%reshaping
if sum(size(x)>1)>1
	error('Input x must be a row or column vector.'); 
else
	x=reshape(x,[],1); 
end
if sum(size(xi)>1)>1
	error('Input xi must be a row or column vector.'); 
else
	xi=reshape(xi,[],1); 
end
if sum(size(y_norm)==1)==1
	y_norm=reshape(y_norm,[],1); 
end
if sum(size(y_deg)==1)==1
	y_deg=reshape(y_deg,[],1); 
end
if prod(size(y_norm))==1
	y_norm=y_norm*ones(size(y_deg)); 
end
if prod(size(y_deg))==1
	y_deg=y_deg*ones(size(y_norm)); 
end

%check size
if length(x)~=size(y_norm,1)
	error('x and y_norm must have the same number of rows.'); 
end
if length(x)~=size(y_deg,1)
	error('x and y_deg must have the same number of rows.'); 
end

%% CALCULATION

%convert degrees to rad
y_deg=deg2rad(y_deg); 

%calculate x and y-coordinates
vector_x=y_norm.*sin(y_deg); 
vector_y=y_norm.*cos(y_deg); 

%interpolate
vector_x=interp1(x,vector_x,xi,OPT.method,OPT.extraval); 
vector_y=interp1(x,vector_y,xi,OPT.method,OPT.extraval); 

%convert back
yi_norm=hypot(vector_x,vector_y); 
yi_deg=atan2(vector_x,vector_y);
yi_deg=mod( rad2deg(yi_deg),360 ); 


