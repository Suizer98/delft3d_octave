function muppet_UIAddText(varargin)

handles=getHandles;

muppet_setPlotEdit(0);

fig=getappdata(gcf,'figure');
ifig=fig.number;

n=0;
for j=1:fig.nrsubplots
    if strcmpi(fig.subplots(j).subplot.type,'map')
        n=n+1;
        h(n)=findobj(gcf,'Tag','axis','UserData',[ifig,j]);
    end
end

opt=muppet_setDefaultPlotOptions;


% Open GUI for text
s.text='txt';
[s,ok]=gui_newWindow(s, 'xmldir', handles.xmlguidir, 'xmlfile', 'interactivetext.xml','iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
if ok
    gui_text('draw','text',s.text,'tag','interactivetext','marker','o', ...
        'createcallback',@addText, ...
        'changecallback',@muppet_changeInteractiveText,'axis',h, ...
        'markersize',opt.markersize,'markeredgecolor',colorlist('getrgb','color',opt.markeredgecolor), ...
        'markerfacecolor',colorlist('getrgb','color',opt.markerfacecolor), ...
        'font',opt.font);
end

%%
function addText(h,x,y)

fig=getappdata(gcf,'figure');
ifig=fig.number;
options=getappdata(h,'options');

% Find subplot number
hax=getappdata(h,'axis');
hh=get(hax,'UserData');
isub=hh(2);

plt=fig.subplots(isub).subplot;
plt.annotationsadded=1;

plt.nrdatasets=plt.nrdatasets+1;
nrd=plt.nrdatasets;
opt=muppet_setDefaultPlotOptions;

if strcmpi(plt.coordinatesystem.type,'geographic')
    switch plt.projection
        case{'mercator'}
            y=invmerc(y);
        case{'albers'}
            [x,y]=albers(x,y,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
    end
end

opt.x=x;
opt.y=y;
opt.rotation=0;
opt.curvature=0;
opt.text=options.text;
opt.type='interactivetext';
opt.plotroutine='interactive text';
opt.name=options.text;

fig.subplots(isub).subplot=plt;

fig.subplots(isub).subplot.datasets(nrd).dataset=opt;

usd=[ifig,isub,nrd];
options.userdata=usd;
setappdata(h,'options',options);

fig.changed=1;

setappdata(gcf,'figure',fig);

%%
function gettextposition(imagefig, varargins,h) 

set(gcf, 'windowbuttonmotionfcn',[]);

if strcmp(get(gcf,'SelectionType'),'normal')

    fig=getappdata(gcf,'figure');
    ifig=fig.number;
    
    % Find subplot number
    hax=gca;
    hh=get(hax,'UserData');
    isub=hh(2);
    
    pos = get(h, 'CurrentPoint');
    xi0=pos(1,1);
    yi0=pos(1,2);

    plttmp=plot(xi0,yi0,'k+');
        
    plt=fig.subplots(isub).subplot;
    switch plt.projection
        case{'mercator'}
            yi=invmerc(yi0);
        case{'albers'}
            [xi,yi]=albers(xi0,yi0,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
        otherwise
            xi=xi0;
            yi=yi0;
    end

    % Add dataset to subplot
    n=fig.subplots(isub).subplot.nrdatasets+1;
    fig.subplots(isub).subplot.nrdatasets=n;
    
    fig.subplots(isub).subplot.datasets(n).dataset=muppet_setDefaultPlotOptions;
    fig.subplots(isub).subplot.datasets(n).dataset.plotroutine='plotinteractivetext';
    fig.subplots(isub).subplot.datasets(n).dataset.font.name='Helvetica';
    fig.subplots(isub).subplot.datasets(n).dataset.font.size=8;
    fig.subplots(isub).subplot.datasets(n).dataset.font.weight='normal';
    fig.subplots(isub).subplot.datasets(n).dataset.font.angle='normal';
    fig.subplots(isub).subplot.datasets(n).dataset.font.color='black';
    fig.subplots(isub).subplot.datasets(n).dataset.type='interactivetext';

    fig.changed=1;
    fig.subplots(isub).subplot.annotationsadded=1;

     delete(plttmp);
     h=text(xi0,yi0,'abc');
     setappdata(h,'axis',gca);
     setappdata(h,'text','abc');
     setappdata(h,'x',xi);
     setappdata(h,'y',yi);
     setappdata(h,'rotation',0);
     setappdata(h,'curvature',0);
     set(h,'Tag','interactivetext');

     usd=[ifig,isub,n];
     options.userdata=usd;
     setappdata(h,'options',options);
     
     fig.subplots(isub).subplot.annotationsadded=1;

     setappdata(gcf,'figure',fig);
     
end

set(gcf, 'windowbuttondownfcn','');
set(gcf,'Pointer','arrow');

% %%
% 
% function movemouse(imagefig, varargins)
% 
% handles=getHandles;
% 
% ifig=get(gcf,'UserData');
% fig=getappdata(gcf,'figure');
% 
% posgcf = get(gcf, 'CurrentPoint')/fig.cm2pix;
% 
% typ='none';
% 
% for j=1:fig.nrsubplots
%     h0=findobj(gcf,'Tag','axis','UserData',[ifig,j]);
%     if ~isempty(h0)
%         pos=get(h0,'Position')/fig.cm2pix;
%         if posgcf(1)>pos(1) && posgcf(1)<pos(1)+pos(3) && posgcf(2)>pos(2) && posgcf(2)<pos(2)+pos(4)
%             typ=fig.subplots(j).subplot.type;
%             h=h0;
%         end
%     end
% end
% 
% oktypes={'map'};
% ii=strmatch(lower(typ),oktypes,'exact');
% 
% if isempty(ii)
%     set(gcf,'Pointer','arrow');
%     set(gcf,'WindowButtonDownFcn',[]);
% else
%     set(gcf, 'Pointer', 'crosshair');
%     set(gcf, 'windowbuttondownfcn', {@gettextposition,h});
% end
