function tsunami_create_obs1(dr,ovrprf,detprf,opt)

% Creates observation points in larger model of boundaries of smaller models

overallmodellist=dir([dr filesep ovrprf '*']);

for jj=1:length(overallmodellist)
    
    overallmodel=overallmodellist(jj).name;
    xml=xml2struct([dr filesep overallmodel filesep overallmodel '.xml']);
    csoverall.name=xml.csname;    
    csoverall.type=xml.cstype;

    modellist=dir([dr filesep detprf '*']);

    % Read overall grid
    [xoverall,yoverall,enc,cs,nodatavalue] = wlgrid('read',[dr filesep overallmodel filesep 'input' filesep overallmodel '.grd']);

    % Read existing observation points overall model
    [name,m,n] = textread([dr filesep overallmodel filesep 'input' filesep overallmodel '.obs'],'%21c%f%f');

    observationPoints=[];
    observationPointNames=[];
    
    for i=1:length(m)
        nm=deblank(name(i,:));
        observationPoints(i).name=nm;
        observationPoints(i).M=m(i);
        observationPoints(i).N=n(i);
        observationPointNames{i}=nm;
    end
        
    for ii=1:length(modellist)
        
        detmodel=modellist(ii).name;
        
        xml=xml2struct([dr filesep detmodel filesep detmodel '.xml']);
        
        if strcmpi(xml.flownested,overallmodel) || opt==1
            
            disp(['Adding observation points for ' detmodel ' in ' overallmodel]);
            
            % Read grid detailed model
            [xdet,ydet,enc,cs,nodatavalue] = wlgrid('read',[dr filesep detmodel filesep 'input' filesep detmodel '.grd']);

            % Determine cell centres
            [xz,yz]=getXZYZ(xdet,ydet);

            mmax=size(xdet,1);
            nmax=size(xdet,2);

            mdet(1)=round(mmax/2);
            ndet(1)=3;
            obsnm{1}=detmodel;

            mdet(2)=2;
            ndet(2)=2;
            obsnm{2}=[detmodel ' - LL'];
            
            mdet(3)=mmax;
            ndet(3)=2;
            obsnm{3}=[detmodel ' - LR'];
            
            % Coordinates
            for ip=1:3
                xp(ip)=xz(mdet(ip),ndet(ip));
                yp(ip)=yz(mdet(ip),ndet(ip));
            end
            
            % Check if coordinate system is the same
            % If not, convert coordinates to overall model cs
            if ~strcmpi(csoverall.name,xml.csname) || ~strcmpi(csoverall.type,xml.cstype)
                [xp,yp]=convertCoordinates(xp,yp,'persistent','CS1.name',xml.csname,'CS1.type',xml.cstype, ...
                    'CS2.name',csoverall.name,'CS2.type',csoverall.type);
            end
            
            [moverall,noverall]=findgridcell(xp,yp,xoverall,yoverall);
            
            for ip=1:length(moverall)
                if moverall(ip)>0
                    np=length(observationPoints);
                    kk=strmatch(obsnm,observationPointNames,'exact');
                    if isempty(kk)
                        np=np+1;
                        observationPoints(np).name=obsnm{ip};
                        observationPoints(np).M=moverall(ip);
                        observationPoints(np).N=noverall(ip);
                        observationPointNames{np}=obsnm{ip};
                    end
                end
            end
        end
    end
    
    fid=fopen([dr filesep overallmodel filesep 'input' filesep overallmodel '.obs'],'w');
    for i=1:length(observationPoints)
        m=observationPoints(i).M;
        n=observationPoints(i).N;
        name=observationPoints(i).name;
        fprintf(fid,'%s %3.0f %3.0f\n',[name repmat(' ',1,21-length(name)) ] ,m,n);
    end
    fclose(fid);
    
end

