function h=muppet_plotInteractivePolyline(handles,i,j,k)

plt=handles.figures(i).figure.subplots(j).subplot;
% nr=plt.datasets(k).dataset.number;
% data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

usd=[i,j,k];

if opt.fillclosedpolygons
    facecolor=colorlist('getrgb','color',opt.fillcolor);
else
    facecolor='none';
end

if handles.figures(i).figure.export
    % Exporting
    if strcmpi(opt.marker,'none')    
        opt.marker='';
    end
else
    % Plotting
    if strcmpi(opt.marker,'none')    
        opt.marker='o';
        opt.markersize=4;
    end
end

h=gui_polyline('plot','x',opt.x,'y',opt.y,'tag','interactivepolyline','marker',opt.marker, ...
    'changecallback',@muppet_changeInteractivePolygon,'axis',gca, ...
    'markersize',opt.markersize,'markeredgecolor',colorlist('getrgb','color',opt.markeredgecolor), ...
    'markerfacecolor',colorlist('getrgb','color',opt.markerfacecolor), ...
    'linewidth',opt.linewidth,'linecolor',colorlist('getrgb','color',opt.linecolor),'linestyle',opt.linestyle, ...
    'facecolor',facecolor, ...
    'arrowthickness',opt.arrowthickness,'headthickness',opt.headthickness,'headlength',opt.headlength, ...
    'nrheads',opt.nrheads,'userdata',usd, ...
    'type',opt.polylinetype,'closed',opt.closepolygons,'fillpolygon',opt.fillclosedpolygons);
