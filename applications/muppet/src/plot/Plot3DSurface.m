function handles=Plot3DSurface(handles,i,j,k,mode)

Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);

col=Ax.CMin:Ax.CStep:Ax.CMax;
 
clmap=GetColors(handles.ColorMaps,Ax.ColMap,64);
colormap(clmap);

x=Data.x;
y=Data.y;
z=Data.z;
z(x<Ax.XMin)=NaN;
z(x>Ax.XMax)=NaN;
z(y<Ax.YMin)=NaN;
z(y>Ax.YMax)=NaN;
z(z<Ax.ZMin)=NaN;
z(z>Ax.ZMax)=NaN;

z=z*Ax.DataAspectRatio(3);

if strcmp(mode,'new')
    dpplot=surf(x,y,z);
    SetObjectData(dpplot,i,j,k,'3dsurface');
else
    dpplot=findobj(gcf,'Tag','3dsurface','UserData',[i,j,k]);
end

set(dpplot,'FaceColor',Plt.Shading);

if Plt.Draw3DGrid
    set(dpplot,'EdgeColor',FindColor(Plt.LineColor));
    set(dpplot,'LineWidth',0.2);
else
    set(dpplot,'EdgeColor','none');
end

caxis([col(1) col(end)]);

set(dpplot,'FaceLighting','phong');
 
if Plt.OneColor==1
    x=Plt.Color;
%    set(dpplot,'FaceColor',FindColor(Plt.Color));
    set(dpplot,'FaceColor',Plt.Color);
end

set(dpplot,'ambientstrength',Ax.LightStrength);
set(dpplot,'specularstrength',Plt.SpecularStrength);
set(dpplot,'SpecularColorReflectance',1);
set(dpplot,'SpecularExponent',100);

if Plt.Transparency<1
    set(dpplot,'EdgeAlpha',Plt.Transparency);
    set(dpplot,'FaceAlpha',Plt.Transparency);
end

hold on;
