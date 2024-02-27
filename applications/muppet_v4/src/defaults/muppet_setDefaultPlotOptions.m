function opt=muppet_setDefaultPlotOptions(varargin)

opt=[];
opt.number=[];

if ~isempty(varargin)
    opt=varargin{1};
end

% Set all possible plot options, will mostly be overwritten
opt.linecolor='Black';
opt.linestyle='-';
opt.linewidth=0.5;

opt.marker='none';
opt.markeredgecolor='black';
opt.markerfacecolor='black';
opt.markersize=10;

opt.legendtext='';

opt.addtext=0;
opt.addtextshade=0;
opt.textposition='right';

opt.font.name='Helvetica';
opt.font.size=8;
opt.font.weight='normal';
opt.font.angle='normal';
opt.font.color='Black';
opt.font.horizontalalignment='left';
opt.font.verticalalignment='top';
opt.textposition='NorthEast';

opt.contourlabels=0;
opt.labels.spacing=72;
opt.labels.font.name='Helvetica';
opt.labels.font.size=5;
opt.labels.font.weight='normal';
opt.labels.font.angle='normal';
opt.labels.font.color='Black';

opt.shading='interp';
opt.contourtype='limits';
opt.transparency=1.0;
opt.contours=0:0.1:1;
opt.rightaxis=0;
opt.closepolygons=0;
opt.fillclosedpolygons=0;
opt.fillcolor='LightGreen';
opt.edgecolor='Black';
opt.facecolor='Red';
opt.polygonelevation=0;
opt.elevation=0;
opt.elevations=[-20 20];
opt.multiply=1;

opt.headwidth=4;
opt.arrowwidth=2;
opt.headlength=8;
opt.nrheads=1;
opt.polylinetype='polyline';
opt.maxdistance=0;

opt.adddatestring=0;
opt.adddate.position='upper-left';
opt.adddate.prefix='';
opt.adddate.suffix='';
opt.adddate.format='dd-mmm-yyyy HH:MM:SS';
opt.adddate.font.name='Helvetica';
opt.adddate.font.size=12;
opt.adddate.font.weight='normal';
opt.adddate.font.angle='normal';
opt.adddate.font.color='Black';
opt.areatext=1;
opt.decimals=0;
opt.fillareas=1;

% Wind/wave rose
opt.firstcolumncalm=1;
opt.addrosetotals=1;
opt.addroselegend=1;
opt.coloredrose=1;
opt.maxradius=16;
opt.radiusstep=4;

opt.unitvector=1;
opt.vectorlegendlength=1;
opt.vectorlegendtext='';
opt.verticalvectorscaling=1;
opt.vectorcolor='black';
opt.verticalvectorscaling=1.0;
opt.fieldthinningtype='none';
opt.fieldthinningfactor1=1;
opt.fieldthinningfactor2=1;
opt.fieldthinningdistance=1;

% CurVec
opt.arrowthickness=0.05;
opt.headthickness=0.15;
opt.curveclength=600;
opt.curvecspacing=5000;
opt.curveclifespan=50;
opt.curvecrelativespeed=1;
opt.fadecurvyarrows=1;

opt.cmin=0;
opt.cstep=0.1;
opt.cmax=1;
opt.usecustomcontours=0;
opt.customcontours=[0 1 2];

opt.plotcolorbar=0;
opt.colormap='jet';
opt.shadesbar=0;
opt.colorbar.position=[];
opt.colorbar.decimals=-1;
opt.colorbar.type=1;
opt.colorbar.label='';
opt.colorbar.labelposition='top';
opt.colorbar.unit='';
opt.colorbar.tickincrement=1;
opt.colorbar.font.name='Helvetica';
opt.colorbar.font.size=8;
opt.colorbar.font.angle='normal';
opt.colorbar.font.weight='normal';
opt.colorbar.font.color='black';
opt.colorbar.changed=0;

