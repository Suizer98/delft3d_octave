function opt=muppet_setDefaultAnnotationOptions(varargin)

opt=[];

if ~isempty(varargin)
    opt=varargin{1};
end

opt=muppet_setDefaultPlotOptions(opt);

opt.position=[0 0 0 0];
opt.linecolor=       'black';
opt.linestyle=       '-';
opt.linewidth=       2;
opt.head1style=      'plain';
opt.head1width=      6;
opt.head1length=     6;
opt.head2style=      'plain';
opt.head2width=      6;
opt.head2length=     6;
opt.backgroundcolor= 'white';
opt.font.name=       'helvetica';
opt.font.size=       8;
opt.font.weight=     'normal';
opt.font.angle=      'normal';
opt.font.color=      'black';
opt.font.horizontalalignment='left';
opt.font.verticalalignment='top';
opt.string=          'Text Box';
opt.box=             1;
opt.plotroutine=     'addannotation';
opt.number=          [];
