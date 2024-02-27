function nice_pictures(XB,zs,zb,t,houses,view1,view2)
if ~exist('view1','var')
    view1 = -29;
    view2 = 56;
end

% Has a figure already been set up?
s1 = findobj('tag','bedsurface');
s2 = findobj('tag','watersurface');
s3 = findobj('tag','houses');


if isempty(s1)
    opengl software
    zs(zs<=zb+0.05)=NaN;
    s1=surf(XB.x,XB.y,zb); hold on
    s3=surf(XB.x,XB.y,houses); 
    C = del2(zs);
    s2=surf(XB.x,XB.y,zs,C); shading interp;hold off
    set(s3,'facelighting','gouraud','AmbientStrength',1,'facecolor',[0.5,0.5,0.5]);
    set(s3,'tag','houses');
    set(s2,'SpecularColorReflectance',0.9,'SpecularExponent',8,'SpecularStrength',0.6);
    set(s2,'facelighting','gouraud','AmbientStrength',1,'facealpha',0.6,'facecolor',[0 0.4 0.9]);
    set(s2,'tag','watersurface');
    set(s1,'facelighting','gouraud','AmbientStrength',0.8,'SpecularColorReflectance',0.6,'SpecularExponent',100,'SpecularStrength',0.2);
    set(s1,'tag','bedsurface');
    light('position',[0 0 20]);
    colormap copper;
    if exist('cax','var')
        caxis(cax);
    else
        caxis([-1.5 1])
    end
    view(view1,view2);
    set(gcf,'Renderer','OpenGL');
    grid off
    axis off
else
    zs(zs<=zb+0.05)=NaN;
    C = del2(zs);
    set(s1,'Cdata',zb,'Zdata',zb);
    set(s2,'Cdata',C,'Zdata',zs);
    set(s3,'Zdata',houses);
end
title([num2str((t)/3600,'% 4.1f') ' hours']);
