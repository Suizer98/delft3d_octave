function tsunami_run_model_series(run,dr,prefx,thresholdlevel,ncores,checkforfinishedsimulations,varargin)

% Set defaults
rdur=120;
tsunamifile=[];
spiderwebfile=[];
adjustbathymetry=0;

% Read input arguments
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'tsunamifile'}
                tsunamifile=varargin{ii+1};
                [xtsu ytsu ztsu info] = arc_asc_read(tsunamifile);
            case{'spiderwebfile'}
                spiderwebfile=varargin{ii+1};
            case{'runduration'}
                rdur=varargin{ii+1};
            case{'refdate'}
                itdate=varargin{ii+1};
            case{'tstart'}
                tstart=varargin{ii+1};
            case{'tstop'}
                tstop=varargin{ii+1};
            case{'adjustbathymetry','updatebathymetry'}
                adjustbathymetry=varargin{ii+1};
        end                
    end
end

if ~isempty(tsunamifile)
    modeltype='tsunami';
else
    modeltype='cyclone';
end

inputdir=[dr filesep 'input' filesep];
runsdir=[dr filesep 'runs' filesep];


if ~isdir(runsdir)
    mkdir(runsdir);
end

if ~isdir([runsdir filesep run])
    mkdir([runsdir filesep run]);
end

modellist=dir([inputdir filesep prefx '*']);

nmodels=length(modellist);

nbatch=0;

