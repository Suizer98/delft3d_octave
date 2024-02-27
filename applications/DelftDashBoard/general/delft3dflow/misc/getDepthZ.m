function zz = getDepthZ(z, dpsopt)
%GETDEPTHZ  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   zz = getDepthZ(z, dpsopt)
%
%   Input:
%   z      =
%   dpsopt =
%
%   Output:
%   zz     =
%
%   Example
%   getDepthZ
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: getDepthZ.m 5562 2011-12-02 12:20:46Z boer_we $
% $Date: 2011-12-02 20:20:46 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5562 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/misc/getDepthZ.m $
% $Keywords: $

%% Return matrix of depths in cell centres
%% dpsopt can be dp, min, max or mean

zz=zeros(size(z));
zz(zz==0)=NaN;

z1=z(1:end-1,1:end-1);
z2=z(2:end  ,1:end-1);
z3=z(2:end  ,2:end  );
z4=z(1:end-1,2:end  );

switch lower(dpsopt)
    case{'dp'}
        zz=z;
    case{'min'}
        zz0=max(z1,z2);
        zz0=max(zz0,z3);
        zz0=max(zz0,z4);
        zz(2:end,2:end)=zz0;
    case{'max'}
        zz0=min(z1,z2);
        zz0=min(zz0,z3);
        zz0=min(zz0,z4);
        zz(2:end,2:end)=zz0;
    case{'mean'}
        zz(2:end,2:end)=(z1+z2+z3+z4)/4;
end

