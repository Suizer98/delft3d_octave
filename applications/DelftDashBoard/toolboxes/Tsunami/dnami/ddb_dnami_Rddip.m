function ddb_dnami_Rddip()
%DDB_DNAMI_RDDIP  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_dnami_Rddip(())
%
%   Input:
%   () =
%
%
%
%
%   Example
%   ddb_dnami_Rddip
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

% $Id: ddb_dnami_Rddip.m 10889 2014-06-25 08:09:38Z boer_we $
% $Date: 2014-06-25 16:09:38 +0800 (Wed, 25 Jun 2014) $
% $Author: boer_we $
% $Revision: 10889 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tsunami/dnami/ddb_dnami_Rddip.m $
% $Keywords: $

%%
global Mw        lat_epi     lon_epi    fdtop     totflength  fwidth   disloc     foption
global dip       strike      slip       fdepth    userfaultL  tolFlength
global nseg      faultX      faultY     faultTotL xvrt        yvrt
global mu        raddeg      degrad     rearth

fig1 = findobj('name','Tsunami Toolkit');
fdtop= str2num(get(findobj(fig1,'tag','FDtop'),'string'));
if fdtop < 0
    set(findobj(fig1,'tag','FDtop'),'string','0')
    fdtop= 0;
end
for i=1:nseg
    dip(i)   = str2num(get(findobj(fig1,'tag',['Dipstr' num2str(i)]),'string'));
    fdepth(i)= 0.5*fwidth*sin(dip(i)*degrad) +fdtop;
    set(findobj(fig1,'tag',['FDepth' num2str(i)]),'string',int2str(fdepth(i)));
end

