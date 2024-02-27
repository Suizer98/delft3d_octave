function mdu = d3d2dflow_evap(mdf,mdu,name_mdu)

fileva    = '';
ext_force = dflowfm_io_extfile('read',[mdu.pathmdu filesep mdu.external_forcing.ExtForceFile]);

%_
% Uniform find forcing

for i_force = 1: length(ext_force)
    if ~isempty(strfind(ext_force(i_force).quantity,'rainfall_mmperday'))
       fileva = [mdu.pathmdu filesep ext_force(i_force).filename];
    end
end

if ~isempty (fileva)
    %
    % Read Delft3D-Flow windforcing data, put into the series array
    evap = delft3d_io_eva('read',[mdf.pathd3d filesep mdf.fileva]);

    SERIES.Values(:,1) = evap.data.minutes;
    SERIES.Values(:,2) = 24.0*(evap.data.precipitation - evap.data.evaporation); %Delft3D-Flow mm/hr; unstruc mm/day
    SERIES.Values      = num2cell(SERIES.Values);

    %
    % General Comments
    SERIES.Comments{1} = '* COLUMNN=2';
    SERIES.Comments{2} = '* COLUMN1=Time (minutes since ITDATE?)';
    SERIES.Comments{3} = '* COLUMN2=Rainfal (negative evaporation) in mm/day';

    %
    % Write the series to file
    dflowfm_io_series('write',fileva,SERIES);
end
