function d3d2dflowfm_grd2net(filgrd,filenc,fildep,netfile,samfile)

% d3d2dflowfm_grd2net : Converts d3d-flow grid file to D-Flow FM net file
%                       (Based upon grd2net from Wim van Balen, however UI dependencies removed)

% Read the grid
G             = delft3d_io_grd('read',filgrd,'enclosure',filenc);
xh            = G.cor.x';
yh            = G.cor.y';
mmax          = G.mmax;
nmax          = G.nmax;
xh(mmax,:)    = NaN;
yh(mmax,:)    = NaN;
xh(:,nmax)    = NaN;
yh(:,nmax)    = NaN;

% Check coordinate system (for grd2net)
spher         = 0;
if strcmp(G.CoordinateSystem,'Spherical');
    spher     = 1;
end

% Read the depth data
if  ~ischar (fildep)
    zh(1:mmax,1:nmax) = -fildep;
elseif exist(fildep,'file') && ~strcmp(fildep(end),'\');
    depthdat      = wldep('read',fildep,[mmax nmax]);
    zh            = depthdat;
    zh(zh==-999)  = NaN;
    zh            = -zh;
    zh(mmax,:)    = NaN;
    zh(:,nmax)    = NaN;
else
    zh            = -5.*ones(mmax,nmax);      % -5 m+NAP as default value, as in D-Flow FM
end

% Make file with bathymetry samples
tmp(:,1)      = reshape(xh,mmax*nmax,1);
tmp(:,2)      = reshape(yh,mmax*nmax,1);
tmp(:,3)      = reshape(zh,mmax*nmax,1);
nonan         = ~isnan(tmp(:,1));
LINE.DATA     = num2cell(tmp(nonan,:));

% Write to unstruc xyz file
dflowfm_io_xydata('write',samfile,LINE);

% Write netCDF-file
if exist(netfile,'file') delete(netfile); end
convertWriteNetcdf;
