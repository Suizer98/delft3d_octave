function handles=muppet_adjustPlotOptions(handles)

plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
nrd=plt.nrdatasets;

dataset=handles.datasets(handles.activedataset).dataset;
%datatype=data.type;

opt=plt.datasets(nrd).dataset;

switch lower(dataset.type)
    case {'scalar2dxy','scalar2dtx','scalar2dxz'}
        cmin=floor(min(min(dataset.z)));
        cmax=ceil(max(max(dataset.z)));
        cstep=0.01*round(100*(cmax-cmin)/20);
        opt.cmin=cmin;
        opt.cmax=cmax;
        opt.cstep=cstep;
        opt.customcontours=cmin:cstep:cmax;
        opt.font.size=6;
    case {'vector2d2dxy','vector2d2duxy'}
        umag=sqrt(dataset.u.^2 + dataset.v.^2);
        umax=max(max(umag));
        unitvec=plt.scale*0.005/umax;
        opt.unitvector=unitvec;
        opt.vectorlegendlength=umax;
        opt.vectorlegendtext=num2str(umax);
        cmin=0;
        cmax=umax;
        cstep=(cmax-cmin)/20;
        opt.cmin=cmin;
        opt.cmax=cmax;
        opt.cstep=cstep;
        opt.customcontours=cmin:cstep:cmax;
        opt.curvecspacing=plt.scale*0.005;
        axpos=plt.position;
        opt.colorbar.position=[axpos(1)+1 axpos(2)+1 0.5 axpos(4)-2];
    case {'vector2d2dxz'}
        vertscale=100*(plt.ymax-plt.ymin)/plt.position(4);
        horiscale=100*(plt.xmax-plt.ymin)/plt.position(3);
        multiv=horiscale/vertscale;
        opt.verticalvectorscaling=multiv;
        umag=sqrt(dataset.u.^2 + dataset.v.^2);
        umax=max(max(umag));
        unitvec=horiscale*0.005/umax;
        opt.unitvector=unitvec;
        opt.vectorlegendlength=umax;
        opt.vectorlegendtext=num2str(umax);
        cmin=0;
        cmax=umax;
        cstep=(cmax-cmin)/20;
        opt.cmin=cmin;
        opt.cmax=cmax;
        opt.cstep=cstep;
        opt.customcontours=cmin:cstep:cmax;
        opt.curvecspacing=plt.scale*0.005;
        axpos=plt.position;
        opt.colorbar.position=[axpos(1)+1 axpos(2)+1 0.5 axpos(4)-2];
    case {'rose'}
        dat=dataset.z;
        sm=sum(dat,2);
        smmax=max(sm);
        if smmax<4
            opt.radiusstep=1;
            opt.maxradius=4;
        elseif smmax<8
            opt.radiusstep=2;
            opt.maxradius=8;
        elseif smmax<16
            opt.radiusstep=4;
            opt.maxradius=16;
        else
            opt.radiusstep=10;
            opt.maxradius=40;
        end
end

plt.datasets(nrd).dataset=opt;
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
