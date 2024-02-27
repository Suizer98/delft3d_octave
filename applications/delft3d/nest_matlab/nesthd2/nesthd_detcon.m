function [bndval] = detcon(fid_adm,bnd,nfs_inf,add_inf,fileInp,varargin)

%***********************************************************************
% delft hydraulics                         marine and coastal management
%
% subroutine         : detcon
% version            : v1.0
% date               : May 1999
% programmer         : Theo van der Kaaij
%
% function           : Determines transport boundary conditions
%                      (time-series)
% limitations        :
% subroutines called : getwgh, check, getwcr
%***********************************************************************
%% Initialisation
no_pnt    = length(bnd.DATA);
notims    = nfs_inf.notims;
t0        = nfs_inf.times(1);
tend      = nfs_inf.times(notims);
kmax      = nfs_inf.kmax;
lstci     = nfs_inf.lstci;
modelType = EHY_getModelType(fileInp);

OPT.ipnt   = NaN;
OPT        = setproperty(OPT,varargin);
if isnan(OPT.ipnt) OPT.ipnt = 1:1:no_pnt; end

for itim = 1: notims bndval(itim).value(1:length(OPT.ipnt),1:kmax,1:lstci) = 0.; end

%% Determine time series of the boundary conditions
for i_conc = 1:lstci
    
    %% If bc for this constituent are requested
    if add_inf.genconc(i_conc)
        
        %% Cycle over all boundary support points
        for i_pnt = OPT.ipnt
            if length(OPT.ipnt) == 1 bndNr = 1; else bndNr = i_pnt; end
            
            if add_inf.display==1
                waitbar(i_pnt/no_pnt);
            else
                fprintf('done %5.1f %% \n',i_pnt/no_pnt*100)
            end
            
            %% First get nesting stations, weights and orientation of support points
            mnbcsp         = bnd.Name{i_pnt};
            [mnnes,weight] = nesthd_getwgh2 (fid_adm,mnbcsp,'z');
            
            if isempty(mnnes)
                error = true;
                if add_inf.display==1
                    close(h);
                end
                simona2mdf_message({'Inconsistancy between boundary definition and' 'administration file'},'Window','Nesthd2 Error','Close',true,'n_sec',10);
                return
            end
            
            %% Temporary for testing with old hong kong model
            if strcmpi(modelType,'d3d')
                for i_stat = 1: length(mnnes)
                    i_start = strfind(mnnes{i_stat},'(');
                    i_com   = strfind(mnnes{i_stat},',');
                    mnnes{i_stat} = [mnnes{i_stat}(1:i_start(2)) mnnes{i_stat}(i_start(2) + 2:i_com(2))  mnnes{i_stat}(i_com(2) + 2:end)];
                end
            end
            
            %% Retrieve the data
            logi      = ~cellfun(@isempty,mnnes); % avoid "Station :  does not exist"-message
            data      = EHY_getmodeldata(fileInp,mnnes(logi),modelType,'varName',lower(nfs_inf.namcon{i_conc}),'t0',t0,'tend',tend);
            data.val(:,~logi,:) = NaN; % this works for 2D and 3D models
            
            %%  Fill conc array with concentrations for the requested stations
            conc              = data.val;
            conc(isnan(conc)) = 0.;
            
            %% Exclude permanently dry points
            exist_stat          = nesthd_wetOrDry(fileInp,conc,mnnes);
            weight(~exist_stat) = 0.;
            
            %% In case of Zmodel, replace nodata values with above or below layer
            if kmax>1 && strcmp(add_inf.profile,'3d-profile')==1 && ~strcmpi(nfs_inf.layer_model,'sigma-model')
                conc = nesthd_uvcFill (conc,'noValue',0.0000);
            end
            
            %% Normalise weights
            wghttot = sum(exist_stat.*weight);
            weight  = weight/wghttot;
            
            %% Determine weighed bandary values
            for iwght = 1: 4
                if exist_stat(iwght)
                    for itim = 1: notims
                        for k = 1: kmax
                            bndval(itim).value(bndNr,k,i_conc) = bndval(itim).value(bndNr,k,i_conc) +  ...
                                conc(itim,iwght,k)*weight(iwght);
                        end
                    end
                end
            end
        end
        
    end
end

%% Adjust boundary conditions
for i_conc = 1: lstci
    if add_inf.genconc(i_conc)
        for i_pnt = OPT.ipnt
            if length(OPT.ipnt) == 1 bndNr = 1; else bndNr = i_pnt; end
            for itim = 1 : notims
                bndval(itim).value(bndNr,:,i_conc) =  bndval(itim).value(bndNr,:,i_conc) + add_inf.add(i_conc);
                bndval(itim).value(bndNr,:,i_conc) =  min(bndval(itim).value(bndNr,:,i_conc),add_inf.max(i_conc));
                bndval(itim).value(bndNr,:,i_conc) =  max(bndval(itim).value(bndNr,:,i_conc),add_inf.min(i_conc));
            end
        end
    end
end

%% Store station with largest weight for interpolation to fixed heights later (use station with largest weight as basis)
if strcmp(nfs_inf.from,'dfm') && (strcmp(nfs_inf.layer_model,'z-sigma-model'    ) || ...
        strcmp(nfs_inf.layer_model,'z-model'          ) )
    [~,nrMax]                   = max(weight);
    bndval(1).statMax           = mnnes{nrMax};
end
