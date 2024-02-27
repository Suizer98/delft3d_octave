%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17508 $
%$Date: 2021-09-30 17:17:04 +0800 (Thu, 30 Sep 2021) $
%$Author: chavarri $
%$Id: data_stations_stations_to_load.m 17508 2021-09-30 09:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/data_stations_stations_to_load.m $
%

function idx=data_stations_stations_to_load(paths_main_folder,varargin)

%% parse

loadall=false;
loadbol=false;
loadidx=false;

if numel(varargin)==1 
    if ischar(varargin{1,1})
        switch varargin{1,1}
            case 'loadall'
                loadall=true;
        end
    elseif islogical(varargin{1,1})
        loadbol=true;
        bol=varargin{1,1};
    else
        loadidx=true;
        idx=varargin{1,1};
    end
    
else

    if rem(numel(varargin),2)~=0
        error('Input should be multiple of two')
    end
    var_name=varargin(1:2:end-1);
    var_loc=varargin(2:2:end);

    ni=numel(var_name);
end

paths=paths_data_stations(paths_main_folder);

%% stations to load

if ~loadidx
    if ~loadbol
        load(paths.data_stations_index,'data_stations_index');
        ns=numel(data_stations_index);
        bol=true(1,ns);
        if ~loadall
            for ki=1:ni
                bol_loc=true(1,ns);
                if ischar(var_loc{ki}) && ~isempty(var_loc{ki})
                    [~,bol_loc]=find_str_in_cell({data_stations_index.(var_name{ki})},var_loc(ki));
                elseif isa(var_loc{ki},'double') && ~isnan(var_loc{ki})
                    bol_loc=[data_stations_index.(var_name{ki})]==var_loc{ki};
                end
                bol=bol & bol_loc;
            end
        end
    end %loadbol
    idx=find(bol);
end %loadidx

end %function
