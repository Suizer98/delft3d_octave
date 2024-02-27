function filebnd = get_bndname(fileInp)

% get_bndname : Get the name of teh file with boundary information (direct, from mdf or from siminp file

[pin,~,~]      = fileparts(fileInp);
[ ~ ,fileType] =  EHY_getTypeOfModelFile(fileInp);

switch fileType
    case 'mdf'
        mdf = ddb_readMDFText(filename);
        filebnd = [pin filesep mdf.filbnd];
    case 'bnd'
        filebnd = fileInp;
    case 'mdu'
         mdu = dflowfm_io_mdu('read',filename);
         filebnd = [pin filesep mdu.external_forcing.ExtForceFile];
    case 'pli'
         filebnd = fileInp;
    case 'siminp'
         filebnd = fileInp;
    case 'ext'
         filebnd = fileInp;
    otherwise
      filebnd = '';
end

