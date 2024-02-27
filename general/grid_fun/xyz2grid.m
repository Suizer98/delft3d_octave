function [X, Y, Z] = xyz2grid(xyz,bbox,trash)
%XYZ2GRID   Converts xyz matrix into X-, Y-, Z- matrices ready for pcolor.
%
%    [X,Y,Z] = xyz2grid(xyz,bbox,trash); 
%
% xyz:      Matrix with latitude (x-dir) in the first column. Longitude (y-dir)
%           in the second column and the corresponding depths in the third
%           column.
% bbox:     Input bbox as an array: [left right bottom top]. Output will only
%           be the values in the bbox. 
% trash:    Give NaN values NaN, or zero. Trash can only be NaN or 0. If trash
%           is set to 0, the values which are missing in the dataset will be 
%           set to 0. Use at own risk.
%
% This function is build using bathymetry maps from: 
%           http://portal.emodnet-bathymetry.eu/
% The XYZ-files downloaded here work for this function.
%
% Example 1:
%           xyz = [10*abs(randn(1000,1)) 50+3*abs(randn(1000,1)) -abs(20+20*randn(1000,1))];
%           [X,Y,Z] = xyz2grid(xyz,[2 8 51 56],0); 
%           pcolor(X,Y,Z);colorbar;shading interp;
%
% See also: CONVERTCOORDINATES
%
%   --------------------------------------------------------------------
%   Copyright (C) 2015 van Oord
%       C. Claessens
%
%       cclaessens@gmail.com	
%
%       van Oord
%       PO Box 44137
%       3006 HC Rotterdam
%       The Netherlands
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

tmp.X= xyz(:,1);
tmp.Y= xyz(:,2);
tmp.Z= xyz(:,3);

tmp.index = tmp.X>=bbox(1) & tmp.X<=bbox(2) ...
            & tmp.Y>=bbox(3) & tmp.Y<=bbox(4);

tmp.fields2copy = {'X','Y','Z'};    
for p = 1:numel(tmp.fields2copy)
    tmp.(tmp.fields2copy{p})(isnan(tmp.(tmp.fields2copy{p}))) = 1e-10;
    tmp.(tmp.fields2copy{p})(tmp.(tmp.fields2copy{p})==0)=1e-10;
    tmp.(tmp.fields2copy{p}) = tmp.(tmp.fields2copy{p}).*tmp.index;
    tmp.(tmp.fields2copy{p})( ~any(tmp.(tmp.fields2copy{p}),2), : ) = [];
    tmp.(tmp.fields2copy{p})( :, ~any(tmp.(tmp.fields2copy{p}),1) ) = [];
    tmp.(tmp.fields2copy{p})(tmp.(tmp.fields2copy{p})==1e-10) = trash;
    tmp.(tmp.fields2copy{p})(isnan(tmp.(tmp.fields2copy{p}))) = trash;
end

tmp.xr = sort(unique(tmp.X));
tmp.yr = sort(unique(tmp.Y));
tmp.gRho = zeros(length(tmp.yr),length(tmp.xr));
Z = griddata(tmp.X,tmp.Y,tmp.Z,tmp.xr,tmp.yr');
Z(isnan(Z)) = trash;
[X,Y] = meshgrid(linspace(min(tmp.X),max(tmp.X),length(tmp.xr)),...
                 linspace(min(tmp.Y),max(tmp.Y),length(tmp.yr)));                       
end

