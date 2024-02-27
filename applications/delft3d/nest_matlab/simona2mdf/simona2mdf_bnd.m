function mdf = simona2mdf_bnd(S,mdf,name_mdf,varargin);

% simona2mdf_bnd : gets all boundary related information out of the parsed siminp (S)

% Start with the boundary definition!

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

bnd = simona2mdf_bnddef(S, 'nesthd_path', OPT.nesthd_path);

% If open boundaries exist, write boundary definition and retrieve
% harmonic data, time series data and astronomical data respectively

if ~isempty(bnd)
    mdf.filbnd = [name_mdf '.bnd'];
    delft3d_io_bnd('write',mdf.filbnd,bnd);
    mdf.filbnd = simona2mdf_rmpath(mdf.filbnd);
    
    %
    % Harmonic boundary conditions
    %

    bch = simona2mdf_bch(S,bnd, 'nesthd_path', OPT.nesthd_path);
    if ~isempty(bch)
        mdf.filbch = [name_mdf '.bch'];
        delft3d_io_bch('write',mdf.filbch,bch);
        mdf.filbch = simona2mdf_rmpath(mdf.filbch);
    end

    %
    % Time series boundary conditions
    %

    bct = simona2mdf_bct(S,bnd,mdf, 'nesthd_path', OPT.nesthd_path);
    if ~isempty(bct)
        mdf.filbct = [name_mdf '.bct'];
        ddb_bct_io('write',mdf.filbct,bct);
        mdf.filbct = simona2mdf_rmpath(mdf.filbct);
    end

    %
    % Q-h relation (not implemented yet)
    %

    bcq = simona2mdf_bcq(S,bnd, 'nesthd_path', OPT.nesthd_path);
    if ~isempty(bcq)
        mdf.filbcq = [name_mdf '.bcq'];
        ddb_bct_io('write',mdf.filbcq,bcq);
        mdf.filbcq = simona2mdf_rmpath(mdf.filbcq);
    end

    %
    % Astronomical Boundary conditions
    %

    bca = simona2mdf_bca(S,bnd, 'nesthd_path', OPT.nesthd_path);
    if ~isempty(bca)
        mdf.filana = [name_mdf '.bca'];
        delft3d_io_bca('write',mdf.filana,bca);
        mdf.filana = simona2mdf_rmpath(mdf.filana);
    end
    
    %
    % Transport boundary conditions (Salinity only for now)
    %

    bcc = simona2mdf_bcc(S,bnd,mdf, 'nesthd_path', OPT.nesthd_path);
    if ~isempty(bcc)
        mdf.filbcc = [name_mdf '.bcc'];
        ddb_bct_io('write',mdf.filbcc,bcc);
        mdf.filbcc = simona2mdf_rmpath(mdf.filbcc);
    end
        
    %
    % Thatcher Harleman times
    %

    mdf = simona2mdf_th(S,bnd,mdf, 'nesthd_path', OPT.nesthd_path);

end



