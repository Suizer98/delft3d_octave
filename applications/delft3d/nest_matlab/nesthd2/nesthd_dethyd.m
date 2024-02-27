      function [bndval,error] = nesthd_dethyd(fid_adm,bnd,nfs_inf,add_inf,fileInp,varargin)

      % dethyd : determines nested hydrodynamic boundary conditions (part of nesthd2)

%***********************************************************************
% delft hydraulics                         marine and coastal management
%
% subroutine         : dethyd
% version            : v1.0
% date               : May 1999
% programmer         : Theo van der Kaaij
%
% function           : Determines hydrodynamic boundary conditions
%                      (time-series)
% limitations        :
% subroutines called : getwgh, check, getwcr
%
%***********************************************************************
% temporary: to ensure that old shenzen history file keeps working
shenzen = false;
[~,name,~] = fileparts(fileInp);
if strcmpi(name,'trih-w41_2') shenzen = true; end

%% Initialisation
modelType  = EHY_getModelType(fileInp);
g          = 9.81;
error      = false;
nopnt      = length(bnd.DATA);
notims     = nfs_inf.notims;
t0         = nfs_inf.times(1);
tend       = nfs_inf.times(notims);
kmax       = nfs_inf.kmax;
names      = nfs_inf.names;

OPT.ipnt   = NaN;
OPT        = setproperty(OPT,varargin);
if isnan(OPT.ipnt) OPT.ipnt = 1:1:nopnt; end
for itim = 1: notims bndval (itim).value(1:length(OPT.ipnt),1:2*kmax,1) = 0.; end

