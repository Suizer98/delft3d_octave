function handles=PlotVectorMagnitude(handles,i,j,k,mode)
 
DeleteObject(i,j,k);

Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);
 
col=[Ax.CMin:Ax.CStep:Ax.CMax];
 
ncol=size(col,2)-1;
clmap=GetColors(handles.ColorMaps,Ax.ColMap,ncol);
 
c1=col(1);
c2=col(end);
 
z=sqrt(Data.u.^2 + Data.v.^2);
 
zz1=max(z,c1);
zz1=min(zz1,c2);
zz1(isnan(Data.u))=NaN;
 
x=Data.x;
y=Data.y;
 
xmean=mean(x(isfinite(x)));
ymean=mean(y(isfinite(y)));
 
x(isnan(x))=xmean;
y(isnan(y))=ymean;
 
[c,h,wb]=contourf_mvo(x,y,zz1,col);

SetObjectData(h,i,j,k,'vectormagnitude');
SetObjectData(wb,i,j,k,'vectormagnitude');
 
hold on;
