function d3d2dflowfm (varargin)

%d3d2dflowfm : converts mdf file into an Unstruc input file ("*.mdu")

Gen_inf    = {'This tool converts a Delft3D-Flow mdf file into an D-Dlow FM mdu file'                              ;
              'with belonging attribute files'                                                                     ;
              ' '                                                                                                  ;
              'Credits go to Wim van Baalen for his conversion of boundary conditions'                             ;
              ' '                                                                                                  ;
              'This tool does a basic first conversion'                                                            ;
              'Not everything is converted:'                                                                       ;
              '- Tracer  information is not converted yet'                                                         ;
              '- 3D is supported as far as DFLOWFM allows (depth-averaged ic and bc)'                              ;
              ' '                                                                                                  ;
              'PLEASE CHECK CAREFULLY( USE AT OWN RISK)'                                                           ;                                                                                        ' '
              ' '                                                                                                  ;
              'If you encounter problems, please do not hesitate to contact me'                                    ;                                                    ;
              'Theo.vanderkaaij@deltares.nl'                                                                      };

%% set path if necessary

if ~isdeployed || ~any(which('setproperty'))
   oetsettings('quiet');
end

%% Check if the general information needs to be displayed
OPT.DispGen = true;
OPT = setproperty(OPT,varargin{3:end});

%% Check if nesthd_path is set
if isempty (getenv_np('nesthd_path'))
   h = warndlg({'Please set the environment variable "nesthd_path"';'See the Release Notes ("Release Notes.chm")'},'NestHD Warning');
   PutInCentre (h);
   uiwait(h);
end

%% Dynamically get filenames (or specify in script), split into name and path

% Call the function either like:

% d3d2dflowfm (a GUI will pop-up)
% d3d2dflowfm('find') (will find a single *.mdf file in the current folder)
% d3d2dflowfm('D:\some_d3d_folder\some_mdf.mdf','D:\some_d3d_fm_folder\some_mdu.mdu') (will convert the provided files)

% Edit Freek Scheel 2016: Make this a bit more dynamic when no arguments are given:
if isempty(varargin)
    [name_mdf, path_mdf] = uigetfile({'*.mdf','Delft3D master definition files (*.mdf)'},'Pick a *.mdf file to convert...','MultiSelect','off');

    if ~ischar(name_mdf)
        error('User abort: No input *.mdf file selected');
    else
        fil_mdf   = [path_mdf name_mdf];
        path_mdu  = uigetdir(path_mdf,'Select an output folder to store the converted Delft3D-FM model to...');
        fil_mdu   = [path_mdu filesep strrep(name_mdf,'.mdf','.mdu')];
    end
else
    if length(varargin) == 1 && ischar(varargin{1}) && ~isempty([strfind(varargin{1},'gen') strfind(varargin{1},'find')])
        mdf_files = dir(['*.mdf']);
        if size(mdf_files,1) == 1
            name_mdf = mdf_files.name;
            path_mdf = pwd;
            fil_mdf  = [path_mdf filesep name_mdf];
        elseif size(mdf_files,1) == 0
            error('No *.mdf file found in the current Matlab working directory..');
        else
            error('Multiple *.mdf files were found in the current Matlab working directory, if you wish to select one manually, simply call the function without any input variables: >> d3d2dflowfm');
        end
    end

    if length(varargin) > 1
        fil_mdf = varargin{1};
        fil_mdu = varargin{2};

        if ~exist(fil_mdf,'file')
            error(['The provided *.mdf file ' fil_mdf ' does not exist']);
        end
    else
        disp(['Unknown input:']);
        disp(' ');
        disp(varargin{1});
        error('Script terminated on unknown input');
    end
end

[path_mdu,name_mdu,~] = fileparts([fil_mdu]);
if isempty(path_mdu) path_mdu = '.'; end
if ~isempty(path_mdu)
    fil_mdu               = [path_mdu filesep name_mdu];
else
    fil_mdu               = name_mdu;
