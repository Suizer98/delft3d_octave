function [G,D,ndomains] = readparallel(varargin)
%readparallel parallel version of readNet/readMap
%
%  [G,D,ndomains] = dflowfm.readNetparallel(ncfile, ...)
%  read network and flow data from parallel D-Flow FM MAP files into NET and MAP structures G and D respectively
%
%  ncfile:               filename of a subdomain, e.g.
%                          ncfile = 'FM_output_test_0004/test_0004_map.nc'
%  additional arguments: see dflowfm.readMap
%
%  G:                    structure with grid data
%  D:                    structure with map  data
%  ndomains:             number of subdomains read (based on file existence)
%
%See also: plotparallel, dflowfm.readMap, dflowfm.plotMap

    if nargin<1
        return
    end

    FNAM = varargin{1};
    
    base = get_names(FNAM);
    
    Lcontinue = true;
    idmn=0;
    while Lcontinue
        sdmn = sprintf('_%.4i', idmn');
        FNAM = fullfile(base.dir, [base.name, sdmn, base.type, base.ext]);
        
        Lcontinue = false;
        if exist(FNAM,'file')
            Lcontinue = true;
            fprintf('Reading %s...', FNAM)
            G{idmn+1} = dflowfm.readNet(FNAM);
            D{idmn+1} = dflowfm.readMap(FNAM, varargin{2:end});
            fprintf(' done.\n')
            idmn = idmn+1;
        else
            Lcontinue = false;
            ndomains = idmn;
        end
    end
%       
end

function base = get_names(FNAM)
% get base directory, name and extension of file from partioned net- or map
% file of the form
%   basedir/basename_NNNN_map.nc or
%   basedir_NNNN/basename_NNNN_map.nc
%
% FNAM = fullfile(base.dir, [base.name, sdmn, base.type, base.ext]), if base.Ladd_sdmn_to_dir
%        fullfile([base.dir, smdn], [base.name, smdn, base.type, base.ext]), otherswise
    
%   find subdomain number
    idx = regexp(FNAM,'_\d\d\d\d');
    if ( isempty(idx) )
        error('Could not determine subdomain number.')
    end
%   consider last domain number in filename only
    idx  = idx(end);
    idmn = str2num(FNAM(idx+1:idx+4));
    sdmn = sprintf('_%.4i', idmn)
    
    [base.dir, name, base.ext] = fileparts(FNAM);
    
%   find file type
    dum=regexp(FNAM,'_\d{4}_(?<FTYP>\w*)\>', 'names');
    base.type=['_', dum.FTYP];

%   base directory, see if we need to add the subdomain number
    base.Ladd_sdmn_to_dir = strcmp(base.dir(max(end-4,1):end),sdmn);
    if base.Ladd_sdmn_to_dir
        base.dir = base.dir(1:end-length(sdmn));
    end

%   base filename
    idx = strfind(name,base.type);
    if isempty(idx)
        error('illegal filename')
    end
    idx = idx(end);    % safety
    idx = strfind(name(1:max(idx-1,1)), sdmn);
    base.name=name(1:idx-1);
end