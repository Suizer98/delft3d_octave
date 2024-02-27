function plot_xyColor(x,y,z,themarkersize,varargin)
%   PLOT_XYCOLOR plots three dimensional information into a cartesian plane
%   by drawing the third dimension as a colormap. The results are similar to
%   the ones in SCATTER. Nevertheless this implementation is considerably
%   less computationally demanding, as it only takes into account a 64
%   dimensional colormap. 
%   
%   PLOT_XYCOLOR(X,Y,Z,themarkersize). Vectors X,Y,Z are all of the same
%   size and Z is plotted as color. The markersize determines specifies the
%   size of the marker in the plot(...,'markersize',themarkersize).
%   
%   PLOT_XYCOLOR(X,Y,Z,themarkersize,colormap). Optionally, the colormap
%   may be provided.
%
%   See also: scatter, scatter3, plot, plotmatrix

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   Created by Ivan Garcia
%   email: ivan.garcia@deltares.com
    
    if nargin > 4
        thelineS = varargin{1};
        colormap(thelineS);
    else
        thelineS = colormap;
    end
    
    if nargin > 5
        if strcmpi(varargin{2},'clim')  
            minZ = varargin{3}(1);
            maxZ = varargin{3}(2);
        end
    else
        minZ = min(z);
        maxZ = max(z);
    end
    
    hold on;
    
    if minZ == maxZ
        thecolors = ones(length(z),1);
    else
        thecolors = fix((z - minZ)/(maxZ - minZ)*length(thelineS-1));
        thecolors(thecolors < 1) = 1;
        thecolors(thecolors > 64) = 64;
    end
    
    for icolor = 1:1:length(thelineS), 
        plot( x(thecolors == icolor), ...
              y(thecolors == icolor), ...
              '.', ...
              'color', thelineS(icolor,:), ...
              'markersize', ...
              themarkersize); 
    end
    
    if minZ ~= maxZ
        clim([minZ maxZ]);
    else
        clim([maxZ maxZ+1]);
    end
    hold off;
end