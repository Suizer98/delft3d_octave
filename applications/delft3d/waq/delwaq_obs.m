%DELWAQ_OBS Reads observation file from delwaq
%
%   [x y layer id] = DELWAQ_OBS(obsFile) Read the observation file
%   <obsFile>  and gives back x,y, layer and the id.
%   
%   NOTE: <obsFile> has to be a delwaq *.obs format
%   
%   Example
%   #  x, y, layer, name 
%   +14368.49181, +378821.90188, 0, appzk1
%   +7408.85431, +384955.72642, 0, appzk10
%   +13359.52025, +379405.76167, 0, appzk2
%   
%   See also: 

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------
function [x y z id] = delwaq_obs(obsFile)

fid = fopen(obsFile);

data = textscan(fid, '%f, %f, %f, %s','commentStyle', '#');
x  = data{1};
y  = data{2};
z  = data{3};
id = data{4};

fclose(fid);
