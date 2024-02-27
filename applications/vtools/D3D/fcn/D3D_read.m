%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18044 $
%$Date: 2022-05-12 20:36:40 +0800 (Thu, 12 May 2022) $
%$Author: chavarri $
%$Id: D3D_read.m 18044 2022-05-12 12:36:40Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_read.m $
%
%get data in D3D
%
%INPUT
%open input_D3D_fig_layout
%e.g.
%
% simdef.D3D.dire_sim=path_sim;
% simdef=D3D_simpath(simdef);
% simdef.flg.which_p=2; 
% simdef.flg.which_v=39;
% in_read.kt=0;
% out_read=D3D_read(simdef,in_read);
% in_read.kt=out_read.nTt;
% out_read=D3D_read(simdef,in_read);

function out=D3D_read(simdef,in)

%% parse error

if isfield(simdef,'err') && simdef.err==1
    error('There is an error in reading the folder. I cannot find the right files. Check <D3D_simpath>')
end

%% grid output

if isfield(simdef.flg,'which_p')==1 && strcmp(simdef.flg.which_p,'grid')
    switch simdef.D3D.structure
        case 1
            out=wlgrid('read',fullfile(simdef.D3D.dire_sim,'grd.grd'));
        case {2,3}
            out=NC_read_grid(simdef,in);
    end
    return
end

%% PARSE
        
%dimensions
in_aux.kt=0; %give as output the domain size
% out_aux=actual_call(simdef,in_aux);
out_aux=sim_dimensions(simdef,in_aux);

if ~(isfield(in,'kt') && any(in.kt==0)) %you want something else than dimensions
    
    %kt
    if isfield(in,'kt')==0 %if time undefined, take all
        in.kt=NaN;
    end
    switch simdef.D3D.structure        
        case 1
            if isnan(in.kt) %if NaN, take all
                in.kt=1:1:out_aux.nTt; 
            end
            if isinf(in.kt)
                in.kt=out_aux.nTt; %take last one
            end
%             if numel(in.kt)==1 && in.kt~=0 %if there is only one element, take this single value. The NaN option is removed above.
                
%             end
        case {2,3}
            if isnan(in.kt) %if NaN, take all
                in.kt=[1,out_aux.nTt]; %[first position, counter]
            end
            if isinf(in.kt)
                in.kt=[out_aux.nTt,1]; %take last one
            end
            if numel(in.kt)==1 && ~isnan(in.kt) && in.kt~=0 %if there is only one element, take this single value
                in.kt=[in.kt,1]; %[first position, counter]
            end
            if numel(in.kt)==2 && in.kt(2)==Inf
                in.kt=[in.kt(1),out_aux.nTt]; %[first position, counter]
            end
            %final test
            if numel(in.kt)~=2 || any(isnan(in.kt)) || any(in.kt==Inf)
                error('kt it is not how it should be')
            end
    end


    %kf
    if isfield(in,'kf')==0
        if isfield(out_aux,'nf')
            in.kf=1:1:out_aux.nf;
        else
            in.kf=NaN;
        end
    end

    %kl
    if isfield(in,'kl')==0
        in.kl=1; %active layer only by default
    end
    
    %kF
    if simdef.D3D.structure==1
        if isa(simdef.flg.which_p,'double')
            %define x nodes to plot
            if isfield(in,'kx')==0
                in.kx=NaN;
            end
            if isnan(in.kx)
                in.kx=1:1:out_aux.MMAX;
            end
            %define y nodes to plot
            if isfield(in,'ky')==0
                in.ky=NaN;
            end
            if isnan(in.ky)
                in.ky=1:1:out_aux.NMAX;
            end
            %flow layers to plot
            if isfield(in,'kl')==0
                in.kl=NaN;
            end
            if isnan(in.kl)
                in.kl=1:1:out_aux.KMAX;
            end
        end
    else %FM
        %faces to plot
        if isfield(in,'kF')==0
            in.kF=NaN;
        end
        if isnan(in.kF)
            in.kF=[1,Inf];
        end

        %branches
        if isfield(in,'branch')==0
           in.branch=NaN; 
        end
    end

    %cross-sections
    if isfield(in,'kcs')==0
        in.kcs=NaN;
    end

    if isfield(in,'rkm_TolMinDist')==0
        in.rkm_TolMinDist=100;
    end
    
    %underlayers
    if isfield(out_aux,'nl')
        in.nl=out_aux.nl;
    end
    
    %flow layers
    if isfield(out_aux,'nfl')
        in.nfl=out_aux.nfl;
    end
    
    %% CALL
    
    field_dim=fields(out_aux);
    nfields=numel(field_dim);
    for kfields=1:nfields
        in.(field_dim{kfields})=out_aux.(field_dim{kfields});
    end
      
    out=actual_call(simdef,in);

else %in.kt==0
    
    out=out_aux;    

end

end

%%
%% FUNCTIONS
%%

%%

function out=actual_call(simdef,in)

switch simdef.D3D.structure
    case 1           
        if isa(simdef.flg.which_p,'double')
            out=D3D_read_map(simdef,in);
        else
            out=D3D_read_his(simdef,in);
        end
    case {2,3}
        if isa(simdef.flg.which_p,'double')
            out=NC_read_map(simdef,in);
        else
            out=NC_read_his(simdef,in);
        end 
end

end

%%

function out=sim_dimensions(simdef,in)

switch simdef.D3D.structure
    case 1      
        if isa(simdef.flg.which_p,'double')
            out=D3D_read_dimensions(simdef);
        else
                    error('ups... you will have to modify this to get the dimensions only')
            out=D3D_read_his(simdef,in);
        end
    case 2
        if isa(simdef.flg.which_p,'double')
            out=NC_read_dimensions(simdef.file.map);
        else
            out=NC_read_dimensions(simdef.file.his);
        end
    case 3
        file_read=S3_file_read(simdef.flg.which_v,simdef.file);
        out=NC_read_dimensions(file_read);
end
  
end
