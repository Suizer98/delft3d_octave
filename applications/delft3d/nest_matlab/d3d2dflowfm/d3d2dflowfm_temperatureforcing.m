function mdu = d3d2dflow_temperatureforcing(mdf,mdu,name_mdu)

filtem    = '';
ext_force = dflowfm_io_extfile('read',[mdu.pathmdu filesep mdu.external_forcing.ExtForceFile]);

%
%% Read name of unstruc file out of external forcing file
for i_force = 1: length(ext_force)
    if ~isempty(strfind(ext_force(i_force).quantity,'humidity_airtemperature_cloudiness')) 
       filtem = [mdu.pathmdu filesep ext_force(i_force).filename];
    end
end

if ~isempty (filtem)
    %
    %% Read Delft3D-Flow temperature file
    tem = delft3d_io_tem('read',[mdf.pathd3d filesep mdf.filtmp],[mdf.pathd3d filesep mdf.named3d]);
    
    %% Times
    times              = (tem.data.datenum - tem.refdatenum)*1440.;
    SERIES.Values(:,1) = times;
    
    if mdu.physics.Temperature == 5 
        %% Names and values
        names     = fieldnames(tem.data);
        no_vars   = (length(names) - 2)/2;
        for i_var = 1: no_vars
            name_var{i_var} = names{3 + (i_var-1)*2};
            unit_var{i_var} = names{4 + (i_var-1)*2};
            SERIES.Values(:,i_var + 1) = tem.data.(name_var{i_var});
        end
        
        %% General Comments
        SERIES.Comments{1} = ['* COLUMNN=' num2str(no_vars + 1)];
        for i_var = 1: no_vars
           SERIES.Comments{i_var + 2} = ['* COLUMN' num2str(i_var + 1) '=' name_var{i_var} ' ' tem.data.(unit_var{i_var})];
        end
    elseif mdu.physics.Temperature == 3
        SERIES.Values(:,2) = -999.999;
        SERIES.Values(:,3) = tem.data.airtemperature;
        SERIES.Values(:,4) = -999.999;
        SERIES.Comments{1} = '* COLUMNN=4';
        SERIES.Comments{2} = '* COLUMN1=Time';
        SERIES.Comments{3} = '* COLUMN2=Relative Humidity (dummy)';
        SERIES.Comments{4} = '* COLUMN3=Air temperature';
        SERIES.Comments{5} = '* COLUMN4=Cloudiness (dummy)';
    end
    %
    %% Write the series to file
    SERIES.Values = num2cell(SERIES.Values);
    dflowfm_io_series('write',filtem,SERIES);
end
