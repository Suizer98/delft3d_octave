function plotXB2D(fig,xdata,ydata,tdata,zdata,names,climin,colmap)

figure(fig);hold on;

nvar=size(zdata);
if length(nvar)==4
    nvar=nvar(4);
else
    nvar=1;
end

spsizes= [ 1  1;
           1  2;
           2  2;
           2  2;
           2  3;
           2  3;
           3  3;
           3  3;
           3  3;
           3  4;
           3  4;
           3  4;
           4  4;
           4  4;
           4  4;
           4  4  ];

spr=spsizes(nvar,1);
spc=spsizes(nvar,2);

set(fig,'Name',['Output after ' num2str(tdata(1)) ' s']);

for i=1:nvar;
    sp(i)=subplot(spr,spc,i);
    axpos(i,:)=get(sp(i),'position');
end

delete(sp);

for i=1:nvar
    AX(i)=axes('position',axpos(i,:));
    p(i)=pcolor(xdata,ydata,squeeze(zdata(:,:,1,i)));
    shading flat;
    if strcmpi(climin{i},'auto')
        caxis auto
    else
        caxis(climin{i});
    end
    cl(i,:)=caxis;
    title(names{i});
    xlabel('x (m)');
    ylabel('y (m)');
    colormap(colmap{i});
    freezeColors(AX(i));
    axis equal
    
    cbtemp=colorbar('location','south');
    cbpos=get(cbtemp,'position');
    delete(cbtemp);
    cb(i)=axes('position',[cbpos(1) cbpos(2) cbpos(3)/2 cbpos(4)/2]);
    xcb=[cl(i,1) : (cl(i,2)-cl(i,1))/200 : cl(i,2);
         cl(i,1) : (cl(i,2)-cl(i,1))/200 : cl(i,2)];
    zcb=[cl(i,1) : (cl(i,2)-cl(i,1))/200 : cl(i,2);
         cl(i,1) : (cl(i,2)-cl(i,1))/200 : cl(i,2)]; 
    ycb=[ ones(1,201);
         zeros(1,201)];
    cbp(i)=pcolor(xcb,ycb,zcb);shading flat;
    caxis(cl(i,:));
    colormap(colmap{i});
    set(cb(i),'ytick',[],'box','on','XAxisLocation','top');
    axis tight
    freezeColors(cb(i));
  
end



for i=1:length(tdata)
    set(fig,'Name',['Output after ' num2str(tdata(i)) ' s']);
    for ii=1:nvar
        axes(AX(ii));
        colormap(colmap{ii});
        set(p(ii),'cdata',squeeze(zdata(:,:,i,ii)));
        freezeColors(AX(ii));
%         set(p(ii),'zdata',squeeze(zdata(:,:,i,ii)));
        if strcmpi(climin{ii},'auto')
            caxis([min(min(squeeze(zdata(:,:,i,ii)))) max(max(squeeze(zdata(:,:,i,ii))))]);
            cl(ii,:)=caxis;
            xcb=[cl(ii,1) : (cl(ii,2)-cl(ii,1))/200 : cl(ii,2);
                 cl(ii,1) : (cl(ii,2)-cl(ii,1))/200 : cl(ii,2)];
            zcb=[cl(ii,1) : (cl(ii,2)-cl(ii,1))/200 : cl(ii,2);
                 cl(ii,1) : (cl(ii,2)-cl(ii,1))/200 : cl(ii,2)];
            axes(cb(ii));
            set(cbp(ii),'xdata',xcb,'cdata',zcb,'zdata',zcb);
            caxis(cl(ii,:));
            xlim([cl(ii,1) cl(ii,2)])
            set(cb(ii),'xtick',[cl(ii,1) (cl(ii,1)+cl(ii,2))/2 cl(ii,2)],'xticklabel',num2str([cl(ii,1);(cl(ii,1)+cl(ii,2))/2;cl(ii,2)],'%5.2f'));
            freezeColors(cb(ii));
        else
            caxis(climin{ii});
            axes(cb(ii));
        end
    end
    pause(.5)
end



