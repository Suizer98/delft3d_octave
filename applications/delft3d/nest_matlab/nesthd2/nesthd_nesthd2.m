
function nesthd_nesthd2 (varargin)

%% nesthd2 : nesting of hydrodynamic models (stage 2)
%  Matlab version of nesthd2 (beta release; based on the original fortran code)
%  Theo van der Kaaij, March 2011
%
%% Warning!!!!
Gen_inf    =      {'Nesthd Version 2.1:'                                                     ;
                  ' '                                                                       ;
                  'Severe changes have been made to the internal data structure'            ;
                  'Purpose was to limit memory usage (request from Firmijn)'                ;
                  ' '                                                                       ;
                  'Instead ot treating all support points simultaneously, '                 ;
                  'they are now treated one at the time'                                    ;
                  ' '                                                                       ;
                  'Also added is the genartion of boundary conditions from a D-Hydro'       ;
                  'z-sigma or z-model'                                                      ;
                  ' '                                                                       ;
                  'The adjustments/extensions were tested extensively,'                     ;  
                  'however I cannot guarantee that I overlooked something'                  ;
                  ' '                                                                       ;
                  'If you encounter problems, please do not hesitate to contact me'         ;
                  'Theo.vanderkaaij@deltares.nl'                                           };
    
simona2mdf_message(Gen_inf,'n_sec',10,'Window','NESTHD Message','Close',true);

%% Initialisation
files   = varargin{1};
if nargin >= 2
    add_inf             = varargin{2};
    %% Temporary, set path to mdf file with NSC layer distribution
    if exist('nsc_thick.mdf','file')
        add_inf.interpolate_z = 'nsc_thick.mdf';
    end
else
    add_inf = nesthd_additional( );
end
if isfield(add_inf,'do_hydro')==0
    add_inf.do_hydro=true;
end

if nargin >= 3
    OPT = varargin{3};
end

%% Administration file
fid_adm     = fopen(files{2},'r');      %

%% Read the boundary definition (use points structure!)
bnd         = nesthd_get_bnd_data (files{1},'Points',true);
if isempty(bnd) return; end

%% Get general information from history file
gen_inf      = nesthd_geninf(files{3});
gen_inf.to   = EHY_getModelType(files{4});
gen_inf.from = EHY_getModelType(files{3});

%% Reduce time frame for generation of boundaary conditions
if ~isfield(add_inf,'t_start'); add_inf.t_start = gen_inf.times(1);   end
if ~isfield(add_inf,'t_stop');  add_inf.t_stop  = gen_inf.times(end); end
if ~isnan(add_inf.t_start)
    index          = find(gen_inf.times >= add_inf.t_start & gen_inf.times <= add_inf.t_stop);
    gen_inf.times  = gen_inf.times(index);
    gen_inf.notims = length(gen_inf.times);
end
if exist('OPT','var') && ~isempty(OPT.no_times) gen_inf.notims = min(gen_inf.notims,OPT.no_times); end

%  For dfm add A0 through the keyworoff-set in stead of directly
%  including it into the boundary (request Jelmer)
if strcmp(gen_inf.to,'dfm') && isfield(add_inf,'a0')
    add_inf.a0_dfm = add_inf.a0;
    add_inf.a0     = 0.;
end

%% General settings
nobnd       = length(bnd.DATA);
kmax        = gen_inf.kmax;
lstci       = gen_inf.lstci;
notims      = gen_inf.notims;

%% HYDRODYNAMIC BC
if add_inf.do_hydro
    %% Display how far we are
    if isfield(add_inf,'display')==0 add_inf.display=1; end
    if add_inf.display==1            h = waitbar(0,'Generating Hydrodynamic boundary conditions','Color',[0.831 0.816 0.784]); end
    
    %% Generate hydrodynamic boundary conditions
    for ibnd = 1: nobnd
        [bndval,error]      = nesthd_dethyd(fid_adm,bnd,gen_inf,add_inf,files{3},'ipnt',ibnd);
        if error return; end
        
        %% Generate depth averaged bc from 3D simulation (not sure if this still works!)
        [bndval,gen_inf] = nesthd_detbc2dh(bndval,bnd,gen_inf,add_inf);
        
        %% Interpolate to fixed heights
        [bndval] = nesthd_interpolate_z_dfm(bndval,gen_inf,add_inf,files{3},'bndType',bnd.DATA(ibnd).bndtype);
        
        %% Write the hydrodynamic boundary conditions to file
        nesthd_wrihyd (files{4},bnd,gen_inf,bndval, add_inf,'ipnt',ibnd);
        
        clear bndval
    end
    if add_inf.display==1 close(h); end
end

%% Generate transport bc if available on history file
if lstci > 0

    %% Needed?
    if sum(add_inf.genconc) > 0

        %% Display how far we are
        if isfield(add_inf,'display')==0 add_inf.display=1                                                                    ; end
        if add_inf.display==1            h = waitbar(0,'Generating transport boundary conditions','Color',[0.831 0.816 0.784]); end
        
        %% Determine (nested) concentrations
        for ibnd = 1: nobnd
            bndval      = nesthd_detcon(fid_adm,bnd,gen_inf,add_inf,files{3},'ipnt',ibnd);
            
            %% Generate depth averaged bc from 3D simulation
            [bndval,gen_inf] = nesthd_detbc2dh(bndval,bnd,gen_inf,add_inf);
            
            %% Interpolate to fixed heights
            [bndval] = nesthd_interpolate_z_dfm(bndval,gen_inf,add_inf,files{3});
            
            %% Write concentrations to file
            nesthd_wricon(files{5},bnd,gen_inf,bndval,add_inf,'ipnt',ibnd);
        end
        
        if add_inf.display==1 close(h); end
    end
end

fclose (fid_adm);