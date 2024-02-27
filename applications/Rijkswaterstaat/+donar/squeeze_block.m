function block_data = squeeze_block(block_data,variableCol,varargin)
%squeeze_block   squeezes out data flagged as 999999999999
%
%    block_data = donar.squeeze_block(block_data,variableCol)
%
% checks whether column variableCol from block_data = donar.read()
% has DONAR nodatavalue value 999999999999, and squeezes it out, so
% block_data becomes smaller in the 1st dimension. To keep the data
% in, set keyword 'nodatavalue' to nan instead of default [].
%
%See also: open, read

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 4 Rijkswaterstaat (SPA Eurotracks)
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: squeeze_block.m 10137 2014-02-05 09:50:57Z boer_g $
% $Date: 2014-02-05 17:50:57 +0800 (Wed, 05 Feb 2014) $
% $Author: boer_g $
% $Revision: 10137 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/+donar/squeeze_block.m $
% $Keywords: $

OPT.nodatavalue = [];

OPT = setproperty(OPT,varargin);

if isempty(OPT.nodatavalue)
   block_data(block_data(:,variableCol)> 999999999999 - .1, :) = [];
else
   block_data(block_data(:,variableCol)> 999999999999 - .1, :) = OPT.nodatavalue;
end
