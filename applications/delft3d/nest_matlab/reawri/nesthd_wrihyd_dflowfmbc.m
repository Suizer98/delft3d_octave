function nesthd_wrihyd_dflowfmbc(fileOut,bnd,nfs_inf,bndval,add_inf,varargin)

% wrihyd_dflowfmbc  : writes hydrodynamic bc to a DFLOWFM bc file
%                     first beta version
%                     for now, only water level boundaries
%                              TK: 18/03/2019  Constituents added
%
%% Set some general parameters
no_pnt        = size  (bndval(1).value,1);
no_times      = length(bndval);
no_layers     = size(bndval(1).value,2);
thick         = nfs_inf.thick;
OPT.first     = false;
OPT.ipnt      = NaN;
OPT           = setproperty(OPT,varargin);

st = dbstack;
if length(st) >= 2 && strcmp(st(2).name,'nesthd_wricon') % caller is nesthd_wricon
    lstci     = nfs_inf.lstci;
else
    lstci     = -1; % Use lstci = -1 to indicate hydrodynamic bc
    no_layers = no_layers/2;
end

itdate        = datestr(nfs_inf.itdate,'yyyy-mm-dd HH:MM:SS');
[path,~,~]    = fileparts(fileOut);
if isempty(path); path = '.'; end

if ~isfield(add_inf,'timeZone'); add_inf.timeZone = 0; end

%% Switch orientation if overall model is delft3D or Waqua (not for fixed layer Delft3D!)
if ~strcmpi(nfs_inf.from,'dfm') && strcmpi(ndf_inf.layer_model,'sigma-model')
    [bndval,thick] = nesthd_flipori(bndval,thick);
end

%% Determine vertical positions
pos(1)        = 0.5*thick(1);
for i_lay = 2: no_layers
    pos(i_lay) = pos(i_lay - 1) + 0.5*(thick(i_lay - 1) + thick(i_lay));
end

