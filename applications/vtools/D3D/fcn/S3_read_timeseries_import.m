%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17376 $
%$Date: 2021-07-02 22:00:24 +0800 (Fri, 02 Jul 2021) $
%$Author: chavarri $
%$Id: S3_read_timeseries_import.m 17376 2021-07-02 14:00:24Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/S3_read_timeseries_import.m $
%
%read time series from a Sobek-3 timeseries_import file based on locationId 

function data_loc=S3_read_timeseries_import(path_js,locationId_v)

%loop on locations
nloc=numel(locationId_v);
data_loc=struct();

for kloc=1:nloc
        
    kl_location=search_text_ascii(path_js,locationId_v{kloc,1},1); %search line with location

    if isnan(kl_location)
        error('location not found: %s',locationId_v{kloc,1});
    end
    
    kl_event=search_text_ascii(path_js,'<event',kl_location); %search line with event

    if isnan(kl_event)
        error('time series for location not found: %s',locationId_v{kloc,1});
    end
    
    %get data
    data_one_loc=read_data_ascii(path_js,'<event date="(\d{4}-\d{2}-\d{2})" time="(\d{2}:\d{2}:\d{2})" value="(\d*?.\d*)" />',kl_event);

    aux_dat=cellfun(@(X)X{1,1}{1,1},data_one_loc,'UniformOutput',false);
    aux_tim=cellfun(@(X)X{1,1}{1,2},data_one_loc,'UniformOutput',false);
    aux_val=cellfun(@(X)X{1,1}{1,3},data_one_loc,'UniformOutput',false);

    aux_dattim=cellfun(@(X,Y)sprintf('%s %s',X,Y),aux_dat,aux_tim,'UniformOutput',false);

    tim=datetime(aux_dattim,'InputFormat','yyyy-MM-dd HH:mm:ss');
    val=cellfun(@(X)str2double(X),aux_val);

    %save
    data_loc(kloc).tim=tim; 
    data_loc(kloc).val=val; 

    %disp
    fprintf('done %4.2f %% \n',kloc/nloc*100)

end

end %function