for imodel=1:nmodels
    
    ok=1;
    
    mdlname=modellist(imodel).name;
    rundir=[runsdir filesep run filesep mdlname];
        
    xml=xml2struct([inputdir filesep mdlname filesep mdlname '.xml']);

    cs.name=xml.csname;
    cs.type=xml.cstype;
    
    if checkforfinishedsimulations
        if exist([rundir filesep 'finished.txt'],'file')
            disp([mdlname ' already finished!']);
            ok=0;
        end
    end

    if isfield(xml,'flownested') && ok
        if ~isempty(xml.flownested)
            %
            % Run nesting first
            %
            ok=0;
            if exist([runsdir filesep run filesep xml.flownested filesep 'trih-' xml.flownested '.dat'],'file')  
                
                if thresholdlevel>0
                    
                    % First check if water level along boundary exceeds threshold
                    fid=qpfopen([runsdir filesep run filesep xml.flownested filesep 'trih-' xml.flownested '.dat']);
                    stations = qpread(fid,1,'water level','stations');
                    
                    % Water level at middle of offshore boundary
                    istat=strmatch(mdlname,stations,'exact');
                    wl=qpread(fid,1,'water level','griddata',0,istat);
                    switch modeltype
                        case{'tsunami'}
                            waveheight=max(wl.Val)-min(wl.Val);
                        case{'cyclone'}
                            waveheight=max(wl.Val);
                    end
                    
                    % Water level at LL corner of offshore boundary
                    istat=strmatch([mdlname ' - LL'],stations,'exact');
                    if ~isempty(istat)
                        wl=qpread(fid,1,'water level','griddata',0,istat);
                        switch modeltype
                            case{'tsunami'}
                                waveheight=max(waveheight,max(wl.Val)-min(wl.Val));
                            case{'cyclone'}
                                waveheight=max(wl.Val);
                        end
                    end
                    
                    % Water level at LR corner of offshore boundary
                    istat=strmatch([mdlname ' - LR'],stations,'exact');
                    if ~isempty(istat)
                        wl=qpread(fid,1,'water level','griddata',0,istat);
                        switch modeltype
                            case{'tsunami'}
                                waveheight=max(waveheight,max(wl.Val)-min(wl.Val));
                            case{'cyclone'}
                                waveheight=max(wl.Val);
                        end
                    end
                    
                else
                    waveheight=1e9;
                end
                
                if waveheight>thresholdlevel
                    
                    ok=1;
                    
                    % Copy input to run directory
                    if ~isdir(rundir)
                        mkdir(rundir);
                    end
                    copyfile([inputdir filesep mdlname filesep 'input' filesep '*'],rundir);
                    
                    switch modeltype
                        case{'tsunami'}
                            % Change run duration
                            findreplace([rundir filesep mdlname '.mdf'],'RDURKEY',num2str(rdur));
                            findreplace([rundir filesep mdlname '.fou'],'RDURKEY',num2str(rdur));
                        case{'cyclone'}
                            % Change run duration
                            t0=(tstart-itdate)*1440;
                            t1=(tstop-itdate)*1440;
                            rdur=(t1-t0);
                            dtmap=60;
                            dthis=10;
                            findreplace([rundir filesep mdlname '.mdf'],'ITDATEKEY',datestr(itdate,'yyyy-mm-dd'));
                            findreplace([rundir filesep mdlname '.mdf'],'TSTARTKEY',num2str(t0));
                            findreplace([rundir filesep mdlname '.mdf'],'TSTOPKEY',num2str(t1));
                            findreplace([rundir filesep mdlname '.mdf'],'DTMAPKEY',num2str(dtmap));
                            findreplace([rundir filesep mdlname '.mdf'],'DTHISKEY',num2str(dthis));
                    end
                    
                    % nesthd2
                    fid=fopen('nesthd2.xml','wt');
                    fprintf(fid,'%s\n','<?xml version="1.0"?>');
                    fprintf(fid,'%s\n','<root>');
                    fprintf(fid,'%s\n',['  <runid>' mdlname '</runid>']);
                    fprintf(fid,'%s\n',['  <inputdir>' rundir filesep '</inputdir>']);
                    fprintf(fid,'%s\n',['  <admfile>' inputdir filesep mdlname filesep mdlname '.adm</admfile>']);
                    fprintf(fid,'%s\n','  <opt>hydro</opt>');
                    fprintf(fid,'%s\n',['  <hisfile>' runsdir filesep run filesep xml.flownested filesep 'trih-' xml.flownested '.dat</hisfile>']);
                    fprintf(fid,'%s\n','</root>');
                    fclose(fid);
                    nesthd2('nesthd2.xml');
                    delete('nesthd2.xml');
                    
                    
                else
                    disp(['Model ' mdlname ' skipped - water level along boundary does not exceed threshold.']);
                end
                
            else
                disp(['Model ' mdlname ' skipped - no output found from overall model.']);
            end
            
        end
        
    end
    
    if ok

        % Copy input to run directory
        if ~isdir(rundir)
            mkdir(rundir);
        end        
        copyfile([inputdir filesep mdlname filesep 'input' filesep '*'],rundir);
        
        % Copy batch files
        copyfile([inputdir 'batch' filesep '*.*'],rundir);
        findreplace([rundir filesep 'config_d_hydro.xml'],'RUNIDKEY',mdlname);
        
        switch modeltype
            case{'tsunami'}

                % Change run duration
                findreplace([rundir filesep mdlname '.mdf'],'RDURKEY',num2str(rdur));
                findreplace([rundir filesep mdlname '.fou'],'RDURKEY',num2str(rdur));
                
                % >>> generate INITIAL CONDITIONS files <<<
                if ~isempty(tsunamifile)
                    
                    newSys.name='WGS 84';
                    newSys.type='geographic';
                    
                    grd=wlgrid('read',[rundir filesep mdlname '.grd']);
                    [xz,yz]=getXZYZ(grd.X,grd.Y);
                    
                    oridepfile=[rundir filesep mdlname '.dep'];
                    newdepfile=oridepfile; % Overwrite original depth file
                    
                    interpolateTsunamiToGrid('xgrid',xz,'ygrid',yz,'gridcs',cs,'tsunamics',newSys, ...
                        'xtsunami',xtsu,'ytsunami',ytsu,'ztsunami',ztsu,'inifile',[rundir filesep mdlname '.ini'], ...
                        'adjustbathymetry',adjustbathymetry,'oridepfile',oridepfile,'newdepfile',newdepfile);
                    
                end
                
            case{'cyclone'}

                csin.name='WGS 84';
                csin.type='geographic';
                csout=cs;
                
                copyfile(spiderwebfile,rundir);
                [pathstr,name,ext] = fileparts(spiderwebfile);
                spwname=[name ext];
                % Convert spw file to the right coordinate system
                if ~strcmpi(csin.name,csout.name) && ~strcmpi(csin.type,csout.type)
                    csoutname=csout.name;
                    csoutname=strrep(csoutname,' ','');
                    csoutname=strrep(csoutname,'/','');
                    csoutname=lower(csoutname);
                    tmpdir=[runsdir filesep run filesep csoutname filesep];
                    if exist([tmpdir spwname],'file')
                        % Spiderweb has already been converted
                        copyfile([tmpdir spwname],rundir);
                    else
                        disp('Converting coordinate system spiderweb file ...');
                        mkdir(tmpdir);
                        copyfile(spiderwebfile,tmpdir);
                        convert_spiderweb_coordinate_system([tmpdir spwname],[tmpdir spwname],csin,csout);
                        copyfile([tmpdir spwname],rundir);
                    end
                else
                    % No need for conversion
                    copyfile(spiderwebfile,rundir);
                end

                % Change run duration
                t0=(tstart-itdate)*1440;
                t1=(tstop-itdate)*1440;
                rdur=(t1-t0);
                dtmap=60;
                dthis=10;
                
                findreplace([rundir filesep mdlname '.mdf'],'ITDATEKEY',datestr(itdate,'yyyy-mm-dd'));
                findreplace([rundir filesep mdlname '.mdf'],'TSTARTKEY',num2str(t0));
                findreplace([rundir filesep mdlname '.mdf'],'TSTOPKEY',num2str(t1));
                findreplace([rundir filesep mdlname '.mdf'],'DTMAPKEY',num2str(dtmap));
                findreplace([rundir filesep mdlname '.mdf'],'DTHISKEY',num2str(dthis));
                findreplace([rundir filesep mdlname '.mdf'],'SPWKEY',spwname);
                
                try
                    findreplace([rundir filesep mdlname '.fou'],'TSTARTKEY',num2str(t0));
                    findreplace([rundir filesep mdlname '.fou'],'RDURKEY',num2str(rdur));
                end

%                findreplace([rundir filesep mdlname '.fou'],'DTMAPKEY',num2str(dtmap));
                
        end
        
    end
    
    if ok
        
        nbatch=nbatch+1;
        mdl{nbatch}=mdlname;
        
        disp(['Starting ' mdlname ' ...']);
        
        fid=fopen('runbatch.bat','wt');
        fprintf(fid,'%s\n',['cd ' rundir]);
        fprintf(fid,'%s\n','start runflow.bat');
        fclose(fid);
               
        system('runbatch.bat');
        delete('runbatch.bat');
        
    end
    
    if nbatch==ncores || imodel==nmodels
        % Start checking for finished simulations
        pause(1);
        while 1
            ok=1;
            for ii=1:nbatch
                if ~exist([runsdir filesep run filesep mdl{ii} filesep 'finished.txt'],'file')
                    ok=0;
                end
            end
            pause(1);
            if ok
                break
            end
        end
        nbatch=0;
        mdl=[];
    end
    
end
