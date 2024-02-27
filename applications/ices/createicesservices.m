function createicesservices
%CREATEICESSERVICES  createClassFromWsdl for ICES
%
%See also: createClassFromWsdl, http://ocean.ices.dk/webservices/hydchem.asmx
%          http://ecosystemdata.ices.dk/webservices/EcoSystemWebServices.asmx

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: createicesservices.m 8461 2013-04-16 14:52:45Z boer_g $
% $Date: 2013-04-16 22:52:45 +0800 (Tue, 16 Apr 2013) $
% $Author: boer_g $
% $Revision: 8461 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ices/createicesservices.m $
% $Keywords$

%% remember current dir before moving to ICES dir
dir0 = pwd;
cd(fileparts(mfilename('fullpath')))

%%
url='http://ecosystemdata.ices.dk/webservices/EcoSystemWebServices.asmx?WSDL';
createClassFromWsdl(url);

%%
url='http://ocean.ices.dk/webservices/hydchem.asmx?WSDL';
createClassFromWsdl(url);

%%
cd(dir0);
