function cmap = colormap_cpt(cpt,nSteps,varargin)
% COLORMAP_CPT   builds a matlab colormap from a cpt file 
%
%   Syntax:
%       cmap = colormap_cpt(name)
%       cmap = colormap_cpt(name, nSteps)
%       cmap = colormap_cpt(name, nSteps, 'Smooth' , true)
%
% Input:
%   name       = the name of a colormap from the cpt-city website, see:
%              <a href="http://soliton.vm.bytemark.co.uk/pub/cpt-city/">http://soliton.vm.bytemark.co.uk/pub/cpt-city/</a>
%   nSteps     = number of colorsteps (optional)
%   $varargin  =
%
%   where the following <keyword,value> pairs have been implemented (values indicated are the current default settings):
%       'Smooth'     , [false]    = Flag to force a smooth color interpolation output
%
% Output:
%   cmap       = RGB (n x 3) colormap matrix with n colors
%
% Note:
%  make sure to have downloaded the cpt-city package from:
%  <a href="http://soliton.vm.bytemark.co.uk/pub/cpt-city/pkg/cpt-city-cpt-1.93.zip">http://soliton.vm.bytemark.co.uk/pub/cpt-city/pkg/cpt-city-cpt-1.93.zip</a>
%  Unpack and add folder to the matlab search path. 
% Remark: It can be that this file has been updated to a higher version.
% 
% Links to 'nice' colormaps are:
%   <a href="http://soliton.vm.bytemark.co.uk/pub/cpt-city/jjg/serrate/seq/index.html</a>
%   <a href="http://soliton.vm.bytemark.co.uk/pub/cpt-city/jjg/serrate/div/index.html</a>
%   <a href="http://soliton.vm.bytemark.co.uk/pub/cpt-city/jjg/cbcont/seq/index.html</a>
%   <a href="http://soliton.vm.bytemark.co.uk/pub/cpt-city/jjg/cbcont/div/index.html</a>
%   <a href="http://soliton.vm.bytemark.co.uk/pub/cpt-city/cb/seq/index.html</a>
%   <a href="http://soliton.vm.bytemark.co.uk/pub/cpt-city/cb/div/index.html</a>
%   <a href="http://soliton.vm.bytemark.co.uk/pub/cpt-city/cb/qual/index.html</a>
%
% Some examples of nice colormaps are:
%   'temperature' 
%   'Spectral 11'
%   'RdYlBu' 
%   'RdBu 11'
%   'RdBu' 
%   'bathymetry_vaklodingen'  
%   
%
% Example:
%
%   figure
%   cmap = colormap_cpt('temperature');
%   subplot(3,1,[1 2])
%       colormap(cmap)
%       [x,y,z] = cylinder(100:-1:10);surf(x,y,z);
%       camlight(300,20); view([-60 32]); shading flat;
%       material shiny; lighting gouraud; colorbar
%   subplot(3,1,3)
%       plot(cmap); axis([1 size(cmap,1) -.01 1.01])
%
%   %The colormap 'temperature' is not continuous (it has 23 colorsteps)
%   %Interpolating the map over more points doesn't give other results:
%
%       cmap = colormap_cpt('temperature',64);
%
%   %By forcing to create a smooth colormap, the function skips the
%   %colorsteps and interpolates over the whole range:
%
%       cmap = colormap_cpt('temperature',100,'Smooth',true);
%
%   %For continuous colormaps, like 'RdBu', this exercise is not necessary. 
%
% See also: colormaps

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% $Id: colormap_cpt.m 14524 2018-08-22 15:09:19Z steven.kox.x $
% $Date: 2018-08-22 23:09:19 +0800 (Wed, 22 Aug 2018) $
% $Author: steven.kox.x $
% $Revision: 14524 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/color_fun/colormaps/colormap_cpt.m $
% $Keywords: $

OPT.smooth = false;

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT,lower(varargin),'onExtraField','silentIgnore');

%% adjust of *.cpt filename so you can copy paste it from the website
cpt = strrep(cpt,' ','_');
if length(cpt) > 3
    if ~strcmpi(cpt(end-3:end),'.cpt')
        cpt = [cpt '.cpt'];
    end
else
    cpt = [cpt '.cpt'];
end
%% open cpt file
fid = fopen(cpt);

S = fgetl(fid);
cdata = [];
while ~isempty(S) && ~isletter(S(1)) && S(1)~=-1;
    % skip lines with a hash
    while strcmp(S(1),'#')
        S = fgetl(fid);
        if isempty(S), S = '#'; end
    end
    cdata = [cdata sscanf(S,'%f')];
    S = fgetl(fid);
end

%% close cpt file
fclose(fid);

%% set nSteps
if nargin == 1;
    nSteps = size(cdata,2);
end
%Check nSteps
if isempty(nSteps) || ischar(nSteps)
    nSteps = size(cdata,2);
end 

%% adjust points to allow for interpolation without duplicate points
cdata(5,1:end-1) = cdata(5,1:end-1)-abs(cdata(5,1:end-1)).*eps;
cdata(5,cdata(5,:)==0) = -eps;

%% interpolation values
xi = linspace(cdata(1,1),cdata(5,end),nSteps);

%% reshape cdata
if OPT.smooth
    cdata = horzcat(cdata(1:4,:),cdata(5:8,end)) ;
else
    cdata = reshape(cdata,size(cdata).*[.5 2]);
end


%% interp RGB values
R = interp1(cdata(1,:),cdata(2,:),xi);
G = interp1(cdata(1,:),cdata(3,:),xi);
B = interp1(cdata(1,:),cdata(4,:),xi);

%% collect data
cmap = [R' G' B']/255;

%% make sure all values are between 0 and 1
% needed because of floating point rounding errors
cmap(cmap>1) = 1;
cmap(cmap<0) = 0;