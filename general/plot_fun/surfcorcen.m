function varargout = surfcorcen(varargin)
%SURFCORCEN    3D surface with correct color shading
%
% surf(z)
% surf(z,c)
% surf(x,y,z)
% surf(x,y,z,c)
%
% surfcorcen is a wrapper to surf for dealing with
% the difficult corner/center issues.
%
% - if corner co-ordinates and corner data are supplied
%   shading interp is used
% - if corner co-ordinates and center data are supplied
%   shading flat is used. In this case the data array at centers
%   should be one smaller in both dimensions than the co-ordinate
%   array given at corners.
%
%  +-------+-------+-------+  LEGEND:
%  |       |       |       |
%  |   o   |   o   |   o   |  + = corner array with
%  |       |       |       |      size mmax=4, nmax=3
%  +-------+-------+-------+
%  |       |       |       |  o = center array with
%  |   o   |   o   |   o   |      size mmax=3, nmax=2
%  |       |       |       |
%  +-------+-------+-------+
%
%  shading flat                shading interp
%  when (x,y,c) have           when the c array is one smaller
%  the same size               in m and n direction than the
%                              (x,y) arrays
%  +-------+-------+-------+   +-------+-------+-------+
%  |.......|%%%%%%%|*******|   |       |       |       |
%  |...o...|%%%o%%%|***o***|   |   o.%..%%%o%%%%***o   |
%  |.......|%%%%%%%|*******|   |    ...%%%%%%%%%****   |
%  +-------+-------+-------+   +----.,.,\%\%\\%\#*#*---+
%  |,,,,,,,|\\\\\\\|#######|   |    ,,,\\\\\\\\\####   |
%  |,,,o,,,|\\\o\\\|###o###|   |   o ,\,\\\o\\\\###o   |
%  |,,,,,,,|\\\\\\\|#######|   |       |       |       |
%  +-------+-------+-------+   +-------+-------+-------+
%
%  surf(..,edgecolor)
%
%  where edgecolor is the color (rgbcymkw or rgb triplet)
%  of the gridlines. By default the grid lines are not
%  drawn but interpolated with the data as described above.
%
%  Note that when plotting a 3x1 z or c matrix, the z or c
%  value is interpreted as an rgb triplet. In this specific case
%  set the line colors with set(...) after calling surfcorcen.
%
%  Note that only for colors flat or interp can be chosen,
%  z values of the surface are always interpolated and should
%  have the size of x and y (no piecewise continuous tiles).
%
% See also:
% PCOLORCORCEN, PCOLOR, MPCOLOR, MSURF, SET
%

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@citg.tudelft.nl
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   Modified by Bart Grasmeijer (Alkyon) on 18 August 2009:
%   added optional arguments: edgecolor, facecolor, edgealpha, facealpha,
%   alphadata
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

edgecolor = nan;
facecolor = nan;
edgealpha = 1;
facealpha = 1;
alphadata = 1;
alphadatamapping = 'scaled';

%% Handles input and directly plot cases where
%% x and y are NOT specified
%% -------------------------------------------

%% surf(z);
%% ------------------

nargin02 = nargin;

%% optional arguments
optvals = varargin;
for i=1:length(optvals),
    if ischar(optvals{i})
        a = optvals{i};
        switch lower(optvals{i}),
            case 'facealpha',
                facealpha = optvals{i+1};
                nargin02 = nargin02-2;
            case 'alphadata',
                alphadata = optvals{i+1};
                nargin02 = nargin02-2;                
            case 'facecolor',
                facecolor = optvals{i+1};
                nargin02 = nargin02-2;                
            case 'edgealpha',
                edgealpha = optvals{i+1};
                nargin02 = nargin02-2;                
            case 'edgecolor',
                edgecolor = optvals{i+1};
                nargin02 = nargin02-2;                
            case 'alphadatamapping',
                alphadatamapping = optvals{i+1};
                nargin02 = nargin02-2;                
        end
        
    end
end;

if nargin02==1
    
    z          = squeeze(varargin{1});
    P          = surf(z);
    plot_later = false;
    edgecolor  = 'interp';
    facecolor  = 'interp';
    
    %% surf(z);
    %% surf(z,c);
    %% ------------------
elseif nargin02==2
    
    z             = squeeze(varargin{1});
    if iscolor(varargin{2})
        edgecolor  = varargin{2};
        facecolor  = 'interp';
        P          = surf(z);
        plot_later = false;
    else
        c          = squeeze(varargin{2});
        
        if     (size(c,1)==size(z,1)) &...
                (size(c,2)==size(z,2))
            if isnan(edgecolor)
                edgecolor ='interp';
            end
            if isnan(facecolor)
                facecolor ='interp';
            end
        elseif (size(c,1)==size(z,1)-1) &...
                (size(c,2)==size(z,2)-1)
            c = addrowcol(c,1,1,nan);
            if isnan(edgecolor)
                edgecolor ='flat';
            end
            if isnan(facecolor)
                facecolor ='flat';
            end
        end
        
        P          = surf(z,c);
        plot_later = false;
    end
    
    %% surf(z,c)
    %% surf(x,y,z)
    %% ------------------
