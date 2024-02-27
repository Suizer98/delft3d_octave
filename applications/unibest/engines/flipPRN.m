function [PRNdata]=flipPRN(PRNdata)
%flipPRN : Flips the x-direction of a PRN output file (e.g. instead of North->South to South->North)
%
%   Syntax:
%     function [PRNdata]=flipPRN(PRNdata)
% 
%   Input:
%     PRNdata              structure that has been read with readPRN.m
%  
%   Output:
%     PRNdata              structure with PRNdata (with flipped x-direction)
%
%   Example:
%     PRNdata    = readPRN('example.PRN');
%     [PRNdata2] = flipPRN(PRNdata)
%
%   See also 
%     readPRN

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

% $Id: flipPRN.m 8631 2013-05-16 14:22:14Z huism_b $
% $Date: 2013-05-16 16:22:14 +0200 (Thu, 16 May 2013) $
% $Author: huism_b $
% $Revision: 8631 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/engines/flipPRN.m $
% $Keywords: $

    for ii=1:length(PRNdata)
        fldnms = fields(PRNdata(ii));
        size2 = length(PRNdata(ii).xdist2);size1=size2+1;
        PRNdata(ii).xdist  = cumsum([0;flipud(diff(PRNdata(ii).xdist))]);
        PRNdata(ii).xdist2 = cumsum([0;flipud(diff(PRNdata(ii).xdist2))]);
        for jj=1:length(fldnms)
            if ~strcmpi(fldnms{jj},'xdist') && ~strcmpi(fldnms{jj},'xdist2') && ...
               (size(PRNdata(ii).(fldnms{jj}),1)==size1 || size(PRNdata(ii).(fldnms{jj}),1)==size2)
                PRNdata(ii).(fldnms{jj}) = flipud(PRNdata(ii).(fldnms{jj}));
            end
        end
    end

end