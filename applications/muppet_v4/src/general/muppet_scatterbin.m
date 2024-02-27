function varargout = scatterbin(x,y,varargin)
%plot bivariate histogram to indicate density of scatter plot
%
% scatterbin(x,y) plots pcolor density plot with automatic bin
% edges. Bin is scaled to represent percentage of total points.
% Text is percentage is added to the plot.
%
% scatterbin(x,y,EDGESx,EDGESy) uses user-defined edges.
% Edges can be a vector with edge corners, or a scaler as the 
% number of bins (default 25), like hist. 
%
% Optional output arguments are: [<h,bin,EDGESx,EDGESy,htxt>] = scatterbin(...)
% where h is the pcolor handle, and htxt is the text handle.
%
% Example:
%  x = rand([100 1]);y = rand([100 1]);
%  EDGESx=0:.1:1
%  EDGESy=0:.1:1
%  scatterbin(x,y,EDGESx,EDGESy) 
%  hold on
%  scatter (x,y)
%  colorbarwithvtext('fraction [%]')
%
%See also: histc2, scatter, wind_rose

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 Van Oord
%       Gerben de Boer, <gerben.deboer@vanoord.com>
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

% $Id: scatterbin.m 12074 2015-07-09 08:23:51Z gerben.deboer.x $
% $Date: 2015-07-09 10:23:51 +0200 (Thu, 09 Jul 2015) $
% $Author: gerben.deboer.x $
% $Revision: 12074 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/scatterbin.m $
% $Keywords: $

OPT.scale = 100; % percent
OPT.fmt   = '%0.2f'; % percent
OPT.text  = 0;
OPT.colormap='jet';

EDGESx = 25;
EDGESy = 25;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'edgesx'}
                EDGESx=varargin{ii+1};
            case{'edgesy'}
                EDGESy=varargin{ii+1};
            case{'text'}
                OPT.text=varargin{ii+1};
            case{'format'}
                OPT.fmt=varargin{ii+1};
            case{'colormap'}
                OPT.colormap=varargin{ii+1};
            case{'scale'}
                OPT.scale=varargin{ii+1};
        end
    end
end

% if nargin==3
% elseif nargin==4
%     EDGESx = varargin{1};
%     EDGESy = varargin{2};
% end

if isscalar(EDGESx)
    EDGESx = linspace(min(x(:)),max(x(:)),EDGESx)';
end
if isscalar(EDGESy)
    EDGESy = linspace(min(y(:)),max(y(:)),EDGESy)';
end

% c = bin2(x,y,ones(size(x)),EDGESx,EDGESy,'exact',1);c = c.n;
bin = histc2(x,y,EDGESx,EDGESy);
bin = OPT.scale.*bin(1:end-1,1:end-1)./nansum(bin(:));
bin(bin==0)=nan;
bin=bin/(max(max(bin)));
%h = pcolorcorcen(EDGESx,EDGESy,bin);
h = pcolor(EDGESx(1:end-1),EDGESy(1:end-1),bin);shading flat;
% set(gca,'xtick',EDGESx)
% set(gca,'ytick',EDGESy)
colormap(OPT.colormap); % make blueish white where there's no data
caxis([0 0.4]);

if OPT.text
    [xc,yc] = meshgrid(corner2center1(EDGESx),corner2center1(EDGESy));
    txt = cellstr(num2str(bin(:),OPT.fmt));
    txt = cellfun(@(x) strtrim(x),txt,'UniformOutput',0);
    ind = strmatch('NaN',txt);
    for i=ind(:)'
        txt{i} = '';
    end
    htxt = text(xc(:),yc(:),txt,'horizontal','center');
end


if nargout==1
    varargout = {h};
elseif nargout==2
    varargout = {h,bin};    
elseif nargout==4
    varargout = {h,bin,EDGESx,EDGESy};
elseif nargout==5
    varargout = {h,bin,EDGESx,EDGESy,htxt};       
end


