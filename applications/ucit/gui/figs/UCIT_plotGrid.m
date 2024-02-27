function plotGrid(X,Y,Z,scheme,d,v)
%UCIT_plotGrid  ucit routine to plot grid information
%
%   Summary:    This routine generates a number of default plots for grids.
%               It takes general X, Y and Z input and contains a number of
%               schemes for plotting morphology, difference maps and
%               contour plots.
%
%   Syntax:     UCIT_plotGrid(X,Y,Z,scheme,datatypeinfo,v)
%
%   Input:      X,Y,Z = matrices with x, y and z values
%               scheme = case identifier indicating a given plot type
%                   1: regular bathymetry plot  - v = [-35 -20 -17.5 -15 -12.5 -10 -7.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5  0 .5 1 2];
%                   2: regular difference plot  - v = [-20 -10 -5:5 10 20]
%                   3: difference per year plot - v = [-1.5 -1 -0.5:0.1:0.5 1 1.5];
%                   4: morphology plot          - v = [-35 -20 -17.5 -15 -12.5 -10 -7.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5  0 .5 1 2];
%                   5: difference maps          - v = [-7.5 -5 -4 -3 -2 -1 -.25 0 .25 1 2 3 4 5 7.5];
%                   6: contours                 - v = [-3 -3 -2 -2];
%                   7: map of datenums - v is unique(Z) is not specified
%               v = vector containing countour or class information (only for scheme 6)
%
%   Output:     no output
%
%   See also UCIT_plotDataInPolygon
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld       
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
%       Ben.deSonneville@Deltares.nl	
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

% default colorscheme is set to 1
if nargin == 3
    scheme = 1;
end

% a landboundary file is plotted first
nameInfo=['UCIT - Grid plot'];
if nargin >= 5
    if isempty(findobj('tag','gridPlot'))
        fh=figure('tag','gridPlot'); clf; ah=axes;
        set(fh,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
        [fh,ah] = UCIT_prepareFigureN(0, fh, 'UL', ah);
        hold on
        UCIT_plotLandboundary(d.ldb,'none')
    else
        mapW=findobj('tag','gridPlot');
        figure(mapW); set(mapW,'CurrentObject',mapW);
        hold on
    end
end

set(gcf,'renderer','zbuffer')

% next one of the preset schemes is applied
switch  scheme
    case 1 % regular bathymetry plot
        thinning = 1;
%         sh = pcolor(X(1:thinning:end,1:thinning:end),Y(1:thinning:end,1:thinning:end),Z(1:thinning:end,1:thinning:end)); axis equal; shading interp; view(2)
        sh = surf(X(1:thinning:end,1:thinning:end),Y(1:thinning:end,1:thinning:end),Z(1:thinning:end,1:thinning:end));
        axis equal; shading interp; view(2);colorbar;axis equal;
%         colormap(colormap_cpt('bathymetry_vaklodingen',200));
        clim([-50 25]);
        lightangle(-180,60);material([.7 .3 0.2]);lighting phong
       

        if nargin ==6
            if length(v)==1
                v=[v(1) - 1 v];
            end
            caxis([min(v) max(v)])
            classbar(colorbar,v,'labelcolor','plotall','%4.2f')
        else
            colorbar
        end
        
    case 2 % regular difference plot
        v = [-20 -10 -5:5 10 20];
        thinning=ceil(max(size(X))/600);
        [CS HS] = contourfcorr(X(1:thinning:end,1:thinning:end),Y(1:thinning:end,1:thinning:end),Z(1:thinning:end,1:thinning:end),v);
        set(HS,'edgecolor','none')
        caxis([min(v) max(v)])
        classbar(colorbar,v,'labelcolor','plotall')
        axis equal

    case 3 % difference per year plot
        v = [-1.5 -1 -0.5:0.1:0.5 1 1.5];
        thinning=ceil(max(size(X))/600);
        [CS HS] = contourfcorr(X(1:thinning:end,1:thinning:end),Y(1:thinning:end,1:thinning:end),Z(1:thinning:end,1:thinning:end),v);
        set(HS,'edgecolor','none')
        caxis([min(v) max(v)])
        classbar(colorbar,v,'labelcolor','plotall')
        axis equal

    case 4 % morphology plot
        % default color scheme developed by Edwin Elias (VOP LT)
        if nargin ~=6
            v = [-35 -20 -17.5 -15 -12.5 -10 -7.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5  0 .5 1 2];
            clrmap(UCIT_colorscheme4);
        end
        thinning=1; %thinning=ceil(max(size(X))/200);
        [CS HS] = contourfcorr(X(1:thinning:end,1:thinning:end),Y(1:thinning:end,1:thinning:end),Z(1:thinning:end,1:thinning:end),v);
        set(HS,'edgecolor','none')

        %---plot classbar for data chronology plot with only 1 unique date (PKT 14-03-2007)
        if min(v)==max(v);
            caxis([(max(v)-1) max(v)]);
        else
            caxis([min(v) max(v)]);
        end

        %caxis([min(v) max(v)])
        classbar(colorbar,v,'%1.6g','labelcolor','plotall')
        axis equal

    case 5 % difference maps
        v = [-7.5 -5 -4 -3 -2 -1 -.25 0 .25 1 2 3 4 5 7.5];
        clrmap(UCIT_colorscheme5);  %sedimentatie erosie
        thinning=ceil(max(size(X))/600);
        pcolor(X(1:thinning:end,1:thinning:end),Y(1:thinning:end,1:thinning:end),Z(1:thinning:end,1:thinning:end));
        caxis([min(v) max(v)])
        classbar(colorbar,v,'labelcolor','plotall')
        axis equal

    case 6 % contours
        if nargin ~=6
            v = [-3 -3 -2 -2];
        end
        thinning=1;
        [C,H] = contour(X(1:thinning:end,1:thinning:end),Y(1:thinning:end,1:thinning:end),Z(1:thinning:end,1:thinning:end),v);
        if length(unique(v))==1
            set(H,'linecolor','k','linewidth',1.5)
        end
        axis equal
    case 7
        
        %% find unique date values
        if nargin < 6
        v = unique(Z(find(~isnan(Z))))
        end
        %if length(v)==1;v=[v(1) - 1 v];end
        nv = length(v);

        if nv == 0
            warning('no data found: only selection polygon plotted')
        end

        % make matrix so you can plot index of unique values
        V=Z;
        for iv=1:nv
            mask = (Z==v(iv));
            V(mask)=iv;
        end

        % plot
        pcolorcorcen(X,Y,V);
        hold on;

        % layout
        if nv > 0
            caxis   ([1-.5 nv+.5])
            colormap(jet(nv));
            [ax,c1] =  colorbarwithtitle('',1:nv+1); %#ok<NASGU>
            set(ax,'yticklabel',datestr(v,29))
        end
        axis equal
end


box  on
set(gcf,'renderer','zbuffer')
set(gca,'fontsize', 8 );
%ylabel('Northing [m]');
%xlabel('Easting [m]');
