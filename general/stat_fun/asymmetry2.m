function [As] = asymmetry2(X)
% asymmetry - computes sample asymmetry of a distribution
%   [As]=asymmetry2(X) computes row-wise asymmetry

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2018 Deltares
%       grasmeij
%
%       bart.grasmeijer@deltares.nl
%
%       P.O.Box 177
%       2600 MH Delft, The Netherlands
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
% Created: 23 May 2018
% Created with Matlab version: 9.3.0.713579 (R2017b)

% $Id: kurtosis2.m 14368 2018-05-23 13:28:53Z bartgrasmeijer.x $
% $Date: 2018-05-23 15:28:53 +0200 (Wed, 23 May 2018) $
% $Author: bartgrasmeijer.x $
% $Revision: 14368 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/stat_fun/kurtosis2.m $
% $Keywords: asymmetry$

if isvector(X)
    X=X(:);
end
sz=[size(X) 1 ];
n=sz(1);
if n<4
    error('Asymmetry needs sample of size > 3')
end
Xh                  = imag(hilbert(X-mean(X)));
As                  = mean(Xh.^3) / mean(((X - mean(X)).^2).^(3/2));
end

