function S = oetroot
% OETROOT  root directory of OpenEarthTools Matlab installation
%
% S = oetroot returns a string that is the name of the directory
% where the OpenEarthTools Matlab software is installed.
%
% see also: matlabroot

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: oetroot.m 2107 2009-12-21 14:45:44Z boer_g $ 
% $Date: 2009-12-21 22:45:44 +0800 (Mon, 21 Dec 2009) $
% $Author: boer_g $
% $Revision: 2107 $

S = [fileparts(which('oetsettings')) filesep]; % fulle filename of current file

%% EOF