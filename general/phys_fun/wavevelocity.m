function [c cg n k] = wavevelocity(T, h, varargin)
%WAVEVELOCITY  dispersion relation of short surface waves
%
%  [c cg n k] = wavevelocity(T, h)
%
%   See also: disper

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
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
% Created: 05 Oct 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: wavevelocity.m 12179 2015-08-18 09:21:31Z ormondt $
% $Date: 2015-08-18 17:21:31 +0800 (Tue, 18 Aug 2015) $
% $Author: ormondt $
% $Revision: 12179 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/phys_fun/wavevelocity.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'g',            9.81 ...
);

OPT = setproperty(OPT, varargin{:});

%% determine wave speed

k   = disper(2*pi./T, h, OPT.g);
n   = .5*(1+2.*k.*h./sinh(2.*k.*h));
c   = OPT.g.*T./(2*pi).*tanh(k.*h);
cg  = n.*c;