%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: S3_delete_grid_points.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/S3_delete_grid_points.m $
%
%Delete computational nodes and cross sections that are separated by a step
%length smaller than desired. 
%
%TO DO:
%   -make output file name to be input or a modification of input
%   -observation cross-sections should also be erased

function S3_delete_grid_points(path_netdef,path_csloc,dx_desired)

%% READ FILES

fprintf('start reading \n')

    %read network
net_in=S3_read_networkdefinition(path_netdef);

    %read cross section definitions
[csloc_in,cs]=S3_read_crosssectiondefinitions(path_csloc);

    %read observations points
% [obs_in,obs]=S3_read_observationpoints(path_obs);
    
    %% display
    
fprintf('finished reading \n')

%% LOOP

net_out=net_in; %output network file

nlloc=1000; %a priori number of lines
csloc_out=cell(nlloc,1); %output cross section location 
csloc_out(1:5)=csloc_in(1:5); %block [general]
kwcs=6; %next line to write

%loop on lines
nl=numel(net_in);
for kl=1:nl
    str_loc=net_in{kl,1};
    if contains(str_loc,'[Branch]')
        
        %get indices of tags
        str_2_find={'gridPointOffsets','gridPointsCount','gridPointX','gridPointY','gridPointIds','id'};
        nstr=numel(str_2_find);
        idx_tags=NaN(nstr,1);
        
        for kstr=1:nstr
            kl_loc=kl+1;
            search_kl=true;
            while search_kl
                str_loc_2=net_in{kl_loc,1};
                if contains(str_loc_2,str_2_find{kstr}) 
                    idx_tags(kstr)=kl_loc;
                    search_kl=false;
                elseif contains(str_loc_2,'[Branch]') %we have reached the next block
                    error('I cannot find one of the strings!')
                else
                    kl_loc=kl_loc+1;
                end
            end %search_kl
        end %kstr
        
        offset_loc=net_in{idx_tags(1),1};
        expr='[0-9]+.[0-9]+';
        offset_str=regexp(offset_loc,expr,'match');
        offset_dou=cellfun(@str2double,offset_str);
%         offset_des=offset_dou(1):dx_desired:offset_dou(end);
        offset_des=[offset_dou(1),offset_dou(1)+dx_desired:dx_desired:offset_dou(end)-dx_desired,offset_dou(end)];
        ndxd=numel(offset_des); 
        idx_min=NaN(1,ndxd);
        for kdxd=1:ndxd
            [~,idx_min(kdxd)]=min(abs(offset_dou-offset_des(kdxd)));
        end %kdxd
        
        %deal with repeated (one point being closest to 2 desired points)
        [idx_min_u,~,~]=unique(idx_min);
        idx_min=idx_min_u;
        ndxd=numel(idx_min);
        
        offset_get=offset_dou(idx_min);
        
        gridpointcount_get=ndxd;
        
        %gridPointX
        expr='[0-9]+.[0-9]+';
        gridx_loc=net_in{idx_tags(3),1};
        gridx_str=regexp(gridx_loc,expr,'match');
        gridx_dou=cellfun(@str2double,gridx_str);
        gridx_get=gridx_dou(idx_min);
        
        %gridPointY
        expr='[0-9]+.[0-9]+';
        gridy_loc=net_in{idx_tags(4),1};
        gridy_str=regexp(gridy_loc,expr,'match');
        gridy_dou=cellfun(@str2double,gridy_str);
        gridy_get=gridy_dou(idx_min);
        
        %gridPointIds
        exprid='\w+([.-]?\w+)*';
        gridid_loc=net_in{idx_tags(5),1};
        gridid_str=regexp(gridid_loc,exprid,'match');
        gridid_get=gridid_str(2:end); %get rid of {'gridPointIds'}
        gridid_get=gridid_get(idx_min);
        
        %modify output network file
        net_out{idx_tags(2),1}=sprintf('gridPointsCount       = %d                  ',gridpointcount_get);
        
        str_out_grx=sprintf('gridPointX            =  %s',repmat('%.3f ',1,ndxd));
        net_out{idx_tags(3),1}=sprintf(str_out_grx,gridx_get);
        
        str_out_gry=sprintf('gridPointY            =  %s',repmat('%.3f ',1,ndxd));
        net_out{idx_tags(4),1}=sprintf(str_out_gry,gridy_get);
        
        str_out_off=sprintf('gridPointOffsets      =  %s',repmat('%.3f ',1,ndxd));
        net_out{idx_tags(1),1}=sprintf(str_out_off,offset_get);
        
        str_out_pid=sprintf('gridPointIds          =  %s',repmat('%s;',1,ndxd));
        net_out{idx_tags(5),1}=sprintf(str_out_pid,gridid_get{:});
        net_out{idx_tags(5),1}(end)=''; %remove last ;
        
        %% cross section
        
        %identify branch
        expr='\w+([.-]?\w+)*';
        branchid_loc=net_in{idx_tags(6)};
        branchid_str=regexp(branchid_loc,exprid,'match');
        branchid_get=branchid_str{1,2}; %get rid of 'id'
        
        %get chainage of the branch
        idx_cs=find_str_in_cell({cs.branchid},{branchid_get});
        chainage_cs_loc=[cs(idx_cs).chainage];
        
        %find which cross sections to save
        idx_min_cs=NaN(ndxd,1);
        for kdxd=1:ndxd
            [~,idx_min_cs(kdxd)]=min(abs(chainage_cs_loc-offset_get(kdxd)));
        end %kdxd
        
        %save cross sections
            %allocate more if necessary
        if kwcs+10>nlloc
            csloc_out_aux=cell(kwcs+nlloc,1);
            csloc_out_aux(1:kwcs)=csloc_out(1:kwcs);
            csloc_out=csloc_out_aux;
        end
        
        for kdxd=1:ndxd
            csloc_out{kwcs}='[CrossSection]'; kwcs=kwcs+1;
            csloc_out{kwcs}=sprintf('    id                    = %s                ',cs(idx_cs(idx_min_cs(kdxd))).id); kwcs=kwcs+1;
            csloc_out{kwcs}=sprintf('    branchid              = %s                ',cs(idx_cs(idx_min_cs(kdxd))).branchid); kwcs=kwcs+1;
            csloc_out{kwcs}=sprintf('    chainage              = %.3f              ',cs(idx_cs(idx_min_cs(kdxd))).chainage); kwcs=kwcs+1;
            csloc_out{kwcs}=sprintf('    name                  = %s                ',cs(idx_cs(idx_min_cs(kdxd))).name); kwcs=kwcs+1;
            csloc_out{kwcs}=sprintf('    shift                 = %.3f              ',cs(idx_cs(idx_min_cs(kdxd))).shift); kwcs=kwcs+1;
            csloc_out{kwcs}=sprintf('    definition            = %s                ',cs(idx_cs(idx_min_cs(kdxd))).definition); kwcs=kwcs+1;
            csloc_out{kwcs}=''; kwcs=kwcs+1;
        end %kdx
        
        %% observation stations
        
        
    end
    
    %display
    fprintf('done %5.1f \n',kl/nl*100)
    
end %kl

%get only the values filled
csloc_out=csloc_out(1:kwcs-1);

%% write output

    %% network
writetxt('NetworkDefinition_mod.ini',net_out,'check_existing',false);

    %% cross-section
writetxt('CrossSectionLocations_mod.ini',csloc_out,'check_existing',false);

end %function