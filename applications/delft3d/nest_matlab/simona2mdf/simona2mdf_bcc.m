function bcc = simona2bnd_bcc(S,bnd,mdf, varargin)

% simona2mdf_bcc : gets time-series transport forcing (for now only salinity)

bcc      = [];
ibnd_bcc = 0;

%
% Time series forcing data (salinity only)
%

OPT.nesthd_path = getenv_np('nesthd_path');
OPT             = setproperty(OPT,varargin{1:end});

%
% get information out of struc
%

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'TRANSPORT' 'PROBLEM' 'SALINITY'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.TRANSPORT.PROBLEM.SALINITY')

    constnr = siminp_struc.ParsedTree.TRANSPORT.PROBLEM.SALINITY.CO;

    siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'TRANSPORT' 'FORCINGS' 'BOUNDARIES' 'TIMESERIES'});
    series       = siminp_struc.ParsedTree.TRANSPORT.FORCINGS.BOUNDARIES.TIMESERIES.TS;

    %
    % cycle over all open boundaries
    %

    for ibnd = 1: length(bnd.DATA)
        clear times values

        %
        % For all boundaries
        %

        ibnd_bcc = ibnd_bcc + 1;

        for iside = 1: 2
            %
            % Get seriesnr
            %
            pntnr = [];
            for ipnt = 1: length(series)
                if series(ipnt).P == bnd.pntnr(ibnd,iside)
                    pntnr = [pntnr ipnt];
                end
            end

            profile{ibnd_bcc} = 'Uniform';
            kmax              = length(pntnr);
            if kmax > 1 profile{ibnd_bcc} = '3d-profile';end

            %
            % Get the time series data
            %

            for ipnt = 1: kmax
                if kmax == 1; k = 1                 ; end
                if kmax >  1; k = series(ipnt).LAYER; end
                if simona2mdf_fieldandvalue(series(ipnt),'SERIES')
                    [times(iside,:),values(iside,:,k)] = simona2mdf_getseries(series(pntnr(ipnt)));
                else
                    times(iside,1)    = mdf.tstart;
                    times(iside,2)    = mdf.tstop;
                    values(iside,1,k) = series(pntnr).CINIT;
                    values(iside,2,k) = series(pntnr).CINIT;
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
        % Fill the bcc (INFO) structure
        %

        quant   ='Salinity             ';
        unit    ='[psu]';

        bcc.NTables=ibnd_bcc;
        bcc.Table(ibnd_bcc).Name=['Boundary Section : ' num2str(ibnd)];
        bcc.Table(ibnd_bcc).Contents=profile{ibnd_bcc};
        bcc.Table(ibnd_bcc).Location=bnd.DATA(ibnd).name;
        bcc.Table(ibnd_bcc).TimeFunction='non-equidistant';
        bcc.Table(ibnd_bcc).ReferenceTime=str2num(datestr(datenum(mdf.itdate,'yyyy-mm-dd'),'yyyymmdd'));
        bcc.Table(ibnd_bcc).TimeUnit='minutes';
        bcc.Table(ibnd_bcc).Interpolation='linear';
        bcc.Table(ibnd_bcc).Parameter(1).Name='time';
        bcc.Table(ibnd_bcc).Parameter(1).Unit='[min]';

        if kmax == 1
            bcc.Table(ibnd_bcc).Parameter(2).Name=[quant 'End A'];
            bcc.Table(ibnd_bcc).Parameter(2).Unit=unit;
            bcc.Table(ibnd_bcc).Parameter(3).Name=[quant 'End B'];
            bcc.Table(ibnd_bcc).Parameter(3).Unit=unit;
        else
            j = 1;
            for k=1:kmax
                j=j+1;
                bcc.Table(ibnd_bcc).Parameter(j).Name=[quant 'End A layer: ' num2str(k)];
                bcc.Table(ibnd_bcc).Parameter(j).Unit=unit;
            end
            for k=1:kmax
                j=j+1;
                bcc.Table(ibnd_bcc).Parameter(j).Name=[quant 'End B layer: ' num2str(k)];
                bcc.Table(ibnd_bcc).Parameter(j).Unit=unit;
            end
        end


        %
        % Fill bnd structure with time series
        %

        bcc.Table(ibnd_bcc).Data(:,1) = times(1,:);
        for k = 1: kmax
            bcc.Table(ibnd_bcc).Data(:,       k + 1) = values(1,:,k);
            bcc.Table(ibnd_bcc).Data(:,kmax + k + 1) = values(2,:,k);
        end
    end
end

