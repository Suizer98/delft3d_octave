function varargout = interpmax(y,varargin)
%INTERPMAX Finds the maximum of the signal of which sample values are given in y. 
%
%For a vector containing the sample values of a signal interpmax finds the maximum
%of the signal by assuming that in the vicinity of the maximum the signal can be approximated
%by a second order polynomial. interpmax also calculates the index/time on which this maximum
%is obtained. For a matrix interpmax does the same for one of the dimension of the matrix. 
%
%Syntax:
%  [max imax tmax]=interpmax(y,<dim>,<keyword>,<value>)
%
%Input:
%  y    =   [n1xn2x..n_j double] matrix containing value of signal(s). 
%  dim 	=	[integer>0] the dimension along which interpmax works (default=1). 
% 
%Output:
%  max  =   [n1xn_i..x1x..n_j double] the maximum value(s) of the signal(s). Dimension 
%			dim is a singleton dimension. 
%  imax =   [n1xn_i..x1x..n_j double] the moment the maximum of the signal(s) is obtained 
%			given as fractional index number.
%  tmax =   [n1xn_i..x1x..n_j double] the moment the maximum of the signal(s) is obtained 
%			given as time. tmax is only in the output if keyword time is specified. 
%
%Optional keywords:
%  time =   [n_dimx1 double/n1xn2..n_j double] times on which the samples values y are taken. 
%			If this value is specified tmax is also given. 
%
%Example 1:
%y=[0 1 2 3 2.5 1.5];
%ymax=interpmax(y); 
%
%Example 2:
%y=[0 1 0; 0 1 1];
%[ymax imax tmax]=interpmax(y,2,'time',[0 10 20]); 
%
%
% See also max, nanmax, min, nanmin, interpmin

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

% $Id: interpmax.m 8456 2013-04-16 07:05:09Z ivo.pasmans.x $
% $Date: 2013-04-16 15:05:09 +0800 (Tue, 16 Apr 2013) $
% $Author: ivo.pasmans.x $
% $Revision: 8456 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/stat_fun/interpmax.m $
% $Keywords: $

%% Preprocessing 

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

%check if chosen dimension is ok
if dim<1 | dim>length(size(y))
    error('Chosen dimension exceeds size y.'); 
end

%Reshape y
dimList=[1:length(size(y))];
dimList=circshift(dimList,[0 dim-1]);
y=permute(y,dimList);
sizey=size(y);
y=reshape(y,size(y,1),[]);

%settings
OPT.time=[];
OPT.order=2; 
[OPT OPTset]=setproperty(OPT,optarg);

%check dimensions time
if OPTset.time
   if (size(OPT.time,1)==1 & size(OPT.time,2)==size(y,1))|(size(OPT.time,2)==1 & size(OPT.time,1)==size(y,1))
       OPT.time=reshape(OPT.time,[],1); 
   elseif sum(sizey==size(OPT.time))==length(sizey)
       %convert time to vector
       OPT.time=shiftdim(OPT.time,dim); 
       OPT.time=OPT.time(:,1);        
   else
       error('Dimension of y and time do not match.'); 
   end %end if dimension time
else
    OPT.time=[1:size(y,1)]; 
end %end if OPTset time

%scaling time to prevent problems with matrix inversion 
if OPTset.time
    time0=OPT.time(1); 
    OPT.time=OPT.time-time0;
else
    time0=0; 
end

%% Locating maximum

%find maximum of the set y
[max_points imax_points]=max(y,[],1);

%interpolate around this maximum
if OPT.order==2
    
    tmax=nan(size(imax_points)); 
    vmax=nan(size(max_points)); 
    
    %maximum at start signal
    tmax(imax_points==1)=OPT.time(1); 
    vmax(imax_points==1)=max_points(imax_points==1); 
    
    %maximum at end signal
    tmax(imax_points==length(OPT.time))=OPT.time(end); 
    vmax(imax_points==length(OPT.time))=max_points(imax_points==length(OPT.time)); 
    
    %maximum in interior
    iInterior=find(imax_points>1 & imax_points<length(OPT.time));
    interpPol=@(x) [1 x(1) x(1)^2; 1 x(2) x(2)^2; 1 x(3) x(3)^2]; 
    for k=iInterior
            imax1=imax_points(k);
            interpCoef=inv(interpPol(OPT.time(imax1-1:imax1+1)))*y(imax1-1:imax1+1,k); 
            tmax(k)=-interpCoef(2)/(2*interpCoef(3)); 
            vmax(k)=interpCoef(1)-interpCoef(2)^2/(4*interpCoef(3)); 
    end %end for iInterior
    
else
    error(sprintf('Interpolation by fitting polynom of order %d is not supported',...
        OPT.order)); 
end %end if OPT.order

%% Postprocessing

%Find index time maximum
imax=interp1(OPT.time,[1:length(OPT.time)],tmax);

%Restore shape
sizey(1)=1; %singleton dimension

vmax=reshape(vmax,sizey); 
imax=reshape(imax,sizey); 
tmax=reshape(tmax,sizey); 

vmax=ipermute(vmax,dimList); 
imax=ipermute(imax,dimList); 
tmax=ipermute(tmax,dimList)+time0; 

%create output
if OPTset.time
    varargout={vmax,imax,tmax};
else
    varargout={vmax,imax};
end %end if OPTset

varargout=varargout(1:min(length(varargout),max(nargout,1))); 

end %end function interpmax



