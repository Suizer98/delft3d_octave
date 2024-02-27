function [m n] = CheckDepth(m, n, dps)
%CHECKDEPTH  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [m n] = CheckDepth(m, n, dps)
%
%   Input:
%   m   =
%   n   =
%   dps =
%
%   Output:
%   m   =
%   n   =
%
%   Example
%   CheckDepth
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

% $Id: CheckDepth.m 5562 2011-12-02 12:20:46Z boer_we $
% $Date: 2011-12-02 20:20:46 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5562 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/misc/CheckDepth.m $
% $Keywords: $

%%
ns=length(m);

for k=1:ns
    i=m(k);
    j=n(k);
    if i>0 && j>0
        if dps(i,j)>-1
            if i==size(dps,1)
                d(1)=999;
            else
                d(1)=dps(i+1,j);
            end
            if j==size(dps,2)
                d(2)=999;
            else
                d(2)=dps(i,j+1);
            end
            if i==1
                d(3)=999;
            else
                d(3)=dps(i-1,j);
            end
            if j==1
                d(4)=999;
            else
                d(4)=dps(i,j-1);
            end
            [dsort,ii] = sort(d);
            if dsort(1)<-1
                switch ii(1)
                    case 1
                        m(k)=i+1;
                        n(k)=j;
                    case 2
                        m(k)=i;
                        n(k)=j+1;
                    case 3
                        m(k)=i-1;
                        n(k)=j;
                    case 4
                        m(k)=i;
                        n(k)=j-1;
                end
            end
        end
    end
end

