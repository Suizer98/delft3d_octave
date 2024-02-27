function bca = simona2bnd_bca(S,bnd, varargin)

% simona2mdf_bca : gets astronomical data out of the siminp

bca      = [];
ibnd_bca = 0;

%
% Astronomical forcing data
%

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

%
% get information out of struc
%

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'FORCINGS' 'HARMONIC'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.FORCINGS.HARMONIC')
    harmonic     = siminp_struc.ParsedTree.FLOW.FORCINGS.HARMONIC;
    const        = harmonic.GENERAL.OMEGA;

    %
    % cycle over all open boundaries and get only the astronmoical boundaries
    %

    for ibnd = 1: length(bnd.DATA)

        %
        % Type of boundary out of the bndstruc, for astronomical data continue
        %

        if strcmpi(bnd.DATA(ibnd).datatype,'A');

            ibnd_bca = ibnd_bca + 1;
            bnd_bca.DATA(ibnd_bca)    = bnd.DATA(ibnd);
            bnd_bca.pntnr(ibnd_bca,:) = bnd.pntnr(ibnd,:);
        end
    end

    no_bnd = length(bnd_bca.DATA);
    pntnrs = reshape(bnd_bca.pntnr,no_bnd*2,1);
    pntnrs = unique(pntnrs);

    for ibndpnt = 1: length(pntnrs)
        pntnr = pntnrs(ibndpnt);
        for ipnt = 1: length(harmonic.CONSTANTS.S)
            if harmonic.CONSTANTS.S(ipnt).P == pntnr
                bca.DATA(ibndpnt).names{1} = 'A0';
                for icons = 1: length(const)
                    bca.DATA(ibndpnt).names{icons+1} = const{icons}(2:end-1);
                end
                ampfas = harmonic.CONSTANTS.S(ipnt);
                bca.DATA(ibndpnt).amp(1) = ampfas.AZERO;
                bca.DATA(ibndpnt).phi(1) = -999.999;
                bca.DATA(ibndpnt).amp(2:length(ampfas.AMPL)+1)  = ampfas.AMPL;
                bca.DATA(ibndpnt).phi(2:length(ampfas.PHASE)+1) = ampfas.PHASE*360/(2*pi);
                bca.DATA(ibndpnt).label = ['P' num2str(pntnr,'%4.4i')];
                break
            end
        end
    end
end


