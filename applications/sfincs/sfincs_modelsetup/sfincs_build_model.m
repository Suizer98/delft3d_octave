function sfincs_build_model(inp,folder,bathy,cs,varargin)

if ~exist(folder,'dir')
    mkdir(folder);
end

% Defaults
zmin                = -2;
zmax                = 10;
manning_input(1)    = 0.024;       %  manning_deep      -> sea
manning_input(2)    = 0.040;       %  manning_shallow   -> on land
manning_input(3)    = 0.00;        %  manning_level     -> cut-off level

% Sub grid
nbin                = 5;               % Number of bins in subgrid table
subgrid_dx          = 10;              % Subgrid refinement factor w.r.t. SFINCS grid in n direction
subgrid_uopt        = 'min';
maxdzdv             = 5;
usemex              = 1;

% Other things
grid_out            = 0;
xy_in               = [];
xy_ex               = [];
xy_bnd_closed       = [];
xy_bnd_open         = [];

%% Read input arguments
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'subgrid_nbin'}
                nbin=varargin{ii+1};
            case{'subgrid_dx'}
                subgrid_dx=varargin{ii+1};
            case{'subgrid_maxdzdv'}
                maxdzdv=varargin{ii+1};
            case{'zmin'}
                zmin=varargin{ii+1};                
            case{'zmax'}
                zmax=varargin{ii+1};     
            case{'export_grid'}
                grid_out=varargin{ii+1};   
            case{'includepolygon'}
                if ~isempty(varargin{ii+1})
                    try
                        xy_in=load_polygon(varargin{ii+1});
                    catch
                        xy_in=load_polygon_ascii(varargin{ii+1});                        
                    end
                end
            case{'excludepolygon'}
                if ~isempty(varargin{ii+1})
                    try
                        xy_ex=load_polygon(varargin{ii+1});
                    catch
                        xy_ex=load_polygon_ascii(varargin{ii+1});                        
                    end                    
                end
            case{'closedboundarypolygon'}
                if ~isempty(varargin{ii+1})
                    try
                        xy_bnd_closed=load_polygon(varargin{ii+1});
                    catch
                        xy_bnd_closed=load_polygon_ascii(varargin{ii+1});
                    end                    
                     
                end
            case{'openboundarypolygon'}
                if ~isempty(varargin{ii+1})
                    xy_bnd_open=load_polygon(varargin{ii+1});
                end
            case{'manning_input'}
                if ~isempty(varargin{ii+1})
                    manning_input=varargin{ii+1};
                end
        end
    end
end

% Create grid
disp('Making grid ...');
[xg,yg,xz,yz]=sfincs_make_grid(inp.x0,inp.y0,inp.dx,inp.dy,inp.mmax,inp.nmax,inp.rotation);

% Create bathymetry
disp('Making bathymetry ...');
zz=interpolate_bathymetry_to_grid(xz,yz,[],bathy,cs,'quiet');
if any(isnan(zz(:)))
    disp('bathy contains NaNs, watch out!')
    disp('bathy contains NaNs, zb will be set to -10')
    zz(isnan(zz)) = -10;    
end
close all
A4fig; axis equal; pcolor(xz,yz,zz); shading flat; colorbar; caxis([-2 10]); xlim([minmin(xz),maxmax(xz)]);ylim([minmin(yz),maxmax(yz)]);
print([folder,'\sfincs_depth.png'],'-dpng','-r200')

% Export grid and bathy in Delft3D format
% can be usefull for inspection and defining polygons for next step
if grid_out == 1
    wlgrid('write', 'FileName', [folder, 'sfincs.grd'], 'X', xz, 'Y', yz)
    zz_tmp                  = zz;
    zz_tmp                  = [zz_tmp  ones(1,size(zz_tmp,1))'*-999];
    zz_tmp                  = [zz_tmp; ones(size(zz_tmp,2),1)'*-999];
    wldep('write', [folder, 'sfincs.dep'], '', zz_tmp);
end

% Create mask
disp('Making mask ...');
msk=sfincs_make_mask(xz,yz,zz,[zmin zmax],'includepolygon',xy_in,'excludepolygon',xy_ex,'closedboundarypolygon',xy_bnd_closed,'openboundarypolygon',xy_bnd_open);
A4fig; axis equal; pcolor(xz,yz,msk); shading flat; colorbar;xlim([minmin(xz),maxmax(xz)]);ylim([minmin(yz),maxmax(yz)]);
idmsk = find(msk==2); plot(xz(idmsk), yz(idmsk), 'r*'); 
idmsk = find(msk==3); plot(xz(idmsk), yz(idmsk), 'bo'); 
legend('msk', 'msk=2 (inflow)', 'msk=3 (outflow)');
print([folder,'\sfincs_msk.png'],'-dpng','-r200')

% Write grid files
disp('Writing files ...');
sfincs_write_binary_inputs(zz,msk,[folder inp.indexfile],[folder inp.depfile],[folder inp.mskfile]);

% Write input file (this needs to be done before writing the subgrid file)
sfincs_write_input([folder 'sfincs.inp'],inp);

% Create subgrid file
if ~isempty(inp.sbgfile)
    disp('Making subgrid file ...');
    refi=ceil(inp.dx/subgrid_dx);
    refj=ceil(inp.dy/subgrid_dx); %dx and dy could be varying
    
    if inp.dx~=inp.dy
       disp('WARNING: subgrid generation - dx is not equal to dy, this might cause problems') 
    end
    
    if rem(inp.dx,1) > 0
       disp('WARNING: subgrid generation: dx is not a whole number, this might cause problems') 
    end
    
    if rem(inp.dy,1) > 0
       disp('WARNING: subgrid generation: dy is not a whole number, this might cause problems') 
    end    
    
    % Make subgrid
    sfincs_make_subgrid_file(folder,inp.sbgfile,bathy,manning_input,cs,nbin,refi,refj,subgrid_uopt,maxdzdv,usemex)
end

disp('Done.');

%%
function p=load_polygon(fname)
data=tekal('read',fname,'loaddata');
np=length(data.Field);
for ip=1:np
    x=data.Field(ip).Data(:,1);
    y=data.Field(ip).Data(:,2);
    if x(end)~=x(1) || y(end)~=y(1)
        x=[x;x(1)];
        y=[y;y(1)];
    end
    p(ip).x=x;
    p(ip).y=y;
end
%%
function p=load_polygon_ascii(fname) %just load 1 polygon from ascii file
data=load(fname);
x = data(:,1);
y = data(:,2);
if x(end)~=x(1) || y(end)~=y(1)
    x=[x;x(1)];
    y=[y;y(1)];
end

p.x=x;
p.y=y;
