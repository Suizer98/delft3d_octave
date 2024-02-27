function nfs_inf = get_general(fileInp)

% get_general: retrieves general information from trih or SDS file

modelType = EHY_getModelType(fileInp);

switch modelType

    case ('d3d')
        nfs_inf     = nesthd_ini_nfs        (fileInp);
    case ('simona')
        nfs_inf     = nesthd_ini_sds        (fileInp);
    case ('dfm')
        nfs_inf     = nesthd_ini_dflowfm    (fileInp);
    case ('mdf')
        nfs_inf     = nesthd_ini_mdf        (fileInp);  
end
