function [succes] = plotMap_1D(xvalues,yvalues, cvalues, colormap, limit, facealpha)
% Function that allows plotting lines of Delft3D-FM

% Pre-step: find correct
cwanted = linspace(limit(1), limit(2), length(colormap));

for ii = 1:length(cvalues)
    idfind      = near(cwanted,cvalues(ii));
    idwanted    = ~isnan(xvalues(ii,:));
    hfill(ii)   = fill(xvalues(ii,idwanted), yvalues(ii,idwanted),colormap(idfind,:), 'LineStyle','none', 'Facealpha', facealpha);
end

% Done
succes = 1;