end

if ~exist(fil_mdf,'file'); error(['The input *.mdf file ' filmdf ' does not exist']); end;
if ~exist(path_mdu,'dir'); mkdir(path_mdu); end;

%% Display the general information
if OPT.DispGen
   simona2mdf_message(Gen_inf,'n_sec',5,'Window','D3D2DFLOWFM Message','Close',true);
end

%% Start with creating empty mdu template
[mdu,mdu_Comment] = dflowfm_io_mdu('new',[getenv_np('nesthd_path') filesep 'bin' filesep 'dflowfm-properties.csv']);
mdu.pathmdu = path_mdu;

%% Read the temporary mdf file, add the path of the d3d files to allow for reading later
tmp                         = delft3d_io_mdf('read',fil_mdf);
mdf                         = tmp.keywords;
[path_mdf,name_mdf,ext_mdf] = fileparts(fil_mdf); if isempty(path_mdf); path_mdf = '.'; end
mdf.pathd3d                 = path_mdf;
mdf.named3d                 = [name_mdf ext_mdf];

%% Generate the net file from the area information
simona2mdf_message('Generating the Net file'                           ,'Window','D3D2DFLOWFM Message');
if isfield(mdf,'fildep')
    d3d2dflowfm_grd2net([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.filgrd],[path_mdf filesep mdf.fildep], ...
                        [fil_mdu '_net.nc']         ,[fil_mdu '.xyz']);
else
    d3d2dflowfm_grd2net([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.filgrd],mdf.depuni                   , ...
                        [fil_mdu '_net.nc']         ,[fil_mdu '.xyz']);
end

mdu.geometry.NetFile = [fil_mdu '_net.nc'];
mdu.geometry.NetFile = simona2mdf_rmpath(mdu.geometry.NetFile);

