function z1 = derefine3(z0)
%DEREFINE3  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   z1 = derefine3(z0)
%
%   Input:
%   z0 =
%
%   Output:
%   z1 =
%
%   Example
%   derefine3
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

% $Id: derefine3.m 5560 2011-12-02 11:26:29Z boer_we $
% $Date: 2011-12-02 19:26:29 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5560 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tiling/derefine3.m $
% $Keywords: $

%%
nx=size(z0,2);
ny=size(z0,1);

iind=[1 1 1 2 2 2 3 3 3];
jind=[1 2 3 1 2 3 1 2 3];
wgt=[1 2 1 2 4 2 1 2 1];

for k=1:9
    %    zz(:,:,k)=z0(iind(k):iind(k)+ny-3,jind(k):jind(k)+nx-3);
    zz(:,:,k)=z0(iind(k):iind(k)+ny-3,jind(k):jind(k)+nx-3);
    isn(:,:,k)=~isnan(zz(:,:,k));
    w(:,:,k)=isn(:,:,k)*wgt(k);
end

sumw=sum(w,3);
zz(isnan(zz))=0;

for k=1:9
    zz(:,:,k)=zz(:,:,k).*w(:,:,k);
end

zz=sum(zz,3)./sumw;

if isempty(find(~isnan(z0(2:end-1,2:end-1)), 1))
    % Only NaNs in inner domain
    zz=nan(size(zz));
end

%z1=zz(1:2:end,1:2:end);
z1=zz(1:2:end,1:2:end);


