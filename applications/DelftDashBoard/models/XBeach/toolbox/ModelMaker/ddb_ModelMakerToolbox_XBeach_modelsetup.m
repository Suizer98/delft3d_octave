function ddb_ModelMakerToolbox_XBeach_modelsetup(handles)
%XB_VISUALIZE_MODELSETUP  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_visualize_modelsetup(varargin)
%
%   Input: For <keyword,value> pairs call xb_visualize_modelsetup() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_visualize_modelsetup
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
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
% Created: 04 Mar 2013
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: xb_visualize_modelsetup.m 9809 2013-12-03 09:48:36Z bieman $
% $Date: 2013-12-03 10:48:36 +0100 (Tue, 03 Dec 2013) $
% $Author: bieman $
% $Revision: 9809 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_visualise/xb_visualize_modelsetup.m $
% $Keywords: $

%% Get relevant variables from input structure
try
    
    x = handles.model.xbeach.domain(handles.activeDomain).grid.x;
    y = handles.model.xbeach.domain(handles.activeDomain).grid.y;
    zgrid = handles.model.xbeach.domain(handles.activeDomain).depth;
    
    %
    crossshore = ((x(1,:) - x(1,1)).^2 + (y(1,:) - y(1,1)).^2.).^0.5;
    longshore = ((x(:,1) - x(1,1)).^2 + (y(:,1) - y(1,1)).^2.).^0.5;
    [XT YT]     = meshgrid(crossshore,longshore);
    [ny1 nx1] = size(XT);
    
    val = crossshore ;
    [nx ny] = size(val);
    for i = 1:(ny-1)
        dval_C(i) = val(i+1) - val(i);
    end
    
    val = longshore;
    [nx ny] = size(val);
    for i = 1:(nx-1)
        dval_L(i) = val(i+1) - val(i);
    end
    
    [n,m1] = size(dval_L);
    [n,m2] = size(dval_C);
    res2 = repmat(dval_C,m1,1) .* repmat(dval_L,m2,1)';
    
    
    figure;
    subplot(2,2,1)
    pcolor(x,y,zgrid); shading flat; caxis([-10 +5]); colormap(jet);  xlabel('X [m]'); ylabel('Y [m]'); title('Model set-up');
    colorbar
    
    subplot(2,2,2)
    pcolor(x([1:(ny1-1)],[1:(nx1-1)]),y([1:(ny1-1)],[1:(nx1-1)]),res2); shading flat; colormap(jet);  xlabel('X [m]'); ylabel('Y [m]'); title('Grid area size');
    colorbar
    
    subplot(2,2,3)
    plot(crossshore(1:(nx1-1)), dval_C); title('Variation grid cross-shore'); xlabel('Cross-shore distance [m]'); ylabel('dx [m]')
    
    subplot(2,2,4)
    plot(longshore(1:(ny1-1)), round(dval_L)); title('Variation grid longshore'); xlabel('Longshore distance [m]'); ylabel('dy [m]')
    
catch
    'something went wrong'
end

