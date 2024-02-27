function bch = simona2bnd_bch(S,bnd, varargin)

% simona2mdf_bch : gets harmonic (fourier) data out of the siminp

bch      = [];
ibnd_bch = 0;

%
% Harmonic forcing data
%

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

%
% get information out of struc
%

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'FORCINGS' 'FOURIER'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.FORCINGS.FOURIER')

    fourier      = siminp_struc.ParsedTree.FLOW.FORCINGS.FOURIER;

    %
    % set frequencies (also convert from simona to D3D unit)
    %

    bch.frequencies = fourier.GENERAL.OMEGA*1e-4*3600*180/pi;

    %
    % cycle over all open boundaries
    %

    for ibnd = 1: length(bnd.DATA)

        %
        % Cycle over harmonic boundarieseand get harmonic data out of the siminp
        %

        if strcmpi(bnd.DATA(ibnd).datatype,'H');

            ibnd_bch = ibnd_bch + 1;

            for iside = 1: 2
                pntnr = bnd.pntnr(ibnd,iside);

                %
                % Find correct point
                %

                for ipnt = 1: length(fourier.SERIES.S)
                    if fourier.SERIES.S(ipnt).P == pntnr
                        %
                        % Fill the bct structure
                        %
                        bch.a0         (iside,ibnd_bch)   = fourier.SERIES.S(ipnt).AZERO;
                        bch.amplitudes (iside,ibnd_bch,:) = fourier.SERIES.S(ipnt).AMPL;
                        bch.phases     (iside,ibnd_bch,:) = fourier.SERIES.S(ipnt).PHASE*180/pi;
                    end
                end
             end
        end
    end
end
