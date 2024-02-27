function dflowfm_oldExt2newExt(oldExtFile,varargin)
%% dflowfm_oldExt2newExt(oldExtFile,varargin)
%
% Based on a old-formatted .ext file, the boundary conditions of the
% Delft3D-FM model are converted to the new boundary condition format
% old: .tim , .cmp
% new: .bc
%
% Example:  dflowfm_oldExt2newExt('D:\model\externalforcing.ext')
%
% May2018	Julien Groenenboom      
% Sep2020   Wilbert Verbruggen

OPT.outputDir=[fileparts(oldExtFile) filesep 'dflowfm_oldExt2newExt_OUTPUT_',datestr(now,'yyyymmdd_HHMMSS')];

%% OPT
OPT.bcFilePerItem = 0;
if nargin>1
    OPT = setproperty(OPT,varargin);
end

% find mduFile

mduFile = dir([fileparts(oldExtFile) filesep '*.mdu']);
if ~isempty(mduFile)
    mdu = dflowfm_io_mdu('read',[fileparts(oldExtFile),filesep,mduFile(1).name]);
    refDate = datenum(num2str(mdu.time.RefDate),'yyyymmdd');
else
    warning('No .mdu file was found in folder where .ext file is located --> .tim files cannot be converted to .bc (refDate unknown)')
end

if ~exist(OPT.outputDir); mkdir(OPT.outputDir); end
%% convert old ext file to new ext file
oldExt=dflowfm_io_extfile('read',oldExtFile);

