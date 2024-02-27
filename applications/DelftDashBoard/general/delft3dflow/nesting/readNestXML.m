function opt=readNestXML(fname)

x=xml_load(fname);

f=fieldnames(x);
fl=lower(fieldnames(x));


ii=strmatch('inputfolder',fl,'exact');
if ~isempty(ii)
    opt.inputDir=x.(f{ii});
else
    opt.inputDir='';
end

ii=strmatch('runid',fl,'exact');
if ~isempty(ii)
    opt.runid=x.(f{ii});
else
    opt.runid='';
end

% Time steps

ii=strmatch('bcttimestep',fl,'exact');
if ~isempty(ii)
    opt.bctTimeStep=str2double(x.(f{ii}));
else
    opt.bctTimeStep=30;
end

ii=strmatch('bcctimestep',fl,'exact');
if ~isempty(ii)
    opt.bccTimeStep=str2double(x.(f{ii}));
else
    opt.bccTimeStep=30;
end

opt.cs=[];

ii=strmatch('csname',fl,'exact');
if ~isempty(ii)
    opt.cs.name=x.(f{ii});
end

ii=strmatch('cstype',fl,'exact');
if ~isempty(ii)
    opt.cs.type=x.(f{ii});
end

opt=fillOpt(opt,x,'waterlevel');
opt=fillOpt(opt,x,'current');
opt=fillOpt(opt,x,'salinity');
opt=fillOpt(opt,x,'temperature');

%%
function opt=fillOpt(opt,x,par)

if strcmpi(par,'waterlevel')
    par2='waterLevel';
else
    par2=par;
end

f=fieldnames(x);
fl=lower(fieldnames(x));
ii=strmatch(par,fl,'exact');
xx=x.(f{ii});

% BC
ff=fieldnames(xx);
ffl=lower(fieldnames(xx));
ii=strmatch('bc',ffl,'exact');
xxx=xx.(ff{ii});

fff=fieldnames(xxx);
fffl=lower(fieldnames(xxx));

ii=strmatch('source',fffl,'exact');
if ~isempty(ii)
    switch lower(xxx.(fff{ii}))
        case{'astro'}
            opt.(par2).BC.source=1;
        case{'file'}
            opt.(par2).BC.source=2;
        case{'astro+file','file+astro'}
            opt.(par2).BC.source=3;
        case{'constant'}
            opt.(par2).BC.source=4;
        case{'profile'}
            opt.(par2).BC.source=5;
        otherwise
            opt.(par2).BC.source=4;
    end
end

ii=strmatch('datafolder',fffl,'exact');
if ~isempty(ii)
    opt.(par2).BC.datafolder=xxx.(fff{ii});
else
    opt.(par2).BC.folder='';
end

ii=strmatch('dataname',fffl,'exact');
if ~isempty(ii)
    opt.(par2).BC.dataname=xxx.(fff{ii});
else
    opt.(par2).BC.dataname='';
end

ii=strmatch('constant',fffl,'exact');
if ~isempty(ii)
    opt.(par2).BC.constant=str2double(xxx.(fff{ii}));
else
    opt.(par2).BC.constant=0;
end

ii=strmatch('bcafile',fffl,'exact');
if ~isempty(ii)
    opt.(par2).BC.astroFile=xxx.(fff{ii});
else
    opt.(par2).BC.astroFile='';
end

ii=strmatch('bndfile',fffl,'exact');
if ~isempty(ii)
    opt.(par2).BC.bndAstroFile=xxx.(fff{ii});
else
    opt.(par2).BC.bndAstroFile='';
end

ii=strmatch('corfile',fffl,'exact');
if ~isempty(ii)
    opt.(par2).BC.corFile=xxx.(fff{ii});
else
    opt.(par2).BC.corFile='';
end


ii=strmatch('bcatanvelfile',fffl,'exact');
if ~isempty(ii)
    opt.(par2).BC.astroTanVelFile=xxx.(fff{ii});
else
    opt.(par2).BC.astroTanVelFile='';
end

ii=strmatch('cortanvelfile',fffl,'exact');
if ~isempty(ii)
    opt.(par2).BC.corTanVelFile=xxx.(fff{ii});
else
    opt.(par2).BC.corTanVelFile='';
end

% IC
ff=fieldnames(xx);
ffl=lower(fieldnames(xx));
ii=strmatch('ic',ffl,'exact');
xxx=xx.(ff{ii});

fff=fieldnames(xxx);
fffl=lower(fieldnames(xxx));

ii=strmatch('source',fffl,'exact');
if ~isempty(ii)
    switch lower(xxx.(fff{ii}))
        case{'astro'}
            opt.(par2).IC.source=1;
        case{'file'}
            opt.(par2).IC.source=2;
        case{'astro+file'}
            opt.(par2).IC.source=3;
        case{'constant'}
            opt.(par2).IC.source=4;
        case{'profile'}
            opt.(par2).IC.source=5;
        otherwise
            opt.(par2).IC.source=4;
    end
end

ii=strmatch('datafolder',fffl,'exact');
if ~isempty(ii)
    opt.(par2).IC.datafolder=xxx.(fff{ii});
else
    opt.(par2).IC.folder='';
end

ii=strmatch('dataname',fffl,'exact');
if ~isempty(ii)
    opt.(par2).IC.dataname=xxx.(fff{ii});
else
    opt.(par2).IC.dataname='';
end

ii=strmatch('constant',fffl,'exact');
if ~isempty(ii)
    opt.(par2).IC.constant=str2double(xxx.(fff{ii}));
else
    opt.(par2).IC.constant=0;
end

ii=strmatch('polygons',fffl,'exact');
if ~isempty(ii)
    nrpol=length(xxx.(fff{ii}));
    for ip=1:nrpol
        opt.(par2).IC.polygons(ip).filename=xxx.(fff{ii})(ip).polygon.filename;
        opt.(par2).IC.polygons(ip).value=str2double(xxx.(fff{ii})(ip).polygon.value);
    end
end
