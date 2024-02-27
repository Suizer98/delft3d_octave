function output=tropical_cyclone_selector(varargin)

if ~isempty(varargin)
    % Check if script is called for the first time
    if isstruct(varargin{1})
        inp=varargin{1};
        varargin=[];
    end
end

if isempty(varargin)

    h=[];                    
    
    if ~isfield(inp,'path')
        xmldir=fileparts(which('tropical_cyclone_selector'));
    else
        xmldir=inp.path;
    end
    
    xmlfile='tropical_cyclone_selector.xml';
    
    [h,ok]=gui_newWindow(h,'xmlfile',xmlfile,'xmldir',xmldir,'createcallback',@initialize,'createinput',inp,'modal',0,'zoom',0);
    
    if ok
        iac=h.storm_number(h.active_storm);
        output=h.all_cyclones(iac);
    else
        output=[];
    end
    
else
    
    %Options selected    
    h=gui_getUserData(gcf);
    opt=lower(varargin{1});
    switch opt
        case{'change_search_window'}
            h=change_search_window(h);
        case{'select_cyclone_from_list'}
            h=select_cyclone_from_list(h);
    end    
    h=plot_cyclones(h);
    gui_setUserData(h);
    gui_updateWindow;    
end

%%
function initialize(varargin)

h=gui_getUserData(gcf);

inp=varargin{1};

% Load all cyclones
% s=load(['d:\delftdashboard\data\toolboxes\TropicalCyclone\hurricanes.mat']);

h.basins={'All','AL','EP'};

% Set defaults
h.basin=inp.basin;
h.year_range=inp.year_range;
h.distance=inp.search_radius; % km
h.vmax_range=inp.vmax_range;
h.xp=inp.x;
h.yp=inp.y;

h.all_cyclones=inp.all_cyclones;

h.storm_names={''};
h.active_storm=1;

fid=tekal('open',inp.polfile);
data=tekal('read',fid);
for ipol=1:length(data)
    x=data{ipol}(:,1);
    y=data{ipol}(:,2);
    p=patch(x,y,'r');
    set(p,'FaceColor',[0.5 1 0.5]);
    set(p,'LineStyle','none');
    hold on
end
%[x,y]=landboundary('read',inp.polfile);
%h.xldb=x;
%h.yldb=y;

set(gca,'color',[0.5 0.5 1]);

h=change_search_window(h);

h=plot_cyclones(h);

ax=findobj(gcf,'tag','cyclonemap');

xl=[h.xp-5 h.xp+5];
yl=[h.yp-5 h.yp+5];
[xl,yl]=zoom_to(ax,xl,yl,'geographic');

gui_setUserData(h);

gui_updateWindow;

%%
function h=change_search_window(h)

n=0;

ntc=length(h.all_cyclones);

if isfield(h,'near_cyclones')
    h=rmfield(h,'near_cyclones');
end

h.storm_names={''};

% h.near_cyclones=[];

for itc=1:ntc
    %
    ok=1;
    %
    % Basin
    %
    if ~strcmpi(h.basin,h.all_cyclones(itc).basin)
        ok=0;
        continue
    end
    %
    % Distance
    %
    xt=h.all_cyclones(itc).x;
    yt=h.all_cyclones(itc).y;
    dst=sqrt((xt-h.xp).^2+(yt-h.yp).^2);
    dst=nanmin(dst);
    if dst>h.distance/100
        ok=0;
        continue
    end
    %
    % Year
    %
    tvec=datevec(h.all_cyclones(itc).time(1));
    yr=tvec(1);
    if yr<h.year_range(1) || yr>h.year_range(2)
        ok=0;
        continue
    end
    %
    % Vmax
    %
    if h.vmax_range(2)<999.9 || h.vmax_range(1)>0
        
        xt=h.all_cyclones(itc).x;
        yt=h.all_cyclones(itc).y;
        dst=sqrt((xt-h.xp).^2+(yt-h.yp).^2);
%        in=find(dst<h.distance/100);
        vmx=nanmax(h.all_cyclones(itc).vmax(dst<h.distance/100));
%        vmx=max(h.all_cyclones(itc).vmax);
        if vmx<h.vmax_range(1) || vmx>h.vmax_range(2)
            ok=0;
            continue
        end
    end
    
    n=n+1;
    h.near_cyclones(n)=h.all_cyclones(itc);
    h.storm_names{n}=h.all_cyclones(itc).name;
    h.storm_number(n)=itc;
            
end

if n==0
    h.near_cyclones=[];
end

h.active_storm=1;


% h=plot_cyclones(h);

%% 
function h=plot_cyclones(h)

ho=findobj(gca,'tag','track');
delete(ho);
ho=findobj(gca,'tag','point');
delete(ho);
ho=findobj(gca,'tag','searchradius');
delete(ho);

n=length(h.near_cyclones);

if n>0
    for itc=1:n
        if itc~=h.active_storm
            x=h.near_cyclones(itc).x;
            y=h.near_cyclones(itc).y;
            p=plot(x,y,'ko-');
            set(p,'tag','track');
            set(p,'markersize',1);
            set(p,'color','k');
            set(p,'color','k');
            set(p,'linewidth',0.5);
            set(p,'buttondownfcn',@select_track);
            set(p,'userdata',itc);
            hold on
        end
    end
    itc=h.active_storm;
    x=h.near_cyclones(itc).x;
    y=h.near_cyclones(itc).y;
    p=plot(x,y,'ko-');
    set(p,'tag','track');
    set(p,'markersize',1);
    set(p,'color','r');
    set(p,'color','r');
    set(p,'linewidth',2);
    set(p,'buttondownfcn',@select_track);
    set(p,'userdata',itc);
    hold on
end

p=plot(h.xp,h.yp,'bo');
set(p,'tag','point');
set(p,'markersize',10);
set(p,'markerfacecolor','b');
set(p,'markeredgecolor','k');

[xm,ym,utmzone]=deg2utm(h.yp,h.xp);
rr=0:0.01:2*pi;
xc=xm+cos(rr)*h.distance*1000;
yc=ym+sin(rr)*h.distance*1000;
[yc,xc]=utm2deg(xc,yc,utmzone);
pc=plot(xc,yc,'w--');
set(pc,'tag','searchradius','LineWidth',2);


%%
function select_track(imagefig, varargins)


h=gui_getUserData(gcf);

ho=gco;
nr=get(ho,'userdata');

h.active_storm=nr;

h=plot_cyclones(h);

gui_setUserData(h);
    
gui_updateWindow;

% set(ho,'color','r');
% set(ho,'markerfacecolor','r');
% set(ho,'markeredgecolor','r');


% neartc=get(gca,'userdata');


% disp(h.near_cyclones(nr).name)


