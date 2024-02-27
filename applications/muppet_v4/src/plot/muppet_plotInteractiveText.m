function h=muppet_plotInteractiveText(handles,i,j,k)

plt=handles.figures(i).figure.subplots(j).subplot;
% nr=plt.datasets(k).dataset.number;
% data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

h=gui_text('plot','x',opt.x,'y',opt.y,'text',opt.text,'tag','interactivetext', ...
    'fontname',opt.font.name,'fontsize',opt.font.size,'fontweight',opt.font.weight,'fontcolor',colorlist('getrgb','color',opt.font.color), ...
    'fontangle',opt.font.angle, ...
    'changecallback',@muppet_changeInteractiveText,'axis',gca);
