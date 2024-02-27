function tsunami_run_nesthd1(dr,ovrprf,detprf,exedir)

overallmodellist=dir([dr filesep ovrprf '*']);

for jj=1:length(overallmodellist)
    
    overallmodel=overallmodellist(jj).name;
    xml=xml2struct([dr filesep overallmodel filesep overallmodel '.xml']);
    csoverall.name=xml.csname;    
    csoverall.type=xml.cstype;

    modellist=dir([dr filesep detprf '*']);
    
    observationPoints=[];
    observationPointNames={''};
    k=0;
    
    for ii=1:length(modellist)
        
        detmodel=modellist(ii).name;
        
        xml=xml2struct([dr filesep detmodel filesep detmodel '.xml']);
        
        if strcmpi(xml.flownested,overallmodel)
            
            disp(['Nesting ' detmodel ' in ' overallmodel]);
            
            % Check if coordinate system is the same
            if ~strcmpi(csoverall.name,xml.csname) || ~strcmpi(csoverall.type,xml.cstype)
                grdfile='tmp.grd';
                [x,y,enc,cs,nodatavalue] = wlgrid('read',[dr filesep detmodel filesep 'input' filesep detmodel '.grd']);
                [x,y]=convertCoordinates(x,y,'persistent','CS1.name',xml.csname,'CS1.type',xml.cstype, ...
                    'CS2.name',csoverall.name,'CS2.type',csoverall.type);
                switch lower(csoverall.type)
                    case{'geographic'}
                        cs='Spherical';
                    otherwise
                        cs='Cartesian';
                end
                 wlgrid('write','FileName','tmp.grd','X',x,'Y',y,'Enclosure',enc,'CoordinateSystem',cs);
            else
                grdfile=[dr filesep detmodel filesep 'input' filesep detmodel '.grd'];
            end
            
            fid=fopen('nesthd1.inp','wt');
            fprintf(fid,'%s\n',[dr filesep overallmodel filesep 'input' filesep overallmodel '.grd']);
            fprintf(fid,'%s\n',[dr filesep overallmodel filesep 'input' filesep overallmodel '.enc']);
            fprintf(fid,'%s\n',grdfile);
            fprintf(fid,'%s\n',[dr filesep detmodel filesep 'input' filesep detmodel '.enc']);
            fprintf(fid,'%s\n',[dr filesep detmodel filesep 'input' filesep detmodel '.bnd']);
            fprintf(fid,'%s\n',[dr filesep detmodel filesep detmodel '.adm']);
            fprintf(fid,'%s\n','ddtemp.obs');
            fclose(fid);
            
            system(['"' exedir 'nesthd1" < nesthd1.inp > out.scr']);
            [name,m,n] = textread('ddtemp.obs','%21c%f%f');
            
            % read original obs file
            for i=1:length(m)
                % Check if observation point already exists
                nm=deblank(name(i,:));
                ii=strmatch(nm,observationPointNames,'exact');
                if isempty(ii)
                    % Observation point does not yet exist
                    k=k+1;
                    observationPoints(k).name=nm;
                    observationPoints(k).M=m(i);
                    observationPoints(k).N=n(i);
                    observationPointNames{k}=nm;
                end
            end
            delete('nesthd1.inp');
            try
                delete('ddtemp.obs');
            end
            try
                if exist('tmp.grd','file')
                    delete('tmp.grd');
                end
            end
            try
                if exist('tmp.enc','file')
                    delete('tmp.enc');
                end
            end
            try
                if exist('out.scr','file')
                    delete('out.scr');
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
