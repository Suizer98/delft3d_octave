function axislat(varargin)
%AXISLAT   Sets (lon,lat) dataaspectratio for speficic latitude to have equal (dx,dy).
%
%    axislat
%    axislat(latitude)      % passing the speficic latitude
%    axislat(ha)            % passing the axes handle
%    axislat(ha, latitude)  % passing the axes handle and speficic latitude
%
% sets the x and y dataaspectratio so that
% WHEN PLOTTING IN DEGREES LAT AND LON, the vertical 
% scale in km is roughly the same as the horizontal one.
% By default mean(ylim).
%
% See also: daspect, num2strll

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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
% changed G.J. de Boer(g.j.deboer@tudelft.nl) 11th March 2006

% $Id: axislat.m 14023 2017-12-05 08:34:58Z rho.x $
% $Date: 2017-12-05 16:34:58 +0800 (Tue, 05 Dec 2017) $
% $Author: rho.x $
% $Revision: 14023 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/axislat.m $
% $Keywords: $

if nargin ==1
    if ishandle(varargin{1})            % Thus the input is: the axes handle
        ha  = varargin{1};
        lat = abs(mean(ylim(ha)));      %   Calculate the average y coordinate
    else                                % Thus the input is: lat
        ha  = gca;
        lat = abs(varargin{1});
    end
    
elseif nargin == 2;                     % Thus the input is: (ha , lat)
    ha  = varargin{1};
    lat = abs(varargin{2});
else
    return
end

d    = get(ha,'dataaspectratio');       % Get the current aspect ratio
d(2) = d(1).*cosd(lat);                 % Calculate the aspect ratio correction

daspect(ha,d);                          % Set the new aspect ratio

%% EOF