% Time bar
opt.timebar.type='none';
opt.timebar.time=datenum(2000,1,1);
opt.timebar.linecolor='Red';
opt.timebar.linestyle='-';
opt.timebar.linewidth=3;
opt.timebar.marker='o';
opt.timebar.markeredgecolor='black';
opt.timebar.markerfacecolor='black';
opt.timebar.markersize=10;

% Time marker
opt.timemarker.enable=0;
opt.timemarker.time=datenum(2000,1,1);
opt.timemarker.marker='o';
opt.timemarker.edgecolor='black';
opt.timemarker.facecolor='black';
opt.timemarker.size=10;
opt.timemarker.trackoption='uptomarker';
opt.timemarker.showlastposition=1;

% Origin marker
opt.originmarker.enable=0;
opt.originmarker.marker='o';
opt.originmarker.edgecolor='black';
opt.originmarker.facecolor='black';
opt.originmarker.size=10;

opt.thinning=1;

% Lint
opt.decimals=2;
opt.lintscale=1;
opt.arrowcolor='red';
opt.multiply=1;
opt.unitarrow=1;

% Kubint
opt.kubfill=1;
opt.areatext='values';

% Image
opt.whitevalue=0.9;
opt.opacity=1;
opt.verticallevel=-1000;

% 3D
opt.plot3dgrid=0;
opt.onecolor=0;
opt.color='lightgreen';
opt.facelighting='gouraud';
opt.edgelighting='none';
opt.backfacelighting='reverselit';
opt.ambientstrength=0.5;
opt.diffusestrength=0.5;
opt.specularstrength=0.5;
opt.specularexponent=100;
opt.specularcolorreflectance=1;
opt.edgeopacity=1;
opt.faceopacity=1;

% Grid
opt.plotgrid=0;

% Annotation
opt.x=0;
opt.y=0;
opt.rotation=0;
opt.curvature=0;

% Annotations
opt.head1style='plain';
opt.head1width=6;
opt.head1length=6;
opt.head2style='plain';
opt.head2width=6;
opt.head2length=6;
opt.box=1;
opt.backgroundcolor='white';

% Stats text
opt.statstext.position='upper-left';
opt.statstext.rmse.include=0;
opt.statstext.rmse.nrdecimals=1;
opt.statstext.r2.include=0;
opt.statstext.r2.nrdecimals=1;
opt.statstext.stdev.include=0;
opt.statstext.stdev.nrdecimals=1;
opt.statstext.font.name='Helvetica';
opt.statstext.font.size=6;
opt.statstext.font.angle='normal';
opt.statstext.font.weight='normal';
opt.statstext.font.color='black';

% Transparency
opt.edgealpha=1;
opt.facealpha=1;

% Line text
opt.addlinetext=0;
opt.linetext.x=0;
opt.linetext.dy=0.03;
opt.linetext.string='';
opt.linetext.font.name='Helvetica';
opt.linetext.font.size=6;
opt.linetext.font.angle='normal';
opt.linetext.font.weight='normal';
opt.linetext.font.color='black';

%% Now overwrite with defaults from xml file
h=getHandles;
n=length(h.plotoption);
for ii=1:n
    name=h.plotoption(ii).plotoption.name;
    if isfield(h.plotoption(ii).plotoption,'variable')
        var=h.plotoption(ii).plotoption.variable;
    else
        var=name;
    end
    if isfield(h.plotoption(ii).plotoption,'default')
        default=h.plotoption(ii).plotoption.default;
        if isstruct(default)
            default=default(1).default;
%            shite=1
        end
        tp='string';
        if isfield(h.plotoption(ii).plotoption,'type')
            tp=h.plotoption(ii).plotoption.type;
        end
        switch tp
            case{'real','int','integer','boolean','booleanorreal'}
                default=str2num(default);
        end
%         opt.(name)=default;
       evalstr=['opt.' var '=default;'];
       eval(evalstr);
        opt.changed=0;        
    end
end

