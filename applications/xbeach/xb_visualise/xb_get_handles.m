function ax = xb_get_handles(n, varargin)
%XB_GET_HANDLES  Return valid axes handles for creating plots
%
%   Return valid axes handles for creating plots. By default, a single
%   figure window is created with the requested number of axes as subplots.
%   If a specific figure handle is provided, this figure window is used. If
%   a list of specific axes handles are provided, these are checked for
%   validity and appended with another figure window with subplots to
%   arrive at the requested number of axes.
%
%   Syntax:
%   ax = xb_get_handles(n, varargin)
%
%   Input:
%   n         = Number of axes needed
%   varargin  = handles:    Figure handle or list of axes handles
%
%   Output:
%   ax        = List with axes handles
%
%   Example
%   ax = xb_get_handles(4)
%   ax = xb_get_handles(4, 'handles', gcf)
%   ax = xb_get_handles(2, 'handles', [ax1 ax2])
%
%   See also xb_plot_hydro, xb_plot_morpho, xb_plot_sedtrans

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 23 Jun 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_get_handles.m 4725 2011-06-27 12:58:48Z hoonhout $
% $Date: 2011-06-27 20:58:48 +0800 (Mon, 27 Jun 2011) $
% $Author: hoonhout $
% $Revision: 4725 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_visualise/xb_get_handles.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'handles',          [] ...
);

OPT = setproperty(OPT, varargin{:});

%% get handles

ax = nan(1,n);

if isempty(OPT.handles) || ~all(ishandle(OPT.handles))
    figure;
    for i = 1:n
        ax(i) = subplot(n,1,i);
    end
else
    idx = strcmpi(get(OPT.handles, 'Type'), 'figure');
    if any(idx)
        figure(OPT.handles(find(idx, 1)));
        for i = 1:n
            ax(i) = subplot(n,1,i);
        end
    else
        idx = find(strcmpi(get(OPT.handles, 'Type'), 'axes'));
        
        for i = 1:min([n length(OPT.handles(idx))])
            ax(i) = OPT.handles(idx(i));
        end
        
        m = n - length(OPT.handles(idx));
        if m>0
            figure;
            for i = 1:m
                ax(length(OPT.handles(idx))+i) = subplot(m,1,i);
            end
        end
    end
end
