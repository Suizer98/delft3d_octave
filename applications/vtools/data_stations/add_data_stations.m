%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17498 $
%$Date: 2021-09-29 14:53:15 +0800 (Wed, 29 Sep 2021) $
%$Author: chavarri $
%$Id: add_data_stations.m 17498 2021-09-29 06:53:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/add_data_stations.m $
%

% data_station.location=platform_id;
% data_station.location_clear=station_name;
% data_station.x=xco;
% data_station.y=yco;
% data_station.epsg=epsg;
% data_station.grootheid='WATHTE';
% data_station.eenheid='mNAP';
% data_station.time=tim;
% data_station.waarde=val;
 
function add_data_stations(paths_main_folder,data_add,varargin)

OPT.ask=1; %0=don't ask; 1=always ask; 2=ask only if new data
OPT.filter_time=1;
OPT.tim_diff_thresh=seconds(0.9);
OPT.combine_type=0;

OPT=setproperty(OPT,varargin);

paths=paths_data_stations(paths_main_folder);

%get available data
fields_add_all=fieldnames(data_add);
% naddall=numel(fields_add_all);

idx_add2index=find(~contains(fields_add_all,{'time','waarde'}));
fields_add2index=fields_add_all(idx_add2index);
nadd2i=numel(fields_add2index);

if isfield(data_add,'location_clear')
    str_no_check={'time','waarde','source','location','epsg','x','y'};
else
    str_no_check={'time','waarde','source','epsg','x','y'};
end
idx_compare=find(~any(cell2mat(cellfun(@(X)strcmp(X,fields_add_all),str_no_check,'UniformOutput',false)),2)); %beautiful line to complicate my future debugging
fields_add=fields_add_all(idx_compare);
nadd=numel(fields_add);

tok_add=cell(1,nadd*2);
for kadd=1:nadd
    tok_add{1,kadd*2-1}=fields_add{kadd};
    tok_add{1,kadd*2  }=data_add.(fields_add{kadd});
end

[data_one_station,idx]=read_data_stations(paths_main_folder,tok_add{:});

ns=numel(idx);
%%
if ns==0
    fprintf('\nNew data:\n')
    if isfield(data_add,'location_clear')
        fprintf('    Location clear: %s\n',data_add.location_clear)
    else
        fprintf('    Location: %s\n',data_add.location)
    end
    fprintf('    Grootheid: %s\n',data_add.grootheid)
    if OPT.ask>0
        in=input('Create new data? (0=NO, 1=YES): ');
        if in==0
            return
        end
    end
    load(paths.data_stations_index,'data_stations_index');
    ns=numel(data_stations_index);
    fnames_index=fieldnames(data_stations_index);
    nfnamesindex=numel(fnames_index);
    for kfnames=1:nfnamesindex
        %check type one above
        data_exist=data_stations_index(ns).(fnames_index{kfnames});
        if ischar(data_exist)
            data_stations_index(ns+1).(fnames_index{kfnames})='';
        elseif isa(data_exist,'double')
            data_stations_index(ns+1).(fnames_index{kfnames})=NaN;
        end
    end
    for kadd2i=1:nadd2i
        data_stations_index(ns+1).(fields_add2index{kadd2i})=data_add.(fields_add2index{kadd2i});
    end
    
    %save index
    save(paths.data_stations_index,'data_stations_index');
    
    %save new file
    data_one_station=data_stations_index(ns+1);
    data_one_station.time=data_add.time;
    data_one_station.waarde=data_add.waarde;
    fname_save=fullfile(paths.separate,sprintf('%06d.mat',ns+1));
    save(fname_save,'data_one_station');
    messageOut(NaN,sprintf('New file written: %s',fname_save)); 
%%
elseif ns==1
    fprintf('\nData already available:\n')
    fprintf('    Location clear: %s\n',data_one_station.location_clear)
    fprintf('    Grootheid: %s\n',data_one_station.grootheid)
    if OPT.ask==1
        in=input('Merge? (0=NO, 1=YES): ');
        if in==0
            return
        end
    end
    if numel(data_one_station)>1
        error('Be more specific, there are several data sets for these tokens.')
    end
    
    %combine
    tim_add=data_add.time;
    val_add=data_add.waarde;
    
    tim_ex=data_one_station.time;
    val_ex=data_one_station.waarde;
    
    switch OPT.combine_type
        case 0
                
        case 1 
            
            bol_ex_out=tim_ex>min(tim_add) & tim_ex<max(tim_add);
            tim_ex=tim_ex(~bol_ex_out);
            val_ex=val_ex(~bol_ex_out);
            
    end
  
    tim_tot=cat(1,tim_ex,reshape(tim_add,[],1));
    val_tot=cat(1,val_ex,reshape(val_add,[],1));

    data_r=timetable(tim_tot,val_tot);
    data_r=rmmissing(data_r);
    data_r=sortrows(data_r);
    tim_u=unique(data_r.tim_tot);
%     data_r=retime(data_r,tim_u,'mean'); 

    tim_tot=data_r.tim_tot;
    val_tot=data_r.val_tot;

    %filter times below threshold
    if OPT.filter_time
        tim_diff=diff(tim_tot);
        bol_same=tim_diff<OPT.tim_diff_thresh;
        bol_rem=[false;bol_same];
        tim_tot(bol_rem)=[];
        val_tot(bol_rem)=[];
    end
%     [tim_tot,idx_s]=sort(tim_tot);
%     val_tot=val_tot(idx_s);
     
    %write
    data_one_station.time=tim_tot;
    data_one_station.waarde=val_tot;
    
    fname=fullfile(paths.separate,sprintf('%06d.mat',idx));
    save(fname,'data_one_station')
    messageOut(NaN,sprintf('data added to file %s',fname));
%%
elseif ns>1
    fprintf('Be more precise, there are more than one station with this data:\n')
    for ks=1:ns
        fprintf('Station index: %d \n',idx(ks))
        fprintf('Location clear: %s\n',data_one_station(ks).location_clear)
        fprintf('Grootheid: %s\n',data_one_station(ks).grootheid)
    end
    return
end

end %function