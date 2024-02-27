function kcs = determineKCS(x, y)
%DETERMINEKCS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   kcs = determineKCS(x, y)
%
%   Input:
%   x   =
%   y   =
%
%   Output:
%   kcs =
%
%   Example
%   determineKCS
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

% $Id: determineKCS.m 5562 2011-12-02 12:20:46Z boer_we $
% $Date: 2011-12-02 20:20:46 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5562 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/misc/determineKCS.m $
% $Keywords: $

%%
kcs=zeros(size(x,1)+1,size(x,2)+1);
kcs(kcs==0)=NaN;
kcs1(:,:,1)=x(1:end-1,1:end-1);
kcs1(:,:,2)=x(2:end  ,1:end-1);
kcs1(:,:,3)=x(2:end  ,2:end  );
kcs1(:,:,4)=x(1:end-1,2:end  );
kcs1=sum(kcs1,3);
kcs(2:end-1,2:end-1)=kcs1;
kcs(~isnan(kcs))=1;
kcs(isnan(kcs))=0;

