function mdu = d3d2dflow_bndforcing(mdf,mdu,name_mdu)

ext_force = dflowfm_io_extfile('read',[mdu.pathmdu filesep mdu.external_forcing.ExtForceFile]);

no_bnd  = 0;
filpli = [];

%% Find the open hydrodynamic boundaries
for i_force = 1: length(ext_force)
    if ~isempty(strfind(ext_force(i_force).quantity,'bnd'        )) && ...
        isempty(strfind(ext_force(i_force).quantity,'salinity'   )) && ...
        isempty(strfind(ext_force(i_force).quantity,'temperature')) && ...
        strcmpi(ext_force(i_force).operand,'O')
        no_bnd        = no_bnd + 1;
        index(no_bnd) = i_force;
    end
end


%% Make the list of pli files
for i_bnd = 1: no_bnd
    if ~isempty(mdu.pathmdu)
        filpli{i_bnd} = [mdu.pathmdu filesep ext_force(index(i_bnd)).filename];
    else
        filpli{i_bnd} = ext_force(index(i_bnd)).filename;
    end
end

%% Convert hydrodynamic boundary conditions, start with astronomical bc

if simona2mdf_fieldandvalue(mdf,'filana')
    if simona2mdf_fieldandvalue(mdf,'filcor') && ~isempty(mdf.filcor)

        %% with correction file
        d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filana],filpli,mdu.pathmdu,'Astronomical',true,'Correction',[mdf.pathd3d filesep mdf.filcor],'Sign',true);
    else

        %% without correction file
        d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filana],filpli,mdu.pathmdu,'Astronomical',true,'Sign',true);
    end
end
if simona2mdf_fieldandvalue(mdf,'filbch')

    %% Harmonical bc
    d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filbch],filpli,mdu.pathmdu,'Harmonic'    ,true,'Sign',true);
end
if simona2mdf_fieldandvalue(mdf,'filbct')

    %% Time series bc
    d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filbct],filpli,mdu.pathmdu,'Series'      ,true,'Sign',true,'Thick',mdf.thick);
end

%% Same story, this time for sea level anomalies
no_bnd  = 0;
filpli = [];

%% Find the open bc0 boundaries
for i_force = 1: length(ext_force)
    if ~isempty(strfind(ext_force(i_force).quantity,'bnd'        )) && ...
        isempty(strfind(ext_force(i_force).quantity,'salinity'   )) && ...
        isempty(strfind(ext_force(i_force).quantity,'temperature')) && ...
        strcmpi(ext_force(i_force).operand,'+')
        no_bnd        = no_bnd + 1;
        index(no_bnd) = i_force;
    end
end

%% Make the list of pli files
for i_bnd = 1: no_bnd
    if ~isempty(mdu.pathmdu)
        filpli{i_bnd} = [mdu.pathmdu filesep ext_force(index(i_bnd)).filename];
    else
        filpli{i_bnd} = ext_force(index(i_bnd)).filename;
    end
end

%% Convert sea level anomolies boundaries
if simona2mdf_fieldandvalue(mdf,'filbc0')

    %% Time series bc
    d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filbc0],filpli,mdu.pathmdu,'Series'      ,true,'Sign',true);
end


%% Same story, this time for the salinity boundaries boundaries
no_bnd  = 0;
filpli  = [];

for i_force = 1: length(ext_force)
    if ~isempty(strfind(ext_force(i_force).quantity,'bnd')) &&  ...
       ~isempty(strfind(ext_force(i_force).quantity,'salinity'))
        no_bnd = no_bnd + 1;
        index(no_bnd) = i_force;
    end
end

%% Make the list of pli files
for i_bnd = 1: no_bnd
    filpli{i_bnd} = [mdu.pathmdu filesep ext_force(index(i_bnd)).filename];
end

%% Convert salinity boundary conditions
if simona2mdf_fieldandvalue(mdf,'filbcc') && ~isempty(filpli)
    d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filbcc],filpli,mdu.pathmdu,'Salinity',true,'Thick',mdf.thick,'Sign',true);
end

%% Same story, this time for the temperature boundaries boundaries
no_bnd  = 0;
filpli  = [];

for i_force = 1: length(ext_force)
    if ~isempty(strfind(ext_force(i_force).quantity,'bnd')) &&  ...
       ~isempty(strfind(ext_force(i_force).quantity,'temperature'))
        no_bnd = no_bnd + 1;
        index(no_bnd) = i_force;
    end
end

%% Make the list of pli files
for i_bnd = 1: no_bnd
    filpli{i_bnd} = [mdu.pathmdu filesep ext_force(index(i_bnd)).filename];
end

%% Convert salinity temperature boundary conditions
if simona2mdf_fieldandvalue(mdf,'filbcc') && ~isempty(filpli)
    d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filbcc],filpli,mdu.pathmdu,'Temperature',true,'Thick',mdf.thick,'Sign',true);
end
