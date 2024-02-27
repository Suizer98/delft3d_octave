function hdfvsave_load_test_oacp()
% HDFVSAVE_LOAD_TEST_OACP  test of hdfvsave and hdfvload
%  
% This file tests hdfvsave and hdfvload.
%
%
%   See also  hdfvsave hdfvload

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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
% Created: 22 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: hdfvsave_load_test_oacp.m 2820 2010-07-13 08:19:36Z geer $
% $Date: 2010-07-13 16:19:36 +0800 (Tue, 13 Jul 2010) $
% $Author: geer $
% $Revision: 2820 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/h4tools/hdfvsave_load_test_oacp.m $
% $Keywords: $

TeamCity.category('DataAccess');

clear S0 S1

fname = 'hdfvsave_tst_oacp.hdf';

S0.A(1).rand = rand(2,3,4);
S0.A(1).a    = rand(4);
S0.A(1).b    = rand(8);
S0.A(1).c2   = ['abc',
                'ABC'];
S0.A(1).e1   =  'abc';           

S0.A(2)      =  S0.A(1);           

S0.B.rand = rand(2,3,4);
S0.B.a    = rand(4);
S0.B.b    = rand(8);
S0.B.c2   = ['defghijklmnopqrstuvw',
             'DEFGHIJKLMNOPQRSTUVW'];
S0.B.e1   =  'defghijklmnopqrstuvw';  

s  = hdfvsave(fname,S0,'c')

S1 = hdfvload(fname)