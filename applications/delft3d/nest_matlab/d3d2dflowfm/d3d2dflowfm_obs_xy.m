function d3d2dflowfm_obs_xy(filgrd,filsta,filsta_dflowfm)

% d3d2dflowfm_obs : Convert and writes station information to D-Flow FM input files

if ~isempty(filgrd) && ~isempty(filsta)

    LINE   = [];

    % Open and read the D3D Files
    grid  = delft3d_io_grd('read',filgrd);
    xcoor = grid.cend.x';
    ycoor = grid.cend.y';

    sta   = delft3d_io_obs('read',filsta);

    %
    % Fill LINE struct for writing to unstruc file
    %

    for ista = 1: sta.NTables
        LINE.DATA{ista,1} = xcoor(sta.m(ista),sta.n(ista));
        LINE.DATA{ista,2} = ycoor(sta.m(ista),sta.n(ista));
        LINE.DATA{ista,3} = ['''' strtrim(sta.namst(ista,:)) ''''];
    end

    % finally write to the unstruc obs file

    dflowfm_io_xydata('write',filsta_dflowfm,LINE);

end
