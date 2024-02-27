function tsunami_create_obs2(dr,detprf)

% Creates observation points in model along boundary of model

modellist=dir([dr filesep detprf '*']);

for ii=1:length(modellist)

    model=modellist(ii).name;

    disp(['Adding observation points for ' model]);    
    
    observationPoints=[];
    observationPointNames=[];

%     if exist([dr filesep model filesep 'input' filesep model '.obs'],'file')
%         delete([dr filesep model filesep 'input' filesep model '.obs']);
%     end

    if exist([dr filesep model filesep 'input' filesep model '.obs'],'file')        
        % Read existing observation points model
        [name,m,n] = textread([dr filesep model filesep 'input' filesep model '.obs'],'%21c%f%f');
        for i=1:length(m)
            nm=deblank(name(i,:));
            observationPoints(i).name=nm;
            observationPoints(i).M=m(i);
            observationPoints(i).N=n(i);
            observationPointNames{i}=nm;
        end
    end
    
    % Read grid detailed model
    [xdet,ydet,enc,cs,nodatavalue] = wlgrid('read',[dr filesep model filesep 'input' filesep model '.grd']);
    
    mmax=size(xdet,1);
    nmax=size(xdet,2);
    
    mdet=round(mmax/2);
    ndet=3;
    
    np=length(observationPoints);
    
    obsnm=model;
    kk=strmatch(obsnm,observationPointNames,'exact');
    if isempty(kk)
        np=np+1;
        observationPoints(np).name=model;
        observationPoints(np).M=mdet;
        observationPoints(np).N=ndet;
        observationPointNames{np}=obsnm;
    end

    obsnm=[model ' - LL'];
    kk=strmatch(obsnm,observationPointNames,'exact');
    if isempty(kk)
        np=np+1;
        observationPoints(np).name=obsnm;
        observationPoints(np).M=2;
        observationPoints(np).N=2;
        observationPointNames{np}=obsnm;
    end

    obsnm=[model ' - LR'];
    kk=strmatch(obsnm,observationPointNames,'exact');
    if isempty(kk)
        np=np+1;
        observationPoints(np).name=obsnm;
        observationPoints(np).M=mmax;
        observationPoints(np).N=2;
        observationPointNames{np}=obsnm;
    end

    fid=fopen([dr filesep model filesep 'input' filesep model '.obs'],'w');
    for i=1:length(observationPoints)
        m=observationPoints(i).M;
        n=observationPoints(i).N;
        name=observationPoints(i).name;
        fprintf(fid,'%s %3.0f %3.0f\n',[name repmat(' ',1,21-length(name)) ] ,m,n);
    end
    fclose(fid);
    
end