%% -----cycle over all boundary support points
for ipnt = OPT.ipnt
    if length(OPT.ipnt) == 1 bndNr = 1; else bndNr = ipnt; end
    type = lower(bnd.DATA(ipnt).bndtype);
    
    if add_inf.display==1
        waitbar(ipnt/nopnt);
    else
        fprintf('done %5.1f %% \n',ipnt/nopnt*100)
    end
    
    wl = [];
    uu = [];
    vv = [];
    
    %% -----------first get nesting stations, weights and orientation
    mnbcsp = bnd.Name{ipnt};
    switch type
        case 'z'
            [mnnes,weight]               = nesthd_getwgh2 (fid_adm,mnbcsp,type);
        case {'c' 'p'}
            [mnnes,weight,angle]         = nesthd_getwgh2 (fid_adm,mnbcsp,'c');
        case {'r' 'x'}
            [mnnes,weight,angle,ori]     = nesthd_getwgh2 (fid_adm,mnbcsp,'r');
        case 'n'
            [mnnes,weight,angle,ori,x,y] = nesthd_getwgh2 (fid_adm,mnbcsp,'n');
    end
    
    %% Error if no nesting stations are found
    if isempty(mnnes)
        error = true;
        if add_inf.display==1
            close(h);
        end
        simona2mdf_message({'Inconsistancy between boundary definition and' 'administration file'},'Window','Nesthd2 Error','Close',true,'n_sec',10);
        return
    end
    
    %% Temporary for testing with old hong kong model
    if shenzen
        for i_stat = 1: length(mnnes)
            i_start = strfind(mnnes{i_stat},'(');
            i_com   = strfind(mnnes{i_stat},',');
            mnnes{i_stat} = [mnnes{i_stat}(1:i_start(2)) mnnes{i_stat}(i_start(2) + 2:i_com(2))  mnnes{i_stat}(i_com(2) + 2:end)];
        end
    end
    
    %% Get the needed data
    if ismember(type,{'z' 'r' 'x' 'n'})
        logi          = ~cellfun(@isempty,mnnes); % avoid "Station :  does not exist"-message
        data          = EHY_getmodeldata(fileInp,mnnes(logi),modelType,'varName','wl','t0',t0,'tend',tend);
        data.val(:,~logi) = NaN;
        wl            = data.val;
        wl(isnan(wl)) = 0.;
        
        %% Exclude permanently dry points
        exist_stat          = nesthd_wetOrDry(fileInp,wl,mnnes);
        weight(~exist_stat) = 0.;
    end
    
    if ismember(type,{'c' 'p' 'r' 'x'})
        logi      = ~cellfun(@isempty,mnnes); % avoid "Station :  does not exist"-message
        data_uv   = EHY_getmodeldata(fileInp,mnnes(logi),modelType,'varName','uv','t0',t0,'tend',tend);
        data_uv.vel_x(:,~logi,:) = NaN; data_uv.vel_y(:,~logi,:) = NaN; % this works for 2D and 3D models
        uu        = data_uv.vel_x; uu(isnan(uu)) = 0.;
        vv        = data_uv.vel_y; vv(isnan(vv)) = 0.;
        [uu,vv]   = nesthd_rotate_vector(uu,vv,pi/2. - angle);
        
        %% Exclude permanently dry points
        exist_u             = nesthd_wetOrDry(fileInp,uu,mnnes);
        exist_v             = nesthd_wetOrDry(fileInp,vv,mnnes);
        exist_stat          = exist_u | exist_v;
        weight(~exist_stat) = 0.;
        
        %% In case of Zmodel, replace nodata values with above or below layer
        if kmax>1 && strcmp(add_inf.profile,'3d-profile')==1 && ~strcmpi(nfs_inf.layer_model,'sigma-model')
            uu = nesthd_uvcFill (uu,'noValue',0.0000);
        end
    end
    
    %% Normalise weights
    wghttot = sum(exist_stat.*weight);
    weight  = weight/wghttot;
    
    %% Generate boundary conditions
    for iwght = 1: 4
        nr_key = get_nr(nfs_inf.names,mnnes{iwght});
        if exist_stat(iwght)
            switch type
                %
                %% Water level boundaries
                case 'z'
                    for itim = 1: notims
                        bndval(itim).value(bndNr,1,1) = bndval(itim).value(bndNr,1,1) + ...
                            weight(iwght)*(wl(itim,iwght) + add_inf.a0);
                    end
                    
                    %% Velocity boundaries (perpendicular component)
                case {'c' 'p'}
                    for itim = 1: notims
                        bndval(itim).value(bndNr,1:kmax,1) = bndval(itim).value(bndNr,1:kmax,1)      + ...
                            squeeze(uu(itim,iwght,:)*weight(iwght))';
                    end
                    
                    %% Rieman boundaries
                case {'r' 'x'}
                    ori = char(ori);
                    if ori(1:2) == 'in'
                        rpos = 1.0;
                    else
                        rpos = -1.0;
                    end
                    for itim = 1: notims
                        bndval(itim).value(bndNr,1:kmax,1) = bndval(itim).value(bndNr,1:kmax,1)  + ...
                            (squeeze(uu(itim,iwght,:))'         + ...
                            rpos*wl(itim,iwght)*sqrt(g/nfs_inf.dps(nr_key)))*weight(iwght);
                    end
            end
        end
    end
    
    %% Neumann boundaries (still to adjust, hardly ever used, works for Delft3D-Flow, not sure about D-Hydro, sign of the water level gradient)
    switch type
        case 'n'
            x     = x     (exist_stat);
            y     = y     (exist_stat);
            mnnes = mnnes (exist_stat);
            
            % Neumann boundaries require 3 surrounding support points
            if length(x) >= 3
                
                % Determine water level gradient
                for itim = 1: notims
                    gradient_global              = nesthd_tri_grad      (x(1:3),y(1:3),wl(itim,1:3));
                    [gradient_boundary,~]        = nesthd_rotate_vector (gradient_global(1),gradient_global(2),pi/2. - angle);
                    bndval(itim).value(bndNr,1,1) = gradient_boundary;
                end
            else
                bndval(itim).value(bndNr,1,1) = NaN;
            end
    end
    
    %% Determine time series for the parallel velocity component
    switch type
        case {'x' 'p'}
            [mnnes,weight,angle]         = nesthd_getwgh2 (fid_adm,mnbcsp,'p');
            
            %% Error if no nesting stations are found
            if isempty(mnnes)
                error = true;
                if add_inf.display==1
                    close(h);
                end
                simona2mdf_message({'Inconsistancy between boundary definition and' 'administration file'},'Window','Nesthd2 Error','Close',true,'n_sec',10);
                return
            end
            
            %% Temporary for testing with old hong kong model
            if shenzen
                for i_stat = 1: length(mnnes)
                    i_start = strfind(mnnes{i_stat},'(');
                    i_com   = strfind(mnnes{i_stat},',');
                    mnnes{i_stat} = [mnnes{i_stat}(1:i_start(2)) mnnes{i_stat}(i_start(2) + 2:i_com(2))  mnnes{i_stat}(i_com(2) + 2:end)];
                end
            end
            
            %% Read velocity data
            logi      = ~cellfun(@isempty,mnnes); % avoid "Station :  does not exist"-message
            data_uv   = EHY_getmodeldata(fileInp,mnnes(logi),modelType,'varName','uv','t0',t0,'tend',tend);
            data_uv.vel_x(:,~logi,:) = NaN; data_uv.vel_y(:,~logi,:) = NaN; % this works for 2D and 3D models
            uu        = data_uv.vel_x; uu(isnan(uu)) = 0.;
            vv        = data_uv.vel_y; vv(isnan(vv)) = 0.;
            [uu,vv]   = nesthd_rotate_vector(uu,vv,pi/2. - angle);
            
            %% Exclude permanently dry points
            exist_u             = nesthd_wetOrDry(fileInp,uu,mnnes);
            exist_v             = nesthd_wetOrDry(fileInp,vv,mnnes);
            exist_stat          = exist_u | exist_v;
            weight(~exist_stat) = 0.;
            
            %% In case of Zmodel, replace nodata values with above or below layer
            if kmax>1 && strcmp(add_inf.profile,'3d-profile')==1 && ~strcmpi(nfs_inf.layer_model,'sigma-model')
                vv = nesthd_uvcFill (vv,'noValue',0.0000);
            end
            
            %% Normalise weights
            wghttot = sum(exist_stat.*weight);
            weight  = weight/wghttot;
            
            for iwght = 1: 4
                if exist_stat(iwght)
                    for itim = 1: notims
                        bndval(itim).value(bndNr,kmax+1:2*kmax,1) = bndval(itim).value(bndNr,kmax+1:2*kmax,1) + ...
                            squeeze(vv(itim,iwght,:)*weight(iwght))' ;
                    end
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



