function handles=PlotPolygon3D(handles,i,j,k,mode)
 
Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);
 
x=Data.x;
y=Data.y;
 
polno=1;
jj=1;
for ii=1:size(x,1);
    if (isnan(x(ii)))
        polno=polno+1;
        jj=1;
    else
        ldb{polno}(jj,1)=x(ii);
        ldb{polno}(jj,2)=y(ii);
        jj=jj+1;
    end
end
 
if isnan(x(end))
    polno=polno-1;
end
 
if strcmp(mode,'new')
    for ii=1:polno
%         xldb(1,:)=ldb{ii}(:,1)';
%         xldb(2,:)=ldb{ii}(:,1)';
%         yldb(1,:)=ldb{ii}(:,2)';
%         yldb(2,:)=ldb{ii}(:,2)';
%         zldb(1,:)=zeros(size(xldb(1,:)))+Plt.Elevations(1);
%         zldb(2,:)=zeros(size(xldb(1,:)))+Plt.Elevations(2);
%         ldbplt=surf(xldb,yldb,zldb);hold on;
%         p=patch(xldb(2,:),yldb(2,:),zldb(2,:),FindColor(Plt.FillColor));
%         SetObjectData(ldbplt,i,j,k,'3dpolygon');
%         SetObjectData(p,i,j,k,'3dpolygon2');
%         clear xldb
%         clear yldb
%         clear zldb

    
        
        xx=ldb{ii}(:,1);
        yy=ldb{ii}(:,2);
        nx=length(xx);

        zz=zeros(size(xx))+Plt.Elevations(1);
        zz=[zz;zeros(size(xx))+Plt.Elevations(2)];

        xx=[xx;xx];
        yy=[yy;yy];

        vtcs=[xx yy zz];
        
        for jj=1:nx-1
            fcs(jj,:)=[jj jj+1 jj+nx+1 jj+nx];
        end

        ldbplt=patch('vertices',vtcs,'faces',fcs);
        
        xldb(1,:)=ldb{ii}(:,1)';
        xldb(2,:)=ldb{ii}(:,1)';
        yldb(1,:)=ldb{ii}(:,2)';
        yldb(2,:)=ldb{ii}(:,2)';
        zldb(1,:)=zeros(size(xldb(1,:)))+Plt.Elevations(1);
        zldb(2,:)=zeros(size(xldb(1,:)))+Plt.Elevations(2);
        
%         ldbplt=surf(xldb,yldb,zldb);hold on;
        p=patch(xldb(2,:),yldb(2,:),zldb(2,:),FindColor(Plt.FillColor));
        SetObjectData(ldbplt,i,j,k,'3dpolygon');
        SetObjectData(p,i,j,k,'3dpolygon2');
        clear xldb
        clear yldb
        clear zldb
    
    
        set(ldbplt,'EdgeColor','none');
        set(ldbplt,'FaceLighting','gouraud','FaceColor',FindColor(Plt.FillColor));
        set(p,'FaceColor',FindColor(Plt.FillColor),'EdgeColor','none');
        set(p,'FaceLighting','none');

    
    end
else
    ldbplt=findobj(gcf,'Tag','3dpolygon','UserData',[i,j,k]);
    p=findobj(gcf,'Tag','3dpolygon2','UserData',[i,j,k]);
end