%% cycle over boundary points
for i_pnt = 1: no_pnt
    if no_pnt >  1; bndNr = i_pnt   ; end
    if no_pnt == 1; bndNr = OPT.ipnt; end
    ext_force = [];
    l_act     =  0;

    for i_conc = 1:max(1,lstci)
        if lstci >= 1
            if add_inf.genconc(i_conc)

                %% Name of the constituent
                quantity = nfs_inf.namcon{i_conc};
                l_act    = l_act + 1;
            end
        elseif lstci == -1

            %% Type of hydrodynamic boundary
            if strcmpi(bnd.DATA(bndNr).bndtype,'z')
                quantity = 'waterlevel';
            elseif strcmpi(bnd.DATA(bndNr).bndtype,'p')
                quantity = 'uxuyadvectionvelocity';
            else
                quantity = ''; % initialise to avoid errors or checks like if exist('quantity','var') && ...
            end
            l_act = 1;
        end

        if lstci == -1 || (lstci >=1 && add_inf.genconc(i_conc))
            %% Header information
            ext_force(l_act).Chapter                  = 'forcing';
            ext_force(l_act).Keyword.Name {1}         = 'Name';
            ext_force(l_act).Keyword.Value{1}         = bnd.Name{bndNr};
            ext_force(l_act).Keyword.Name {end+1}     = 'Function';
            if strcmpi(quantity,'waterlevel') ||  strcmpi(add_inf.profile,'uniform')
                dav                                   = true;
                ext_force(l_act).Keyword.Value{end+1} = 'timeseries';
            elseif strcmpi(add_inf.profile,'3d-profile')
                dav                                   = false;
                ext_force(l_act).Keyword.Value{end+1} = 't3d';
            end

            ext_force(l_act).Keyword.Name {end+1}     = 'Time-interpolation';
            ext_force(l_act).Keyword.Value{end+1}     = 'linear';

            if (strcmpi(quantity,'uxuyadvectionvelocity'))
                ext_force(l_act).Keyword.Name {end+1}     = 'Vector';
                ext_force(l_act).Keyword.Value{end+1}     = 'uxuyadvectionvelocitybnd:ux,uy';
            end

            if  strcmpi(quantity,'waterlevel') &&  isfield(add_inf,'a0_dfm')
                ext_force(l_act).Keyword.Name {end+1} = 'Offset';
                ext_force(l_act).Keyword.Value{end+1} = num2str(add_inf.a0_dfm,'%12.3f');
            end

            if ~dav
                if strcmpi(nfs_inf.layer_model,'sigma-model')
                    ext_force(l_act).Keyword.Name {end+1} = 'Vertical position type         ';
                    ext_force(l_act).Keyword.Value{end+1} = 'percentage from bed';
                    nonan                                 = true(no_layers,1);
                    format                                = repmat('%6.3f ',1,no_layers);
                    ext_force(l_act).Keyword.Name {end+1} = 'Vertical position specification';
                    ext_force(l_act).Keyword.Value{end+1} = sprintf(format,pos);
                else % z-(sigma-)layer model
                    if bndNr == 1 && i_conc == 1; warning('Fixed or mixed layers (z and z-sigma) not properly checked yet'); end
                    ext_force(l_act).Keyword.Name {end+1} = 'Vertical position type         ';
                    ext_force(l_act).Keyword.Value{end+1} = 'zdatum';
                    zcen_cen                              = bndval(1).zInterp; % take z-(sigma-)layer coordinates from first timestep

                    nr_active_layer                       = length(zcen_cen);
                    format                                = repmat('%6.3f ',1,nr_active_layer);
                    ext_force(l_act).Keyword.Name {end+1} = 'Vertical position specification';
                    ext_force(l_act).Keyword.Value{end+1} = sprintf(format,zcen_cen);
                end

            end

            ext_force(l_act).Keyword.Name {end+1} = 'Quantity';
            ext_force(l_act).Keyword.Value{end+1} = 'time';
            ext_force(l_act).Keyword.Name {end+1} = 'Unit';
            ext_force(l_act).Keyword.Value{end+1} = ['minutes since ' itdate];

            no_xy = 1;
            if strcmpi(quantity,'uxuyadvectionvelocity') no_xy = 2; end

            if dav
                for i_xy = 1: no_xy
                    ext_force(l_act).Keyword.Name {end+1} = 'Quantity';
                    ext_force(l_act).Keyword.Value{end+1} = [quantity 'bnd'];
                    if strcmpi(quantity,'uxuyadvectionvelocity')
                        if i_xy == 1 ext_force(l_act).Keyword.Value{end} = 'ux'; end
                        if i_xy == 2 ext_force(l_act).Keyword.Value{end} = 'uy'; end
                    end
                    ext_force(l_act).Keyword.Name {end+1} = 'Unit';
                    ext_force(l_act).Keyword.Value{end+1} = 'kg/m3';
                    if strcmpi(quantity,'waterlevel'           ) ext_force(l_act).Keyword.Value{end} = 'm'  ; end
                    if strcmpi(quantity,'uxuyadvectionvelocity') ext_force(l_act).Keyword.Value{end} = 'm/s'; end
                    if strcmpi(quantity,'salinity'             ) ext_force(l_act).Keyword.Value{end} = 'psu'; end
                    if strcmpi(quantity,'temperature'          ) ext_force(l_act).Keyword.Value{end} = 'oC' ; end
                end
            else
                for i_lay = 1: no_layers
                    for i_xy = 1: no_xy
                        ext_force(l_act).Keyword.Name {end+1} = 'Quantity';
                        ext_force(l_act).Keyword.Value{end+1} = [quantity 'bnd'];
                        if strcmpi(quantity,'uxuyadvectionvelocity')
                            if i_xy == 1 ext_force(l_act).Keyword.Value{end} = 'ux'; end
                            if i_xy == 2 ext_force(l_act).Keyword.Value{end} = 'uy'; end
                        end
                        ext_force(l_act).Keyword.Name {end+1} = 'Unit';
                        ext_force(l_act).Keyword.Value{end+1} = 'kg/m3';
                        if strcmpi(quantity,'waterlevel'           ) ext_force(l_act).Keyword.Value{end} = 'm'  ; end
                        if strcmpi(quantity,'uxuyadvectionvelocity') ext_force(l_act).Keyword.Value{end} = 'm/s'; end
                        if strcmpi(quantity,'salinity'             ) ext_force(l_act).Keyword.Value{end} = 'psu'; end
                        if strcmpi(quantity,'temperature'          ) ext_force(l_act).Keyword.Value{end} = 'oC' ; end
                        ext_force(l_act).Keyword.Name {end+1} = 'Vertical position';
                        ext_force(l_act).Keyword.Value{end+1} = num2str(i_lay,'%3i');
                    end
                end
            end

            %% Series information
            for i_time = 1: no_times
                ext_force(l_act).values(i_time,1) = (nfs_inf.times(i_time) - nfs_inf.itdate)*1440. + add_inf.timeZone*60.;    % minutes!
                if dav
                    ext_force(l_act).values(i_time,2) = bndval(i_time).value(i_pnt,1,i_conc);
                    if lower(bnd.DATA(bndNr).bndtype) == 'p' || lower(bnd.DATA(bndNr).bndtype) == 'x'
                        ext_force(i_conc).values(i_time,3) = bndval(i_time).value(i_pnt,2,1);
                    end
                else
                    for i_lay = 1: no_layers
                        if no_xy == 2
                            for i_xy = 1: no_xy
                                ext_force(l_act).values(i_time,i_lay*2 + i_xy - 1) = bndval(i_time).value(i_pnt,i_lay +  (i_xy - 1)*no_layers,i_conc);
                            end
                        else
                            ext_force(l_act).values(i_time,i_lay + 1) = bndval(i_time).value(i_pnt,i_lay,i_conc);
                        end
                    end
                end
            end
        end
    end

    %% Write the series for individual support points, first time open file, after that append
    if (i_pnt == 1  && no_pnt > 1) || OPT.first
        dflowfm_io_extfile('write',fileOut,'ext_force',ext_force,'type','ini');
    else
        dflowfm_io_extfile('write',fileOut,'ext_force',ext_force,'type','ini','first',false);
    end
end
