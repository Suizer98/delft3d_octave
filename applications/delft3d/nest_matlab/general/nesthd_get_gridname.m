function fileOut = get_gridname(fileInp)

% get_gridname: gets the gridname either direct, from siminp file or mdf file

filegrd = fileInp;

[pin,~,~]    = fileparts(fileInp);
pin          = [pin filesep];

[~,fileType] = EHY_getTypeOfModelFile (fileInp);

switch fileType
    case 'mdf'
        mdf     = ddb_readMDFText(fileInp);
        fileOut = [pin mdf.filcco];
    case 'mdu'
        mdu     = dflowfm_io_mdu('read',fileInp);
        fileOut = [pin mdu.geometry.NetFile];
    case {'grd' 'net_nc' 'map_nc' 'grid'}
        fileOut = fileInp;
    case 'siminp'

        %
        % Read the siminp file
        [P,N,E] = fileparts(fileInp);
        fileInp = [N E];
        exclude  = {true;true};
        S = readsiminp(P,fileInp,exclude);
        S = all_in_one(S);

        %
        % Parse Mesh/grid part
        nesthd_dir   = getenv_np('nesthd_path');
        siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'GRID'});
        fileOut = siminp_struc.ParsedTree.MESH.GRID.CURVILINEAR.RGFFILE;
        fileOut = [pin filegrd];
    otherwise
        fileOut = '';
end

