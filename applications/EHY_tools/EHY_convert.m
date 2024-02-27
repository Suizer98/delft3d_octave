function varargout=EHY_convert(varargin)
%% varargout=EHY_convert(varargin)
%
% Converts the inputFile to a file with the outputExt.
% It makes use of available conversion scripts in the OET.

% Example1: EHY_convert
% Example2: EHY_convert('D:\path.kml')
% Example3: ldb=EHY_convert('D:\path.kml','ldb')
% Example4: pol=EHY_convert('D:\path.kml','pol','saveOutputFile',0)
% Example5: net=EHY_convert('D:\grid_net.nc','ldb','saveOutputFile',0)
% Example6: EHY_convert('D:\coastline.ldb','ldb','fromEPSG',4326','toEPSG',28992,'overwrite',1)

% created by Julien Groenenboom, August 2017
%%
OPT.saveOutputFile  = 1; % 0=do not save, 1=save
OPT.outputFile      = []; % if isempty > outputFile=strrep(inputFile,inputExt,outputExt);
OPT.overwrite       = 0; % 0=user will be asked if it's ok to overwrite, 1=overwrite existing file
OPT.lineColor       = [1 0 0]; % default is red
OPT.lineWidth       = 1;
OPT.fromEPSG        = []; % convert from this EPSG in case of conversion to kml or same extension
OPT.toEPSG          = []; % convert to this EPSG in case of conversion to same extension
OPT.grdFile         = [];  % corresponding .grd file for files like .crs / .dry / obs. / ...
OPT.netFile         = [];  % *_net.nc-file for conversion of .xyz (dry points) to dry-crosses-ldb
OPT.grd             = []; % wlgrid('read',OPT.grdFile);
OPT.iconFile        = 'http://maps.google.com/mapfiles/kml/paddle/blu-stars.png'; % for PlaceMark
OPT.mergePartitions = 0; % merge output from several dfm spatial *.nc-files

% if structure was given as input OPT
OPTid=find(cellfun(@isstruct, varargin));
if ~isempty(OPTid)
    if ~isfield(varargin{OPTid},'X') % grd can also be given as input struct
        OPT=setproperty(OPT,varargin{OPTid});
        varargin{OPTid}=[];
        varargin=varargin(~cellfun('isempty',varargin));
    end
end

% if pairs were given as input OPT
if length(varargin)>2
    if mod(length(varargin),2)==0
        OPT = setproperty(OPT,varargin{3:end});
    else
        error('Additional input arguments must be given in pairs.')
    end
end

%% availableConversions
A=textread(which('EHY_convert.m'),'%s','delimiter','\n');
searchLine='function [output,OPT] = EHY_convert_';
lineNrs=find(~cellfun('isempty',strfind(A,searchLine)));
availableConversions={'pli'};
for ii=2:length(lineNrs)
    txt=strrep(A{lineNrs(ii)},searchLine,'');
    txt(strfind(txt,'('):end)=[];
    [ext1,ext2]=strtok(txt,'2');
    availableConversions{end+1,1}=ext1;
    availableConversions{end,2}=ext2(2:end);
end

%% initialise
if length(varargin)==0
    listOfExt=unique(availableConversions(:,1));
    disp(['EHY_convert  -  Conversion possible for following inputFiles: ' char(10),...
        strrep(strtrim(sprintf('%s ',listOfExt{:})),' ',', ')])
    availableExt=strcat('*.',[{'*'}; listOfExt]);
    disp('Open a file that you want to convert')
    [filename, pathname]=uigetfile(availableExt,'Open a file that you want to convert');
    if isnumeric(filename); disp('EHY_convert stopped by user.'); return; end
    varargin{1}=[pathname filename];
end
if length(varargin)==1
    inputFile=varargin{1};
    [~,~,inputExt0]= fileparts(inputFile);
    inputExt=lower(strrep(inputExt0,'.',''));
    if isempty(inputExt0) % simona model input file
        inputExt=EHY_convert_askForInputExt;
    end
    
    if strcmp(inputExt,'pli'); inputExt='pol'; end
    if strcmp(inputExt,'lga'); inputExt='cco'; end
    availableInputId=strmatch(inputExt,availableConversions(:,1));
    if isempty(availableInputId)
        error(['No conversions available for ' inputExt '-files.'])
    end
    availableoutputExt=availableConversions(availableInputId,2);
    if ~isempty(strmatch('pol',availableoutputExt))
        availableoutputExt=[availableoutputExt; 'pli'];
    end
    if ismember(inputExt0,{'.grd','.ldb','.nc','.pli','.pliz','.pol','.xyz','.xyn'})
        availableoutputExt=sort([availableoutputExt; inputExt0(2:end)]);
        [availableoutputId,~]=  listdlg('PromptString',['Convert this ' inputExt0 '-file to (to same extension >> coordinate conversion):'],...
            'SelectionMode','single',...
            'ListString',availableoutputExt,...
            'ListSize',[500 100]);
    else
        [availableoutputId,~]=  listdlg('PromptString',['Convert this ' inputExt0 '-file to:'],...
            'SelectionMode','single',...
            'ListString',availableoutputExt,...
            'ListSize',[500 100]);
    end
    if isempty(availableoutputId)
        error('No output extension was chosen.')
    end
    outputExt=availableoutputExt{availableoutputId};
else
    inputFile=varargin{1};
    [~,~,inputExt]= fileparts(inputFile);
    inputExt0=inputExt;
    inputExt=lower(strrep(inputExt,'.',''));
    if isempty(inputExt) % simona model input file
        inputExt=EHY_convert_askForInputExt;
    end
    outputExt=varargin{2};
end

%% Choose and run conversion
% coordinate conversion
if strcmp(inputExt0(2:end),outputExt)
    OPT = EHY_selectToAndFromEPSG(OPT);
    if ~exist('inputExt0','var'); inputExt0=['.' inputExt]; end
    outputFile=strrep(inputFile,inputExt0,['_EPSG-' num2str(OPT.toEPSG) '.' outputExt]);
end

% determine outputFile
if ~isempty(OPT.outputFile) % outputFile was specified by user
    outputFile=OPT.outputFile;
elseif strcmp(inputExt,outputExt) % coordinate conversion
    OPT = EHY_selectToAndFromEPSG(OPT);
    if ~exist('inputExt0','var'); inputExt0=['.' inputExt]; end
    outputFile=strrep(inputFile,['.' inputExt],['_EPSG-' num2str(OPT.toEPSG) '.' outputExt]);
elseif exist('outputFile','var') % outputFile was determined based on coordinate conversion
    % do nothing
else % replace inputExt by outputExt
    [pathstr, name, ext] = fileparts(inputFile);
    outputFile=[pathstr filesep name '.' outputExt];
end

inputFile=strrep(inputFile,[filesep filesep],filesep);
outputFile=strrep(outputFile,[filesep filesep],filesep);

if OPT.saveOutputFile && exist(outputFile,'file') && ~OPT.overwrite
    [YesNoID,~]=  listdlg('PromptString',{'The outputFile already exists. Overwrite the file below?',outputFile},...
        'SelectionMode','single',...
        'ListString',{'Yes','No','No, but save as...'},...
        'ListSize',[800 50]);
    if YesNoID==2
        OPT.saveOutputFile=0;
    elseif YesNoID==3
        [pathstr,~,ext] = fileparts(outputFile);
        [FileName,PathName] = uiputfile([pathstr filesep ext]);
        outputFile=[PathName FileName];
    elseif isempty(YesNoID)
        disp('EHY_convert stopped by user.'); return;
    end
end

inputExt=lower(inputExt);
outputExt=lower(outputExt);

if strcmp(inputExt,'pli');   inputExt  = 'pol'; end
if strcmpi(outputExt,'pli'); outputExt = 'pol'; end %treat as .pol, but still save as .pli
if strcmp(inputExt,'lga');   inputExt  = 'cco'; end %treat as .cco
if strcmpi(outputExt,'nc')
    if isempty(strfind(outputFile,'_net.nc'))
        outputFile=strrep(outputFile,'.nc','_net.nc');
    end
end

output = [];

if ~strcmp(inputExt,outputExt)
    eval(['[output,OPT] = EHY_convert_' inputExt '2' outputExt '(''' inputFile ''',''' outputFile ''',OPT);'])
else
    eval(['[output,OPT] = EHY_convertCoordinates(''' inputFile ''',''' outputFile ''',OPT);'])
end

if OPT.saveOutputFile
    if ~isempty(strfind(outputExt,'.xdry'))
        outputFile0=outputFile;
        outputFile=strrep(outputFile0,'.xdry','_xdry.');
        movefile(outputFile0,outputFile);
    end
    if and(strcmp(inputExt,'crs') || strcmp(inputExt,'curves'),strcmp(outputExt,'kml'))
        outputFile1=strrep(fullfile(outputFile),'.kml','_lines.kml');
        outputFile2=strrep(fullfile(outputFile),'.kml','_names.kml');
        disp([char(10) 'EHY_convert created the files: ' char(10) outputFile1 char(10) outputFile2])
    else
        disp([char(10) 'EHY_convert created the file: ' char(10) fullfile(outputFile) char(10)])
    end
end
%% conversion functions - in alphabetical order
% ann2xyn
    function [output,OPT] = EHY_convert_ann2xyn(inputFile,outputFile,OPT)
        ann=delft3d_io_ann('read',inputFile);
        xyn.x=ann.DATA.x;
        xyn.y=ann.DATA.y;
        xyn.name=ann.DATA.txt;
        if OPT.saveOutputFile
            delft3d_io_xyn('write',outputFile,xyn);
        end
        output=xyn;
    end
% ann2kml
    function [output,OPT] = EHY_convert_ann2kml(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveOutputFile=0;
        xyn=EHY_convert_ann2xyn(inputFile,outputFile,OPT);
        [xyn.x,xyn.y,OPT] = EHY_convert_coorCheck(xyn.x,xyn.y,OPT);
        OPT=OPT_user;
        if OPT.saveOutputFile
            [~,name]=fileparts(outputFile);
            tempFile=[tempdir name '.kml'];
            KMLPlaceMark(xyn.y,xyn.x,tempFile,'name',xyn.name,'icon',OPT.iconFile);
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output = [];
    end
% arl2xyz
    function [output,OPT] = EHY_convert_arl2xyz(inputFile,outputFile,OPT)
        output = dlmread(inputFile);
        output = output(:,[1 2 4]); % x,y,code
        if OPT.saveOutputFile
            fid = fopen(outputFile,'w');
            fprintf(fid,'%.7f %.7f %4.0f\n',output');
            fclose(fid);
        end
    end
% box2dep
    function [output,OPT] = EHY_convert_box2dep(inputFile,outputFile,OPT)
        fid=fopen(inputFile,'r');
        line=lower(fgetl(fid));
        while feof(fid)==0 && ~isempty(strfind(line,'box')) % new box
            % get dimensions of box
            line=line(strfind(line,'(')+1:strfind(line,')')-1);
            line=strrep(line,';',' ');
            line=strtrim(strrep(line,',',' '));
            line=cellfun(@str2num,regexp(line,'\s+','split'));
            
            m=line(1):line(3);
            n=line(2):line(4);
            
            % read this block
            for iM=1:length(m)
                line=lower(fgetl(fid));
                line(strfind(line,'#'):end)=''; % delete comments
                dep(n,m(iM))=str2num(line);
            end
            line=lower(fgetl(fid));
        end
        output=dep;
        if OPT.saveOutputFile
            delft3d_io_dep('write',outputFile,dep,'location','cor');
        end
    end
% cco2grd
    function [output,OPT] = EHY_convert_cco2grd(inputFile,outputFile,OPT)
        dw = delwaq('open',inputFile);
        grd.X = dw.X;
        grd.Y = dw.Y;
        if OPT.saveOutputFile
            wlgrid('write',outputFile,grd);
        end
        output = grd;
    end
% cco2kml
    function [output,OPT] = EHY_convert_cco2kml(inputFile,outputFile,OPT)
        if OPT.saveOutputFile
            [~,name] = fileparts(outputFile);
            tempFileGrd = [tempdir name '.grd'];
            tempFileKml = [tempdir name '.kml'];
            copyfile(inputFile,tempFileGrd);
            dw = delwaq('open',inputFile);
            grd.X = dw.X; grd.Y = dw.Y;
            [x,y,OPT] = EHY_convert_coorCheck(grd.X,grd.Y,OPT);
            if ~any(any(grd.X==x)) % coordinates have been converted
                grd.X=x; grd.Y=y; grd.CoordinateSystem='Spherical';
                wlgrid('write',tempFileGrd,grd);
            end
            grid2kml(tempFileGrd,OPT.lineColor*255);
            copyfile(tempFileKml,outputFile);
            delete(tempFileGrd)
            if exist(strrep(tempFileGrd,'.grd','.enc'))
                delete(strrep(tempFileGrd,'.grd','.enc'))
            end
            delete(tempFileKml)
        end
        output = [];
    end
% crs2kml
    function [output,OPT] = EHY_convert_crs2kml(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveOutputFile=0;
        pol=EHY_convert_crs2pol(inputFile,outputFile,OPT);
        [x,y,OPT] = EHY_convert_coorCheck(pol(:,1),pol(:,2),OPT);
        output = [x y];
        % delete multiple NaN rows
        output(find(isnan(output(2:end,1)) & isnan(output(1:end-1,1))),:)=[];
        OPT=OPT_user;
        if OPT.saveOutputFile
            % lines
            [~,name]=fileparts(outputFile);
            tempFile=[tempdir name '_lines.kml'];
            ldb2kml(output(:,1:2),tempFile,OPT.lineColor,OPT.lineWidth)
            copyfile(tempFile,strrep(outputFile,'.kml','_lines.kml'));
            delete(tempFile)
            % markers with names
            crs=delft3d_io_crs('read',inputFile);
            nanInd=unique([1; find(isnan(output(:,1))); size(output,1)]);
            xyInd=nanInd(1:end-1)+round(diff(nanInd)/2);
            KMLPlaceMark(output(xyInd,2),output(xyInd,1),strrep(outputFile,'.kml','_names.kml'),'name',{crs.DATA.name},'icon',OPT.iconFile);
        end
    end
% crs2pol
    function [output,OPT] = EHY_convert_crs2pol(inputFile,outputFile,OPT)
        crs=delft3d_io_crs('read',inputFile);
        x=[];y=[];
        [OPT,grd]=EHY_convert_gridCheck(OPT,inputFile);
        for iM=1:crs.NTables
            mrange=min(crs.DATA(iM).m):max(crs.DATA(iM).m);
            nrange=min(crs.DATA(iM).n):max(crs.DATA(iM).n);
            if length(mrange)~=1
                mrange=[mrange(1)-1 mrange];
            elseif length(nrange)~=1
                nrange=[nrange(1)-1 nrange];
            end
            x=[x;reshape(grd.X(mrange,nrange),[],1); NaN];
            y=[y;reshape(grd.Y(mrange,nrange),[],1); NaN];
        end
        output = [x y];
        if OPT.saveOutputFile
            if isfield(OPT,'fromEPSG') & isfield(OPT,'toEPSG') % convert if wanted
                [x,y]=convertCoordinates(x,y,'CS1.code',OPT.fromEPSG,'CS2.code',OPT.toEPSG);
            end
            if isnan(x(1)); x(1)=[];y(1)=[]; end; if isnan(x(end)); x(end)=[];y(end)=[]; end
            blockStart=[1; find(isnan(x))+1];
            blockEnd=[find(isnan(x))-1; length(x)];
            fid=fopen(outputFile,'w');
            for iC=1:length(crs.DATA)
                fprintf(fid,'%s\n',[crs.DATA(iC).name]);
                fprintf(fid,'%5i %5i \n',blockEnd(iC)-blockStart(iC)+1,2);
                for iX=blockStart(iC):blockEnd(iC)
                    fprintf(fid,' %20.7f %20.7f \n',x(iX),y(iX));
                end
            end
            fclose(fid);
        end
    end
% curves2crs
    function [output,OPT] = EHY_convert_curves2crs(inputFile,outputFile,OPT)
        % read curve file
        curv.p=[];
        curv.name=[];
        fid=fopen(inputFile,'r');
        while feof(fid)~=1
            line0=fgetl(fid);
            line=strtrim(line0);
            if ~isempty(line) & ~strcmp(line(1),'#')
                line=line(strfind(lower(line),'line')+4:end);
                dmy=regexpi(line, 'p.*?(\d+)', 'tokens');
                curv.p(end+1,1)=str2num(char(dmy{1}));
                curv.p(end,2)  =str2num(char(dmy{2}));
                dmy=strfind(line,'''');
                curv.name{end+1,1}=line([dmy(1)+1:dmy(2)-1]);
            end
        end
        fclose(fid);
        % Open the corresponding points/locaties-file(s)
        disp('Open the corresponding points/locaties-file(s)')
        [pointFileNames,pointFilePath]=uigetfile([fileparts(inputFile) filesep '*'],'Open the corresponding points/locaties-file(s)',...
            'MultiSelect','on');
        pointFiles=cellstr(fullfile(pointFilePath,pointFileNames));
        % read points files
        for iF=1:length(pointFiles)
            copyfile(pointFiles{iF},[tempdir 'EHY_dmy.locaties'])
            obs(iF)=EHY_convert([tempdir 'EHY_dmy.locaties'],'obs','saveOutputFile',0);
        end
        fclose('all');delete([tempdir 'EHY_dmy.locaties'])
        fn=fieldnames(obs);
        for iF=1:length(fn)
            OBS.(fn{iF})=cat(1,obs.(fn{iF}));
        end
        % find corresponding points for curves
        for iC=1:length(curv.p)
            for jj=1:2
                ind=find(OBS.p==curv.p(iC,jj));
                if isempty(ind)
                    error(['Can not find Point P ' num2str(curv.p(iC,jj)) ' in the provided Point-files'])
                else
                    ind=ind(1);
                end
                curv.m(iC,jj)= OBS.m(ind);
                curv.n(iC,jj)= OBS.n(ind);
            end
        end
        if OPT.saveOutputFile
            % write to .crs file
            fid=fopen(outputFile,'w+');
            for iC=1:size(curv.m,1)
                fprintf(fid,'%-30s %10.0f %10.0f %10.0f %10.0f\n',curv.name{iC},curv.m(iC,1),curv.n(iC,1),curv.m(iC,2),curv.n(iC,2));
            end
            fclose(fid);
        end
        output=curv;
    end
% curves2kml
    function [output,OPT] = EHY_convert_curves2kml(inputFile,outputFile,OPT)
        tempCrsFile=[fileparts(inputFile) filesep 'EHY_temporary.crs'];
        [output,OPT] = EHY_convert_curves2crs(inputFile,tempCrsFile,OPT);
        if OPT.saveOutputFile
            [output,OPT] = EHY_convert_crs2kml(tempCrsFile,outputFile,OPT);
            fclose('all');delete(tempCrsFile);
        end
    end
% dep2box
    function [output,OPT] = EHY_convert_dep2box(inputFile,outputFile,OPT)
        [OPT,grd]=EHY_convert_gridCheck(OPT,inputFile);
        msize=size(grd.X,1);
        nsize=size(grd.X,2);
        try
            dep=wldep('read',inputFile,[msize+2 nsize+2]); % extra dummy's
        catch
            dep=wldep('read',inputFile,[msize+1 nsize+1]);
        end
        if OPT.saveOutputFile
            if exist(outputFile,'file'); delete(outputFile); end
            fid=fopen(outputFile,'a+');
            for iN=1:10:nsize
                nrange=[iN:iN+9];
                nrange(nrange>nsize+1)=[];
                fprintf(fid,'%s\n',['BOX MNMN=(' sprintf('%5.0f',1) ',' sprintf('%5.0f',nrange(1)) ';' ...
                    sprintf('%5.0f',msize+1) ',' sprintf('%5.0f',nrange(end)) '), VARIABLE_VAL = ']);
                for iM=1:msize+1
                    fprintf(fid,[repmat('%10.4f',1,length(nrange)) '\n'],dep(iM,nrange));
                end
            end
            fclose(fid);
        end
        output=dep;
    end
% dry2xdrykml
    function [output,OPT] = EHY_convert_dry2xdrykml(inputFile,outputFile,OPT)
        OPT_user.saveOutputFile=OPT.saveOutputFile;
        OPT.saveOutputFile=0;
        [ldb,OPT] = EHY_convert_dry2xdryldb(inputFile,outputFile,OPT);
        OPT.saveOutputFile=OPT_user.saveOutputFile;
        if OPT.saveOutputFile
            [ldb(:,1),ldb(:,2),OPT] = EHY_convert_coorCheck(ldb(:,1),ldb(:,2),OPT);
            [~,name]=fileparts(outputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(ldb(:,1:2),tempFile,OPT.lineColor,OPT.lineWidth)
            copyfile(tempFile,outputFile);
            delete(tempFile);
        end
        output=ldb;
    end
% dry2xdryldb
    function [output,OPT] = EHY_convert_dry2xdryldb(inputFile,outputFile,OPT)
        dry=delft3d_io_dry('read',inputFile);
        [OPT,grd]=EHY_convert_gridCheck(OPT,inputFile);
        ldb=[];
        for iM=1:length(dry.m)
            mm=dry.m(iM);
            nn=dry.n(iM);
            crossInd=[mm-1 mm-1 mm   mm mm-1 mm   mm-1 mm;,...
                nn   nn-1 nn-1 nn nn   nn-1 nn-1 nn];
            crossInd=sub2ind(size(grd.X),crossInd(1,:),crossInd(2,:));
            ldb=[ldb;grd.X(crossInd)' grd.Y(crossInd)'; NaN NaN];
        end
        if OPT.saveOutputFile
            io_polygon('write',outputFile,ldb);
        end
        output=ldb;
    end
% dry2thd
    function [output,OPT] = EHY_convert_dry2thd(inputFile,outputFile,OPT)
        dry=delft3d_io_dry('read',inputFile);
        thd.DATA=struct;
        for iM=1:length(dry.m)
            if iM==1
                thd.DATA(end).mn=[dry.m(iM);dry.n(iM);dry.m(iM);dry.n(iM)];
                thd.DATA(end).direction='U';
            else
                thd.DATA(end+1).mn=[dry.m(iM);dry.n(iM);dry.m(iM);dry.n(iM)];
                thd.DATA(end).direction='U';
            end
            thd.DATA(end+1).mn=[dry.m(iM);dry.n(iM);dry.m(iM);dry.n(iM)];
            thd.DATA(end).direction='V';
            thd.DATA(end+1).mn=[dry.m(iM)-1;dry.n(iM);dry.m(iM)-1;dry.n(iM)];
            thd.DATA(end).direction='U';
            thd.DATA(end+1).mn=[dry.m(iM);dry.n(iM)-1;dry.m(iM);dry.n(iM)-1];
            thd.DATA(end).direction='V';
        end
        if OPT.saveOutputFile
            delft3d_io_thd('write',outputFile,thd)
        end
        output = [];
    end
% dry2xyz
    function [output,OPT] = EHY_convert_dry2xyz(inputFile,outputFile,OPT)
        dry=delft3d_io_dry('read',inputFile);
        OPT = EHY_convert_gridCheck(OPT,inputFile);
        [x,y]=EHY_mn2xy(dry.m,dry.n,OPT.grdFile);
        xyz=[x y zeros(length(x),1)];
        if OPT.saveOutputFile
            dlmwrite(outputFile,xyz,'delimiter',' ','precision','%20.7f')
        end
        output=xyz;
    end
% ext2kml
    function [output,OPT] = EHY_convert_ext2kml(inputFile,outputFile,OPT)
        fid=fopen(inputFile);
        ext=textscan(fid,'%s','delimiter','\n');ext=ext{1,1};
        fclose(fid);
        indPli=strfind(ext,'.pli');
        indPli = find(not(cellfun('isempty',indPli)));
        % do not plot initial profiles
        indInitialvertical=strfind(ext,'initialvertical');
        indInitialvertical = find(not(cellfun('isempty',indInitialvertical)))+1;
        indPli(ismember(indPli,indInitialvertical))=[];
        [~,pliFiles]=strtok({ext{indPli}},'=');
        if isempty(pliFiles)
            output = [];
        else
            pliFiles=unique(strtrim(strrep(pliFiles,'=','')));
            pliFiles=cellstr(EHY_getFullWinPath(pliFiles,fileparts(inputFile)));
            PLI=[];
            for iF=1:length(pliFiles)
                pol=io_polygon('read',pliFiles{iF});
                pol(pol==-999)=NaN;
                xyn.x(iF)=nanmean(pol(:,1));xyn.y(iF)=nanmean(pol(:,2));
                [~,xyn.name{iF}]=fileparts(pliFiles{iF});
                PLI=[PLI;NaN NaN; pol(:,1:2)];
            end
            [PLI(:,1),PLI(:,2),OPT] = EHY_convert_coorCheck(PLI(:,1),PLI(:,2),OPT);
            [xyn.x,xyn.y,OPT] = EHY_convert_coorCheck(xyn.x,xyn.y,OPT);
            if OPT.saveOutputFile
                ldb2kml(PLI(:,1:2),strrep(outputFile,'.kml','_lines.kml'),OPT.lineColor,OPT.lineWidth);
                KMLPlaceMark(xyn.y,xyn.x,strrep(outputFile,'.kml','_names.kml'),'name',xyn.name,'icon',OPT.iconFile);
            end
            output=PLI;
        end
    end
% grd2kml
    function [output,OPT] = EHY_convert_grd2kml(inputFile,outputFile,OPT)
        if OPT.saveOutputFile
            [~,name]=fileparts(outputFile);
            tempFileGrd=[tempdir name '.grd'];
            tempFileKml=[tempdir name '.kml'];
            copyfile(inputFile,tempFileGrd);
            grd=wlgrid('read',tempFileGrd);
            [x,y,OPT] = EHY_convert_coorCheck(grd.X,grd.Y,OPT);
            if ~any(any(grd.X==x)) % coordinates have been converted
                grd.X=x; grd.Y=y; grd.CoordinateSystem='Spherical';
                wlgrid('write',tempFileGrd,grd);
            end
            grid2kml(tempFileGrd,OPT.lineColor*255);
            copyfile(tempFileKml,outputFile,'f');
            delete(tempFileGrd)
            delete(strrep(tempFileGrd,'.grd','.enc'))
            delete(tempFileKml)
        end
        output = [];
    end
% grd2nc
    function [output,OPT] = EHY_convert_grd2nc(inputFile,outputFile,OPT)
        if OPT.saveOutputFile
            % based on d3d2dflowfm_grd2net
            G             = delft3d_io_grd('read',inputFile);
            xh            = G.cor.x';
            yh            = G.cor.y';
            mmax          = G.mmax;
            nmax          = G.nmax;
            xh(mmax,:)    = NaN;
            yh(mmax,:)    = NaN;
            xh(:,nmax)    = NaN;
            yh(:,nmax)    = NaN;
            spher         = 0;
            if strcmp(G.CoordinateSystem,'Spherical');
                spher     = 1;
            end
            zh            = -5.*ones(mmax,nmax);
            netfile=outputFile;
            
            % delete old file first in case of overwrite
            if OPT.overwrite && exist(netfile,'file')
                delete(netfile);
            end
            % to avoid error of variables being created in below function
            X=[];Y=[];Z=[];NetNode_mask=[];nNetNode=[];vals=[];nc=[];ifld=[];attr=[];dims=[];
            ContourLink=[];NetLink=[];
            convertWriteNetcdf;
            disp('For grd2nc conversion incl. depth, have a look at function ''d3d2dflowfm_grd2net.m'' ');
        end
        output = [];
    end
% grd2ldb
    function [output,OPT] = EHY_convert_grd2ldb(inputFile,outputFile,OPT)
        gridInfo = EHY_getGridInfo(inputFile,{'grid'});
        output = gridInfo.grid;
        if OPT.saveOutputFile
            io_polygon('write',outputFile,output);
        end
    end
% grd2pol
    function [output,OPT] = EHY_convert_grd2pol(inputFile,outputFile,OPT)
        gridInfo = EHY_getGridInfo(inputFile,{'grid'});
        output = gridInfo.grid;
        if OPT.saveOutputFile
            io_polygon('write',outputFile,output);
        end
    end
% grd2shp
    function [output,OPT] = EHY_convert_grd2shp(inputFile,outputFile,OPT)
        gridInfo = EHY_getGridInfo(inputFile,{'grid'});
        output = gridInfo.grid;
        nanInd = find(isnan(output(:,1)));
        if nanInd(1)~=1; nanInd = [0; nanInd]; end
        if nanInd(end)~=size(output,1); nanInd(end+1) = NaN; end
        for ii = 1:length(nanInd)-1
            shp{ii} = output(nanInd(ii)+1:nanInd(ii+1)-1,1:2);
        end
        if OPT.saveOutputFile
            shapewrite(outputFile,'polyline',shp,{})
        end
    end
% kml2ldb
    function [output,OPT] = EHY_convert_kml2ldb(inputFile,outputFile,OPT)
        copyfile(inputFile,[tempdir 'kmlpath.kml'])
        output = kml2ldb(0,[tempdir 'kmlpath.kml']);
        if OPT.saveOutputFile
            landboundary('write',outputFile,output,'dosplit');
        end
        fclose all;
        delete([tempdir 'kmlpath.kml'])
    end
% kml2pol
    function [output,OPT] = EHY_convert_kml2pol(inputFile,outputFile,OPT)
        copyfile(inputFile,[tempdir 'kmlpath.kml'])
        [output, names] = kml2ldb(0,[tempdir 'kmlpath.kml']);
        if OPT.saveOutputFile
            if ~isempty(names{1,1})
                landboundary('write',outputFile,output,'names',names,'dosplit');
            else
                landboundary('write',outputFile,output,'dosplit');
            end
        end
        fclose all;
        delete([tempdir 'kmlpath.kml'])
    end
% kml2shp
    function [output,OPT] = EHY_convert_kml2shp(inputFile,outputFile,OPT)
        OPT_user = OPT;
        OPT.saveOutputFile = 0;
        lines = EHY_convert_kml2pol(inputFile,outputFile,OPT);
        OPT = OPT_user;
        nanInd = find(isnan(lines(:,1)));
        if nanInd(1)~=1; nanInd = [0; nanInd]; end
        if nanInd(end)~=size(lines,1); nanInd(end+1) = NaN; end
        for ii=1:length(nanInd)-1
            lines2{ii}=lines(nanInd(ii)+1:nanInd(ii+1)-1,1:2);
        end
        if OPT.saveOutputFile
            shapewrite(outputFile,'polyline',lines2,{})
        end
        output=lines;
    end
% kml2xyn
    function [output,OPT] = EHY_convert_kml2xyn(inputFile,outputFile,OPT)
        kml = xml_read(inputFile);
        if any(contains(fieldnames(kml),'Document')) %JV: remove unwanted kml level
            kml = kml.Document;
        end
        if any(contains(fieldnames(kml),'Folder')) %JV: remove unwanted kml level
            kml.Placemark = kml.Folder.Placemark;
        end
        for ii=1:length(kml.Placemark)
            names{ii,1}=kml.Placemark(ii).name;
            if ischar(kml.Placemark(ii).Point.coordinates) %for normal kml files
                coords=regexp(kml.Placemark(ii).Point.coordinates,',','split');
                x(ii,1)=str2num(coords{1});
                y(ii,1)=str2num(coords{2});
            else %JV: for kml files written with ldb2kml
                coords=kml.Placemark(ii).Point.coordinates;
                x(ii,1)=coords(1);
                y(ii,1)=coords(2);
            end
        end
        output={x y names};
        if OPT.saveOutputFile
            fid=fopen(outputFile,'w');
            for iM=1:length(x)
                fprintf(fid,'%20.7f%20.7f ',[x(iM,1) y(iM,1)]);
                fprintf(fid,'%-s\n',['''' strtrim(names{iM}) '''']);
            end
            fclose(fid);
        end
    end
% kml2xyz
    function [output,OPT] = EHY_convert_kml2xyz(inputFile,outputFile,OPT)
        xyz=kml2ldb(0,inputFile);
        xyz(isnan(xyz(:,1)),:)=[];
        xyz(:,3)=0;
        if OPT.saveOutputFile
            dlmwrite(outputFile,xyz,'delimiter',' ','precision','%20.7f');
        end
        output=xyz;
    end
% ldb2kml
    function [output,OPT] = EHY_convert_ldb2kml(inputFile,outputFile,OPT)
        ldb=landboundary('read',inputFile);
        if OPT.saveOutputFile
            [ldb(:,1),ldb(:,2),OPT] = EHY_convert_coorCheck(ldb(:,1),ldb(:,2),OPT);
            [~,name]=fileparts(outputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(ldb(:,1:2),tempFile,OPT.lineColor,OPT.lineWidth)
            copyfile(tempFile,outputFile);
            delete(tempFile);
        end
        output = [];
    end
% ldb2pol
    function [output,OPT] = EHY_convert_ldb2pol(inputFile,outputFile,OPT)
        if OPT.saveOutputFile
            copyfile(inputFile,outputFile);
        end
        ldb=landboundary('read',inputFile);
        output=ldb;
    end
% ldb2shp
    function [output,OPT] = EHY_convert_ldb2shp(inputFile,outputFile,OPT)
        ldb = landboundary('read',inputFile);
        nanInd = find(isnan(ldb(:,1)));
        if nanInd(1)~=1; nanInd = [0; nanInd]; end
        if nanInd(end)~=size(ldb,1); nanInd(end+1) = size(ldb,1)+1; end
        for ii = 1:length(nanInd)-1
            ldb2{ii} = ldb(nanInd(ii)+1:nanInd(ii+1)-1,1:2);
        end
        if OPT.saveOutputFile
            shapewrite(outputFile,'polyline',ldb2,{})
        end
        output=ldb;
    end
% locaties2kml
    function [output,OPT] = EHY_convert_locaties2kml(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveOutputFile=0;
        xyn=EHY_convert_locaties2xyn(inputFile,outputFile,OPT);
        [xyn{1,1},xyn{1,2},OPT] = EHY_convert_coorCheck(xyn{1,1},xyn{1,2},OPT);
        OPT=OPT_user;
        if OPT.saveOutputFile
            [~,name]=fileparts(outputFile);
            tempFile=[tempdir name '.kml'];
            KMLPlaceMark(xyn{1,2},xyn{1,1},tempFile,'name',xyn{1,3}','icon',OPT.iconFile);
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output = [];
    end
% locaties2obs
    function [output,OPT] = EHY_convert_locaties2obs(inputFile,outputFile,OPT)
        obs.p=[];
        obs.m=[];
        obs.n=[];
        obs.namst=[];
        fid=fopen(inputFile,'r');
        while feof(fid)~=1
            line0=fgetl(fid);
            line=strtrim(line0);
            if ~isempty(line) & ~strcmp(line(1),'#')
                dmy=regexpi(line, 'p.*?(\d+)', 'tokens', 'once');
                obs.p(end+1,1)=str2num(dmy{1});
                dmy=regexpi(line, 'm.*?=.*?(\d+)', 'tokens', 'once');
                obs.m(end+1,1)=str2num(dmy{1});
                dmy=regexpi(line, 'n.*?=.*?(\d+)', 'tokens', 'once');
                obs.n(end+1,1)=str2num(dmy{1});
                dmy=strfind(line,'''');
                obs.namst{end+1,1}=line([dmy(1)+1:dmy(2)-1]);
            end
        end
        fclose(fid);
        if OPT.saveOutputFile
            delft3d_io_obs('write',outputFile,obs);
        end
        output=obs;
    end
% locaties2xyn
    function [output,OPT] = EHY_convert_locaties2xyn(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveOutputFile=0;
        obs=EHY_convert_locaties2obs(inputFile,outputFile,OPT);
        OPT=OPT_user;
        pathstr = fileparts(inputFile);
        OPT = EHY_convert_gridCheck(OPT,inputFile);
        [x,y]=EHY_mn2xy(obs.m,obs.n,OPT.grdFile);
        if OPT.saveOutputFile
            fid=fopen(outputFile,'w');
            for iM=1:length(x)
                fprintf(fid,'%20.7f%20.7f ',[x(iM,1) y(iM,1)]);
                fprintf(fid,'%-s\n',['''' strtrim(obs.namst{iM}) '''']);
            end
            fclose(fid);
        end
        output={x y cellstr(obs.namst)};
    end
% mdf2xlsx
    function [output,OPT] = EHY_convert_mdf2xlsx(inputFile,outputFile,OPT)
        mdf = delft3d_io_mdf('read',inputFile);
        output = {};
        fns = fieldnames(mdf.keywords);
        for i = 1:length(fns)
            output{end+1,1} = fns{i};
            output{end  ,2} = mdf.keywords.(fns{i});
        end
        if OPT.saveOutputFile
            xlswrite(outputFile,output);
        end
    end
% mdu2xlsx
    function [output,OPT] = EHY_convert_mdu2xlsx(inputFile,outputFile,OPT)
        mdu = dflowfm_io_mdu('read',inputFile);
        output = {};
        ind = 0;
        fns = fieldnames(mdu);
        for i = 1:length(fns)
            ind = ind + 1;
            output{ind,1} = fns{i};
            fns2 = fieldnames(mdu.(fns{i}));
            for j = 1:length(fns2)
                output{ind,2} = fns2{j};
                output{end,3} = mdu.(fns{i}).(fns2{j});
                ind = ind + 1;
            end
        end
        if OPT.saveOutputFile
            xlswrite(outputFile,output);
        end
    end
% nc2kml
    function [output,OPT] = EHY_convert_nc2kml(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveOutputFile=0;
        lines=EHY_convert_nc2ldb(inputFile,outputFile,OPT);
        OPT=OPT_user;
        lines=ipGlueLDB(lines);
        if OPT.saveOutputFile
            [lines(:,1),lines(:,2),OPT] = EHY_convert_coorCheck(lines(:,1),lines(:,2),OPT);
            [~,name]=fileparts(outputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(lines,tempFile,OPT.lineColor,OPT.lineWidth)
            copyfile(tempFile,outputFile,'f');
            delete(tempFile)
        end
        output=lines;
    end
% nc2ldb
    function [output,OPT] = EHY_convert_nc2ldb(inputFile,outputFile,OPT)
        gridInfo = EHY_getGridInfo(inputFile,{'XYcor','edge_nodes'},'disp',0,'mergePartitions',OPT.mergePartitions);
        edges = gridInfo.edge_nodes;
        x = gridInfo.Xcor; y = gridInfo.Ycor;
        lines = zeros(length(edges)*3,2);
        lines(3*(1:length(edges))-2,:) = [x(edges(1,:)) y(edges(1,:))];
        lines(3*(1:length(edges))-1,:) = [x(edges(2,:)) y(edges(2,:))];
        lines(3*(1:length(edges)),:) = NaN;
        if OPT.saveOutputFile
            io_polygon('write',outputFile,lines);
        end
        output = lines;
    end
% nc2shp
    function [output,OPT] = EHY_convert_nc2shp(inputFile,outputFile,OPT)
        GI = EHY_getGridInfo(inputFile,'face_nodes_xy');
        if isfield(GI,'face_nodes_x')
            % write as shape 'polygon'
            
            XYcell(1:size(GI.face_nodes_x,2),1) = {[]};
            for i = 1:size(GI.face_nodes_x,2)
                nonan = ~isnan(GI.face_nodes_x(:,i));
                XYcell{i,1} = [GI.face_nodes_x(nonan,i) GI.face_nodes_y(nonan,i)];
            end
            
            if OPT.saveOutputFile
                shapewrite(outputFile,'polygon',XYcell)
            end
            output.face_nodes_x = GI.face_nodes_x;
            output.face_nodes_y = GI.face_nodes_y;
        else
            % write as shape 'polyline'
            disp('There is no UGRID-info available in your network. A shapefile ''polyline'' is created.')
            disp('In case you want a shapefile ''polygon'', save your grid as UGRID (via RGFGRID or interacter [open grid, save as.. UGRID]) and try again.')
            OPT_user = OPT;
            OPT.saveOutputFile = 0;
            lines = EHY_convert_nc2ldb(inputFile,outputFile,OPT);
            OPT = OPT_user;
            nanInd = find(isnan(lines(:,1)));
            if nanInd(1)~=1; nanInd = [0; nanInd]; end
            if nanInd(end)~=size(lines,1); nanInd(end+1) = NaN; end
            for ii = 1:length(nanInd)-1
                lines2{ii} = lines(nanInd(ii)+1:nanInd(ii+1)-1,1:2);
            end
            if OPT.saveOutputFile
                shapewrite(outputFile,'polyline',lines2,{})
            end
            output = lines;
        end
    end
% obs2kml
    function [output,OPT] = EHY_convert_obs2kml(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveOutputFile=0;
        xyn=EHY_convert_obs2xyn(inputFile,outputFile,OPT);
        [xyn.x,xyn.y,OPT] = EHY_convert_coorCheck(xyn.x,xyn.y,OPT);
        OPT=OPT_user;
        if OPT.saveOutputFile
            [~,name]=fileparts(outputFile);
            tempFile=[tempdir name '.kml'];
            KMLPlaceMark(xyn.y,xyn.x,tempFile,'name',xyn.name,'icon',OPT.iconFile);
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output = [];
    end
% obs2locaties
    function [output,OPT] = EHY_convert_obs2locaties(inputFile,outputFile,OPT)
        obs=delft3d_io_obs('read',inputFile);
        if OPT.saveOutputFile
            fid=fopen(outputFile,'w');
            for iMN=1:length(obs.m)
                fprintf(fid,'P %d = (M = %5d, N = %5d, NAME = ''%s'')\n',4000+iMN,obs.m(iMN),obs.n(iMN),obs.namst(iMN,:));
            end
            fclose(fid);
            disp('You may want to change/check the observation point numbers yourself (e.g. P 4001 = .. )')
        end
        output=obs;
    end
% obs2xyn
    function [output,OPT] = EHY_convert_obs2xyn(inputFile,outputFile,OPT)
        pathstr = fileparts(inputFile);
        obs=delft3d_io_obs('read',inputFile);
        OPT = EHY_convert_gridCheck(OPT,inputFile);
        [xyn.x,xyn.y]=EHY_mn2xy(obs.m,obs.n,OPT.grdFile);
        xyn.name=obs.namst;
        if ischar(xyn.name)
            xyn.name=cellstr(xyn.name);
        end
        if OPT.saveOutputFile
            delft3d_io_xyn('write',outputFile,xyn);
        end
        output=xyn;
    end
% pliz2kml
    function [output,OPT] = EHY_convert_pliz2kml(inputFile,outputFile,OPT)
        if OPT.saveOutputFile
            T=tekal('read',inputFile,'loaddata');
            pol=[];
            for iT=1:length(T.Field)
                pol=[pol; T.Field(iT).Data(:,1:2); NaN NaN];
            end
            pol(end,:)=[];
            [pol(:,1),pol(:,2),OPT] = EHY_convert_coorCheck(pol(:,1),pol(:,2),OPT);
            if OPT.saveOutputFile
                [~,name]=fileparts(outputFile);
                tempFile=[tempdir name '.kml'];
                ldb2kml(pol(:,1:2),tempFile,OPT.lineColor,OPT.lineWidth)
                copyfile(tempFile,outputFile);
                delete(tempFile)
            end
            output=pol;
        end
    end
% pliz2pol
    function [output,OPT] = EHY_convert_pliz2pol(inputFile,outputFile,OPT)
        if OPT.saveOutputFile
            T=tekal('read',inputFile,'loaddata');
            pol=[];
            for iT=1:length(T.Field)
                pol=[pol; T.Field(iT).Data(:,1:2); NaN NaN];
            end
            pol(end,:)=[];
            if OPT.saveOutputFile
                io_polygon('write',outputFile,pol,'dosplit');
            end
            output=pol;
        end
    end
% pol2kml
    function [output,OPT] = EHY_convert_pol2kml(inputFile,outputFile,OPT)
        pol=landboundary('read',inputFile);
        [pol(:,1),pol(:,2),OPT] = EHY_convert_coorCheck(pol(:,1),pol(:,2),OPT);
        %read names of pol 
        %This could be done inside <landboundary>, but I do not want to mess up too much
        T=tekal('open',inputFile,'loaddata');
        names={T.Field.Name};
        if OPT.saveOutputFile
            % polylines
            [~,name]=fileparts(outputFile);
            tempFile=[tempdir name '.kml'];
            try % including 'names'-arguments 
                ldb2kml(pol(:,1:2),tempFile,OPT.lineColor,OPT.lineWidth,names)
            catch % An older version of ldb2kml is being used
                disp(['Please consider updating the ldb2kml-function: ' which('ldb2kml') ])
                ldb2kml(pol(:,1:2),tempFile,OPT.lineColor,OPT.lineWidth)
            end
            copyfile(tempFile,outputFile);
            delete(tempFile)
            % markers with names
            nanInd=unique([1; find(isnan(pol(:,1))); size(pol,1)]);
            xyInd=nanInd(1:end-1)+round(diff(nanInd)/2);
            KMLPlaceMark(pol(xyInd,2),pol(xyInd,1),strrep(outputFile,'.kml','_names.kml'),'name',names,'icon',OPT.iconFile);
        end
        output = [];
    end
% pol2ldb
    function [output,OPT] = EHY_convert_pol2ldb(inputFile,outputFile,OPT)
        if OPT.saveOutputFile
            copyfile(inputFile,outputFile)
        end
        output=landboundary('read',inputFile);
    end
% pol2shp
    function [output,OPT] = EHY_convert_pol2shp(inputFile,outputFile,OPT)
        pol=landboundary('read',inputFile);
        if ~isnan(pol(1,1)); pol=[NaN NaN; pol(:,1:2)];  end
        if ~isnan(pol(end,1)); pol=[pol(:,1:2);NaN NaN]; end
        
        nanInd=find(isnan(pol(:,1)));
        if nanInd(1)~=1; nanInd = [0; nanInd]; end
        if nanInd(end)~=size(pol,1); nanInd(end+1) = NaN; end
        for ii=1:length(nanInd)-1
            pol2{ii}=pol(nanInd(ii)+1:nanInd(ii+1)-1,1:2);
        end
        if OPT.saveOutputFile
            shapewrite(outputFile,'polyline',pol2,{})
        end
        output=pol;
    end
% pol2xyz
    function [output,OPT] = EHY_convert_pol2xyz(inputFile,outputFile,OPT)
        xyz=landboundary('read',inputFile);
        xyz(isnan(xyz(:,1)),:)=[];
        if OPT.saveOutputFile
            dlmwrite(outputFile,xyz);
        end
        output=xyz;
    end
% shp2kml
    function [output,OPT] = EHY_convert_shp2kml(inputFile,outputFile,OPT)
        ldb = shape2ldb(inputFile,0);
        if iscell(ldb) && numel(ldb) == 1
            ldb = ldb{1};
        end
        if OPT.saveOutputFile
            [ldb(:,1),ldb(:,2),OPT] = EHY_convert_coorCheck(ldb(:,1),ldb(:,2),OPT);
            [~,name] = fileparts(outputFile);
            tempFile = [tempdir name '.kml'];
            ldb2kml(ldb(:,1:2),tempFile,OPT.lineColor,OPT.lineWidth)
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output = ldb;
    end
% shp2ldb
    function [output,OPT] = EHY_convert_shp2ldb(inputFile,outputFile,OPT)
        output = shape2ldb(inputFile,0);
        if iscell(output)
            if numel(output) == 1
                output = output{1};
            else
                ldb = [];
                for i = 1:length(output)
                    ldb = [ldb; NaN NaN; output{i,1}(:,1:2)];
                end
                output = ldb(2:end,:);
            end
        end
        if OPT.saveOutputFile
            landboundary('write',outputFile,output(:,1:2));
        end
    end
% shp2pol
    function [output,OPT] = EHY_convert_shp2pol(inputFile,outputFile,OPT)
        output = shape2ldb(inputFile,0);
        if iscell(output)
            if numel(output) == 1
                output = output{1};
            else
                output0 = output;
                output = [];
                for i = 1:length(output0)
                    output = [output; NaN NaN; output0{i}];
                end
                output = output(2:end,:); % remove first row of NaN's
            end
        end
        if OPT.saveOutputFile
            io_polygon('write',outputFile,output(:,1:2));
        end
    end
% src2kml
    function [output,OPT] = EHY_convert_src2kml(inputFile,outputFile,OPT)
        OPT_user = OPT;
        OPT.saveOutputFile = 0;
        xyn = EHY_convert_src2xyn(inputFile,outputFile,OPT);
        [xyn.x,xyn.y] = EHY_convert_coorCheck(xyn.x,xyn.y,OPT);
        OPT = OPT_user;
        if OPT.saveOutputFile
            [~,name] = fileparts(outputFile);
            tempFile = [tempdir name '.kml'];
            KMLPlaceMark(xyn.x,xyn.y,tempFile,'name',xyn.name,'icon',OPT.iconFile);
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output = [];
    end
% src2xyn
    function [output,OPT] = EHY_convert_src2xyn(inputFile,outputFile,OPT)
        src = delft3d_io_src('read',inputFile);
        OPT = EHY_convert_gridCheck(OPT,inputFile);
        [x,y] = EHY_mn2xy(src.m,src.n,OPT.grdFile);
        
        if OPT.saveOutputFile
            fid = fopen(outputFile,'w');
            for iM = 1:length(x)
                fprintf(fid,'%20.7f%20.7f ',[x(iM,1) y(iM,1)]);
                fprintf(fid,'%-s\n',['''' strtrim(src.DATA(iM).name) '''']);
            end
            fclose(fid);
        end
        output.x = reshape(x,1,[]);
        output.y = reshape(y,1,[]);
        output.name = reshape({src.DATA.name},1,[]);
    end
% thd2kml
    function [output,OPT] = EHY_convert_thd2kml(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveOutputFile=0;
        pol=EHY_convert_thd2pol(inputFile,outputFile,OPT);
        [pol(:,1),pol(:,2),OPT] = EHY_convert_coorCheck(pol(:,1),pol(:,2),OPT);
        output=pol;
        OPT=OPT_user;
        if OPT.saveOutputFile
            [~,name]=fileparts(outputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(output(:,1:2),tempFile,OPT.lineColor,OPT.lineWidth)
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
    end
% thd2pol
    function [output,OPT] = EHY_convert_thd2pol(inputFile,outputFile,OPT)
        thd=delft3d_io_thd('read',inputFile);
        x=[];y=[];
        [OPT,grd]=EHY_convert_gridCheck(OPT,inputFile);
        
        for iM=1:thd.NTables
            if strcmpi(thd.DATA(iM).direction,'U')
                x=[x;grd.X(thd.DATA(iM).m(1),thd.DATA(iM).n(1));...
                    grd.X(thd.DATA(iM).m(1),thd.DATA(iM).n(1)-1); NaN];
                y=[y;grd.Y(thd.DATA(iM).m(1),thd.DATA(iM).n(1));...
                    grd.Y(thd.DATA(iM).m(1),thd.DATA(iM).n(1)-1); NaN];
            else
                x=[x;grd.X(thd.DATA(iM).m(1),thd.DATA(iM).n(1));...
                    grd.X(thd.DATA(iM).m(1)-1,thd.DATA(iM).n(1)); NaN];
                y=[y;grd.Y(thd.DATA(iM).m(1),thd.DATA(iM).n(1));...
                    grd.Y(thd.DATA(iM).m(1)-1,thd.DATA(iM).n(1)); NaN];
            end
        end
        output = [x y];
        if OPT.saveOutputFile
            io_polygon('write',outputFile,x,y,'dosplit','-1');
        end
    end
% xyn2kml
    function [output,OPT] = EHY_convert_xyn2kml(inputFile,outputFile,OPT)
        try
            xyn=delft3d_io_xyn('read',inputFile);
        catch
            fid=fopen(inputFile,'r');
            D=textscan(fid,'%f%f%s','delimiter','\n');
            fclose(fid);
            xyn.x=D{1,1};
            xyn.y=D{1,2};
            xyn.name=D{1,3};
        end
        [xyn.x,xyn.y,OPT] = EHY_convert_coorCheck(xyn.x,xyn.y,OPT);
        if OPT.saveOutputFile
            [~,name]=fileparts(outputFile);
            tempFile=[tempdir name '.kml'];
            KMLPlaceMark(xyn.y,xyn.x,tempFile,'name',xyn.name,'icon',OPT.iconFile);
            copyfile(tempFile,outputFile);
            delete(tempFile);
        end
        output = [];
    end
% xyn2locaties
    function [output,OPT] = EHY_convert_xyn2locaties(inputFile,outputFile,OPT)
        try
            xyn=delft3d_io_xyn('read',inputFile);
        catch
            fid=fopen(inputFile,'r');
            D=textscan(fid,'%f%f%s','delimiter','\n');
            fclose(fid);
            xyn.x=D{1,1};
            xyn.y=D{1,2};
            xyn.name=D{1,3};
        end
        OPT = EHY_convert_gridCheck(OPT,inputFile);
        [obs.m,obs.n]=EHY_xy2mn(xyn.x,xyn.y,OPT.grdFile);
        obs.namst = xyn.name;
        if OPT.saveOutputFile
            fid=fopen(outputFile,'w');
            for iMN=1:length(obs.m)
                fprintf(fid,'P %d = (M = %5d, N = %5d, NAME = ''%s'')\n',4000+iMN,obs.m(iMN),obs.n(iMN),obs.namst{iMN});
            end
            fclose(fid);
            disp('You may want to change/check the observation point numbers yourself (e.g. P 4001 = .. )')
        end
        output=obs;
    end
% xyn2obs
    function [output,OPT] = EHY_convert_xyn2obs(inputFile,outputFile,OPT)
        try
            xyn=delft3d_io_xyn('read',inputFile);
        catch
            fid=fopen(inputFile,'r');
            D=textscan(fid,'%f%f%s','delimiter','\n');
            fclose(fid);
            xyn.x=D{1,1};
            xyn.y=D{1,2};
            xyn.name=D{1,3};
        end
        OPT = EHY_convert_gridCheck(OPT,inputFile);
        [m,n]=EHY_xy2mn(xyn.x,xyn.y,OPT.grdFile);
        if OPT.saveOutputFile
            obs.m=m; obs.n=n; obs.namst=xyn.name;
            delft3d_io_obs('write',outputFile,obs);
        end
        output = [reshape(m,[],1) reshape(n,[],1)];
    end
% xyn2segmnr
    function [output,OPT] = EHY_convert_xyn2segmnr(inputFile,outputFile,OPT)
        try
            xyn=delft3d_io_xyn('read',inputFile);
        catch
            fid=fopen(inputFile,'r');
            D=textscan(fid,'%f%f%s','delimiter','\n');
            fclose(fid);
            xyn.x=D{1,1};
            xyn.y=D{1,2};
            xyn.name=D{1,3};
        end
        OPT = EHY_convert_ccoCheck(OPT,inputFile);
        GI = EHY_getGridInfo(OPT.grdFile,{'XYcen','no_layers'});
        [~,~,ext] = fileparts(OPT.grdFile);
        [k,dist] = dsearchn([GI.Xcen(:) GI.Ycen(:)],[reshape(xyn.x,[],1) reshape(xyn.y,[],1)]);
        [m,n] = ind2sub(size(GI.Xcen),k);
        if ismember(ext,{'.lga','.cco'})
            dw = delwaq('open',OPT.grdFile);
            m = m+1;
            n = n+1;
        elseif strcmp(ext,'.nc')
            dw.Index(:,1) = 1:length(GI.Xcen);
            dw.NoSegPerLayer = length(GI.Xcen);
            GI.no_layers = 36;
        end
        for i = 1:length(m)
            output.segmnr(i,1) = dw.Index(m(i),n(i),1);
        end
        output.name = reshape(xyn.name,[],1);
        no_stat = length(output.name);
        for iS = 1:no_stat
        for k = 1:GI.no_layers
            output.name{end+1} = [output.name{iS} ' (' num2str(k) ')' ];
            output.segmnr(end+1) = output.segmnr(iS) + (k-1)*dw.NoSegPerLayer;
        end
        end
        
        if OPT.saveOutputFile
            fid = fopen(outputFile,'w');
            for i = 1:length(output.segmnr)
                fprintf(fid,'%-s\t1\t%d \n',['''' output.name{i} ''''],output.segmnr(i));
            end
            fclose(fid);
        end
    end
% xyn2src
    function [output,OPT] = EHY_convert_xyn2src(inputFile,outputFile,OPT)
        xyn = delft3d_io_xyn('read',inputFile);
        OPT = EHY_convert_gridCheck(OPT,inputFile);
        [m,n] = EHY_xy2mn(xyn.x,xyn.y,OPT.grdFile);
        for i = 1:length(m)
            src(i).name = xyn.name{i};
            src(i).interpolation = 'Y';
            src(i).m = m(i);
            src(i).n = n(i);
            src(i).k = 0;
            src(i).type = [];
        end
        if OPT.saveOutputFile
            delft3d_io_src('write',outputFile,src)
        end
        output = src;
    end
% xyn2xyz
    function [output,OPT] = EHY_convert_xyn2xyz(inputFile,outputFile,OPT)
        try
            xyn = delft3d_io_xyn('read',inputFile);
        catch
            fid = fopen(inputFile,'r');
            D = textscan(fid,'%f%f%s','delimiter','\n');
            fclose(fid);
            xyn.x = D{1,1};
            xyn.y = D{1,2};
            xyn.name = D{1,3};
        end
        xyz = [reshape(xyn.x,[],1) reshape(xyn.y,[],1)];
        xyz(:,3) = 0;
        if OPT.saveOutputFile
            dlmwrite(outputFile,xyz,'delimiter',' ','precision','%20.7f')
        end
        output = xyz;
    end
% xyz2dry
    function [output,OPT] = EHY_convert_xyz2dry(inputFile,outputFile,OPT)
        xyz=importdata(inputFile);
        OPT = EHY_convert_gridCheck(OPT,inputFile);
        [m,n]=EHY_xy2mn(xyz(:,1),xyz(:,2),OPT.grdFile);
        if OPT.saveOutputFile
            delft3d_io_dry('write',outputFile,m,n);
        end
        if size(m,1)==1; m=m'; n=n'; end
        output = [m n];
    end
% xyz2kml
    function [output,OPT] = EHY_convert_xyz2kml(inputFile,outputFile,OPT)
        xyz = dlmread(inputFile);
        [lon,lat,OPT] = EHY_convert_coorCheck(xyz(:,1),xyz(:,2),OPT);
        if OPT.saveOutputFile
            [~,name] = fileparts(outputFile);
            tempFile = [tempdir name '.kml'];
            skipIndex = find(max(lat) > 90 | min(lat) < -90 | max(lon) > 180 | min(lon) < -180);
            if ~isempty(skipIndex)
                disp('Some points outside [lat,lon]-range of [-90:90,-180:180]. These points will be skipped')
                lat(skipIndex) = [];lon(skipIndex) = [];
            end
            KMLscatter(lat,lon,xyz(:,3),'fileName',tempFile)
            %             KMLPlaceMark(lat,lon,tempFile,'icon',OPT.iconFile);
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output = [lon lat];
    end
% xyz2shp
    function [output,OPT] = EHY_convert_xyz2shp(inputFile,outputFile,OPT)
        xyz = importdata(inputFile);
        XY = xyz(:,1:2);
        if OPT.saveOutputFile
            shapewrite(outputFile,'point',XY);
        end
        output = XY;
    end
% xyz2xdrykml
    function [output,OPT] = EHY_convert_xyz2xdrykml(inputFile,outputFile,OPT)
        OPT_user.saveOutputFile=OPT.saveOutputFile;
        OPT.saveOutputFile=0;
        [ldb,OPT] = EHY_convert_xyz2xdryldb(inputFile,outputFile,OPT);
        OPT.saveOutputFile=OPT_user.saveOutputFile;
        if OPT.saveOutputFile
            [ldb(:,1),ldb(:,2),OPT] = EHY_convert_coorCheck(ldb(:,1),ldb(:,2),OPT);
            [~,name]=fileparts(outputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(ldb(:,1:2),tempFile,OPT.lineColor,OPT.lineWidth)
            copyfile(tempFile,outputFile);
            delete(tempFile);
        end
        output=ldb;
    end
% xyz2xdryldb
    function [output,OPT] = EHY_convert_xyz2xdryldb(inputFile,outputFile,OPT)
        OPT = EHY_convert_netCheck(OPT,inputFile);
        try
            gridInfo=EHY_getGridInfo(OPT.netFile,{'XYcor','XYcen','face_nodes_xy'});
            nrCellCorners=sum(~isnan(gridInfo.face_nodes_x));
            xyz=importdata(inputFile);
            k = dsearchn([gridInfo.Xcen gridInfo.Ycen],xyz(:,1:2));
            
            % check if closest point is also in grid cell
            xBndCell=gridInfo.face_nodes_x(:,k);
            xBndCell(end+1,:)=NaN; % close polygon
            yBndCell=gridInfo.face_nodes_y(:,k);
            yBndCell(end+1,:)=NaN; % close polygon
            in= inpolygon(gridInfo.Xcen(k),gridInfo.Ycen(k),xBndCell(:),yBndCell(:));
            k=k(in);
            
            % make and cat ldb from cell center to all the corners
            ldb0{size(xyz,1),1}=[];
            for i_k=1:length(k)
                dmyLdb=[];
                for iCorners=1:nrCellCorners(k(i_k))
                    dmyLdb=[dmyLdb;gridInfo.Xcen(k(i_k)) gridInfo.Ycen(k(i_k)); gridInfo.face_nodes_x(iCorners,k(i_k)) gridInfo.face_nodes_y(iCorners,k(i_k))];
                end
                ldb0{i_k}=[dmyLdb;NaN NaN];
            end
            ldb=cell2mat(ldb0);
            if OPT.saveOutputFile
                io_polygon('write',outputFile,ldb);
            end
            output=ldb;
        catch
            disp('Import grid>export grid in RGFGRID and try again')
        end
    end
%% output
if nargout==1
    varargout{1}=output;
elseif nargout>1
    varargout{1}=output;
    varargout{2}=OPT;
end

end

function varargout = EHY_convert_gridCheck(OPT,inputFile)
if isempty(OPT.grdFile) && isempty(OPT.grd)
    disp('Open the corresponding .grd-file')
    [grdName,grdPath]=uigetfile([fileparts(inputFile) filesep '.grd'],'Open the corresponding .grd-file');
    OPT.grdFile=[grdPath grdName];
end

if nargout==2
    if isempty(OPT.grd)
        [~, name] = fileparts(OPT.grdFile);
        tempFile=[tempdir name '.grd'];
        copyfile(OPT.grdFile,tempFile);
        OPT.grd=wlgrid('read',tempFile);
        delete(tempFile);
    end
    varargout{2}=OPT.grd;
end
varargout{1}=OPT;
end

function OPT = EHY_convert_netCheck(OPT,inputFile)
if isempty(OPT.netFile)
    disp('Open the corresponding _net.nc-file')
    [netName,netPath]=uigetfile([fileparts(inputFile) filesep '.nc'],'Open the corresponding _net.nc-file');
    OPT.netFile=[netPath netName];
end
end

function OPT = EHY_convert_ccoCheck(OPT,inputFile)
if isempty(OPT.grdFile)
    disp('Open the corresponding .cco/.lga-file')
    [netName,netPath]=uigetfile([fileparts(inputFile) filesep '.cco'],'Open the corresponding .cco-file');
    OPT.grdFile=[netPath netName];
end
end

function [x,y,OPT] = EHY_convert_coorCheck(x,y,OPT)
% coordinates to check to guess coordinate system
xx=x(~isnan(x));
yy=y(~isnan(y));
if isempty(OPT.fromEPSG)
    if isempty(OPT.fromEPSG) && all(all(xx>=-180)) && all(all(xx<=180)) && all(all(yy>=-90)) && all(all(yy<=90))
        [outputId,~] = listdlg('PromptString',{'Input coordinations are probably in [Longitude,Latitude] - WGS ''84, EPSG 4326',...
            'Is this correct?'},...
            'SelectionMode','single',...
            'ListString',{'Yes','No'},'ListSize',[500 100]);
        if outputId==1
            OPT.fromEPSG='4326';
        end
    elseif isempty(OPT.fromEPSG) && all(all(xx>-7000)) && all(all(xx<300000)) && all(all(yy>289000)) && all(all(yy<629000))   % probably RD in m
        [outputId,~] = listdlg('PromptString',{'Input coordinations are probably in meter Amersfoort/RD New, EPSG 28992',...
            'Is this correct?'},...
            'SelectionMode','single',...
            'ListString',{'Yes','No'},'ListSize',[500 100]);
        if outputId==1
            OPT.fromEPSG='28992';
        end
    end
    if isempty(OPT.fromEPSG)
        answer=inputdlg(['Input coordinations are probably not in [Longitude,Latitude] - WGS ''84''.' char(10),...
            'What is the code of the input coordinates? EPSG: ' char(10) char(10),...
            '(common EPSG-code: Amersfoort/RD New: 28992)']);
        OPT.fromEPSG=str2num(answer{1});
    end
end

% ad-hoc for Singapore
if OPT.fromEPSG==3414
    warning('Ad-hoc conversion for SVY21, based on WGS84/UTM48N');
    OPT.fromEPSG=32648;
    x=x+342212;
    y=y+112342;
end
% end

if isempty(OPT.fromEPSG)
    disp('Coordinates are assumed to be in WGS''84 (Latitude,Longitude)')
    OPT.fromEPSG='4326';
elseif ~isempty(OPT.fromEPSG) && ~strcmp(OPT.fromEPSG,'4326')
    [x,y]=convertCoordinates(x,y,'CS1.code',OPT.fromEPSG,'CS2.code',4326);
end
end

function OPT = EHY_selectToAndFromEPSG(OPT)
availableCoorSys={'EPSG: 28992, Amersfoort / RD New',28992;,...
    'EPSG:  4326, WGS ''84',4326;,...
    'Other...',-999};

% coordinate system of input file
if isempty(OPT.fromEPSG)
    [outputId,~]=  listdlg('PromptString','Coordinate system of the input file is: ',...
        'SelectionMode','single',...
        'ListString',availableCoorSys(:,1),'ListSize',[500 100]);
    if outputId~=length(availableCoorSys)
        OPT.fromEPSG=availableCoorSys{outputId,2};
    elseif outputId==length(availableCoorSys)
        OPT.fromEPSG=input('Coordinate system of the input file is, EPSG-code: ');
    end
end

% coordinate system of output file
if isempty(OPT.toEPSG)
    indExclToEPSG=find(cell2mat(availableCoorSys(:,2))~=OPT.fromEPSG);
    availableCoorSys=availableCoorSys(indExclToEPSG,:);
    [outputId,~]=  listdlg('PromptString','Convert the input file to coordinate system: ',...
        'SelectionMode','single',...
        'ListString',availableCoorSys(:,1),'ListSize',[500 100]);
    if outputId~=length(availableCoorSys)
        OPT.toEPSG=availableCoorSys{outputId,2};
    elseif outputId==length(availableCoorSys)
        OPT.toEPSG=input('Convert the input file to coordinate system of EPSG-code: ');
    end
end
end

function [output,OPT] = EHY_convertCoordinates(inputFile,outputFile,OPT)
% convert the file
if OPT.fromEPSG~=OPT.toEPSG
    [~,~,ext]=fileparts(inputFile);
    switch ext
        case '.grd'
            output=wlgrid('read',inputFile);
            [output.X,output.Y]=convertCoordinates(output.X,output.Y,'CS1.code',OPT.fromEPSG,'CS2.code',OPT.toEPSG);
            if OPT.saveOutputFile
                if OPT.toEPSG==4326
                    wlgrid('write',outputFile,output,'CoordinateSystem','Spherical');
                else
                    wlgrid('write',outputFile,output);
                end
            end
        case {'.ldb','.pli','.pol'}
            T=tekal('read',inputFile,'loaddata');
            % tekal is used to keep the same polygon-names
            if length(T.Field)>50 % put everything in one field, otherwise it takes a lot of time
                T.Field(1).Data=io_polygon('read',inputFile);
                T.Field(2:end)=[];
            end
            
            % ad-hoc for Singapore
            if OPT.toEPSG==3414
                warning('Ad-hoc conversion for SVY21, based on WGS84/UTM48N');
                OPT.toEPSG=32648;
                for iT=1:length(T.Field)
                    [T.Field(iT).Data(:,1),T.Field(iT).Data(:,2)]=convertCoordinates(T.Field(iT).Data(:,1),T.Field(iT).Data(:,2),'CS1.code',OPT.fromEPSG,'CS2.code',OPT.toEPSG);
                end
                T.Field.Data(:,1)=T.Field.Data(:,1)-342212;
                T.Field.Data(:,2)=T.Field.Data(:,2)-112342;
                
            else
                for iT=1:length(T.Field)
                    [T.Field(iT).Data(:,1),T.Field(iT).Data(:,2)]=convertCoordinates(T.Field(iT).Data(:,1),T.Field(iT).Data(:,2),'CS1.code',OPT.fromEPSG,'CS2.code',OPT.toEPSG);
                end
            end
            
            output = []; % to do
            
            % don't take third dimensions into account
            if OPT.saveOutputFile
                fid=fopen(outputFile,'w');
                for iT=1:length(T.Field)
                    fprintf(fid,'%s\n',T.Field(iT).Name);
                    fprintf(fid,'     %i     %i\n',size(T.Field(iT).Data,1), 2);
                    fprintf(fid,'%20.7f %20.7f\n',[T.Field(iT).Data(:,1) T.Field(iT).Data(:,2)]');
                end
                fclose(fid);
            end
        case '.pliz'
            T=tekal('read',inputFile,'loaddata');
            for iT=1:length(T.Field)
                [T.Field(iT).Data(:,1),T.Field(iT).Data(:,2)]=convertCoordinates(T.Field(iT).Data(:,1),T.Field(iT).Data(:,2),'CS1.code',OPT.fromEPSG,'CS2.code',OPT.toEPSG);
            end
            if OPT.saveOutputFile
                tekal('write',outputFile,T);
            end
            output=T;
        case '.nc'
            varNameX = EHY_nameOnFile(inputFile,'NetNode_x');
            varNameY = EHY_nameOnFile(inputFile,'NetNode_y');
            output = [ncread(inputFile,varNameX) ncread(inputFile,varNameY)];
            
            [output(:,1),output(:,2)]=convertCoordinates(output(:,1),output(:,2),'CS1.code',OPT.fromEPSG,'CS2.code',OPT.toEPSG);
            if OPT.saveOutputFile
                copyfile(inputFile,outputFile)
                nc_varput(outputFile,varNameX,output(:,1));
                nc_varput(outputFile,varNameY,output(:,2));
                
                % to do: fix setting the right EPSG code in the .nc file,
                % not properply working yet
                %                 if OPT.toEPSG==4326
                %                     nccreate(outputFile,'wgs84','Datatype','int32')
                %                     epsgInfo={'name','WGS84';'epsg',4326;'grid_mapping_name','latitude_longitude';'longitude_of_prime_meridian',0;'semi_major_axis',6378137;'semi_minor_axis',6356752.31424500;'inverse_flattening',298.257223563000;'epsg_code','EPSG:4326';'value','value is equal to EPSG code'};
                %                     for iE=1:length(epsgInfo)
                %                         ncwriteatt(outputFile,'wgs84',epsgInfo{iE,1},epsgInfo{iE,2});
                %                     end
                %                     ncwriteatt(outputFile,'Mesh2D','topology_dimension',1);
                %                     ncid = netcdf.open(outputFile,'WRITE');
                %                     netcdf.reDef(ncid);
                % %                     netcdf.delAtt(ncid,netcdf.getConstant('GLOBAL'),'Spherical');
                %                     netcdf.close(ncid);
                %                 end
            end
        case {'.xyz'}
            output=importdata(inputFile);
            [output(:,1),output(:,2)]=convertCoordinates(output(:,1),output(:,2),'CS1.code',OPT.fromEPSG,'CS2.code',OPT.toEPSG);
            if OPT.saveOutputFile
                dlmwrite(outputFile,output,'delimiter',' ','precision','%20.7f');
            end
        case {'.xyn'}
            xyn=delft3d_io_xyn('read',inputFile);
            [xyn.x,xyn.y]=convertCoordinates(xyn.x,xyn.y,'CS1.code',OPT.fromEPSG,'CS2.code',OPT.toEPSG);
            output = [num2cell(xyn.x') num2cell(xyn.y') xyn.name'];
            if OPT.saveOutputFile
                fid=fopen(outputFile,'w');
                for iM=1:length(xyn.x)
                    fprintf(fid,'%20.7f%20.7f ',[xyn.x(iM) xyn.y(iM)]);
                    fprintf(fid,'%-s\n',['''' xyn.name{iM} '''']);
                end
                fclose(fid);
            end
        otherwise
            error('cannot convert coordinates in this file format: %s',ext)
    end
end
end

function inputExt=EHY_convert_askForInputExt
[selection,~]=  listdlg('PromptString','Input file does not have an extension. What kind of file is it?',...
    'SelectionMode','single',...
    'ListString',{'Simona observation points file (locaties)','Simona rooster/grid file (.grd)',...
    'Simona box/depth file (bodem)','Simona cross-sections file (curves)'},...
    'ListSize',[500 100]);
if selection==1
    inputExt='locaties';
elseif selection==2
    inputExt='grd';
elseif selection==3
    inputExt='box';
elseif selection==4
    inputExt='curves';
else
    disp('EHY_convert stopped by user.'); return
end
end