for iE=1:length(oldExt)
    disp([datestr(now),': Converting item ',num2str(iE),' of ',num2str(length(oldExt)),': ', oldExt(iE).quantity])
    if ~isempty(oldExt(iE).quantity)
        if ~strcmpi(oldExt(iE).quantity(end-2:end),'bnd')
            convertData = 0;
            disp([datestr(now),': Quantity ''' oldExt(iE).quantity ''' is not a boundary condition, so cannot be converted to .bc'])
        elseif ~ismember(oldExt(iE).quantity,{'waterlevelbnd','neumannbnd','dischargebnd','velocitybnd','salinitybnd','temperaturebnd'})
            convertData = 0;
            disp([datestr(now),': Quantity ''' oldExt(iE).quantity ''' is not yet implemented in this conversion'])
        else
            convertData = 1;
        end
        
        if convertData
            % find and copy and open pli file
            pliFile=EHY_getFullWinPath([fileparts(oldExtFile) filesep oldExt(iE).filename]);
            copyfile(pliFile,OPT.outputDir);
            [pathstr,name,ext]=fileparts(pliFile);
            pli = landboundary('read',pliFile);
            
            % define bc name
            if OPT.bcFilePerItem == 0
                BcFile=[OPT.outputDir filesep oldExt(iE).quantity '.bc'];
            else
                BcFile=[OPT.outputDir filesep oldExt(iE).quantity '_',name,'_item_',num2str(iE),'.bc'];                
            end
            
            % define unit
            if strcmpi(oldExt(iE).quantity,'waterlevelbnd')
                info.unit = 'm';
            elseif strcmpi(oldExt(iE).quantity,'neumannbnd')
                info.unit = '-';
            elseif strcmpi(oldExt(iE).quantity,'velocitybnd')
                info.unit = 'm/s';
            elseif strcmpi(oldExt(iE).quantity,'dischargebnd')
                info.unit = 'm3/s';
            elseif strcmpi(oldExt(iE).quantity,'salinitybnd')
                info.unit = 'ppt';
            end
            
            % define info structure
            info.bndType = oldExt(iE).quantity;
            info.refDate = refDate;
            
            % check if forcing is based on astronomical cmp or timeseries
            if exist([pathstr filesep name '_0001.cmp']) % astro components
                for iP=1:size(pli,1)
                    info.Name = [name '_' sprintf('%04d',iP)];
                    
                    cmpFile=[pathstr filesep info.Name '.cmp'];
                    if exist(cmpFile,'file')
                        fidCmp=fopen(cmpFile,'r');
                        
                        cmpAll = textread(cmpFile,'%s','delimiter',char(13),'whitespace','');
                        IDheaderlines = find(~cellfun(@isempty,strfind(cmpAll(:,1),'*')));
                        
                        fidCmp=fopen(cmpFile,'r');
                        cmp=textscan(fidCmp,'%s%s%s','Headerlines',length(IDheaderlines));                        
                        cmp=[cmp{:}];
                        
                        % write .bc file
                        writeBCFile(BcFile,info,cmp,'cmp')
                    end
                end
            elseif exist([pathstr filesep name '_0001.tim']) % time series
                for iP=1:size(pli,1)
                    info.Name = [name '_' sprintf('%04d',iP)];
                    % read cmp file
                    timFile=[pathstr filesep info.Name '.tim'];
                    if exist(timFile,'file')
                        tim = importdata(timFile);
                        if isstruct(tim)
                            tim = tim.data;
                        end
                        
                        % write .bc file
                        if ismember(oldExt(iE).quantity,{'salinitybnd','temperaturebnd'})
                            if size(tim,2)==2
                                info.vertPosType = 'single';
                                info.vertInterpolation = 'linear';
                            else
                                error([datestr(now),': Conversion of item ',num2str(iE),' of ',num2str(length(oldExt)),': ', oldExt(iE).quantity,' failed. Writing of 3D salinity input is not implemented yet.'])
                                info.vertPosType = 'zdatum';
                            end
                        end
                        writeBCFile(BcFile,info,tim,'time')
                        
                    end
                end
                
            else
                disp([datestr(now),': No .cmp or .tim file found'])
            end
        end
    end
    clear info
end


function writeBCFile(BcFile,info,data,fileType)

fidBc=fopen(BcFile,'a'); % create new or open existing

% start writing forcing block
fprintf(fidBc,'[forcing]\n');
fprintf(fidBc,['Name                            = ',info.Name,'\n']);

if strcmpi(fileType,'cmp')
    % write cmp data to bc file
    fprintf(fidBc,'Function                        = astronomic\n');
    fprintf(fidBc,'Quantity                        = astronomic component\n');
    fprintf(fidBc,'Unit                            = -\n');
    fprintf(fidBc,['Quantity                        = ',info.bndType,' amplitude\n']);
    fprintf(fidBc,['Unit                            = ',info.unit,'\n']);
    fprintf(fidBc,['Quantity                        = ',info.bndType,' phase\n']);
    fprintf(fidBc,'Unit                            = deg\n');
    for iC = 1:size(data,1)
        fprintf(fidBc,'%-9s',data{iC,1});
        fprintf(fidBc,'%20s  %20s\n',data{iC,2},data{iC,3});
    end
elseif strcmpi(fileType,'time')
    fprintf(fidBc,'Function                        = timeseries\n');
    fprintf(fidBc,'Time-interpolation              = linear\n');
    if isfield(info,'vertPosType')
        fprintf(fidBc,['Vertical position type          = ',info.vertPosType,'\n']);
        fprintf(fidBc,['Vertical interpolation          = ',info.vertInterpolation,'\n']);
        
    end
    fprintf(fidBc,'Quantity                        = time\n');
    fprintf(fidBc,['Unit                            = minutes since ',datestr(info.refDate,'yyyy-mm-dd HH:MM:SS'),'\n']);
    fprintf(fidBc,['Quantity                        = ',info.bndType,'\n']);
    fprintf(fidBc,['Unit                            = ',info.unit,'\n']);
    fprintf(fidBc,'%u %3.7f \n',data');
    fprintf(fidBc,'%s\n','');
elseif strcmpi(fileType,'time_3D')
    
end
fprintf(fidBc,'\n');
fclose(fidBc);
