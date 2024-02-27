function pausedisp(varargin)
%PAUSEDISP   calls pause after displaying 'Pause, press key to continue ...'
%
% pausedisp(txt) displays txt instead of default message
%
%See also: PAUSE

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: pausedisp.m 7771 2012-12-03 12:18:05Z boer_g $
% $Date: 2012-12-03 20:18:05 +0800 (Mon, 03 Dec 2012) $
% $Author: boer_g $
% $Revision: 7771 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/pausedisp.m $
% $Keywords: $

   if nargin==0
      disp('Pause, press key to continue ...')
   else
      disp(char(varargin))
   end

   pause

%% EOF