function [x1,y1,ii] = poly_simplify(x, y, tolerance, varargin)
%POLY_SIMPLIFY  Simple algortihm for vertexx reduction of polygons
%
%   Methods supported are fast and slow. The slower method returns less
%   vertices to fullfill the same criterion, but for large datasets (in
%   combination with high tolerances) it is much, much slower.
%
%   Syntax:
%   [x1 y1] = poly_simplify(x, y, tolerance, varargin)
%
%   Input:
%   x         = x coordinates of polygon
%   y         = y coordinates of polygon
%   tolerance = maximum error that can exist after simplifaction compared
%               to original values
%   varargin  = <keyword>,<value>
%
%   Output:
%   x1        = x coordinates of simplified polygon
%   y1        = y coordinates of simplified polygon
%
%   Example
%     x1  = [2 9 9 5 3 2 2];
%     y1  = [1 3 2 4 7 5 1];
%     n   = length(x1);
%     x   = spline(1:n,x1,linspace(1,n,1e4))';
%     y   = spline(1:n,y1,linspace(1,n,1e4))';
%
%     tolerance = 0.15;
%     tic; [x1 y1] = poly_simplify(x,y,tolerance,'method','fast'); method_fast = toc;
%     tic; [x2 y2] = poly_simplify(x,y,tolerance,'method','slow'); method_slow = toc;
%     fprintf('fast method took %2.6f seconds and calculated a polygon with % 3d vertices to fullfill the requirement\n',method_fast,length(x1))
%     fprintf('slow method took %2.6f seconds and calculated a polygon with % 3d vertices to fullfill the requirement\n',method_slow,length(x2))
%     theta = poly_bisect(x,y);
%     offset = tolerance;
%     plot(x1,y1,'o','markerFaceColor','b'); hold on
%     plot(x,y,'k',...
%         x-offset*sin(theta),y+offset*cos(theta),'g',...
%         x1,y1,'.r',x2,y2,'.g',...
%         x2,y2,'g',x1,y1,'r',...
%         x+tolerance*sin(theta),y-tolerance*cos(theta),'g');
%     daspect([1 1 1]);
%     legend({'spline points','evaluated spline','maximum tolerance window','method = fast','method = slow'});
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64%       3067 GG%       Rotterdam%       The Netherlands
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

% This tool is part of OpenEarthTools.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 03 Nov 2010
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: poly_simplify.m 7860 2012-12-24 05:54:27Z tda.x $
% $Date: 2012-12-24 13:54:27 +0800 (Mon, 24 Dec 2012) $
% $Author: tda.x $
% $Revision: 7860 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/poly_fun/poly_simplify.m $
% $Keywords: $

%% proces varargin

OPT.method = 'fast';

OPT = setproperty(OPT,varargin{:});


%% start alorithm
ii          = false(size(x));
ii([1 end]) = true;
nn          = 1;
kk          = 2;
tolerance2  = tolerance^2;

switch OPT.method
    case {'slow'}
        while kk<numel(ii)
            xa  = x(nn);    ya  = y(nn);
            xb  = x(kk);    yb  = y(kk);
            xc  = x(nn:kk); yc  = y(nn:kk);
            
            cd2 = calculate_cd2(xa,xb,xc,ya,yb,yc);
            
            if any(cd2>tolerance2)
                nn = kk-1;
                ii(nn) = true;
            end
            kk = kk+1;
        end
    case {'fast'} 
        % orders of magnitude faster for large datasets, but results in
        % polygon of more points than strictly necessary fo fulfill the
        % criterion
        %
        % based on Ramer–Douglas–Peucker algorithm
        % http://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm
        if x(end)==x(1)&&y(end)==y(1)
            [dummy,ind] = max((x-x(1)).^2+(y-y(1)));
            ii(ind) = true;
        end
        
        nn = 1;
        tolerance2 = tolerance^2;
        ind = find(ii);
        while ind(nn)~=length(ii);
            ind = find(ii);
            
            xa  = x(ind(nn));           ya  = y(ind(nn));
            xb  = x(ind(nn+1));         yb  = y(ind(nn+1));
            xc  = x(ind(nn):ind(nn+1)); yc  = y(ind(nn):ind(nn+1));
            
            cd2 = calculate_cd2(xa,xb,xc,ya,yb,yc);
            
            
            [max_error,ind2] = max(cd2);
            if max_error>tolerance2
                ii(ind(nn)-1+ind2) = true;
            else
                nn = nn+1;
            end
        end
    otherwise
        error('unsupported method: %s', OPT.method)
end
x1 = x(ii);
y1 = y(ii);

function cd2 = calculate_cd2(xa,xb,xc,ya,yb,yc)
% algortihm is pretty simple:
% define two points, nn and kk, and calculate the distance of all
% points on the interval nn:kk to the straight line connecting them
%
%      	   _C
%        _/ |\
%      _/   | \
%    _/     |  \
%   A-------D---B
%
% We want to find distance cd.
%
% Algebra:
%
% cd2     = ac2 - ad2
% cd2     = bc2 - bd2
% ad + bd = ab
% bd2     = (ab - ad)2
% ac2-ad2 = bc2 - (ab - ad)2
% ad      = (-bc2+ac2+ab2)/2ab
% cd      = sqrt(ac2-ad2)
ac2 = (xa-xc).^2+(ya-yc).^2;
bc2 = (xb-xc).^2+(yb-yc).^2;
ab2 = (xa-xb).^2+(ya-yb).^2;
ad2 = (-bc2+ac2+ab2).^2/4/ab2;
cd2 = ac2-ad2;