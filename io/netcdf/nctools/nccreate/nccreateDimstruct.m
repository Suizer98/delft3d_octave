function dimstruct = nccreateDimstruct(varargin)
%NCCREATEDIMSTRUCT  Subsidiary of nccreateSchema
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = nccreateDimstruct(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   nccreateDimstruct
%
%   See also: ncCreateSchema, nccreateVarstruct

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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
% Created: 30 Mar 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: nccreateDimstruct.m 6391 2012-06-13 09:32:40Z tda.x $
% $Date: 2012-06-13 17:32:40 +0800 (Wed, 13 Jun 2012) $
% $Author: tda.x $
% $Revision: 6391 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nccreate/nccreateDimstruct.m $
% $Keywords: $

%%
dimstruct.Name      = '';
dimstruct.Length    = 0;
dimstruct.Unlimited = false;

dimstruct = setproperty(dimstruct,varargin);