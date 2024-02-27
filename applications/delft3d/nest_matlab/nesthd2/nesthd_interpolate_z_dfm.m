function [bndval] = nesthd_interpolate_z_dfm(bndval,gen_inf,add_inf,fileInp,varargin)

%% Interpolate boundary values to a vertical with fixed points (zInterp).
%  For the generation of 3D boundary conditions in case the overall model is a D-Hydro model with fixed layer or combination of fixed/sigma layers.
%
%  Method:
%  - Determine 1 interpolation vertical zInterp to e used for all time steps!
%  - Use the most important station, i.e. the station with the largest weight.
%  - For z-sigma: use as starting point the vertical coordinates at the first time step. Than, stack layers until just below the water surface.
%  = For z      : use vertical coordinates at time of maximum water level (time when most layers are "active").
%  - add both water level and bed to the interpolation vertical,
%  - interpolate everything to zInterp
%  - add A0 to zInterp (in case overall and detailled model hev a different vertical reference level).
%  - store zInterp for use in writing of the bc file

%% Initialise
notims      = gen_inf.notims;
t0          = gen_inf.times(1);
tend        = gen_inf.times(notims);
kmax        = gen_inf.kmax;
layer_model = gen_inf.layer_model;
lstci       = 1;
if length(size(bndval(1).value)) ~= 2 lstci = size(bndval(1).value,3); end

OPT.bndType = 'constituent';
OPT         = setproperty(OPT,varargin);

%% No interpolation for water level and neumann boundaries
if ~strcmpi(OPT.bndType,'z') && ~strcmpi(OPT.bndType,'n')

    %% Only if detailled model is dfm (and kmax > 1)
    if strcmpi(gen_inf.from,'dfm') && kmax > 1 && (strcmpi(layer_model,'z-sigma-model') || ...
            strcmpi(layer_model,'z-model')                                              )

        % maximum water level and intial z coordinates
        wlevTmp            = EHY_getmodeldata(fileInp,bndval(1).statMax,'dfm','varName','wl'      ,'t0',t0,'tend',tend);
        data_zcen_cen      = EHY_getmodeldata(fileInp,bndval(1).statMax,'dfm','varName','Zcen_cen','t0',t0,'tend',tend);
        bed                = EHY_getmodeldata(fileInp,bndval(1).statMax,'dfm','varName','bed'                         );
        [wlevMax,indexMax] = max(wlevTmp.val);

        % Generate z coordinates for interpolation
        switch layer_model
            case 'z-sigma-model'

                % Based on coordinates at t = t0
                zInterp       = squeeze(data_zcen_cen.val(1,1,:));
                zInterp       = zInterp(~isnan(zInterp));

                % Stack layers until maximum water level is reached
                while zInterp(end) < wlevMax
                    zInterp (end + 1) = zInterp(end) + (zInterp(end) - zInterp(end - 1));
                    zInterp (end    ) = min(zInterp(end),wlevMax);
                end

            case 'z-model'

                % based on coordinates at time of maximam water level
                zInterp        = squeeze(data_zcen_cen.val(indexMax,1,:));
                zInterp        = zInterp(~isnan(zInterp));
                zInterp(end+1) = wlevMax;
        end
        zInterp = [bed.val zInterp'];
        kmaxInt = length(zInterp);

        %% Now, Interpolate everything to zInterp
        tmp  = bndval;
        clear bndval

        for i_time = 1: notims

            % Use only "active" layers
            index                     = ~isnan(data_zcen_cen.val(i_time,1,:));
            zOrg                      = squeeze(data_zcen_cen.val(i_time,1,index));
            zOrg                      = [bed.val zOrg' wlevMax];

            % For all of the constituents
            for l = 1: lstci
                value_u                     = tmp(i_time).value(1,1       :kmax,l); % Can be water levels
                value_u                     = value_u(index);
                value_u                     = [value_u(1) value_u value_u(end)];
                bndval(i_time).value(1,:,l) = interp1(zOrg,value_u,zInterp);

                % Parallel/v velocities
                if ~strcmpi(OPT.bndType,'constituent')
                    value_v                                         = tmp(i_time).value(1,kmax + 1:end ,l);
                    value_v                                         = value_v(index);
                    value_v                                         = [value_v(1) value_v value_v(end)];
                    bndval(i_time).value(1,kmaxInt + 1:2*kmaxInt,l) = interp1(zOrg,value_v,zInterp);
                end
            end
        end

        %% Store zInterp
        bndval(1).zInterp = zInterp;
        if isfield('add_inf','a0_dfm') bndval(1).zInterp = bndval(1).zInterp + add_inf.a0_dfm; end
    end
end