elseif nargin02==3
    
    %% surfcorcen(z,c,'r')
    %% surfcorcen(z,c,[.5 .5 .5])
    %% ------------------
    if iscolor(varargin{3})
        z         = squeeze(varargin{1});
        c         = squeeze(varargin{2});
        edgecolor = varargin{3};
        
        if     (size(c,1)==size(z,1)) &...
                (size(c,2)==size(z,2))
            if isnan(facecolor)
                facecolor ='interp';
            end
        elseif (size(c,1)==size(z,1)-1) &...
                (size(c,2)==size(z,2)-1)
            c = addrowcol(c,1,1,nan);
            if isnan(facecolor)
                facecolor ='flat';
            end
        else
            error(' ')
        end
        P          = surf(z,c);
        plot_later = false;
        %% surfcorcen(x,y,z)
        %% ------------------
    else
        x          = squeeze(varargin{1});
        y          = squeeze(varargin{2});
        z          = squeeze(varargin{3});
        c          = z;
        plot_later = true;
    end
    
    %% surf(x,y,z,c)
    %% surf(x,y,z,'r')
    %% surf(x,y,z,[.5 .5 .5])
    %% surf(x,y,z,c,'r')
    %% surf(x,y,z,c,[.5 .5 .5])
    %% ------------------
elseif nargin02>3
    
    x          = squeeze(varargin{1});
    y          = squeeze(varargin{2});
    z          = squeeze(varargin{3});
    plot_later = true;
    
    if nargin02==4
        if iscolor(varargin{4})
            edgecolor = varargin{4};
            c         = z;
        else
            c         = squeeze(varargin{4});
        end % isstr(varargin{4})
    elseif nargin02==5
        c         = squeeze(varargin{4});
        edgecolor = varargin{5};
    end
    
end % nargin02 <>

if plot_later
    
    %% Plot for cases where x and y are specified
    %% -------------------------------------------
    
    if     (size(x,1)==size(y,1) & size(c,1)==size(z,1)) &...
            (size(x,2)==size(y,2) & size(c,2)==size(z,2))
        
        %% values and co-ordinates at corner points
        %% x,y,and c same size
        %% SHADING INTERP
        %% -------------------------------
        if size(x,1)==size(c,1) & ...
                size(x,2)==size(c,2)
            
            P = surf(x,y,z,c);
            if isnan(edgecolor)
                edgecolor ='interp';
            end
            if isnan(facecolor)
                facecolor ='interp';
            end
            
            %% values at center points, co-ordinates at corner points
            %% c in all directions one smaller than x,y
            %% SHADING FLAT
            %% -------------------------------
        elseif size(x,1)==size(c,1)+1 & ...
               size(x,2)==size(c,2)+1;
            
            P = surf(x,y,addrowcol(z,1,1,nan),addrowcol(c,1,1,nan));
            if isnan(edgecolor)
                edgecolor ='flat';
            end
            if isnan(facecolor)
                facecolor ='flat';
            end
            
        else
            error(['surfcorcen(x,y,z,c) sizes x,y,z and c do not match: ',num2str(size(x)),' | ',num2str(size(y)),' | ',num2str(size(z)),' | ',num2str(size(c))])
        end % size(x,1)==size(c,1) & ...
        
    elseif (size(x,1)==size(y,1) & size(c,1)==size(z,1)-1) &...
            (size(x,2)==size(y,2) & size(c,2)==size(z,2)-1)
        
        c = addrowcol(c,1,1,nan);
        
        P = surf(x,y,z,c);
        if isnan(edgecolor)
            edgecolor ='flat';
        end
        if isnan(facecolor)
            facecolor ='flat';
        end
        
    else
        error(['surfcorcen(x,y,z,c) sizes x,y,z and c do not match: ',num2str(size(x)),' | ',num2str(size(y)),' | ',num2str(size(z)),' | ',num2str(size(c))])
    end % (size(x,1)==size(y,1) & size(c,1)==size(z,1)) &...

end % if plot_later

set(P,'alphadata',alphadata);
set(P,'edgecolor',edgecolor);
set(P,'facecolor',facecolor);
set(P,'edgealpha',edgealpha);
set(P,'facealpha',facealpha);
set(P,'alphadatamapping',alphadatamapping);

if nargout==1
    varargout = {P};
end

%%% --------------------------------------------------
%%% --------------------------------------------------
%%% --------------------------------------------------

function OUT = addrowcol(IN,varargin);
%ADDROWCOL
%  addrowcol adds a row and column to an array
% (by default filled with nans).
%
%  WORKS FOR THE MOMENT ONLY FOR 2dimensional ARRAYS!
%  --------------------------------------------------
%
%  out = addrowcol(in,marker) adds a row and column
%  filled with the value of marker.
%
%  out = addrowcol(in,dm,dn) adds dm rows and
%  dm columns with nans.
%
%  out = addrowcol(in,dm,dn,marker) adds dm rows and
%  dm columns with the value of marker.
%
%  If either dm and/or dn is negative, existing
%  rows/columns are shifted by |dn| or |dm|
%  and the first |dn| or |dm| columns are given the
%  value nan (default) or marker.
%
%  Example:
%     addrowcol(ones(2), 1, 1,Inf) yields
%
%          1     1   Inf
%          1     1   Inf
%        Inf   Inf   Inf
%
%     addrowcol(ones(2),-1,-1,Inf)  yields
%
%        Inf   Inf   Inf
%        Inf     1     1
%        Inf     1     1
%

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@citg.tudelft.nl
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   --------------------------------------------------------------------

dm            = 1;
dn            = 1;
illegalmarker = NaN;

if nargin==2
    illegalmarker = varargin{1};
elseif nargin==3
    dm            = varargin{1};
    dn            = varargin{2};
elseif nargin==4
    dm            = varargin{1};
    dn            = varargin{2};
    illegalmarker = varargin{3};
end

OUT = repmat(illegalmarker,size(IN,1)+abs(dm) ,...
    size(IN,2)+abs(dn));

OUT(1-min(dm,0):end-max(dm,0),...
    1-min(dn,0):end-max(dn,0))=IN;
