function fillAxis(ax_handle)
%FILLAXIS As axis equal, but keeps the axis filled to its position
%
% Syntax:
% FILLAXIS(ax_handle)
%
% ax_handle:    handle of axis
%
% See also: AXIS

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Code
axPos=get(ax_handle,'position');
ratio=axPos(3)/axPos(4);
xL=get(ax_handle,'XLim');
yL=get(ax_handle,'YLim');

if diff(xL)/diff(yL) > ratio
    yL=[mean(yL)-diff(xL)/(2*ratio) mean(yL)+diff(xL)/(2*ratio)];
    set(ax_handle,'YLim',yL);
else
    xL=[mean(xL)-diff(yL)/(2*ratio) mean(xL)+diff(yL)/(2*ratio)];
    set(ax_handle,'XLim',xL);
end

daspect([1 1 1]);