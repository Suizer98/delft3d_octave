function h=muppet_plot3DSurface(handles,ifig,isub,id)

h=[];

plt=handles.figures(ifig).figure.subplots(isub).subplot;
nr=plt.datasets(id).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(id).dataset;

if ~plt.usecustomcontours
    col=plt.cmin:plt.cstep:plt.cmax;
else
    col=plt.customcontours;
end

clmap=muppet_getColors(handles.colormaps,plt.colormap,64);
colormap(clmap);

x=data.x;
y=data.y;
z=data.z;

dpplot=surf(x,y,z);

if isfield(data,'rgb')
    if ~isempty(data.rgb)
        set(dpplot,'CData',data.rgb);
        shading flat;
    end
end

set(dpplot,'FaceColor',opt.shading);

if opt.plotgrid
    set(dpplot,'EdgeColor',colorlist('getrgb','color',opt.linecolor));
    set(dpplot,'LineWidth',opt.linewidth);
    set(dpplot,'LineStyle',opt.linestyle);
else
    set(dpplot,'EdgeColor','none');
end

caxis([col(1) col(end)]);

if opt.onecolor==1
    set(dpplot,'FaceColor',colorlist('getrgb','color',opt.color));
end

set(dpplot,'FaceLighting',opt.facelighting);
set(dpplot,'BackFaceLighting',opt.backfacelighting);
set(dpplot,'EdgeLighting',opt.edgelighting);
 
set(dpplot,'ambientstrength',opt.ambientstrength);
set(dpplot,'specularstrength',opt.specularstrength);
set(dpplot,'diffusestrength',opt.diffusestrength);
set(dpplot,'SpecularColorReflectance',opt.specularcolorreflectance);
set(dpplot,'SpecularExponent',opt.specularexponent);

set(dpplot,'EdgeAlpha',opt.edgeopacity);
set(dpplot,'FaceAlpha',opt.faceopacity);

hold on;
