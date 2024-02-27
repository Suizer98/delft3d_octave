function [Z, Y, X] = data_xyz_2_XY(varargin)
%DATA_XYZ_2_XY  Script to place regularly spaced xyz column data onto an X, Y grid returning Z
%
% See also

% --------------------------------------------------------------------
% Copyright (C) 2004-2009 Van Oord Dredging and Marine Contractors
% Version:      Version 1.0, October 2009
%     Mark van Koningsveld
%
%     mrv@vanoord.com
%
%     Environmental Engineering Department
%     Van Oord Dredging and Marine Contractors
%     Watermanweg 64
%     2628CN Rotterdam
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% --------------------------------------------------------------------

% $Id: data_xyz_2_XY.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $

%% settings
% defaults
OPT = struct(...
    'xyz', [], ...
    'X', [], ...
    'Y', [] ...
    );

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

% find locations of z values on X and Y grid
[dummy, idX] = ismember(OPT.xyz(:,1),OPT.X(1,:));
[dummy, idY] = ismember(OPT.xyz(:,2),OPT.Y(:,1));

% place z values onto Z grid at proper location (Z is preallocated for speed)
Z     = ones(size(OPT.X));    Z(:,:)=nan;
for i = 1:length(OPT.xyz(:,1))
    if idX(i) ~= 0 && idY(i) ~= 0
        try
            Z(idY(i),idX(i)) = OPT.xyz(i,3);
        end
    end
end

if sum(sum(~isnan(Z)))==0
    try
        Z = griddata(OPT.xyz(:,1),OPT.xyz(:,2),OPT.xyz(:,3),OPT.X,OPT.Y,'cubic');
        Z = Z.*nan;
    end
end
X = OPT.X;
Y = OPT.Y;