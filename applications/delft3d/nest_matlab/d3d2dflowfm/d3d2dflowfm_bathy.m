function mdu = d3d2dflowfm_bathy(mdf, mdu, name_mdu)

% d3d2dflowfm_bathy : Converts bathymetry to samples (xyb) file (only if dpsopt = dp)

filgrd     = [mdf.pathd3d filesep mdf.filcco];
fildep     = [mdf.pathd3d filesep mdf.fildep];
[~,name,~] = fileparts(fildep);
filsam     = [mdu.pathmdu filesep name '.xyb'];

%% Read the grid
G             = delft3d_io_grd('read',filgrd);
xh            = G.cend.x';
yh            = G.cend.y';
mmax          = size(xh,1);
nmax          = size(xh,2);

%% Read the depth Data
depthdat      = wldep('read',fildep,[mmax nmax]);
zh            = depthdat;
zh(zh==-999)  = NaN;
zh            = -zh;

%% Make file with bathymetry samples
tmp(:,1)      = reshape(xh,mmax*nmax,1);
tmp(:,2)      = reshape(yh,mmax*nmax,1);
tmp(:,3)      = reshape(zh,mmax*nmax,1);
nonan         = ~isnan(tmp(:,3));
tmp           = d3d2dflowfm_addsquare(tmp(nonan,:));
LINE.DATA     = num2cell(tmp);

%% Write to unstruc xyz file
dflowfm_io_xydata('write',filsam,LINE);

%% filename in mdufile
mdu.geometry.BathymetryFile = simona2mdf_rmpath(filsam);
mdu.geometry.BedlevType     =  1;
mdu.geometry.Conveyance2D   = -1;


