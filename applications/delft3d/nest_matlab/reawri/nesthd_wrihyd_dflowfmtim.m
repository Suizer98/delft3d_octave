function nesthd_wrihyd_dflowfmtim(filename,bnd,nfs_inf,bndval,add_inf,varargin)

% wrihyd_dflowfmtim : writes hydrodynamic bc to a DFLOWFM tim files
%                     first beta version
%
% Set some general parameters
%

no_pnt        = size  (bndval(1).value,1);
no_times      = length(bndval);
kmax          = size(bndval(1).value,2)/2;
[path,~,~]    = fileparts(filename);
OPT.ipnt      = NaN;
OPT           = setproperty(OPT,varargin);
%
% cycle over boundary points
%

for i_pnt = 1: no_pnt
    if no_pnt >  1; bndNr = i_pnt   ; end
    if no_pnt == 1; bndNr = OPT.ipnt; end
    fname       = [path filesep bnd.Name{bndNr} '.tim'];

    % Comments

    SERIES.Comments{1} = '* COLUMNN=2';
    SERIES.Comments{2} = ['* COLUMN1=Time (min) since ' datestr(nfs_inf.itdate,'yyyy-mm-dd  HH:MM:SS')];

    if lower(bnd.DATA(bndNr).bndtype) == 'z'
        SERIES.Comments{3} = '* COLUMN2=Waterlevel';
    elseif lower(bnd.DATA(bndNr).bndtype) == 'c'
        SERIES.Comments{3} = '* COLUMN2=Perpendicular velocity';
    elseif lower(bnd.DATA(bndNr).bndtype) == 'r'
        SERIES.Comments{3} = '* COLUMN2=Rieman invariant (D3D - flow definition)';
    elseif lower(bnd.DATA(bndNr).bndtype) == 'p'
         SERIES.Comments{1} = '* COLUMNN=3';
         SERIES.Comments{3} = '* COLUMN2=Perpendicular velocity';
         SERIES.Comments{4} = '* COLUMN3=Tangential velocity';
    elseif lower(bnd.DATA(bndNr).bndtype) == 'x'
         SERIES.Comments{1} = '* COLUMNN=3';
         SERIES.Comments{3} = '* COLUMN2=Rieman invariant';
         SERIES.Comments{4} = '* COLUMN3=Tangential velocity';
    end

    % Boundary values

    for i_time = 1: no_times
        SERIES.Values(i_time,1) = (nfs_inf.times(i_time) - nfs_inf.itdate)*1440. + add_inf.timeZone*60.;    % minutes!
        SERIES.Values(i_time,2) = bndval(i_time).value(i_pnt,1,1);
        if lower(bnd.DATA(bndNr).bndtype) == 'p' || lower(bnd.DATA(bndNr).bndtype) == 'x'
            SERIES.Values(i_time,3) = bndval(i_time).value(i_pnt,2,1);
        end
    end

    % Write the series

    SERIES.Values = num2cell(SERIES.Values);
    dflowfm_io_series( 'write',fname,SERIES);

    clear SERIES
end
