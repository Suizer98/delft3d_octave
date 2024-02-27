%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: modify_boundary_conditions.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/rmm_setup/modify_boundary_conditions.m $
%

function bcmod=modify_boundary_conditions(bc,bcn,loclabels,start_time)

bcmod=bc;
nbcd=numel(bcn.tsc);

%get names of all stations with BC
        %there may be a smarte way to do this
        %we rely on the name being in the first position. otherwise, first
        %search where name is.
nbc=numel(bcmod);
bc_prop=cell(nbc,2); %1: name, 2:quantity
for kbc=1:nbc
    idx_aux=find(strcmp(bcmod(kbc).Keyword.Name,'name'));
    if ~isempty(idx_aux)
        bc_prop{kbc,1}=bcmod(kbc).Keyword.Value{idx_aux};  
    else
        bc_prop{kbc,1}='';
    end
    idx_aux=find(strcmp(bcmod(kbc).Keyword.Name,'quantity'));
    if ~isempty(idx_aux)
        aux_name={bcmod(kbc).Keyword.Value{idx_aux}}; %#ok<CCAT1>
        idx_t=strcmp([aux_name],'time'); %#ok<NBRAK>
        bc_prop{kbc,2}=aux_name{~idx_t};
    else
        bc_prop{kbc,2}='';
    end
end
    
%loop on data boundary conditions
for kbcd=1:nbcd
    idx_loc_data_v=find(strcmp({loclabels.data},bcn.tsc(kbcd).Locatiecode));
    paramcode=bcn.tsc(kbcd).Parametercode;
    
    nlocdata=numel(idx_loc_data_v);
    
    for klocdata=1:nlocdata
        idx_loc_data=idx_loc_data_v(klocdata);
        
        %identify model wide parameters
        if any(strcmp(paramcode,{'WINDRTG','WINDSHD'}))
            idx_loc_data=NaN;
        end

        if ~isempty(idx_loc_data)
            switch paramcode
                case 'Cl'
                    quantity_s3='water_salinity';
                    unit_s3='ppt';
                case 'Q'
                    quantity_s3='water_discharge';
                    unit_s3='m^3/s';
                case 'WATHTE'
                    quantity_s3='water_level';
                    unit_s3='m';
                case 'WINDRTG'
                    quantity_s3='wind_from_direction';
                    unit_s3='degree';
                case 'WINDSHD'
                    quantity_s3='wind_speed';
                    unit_s3='m/s';
                otherwise 
                    error('define it')
            end

            if isnan(idx_loc_data) %model wide
                bc_name='model_wide';
            else
                bc_name=loclabels(idx_loc_data).s3;
            end
            idx_loc_bc=find(strcmp(bc_prop(:,1),bc_name));
            idx_bc_prop2=find(strcmp(bc_prop(idx_loc_bc,2),quantity_s3));
            idx_bcmod=idx_loc_bc(idx_bc_prop2);

            %rename all is easier, as some are initially not a time series
                %maybe it is necessary to first empty it?
            bcmod(idx_bcmod).Keyword.Name{1}='name';
            bcmod(idx_bcmod).Keyword.Value{1}=bc_name;

            bcmod(idx_bcmod).Keyword.Name{2}='function';
            bcmod(idx_bcmod).Keyword.Value{2}='timeseries';

            bcmod(idx_bcmod).Keyword.Name{3}='time-interpolation';
            bcmod(idx_bcmod).Keyword.Value{3}='linear-extrapolate';

            bcmod(idx_bcmod).Keyword.Name{4}='quantity';
            bcmod(idx_bcmod).Keyword.Value{4}='time';

            bcmod(idx_bcmod).Keyword.Name{5}='unit';
            bcmod(idx_bcmod).Keyword.Value{5}=sprintf('minutes since %s',datestr(start_time,'yyyy-mm-dd HH:MM:ss'));

            bcmod(idx_bcmod).Keyword.Name{6}='quantity';
            bcmod(idx_bcmod).Keyword.Value{6}=quantity_s3;

            bcmod(idx_bcmod).Keyword.Name{7}='unit';
            bcmod(idx_bcmod).Keyword.Value{7}=unit_s3;

            %time
            time_data=minutes(bcn.tsc(kbcd).daty-start_time);
            if ~isnan(idx_loc_data)
                if loclabels(idx_loc_data).function_s3==1 %applyt shift time
                    time_data=time_data+loclabels(idx_loc_data).function_param_s3;
                end
            else
                %we should deal with the case in which you could like to apply
                %a function to model wide parameters
            end

            %quantity
            quantity_data=reshape(bcn.tsc(kbcd).val,[],1);
            switch bcn.tsc(kbcd).Parametereenheid
                case 'mg/l'
                    quantity_data=quantity_data*0.0018066;
                case 'cm'
                    quantity_data=quantity_data/100;
            end

            nt=numel(time_data);
            bcmod(idx_bcmod).values=cell(nt,2);
            bcmod(idx_bcmod).values(:,1)=num2cell(time_data');
            bcmod(idx_bcmod).values(:,2)=num2cell(quantity_data);

            %plot modified boundary conditions
            han.fig=figure;
            hold on
            plot(time_data,quantity_data)
            xlabel(bcmod(idx_bcmod).Keyword.Value{5})
            ylabel(sprintf('%s [%s]',strrep(quantity_s3,'_',' '),unit_s3))
            title(strrep(bc_name,'_','\_'))
            print(han.fig,sprintf('%s_%d.png',bc_name,kbcd),'-dpng','-r300')
            close(han.fig)

        end %~isempty(idx_loc_data)
    end %klocdata    
end %kbcd

end %function