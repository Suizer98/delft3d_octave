function [volumes, CumVolume] = getCumVolume (x, z, z2)
% GETCUMVOLUME routine to derive the cumulative volume  between 2 profiles
%
% routine to derive the volume between two profiles using the same x-grid:z and z2. 
% The the volumes of each individual grid cell as well as the cumulative volumes (going landward) 
% are derived.
%
% Syntax:
% [volumes, CumVolume] = getCumVolume (x, z, z2)
%
% Input:
% x         = column array with x-values
% z         = column array with z-values
% z2        = column array with z2-values
%
% Output:
% volumes   = volumes of each individual grid cell
% CumVolume = cumulative volume (going landward)
%
% See also: 
 
%--------------------------------------------------------------------------------
% Copyright(c) Deltares 2004 - 2007  FOR INTERNAL USE ONLY
% Version:  Version 1.0, April 2008 (Version 1.0, April 2008)
% By:      <Pieter van Geer and Kees den Heijer (email:Pieter.vanGeer@deltares.nl / Kees.denHeijer@deltares.nl)>
%--------------------------------------------------------------------------------
 
 
%% check input
xIsVector  = isvector(x);
zIsVector  = isvector(z);
z2IsVector = isvector(z2);

if xIsVector && zIsVector && z2IsVector
    AllSameSize = length(x) == length(z) && length(x) == length(z2);
    if ~AllSameSize
        error('GETCUMVOLUME:sizeXZZ2', 'x, z and z2 should be the same size')
    end
else
    error('GETCUMVOLUME:XZZ2novector', 'x, z and z2 should be vectors')
end

%%
if length(x)>1
    thr = 8;

    % mean z of succesive elements of z and z2
    meanZ  = mean([z(1:end-1)  z(2:end)],  2);
    meanZ2 = mean([z2(1:end-1) z2(2:end)], 2);

    % horizontal gridsizes
    diffX = diff(x);

    % volumes of individual cells = dx * dz
    volumes = roundoff((meanZ2-meanZ).*diffX, thr);

    % Cumulative volume (going landward)
    CumVolume = roundoff(flipud(cumsum(flipud(volumes))), thr);
else
    [volumes CumVolume] = deal(0);
end