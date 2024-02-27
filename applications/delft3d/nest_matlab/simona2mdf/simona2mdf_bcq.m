function bcq = simona2mdf_bcq(S,bnd, varargin)

% simona2mdf_bcq : gets qh forcing out of the siminp

bcq      = [];
ibnd_bcq = 0;

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

%
% Not implemented yet
%

for ibnd = 1: length(bnd.DATA)
    if strcmpi(bnd.DATA(ibnd).datatype,'q')
        ibnd_bcq = ibnd_bcq + 1;
    end
end

%
% Displays warning message
%

if ibnd_bcq > 0
    simona2mdf_message('Conversion of QH boundaries not implemented yet','Window','SIMONA2MDF Warning','Close',true,'n_sec',10);
end
