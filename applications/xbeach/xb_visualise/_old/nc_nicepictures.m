function nc_nicepictures(url,t,nebed,tide)

nc_check;

% retrieve data
my = 3; mx = 150;
xb = nc_getdimensions(url);
x = nc_varget(url,'x',[mx],[xb.nx-mx-my+1]);
y = nc_varget(url,'y',[my],[xb.ny-2*my+1]);
zb = nc_varget(url,'zb',[t my mx],[1 xb.ny-2*my+1 xb.nx-mx-my+1]);
zs = nc_varget(url,'zs',[t my mx],[1 xb.ny-2*my+1 xb.nx-mx-my+1]);

timeax = xb.tsglobal/3600/24;
timeax(timeax>1e10) = nan;

houses = nan(size(zb));
if exist('nebed','var')
    if exist(nebed,'file')
        ne_bed = load(nebed);
        ne_bed = ne_bed(my:end-my-1,mx:end-my-1);
        houses(ne_bed'==0) = zb(ne_bed'==0)+1;
        for i = 2:length(y)-1
            for j = 2:length(x)-1
                if ne_bed(i-1,j)==0 || ne_bed(i+1,j)==0 || ...
                    ne_bed(i,j-1)==0 || ne_bed(i,j+1)==0 || ...
                    ne_bed(i-1,j-1)==0 || ne_bed(i-1,j+1)==0 || ...
                    ne_bed(i+1,j-1)==0 || ne_bed(i+1,j+1)==0
                    houses(i,j) = zb(i,j)+1;
                end
            end
        end
    end
end

wl = nan(size(xb.tsglobal));
if exist('tide','var')
    if exist(tide,'file')
        wl = load(tide);
        wl = wl(:,1:2);
        wl(:,1) = wl(:,1)/3600/24;
    end
end

% figure already set up?
s1 = findobj('tag','bedsurface');
s2 = findobj('tag','watersurface');
s3 = findobj('tag','houses');
s4 = findobj('tag','waterlevel');

if isempty(s1)
    opengl software
    
    zs(zs<=zb+0.05)=NaN;
    C = del2(zs);
    
    figure;
    subplot(4,1,[1 3]);
    s1=surf(x,y,zb); hold on;
    s3=surf(x,y,houses);
    s2=surf(x,y,zs,C); shading interp; hold off;
    
    set(s3,'facelighting','gouraud','AmbientStrength',1,'facecolor',[0.5,0.5,0.5]);
    set(s3,'tag','houses');
    set(s2,'SpecularColorReflectance',0.9,'SpecularExponent',8,'SpecularStrength',0.6);
    set(s2,'facelighting','gouraud','AmbientStrength',1,'facealpha',0.6,'facecolor',[0 0.4 0.9]);
    set(s2,'tag','watersurface');
    set(s1,'facelighting','gouraud','AmbientStrength',0.8,'SpecularColorReflectance',0.6,'SpecularExponent',100,'SpecularStrength',0.2);
    set(s1,'tag','bedsurface');
    
    light('position',[0 0 20]);
    colormap copper;
    caxis([-1.5 1])
    
%     view(-90,90);
%     set(gca,'XLim',[4000 5300])
%     set(gca,'YLim',[3000 4800])
%     view(-90,90);
%     set(gca,'XLim',[4000 5300])
%     set(gca,'YLim',[1800 3400])
%     view(-29,56);
%    view(-20,60);
    view(-160,80);
    
    set(gcf,'Renderer','OpenGL');
    grid off; axis off;
    
    subplot(4,1,4);
    plot(wl(:,1),wl(:,2),'-k'); hold on;
    s4 = plot(timeax(t+1),interp1(wl(:,1),wl(:,2),timeax(t+1)),'or');
    set(s4,'tag','waterlevel');
    datetick('x');
    set(gca,'XLim',wl([1 end],1));
else
    xlim = get(gca,'XLim');
    ylim = get(gca,'YLim');
    zlim = get(gca,'ZLim');
    clim = get(gca,'CLim');
    
    zs(zs<=zb+0.05)=NaN;
    C = del2(zs);
    
    set(s1,'Cdata',zb,'Zdata',zb);
    set(s2,'Cdata',C,'Zdata',zs);
    set(s3,'Zdata',houses);
    set(s4,'Xdata',timeax(t+1),'Ydata',interp1(wl(:,1),wl(:,2),timeax(t+1)));
    
    set(gca,'XLim',xlim);
    set(gca,'YLim',ylim);
    set(gca,'ZLim',zlim);
    set(gca,'CLim',clim);
end

%title([num2str((xb.tsglobal(t))/3600,'% 4.1f') ' hours']);