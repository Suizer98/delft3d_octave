function filtersco(deg1,deg2,SCOfilename)
%filtersco : Script to filter out directions smaller than 'deg1' & larger than 'deg2'
%
%   Syntax:
%     function filtersco(deg1,deg2,SCOfilename)
%
%   Input:
%     deg1          :  angle 1
%     deg2          :  angle 2
%     SCOfilename   :  (optional) string with .SCO filename (otherwise a file can be selected)
%
%   Output:
%     .sco file
%
%   Example:
%     filtersco(240,290,'test.sco')
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: filtersco.m 3517 2013-04-11 13:57:14Z hoekstra $
% $Date: 2013-04-11 15:57:14 +0200 (Thu, 11 Apr 2013) $
% $Author: hoekstra $
% $Revision: 3517 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/SCOextract/filtersco.m $
% $Keywords: $

if nargin<3
    [filename, pathname] = uigetfile('*.sco', 'Select an SCO-file');
else
    [pathname nm1 nm2]=fileparts(SCOfilename);
    pathname = [pathname,filesep];
    filename = [nm1,nm2];
end
sco_output = ([pathname filename(1:end-4) 'new.sco']);

[S.wl,S.hs,S.tp,S.xdir,S.dur,S.x,S.y,S.numOfDays] = readSCO([pathname filename]);
i=0;
for k=1:length(S.wl)
    if S.xdir(k)>deg1 && S.xdir(k)<deg2 && deg2>deg1
        i=i+1;
        Snew.wl(i,1)  = S.wl(k);
        Snew.hs(i,1)  = S.hs(k);
        Snew.tp(i,1)  = S.tp(k);
        Snew.xdir(i,1)= S.xdir(k);
        Snew.dur(i,1) = S.dur(k);
    elseif deg2<deg1 %relevant if domain crosses north
        if S.xdir(k)>deg1 || S.xdir(k)<(deg1-360+(deg1-deg2))
            i=i+1;
            Snew.wl(i,1)  = S.wl(k);
            Snew.hs(i,1)  = S.hs(k);
            Snew.tp(i,1)  = S.tp(k);
            Snew.xdir(i,1)= S.xdir(k);
            Snew.dur(i,1) = S.dur(k);
        end
    end
end
Snew.x=S.x; Snew.y=S.y; Snew.numOfDays=S.numOfDays;
writeSCO(sco_output,Snew.wl,Snew.hs,Snew.tp,Snew.xdir,Snew.dur,S.x,S.y,S.numOfDays);
