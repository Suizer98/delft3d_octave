function qv=muppet_plotVectors(handles,i,j,k)

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

switch lower(opt.fieldthinningtype)
    case{'none'}
        x=data.x;
        y=data.y;
        u=data.u;
        v=data.v;
    case{'uniform'}
        x=data.x(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor2:end);
        y=data.y(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor2:end);
        u=data.u(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor2:end);
        v=data.v(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor2:end);
end

z=zeros(size(u));
z=z+500;
w=zeros(size(u));

multiy=1.0;
multiv=opt.verticalvectorscaling;

if strcmpi(plt.coordinatesystem.type,'geographic')
    opt.unitvector=opt.unitvector/111111;
end

% % Logarithmic vector scaling
% mag=sqrt(u.^2+v.^2);
% logv=log10(mag);
% logv=logv+8;
% logv=max(logv,0);
% u=u.*logv./mag;
% v=v.*logv./mag;


if strcmpi(opt.plotroutine,'vectors')
    % Regular vectors
    qv=quiver(x,multiy*y,opt.unitvector*u,multiv*opt.unitvector*v,0);hold on;
    set(qv,'Color',colorlist('getrgb','color',opt.vectorcolor));
else
    % Colored vectors
    if ~opt.plotcolorbar
        % Using colormap of subplot
        if ~opt.usecustomcontours
            col=plt.cmin:(plt.cmax-plt.cmin)/64:plt.cmax;
        else
            col=plt.customcontours;
        end
        ncol=size(col,2)-1;
        clmap=muppet_getColors(handles.colormaps,opt.colormap,ncol);
        colormap(clmap);
        caxis([col(2) col(end-1)]);
        qv=quiver3(x,multiy*y,z,opt.unitvector*u,multiv*opt.unitvector*v,w,0);hold on;
        qv=mp_colquiver(qv,sqrt(u.^2+v.^2));
    else
        % Vectors get their own color scaling
        colorfix;
        if ~opt.usecustomcontours
            col=opt.cmin:(opt.cmax-opt.cmin)/64:opt.cmax;
        else
            col=opt.customcontours;
        end
        ncol=size(col,2)-1;
        clmap=muppet_getColors(handles.colormaps,opt.colormap,ncol);
        colormap(clmap);
        caxis([col(2) col(end-1)]);
        qv=quiver3(x,multiy*y,z,opt.unitvector*u,multiv*opt.unitvector*v,w,0);hold on;
        qv=mp_colquiver(qv,sqrt(u.^2+v.^2));
        colorfix;
        clmap=muppet_getColors(handles.colormaps,plt.colormap,ncol);
        colormap(clmap);
    end
end
