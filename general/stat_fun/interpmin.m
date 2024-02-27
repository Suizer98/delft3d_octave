function varargout = interpmin(y,varargin)
%INTERPMIN Finds the minimum of the signal of which sample values are given in y. 
%
%For a vector containing the sample values of a signal interpmax finds the minimum
%of the signal by assuming that in the vicinity of the minimum the signal can be approximated
%by a second order polynomial. interpmin also calculates the index/time on which this minimum
%is obtained. For a matrix interpin does the same for one of the dimension of the matrix. 
%
%Syntax:
%  [min imin tmin]=interpmin(y,<dim>,<keyword>,<value>)
%
%Input:
%  y    =   [n1xn2x..n_j double] matrix containing value of signal(s). 
%  dim 	=	[integer>0] the dimension along which interpmin works (default=1). 
% 
%Output:
%  min  =   [n1xn_i..x1x..n_j double] the minimum value(s) of the signal(s). Dimension 
%			dim is a singleton dimension. 
%  imin =   [n1xn_i..x1x..n_j double] the moment the minimum of the signal(s) is obtained 
%			given as fractional index number.
%  tmin =   [n1xn_i..x1x..n_j double] the moment the minimum of the signal(s) is obtained 
%			given as time. tmax is only in the output if keyword time is specified. 
%
%Optional keywords:
%  time =   [n_dimx1 double/n1xn2..n_j double] times on which the samples values y are taken. 
%			If this value is specified tmax is also given. 
%
%Example 1:
%y=[1 0 1 2 3 2.5 1.5];
%ymin=interpmin(y); 
%
%Example 2:
%y=[0 -1 0; 0 -1 -1];
%[ymin imin tmin]=interpmin(y,2,'time',[0 10 20]); 
%
%
% See also max, nanmax, min, nanmin, interpmax

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Arcadis
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
%
% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 15 Apr 2013
% Created with Matlab version: 7.5.0 (R2007b)

% $Id: interpmin.m 8457 2013-04-16 07:05:40Z ivo.pasmans.x $
% $Date: 2013-04-16 15:05:40 +0800 (Tue, 16 Apr 2013) $
% $Author: ivo.pasmans.x $
% $Revision: 8457 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/stat_fun/interpmin.m $
% $Keywords: $


%find dimension along which interpmax works
if ~isempty(varargin) & ~ischar(varargin{1})
    dim=varargin{1};
    dimset=true; 
    if length(varargin)>1
        optarg=varargin(2:end); 
    else
        optarg={}; 
    end
else
    dim=1;
    dimset=false; 
    optarg=varargin; 
end
    
%check dimension y
if size(y,1)==1 & ~dimset
    dim=2; 
end

%settings
OPT.time=[];
OPT.order=2; 
[OPT OPTset]=setproperty(OPT,optarg);

%Calculate minimum
if OPTset.time
	[out{1} out{2} out{3}]=interpmax(-y,dim,optarg{:}); 
else
	[out{1} out{2}]=interpmax(-y,dim,optarg{:}); 
end
out{1}=-out{1}; 

%Pass output
varargout=out(1:min( max(nargout,1),length(out)));  


end %end function interpmax