%% Generate unstruc additional files and fill the mdu structure
simona2mdf_message('Generating D-Flow FM Area              information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_area     (mdf,mdu,fil_mdu);

if strcmpi(mdf.dpsopt,'dp') % depth defined in cell centres, make xyb file
    simona2mdf_message('Generating D-Flow FM Bathymetry         information','Window','D3D2DFLOWFM Message');
    mdu = d3d2dflowfm_bathy(mdf,mdu,fil_mdu);
end

simona2mdf_message('Generating D-Flow FM Dry Point         information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_dry      (mdf,mdu,fil_mdu);

simona2mdf_message('Generating D-Flow FM Thin Dam          information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_thd      (mdf,mdu,fil_mdu);

simona2mdf_message('Generating D-Flow FM Weir              information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_weirs    (mdf,mdu,fil_mdu);

simona2mdf_message('Generating D-Flow FM TIMES             information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_times    (mdf,mdu,fil_mdu);

simona2mdf_message('Generating D-Flow FM PHYSICAL          information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_physical (mdf,mdu,fil_mdu);

simona2mdf_message('Generating D-Flow FM NUMERICAL         information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_numerical(mdf,mdu,fil_mdu);

if simona2mdf_fieldandvalue(mdf,'filbnd')
    simona2mdf_message('Generating D-Flow FM Boundary definition          ','Window','D3D2DFLOWFM Message');
    mdu.Filbnd = d3d2dflowfm_bnd2pli([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.filbnd],fil_mdu,...
                                      'enclosure',[path_mdf filesep mdf.filgrd]);
else
    mdu.Filbnd = '';
end

if simona2mdf_fieldandvalue(mdf,'filbc0')
     simona2mdf_message('Generating D-Flow FM bc0      definition          ','Window','D3D2DFLOWFM Message');
     mdu.Filbc0 = d3d2dflowfm_bnd2pli([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.filbnd],fil_mdu,...
                                      'bc0',[path_mdf filesep mdf.filbc0]);
else
    mdu.Filbc0 = '';
end

if mdu.physics.Salinity && simona2mdf_fieldandvalue(mdf,'filbnd')        % Salinity, write _sal pli files
    tmp = d3d2dflowfm_bnd2pli([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.filbnd],fil_mdu,'Salinity',true);
    mdu.Filbnd = [mdu.Filbnd tmp];
end

if mdu.physics.Temperature > 0 && simona2mdf_fieldandvalue(mdf,'filbnd') % Temperature,
    tmp = d3d2dflowfm_bnd2pli([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.filbnd],fil_mdu,'Temperature',true);
    mdu.Filbnd = [mdu.Filbnd tmp];
end

simona2mdf_message('Generating D-Flow FM Sources                      ','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_src       (mdf,mdu,fil_mdu);

simona2mdf_message('Generating D-Flow FM Initial Condition information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_initial  (mdf,mdu,fil_mdu);

simona2mdf_message('Generating D-Flow FM Friction          information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_friction (mdf,mdu,fil_mdu);

simona2mdf_message('Generating D-Flow FM Viscosity/diff.   information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_viscosity(mdf,mdu,fil_mdu);

simona2mdf_message('Generating External forcing file                  ','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_genext   (mdu,fil_mdu,'Filbnd'     ,mdu.Filbnd    ,'Comments',true);
mdu = d3d2dflowfm_genext   (mdu,fil_mdu,'Filbc0'     ,mdu.Filbc0    );
mdu = d3d2dflowfm_genext   (mdu,fil_mdu,'Filsrc'     ,mdu.Filsrc    );
mdu = d3d2dflowfm_genext   (mdu,fil_mdu,'Filini_wl'  ,mdu.Filini_wl );
mdu = d3d2dflowfm_genext   (mdu,fil_mdu,'Filini_sal' ,mdu.Filini_sal);
mdu = d3d2dflowfm_genext   (mdu,fil_mdu,'Filini_tem' ,mdu.Filini_tem);
mdu = d3d2dflowfm_genext   (mdu,fil_mdu,'Filrgh'     ,mdu.Filrgh    );
mdu = d3d2dflowfm_genext   (mdu,fil_mdu,'Filvico'    ,mdu.Filvico   );
mdu = d3d2dflowfm_genext   (mdu,fil_mdu,'Fildico'    ,mdu.Fildico   );
mdu = d3d2dflowfm_genext   (mdu,fil_mdu,'Filwnd'     ,mdu.Filwnd    );
mdu = d3d2dflowfm_genext   (mdu,fil_mdu,'Filtem'     ,mdu.Filtem    );
mdu = d3d2dflowfm_genext   (mdu,fil_mdu,'Fileva'     ,mdu.Fileva    );
mdu = d3d2dflowfm_genext   (mdu,fil_mdu,'Filwsvp'    ,mdu.Filwsvp   );

simona2mdf_message('Generating D-Flow FM boundary conditions          ','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_bndforcing(mdf,mdu,fil_mdu);

simona2mdf_message('Generating D-Flow FM Wind Forcing                 ','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_wndforcing(mdf,mdu,fil_mdu);

simona2mdf_message('Generating D-Flow FM Temperature Forcing          ','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_temperatureforcing(mdf,mdu,fil_mdu);

simona2mdf_message('Generating D-Flow FM Rain and Evaporation         ','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_evap              (mdf,mdu,fil_mdu);

simona2mdf_message('Generating D-Flow FM STATION           information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_obs      (mdf,mdu,fil_mdu);

simona2mdf_message('Generating D-Flow FM CROSS-SECTION     information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_crs      (mdf,mdu,fil_mdu);

simona2mdf_message('Generating D-Flow FM OUTPUT            information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_output   (mdf,mdu,fil_mdu);

%% Finally,  write the mdu file and close everything
simona2mdf_message('Writing    D-Flow FM *.mdu file                   ','Window','D3D2DFLOWFM Message','Close',true,'n_sec',1);
mdu = d3d2dflowfm_cleanup(mdu);
dflowfm_io_mdu('write',[fil_mdu '.mdu'],mdu,mdu_Comment);
