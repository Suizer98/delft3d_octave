% function readSTI_test()
% READSTI_TEST  One line description goes here
%
% More detailed description of the test goes here.
%
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Kees den Heijer
%
%       kees.denheijer@deltares.nl
%
%       P.O. Box 177
%       2600 MH  DELFT
%       The Netherlands
%       Rotterdamseweg 185
%       2629 HD  DELFT
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 26 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: readSTI_test.m 10185 2014-02-11 08:46:43Z heijer $
% $Date: 2014-02-11 16:46:43 +0800 (Tue, 11 Feb 2014) $
% $Author: heijer $
% $Revision: 10185 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DGeoStability/io/readSTI_test.m $
% $Keywords: $

MTestCategory.WorkInProgress;

D = dir2('n:\Applications\DSC\DGeoStability\Projects\Examples\',...
    'file_incl', '1a\.sti$',...
    'no_dirs', true);

for i = 1:length(D)
    
    fname = fullfile(D(i).pathname, D(i).name);
    F = dgst_stiread(fname);
    dgst_stiwrite([D(i).name(1:end-4) 'rep.sti'], F)
end