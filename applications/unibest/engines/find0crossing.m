function [x_zerocross,varargout]=find0crossing(X,Y,varargin)
%find0crossing : finds zero crossings in x,y 
%
%   Syntax:
%     function [x_zerocross,id]=find0crossing(X,Y,Ylevel)
% 
%   Input:
%     X            [1xN] vector
%     Y            [1xN] vector
%     Ylevel       (optional) level at which crossing should be computed (default=0)
%  
%   Output:
%     x_zerocross  location of zero crossing
%     id           (optional) id of zerocrosspoint
%
%   Example:
%     X=[1:32];
%     Y=[-1:0.1:1,1:-0.3:-2];
%     Ylevel=0;
%     [x_zerocross,id]=find0crossing(X,Y,Ylevel)
%
%   See also 
%     

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: flipPRN.m 8631 2013-05-16 14:22:14Z huism_b $
% $Date: 2013-05-16 16:22:14 +0200 (Thu, 16 May 2013) $
% $Author: huism_b $
% $Revision: 8631 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/engines/flipPRN.m $
% $Keywords: $


%if nargin>3
%   level = varargin{1};
%   dx    = varargin{2};
%elseif
if nargin>2
    level = varargin{1};
%   dx    = (max(X)-min(X))/100000;
else
    level = 0;
%   dx    = (max(X)-min(X))/100000;
end

if size(X,2)>size(X,1)
    X=X';
end
if size(Y,2)>size(Y,1)
    Y=Y';
end

id_zerocross=[];
clear x_zerocross
if isnumeric(X) & isnumeric(Y)
    if size(X,2)==1 & size(X,1)>1 & size(Y,2)==1 & size(Y,1)>1
        x_zerocross=[];
        %xy = addEquidistantPointsBetweenSupportingLDBPoints([X,Y],dx);
        %diffy       = abs(xy(:,2) - level);
        %id          = find(diffy==min(min(diffy)));
        %x_zerocross = xy(id,1);
        
        
        Ydiff  = Y-level;
        idplus = find(Ydiff(2:end)>0 & Ydiff(1:end-1)<0);
        idmin  = find(Ydiff(1:end-1)>0 & Ydiff(2:end)<0);
        idzero = find(Ydiff==0);
        
        for ii=1:length(idplus)
            x1 = X(idplus(ii));
            x2 = X(idplus(ii)+1);
            y1 = Y(idplus(ii));
            y2 = Y(idplus(ii)+1);
            x_zerocross(ii)      = x1 + (x2-x1)/(y2-y1)*(level-y1);
            id_zerocross(ii)     = mean(idplus(ii)) + (level-y1)/(y2-y1);
        end
        for iii=1:length(idmin)
            x1 = X(idmin(iii));
            x2 = X(idmin(iii)+1);
            y1 = Y(idmin(iii));
            y2 = Y(idmin(iii)+1);
            x_zerocross(iii+length(idplus))      = x1 + (x2-x1)/(y2-y1)*(level-y1);
            id_zerocross(iii+length(idplus))     = mean(idmin(iii)) + (level-y1)/(y2-y1);
        end
        for iiii=1:length(idzero)
            x1 = X(idzero(iiii));
            x_zerocross(iiii+length(idplus)+length(idmin))      = x1;
            id_zerocross(iiii+length(idplus)+length(idmin))     = mean(idzero(iiii));
        end
        if isempty(idplus) & isempty(idmin) & isempty(idzero)
            %fprintf('warning cannot find crossing point!\n');
            %fprintf('(polygon does not cross horizontal plane)\n');
        end
    elseif size(X,2)==1 & size(X,1)==1 & size(Y,2)==1 & size(Y,1)==1
        x_zerocross=[];
        fprintf('warning cannot find crossing point if only 1 point is specified!\n');
    else
        x_zerocross=[];
        fprintf('warning x,y values should be vectors!\n');
    end
else
    x_zerocross=[];
    fprintf('warning x,y values are not numeric!\n');
end
x_zerocross=sort(x_zerocross);

if nargout==2
    varargout{1}=id_zerocross;
end