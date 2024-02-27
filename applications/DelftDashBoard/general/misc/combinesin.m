function [a3 phi3] = combinesin(a1, phi1, a2, phi2,varargin)
%COMBINESIN  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [a3 phi3] = combinesin(a1, phi1, a2, phi2)
%
%   Input:
%   a1   =
%   phi1 =
%   a2   =
%   phi2 =
%
%   Output:
%   a3   =
%   phi3 =
%
%   Example
%   combinesin
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: combinesin.m 11440 2014-11-25 22:39:00Z ormondt $
% $Date: 2014-11-26 06:39:00 +0800 (Wed, 26 Nov 2014) $
% $Author: ormondt $
% $Revision: 11440 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/misc/combinesin.m $
% $Keywords: $

%%

operation='add';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'subtract'}
                operation='subtract';
        end
    end
end

c1=a1.*exp(i*phi1);
c2=a2.*exp(i*phi2);

switch operation
    case{'add'}
        c3=c1+c2;
    otherwise
        c3=c1-c2;
end

a=real(c3);
b=imag(c3);

a3=sqrt(a.^2+b.^2);
phi3=atan2(b,a);

