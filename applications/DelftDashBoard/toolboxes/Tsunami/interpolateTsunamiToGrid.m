function interpolateTsunamiToGrid(varargin)
% Generates initial conditions file for Delft3D from tsunami input (ArcInfo ASCII grid) 
%
% Input (works with keyword-value pairs):
%
% inifile     = filename of Delft3D ini file
% grdfile     = filename of Delft3D grid file
% tsunamifile = filename of ArcInfo grid file
% 
% Example:
%
% interpolateTsunamiToGrid('inifile','run09.ini','grdfile','chile_coarse.grd','tsunamifile','chile09.asc');
%
% If the model grid is not in lat-lon (WGS 84), the coordinate system of the grid needs to be specified!
%
% e.g. 
%
% gridcs.name='WGS 84 / UTM zone 18S';
% gridcs.type='projected';
% interpolateTsunamiToGrid('inifile','run09.ini','grdfile','chile_coarse.grd','tsunamifile','chile09.asc','gridcs',gridcs);

% Defaults
OPT.kmax=1;
OPT.gridcs.name='WGS 84';
OPT.gridcs.type='geographic';
OPT.tsunamics.name='WGS 84';
OPT.tsunamics.type='geographic';

OPT.adjustbathymetry=0;
OPT.oridepfile=[];
OPT.newdepfile=[];

OPT.inifile=[];

OPT.xgrid=[];
OPT.ygrid=[];
OPT.grdfile=[];
OPT.depth=[];

OPT.xtsunami=[];
OPT.ytsunami=[];
OPT.ztsunami=[];
OPT.tsunamifile=[];

OPT = setproperty(OPT,varargin{:});

% Ini file
if isempty(OPT.inifile)
    error('No initial conditions file specified!');
end

% Grid
if ~isempty(OPT.grdfile)
    % Read grid file
    [x,y,enc,cs,nodatavalue]=wlgrid('read',OPT.grdfile);
    [xz,yz] = getXZYZ(x,y);
elseif ~isempty(OPT.xgrid)
    xz=OPT.xgrid;
    yz=OPT.ygrid;
else
    error('No grid coordinates specified!');
end

%xz=xz-360;

% Tsunami
if ~isempty(OPT.tsunamifile)
    % Read tsunami asc file
    [xx yy zz info] = arc_asc_read(OPT.tsunamifile);
elseif ~isempty(OPT.xtsunami)
    xx=OPT.xtsunami;
    yy=OPT.ytsunami;
    zz=OPT.ztsunami;
else
    error('No tsunami data specified!');
end

mmax=size(xz,1);
nmax=size(xz,2);

% Convert grid to coordinate system of tsunami data
if ~strcmpi(OPT.gridcs.name,OPT.tsunamics.name)
    [xz,yz]=ddb_coordConvert(xz,yz,OPT.gridcs,OPT.tsunamics);
end

zz(isnan(zz))=0;
xz(isnan(xz))=0;
yz(isnan(yz))=0;
iniwl0=interp2(xx,yy,zz,xz,yz);

iniwl0=reshape(iniwl0,mmax,nmax);
iniwl0(isnan(iniwl0))=0;

u=zeros(mmax+1,nmax+1);
iniwl=u;

iniwl(1:end-1,1:end-1)=iniwl0;

if exist(OPT.inifile,'file')
    delete(OPT.inifile);
end
ddb_wldep('append',OPT.inifile,iniwl,'negate','n','bndopt','n');
for k=1:OPT.kmax
    ddb_wldep('append',OPT.inifile,u,'negate','n','bndopt','n');
    ddb_wldep('append',OPT.inifile,u,'negate','n','bndopt','n');
end

% If bathymetry needs to be adjusted
if OPT.adjustbathymetry
    if isempty(OPT.depth)
        % Depth NOT given in matrix so read it from file
        depth=ddb_wldep('read',OPT.oridepfile,[mmax+1 nmax+1]);
        depth=depth(1:end-1,1:end-1);
        newdepth=iniwl0-depth;
    else
        % Depth is given in matrix so read it from file
        newdepth=OPT.depth+iniwl0;
    end
    ddb_wldep('write',OPT.newdepfile,newdepth,'negate','y','bndopt','9');
end
