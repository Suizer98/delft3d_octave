function bct = simona2bnd_bct(S,bnd,mdf, varargin)

% simona2mdf_bca : gets time-series boundary forcing out the mdf file

bct      = [];
ibnd_bct = 0;

%
% Time series forcing data
%

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

%
% get information out of struc
%

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'FORCINGS' 'TIMESERIES'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.FORCINGS.TIMESERIES')
    series       = siminp_struc.ParsedTree.FLOW.FORCINGS.TIMESERIES;

    %
    % cycle over all open boundaries
    %

    for ibnd = 1: length(bnd.DATA)

        %
        % Type of boundary out of the bndstruc, for astronomical data continue
        %

        if strcmpi(bnd.DATA(ibnd).datatype,'T')

            ibnd_bct = ibnd_bct + 1;
            clear times values
            if strcmpi(bnd.DATA(ibnd).bndtype,'C') && strcmpi(bnd.DATA(ibnd).vert_profile,'3d-profile')
                kmax = mdf.mnkmax(3);
            else
                kmax = 1;
            end

            for iside = 1: 2
                if iside == 2 && strcmpi(bnd.DATA(ibnd).bndtype,'T')
                    times(2,:)                  = times(1,:);
                    values(2,1:size(times,2),1) = -999.999;
                else
                    %
                    % Get seriesnr
                    %
                    pntnr = [];
                    for k = 1: kmax
                        for ipnt = 1: length(series.S)
                            if series.S(ipnt).P == bnd.pntnr(ibnd,iside);
                                if kmax == 1
                                    pntnr = ipnt;
                                    break
                                else
                                    if series.S(ipnt).LAYER == k
                                        pntnr = ipnt;
                                    end
                                end
                            end
                        end
                        %
                        % Get the time series data
                        %
                        [times(iside,:),values(iside,:,k)] = simona2mdf_getseries(series.S(pntnr));
                    end
                end
            end
            %
            % Check if times are correct
            %
            if ~isequal(times(1,:),times(2,:))
                simona2mdf_message('Times for timeseries SIDE A and SIDE B must be identical','Window','SIMONA2MDF Warning','Close',true,'n_sec',10);
            end
            %
            % Fill the bct (INFO) structure
            %
            switch lower(bnd.DATA(ibnd).bndtype)
                case{'z'}
                    quant='Water elevation (Z)  ';
                    unit='[m]';
                    profile = 'uniform';
                case{'c'}
                    quant='Current         (C)  ';
                    unit='[m/s]';
                    profile = bnd.DATA(ibnd).vert_profile;
                case{'r'}
                    quant='Riemann         (R)  ';
                    unit='[m/s]';
                    profile = 'uniform';
                 case{'q'}
                    quant='flux/discharge  (Q)  ';
                    unit='[m3/s]';
                    profile = 'uniform';
                 case{'t'}
                    quant='total discharge (T)  ';
                    unit='[m3/s]';
                    profile = 'uniform';
            end

            bct.NTables=ibnd_bct;
            bct.Table(ibnd_bct).Name=['Boundary Section : ' num2str(ibnd)];
            bct.Table(ibnd_bct).Contents=profile;
            bct.Table(ibnd_bct).Location=bnd.DATA(ibnd).name;
            bct.Table(ibnd_bct).TimeFunction='non-equidistant';
            bct.Table(ibnd_bct).ReferenceTime=str2num(datestr(datenum(mdf.itdate,'yyyy-mm-dd'),'yyyymmdd'));
            bct.Table(ibnd_bct).TimeUnit='minutes';
            bct.Table(ibnd_bct).Interpolation='linear';
            bct.Table(ibnd_bct).Parameter(1).Name='time';
            bct.Table(ibnd_bct).Parameter(1).Unit='[min]';

            switch lower(profile)
                case{'uniform' 'logarithmic'}
                    bct.Table(ibnd_bct).Parameter(2).Name=[quant 'End A'];
                    bct.Table(ibnd_bct).Parameter(2).Unit=unit;
                    bct.Table(ibnd_bct).Parameter(3).Name=[quant 'End B'];
                    bct.Table(ibnd_bct).Parameter(3).Unit=unit;
                otherwise
                   j=1;
                   for kk=1:kmax
                       j=j+1;
                       bct.Table(ibnd_bct).Parameter(j).Name=[quant 'End A layer: ' num2str(kk)];
                       bct.Table(ibnd_bct).Parameter(j).Unit=unit;
                   end
                   for kk=1:kmax
                       j=j+1;
                       bct.Table(ibnd_bct).Parameter(j).Name=[quant 'End B layer: ' num2str(kk)];
                       bct.Table(ibnd_bct).Parameter(j).Unit=unit;
                   end
            end

            %
            % Fill bnd structure with time series
            %

            bct.Table(ibnd_bct).Data(:,1) = times(1,:);
            for k = 1: kmax
                bct.Table(ibnd_bct).Data(:,k+1     ) = values(1,:,k);
                bct.Table(ibnd_bct).Data(:,k+kmax+1) = values(2,:,k);
            end
        end
    end
end
