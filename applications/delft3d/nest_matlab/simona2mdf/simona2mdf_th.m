function mdf = simona2mdf_th (S,bnd,mdf, varargin)

% simona2mdf_th : Get thatcher Harleman time lags and set in the mdf struct

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

mdf.rettis(1:length(bnd.DATA)) = 0.0;
mdf.rettib(1:length(bnd.DATA)) = 0.0;

%
% get information out of struc
%

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'TRANSPORT'});


if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.TRANSPORT.PROBLEM.SALINITY')

    th    = siminp_struc.ParsedTree.TRANSPORT.FORCINGS.BOUNDARIES.RETURNTIME.CRET;

    %
    % cycle over all open boundaries
    %

    for ibnd = 1: length(bnd.DATA)

        %
        % Get seriesnr
        %

        for ipnt = 1: length(th)
             if th(ipnt).P == bnd.pntnr(ibnd,1)
                  pntnr = ipnt;
                  break
             end
        end

        mdf.rettis(ibnd) = th(pntnr).TCRETA;
        mdf.rettib(ibnd) = th(pntnr).TCRETA;

    end
end

