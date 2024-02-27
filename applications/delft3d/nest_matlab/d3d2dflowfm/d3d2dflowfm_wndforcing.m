function mdu = d3d2dflow_wndforcing(mdf,mdu,name_mdu)

filwnd    = '';
ext_force = dflowfm_io_extfile('read',[mdu.pathmdu filesep mdu.external_forcing.ExtForceFile]);

%_
% Uniform find forcing

for i_force = 1: length(ext_force)
    if ~isempty(strfind(ext_force(i_force).quantity,'windxy'))
       filwnd = [mdu.pathmdu filesep ext_force(i_force).filename];
    end
end

if ~isempty (filwnd)
    %
    % Read Delft3D-Flow windforcing data, put into the series array
    wnd = delft3d_io_wnd('read',[mdf.pathd3d filesep mdf.filwnd]);

    SERIES.Values(:,1) = wnd.data.minutes;
    SERIES.Values(:,2) = wnd.data.speed;
    SERIES.Values(:,3) = wnd.data.direction;
    SERIES.Values      = num2cell(SERIES.Values);

    %
    % General Comments
    SERIES.Comments{1} = '* COLUMNN=3';
    SERIES.Comments{2} = '* COLUMN1=Time (minutes since ITDATE?)';
    SERIES.Comments{3} = '* COLUMN2=Windspeed (m/s)';
    SERIES.Comments{4} = '* COLUMN3=Winddirection (deg, nautical convention)';

    %
    % Write the series to file
    dflowfm_io_series('write',filwnd,SERIES);
end
